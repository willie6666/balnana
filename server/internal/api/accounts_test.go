package api

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"balnana/internal/config"
)

func accountsClient(t *testing.T, env map[string]string) *client {
	env["BALNANA_AUTH_MODE"] = "accounts"
	return newClientWith(t, env)
}

// register signs c up and keeps the bearer token.
func register(c *client, email, name string) User {
	c.t.Helper()
	var s Session
	c.must(201, "POST", "/auth/register", RegisterInput{Email: ptr(email), Password: "correct horse", Name: name}, &s)
	if s.Token == nil {
		c.t.Fatal("no token")
	}
	c.token = *s.Token
	return s.User
}

func TestPasswordHash(t *testing.T) {
	h := hashPassword("hunter22")
	if !checkPassword(h, "hunter22") || checkPassword(h, "hunter23") || checkPassword("garbage", "hunter22") {
		t.Fatal("checkPassword wrong")
	}
	if hashPassword("hunter22") == h {
		t.Fatal("no salt")
	}
}

func TestSessions(t *testing.T) {
	c := accountsClient(t, map[string]string{})
	if code := c.errorCode(401, "GET", "/me", nil); code != "sign_in_required" {
		t.Fatal(code)
	}
	u := register(c, "ana@example.com", "Ana")
	var me User
	c.must(200, "GET", "/me", nil, &me)
	if me.Id != u.Id || me.Name != "Ana" || !me.HasPassword {
		t.Fatalf("me = %+v", me)
	}
	if code := c.another().errorCode(409, "POST", "/auth/register", RegisterInput{Email: ptr("ANA@example.com"), Password: "12345678", Name: "Other"}); code != "email_taken" {
		t.Fatal(code)
	}
	if code := c.errorCode(400, "POST", "/auth/register", RegisterInput{Email: ptr("Ana <a@example.com>"), Password: "12345678", Name: "X"}); code != "invalid_email" {
		t.Fatal(code)
	}
	if code := c.errorCode(400, "POST", "/auth/register", RegisterInput{Email: ptr("b@example.com"), Password: "short", Name: "X"}); code != "invalid_password" {
		t.Fatal(code)
	}

	// Sign in on the web: the session lives in an HttpOnly cookie.
	web := c.another()
	if code := web.errorCode(401, "POST", "/auth/login", LoginInput{Login: "ana@example.com", Password: "wrong password"}); code != "invalid_credentials" {
		t.Fatal(code)
	}
	if code := web.errorCode(401, "POST", "/auth/login", LoginInput{Login: "nobody@example.com", Password: "wrong password"}); code != "invalid_credentials" {
		t.Fatal(code)
	}
	var s Session
	web.must(200, "POST", "/auth/login", LoginInput{Login: "Ana@Example.com", Password: "correct horse", Cookie: ptr(true)}, &s)
	if s.Token != nil || len(web.jar) != 1 || !web.jar[0].HttpOnly {
		t.Fatalf("token %v, cookies %v", s.Token, web.jar)
	}
	web.must(200, "PATCH", "/me", UserUpdate{Name: ptr("Ana B"), Locale: ptr("en-GB")}, &me)
	if me.Name != "Ana B" || me.Locale == nil || *me.Locale != "en-GB" {
		t.Fatalf("me = %+v", me)
	}

	// Cookie sessions refuse writes from other sites.
	web.header = http.Header{"Origin": {"https://evil.example"}}
	if code := web.errorCode(403, "PATCH", "/me", UserUpdate{Name: ptr("Evil")}); code != "bad_origin" {
		t.Fatal(code)
	}
	web.header = nil

	// Changing the password signs out the other sessions.
	c.must(204, "POST", "/me/password", PasswordChange{CurrentPassword: ptr("correct horse"), NewPassword: "battery staple"}, nil)
	web.errorCode(401, "GET", "/me", nil)
	if len(web.jar) != 0 {
		t.Fatal("stale cookie kept")
	}
	c.must(200, "GET", "/me", nil, nil)
	if code := c.errorCode(403, "POST", "/me/password", PasswordChange{CurrentPassword: ptr("correct horse"), NewPassword: "whatever123"}); code != "wrong_password" {
		t.Fatal(code)
	}

	c.must(204, "POST", "/auth/logout", nil, nil)
	c.errorCode(401, "GET", "/me", nil)
}

func TestSignupPolicy(t *testing.T) {
	c := accountsClient(t, map[string]string{"BALNANA_AUTH_SIGNUP": "closed"})
	register(c, "first@example.com", "First") // the first account is always allowed
	if code := c.another().errorCode(403, "POST", "/auth/register", RegisterInput{Email: ptr("second@example.com"), Password: "12345678", Name: "Second"}); code != "signup_closed" {
		t.Fatal(code)
	}
}

