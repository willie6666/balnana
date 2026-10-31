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
	env["BALNANA_OAUTH_OIDC_PROVIDERS"] = "oidc"
	env["BALNANA_OAUTH_OIDC_OIDC_ISSUER"] = f.srv.URL
	env["BALNANA_OAUTH_OIDC_OIDC_CLIENT_ID"] = "balnana"
	env["BALNANA_OAUTH_OIDC_OIDC_SECRET"] = "s3cret"
	env["BALNANA_OAUTH_OIDC_OIDC_NAME"] = "OpenID Connect"
	if _, set := env["BALNANA_OAUTH_OIDC_OIDC_TRUST_EMAIL"]; !set {
		env["BALNANA_OAUTH_OIDC_OIDC_TRUST_EMAIL"] = "true"
	}
	return env
}

// approve plays the provider's sign-in page for the authorization URL c was
// sent to, and returns the callback path (below BasePath) that follows.
func (f *fakeIdP) approve(c *client, claims map[string]any) string {
	c.t.Helper()
	return f.approveAt(c, "oidc", claims)
}

// approveAt is approve for the provider configured as id.
func (f *fakeIdP) approveAt(c *client, id string, claims map[string]any) string {
	c.t.Helper()
	u, err := url.Parse(c.location)
	if err != nil || !strings.HasPrefix(c.location, f.srv.URL+"/authorize?") {
		c.t.Fatalf("start went to %q", c.location)
	}
	q := u.Query()
	if q.Get("redirect_uri") != "http://localhost:8080/api/v1/auth/oauth/"+id+"/callback" || q.Get("code_challenge_method") != "S256" {
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
	return "/auth/oauth/" + id + "/callback?" + url.Values{"code": {code}, "state": {q.Get("state")}}.Encode()
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

	// A provider that does not vouch for the address: the address is not
	// confirmed.
	eve := c.another()
	f.login(eve, "/groups", map[string]any{"sub": "2", "email": "eve@example.com", "email_verified": "false", "preferred_username": "eve"})
	var eveUser User
	eve.must(200, "GET", "/me", nil, &eveUser)
	if eveUser.Name != "eve" || eveUser.Email == nil || *eveUser.Email != "eve@example.com" || eveUser.EmailVerified {
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
	ana, mail, srv := mailServer(t, f.env(map[string]string{"BALNANA_AUTH_SIGNUP": "invite_only"}))
	anaUser := register(ana, "ana@example.com", "Ana")

	// Not invited: no new account.
	ben := ana.another()
	if e := oauthError(t, f.login(ben, "/groups", person("b", "ben@example.com", "Ben"))); e != "signup_closed" {
		t.Fatal(e)
	}

	// Invited: the provider vouches for the invited address. Inviting takes
	// a confirmed address; Ana's is unconfirmed again below.
	confirmEmail(ana, mail, "ana@example.com")
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

	// An account with the address that never confirmed it waits for the
	// person signing in to say whether it is theirs.
	takeAddress(t, srv.db, anaUser.Id, "ana@example.com")
	other := ana.another()
	pending := pendingToken(t, f.login(other, "/groups", person("a", "ana@example.com", "Ana G")))
	var p OAuthPending
	other.must(200, "POST", "/auth/oauth/pending", OAuthPendingToken{Token: pending}, &p)
	if p.Email != "ana@example.com" || p.Provider != "oidc" || !p.HasPassword || p.Signup {
		t.Fatalf("pending = %+v", p)
	}
	// Forgot the password: the account becomes theirs, and its password and
	// sessions stop working.
	var s Session
	other.must(200, "POST", "/auth/oauth/pending/finish",
		OAuthPendingFinish{Token: pending, Choice: OAuthPendingFinishChoiceTakeOver, Cookie: ptr(true)}, &s)
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
	// The answer is spent.
	other.errorCode(400, "POST", "/auth/oauth/pending/finish",
		OAuthPendingFinish{Token: pending, Choice: OAuthPendingFinishChoiceTakeOver, Cookie: ptr(true)})

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

// pendingToken is the answer the sign-in that went to location waits for.
func pendingToken(t *testing.T, location string) string {
	t.Helper()
	u, err := url.Parse(location)
	if err != nil || u.Query().Get("pending") == "" || u.Query().Get("error") != "" {
		t.Fatalf("sign-in went to %s", location)
	}
	return u.Query().Get("pending")
}

// verifiedOnly holds back accounts whose address is not confirmed, which
// takes email.
func verifiedOnly(env map[string]string) map[string]string {
	env["BALNANA_AUTH_REQUIRE_VERIFIED"] = "true"
	env["BALNANA_SMTP_HOST"] = "smtp.example.com"
	env["BALNANA_SMTP_FROM"] = "Balnana <balnana@example.com>"
	return env
}

// The answers to "is this account yours?": linking keeps the password and
// takes it, and a new account leaves the old one without the address.
func TestOAuthPendingChoices(t *testing.T) {
	f := newFakeIdP(t)
	c := accountsClient(t, f.env(map[string]string{}))
	ana := register(c, "ana@example.com", "Ana")

	// Only the browser that signed in may answer.
	browser := c.another()
	pending := pendingToken(t, f.login(browser, "/groups", person("a", "ana@example.com", "Ana G")))
	stranger := c.another()
	link := OAuthPendingFinish{Token: pending, Choice: OAuthPendingFinishChoiceLink, Password: ptr("correct horse"), Cookie: ptr(true)}
	if code := stranger.errorCode(400, "POST", "/auth/oauth/pending/finish", link); code != "invalid_token" {
		t.Fatal(code)
	}
	wrong := link
	wrong.Password = ptr("a guess")
	if code := browser.errorCode(403, "POST", "/auth/oauth/pending/finish", wrong); code != "wrong_password" {
		t.Fatal(code)
	}
	var s Session
	browser.must(200, "POST", "/auth/oauth/pending/finish", link, &s)
	if s.User.Id != ana.Id || !s.User.EmailVerified || !s.User.HasPassword {
		t.Fatalf("session = %+v", s)
	}
	c.must(200, "GET", "/me", nil, nil)
	again := c.another()
	if e := oauthError(t, f.login(again, "/groups", person("a", "ana@example.com", "Ana G"))); e != "" {
		t.Fatal(e)
	}
	var me User
	again.must(200, "GET", "/me", nil, &me)
	if me.Id != ana.Id {
		t.Fatal("the linked identity reached another account")
	}

	// Not theirs, but the account has no other way in: it keeps the address.
	mallory := c.another()
	taken := register(mallory, "ben@example.com", "Mallory")
	ben := c.another()
	pending = pendingToken(t, f.login(ben, "/groups", person("b", "ben@example.com", "Ben")))
	var p OAuthPending
	ben.must(200, "POST", "/auth/oauth/pending", OAuthPendingToken{Token: pending}, &p)
	if p.Signup {
		t.Fatalf("pending = %+v", p)
	}
	newAccount := OAuthPendingFinish{Token: pending, Choice: OAuthPendingFinishChoiceNewAccount, Cookie: ptr(true)}
	if code := ben.errorCode(400, "POST", "/auth/oauth/pending/finish", newAccount); code != "email_needed" {
		t.Fatal(code)
	}

	// With a provider of its own, a new account gets the address, confirmed.
	var ticket OAuthLinkTicket
	mallory.must(200, "POST", "/me/oauth/oidc", OAuthLinkInput{Password: ptr("correct horse")}, &ticket)
	linking := c.another()
	linking.token = mallory.token
	linking.must(302, "GET", "/auth/oauth/oidc/start?"+url.Values{"app": {"web"}, "link": {ticket.Ticket}}.Encode(), nil, nil)
	linking.must(302, "GET", f.approve(linking, person("m", "mallory@example.com", "Mallory")), nil, nil)
	pending = pendingToken(t, f.login(ben, "/groups", person("b", "ben@example.com", "Ben")))
	ben.must(200, "POST", "/auth/oauth/pending/finish",
		OAuthPendingFinish{Token: pending, Choice: OAuthPendingFinishChoiceNewAccount, Cookie: ptr(true)}, &s)
	if s.User.Id == taken.Id || s.User.Email == nil || *s.User.Email != "ben@example.com" || !s.User.EmailVerified {
		t.Fatalf("session = %+v", s)
	}
	var hers User
	mallory.must(200, "GET", "/me", nil, &hers)
	if hers.Email != nil || hers.EmailVerified {
		t.Fatalf("Mallory kept %+v", hers)
	}
}

// With confirmed addresses required, the provider's word takes the account
// at once; until then an account that never confirmed its address may sign
// in but do nothing else.
func TestOAuthRequireVerified(t *testing.T) {
	f := newFakeIdP(t)
	c := accountsClient(t, verifiedOnly(f.env(map[string]string{})))
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if !info.VerifiedRequired {
		t.Fatal("verifiedRequired is off")
	}
	mallory := register(c, "ana@example.com", "Mallory")
	c.must(200, "GET", "/me", nil, nil)
	if code := c.errorCode(403, "GET", "/me/groups", nil); code != "email_unverified" {
		t.Fatal(code)
	}
	if code := c.errorCode(403, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Mallory"}}); code != "email_unverified" {
		t.Fatal(code)
	}

	ana := c.another()
	if e := oauthError(t, f.login(ana, "/groups", person("a", "ana@example.com", "Ana"))); e != "" {
		t.Fatal(e)
	}
	var me User
	ana.must(200, "GET", "/me", nil, &me)
	if me.Id != mallory.Id || me.HasPassword || !me.EmailVerified {
		t.Fatalf("me = %+v", me)
	}
	c.errorCode(401, "GET", "/me", nil)
	ana.must(200, "GET", "/me/groups", nil, nil)
}

// A provider whose word on addresses is not trusted signs nobody in to an
// account by its address: its person signs in their own way and links it.
func TestOAuthUntrustedProviderAndLinking(t *testing.T) {
	f := newFakeIdP(t)
	c := accountsClient(t, f.env(map[string]string{"BALNANA_OAUTH_OIDC_OIDC_TRUST_EMAIL": "false"}))
	ana := register(c, "ana@example.com", "Ana")
	if e := oauthError(t, f.login(c.another(), "/groups", person("a", "ana@example.com", "Ana"))); e != "email_has_account" {
		t.Fatal(e)
	}

	var links OAuthLinks
	c.must(200, "GET", "/me/oauth", nil, &links)
	if len(links.Providers) != 0 {
		t.Fatalf("links = %+v", links)
	}
	if code := c.errorCode(403, "POST", "/me/oauth/oidc", OAuthLinkInput{Password: ptr("a guess")}); code != "wrong_password" {
		t.Fatal(code)
	}
	c.errorCode(404, "POST", "/me/oauth/google", OAuthLinkInput{Password: ptr("correct horse")})
	var ticket OAuthLinkTicket
	c.must(200, "POST", "/me/oauth/oidc", OAuthLinkInput{Password: ptr("correct horse")}, &ticket)

	// Sent to someone else, the ticket does nothing in their browser.
	start := "/auth/oauth/oidc/start?" + url.Values{"app": {"web"}, "link": {ticket.Ticket}, "next": {"/account"}}.Encode()
	other := c.another()
	register(other, "eve@example.com", "Eve")
	for _, b := range []*client{c.another(), other} {
		b.must(302, "GET", start, nil, nil)
		if e := oauthError(t, b.location); e != "invalid_token" {
			t.Fatal(b.location)
		}
	}

	// The account's own browser uses it, once.
	c.must(200, "POST", "/me/oauth/oidc", OAuthLinkInput{Password: ptr("correct horse")}, &ticket)
	start = "/auth/oauth/oidc/start?" + url.Values{"app": {"web"}, "link": {ticket.Ticket}, "next": {"/account"}}.Encode()
	browser := c.another()
	browser.token = c.token
	browser.must(302, "GET", start, nil, nil)
	browser.must(302, "GET", f.approve(browser, person("a", "ana@example.com", "Ana")), nil, nil)
	if u, _ := url.Parse(browser.location); u.Query().Get("linked") != "oidc" {
		t.Fatal(browser.location)
	}
	reused := c.another()
	reused.token = c.token
	reused.must(302, "GET", start, nil, nil)
	if e := oauthError(t, reused.location); e != "invalid_token" {
		t.Fatal(reused.location)
	}

	in := c.another()
	if e := oauthError(t, f.login(in, "/groups", person("a", "ana@example.com", "Ana"))); e != "" {
		t.Fatal(e)
	}
	var me User
	in.must(200, "GET", "/me", nil, &me)
	if me.Id != ana.Id {
		t.Fatal("the linked identity reached another account")
	}
	c.must(200, "GET", "/me/oauth", nil, &links)
	if len(links.Providers) != 1 || links.Providers[0] != "oidc" {
		t.Fatalf("links = %+v", links)
	}

	// Someone else's identity cannot be linked.
	c.must(200, "POST", "/me/oauth/oidc", OAuthLinkInput{Password: ptr("correct horse")}, &ticket)
	ben := c.another()
	register(ben, "ben@example.com", "Ben")
	var benTicket OAuthLinkTicket
	ben.must(200, "POST", "/me/oauth/oidc", OAuthLinkInput{Password: ptr("correct horse")}, &benTicket)
	b := c.another()
	b.token = ben.token
	b.must(302, "GET", "/auth/oauth/oidc/start?"+url.Values{"app": {"web"}, "link": {benTicket.Ticket}}.Encode(), nil, nil)
	b.must(302, "GET", f.approve(b, person("a", "ana@example.com", "Ana")), nil, nil)
	if e := oauthError(t, b.location); e != "identity_taken" {
		t.Fatal(b.location)
	}

	// Unlinking keeps a way in: the password.
	c.must(204, "DELETE", "/me/oauth/oidc", OAuthLinkInput{Password: ptr("correct horse")}, nil)
	c.errorCode(404, "DELETE", "/me/oauth/oidc", OAuthLinkInput{Password: ptr("correct horse")})
	if e := oauthError(t, f.login(c.another(), "/groups", person("a", "ana@example.com", "Ana"))); e != "email_has_account" {
		t.Fatal(e)
	}

	// An account with only the provider keeps it.
	solo := c.another()
	f.login(solo, "/groups", person("s", "solo@example.com", "Solo"))
	if code := solo.errorCode(409, "DELETE", "/me/oauth/oidc", OAuthLinkInput{}); code != "last_sign_in_method" {
		t.Fatal(code)
	}
}

// Several OpenID Connect providers each have their own button, redirect URI
// and identities.
func TestOAuthSeveralProviders(t *testing.T) {
	a, b := newFakeIdP(t), newFakeIdP(t)
	env := a.env(map[string]string{
		"BALNANA_OAUTH_OIDC_WORK_ISSUER":      b.srv.URL,
		"BALNANA_OAUTH_OIDC_WORK_CLIENT_ID":   "balnana",
		"BALNANA_OAUTH_OIDC_WORK_SECRET":      "s3cret",
		"BALNANA_OAUTH_OIDC_WORK_NAME":        "Work",
		"BALNANA_OAUTH_OIDC_WORK_TRUST_EMAIL": "true",
	})
	env["BALNANA_OAUTH_OIDC_PROVIDERS"] = "oidc,work" // after a.env
	c := accountsClient(t, env)
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if len(info.OauthProviders) != 2 || info.OauthProviders[1].Id != "work" || info.OauthProviders[1].Name != "Work" {
		t.Fatalf("providers = %+v", info.OauthProviders)
	}
	first := c.another()
	a.login(first, "/groups", person("1", "ana@example.com", "Ana"))
	var ana User
	first.must(200, "GET", "/me", nil, &ana)

	// The same subject at the other provider is the same person only by
	// the address it vouches for.
	work := c.another()
	work.must(302, "GET", "/auth/oauth/work/start?app=web", nil, nil)
	u, _ := url.Parse(work.location)
	if !strings.HasPrefix(work.location, b.srv.URL+"/authorize?") ||
		u.Query().Get("redirect_uri") != "http://localhost:8080/api/v1/auth/oauth/work/callback" {
		t.Fatal(work.location)
	}
	work.must(302, "GET", b.approveAt(work, "work", person("1", "ben@example.com", "Ben")), nil, nil)
	var ben User
	work.must(200, "GET", "/me", nil, &ben)
	if ben.Id == ana.Id {
		t.Fatal("another provider's subject signed in to Ana's account")
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
	pending := pendingToken(t, f.login(ana, "/groups", person("a", "ana@example.com", "Ana")))
	ana.must(200, "POST", "/auth/oauth/pending/finish",
		OAuthPendingFinish{Token: pending, Choice: OAuthPendingFinishChoiceTakeOver, Cookie: ptr(true)}, nil)
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
	if hers.Id == me.Id {
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

// The app adds a provider through a code only it can trade: a ticket sent to
// someone else adds nothing for them.
func TestOAuthLinkFromApp(t *testing.T) {
	f := newFakeIdP(t)
	c := accountsClient(t, f.env(map[string]string{}))
	register(c, "ana@example.com", "Ana")
	sum := sha256.Sum256([]byte("the app's own verifier"))
	challenge := base64.RawURLEncoding.EncodeToString(sum[:])
	link := func() string {
		var ticket OAuthLinkTicket
		c.must(200, "POST", "/me/oauth/oidc", OAuthLinkInput{Password: ptr("correct horse")}, &ticket)
		browser := c.another()
		browser.must(302, "GET", "/auth/oauth/oidc/start?"+url.Values{
			"app": {"android"}, "challenge": {challenge}, "link": {ticket.Ticket}}.Encode(), nil, nil)
		browser.must(302, "GET", f.approve(browser, person("a", "ana@example.com", "Ana")), nil, nil)
		u, _ := url.Parse(browser.location)
		if u.Query().Get("linked") != "oidc" || u.Query().Get("code") == "" {
			t.Fatal(browser.location)
		}
		return u.Query().Get("code")
	}
	var links OAuthLinks
	if e := c.another().errorCode(400, "POST", "/auth/oauth/exchange", OAuthExchange{Code: link(), Verifier: "a guess"}); e != "invalid_token" {
		t.Fatal(e)
	}
	c.must(200, "GET", "/me/oauth", nil, &links)
	if len(links.Providers) != 0 {
		t.Fatalf("links = %+v", links)
	}

	var s Session
	c.must(200, "POST", "/auth/oauth/exchange", OAuthExchange{Code: link(), Verifier: "the app's own verifier"}, &s)
	if s.Token != nil || !s.User.EmailVerified {
		t.Fatalf("session = %+v", s)
	}
	c.must(200, "GET", "/me/oauth", nil, &links)
	if len(links.Providers) != 1 {
		t.Fatalf("links = %+v", links)
	}
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
	next.OIDC = []config.OIDC{{OAuthClient: cfg.OIDC[0].OAuthClient, ID: "oidc", Issuer: b.srv.URL, Name: "New provider"}}
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

// A web app on another origin listed in BALNANA_CORS_ORIGINS cannot use this
// server's cookie: it signs in with a bearer token, by password or through a
// provider, as the Android app does.
func TestCrossOriginWebApp(t *testing.T) {
	const app = "https://app.example"
	f := newFakeIdP(t)
	c, _, s := mailServer(t, f.env(map[string]string{"BALNANA_CORS_ORIGINS": app}))
	browser := http.Header{"Origin": {app}, "Sec-Fetch-Site": {"cross-site"}}
	c.header = browser

	// The preflight lets it send its token.
	req := httptest.NewRequest(http.MethodOptions, BasePath+"/me", nil)
	req.Header.Set("Origin", app)
	req.Header.Set("Access-Control-Request-Method", "GET")
	req.Header.Set("Access-Control-Request-Headers", "authorization")
	rec := httptest.NewRecorder()
	c.h.ServeHTTP(rec, req)
	if rec.Code != http.StatusNoContent || rec.Header().Get("Access-Control-Allow-Origin") != app ||
		!strings.Contains(rec.Header().Get("Access-Control-Allow-Headers"), "Authorization") {
		t.Fatalf("preflight: %d %v", rec.Code, rec.Header())
	}

	in := RegisterInput{Email: ptr("ana@example.com"), Password: "correct horse", Name: "Ana", Cookie: ptr(true)}
	if code := c.errorCode(403, "POST", "/auth/register", in); code != "bad_origin" {
		t.Fatal(code)
	}
	in.Cookie = ptr(false)
	var signedUp Session
	c.must(201, "POST", "/auth/register", in, &signedUp)
	if signedUp.Token == nil || len(c.jar) != 0 {
		t.Fatalf("session %+v, cookies %v", signedUp, c.jar)
	}
	login := c.another()
	login.header = browser
	var signedIn Session
	login.must(200, "POST", "/auth/login", LoginInput{Login: "ana@example.com", Password: "correct horse"}, &signedIn)
	login.token = *signedIn.Token
	var me User
	login.must(200, "GET", "/me", nil, &me)
	if me.Name != "Ana" {
		t.Fatalf("me = %+v", me)
	}

	// A session in use is renewed without a cookie.
	ctx := context.Background()
	if _, err := s.db.Exec(ctx, `update sessions set last_used_at = now() - interval '2 days',
		expires_at = now() + interval '1 hour' where token_hash = $1`, hashToken(login.token)); err != nil {
		t.Fatal(err)
	}
	login.must(200, "GET", "/me", nil, nil)
	var expires time.Time
	if err := s.db.QueryRow(ctx, `select expires_at from sessions where token_hash = $1`, hashToken(login.token)).
		Scan(&expires); err != nil || time.Until(expires) < sessionLifetime-time.Hour || len(login.jar) != 0 {
		t.Fatalf("expires %v (%v), cookies %v", expires, err, login.jar)
	}

	// A provider's sign-in comes back to the app as a code for its verifier.
	start := func(q url.Values) *client {
		b := c.another()
		b.must(302, "GET", "/auth/oauth/oidc/start?"+q.Encode(), nil, nil)
		return b
	}
	sum := sha256.Sum256([]byte("the web app's verifier"))
	challenge := base64.RawURLEncoding.EncodeToString(sum[:])
	for _, q := range []url.Values{
		{"app": {"web"}, "origin": {"https://evil.example"}, "challenge": {challenge}},
		{"app": {"web"}, "origin": {app + "/"}, "challenge": {challenge}},
	} {
		if code := c.errorCode(400, "GET", "/auth/oauth/oidc/start?"+q.Encode(), nil); code != "invalid_origin" {
			t.Fatal(q, code)
		}
	}
	noChallenge := "/auth/oauth/oidc/start?app=web&origin=" + url.QueryEscape(app)
	if code := c.errorCode(400, "GET", noChallenge, nil); code != "invalid_challenge" {
		t.Fatal(code)
	}
	b := start(url.Values{"app": {"web"}, "origin": {app}, "challenge": {challenge}, "next": {"/groups"}})
	b.must(302, "GET", f.approve(b, person("1", "ana@example.com", "Ana")), nil, nil)
	u, err := url.Parse(b.location)
	if err != nil || !strings.HasPrefix(b.location, app+"/oauth-done?") || u.Query().Get("next") != "/groups" {
		t.Fatal(b.location)
	}
	b.errorCode(401, "GET", "/me", nil)
	// The account's address was never confirmed, so the app asks whether
	// it is theirs, with its verifier.
	var viaProvider Session
	finish := OAuthPendingFinish{Token: u.Query().Get("pending"), Choice: OAuthPendingFinishChoiceLink,
		Password: ptr("correct horse"), Cookie: ptr(false)}
	if code := c.errorCode(400, "POST", "/auth/oauth/pending/finish", finish); code != "invalid_token" {
		t.Fatal(code)
	}
	finish.Verifier = ptr("the web app's verifier")
	c.must(200, "POST", "/auth/oauth/pending/finish", finish, &viaProvider)
	if viaProvider.Token == nil || viaProvider.User.Id != me.Id {
		t.Fatalf("session = %+v", viaProvider)
	}

	// A "*" list lets any site call the API, but sends codes to none.
	wild := accountsClient(t, f.env(map[string]string{"BALNANA_CORS_ORIGINS": "*"}))
	q := url.Values{"app": {"web"}, "origin": {app}, "challenge": {challenge}}
	if code := wild.errorCode(400, "GET", "/auth/oauth/oidc/start?"+q.Encode(), nil); code != "invalid_origin" {
		t.Fatal(code)
	}
}

// Without a password, only a new session makes the changes a password guards:
// a session stolen long ago can't lock its owner out.
func TestRecentSignIn(t *testing.T) {
	f := newFakeIdP(t)
	c, _, pool := adminClient(t, f.env(map[string]string{"BALNANA_AUTH_MODE": "accounts"}))
	f.login(c, "/groups", person("a", "ana@example.com", "Ana"))
	var ticket OAuthLinkTicket
	c.must(200, "POST", "/me/oauth/oidc", OAuthLinkInput{}, &ticket)

	if _, err := pool.Exec(context.Background(), `update sessions set created_at = now() - $1::interval`, "16 minutes"); err != nil {
		t.Fatal(err)
	}
	for path, body := range map[string]any{
		"/me/delete":     AccountDelete{},
		"/me/oauth/oidc": OAuthLinkInput{},
		"/me/email":      ChangeEmailJSONRequestBody{Email: "eve@example.com"},
		"/me/password":   ChangePasswordJSONRequestBody{NewPassword: "correct horse"},
	} {
		if code := c.errorCode(403, "POST", path, body); code != "recent_sign_in_required" {
			t.Errorf("%s: %s", path, code)
		}
	}
	if code := c.errorCode(403, "DELETE", "/me/oauth/oidc", OAuthLinkInput{}); code != "recent_sign_in_required" {
		t.Error(code)
	}

	// Signing in again makes the session new.
	f.login(c, "/groups", person("a", "ana@example.com", "Ana"))
	c.must(200, "POST", "/me/oauth/oidc", OAuthLinkInput{}, &ticket)
}

// Removing a way to sign in takes the password of an account that has one.
func TestUnlinkOAuthAsksPassword(t *testing.T) {
	f := newFakeIdP(t)
	c, _, pool := adminClient(t, f.env(map[string]string{"BALNANA_AUTH_MODE": "accounts"}))
	ana := register(c, "ana@example.com", "Ana")
	if _, err := pool.Exec(context.Background(),
		`insert into oauth_identities (provider, issuer, subject, user_id) values ('oidc', 'issuer', 'a', $1)`, ana.Id); err != nil {
		t.Fatal(err)
	}
	if code := c.errorCode(403, "DELETE", "/me/oauth/oidc", OAuthLinkInput{}); code != "wrong_password" {
		t.Fatal(code)
	}
	if code := c.errorCode(403, "DELETE", "/me/oauth/oidc", OAuthLinkInput{Password: ptr("a guess")}); code != "wrong_password" {
		t.Fatal(code)
	}
	c.must(204, "DELETE", "/me/oauth/oidc", OAuthLinkInput{Password: ptr("correct horse")}, nil)
}
