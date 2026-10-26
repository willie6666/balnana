package api

import (
	"context"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"sync"
	"time"

	"github.com/coreos/go-oidc/v3/oidc"
	"github.com/jackc/pgx/v5"
	"golang.org/x/oauth2"

	"balnana/internal/config"
)

// Sign-in with Google and any OpenID Connect provider: the authorization
// code flow with PKCE, the ID token checked against the provider's keys.

const (
	oauthCookie       = "balnana_oauth"
	oauthLifetime     = 10 * time.Minute
	oauthCodeLifetime = 2 * time.Minute
	googleIssuer      = "https://accounts.google.com"
	// The Android app opens links on this scheme (AndroidManifest.xml).
	androidReturn = "balnana://app/oauth-done"
)

// A PKCE S256 challenge: base64url of 32 bytes, unpadded.
var pkceChallenge = regexp.MustCompile(`^[A-Za-z0-9_-]{43}$`)

type oauthProvider struct {
	id     string
	issuer string
	client config.OAuthClient

	mu   sync.Mutex
	oidc *oidc.Provider // discovered on first use
}

func newOAuthProviders(cfg *config.Config) map[string]*oauthProvider {
	ps := map[string]*oauthProvider{}
	if cfg.Google != nil {
		ps["google"] = &oauthProvider{id: "google", issuer: googleIssuer, client: *cfg.Google}
	}
	if cfg.OIDC != nil {
		ps["oidc"] = &oauthProvider{id: "oidc", issuer: cfg.OIDC.Issuer, client: cfg.OIDC.OAuthClient}
	}
	return ps
}

// discover fetches the provider's configuration once. A provider that is
// down when the server starts is asked again on the next sign-in.
func (p *oauthProvider) discover() (*oidc.Provider, error) {
	p.mu.Lock()
	defer p.mu.Unlock()
	if p.oidc == nil {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		prov, err := oidc.NewProvider(ctx, p.issuer)
		if err != nil {
			return nil, err
		}
		p.oidc = prov
	}
	return p.oidc, nil
}

func (s *Server) oauthConfig(p *oauthProvider, prov *oidc.Provider) *oauth2.Config {
	return &oauth2.Config{
		ClientID:     p.client.ClientID,
		ClientSecret: p.client.ClientSecret,
		Endpoint:     prov.Endpoint(),
		RedirectURL:  s.appLink(BasePath+"/auth/oauth/"+p.id+"/callback", nil),
		Scopes:       []string{oidc.ScopeOpenID, "email", "profile"},
	}
}

func (s *Server) oauthProvider(id string) (*oauthProvider, error) {
	if err := s.requireAccounts(); err != nil {
		return nil, err
	}
	p := s.settings.Load().oauth[id]
	if p == nil {
		return nil, errNotFound
	}
	return p, nil
}

// oauthReturn is where the browser goes once the provider is done: the web
// app's /oauth-done page, or the Android app's.
func (s *Server) oauthReturn(app, next string, q url.Values) string {
	q.Set("next", next)
	if app == "android" {
		return androidReturn + "?" + q.Encode()
	}
	return s.appLink("/oauth-done", q)
}

func (s *Server) setOAuthCookie(ctx context.Context, value string, maxAge int) {
	st, _ := ctx.Value(authKey{}).(*authState)
	if st == nil {
		return
	}
	http.SetCookie(st.w, &http.Cookie{
		Name:     oauthCookie,
		Value:    value,
		Path:     BasePath + "/auth/oauth/",
		MaxAge:   maxAge,
		HttpOnly: true,
		Secure:   s.conf().PublicURL.Scheme == "https",
		SameSite: http.SameSiteLaxMode,
	})
}

