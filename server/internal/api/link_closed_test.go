package api

import "testing"

func TestLinkClosed(t *testing.T) {
	ana, f := mailClient(t, map[string]string{})
	register(ana, "ana@example.com", "Ana")
	confirmEmail(ana, f, "ana@example.com")
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben", "Cy"}}, &g)
	path := "/g/" + g.Token
	ana.must(200, "PATCH", path, GroupUpdate{LinkAccess: ptr(true)}, &g)
	if g.LinkClosed || !g.LinkAccess {
		t.Fatalf("new group: linkClosed %v, linkAccess %v", g.LinkClosed, g.LinkAccess)
	}

	// Ben joins while the link is open.
	ben := ana.another()
	register(ben, "ben@example.com", "Ben")
	ben.must(200, "POST", path+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)

	// Any member closes it, and closing turns link access off.
	ben.must(200, "PATCH", path, GroupUpdate{LinkClosed: ptr(true)}, &g)
	if !g.LinkClosed || g.LinkAccess {
		t.Fatalf("closed: linkClosed %v, linkAccess %v", g.LinkClosed, g.LinkAccess)
	}
	if code := ana.errorCode(409, "PATCH", path, GroupUpdate{LinkAccess: ptr(true)}); code != "link_closed" {
		t.Fatal(code)
	}
	var log ActivityPage
	ana.must(200, "GET", path+"/activity", nil, &log)
	if log.Items[0].Action != "group.link_closed" {
		t.Fatalf("last activity %s", log.Items[0].Action)
	}

	// Members keep using it.
	ben.must(200, "GET", path, nil, nil)
	ben.must(200, "GET", path+"/join", nil, nil)

	// The link alone gets no one in, signed in or not.
	if code := ana.another().errorCode(401, "GET", path, nil); code != "sign_in_required" {
		t.Fatal(code)
	}
	cy := ana.another()
	register(cy, "cy@example.com", "Cy")
	for _, method := range []string{"GET", "POST"} {
		if code := cy.errorCode(403, method, path+"/join", JoinInput{}); code != "link_closed" {
			t.Fatalf("%s join: %s", method, code)
		}
	}
	if code := cy.errorCode(403, "GET", path, nil); code != "not_a_member" {
		t.Fatal(code)
	}

	// An email invitation still lets Cy in.
	ana.must(204, "POST", path+"/invites", InviteInput{Email: "cy@example.com", MemberId: &g.Members[2].Id}, nil)
	f.next(t, "cy@example.com")
	if code := cy.errorCode(403, "GET", path+"/join", nil); code != "link_closed" {
		t.Fatalf("unconfirmed address: %s", code)
	}
	confirmEmail(cy, f, "cy@example.com")
	var info JoinInfo
	cy.must(200, "GET", path+"/join", nil, &info)
	if info.InvitedMemberId == nil || *info.InvitedMemberId != g.Members[2].Id {
		t.Fatalf("invitedMemberId = %v", info.InvitedMemberId)
	}
	cy.must(200, "POST", path+"/join", JoinInput{ClaimMemberId: &g.Members[2].Id}, nil)
	cy.must(200, "GET", path, nil, nil)

	// Leaving uses up the invitation: coming back needs another.
	cy.must(204, "DELETE", path+"/members/"+g.Members[2].Id, nil, nil)
	if code := cy.errorCode(403, "POST", path+"/join", JoinInput{}); code != "link_closed" {
		t.Fatal(code)
	}

	// Opening it again lets the link work as before.
	ana.must(200, "PATCH", path, GroupUpdate{LinkClosed: ptr(false)}, &g)
	if g.LinkClosed || g.LinkAccess {
		t.Fatalf("reopened: linkClosed %v, linkAccess %v", g.LinkClosed, g.LinkAccess)
	}
	cy.must(200, "POST", path+"/join", JoinInput{}, nil)
	ana.must(200, "GET", path+"/activity", nil, &log)
	found := false
	for _, a := range log.Items {
		found = found || a.Action == "group.link_opened"
	}
	if !found {
		t.Fatal("no group.link_opened activity")
	}
}

func TestLinkClosedLinkMode(t *testing.T) {
	ana := newClient(t)
	g := createGroup(ana, "Ana")
	if code := ana.errorCode(403, "PATCH", "/g/"+g.Token, GroupUpdate{LinkClosed: ptr(true)}); code != "accounts_off" {
		t.Fatal(code)
	}
	// Leaving it open is no change.
	ana.must(200, "PATCH", "/g/"+g.Token, GroupUpdate{LinkClosed: ptr(false)}, &g)
	if g.LinkClosed {
		t.Fatal("linkClosed in link mode")
	}
}