func TestUsernameAccounts(t *testing.T) {
	c := accountsClient(t, map[string]string{"BALNANA_AUTH_REQUIRE_EMAIL": "false"})
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if info.EmailRequired {
		t.Fatal("email required")
	}
	if code := c.errorCode(400, "POST", "/auth/register", RegisterInput{Password: "12345678", Name: "Ana"}); code != "invalid_username" {
		t.Fatal(code)
	}
	for _, bad := range []string{"an", "ana@home", ".ana", "ana nas"} {
		in := RegisterInput{Username: ptr(bad), Password: "12345678", Name: "Ana"}
		if code := c.errorCode(400, "POST", "/auth/register", in); code != "invalid_username" {
			t.Fatalf("%q: %s", bad, code)
		}
	}
	// No address at all, and a blank one counts as none.
	var s Session
	in := RegisterInput{Username: ptr(" Ana.B "), Email: ptr(""), Password: "correct horse", Name: "Ana"}
	c.must(201, "POST", "/auth/register", in, &s)
	if s.User.Username == nil || *s.User.Username != "ana.b" || s.User.Email != nil {
		t.Fatalf("user = %+v", s.User)
	}
	other := c.another()
	in = RegisterInput{Username: ptr("ANA.B"), Password: "12345678", Name: "Other"}
	if code := other.errorCode(409, "POST", "/auth/register", in); code != "username_taken" {
		t.Fatal(code)
	}
	// An address may come along, and then signs in too.
	in = RegisterInput{Username: ptr("ben"), Email: ptr("ben@example.com"), Password: "correct horse", Name: "Ben"}
	other.must(201, "POST", "/auth/register", in, nil)
	for _, login := range []string{"Ana.B", "ben", "ben@example.com"} {
		c.another().must(200, "POST", "/auth/login", LoginInput{Login: login, Password: "correct horse"}, nil)
	}

	// Requiring addresses again ignores usernames for new accounts, while
	// accounts that have one still sign in with it.
	req := accountsClient(t, map[string]string{"BALNANA_AUTH_REQUIRE_EMAIL": "true"})
	in = RegisterInput{Username: ptr("cy"), Password: "12345678", Name: "Cy"}
	if code := req.errorCode(400, "POST", "/auth/register", in); code != "invalid_email" {
		t.Fatal(code)
	}
	in = RegisterInput{Username: ptr("cy"), Email: ptr("cy@example.com"), Password: "12345678", Name: "Cy"}
	var cy Session
	req.must(201, "POST", "/auth/register", in, &cy)
	if cy.User.Username != nil {
		t.Fatalf("username kept: %v", *cy.User.Username)
	}
}

func TestLinkModeHasNoAccounts(t *testing.T) {
	c := newClient(t)
	if code := c.errorCode(403, "POST", "/auth/login", LoginInput{Login: "a@example.com", Password: "12345678"}); code != "accounts_off" {
		t.Fatal(code)
	}
}

