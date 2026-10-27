package api

import (
	"context"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"sync"
	"testing"
	"time"

	"balnana/internal/config"
	"github.com/go-jose/go-jose/v4"
)

// fakeIdP is an OpenID Connect provider that approves whatever sign-in a
// test hands it.
type fakeIdP struct {
	t   *testing.T
	srv *httptest.Server
	key *rsa.PrivateKey

	mu     sync.Mutex
	grants map[string]fakeGrant // by code
}

type fakeGrant struct {
	claims    map[string]any
	challenge string
}

func newFakeIdP(t *testing.T) *fakeIdP {
	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	f := &fakeIdP{t: t, key: key, grants: map[string]fakeGrant{}}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /.well-known/openid-configuration", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, 200, map[string]any{
			"issuer":                                f.srv.URL,
			"authorization_endpoint":                f.srv.URL + "/authorize",
			"token_endpoint":                        f.srv.URL + "/token",
			"jwks_uri":                              f.srv.URL + "/jwks",
			"id_token_signing_alg_values_supported": []string{"RS256"},
		})
	})
	mux.HandleFunc("GET /jwks", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, 200, jose.JSONWebKeySet{Keys: []jose.JSONWebKey{
			{Key: &key.PublicKey, KeyID: "k1", Algorithm: "RS256", Use: "sig"},
		}})
	})
	mux.HandleFunc("POST /token", func(w http.ResponseWriter, r *http.Request) {
		_ = r.ParseForm()
		id, secret, ok := r.BasicAuth()
		if !ok {
			id, secret = r.Form.Get("client_id"), r.Form.Get("client_secret")
		}
		f.mu.Lock()
		g, found := f.grants[r.Form.Get("code")]
		delete(f.grants, r.Form.Get("code"))
		f.mu.Unlock()
		sum := sha256.Sum256([]byte(r.Form.Get("code_verifier")))
		if id != "balnana" || secret != "s3cret" || !found || base64.RawURLEncoding.EncodeToString(sum[:]) != g.challenge {
			writeJSON(w, 400, map[string]string{"error": "invalid_grant"})
			return
		}
		writeJSON(w, 200, map[string]any{"access_token": "at", "token_type": "Bearer", "id_token": f.sign(g.claims)})
	})
	f.srv = httptest.NewServer(mux)
	t.Cleanup(f.srv.Close)
	return f
}

func (f *fakeIdP) sign(claims map[string]any) string {
	signer, err := jose.NewSigner(jose.SigningKey{Algorithm: jose.RS256, Key: f.key},
		(&jose.SignerOptions{}).WithType("JWT").WithHeader("kid", "k1"))
	if err != nil {
		f.t.Fatal(err)
	}
	payload, _ := json.Marshal(claims)
	jws, err := signer.Sign(payload)
	if err != nil {
		f.t.Fatal(err)
	}
	s, _ := jws.CompactSerialize()
	return s
}

// env configures a server to use this provider.
func (f *fakeIdP) env(env map[string]string) map[string]string {
	env["BALNANA_OAUTH_OIDC_ISSUER"] = f.srv.URL
	env["BALNANA_OAUTH_OIDC_CLIENT_ID"] = "balnana"
	env["BALNANA_OAUTH_OIDC_SECRET"] = "s3cret"
	return env
}

// approve plays the provider's sign-in page for the authorization URL c was
// sent to, and returns the callback path (below BasePath) that follows.
func (f *fakeIdP) approve(c *client, claims map[string]any) string {
	c.t.Helper()
	u, err := url.Parse(c.location)
	if err != nil || !strings.HasPrefix(c.location, f.srv.URL+"/authorize?") {
		c.t.Fatalf("start went to %q", c.location)
	}
	q := u.Query()
	if q.Get("redirect_uri") != "http://localhost:8080/api/v1/auth/oauth/oidc/callback" || q.Get("code_challenge_method") != "S256" {
		c.t.Fatalf("authorization URL %s", c.location)
	}
	full := map[string]any{
		"iss":   f.srv.URL,
		"aud":   "balnana",
		"exp":   time.Now().Add(time.Hour).Unix(),
		"iat":   time.Now().Unix(),
		"nonce": q.Get("nonce"),
	}
	for k, v := range claims {
		full[k] = v
	}
	code := secretToken()
	f.mu.Lock()
	f.grants[code] = fakeGrant{claims: full, challenge: q.Get("code_challenge")}
	f.mu.Unlock()
	return "/auth/oauth/oidc/callback?" + url.Values{"code": {code}, "state": {q.Get("state")}}.Encode()
}

// login signs c in on the web through the provider and returns where the
// callback sends the browser.
func (f *fakeIdP) login(c *client, next string, claims map[string]any) string {
	c.t.Helper()
	c.must(302, "GET", "/auth/oauth/oidc/start?"+url.Values{"app": {"web"}, "next": {next}}.Encode(), nil, nil)
	c.must(302, "GET", f.approve(c, claims), nil, nil)
	return c.location
}