func (s *Server) StartOAuth(ctx context.Context, req StartOAuthRequestObject) (StartOAuthResponseObject, error) {
	p, err := s.oauthProvider(req.Provider)
	if err != nil {
		return nil, err
	}
	in := req.Params
	next := "/groups"
	if in.Next != nil && strings.HasPrefix(*in.Next, "/") && !strings.HasPrefix(*in.Next, "//") && !strings.Contains(*in.Next, `\`) {
		next = *in.Next
	}
	var challenge *string
	switch in.App {
	case "web":
	case "android":
		if in.Challenge == nil || !pkceChallenge.MatchString(*in.Challenge) {
			return nil, badRequest("invalid_challenge")
		}
		challenge = in.Challenge
	default:
		return nil, badRequest("invalid_app")
	}
	app := string(in.App)

	prov, err := p.discover()
	if err != nil {
		s.log.Warn("OpenID Connect discovery failed", "provider", p.id, "err", err)
		return StartOAuth302Response{Headers: StartOAuth302ResponseHeaders{
			Location: s.oauthReturn(app, next, url.Values{"error": {"oauth_failed"}}),
		}}, nil
	}
	state, verifier, nonce := secretToken(), oauth2.GenerateVerifier(), secretToken()
	if _, err := s.db.Exec(ctx, `delete from oauth_logins where expires_at < now()`); err != nil {
		return nil, err
	}
	_, err = s.db.Exec(ctx, `
		insert into oauth_logins (state_hash, provider, verifier, nonce, app, next, challenge, expires_at)
		values ($1, $2, $3, $4, $5, $6, $7, $8)`,
		hashToken(state), p.id, verifier, nonce, app, next, challenge, time.Now().Add(oauthLifetime))
	if err != nil {
		return nil, err
	}
	s.setOAuthCookie(ctx, state, int(oauthLifetime.Seconds()))

	opts := []oauth2.AuthCodeOption{oauth2.S256ChallengeOption(verifier), oidc.Nonce(nonce)}
	if p.id == "google" {
		// Shared computers: let people pick the account instead of
		// silently taking whichever is signed in to Google.
		opts = append(opts, oauth2.SetAuthURLParam("prompt", "select_account"))
	}
	return StartOAuth302Response{Headers: StartOAuth302ResponseHeaders{
		Location: s.oauthConfig(p, prov).AuthCodeURL(state, opts...),
	}}, nil
}

type oauthLogin struct {
	app, next, verifier, nonce string
	challenge                  *string
}

// takeOAuthLogin spends the sign-in that state belongs to. The browser must
// have the same state in its cookie: a callback link someone else started
// does nothing.
func takeOAuthLogin(ctx context.Context, q querier, provider string, state, cookie *string) (*oauthLogin, error) {
	if state == nil || cookie == nil || *state == "" || *state != *cookie {
		return nil, nil
	}
	var l oauthLogin
	err := q.QueryRow(ctx, `
		delete from oauth_logins where state_hash = $1 and provider = $2 and expires_at > now()
		returning app, next, verifier, nonce, challenge`, hashToken(*state), provider).
		Scan(&l.app, &l.next, &l.verifier, &l.nonce, &l.challenge)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return &l, err
}

func (s *Server) OauthCallback(ctx context.Context, req OauthCallbackRequestObject) (OauthCallbackResponseObject, error) {
	p, err := s.oauthProvider(req.Provider)
	if err != nil {
		return nil, err
	}
	in := req.Params
	s.setOAuthCookie(ctx, "", -1)
	login, err := takeOAuthLogin(ctx, s.db, p.id, in.State, in.BalnanaOauth)
	if err != nil {
		return nil, err
	}
	redirect := func(app, next string, q url.Values) OauthCallbackResponseObject {
		return OauthCallback302Response{Headers: OauthCallback302ResponseHeaders{Location: s.oauthReturn(app, next, q)}}
	}
	if login == nil {
		noteMiss(ctx)
		return redirect("web", "/groups", url.Values{"error": {"oauth_failed"}}), nil
	}

	q := url.Values{}
	userID, err := s.finishOAuth(ctx, p, login, in)
	var ae *apiError
	switch {
	case errors.As(err, &ae):
		q.Set("error", ae.code)
	case err != nil:
		s.log.Warn("OAuth sign-in failed", "provider", p.id, "err", err)
		q.Set("error", "oauth_failed")
	case login.app == "android":
		code := secretToken()
		_, err := s.db.Exec(ctx, `insert into oauth_codes (code_hash, user_id, challenge, expires_at) values ($1, $2, $3, $4)`,
			hashToken(code), userID, *login.challenge, time.Now().Add(oauthCodeLifetime))
		if err != nil {
			return nil, err
		}
		q.Set("code", code)
	default:
		if _, err := s.startSession(ctx, s.db, userID, true); err != nil {
			return nil, err
		}
	}
	return redirect(login.app, login.next, q), nil
}

// finishOAuth trades the provider's code for an ID token and returns the
// account it signs in to.
func (s *Server) finishOAuth(ctx context.Context, p *oauthProvider, login *oauthLogin, in OauthCallbackParams) (string, error) {
	if in.Error != nil {
		if *in.Error == "access_denied" {
			return "", badRequest("oauth_cancelled")
		}
		return "", fmt.Errorf("provider error %q", *in.Error)
	}
	if in.Code == nil {
		return "", errors.New("no code")
	}
	prov, err := p.discover()
	if err != nil {
		return "", err
	}
	token, err := s.oauthConfig(p, prov).Exchange(ctx, *in.Code, oauth2.VerifierOption(login.verifier))
	if err != nil {
		return "", err
	}
	raw, _ := token.Extra("id_token").(string)
	if raw == "" {
		return "", errors.New("no ID token")
	}
	id, err := prov.Verifier(&oidc.Config{ClientID: p.client.ClientID}).Verify(ctx, raw)
	if err != nil {
		return "", err
	}
	if id.Nonce != login.nonce {
		return "", errors.New("wrong nonce")
	}
	var c idClaims
	if err := id.Claims(&c); err != nil {
		return "", err
	}
	return s.oauthUser(ctx, p.id, id.Subject, c)
}

type idClaims struct {
	Email             string    `json:"email"`
	EmailVerified     claimBool `json:"email_verified"`
	Name              string    `json:"name"`
	PreferredUsername string    `json:"preferred_username"`
	Picture           string    `json:"picture"`
}

// claimBool reads true and "true": some providers send booleans as strings.
type claimBool bool

func (b *claimBool) UnmarshalJSON(data []byte) error {
	*b = claimBool(string(data) == "true" || string(data) == `"true"`)
	return nil
}

// email is the address the provider vouches for, or nil.
func (c idClaims) email() *string {
	email, err := cleanEmail(c.Email)
	if err != nil || !c.EmailVerified {
		return nil
	}
	return &email
}

func (c idClaims) name() string {
	for _, n := range []string{c.Name, c.PreferredUsername, strings.Split(c.Email, "@")[0]} {
		if r := []rune(strings.TrimSpace(n)); len(r) > maxNameLen {
			n = string(r[:maxNameLen])
		}
		if name, err := cleanName(n); err == nil {
			return name
		}
	}
	return "Balnana user"
}

// oauthUser finds the account of a provider identity. An account with the
// address the provider vouches for gets the identity; failing that, a new
// account is made if sign-up allows it.
func (s *Server) oauthUser(ctx context.Context, provider, subject string, c idClaims) (string, error) {
	var userID string
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		err := tx.QueryRow(ctx, `select user_id::text from oauth_identities where provider = $1 and subject = $2`,
			provider, subject).Scan(&userID)
		if !errors.Is(err, pgx.ErrNoRows) {
			return err
		}
		if _, err := tx.Exec(ctx, `lock table users in share row exclusive mode`); err != nil {
			return err
		}
		email := c.email()
		if email != nil {
			var verified bool
			err := tx.QueryRow(ctx, `select id::text, email_verified from users where email = $1`, *email).Scan(&userID, &verified)
			switch {
			case err == nil && !verified:
				// Whoever made that account may not own the address, and
				// would keep its password.
				return conflict("email_taken")
			case err != nil && !errors.Is(err, pgx.ErrNoRows):
				return err
			}
		}
		if userID == "" {
			// An invitation to the address the provider vouches for counts.
			invited := false
			if email != nil {
				err := tx.QueryRow(ctx, `select exists (select 1 from invites where email = $1 and expires_at > now())`,
					*email).Scan(&invited)
				if err != nil {
					return err
				}
			}
			if err := s.signupAllowed(ctx, tx, invited); err != nil {
				return err
			}
			var avatar *string
			if strings.HasPrefix(c.Picture, "https://") {
				avatar = &c.Picture
			}
			err := tx.QueryRow(ctx, `
				insert into users (email, email_verified, display_name, avatar_url)
				values ($1, $2, $3, $4) returning id::text`, email, email != nil, c.name(), avatar).Scan(&userID)
			if err != nil {
				return err
			}
		}
		_, err = tx.Exec(ctx, `insert into oauth_identities (provider, subject, user_id) values ($1, $2, $3)`,
			provider, subject, userID)
		return err
	})
	return userID, err
}

func (s *Server) ExchangeOAuthCode(ctx context.Context, req ExchangeOAuthCodeRequestObject) (ExchangeOAuthCodeResponseObject, error) {
	if err := s.requireAccounts(); err != nil {
		return nil, err
	}
	in := req.Body
	sum := sha256.Sum256([]byte(in.Verifier))
	// Spent whatever the verifier, so it cannot be guessed at.
	var u user
	var challenge string
	var live bool
	err := s.db.QueryRow(ctx, `
		delete from oauth_codes where code_hash = $1
		returning user_id::text, challenge, expires_at > now()`, hashToken(in.Code)).Scan(&u.id, &challenge, &live)
	if errors.Is(err, pgx.ErrNoRows) || err == nil && (!live || challenge != base64.RawURLEncoding.EncodeToString(sum[:])) {
		noteMiss(ctx)
		return nil, badRequest("invalid_token")
	}
	if err != nil {
		return nil, err
	}
	err = s.db.QueryRow(ctx, `
		select email::text, email_verified, password_hash is not null, display_name, locale
		from users where id = $1`, u.id).Scan(&u.email, &u.verified, &u.hasPassword, &u.name, &u.locale)
	if err != nil {
		return nil, err
	}
	out := Session{User: u.api()}
	if out.Token, err = s.startSession(ctx, s.db, u.id, false); err != nil {
		return nil, err
	}
	return ExchangeOAuthCode200JSONResponse(out), nil
}