func TestAccountsGroupAccess(t *testing.T) {
	ana := accountsClient(t, map[string]string{})
	if code := ana.errorCode(401, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana"}}); code != "sign_in_required" {
		t.Fatal(code)
	}
	register(ana, "ana@example.com", "Ana")
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &g)
	if g.LinkAccess || g.MyMemberId == nil || *g.MyMemberId != g.Members[0].Id || !g.Members[0].Claimed || !g.Members[0].Owner || g.Members[1].Claimed {
		t.Fatalf("group = %+v", g)
	}
	path := "/g/" + g.Token

	// The link alone is not enough.
	anon := ana.another()
	if code := anon.errorCode(401, "GET", path, nil); code != "sign_in_required" {
		t.Fatal(code)
	}
	ben := ana.another()
	register(ben, "ben@example.com", "Benjamin")
	if code := ben.errorCode(403, "GET", path, nil); code != "not_a_member" {
		t.Fatal(code)
	}
	ben.errorCode(403, "GET", path+"/expenses", nil)

	// Ben sees who he can be and claims his placeholder.
	var info JoinInfo
	ben.must(200, "GET", path+"/join", nil, &info)
	if info.Name != "Flat" || info.Member || len(info.Members) != 2 || !info.Members[0].Claimed || info.Members[1].Claimed {
		t.Fatalf("info = %+v", info)
	}
	if code := ben.errorCode(409, "POST", path+"/join", JoinInput{ClaimMemberId: &g.Members[0].Id}); code != "member_claimed" {
		t.Fatal(code)
	}
	var joined Group
	ben.must(200, "POST", path+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, &joined)
	if joined.MyMemberId == nil || *joined.MyMemberId != g.Members[1].Id {
		t.Fatalf("joined = %+v", joined)
	}
	ben.must(200, "GET", path, nil, nil)

	// The account is the actor; the header is ignored.
	ben.member = g.Members[0].Id
	var e Expense
	ben.must(201, "POST", path+"/expenses", ExpenseInput{
		Title: "Rent", Amount: "100.00", OccurredAt: mustTime(t, "2026-01-01T00:00:00Z"),
		Payers: []PayerInput{{MemberId: g.Members[1].Id, Amount: "100.00"}}, SplitMethod: "equal",
		Splits: []Share{{MemberId: g.Members[0].Id}, {MemberId: g.Members[1].Id}},
	}, &e)
	if e.CreatedBy == nil || *e.CreatedBy != g.Members[1].Id {
		t.Fatalf("createdBy = %v", e.CreatedBy)
	}
	ben.member = ""

	// Only Ana may rename Ana; only the owner may turn on link access.
	if code := ben.errorCode(403, "PATCH", path+"/members/"+g.Members[0].Id, MemberInput{Name: "Anna"}); code != "not_allowed" {
		t.Fatal(code)
	}
	if code := ben.errorCode(403, "PATCH", path, GroupUpdate{LinkAccess: ptr(true)}); code != "owner_only" {
		t.Fatal(code)
	}

	// Home lists the account's groups with its balance.
	var mine GroupSummaryList
	ben.must(200, "GET", "/me/groups", nil, &mine)
	if len(mine.Groups) != 1 || mine.Groups[0].Balance == nil || *mine.Groups[0].Balance != "50.00" {
		t.Fatalf("my groups = %+v", mine)
	}

	// With link access, the link opens the group to anyone again.
	ana.must(200, "PATCH", path, GroupUpdate{LinkAccess: ptr(true)}, &g)
	if !g.LinkAccess {
		t.Fatal("link access not on")
	}
	anon.must(200, "GET", path, nil, nil)

	// A new member joins under their account name, leaves and comes back.
	cy := ana.another()
	register(cy, "cy@example.com", "Cy")
	cy.must(200, "POST", path+"/join", JoinInput{}, &joined)
	cyID := *joined.MyMemberId
	cy.must(204, "DELETE", path+"/members/"+cyID, nil, nil)
	ana.must(200, "PATCH", path, GroupUpdate{LinkAccess: ptr(false)}, nil)
	cy.errorCode(403, "GET", path, nil)
	cy.must(200, "POST", path+"/join", JoinInput{}, &joined)
	if *joined.MyMemberId != cyID {
		t.Fatal("rejoining made a new member")
	}
}

func TestLinkGroupsOff(t *testing.T) {
	ana := accountsClient(t, map[string]string{"BALNANA_LINK_GROUPS": "false"})
	register(ana, "ana@example.com", "Ana")
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana"}, LinkAccess: ptr(true)}, &g)
	if g.LinkAccess {
		t.Fatal("link access on though the server forbids it")
	}
	if code := ana.errorCode(403, "PATCH", "/g/"+g.Token, GroupUpdate{LinkAccess: ptr(true)}); code != "link_groups_off" {
		t.Fatal(code)
	}
}

// Signed-in group writes hold a connection for their transaction, so the
// account must be looked up without needing a second one.
func TestAccountWritesWithSmallPool(t *testing.T) {
	for _, conns := range []int32{1, 2} {
		pool := testDBConns(t, conns)
		cfg := baseConfig(t, map[string]string{"BALNANA_AUTH_MODE": "accounts"})
		c := &client{t: t, h: NewHandler(NewServer(cfg, pool, slog.New(slog.DiscardHandler), "test"), http.NotFoundHandler())}
		register(c, fmt.Sprintf("ana%d@example.com", conns), "Ana")
		var g Group
		c.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana"}}, &g)

		// Stuck writes give up after a while, and fail with a 500.
		const writers = 6
		codes := make(chan int, writers)
		for i := range writers {
			go func() {
				ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
				defer cancel()
				body := fmt.Sprintf(`{"name":"Flat %d"}`, i)
				req := httptest.NewRequestWithContext(ctx, "PATCH", BasePath+"/g/"+g.Token, strings.NewReader(body))
				req.Header.Set("Content-Type", "application/json")
				req.Header.Set("Authorization", "Bearer "+c.token)
				rec := httptest.NewRecorder()
				c.h.ServeHTTP(rec, req)
				codes <- rec.Code
			}()
		}
		for range writers {
			if code := <-codes; code != 200 {
				t.Fatalf("pool of %d: status %d", conns, code)
			}
		}
	}
}