func person(sub, email, name string) map[string]any {
	return map[string]any{"sub": sub, "email": email, "email_verified": true, "name": name}
}

func oauthError(t *testing.T, location string) string {
	t.Helper()
	u, err := url.Parse(location)
	if err != nil {
		t.Fatal(err)
	}
	return u.Query().Get("error")
}

func TestOAuthWeb(t *testing.T) {
	f := newFakeIdP(t)
	c := accountsClient(t, f.env(map[string]string{}))
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if len(info.OauthProviders) != 1 || info.OauthProviders[0].Id != "oidc" || info.OauthProviders[0].Name != "OpenID Connect" {
		t.Fatalf("providers = %+v", info.OauthProviders)
	}

	if loc := f.login(c, "/g/abc/join", person("1", "ana@example.com", "Ana")); loc != "http://localhost:8080/oauth-done?next=%2Fg%2Fabc%2Fjoin" {
		t.Fatal(loc)
	}
	var me User
	c.must(200, "GET", "/me", nil, &me)
	if me.Name != "Ana" || me.Email == nil || *me.Email != "ana@example.com" || !me.EmailVerified || me.HasPassword {
		t.Fatalf("me = %+v", me)
	}

	// The same person again: the same account, and no way out of the app.
	again := c.another()
	if loc := f.login(again, "//evil.example.com", person("1", "ana@example.com", "Ana")); loc != "http://localhost:8080/oauth-done?next=%2Fgroups" {
		t.Fatal(loc)
	}
	var me2 User
	again.must(200, "GET", "/me", nil, &me2)
	if me2.Id != me.Id {
		t.Fatal("second sign-in made another account")
	}

	// A provider that does not vouch for the address: no address on the account.
	eve := c.another()
	f.login(eve, "/groups", map[string]any{"sub": "2", "email": "eve@example.com", "email_verified": "false", "preferred_username": "eve"})
	var eveUser User
	eve.must(200, "GET", "/me", nil, &eveUser)
	if eveUser.Name != "eve" || eveUser.Email != nil || eveUser.EmailVerified {
		t.Fatalf("me = %+v", eveUser)
	}

	// A callback works once, and only in the browser that started it.
	ben := c.another()
	ben.must(302, "GET", "/auth/oauth/oidc/start?app=web", nil, nil)
	callback := f.approve(ben, person("3", "ben@example.com", "Ben"))
	mallory := c.another()
	mallory.must(302, "GET", callback, nil, nil)
	if e := oauthError(t, mallory.location); e != "oauth_failed" {
		t.Fatal(mallory.location)
	}
	mallory.errorCode(401, "GET", "/me", nil)
	ben.must(302, "GET", callback, nil, nil)
	if e := oauthError(t, ben.location); e != "" {
		t.Fatal(ben.location)
	}
	ben.must(302, "GET", callback, nil, nil)
	if e := oauthError(t, ben.location); e != "oauth_failed" {
		t.Fatal(ben.location)
	}

	// Saying no at the provider.
	cy := c.another()
	cy.must(302, "GET", "/auth/oauth/oidc/start?app=web", nil, nil)
	state, _ := url.Parse(cy.location)
	cy.must(302, "GET", "/auth/oauth/oidc/callback?error=access_denied&state="+state.Query().Get("state"), nil, nil)
	if e := oauthError(t, cy.location); e != "oauth_cancelled" {
		t.Fatal(cy.location)
	}

	c.errorCode(404, "GET", "/auth/oauth/google/start?app=web", nil)
}

