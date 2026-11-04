package api

import (
	"log/slog"
	"net/http"
	"slices"
	"strings"
	"testing"
)

func TestPaymentDetails(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben")
	path := "/g/" + g.Token + "/members/" + g.Members[0].Id
	if g.Members[0].PaymentDetails == nil || len(g.Members[0].PaymentDetails) != 0 {
		t.Fatalf("new member: %#v", g.Members[0].PaymentDetails)
	}

	var m Member
	c.must(200, "PATCH", path, MemberInput{Name: "Ana", PaymentDetails: &[]PaymentDetail{
		{Label: " LINE Pay ", Value: " ana.tw "}, {Label: "Bank", Value: "012-345678"},
	}}, &m)
	want := []PaymentDetail{{Label: "LINE Pay", Value: "ana.tw"}, {Label: "Bank", Value: "012-345678"}}
	if !slices.Equal(m.PaymentDetails, want) {
		t.Fatalf("set: %+v", m.PaymentDetails)
	}
	// Left out, they stay.
	c.must(200, "PATCH", path, MemberInput{Name: "Anna"}, nil)
	var read Group
	c.must(200, "GET", "/g/"+g.Token, nil, &read)
	if !slices.Equal(read.Members[0].PaymentDetails, want) {
		t.Fatalf("kept: %+v", read.Members[0].PaymentDetails)
	}

	bad := map[string][]PaymentDetail{
		"too many":     slices.Repeat([]PaymentDetail{{Label: "Bank", Value: "1"}}, maxPayDetails+1),
		"no label":     {{Label: " ", Value: "1"}},
		"no value":     {{Label: "Bank", Value: ""}},
		"long label":   {{Label: strings.Repeat("a", maxPayLabel+1), Value: "1"}},
		"long value":   {{Label: "Bank", Value: strings.Repeat("1", maxPayValue+1)}},
		"two lines":    {{Label: "Bank", Value: "1\n2"}},
		"control char": {{Label: "Bank\x07", Value: "1"}},
	}
	for name, in := range bad {
		if code := c.errorCode(400, "PATCH", path, MemberInput{Name: "Anna", PaymentDetails: &in}); code != "invalid_payment_details" {
			t.Fatalf("%s: %s", name, code)
		}
	}

	c.must(200, "PATCH", path, MemberInput{Name: "Anna", PaymentDetails: &[]PaymentDetail{}}, &m)
	if m.PaymentDetails == nil || len(m.PaymentDetails) != 0 {
		t.Fatalf("cleared: %#v", m.PaymentDetails)
	}
	c.must(201, "POST", "/g/"+g.Token+"/members", MemberInput{Name: "Cleo",
		PaymentDetails: &[]PaymentDetail{{Label: "PayPal", Value: "https://paypal.me/cleo"}}}, &m)
	if len(m.PaymentDetails) != 1 {
		t.Fatalf("added: %+v", m.PaymentDetails)
	}
}

// In accounts mode only the member's own account may say how they are paid,
// not even the group's owner.
func TestPaymentDetailsAreTheirOwn(t *testing.T) {
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
	bank := &[]PaymentDetail{{Label: "Bank", Value: "012-345678"}}

	ana.must(200, "PATCH", path+"/members/"+g.Members[0].Id, MemberInput{Name: "Ana", PaymentDetails: bank}, nil)
	ben.must(200, "PATCH", path+"/members/"+g.Members[1].Id, MemberInput{Name: "Ben", PaymentDetails: bank}, nil)
	for who, m := range map[string]string{"claimed": g.Members[1].Id, "unclaimed": g.Members[2].Id} {
		other := &[]PaymentDetail{{Label: "Bank", Value: "999"}}
		if code := ana.errorCode(403, "PATCH", path+"/members/"+m, MemberInput{Name: "X", PaymentDetails: other}); code != "not_allowed" {
			t.Fatalf("%s: %s", who, code)
		}
	}
	// Sending back what is there, as a rename does, is no change to them.
	var m Member
	ana.must(200, "PATCH", path+"/members/"+g.Members[1].Id, MemberInput{Name: "Benjamin", PaymentDetails: bank}, &m)
	if m.Name != "Benjamin" || !slices.Equal(m.PaymentDetails, *bank) {
		t.Fatalf("renamed: %+v", m)
	}
	if code := ana.errorCode(403, "POST", path+"/members", MemberInput{Name: "Dan", PaymentDetails: bank}); code != "not_allowed" {
		t.Fatal(code)
	}

	// Coming back as another member takes Ben's account with him, and his
	// details too: whoever claims his old member next is paid elsewhere.
	ben.must(204, "DELETE", path+"/members/"+g.Members[1].Id, nil, nil)
	ben.must(200, "POST", path+"/join", JoinInput{ClaimMemberId: &g.Members[2].Id}, nil)
	var read Group
	ana.must(200, "GET", path, nil, &read)
	if len(read.Members[1].PaymentDetails) != 0 {
		t.Fatalf("left behind: %+v", read.Members[1].PaymentDetails)
	}
}
