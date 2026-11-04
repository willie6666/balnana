package api

import (
	"reflect"
	"strings"
	"testing"
)

func TestRemind(t *testing.T) {
	c, f, s := pushClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben", "Cy")
	ana, ben, cy := g.Members[0].Id, g.Members[1].Id, g.Members[2].Id
	subscribe(c, "ana-phone", follow(g.Token, ana))
	subscribe(c, "ben-phone", follow(g.Token, ben))
	base := "/g/" + g.Token
	c.member = ana
	c.must(201, "POST", base+"/expenses", ExpenseInput{
		Title:       "Dinner",
		Amount:      "30",
		OccurredAt:  mustTime(t, "2026-10-01T19:00:00Z"),
		Payers:      []PayerInput{{MemberId: ana, Amount: "30"}},
		SplitMethod: "equal",
		Splits:      []Share{{MemberId: ana}, {MemberId: ben}, {MemberId: cy}},
	}, nil)
	f.take(s)

	var r Reminder
	c.must(200, "POST", base+"/members/"+ben+"/remind", nil, &r)
	sent := f.take(s)
	want := notification{Group: g.Token, Expense: ben, Title: "Trip", Key: "push_reminder", Args: []string{"Ana", "10.00 EUR"}}
	if r.Devices != 1 || len(sent) != 1 || sent[0].phone != "ben-phone" || !reflect.DeepEqual(sent[0].n, want) ||
		sent[0].Topic != strings.ReplaceAll(ben, "-", "") {
		t.Fatalf("%+v %+v", r, sent)
	}
	// Nobody to hear it: the app offers to share it instead.
	c.must(200, "POST", base+"/members/"+cy+"/remind", nil, &r)
	if sent := f.take(s); r.Devices != 0 || len(sent) != 0 {
		t.Fatalf("%+v %+v", r, sent)
	}

	// Only whoever is owed may send one, and only to whoever owes them.
	if code := c.errorCode(409, "POST", base+"/members/"+ana+"/remind", nil); code != "nothing_owed" {
		t.Error(code)
	}
	c.member = cy
	if code := c.errorCode(409, "POST", base+"/members/"+ben+"/remind", nil); code != "nothing_owed" {
		t.Error(code)
	}
	c.member = ""
	if code := c.errorCode(409, "POST", base+"/members/"+ben+"/remind", nil); code != "nothing_owed" {
		t.Error(code)
	}
	c.must(404, "POST", base+"/members/00000000-0000-0000-0000-000000000000/remind", nil, nil)
	if sent := f.take(s); len(sent) != 0 {
		t.Fatalf("%+v", sent)
	}

	// With push off there is nobody to send to, so it says so.
	s.push = nil
	c.member = ana
	c.must(200, "POST", base+"/members/"+ben+"/remind", nil, &r)
	if r.Devices != 0 {
		t.Fatalf("%+v", r)
	}
}

func TestRemindPlan(t *testing.T) {
	ana, f, s := pushClient(t, map[string]string{"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true"})
	u := register(ana, "ana@example.com", "Ana")
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &g)
	ben := ana.another()
	register(ben, "ben@example.com", "Ben")
	base := "/g/" + g.Token
	ben.must(200, "POST", base+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)
	subscribe(ben, "ben-phone", PushDeviceInput{})
	ana.must(201, "POST", base+"/payments", PaymentInput{Amount: "5", FromMemberId: g.Members[0].Id, ToMemberId: g.Members[1].Id}, nil)
	f.take(s)

	remind := base + "/members/" + g.Members[1].Id + "/remind"
	var refused struct {
		Code   string         `json:"code"`
		Params map[string]any `json:"params"`
	}
	ana.must(402, "POST", remind, nil, &refused)
	if refused.Code != "plan_limit" || refused.Params["limit"] != "reminders" {
		t.Fatalf("%+v", refused)
	}
	var gp GroupPlan
	ana.must(200, "GET", base+"/plan", nil, &gp)
	if gp.Reminders {
		t.Fatalf("%+v", gp)
	}

	grant(t, s, u.Id, "plus")
	var mine MyPlan
	ana.must(200, "GET", "/me/plan", nil, &mine)
	if !mine.Reminders {
		t.Fatalf("%+v", mine)
	}
	ana.must(200, "PUT", base+"/sponsor", nil, nil)
	ana.must(200, "GET", base+"/plan", nil, &gp)
	var r Reminder
	ana.must(200, "POST", remind, nil, &r)
	if sent := f.take(s); !gp.Reminders || r.Devices != 1 || len(sent) != 1 || sent[0].phone != "ben-phone" ||
		sent[0].n.Args[1] != "5.00 EUR" {
		t.Fatalf("%+v %+v %+v", gp, r, sent)
	}
}
