package api

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"sync"
	"testing"
	"time"

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

	// An account with the address that never confirmed it is not taken over.
	other := ana.another()
	if e := oauthError(t, f.login(other, "/groups", person("a", "ana@example.com", "Ana G"))); e != "email_taken" {
		t.Fatal(e)
	}
	// Once confirmed, signing in with the provider reaches it.
	ana.must(204, "POST", "/me/verify-email", nil, nil)
	ana.must(204, "POST", "/auth/verify-email", EmailToken{Token: lastPart(mail.next(t, "ana@example.com"))}, nil)
	if e := oauthError(t, f.login(other, "/groups", person("a", "ana@example.com", "Ana G"))); e != "" {
		t.Fatal(e)
	}
	var me User
	other.must(200, "GET", "/me", nil, &me)
	if me.Id != anaUser.Id || me.Name != "Ana" || !me.HasPassword {
		t.Fatalf("me = %+v", me)
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