func TestOAuthAccountsAndSignup(t *testing.T) {
	f := newFakeIdP(t)
	ana, mail := mailClient(t, f.env(map[string]string{"BALNANA_AUTH_SIGNUP": "invite_only"}))
	anaUser := register(ana, "ana@example.com", "Ana")

	// Not invited: no new account.
	ben := ana.another()
	if e := oauthError(t, f.login(ben, "/groups", person("b", "ben@example.com", "Ben"))); e != "signup_closed" {
		t.Fatal(e)
	}

	// Invited: the provider vouches for the invited address.
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &g)
	ana.must(204, "POST", "/g/"+g.Token+"/invites", InviteInput{Email: "ben@example.com", MemberId: &g.Members[1].Id}, nil)
	mail.next(t, "ben@example.com")
	if e := oauthError(t, f.login(ben, "/g/"+g.Token+"/join", person("b", "ben@example.com", "Ben"))); e != "" {
		t.Fatal(e)
	}
	var info JoinInfo
	ben.must(200, "GET", "/g/"+g.Token+"/join", nil, &info)
	if info.InvitedMemberId == nil || *info.InvitedMemberId != g.Members[1].Id {
		t.Fatalf("invitedMemberId = %v", info.InvitedMemberId)
	}

	// An account with the address that never confirmed it goes to the person
	// the provider vouches for: its password and sessions stop working.
	other := ana.another()
	if e := oauthError(t, f.login(other, "/groups", person("a", "ana@example.com", "Ana G"))); e != "" {
		t.Fatal(e)
	}
	var me User
	other.must(200, "GET", "/me", nil, &me)
	if me.Id != anaUser.Id || me.HasPassword || !me.EmailVerified {
		t.Fatalf("me = %+v", me)
	}
	if code := ana.errorCode(401, "GET", "/me", nil); code != "sign_in_required" {
		t.Fatal(code)
	}
	login := LoginInput{Login: "ana@example.com", Password: "correct horse"}
	if code := ana.another().errorCode(401, "POST", "/auth/login", login); code != "invalid_credentials" {
		t.Fatal(code)
	}

	// The owner sets a password again; another identity with the confirmed
	// address reaches the same account and leaves it be.
	other.must(204, "POST", "/me/password", PasswordChange{NewPassword: "a new password"}, nil)
	third := ana.another()
	if e := oauthError(t, f.login(third, "/groups", person("a2", "ana@example.com", "Ana G"))); e != "" {
		t.Fatal(e)
	}
	third.must(200, "GET", "/me", nil, &me)
	if me.Id != anaUser.Id || me.Name != "Ana" || !me.HasPassword {
		t.Fatalf("me = %+v", me)
	}
}

// Someone who signs up with a provider and then puts another person's address
// on the account must not follow that person in once they sign in with it.
func TestOAuthTakeoverDropsOldIdentities(t *testing.T) {
	f := newFakeIdP(t)
	mallory := accountsClient(t, f.env(map[string]string{}))
	unvouched := map[string]any{"sub": "m", "email": "mallory@example.com", "email_verified": false, "name": "Mallory"}
	f.login(mallory, "/groups", unvouched)
	var before User
	mallory.must(200, "POST", "/me/email", EmailChange{Email: "ana@example.com"}, &before)

	ana := mallory.another()
	if e := oauthError(t, f.login(ana, "/groups", person("a", "ana@example.com", "Ana"))); e != "" {
		t.Fatal(e)
	}
	var me User
	ana.must(200, "GET", "/me", nil, &me)
	if me.Id != before.Id || !me.EmailVerified {
		t.Fatalf("me = %+v", me)
	}
	mallory.errorCode(401, "GET", "/me", nil)

	again := mallory.another()
	f.login(again, "/groups", unvouched)
	var hers User
	again.must(200, "GET", "/me", nil, &hers)
	if hers.Id == me.Id || hers.Email != nil {
		t.Fatalf("Mallory signed in to %+v", hers)
	}
	// Ana still reaches her account.
	anaAgain := ana.another()
	f.login(anaAgain, "/groups", person("a", "ana@example.com", "Ana"))
	anaAgain.must(200, "GET", "/me", nil, &me)
	if me.Id != before.Id {
		t.Fatal("Ana lost her account")
	}
}

func TestOAuthAndroid(t *testing.T) {
	f := newFakeIdP(t)
	c := accountsClient(t, f.env(map[string]string{}))
	if code := c.errorCode(400, "GET", "/auth/oauth/oidc/start?app=android", nil); code != "invalid_challenge" {
		t.Fatal(code)
	}

	signIn := func(verifier string) string {
		sum := sha256.Sum256([]byte(verifier))
		challenge := base64.RawURLEncoding.EncodeToString(sum[:])
		browser := c.another()
		browser.must(302, "GET", "/auth/oauth/oidc/start?app=android&challenge="+challenge, nil, nil)
		browser.must(302, "GET", f.approve(browser, person("1", "ana@example.com", "Ana")), nil, nil)
		u, err := url.Parse(browser.location)
		if err != nil || !strings.HasPrefix(browser.location, "balnana://app/oauth-done?") || u.Query().Get("next") != "/groups" {
			t.Fatal(browser.location)
		}
		browser.errorCode(401, "GET", "/me", nil)
		return u.Query().Get("code")
	}

	// The code is no use without the app's verifier, and spent by trying.
	code := signIn("the app's own verifier")
	if e := c.errorCode(400, "POST", "/auth/oauth/exchange", OAuthExchange{Code: code, Verifier: "a guess"}); e != "invalid_token" {
		t.Fatal(e)
	}
	c.errorCode(400, "POST", "/auth/oauth/exchange", OAuthExchange{Code: code, Verifier: "the app's own verifier"})

	code = signIn("the app's own verifier")
	var s Session
	c.must(200, "POST", "/auth/oauth/exchange", OAuthExchange{Code: code, Verifier: "the app's own verifier"}, &s)
	if s.Token == nil || s.User.Name != "Ana" {
		t.Fatalf("session = %+v", s)
	}
	c.token = *s.Token
	c.must(200, "GET", "/me", nil, nil)
	c.another().errorCode(400, "POST", "/auth/oauth/exchange", OAuthExchange{Code: code, Verifier: "the app's own verifier"})
}