// Another site cannot start a cookie session (login CSRF), with or without
// an earlier cookie; the app on this server and bearer sign-ins still can.
func TestCookieSessionsNeedSameOrigin(t *testing.T) {
	c := accountsClient(t, map[string]string{})
	register(c, "ana@example.com", "Ana")
	evil := http.Header{"Origin": {"https://evil.example"}, "Sec-Fetch-Site": {"cross-site"}}

	web := c.another()
	web.header = evil
	login := LoginInput{Login: "ana@example.com", Password: "correct horse", Cookie: ptr(true)}
	if code := web.errorCode(403, "POST", "/auth/login", login); code != "bad_origin" || len(web.jar) != 0 {
		t.Fatalf("cross-site login: %s, cookies %v", code, web.jar)
	}
	in := RegisterInput{Email: ptr("ben@example.com"), Password: "correct horse", Name: "Ben", Cookie: ptr(true)}
	if code := web.errorCode(403, "POST", "/auth/register", in); code != "bad_origin" || len(web.jar) != 0 {
		t.Fatalf("cross-site register: %s, cookies %v", code, web.jar)
	}

	// A form post from another site is plain text, which the API refuses.
	req := httptest.NewRequest("POST", BasePath+"/auth/login", strings.NewReader(`{"email":"ana@example.com","password":"correct horse","cookie":true}`))
	req.Header.Set("Content-Type", "text/plain")
	rec := httptest.NewRecorder()
	c.h.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnsupportedMediaType || len(rec.Result().Cookies()) != 0 {
		t.Fatalf("plain text login: %d", rec.Code)
	}

	// Native apps send no Origin; a bearer login from elsewhere is fine.
	web.header = http.Header{"Origin": {"https://evil.example"}}
	web.must(200, "POST", "/auth/login", LoginInput{Login: "ana@example.com", Password: "correct horse"}, nil)
	same := c.another()
	same.header = http.Header{"Origin": {"http://example.com"}, "Sec-Fetch-Site": {"same-origin"}}
	same.must(200, "POST", "/auth/login", login, nil)
	if len(same.jar) != 1 {
		t.Fatalf("same-origin cookies %v", same.jar)
	}
}

// A closed server tells the app when its first account may still sign up.
func TestFirstAccountOnClosedServer(t *testing.T) {
	c := accountsClient(t, map[string]string{"BALNANA_AUTH_SIGNUP": "closed"})
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if !info.FirstAccount {
		t.Fatal("fresh closed server: no first account")
	}
	register(c, "ana@example.com", "Ana")
	c.must(200, "GET", "/server-info", nil, &info)
	if info.FirstAccount {
		t.Fatal("first account still offered")
	}
	in := RegisterInput{Email: ptr("ben@example.com"), Password: "correct horse", Name: "Ben"}
	if code := c.another().errorCode(403, "POST", "/auth/register", in); code != "signup_closed" {
		t.Fatal(code)
	}

	open := accountsClient(t, map[string]string{"BALNANA_AUTH_SIGNUP": "open"})
	open.must(200, "GET", "/server-info", nil, &info)
	if info.FirstAccount {
		t.Fatal("open server offers a first account")
	}
}

// In link mode, members claimed by accounts are anyone's to change, as there
// are no accounts; back in accounts mode, they are their accounts' again.
func TestLinkModeClaimedMembers(t *testing.T) {
	pool := testDB(t)
	cfg := baseConfig(t, map[string]string{"BALNANA_AUTH_MODE": "accounts"})
	srv := NewServer(cfg, pool, slog.New(slog.DiscardHandler), "test")
	ana := &client{t: t, h: NewHandler(srv, http.NotFoundHandler())}
	register(ana, "ana@example.com", "Ana")
	g := createGroup(ana, "Ana", "Ben", "Cleo")
	path := "/g/" + g.Token
	ben := ana.another()
	register(ben, "ben@example.com", "Ben")
	ben.must(200, "POST", path+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)

	link := *cfg
	link.AuthMode = config.AuthModeLink
	srv.apply(&link)
	anyone := ana.another()
	anyone.must(200, "PATCH", path+"/members/"+g.Members[0].Id, MemberInput{Name: "Anna"}, nil)
	anyone.must(204, "DELETE", path+"/members/"+g.Members[2].Id, nil, nil)

	srv.apply(cfg)
	if code := ben.errorCode(403, "PATCH", path+"/members/"+g.Members[0].Id, MemberInput{Name: "Ana"}); code != "not_allowed" {
		t.Fatal(code)
	}
	ben.must(200, "PATCH", path+"/members/"+g.Members[1].Id, MemberInput{Name: "Benjamin"}, nil)
	ana.must(200, "PATCH", path+"/members/"+g.Members[1].Id, MemberInput{Name: "Ben"}, nil)
}
