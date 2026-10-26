package api

import (
	"testing"
)

func TestDeleteAccount(t *testing.T) {
	ana := accountsClient(t, map[string]string{})
	register(ana, "ana@example.com", "Ana")
	ben := ana.another()
	register(ben, "ben@example.com", "Ben")

	// A group shared with Ben, one only Ana is in, and one open by link.
	var flat, solo, open Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &flat)
	ben.must(200, "POST", "/g/"+flat.Token+"/join", JoinInput{ClaimMemberId: &flat.Members[1].Id}, nil)
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Solo", Currency: "EUR", Members: []string{"Ana"}}, &solo)
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Open", Currency: "EUR", Members: []string{"Ana"}, LinkAccess: ptr(true)}, &open)

	if code := ana.errorCode(403, "POST", "/me/delete", AccountDelete{}); code != "wrong_password" {
		t.Fatal(code)
	}
	if code := ana.errorCode(403, "POST", "/me/delete", AccountDelete{Password: ptr("wrong password")}); code != "wrong_password" {
		t.Fatal(code)
	}
	ana.must(204, "POST", "/me/delete", AccountDelete{Password: ptr("correct horse")}, nil)

	if code := ana.errorCode(401, "GET", "/me", nil); code != "sign_in_required" {
		t.Fatal(code)
	}
	login := LoginInput{Login: "ana@example.com", Password: "correct horse"}
	if code := ana.another().errorCode(401, "POST", "/auth/login", login); code != "invalid_credentials" {
		t.Fatal(code)
	}

	// Ana's member stays, unclaimed; Ben owns the group now.
	var g Group
	ben.must(200, "GET", "/g/"+flat.Token, nil, &g)
	if a, b := g.Members[0], g.Members[1]; a.Name != "Ana" || a.Claimed || a.Owner || !b.Owner {
		t.Fatalf("members = %+v", g.Members)
	}
	// Nobody could reach Solo any more; Open still has its link.
	if code := ben.errorCode(404, "GET", "/g/"+solo.Token, nil); code != "not_found" {
		t.Fatal(code)
	}
	ben.must(200, "GET", "/g/"+open.Token, nil, nil)

	// The address is free again.
	register(ana.another(), "ana@example.com", "Ana")
}

func TestDeleteAccountWithoutPassword(t *testing.T) {
	f := newFakeIdP(t)
	c := accountsClient(t, f.env(map[string]string{}))
	if e := oauthError(t, f.login(c, "/groups", person("a", "ana@example.com", "Ana"))); e != "" {
		t.Fatal(e)
	}
	c.must(204, "POST", "/me/delete", AccountDelete{}, nil)
	if code := c.errorCode(401, "GET", "/me", nil); code != "sign_in_required" {
		t.Fatal(code)
	}
}

func TestDeleteGroup(t *testing.T) {
	ana := accountsClient(t, map[string]string{})
	register(ana, "ana@example.com", "Ana")
	ben := ana.another()
	register(ben, "ben@example.com", "Ben")
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben"}, LinkAccess: ptr(true)}, &g)
	path := "/g/" + g.Token

	// Holding the link is not enough, nor is being a member.
	if code := ben.errorCode(403, "DELETE", path, nil); code != "not_a_member" {
		t.Fatal(code)
	}
	ben.must(200, "POST", path+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)
	if code := ben.errorCode(403, "DELETE", path, nil); code != "owner_only" {
		t.Fatal(code)
	}
	ana.must(204, "DELETE", path, nil, nil)
	ana.errorCode(404, "GET", path, nil)
	var mine GroupSummaryList
	ben.must(200, "GET", "/me/groups", nil, &mine)
	if len(mine.Groups) != 0 {
		t.Fatalf("groups = %+v", mine.Groups)
	}

	// In link mode the link is enough.
	c := newClientWith(t, map[string]string{"BALNANA_AUTH_MODE": "link"})
	lg := createGroup(c, "Ana", "Ben")
	c.must(204, "DELETE", "/g/"+lg.Token, nil, nil)
	c.errorCode(404, "GET", "/g/"+lg.Token, nil)
}

