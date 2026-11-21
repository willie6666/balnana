package api

import (
	"crypto/sha256"
	"encoding/base64"
	"testing"
	"time"

	"balnana/internal/config"
)

// appleServer is an accounts server whose iOS app signs in with Apple, played
// by a fake provider.
func appleServer(t *testing.T) (*client, *fakeIdP, *Server) {
	t.Helper()
	f := newFakeIdP(t)
	c, _, s := mailServer(t, map[string]string{"BALNANA_APPLE_BUNDLE_ID": "com.balnana.test"})
	if s.settings.Load().apple == nil {
		t.Fatal("no apple provider")
	}
	s.settings.Load().apple = &oauthProvider{id: appleID, issuer: f.srv.URL,
		client: config.OAuthClient{ClientID: "com.balnana.test", TrustEmail: true}}
	return c, f, s
}

// appleToken is an identity token as Apple gives the app for nonce.
func (f *fakeIdP) appleToken(nonce string, claims map[string]any) string {
	full := map[string]any{
		"iss": f.srv.URL, "aud": "com.balnana.test", "sub": "001234.apple",
		"exp": time.Now().Add(time.Hour).Unix(), "iat": time.Now().Unix(),
		"nonce": appleNonce(nonce), "email": "ana@privaterelay.appleid.com", "email_verified": "true",
	}
	for k, v := range claims {
		full[k] = v
	}
	return f.sign(full)
}

func pkce(verifier string) string {
	sum := sha256.Sum256([]byte(verifier))
	return base64.RawURLEncoding.EncodeToString(sum[:])
}

func TestSignInWithApple(t *testing.T) {
	c, f, _ := appleServer(t)
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if info.AppleSignIn == nil || !*info.AppleSignIn || len(info.OauthProviders) != 0 {
		t.Fatalf("server info %+v %+v", info.AppleSignIn, info.OauthProviders)
	}
	nonce, verifier := "a-nonce-of-some-length", "a-verifier-the-app-keeps-to-itself-xxxxxxxx"
	challenge := pkce(verifier)
	in := AppleSignInRequest{IdentityToken: f.appleToken(nonce, nil), Nonce: nonce, Challenge: &challenge, Name: ptr("Ana")}

	// Another nonce, another app, or no challenge: refused.
	wrong := in
	wrong.Nonce = "another-nonce-entirely"
	c.must(400, "POST", "/auth/apple", wrong, nil)
	wrong = in
	wrong.IdentityToken = f.appleToken(nonce, map[string]any{"aud": "com.other"})
	c.must(400, "POST", "/auth/apple", wrong, nil)
	wrong = in
	wrong.Challenge = nil
	c.must(400, "POST", "/auth/apple", wrong, nil)

	var out AppleSignIn
	c.must(200, "POST", "/auth/apple", in, &out)
	if out.Code == nil || out.Pending != nil {
		t.Fatalf("answer %+v", out)
	}
	var s Session
	c.must(200, "POST", "/auth/oauth/exchange", OAuthExchange{Code: *out.Code, Verifier: verifier}, &s)
	if s.Token == nil || s.User.Name != "Ana" || !s.User.EmailVerified {
		t.Fatalf("session %+v", s)
	}
	// Signing in again finds the same account, without a name this time.
	in.Name = nil
	in.IdentityToken = f.appleToken(nonce, nil)
	c.must(200, "POST", "/auth/apple", in, &out)
	var again Session
	c.must(200, "POST", "/auth/oauth/exchange", OAuthExchange{Code: *out.Code, Verifier: verifier}, &again)
	if again.User.Id != s.User.Id {
		t.Fatal("a second account")
	}
}

func TestLinkApple(t *testing.T) {
	c, f, _ := appleServer(t)
	register(c, "bob@example.test", "Bob")
	var ticket OAuthLinkTicket
	c.must(200, "POST", "/me/oauth/apple", OAuthLinkInput{Password: ptr("correct horse")}, &ticket)
	nonce := "a-nonce-of-some-length"
	var out AppleSignIn
	c.must(200, "POST", "/auth/apple", AppleSignInRequest{
		IdentityToken: f.appleToken(nonce, map[string]any{"sub": "bob.apple", "email": "bob@privaterelay.appleid.com"}),
		Nonce:         nonce, Link: &ticket.Ticket,
	}, &out)
	if out.Linked == nil || !*out.Linked {
		t.Fatalf("answer %+v", out)
	}
	// Spent, the ticket links nothing more.
	c.must(400, "POST", "/auth/apple", AppleSignInRequest{
		IdentityToken: f.appleToken(nonce, nil), Nonce: nonce, Link: &ticket.Ticket,
	}, nil)
	// With a password left, Apple can go again.
	c.must(204, "DELETE", "/me/oauth/apple", OAuthLinkInput{Password: ptr("correct horse")}, nil)
}

func TestAppleOffWithoutBundleID(t *testing.T) {
	c, _, s := mailServer(t, map[string]string{})
	if s.settings.Load().apple != nil {
		t.Fatal("apple on")
	}
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if info.AppleSignIn != nil {
		t.Fatal("apple offered")
	}
	c.must(404, "POST", "/auth/apple", AppleSignInRequest{IdentityToken: "x", Nonce: "y", Challenge: ptr(pkce("z"))}, nil)
}