// The address owner taking an account back with a reset link shuts out its
// maker as an OAuth sign-in does: their identity no longer reaches it. On an
// account the owner already had, a reset leaves their identities be.
func TestPasswordResetReclaimsAccount(t *testing.T) {
	f := newFakeIdP(t)
	mallory, mail, s := mailServer(t, f.env(map[string]string{}))
	unvouched := map[string]any{"sub": "m", "email": "mallory@example.com", "email_verified": false, "name": "Mallory"}
	f.login(mallory, "/groups", unvouched)
	var taken User
	mallory.must(200, "GET", "/me", nil, &taken)
	takeAddress(t, s.db, taken.Id, "ana@example.com")

	ana := mallory.another()
	ana.must(204, "POST", "/auth/password-reset", PasswordResetRequest{Email: "ana@example.com"}, nil)
	ana.must(204, "POST", "/auth/password-reset/confirm",
		PasswordReset{Token: lastPart(mail.next(t, "ana@example.com")), NewPassword: "new password"}, nil)
	mallory.errorCode(401, "GET", "/me", nil)
	again := mallory.another()
	f.login(again, "/groups", unvouched)
	var hers User
	again.must(200, "GET", "/me", nil, &hers)
	if hers.Id == taken.Id {
		t.Fatal("Mallory signed back in to the account taken back")
	}

	// Ana's own identity outlives a reset of her verified account.
	f.login(ana, "/groups", person("a", "ana@example.com", "Ana"))
	ana.must(204, "POST", "/auth/password-reset", PasswordResetRequest{Email: "ana@example.com"}, nil)
	ana.must(204, "POST", "/auth/password-reset/confirm",
		PasswordReset{Token: lastPart(mail.next(t, "ana@example.com")), NewPassword: "newer password"}, nil)
	anaAgain := ana.another()
	f.login(anaAgain, "/groups", person("a", "ana@example.com", "Ana"))
	var me User
	anaAgain.must(200, "GET", "/me", nil, &me)
	if me.Id != taken.Id {
		t.Fatalf("me = %+v", me)
	}
}

// A subject is someone only at the issuer that vouched for it: another
// provider in the same place, with the same subjects, signs in other people.
func TestOAuthIssuers(t *testing.T) {
	a, b := newFakeIdP(t), newFakeIdP(t)
	pool := testDB(t)
	cfg := baseConfig(t, a.env(map[string]string{"BALNANA_AUTH_MODE": "accounts"}))
	srv := NewServer(cfg, pool, slog.New(slog.DiscardHandler), "test")
	c := &client{t: t, h: NewHandler(srv, http.NotFoundHandler())}
	login := func(f *fakeIdP, sub, email, name string) User {
		t.Helper()
		in := c.another()
		if e := oauthError(t, f.login(in, "/groups", person(sub, email, name))); e != "" {
			t.Fatal(e)
		}
		var me User
		in.must(200, "GET", "/me", nil, &me)
		return me
	}
	ana := login(a, "1", "ana@example.com", "Ana")

	// Made before issuers were kept, the identity is the configured one's.
	ctx := context.Background()
	if _, err := pool.Exec(ctx, `update oauth_identities set issuer = null`); err != nil {
		t.Fatal(err)
	}
	if err := srv.NameIdentityIssuers(ctx); err != nil {
		t.Fatal(err)
	}
	if me := login(a, "1", "ana@example.com", "Ana"); me.Id != ana.Id {
		t.Fatal("Ana lost her account")
	}
	var identities int
	if err := pool.QueryRow(ctx, `select count(*) from oauth_identities`).Scan(&identities); err != nil {
		t.Fatal(err)
	}
	if identities != 1 {
		t.Fatalf("%d identities", identities)
	}

	next := *cfg
	next.OIDC = &config.OIDC{OAuthClient: cfg.OIDC.OAuthClient, Issuer: b.srv.URL, Name: "New provider"}
	srv.apply(&next)
	ben := login(b, "1", "ben@example.com", "Ben")
	if ben.Id == ana.Id || ben.Email == nil || *ben.Email != "ben@example.com" {
		t.Fatalf("Ben signed in as %+v", ben)
	}

	srv.apply(cfg)
	if me := login(a, "1", "ana@example.com", "Ana"); me.Id != ana.Id {
		t.Fatal("Ana lost her account")
	}
}
