package api

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"time"

	"github.com/coreos/go-oidc/v3/oidc"
	"github.com/jackc/pgx/v5"

	"balnana/internal/config"
)

// Sign in with Apple, from the iOS app. The app asks Apple itself
// (AuthenticationServices) and sends the identity token it got, which is
// checked against Apple's keys for the app's bundle ID. That needs no
// secret, unlike Apple's web sign-in, so only the iOS app offers it. The
// rest is the OpenID Connect sign-in's: the same accounts, identities,
// pending choices and codes.

const appleID = "apple"

// appleIssuer signs Apple's identity tokens. Tests point it elsewhere.
var appleIssuer = "https://appleid.apple.com"

// newAppleProvider is nil until the iOS app's bundle ID is set, and in link mode.
func newAppleProvider(cfg *config.Config) *oauthProvider {
	if cfg.AppleBundleID == "" || cfg.AuthMode != config.AuthModeAccounts {
		return nil
	}
	// Apple confirms every address it hands out, its relay addresses too.
	return &oauthProvider{id: appleID, issuer: appleIssuer,
		client: config.OAuthClient{ClientID: cfg.AppleBundleID, TrustEmail: true}}
}

// appleNonce is what the app gave Apple for nonce: the hex SHA-256 of what
// it sends here, so the token can't be used by anyone who didn't make it.
func appleNonce(raw string) string {
	sum := sha256.Sum256([]byte(raw))
	return hex.EncodeToString(sum[:])
}

// verifyApple checks the identity token and returns who it names.
func verifyApple(ctx context.Context, p *oauthProvider, token, nonce string) (string, idClaims, error) {
	var c idClaims
	if len(nonce) < 16 || len(token) > maxSignedTransaction {
		return "", c, errors.New("bad nonce or token")
	}
	prov, err := p.discover()
	if err != nil {
		return "", c, err
	}
	id, err := prov.Verifier(&oidc.Config{ClientID: p.client.ClientID}).Verify(ctx, token)
	if err != nil {
		return "", c, err
	}
	if id.Nonce != appleNonce(nonce) {
		return "", c, errors.New("wrong nonce")
	}
	if err := id.Claims(&c); err != nil {
		return "", c, err
	}
	return id.Subject, c, nil
}

func (s *Server) SignInWithApple(ctx context.Context, req SignInWithAppleRequestObject) (SignInWithAppleResponseObject, error) {
	if err := s.requireAccounts(); err != nil {
		return nil, err
	}
	p := s.settings.Load().apple
	if p == nil {
		return nil, errNotFound
	}
	in := req.Body
	if in.Link == nil && (in.Challenge == nil || !pkceChallenge.MatchString(*in.Challenge)) {
		return nil, badRequest("invalid_challenge")
	}
	subject, c, err := verifyApple(ctx, p, in.IdentityToken, in.Nonce)
	if err != nil {
		noteMiss(ctx)
		s.log.Info("Sign in with Apple refused", "err", err)
		return nil, badRequest("invalid_token")
	}
	// Apple gives the name only once, to the app, and never in the token.
	if in.Name != nil && c.Name == "" {
		c.Name = *in.Name
	}

	if in.Link != nil {
		u, err := s.requireAccount(ctx)
		if err != nil {
			return nil, err
		}
		var userID string
		var live bool
		err = s.db.QueryRow(ctx, `delete from oauth_link_tickets where ticket_hash = $1 returning user_id::text, expires_at > now()`,
			hashToken(*in.Link)).Scan(&userID, &live)
		if errors.Is(err, pgx.ErrNoRows) || err == nil && (!live || userID != u.id) {
			noteMiss(ctx)
			return nil, badRequest("invalid_token")
		}
		if err != nil {
			return nil, err
		}
		var vouched *string
		if p.vouched(c) {
			vouched = c.email()
		}
		err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
			if err := lockUsersTable(ctx, tx); err != nil {
				return err
			}
			return addIdentity(ctx, tx, u.id, p.id, p.issuer, subject, vouched)
		})
		if err != nil {
			return nil, err
		}
		linked := true
		return SignInWithApple200JSONResponse(AppleSignIn{Linked: &linked}), nil
	}

	var code, pending string
	issue := func(tx pgx.Tx, userID string) error {
		code = secretToken()
		_, err := tx.Exec(ctx, `insert into oauth_codes (code_hash, user_id, challenge, expires_at) values ($1, $2, $3, $4)`,
			hashToken(code), userID, *in.Challenge, time.Now().Add(oauthCodeLifetime))
		return err
	}
	pend := func(tx pgx.Tx, userID, email string) error {
		pending = secretToken()
		_, err := tx.Exec(ctx, `
			insert into oauth_pending (token_hash, provider, issuer, subject, email, user_id, name, avatar_url,
			                           challenge, expires_at)
			values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
			hashToken(pending), p.id, p.issuer, subject, email, userID, c.name(), c.avatar(), *in.Challenge,
			time.Now().Add(oauthLifetime))
		return err
	}
	if err := s.oauthUser(ctx, p, subject, c, issue, pend); err != nil {
		var ae *apiError
		if !errors.As(err, &ae) {
			s.log.Warn("Sign in with Apple failed", "err", err)
		}
		return nil, err
	}
	out := AppleSignIn{}
	if pending != "" {
		out.Pending = &pending
	} else {
		out.Code = &code
	}
	return SignInWithApple200JSONResponse(out), nil
}

// linkableProvider checks that the account page may add provider id: one
// signed in to through the browser, or Apple from the iOS app.
func (s *Server) linkableProvider(id string) error {
	if id == appleID {
		if err := s.requireAccounts(); err != nil {
			return err
		}
		if s.settings.Load().apple == nil {
			return errNotFound
		}
		return nil
	}
	_, err := s.oauthProvider(id)
	return err
}