func TestResetLinkMembersOnly(t *testing.T) {
	ana := accountsClient(t, map[string]string{})
	register(ana, "ana@example.com", "Ana")
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana"}, LinkAccess: ptr(true)}, &g)
	if code := ana.another().errorCode(403, "POST", "/g/"+g.Token+"/reset-link", nil); code != "not_a_member" {
		t.Fatal(code)
	}
	var reset Group
	ana.must(200, "POST", "/g/"+g.Token+"/reset-link", nil, &reset)
	if reset.Token == g.Token {
		t.Fatal("same token")
	}
}

func TestChangeEmail(t *testing.T) {
	c := accountsClient(t, map[string]string{"BALNANA_AUTH_REQUIRE_EMAIL": "false"})
	var s Session
	c.must(201, "POST", "/auth/register", RegisterInput{Username: ptr("ana"), Password: "correct horse", Name: "Ana"}, &s)
	c.token = *s.Token
	other := c.another()
	other.must(201, "POST", "/auth/register", RegisterInput{Username: ptr("ben"), Email: ptr("ben@example.com"), Password: "correct horse", Name: "Ben"}, nil)

	if code := c.errorCode(403, "POST", "/me/email", EmailChange{Email: "ana@example.com"}); code != "wrong_password" {
		t.Fatal(code)
	}
	if code := c.errorCode(409, "POST", "/me/email", EmailChange{Email: "BEN@example.com", Password: ptr("correct horse")}); code != "email_taken" {
		t.Fatal(code)
	}
	var me User
	c.must(200, "POST", "/me/email", EmailChange{Email: "ana@example.com", Password: ptr("correct horse")}, &me)
	if me.Email == nil || *me.Email != "ana@example.com" || me.EmailVerified {
		t.Fatalf("me = %+v", me)
	}
	// It signs in with the address too.
	c.another().must(200, "POST", "/auth/login", LoginInput{Login: "ana@example.com", Password: "correct horse"}, nil)
	var none User
	c.must(200, "POST", "/me/email", EmailChange{Email: "", Password: ptr("correct horse")}, &none)
	if none.Email != nil {
		t.Fatalf("me = %+v", none)
	}

	// An account known by its address keeps one.
	e := accountsClient(t, map[string]string{"BALNANA_AUTH_REQUIRE_EMAIL": "true"})
	register(e, "ana@example.com", "Ana")
	if code := e.errorCode(400, "POST", "/me/email", EmailChange{Email: "", Password: ptr("correct horse")}); code != "email_needed" {
		t.Fatal(code)
	}
}

func TestSignupLimit(t *testing.T) {
	c := accountsClient(t, map[string]string{})
	for i := range signupBurst {
		c.another().must(201, "POST", "/auth/register", RegisterInput{Email: ptr(string(rune('a'+i)) + "@example.com"), Password: "correct horse", Name: "X"}, nil)
	}
	if code := c.another().errorCode(429, "POST", "/auth/register", RegisterInput{Email: ptr("z@example.com"), Password: "correct horse", Name: "X"}); code != "rate_limited" {
		t.Fatal(code)
	}
}

func TestAdminUsers(t *testing.T) {
	c, _, _ := adminClient(t, map[string]string{"BALNANA_AUTH_MODE": "accounts"})
	admin := c.asAdmin(setUp(c))
	register(c.another(), "ana@example.com", "Ana")
	ben := c.another()
	register(ben, "ben@example.com", "Ben")
	createGroup(ben, "Ben")

	if code := c.errorCode(401, "GET", "/admin/users", nil); code != "admin_required" {
		t.Fatal(code)
	}
	var list AdminUserList
	admin.must(200, "GET", "/admin/users", nil, &list)
	if list.Total != 2 || len(list.Users) != 2 || list.Users[0].Name != "Ben" || list.Users[0].Groups != 1 || !list.Users[0].HasPassword {
		t.Fatalf("list = %+v", list)
	}
	admin.must(200, "GET", "/admin/users?q=ANA%40", nil, &list)
	if list.Total != 1 || list.Users[0].Name != "Ana" {
		t.Fatalf("list = %+v", list)
	}
	admin.must(204, "DELETE", "/admin/users/"+list.Users[0].Id, nil, nil)
	admin.errorCode(404, "DELETE", "/admin/users/"+list.Users[0].Id, nil)
	admin.must(200, "GET", "/admin/users", nil, &list)
	if list.Total != 1 || list.Users[0].Name != "Ben" {
		t.Fatalf("list = %+v", list)
	}
}
