package api

import (
	"context"
	"net/http"
	"reflect"
	"strings"
	"testing"
	"time"
)

var showAll = ViewLinkShow{Balances: true, Expenses: true, Spending: true}

// viewRaw fetches a view path and returns its status and body.
func (c *client) viewRaw(path string) (int, string) {
	c.t.Helper()
	rec := c.do("GET", path, nil)
	return rec.Code, rec.Body.String()
}

func TestViewLinkLive(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	base := "/g/" + g.Token
	c.member = ana

	var state ViewLinkState
	c.must(200, "GET", base+"/view-link", nil, &state)
	if state.Link != nil {
		t.Fatalf("%+v", state)
	}
	// It shows something besides the header, and never a past expiry.
	none := ViewLinkShow{Notes: true}
	if code := c.errorCode(400, "POST", base+"/view-link", ViewLinkCreate{Live: true, Show: none}); code != "invalid_show" {
		t.Error(code)
	}
	past := time.Now().Add(-time.Minute)
	if code := c.errorCode(400, "POST", base+"/view-link", ViewLinkCreate{Live: true, Show: showAll, ExpiresAt: &past}); code != "invalid_expiry" {
		t.Error(code)
	}

	var link ViewLink
	c.must(201, "POST", base+"/view-link", ViewLinkCreate{Live: true, Show: showAll}, &link)
	if !link.Live || link.SnapshotAt != nil || link.Paused || len(link.Token) != tokenLen || link.Token == g.Token ||
		link.LastViewedAt != nil {
		t.Fatalf("%+v", link)
	}
	if code := c.errorCode(409, "POST", base+"/view-link", ViewLinkCreate{Live: true, Show: showAll}); code != "view_link_exists" {
		t.Error(code)
	}
	c.must(200, "GET", base+"/view-link", nil, &state)
	if state.Link == nil || state.Link.Token != link.Token {
		t.Fatalf("%+v", state)
	}

	view := "/v/" + link.Token
	var e Expense
	c.must(201, "POST", base+"/expenses", ExpenseInput{Title: "Lunch", Amount: "10", Note: ptr("secret sauce"),
		Location:   &Location{Name: ptr("Hidden Cafe"), Point: &GeoPoint{Latitude: 1, Longitude: 2}},
		OccurredAt: mustTime(t, "2026-10-23T10:00:00Z"), Payers: []PayerInput{{MemberId: ana, Amount: "10"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ana}, {MemberId: ben}}}, &e)

	// Strangers see it without a session, a member or a key.
	viewer := c.another()
	var vg ViewGroup
	viewer.must(200, "GET", view, nil, &vg)
	if vg.Name != "Trip" || !vg.Live || vg.AsOf != nil || len(vg.Members) != 2 || vg.Members[0].Balance == nil ||
		*vg.Members[0].Balance != "5.00" || vg.Transfers == nil || len(*vg.Transfers) != 1 || len(vg.Categories) == 0 {
		t.Fatalf("%+v", vg)
	}
	for _, path := range []string{view, view + "/expenses", view + "/stats"} {
		code, body := viewer.viewRaw(path)
		if code != 200 || strings.Contains(body, g.Token) || strings.Contains(body, "createdBy") ||
			strings.Contains(body, "userId") || strings.Contains(body, "claimed") || strings.Contains(body, "version") ||
			strings.Contains(body, "secret sauce") || strings.Contains(body, "Hidden Cafe") {
			t.Fatalf("%s: %d %s", path, code, body)
		}
	}
	c.must(200, "GET", base+"/view-link", nil, &state)
	if state.Link.LastViewedAt == nil || !state.Link.LastViewedAt.Equal(state.Link.LastViewedAt.Truncate(time.Hour)) {
		t.Fatalf("last viewed %v", state.Link.LastViewedAt)
	}

	// Search finds only what is shown.
	var page ViewExpensePage
	viewer.must(200, "GET", view+"/expenses?q=sauce", nil, &page)
	if len(page.Items) != 0 {
		t.Fatalf("%+v", page)
	}
	viewer.must(200, "GET", view+"/expenses?q=lunch", nil, &page)
	if len(page.Items) != 1 || page.Items[0].Note != nil || page.Items[0].Location != nil || page.Items[0].HasReceipt {
		t.Fatalf("%+v", page)
	}

	// An edit shows at once.
	edit := ExpenseInput{Title: "Brunch", Amount: "20", Note: e.Note, Location: e.Location, OccurredAt: e.OccurredAt,
		Payers: []PayerInput{{MemberId: ana, Amount: "20"}}, SplitMethod: "equal",
		Splits: []Share{{MemberId: ana}, {MemberId: ben}}, Version: &e.Version}
	c.must(200, "PUT", base+"/expenses/"+e.Id, edit, &e)
	viewer.must(200, "GET", view+"/expenses", nil, &page)
	if len(page.Items) != 1 || page.Items[0].Title != "Brunch" || page.Items[0].Amount != "20.00" {
		t.Fatalf("%+v", page)
	}

	// Notes, places and receipts once shown.
	if rec := c.upload(base+"/expenses/"+e.Id+"/receipt", "image/png", pngBytes(t, halves(40, 20))); rec.Code != 200 {
		t.Fatalf("upload: %d %s", rec.Code, rec.Body)
	}
	viewer.must(404, "GET", view+"/expenses/"+e.Id+"/receipt", nil, nil)
	more := showAll
	more.Notes, more.Places, more.Receipts = true, true, true
	c.must(200, "PUT", base+"/view-link", ViewLinkSettings{Show: more}, &link)
	if link.Show != more {
		t.Fatalf("%+v", link)
	}
	viewer.must(200, "GET", view+"/expenses?q=sauce", nil, &page)
	if len(page.Items) != 1 || page.Items[0].Note == nil || page.Items[0].Location == nil || !page.Items[0].HasReceipt {
		t.Fatalf("%+v", page)
	}
	if rec := viewer.do("GET", view+"/expenses/"+e.Id+"/receipt", nil); rec.Code != 200 ||
		rec.Header().Get("Content-Type") != "image/jpeg" {
		t.Fatalf("receipt: %d", rec.Code)
	}

	// The stats are the group's.
	var want, got GroupStats
	c.must(200, "GET", base+"/stats?timeZone=Asia/Taipei", nil, &want)
	viewer.must(200, "GET", view+"/stats?timeZone=Asia/Taipei", nil, &got)
	if !reflect.DeepEqual(want, got) || got.Count != 1 {
		t.Fatalf("%+v != %+v", got, want)
	}

	// Each section can be hidden; notes, places and receipts go with expenses.
	c.must(200, "PUT", base+"/view-link", ViewLinkSettings{Show: ViewLinkShow{Spending: true, Notes: true, Places: true,
		Receipts: true}}, nil)
	vg = ViewGroup{}
	viewer.must(200, "GET", view, nil, &vg)
	if vg.Transfers != nil || vg.Members[0].Balance != nil || vg.Show != (ViewLinkShow{Spending: true}) {
		t.Fatalf("%+v", vg)
	}
	viewer.must(404, "GET", view+"/expenses", nil, nil)
	viewer.must(404, "GET", view+"/expenses/"+e.Id+"/receipt", nil, nil)
	viewer.must(200, "GET", view+"/stats", nil, nil)
	c.must(200, "PUT", base+"/view-link", ViewLinkSettings{Show: ViewLinkShow{Balances: true}}, nil)
	viewer.must(404, "GET", view+"/stats", nil, nil)

	// A group password is not asked for.
	var key GroupKey
	c.must(200, "PUT", base+"/password", GroupPasswordInput{Password: "hunter22"}, &key)
	c = c.withKey(key.Key)
	viewer.must(200, "GET", view, nil, nil)

	// Expired.
	soon := time.Now().Add(time.Hour)
	c.must(200, "PUT", base+"/view-link", ViewLinkSettings{Show: showAll, ExpiresAt: &soon}, &link)
	if link.ExpiresAt == nil {
		t.Fatalf("%+v", link)
	}
	exec(t, s, `update view_links set expires_at = now() - interval '1 second' where token = $1`, link.Token)
	if code := viewer.errorCode(http.StatusGone, "GET", view, nil); code != "view_link_expired" {
		t.Error(code)
	}
	// Its other settings change with the end date kept as it was; another
	// date that has passed is still refused.
	c.must(200, "GET", base+"/view-link", nil, &state)
	c.must(200, "PUT", base+"/view-link", ViewLinkSettings{Show: ViewLinkShow{Balances: true},
		ExpiresAt: state.Link.ExpiresAt}, &link)
	if link.ExpiresAt == nil || !link.ExpiresAt.Equal(*state.Link.ExpiresAt) {
		t.Fatalf("%+v", link)
	}
	earlier := state.Link.ExpiresAt.Add(-time.Minute)
	if code := c.errorCode(400, "PUT", base+"/view-link", ViewLinkSettings{Show: showAll, ExpiresAt: &earlier}); code != "invalid_expiry" {
		t.Error(code)
	}
	c.must(200, "PUT", base+"/view-link", ViewLinkSettings{Show: showAll}, nil)
	viewer.must(200, "GET", view, nil, nil)

	// Revoked, it is gone; a new one has a new URL.
	c.must(204, "DELETE", base+"/view-link", nil, nil)
	c.must(204, "DELETE", base+"/view-link", nil, nil)
	viewer.must(404, "GET", view, nil, nil)
	viewer.must(404, "GET", "/v/not-a-token", nil, nil)
	var again ViewLink
	c.must(201, "POST", base+"/view-link", ViewLinkCreate{Live: true, Show: showAll}, &again)
	if again.Token == link.Token {
		t.Fatal("same token")
	}
	var log ActivityPage
	c.must(200, "GET", base+"/activity", nil, &log)
	actions := map[string]int{}
	for _, a := range log.Items {
		actions[a.Action]++
	}
	if actions["group.view_link_created"] != 2 || actions["group.view_link_changed"] != 6 ||
		actions["group.view_link_revoked"] != 1 {
		t.Fatalf("%v", actions)
	}

	// Deleting the group stops it.
	c.must(204, "DELETE", base, nil, nil)
	viewer.must(404, "GET", "/v/"+again.Token, nil, nil)
}

func TestViewLinkSnapshot(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben", "Cy")
	ana, ben, cy := g.Members[0].Id, g.Members[1].Id, g.Members[2].Id
	base := "/g/" + g.Token
	add := func(title, amount, at string, category *string, payer string, splits ...string) Expense {
		in := ExpenseInput{Title: title, Amount: amount, CategoryId: category, OccurredAt: mustTime(t, at),
			Note: ptr("note " + title), Location: &Location{Name: ptr("at " + title)},
			Payers: []PayerInput{{MemberId: payer, Amount: amount}}, SplitMethod: "equal"}
		for _, m := range splits {
			in.Splits = append(in.Splits, Share{MemberId: m})
		}
		var e Expense
		c.must(201, "POST", base+"/expenses", in, &e)
		return e
	}
	food, travel := ptr("food"), ptr("transport")
	lunch := add("Lunch", "30", "2026-09-30T20:00:00Z", food, ana, ana, ben, cy)
	add("Train", "12.50", "2026-10-02T08:00:00Z", travel, ben, ben, cy)
	add("Taxi", "8", "2026-10-02T08:00:00Z", travel, cy, ana, cy)
	refund := add("Refund", "5", "2026-10-05T12:00:00Z", food, ana, ana, ben)
	income := add("Pay", "100", "2026-10-06T12:00:00Z", nil, ana, ben)
	add("Snack", "3", "2026-11-01T00:30:00Z", nil, cy, cy)
	c.must(201, "POST", base+"/expenses", transfer(ben, ana, "4"), nil)
	exec(t, s, `update expenses set transaction_type = 'refund' where id = $1`, refund.Id)
	exec(t, s, `update expenses set transaction_type = 'income' where id = $1`, income.Id)

	if code := c.errorCode(400, "POST", base+"/view-link", ViewLinkCreate{Show: ViewLinkShow{Expenses: true,
		Receipts: true}}); code != "invalid_show" {
		t.Error(code)
	}
	old := maxViewSnapshot
	maxViewSnapshot = 100
	if code := c.errorCode(413, "POST", base+"/view-link", ViewLinkCreate{Show: showAll}); code != "too_large" {
		t.Error(code)
	}
	maxViewSnapshot = old

	var before Group
	c.must(200, "GET", base, nil, &before)
	var link ViewLink
	c.must(201, "POST", base+"/view-link", ViewLinkCreate{Show: showAll}, &link)
	if link.Live || link.SnapshotAt == nil {
		t.Fatalf("%+v", link)
	}
	view := "/v/" + link.Token
	viewer := c.another()

	// What it shows agrees with the group as it was.
	check := func() {
		t.Helper()
		var vg ViewGroup
		viewer.must(200, "GET", view, nil, &vg)
		if vg.Live || vg.AsOf == nil || !vg.AsOf.Equal(*link.SnapshotAt) || len(vg.Members) != 3 || vg.Name != "Trip" {
			t.Fatalf("%+v", vg)
		}
		for i, m := range vg.Members {
			if m.Balance == nil || *m.Balance != before.Members[i].Balance {
				t.Fatalf("%d: %+v != %+v", i, m, before.Members[i])
			}
		}
		for _, q := range []string{"", "&timeZone=Asia/Taipei", "&timeZone=America/Los_Angeles&from=2026-10-01T00:00:00Z",
			"&to=2026-10-03T00:00:00Z"} {
			var want, got GroupStats
			c.must(200, "GET", base+"/stats?"+q, nil, &want)
			viewer.must(200, "GET", view+"/stats?"+q, nil, &got)
			if !reflect.DeepEqual(want, got) {
				t.Fatalf("%s: %+v != %+v", q, got, want)
			}
		}
		for _, q := range []string{"", "q=TAXI", "q=note", "member=" + strings.ToUpper(ben), "category=transport",
			"category=transfer", "from=2026-10-02T08:00:00Z&to=2026-11-01T00:00:00Z", "q=%25"} {
			var want []string
			for cursor := ""; ; {
				var p ExpensePage
				c.must(200, "GET", base+"/expenses?limit=2&"+q+"&cursor="+cursor, nil, &p)
				for _, e := range p.Items {
					want = append(want, e.Id+" "+e.Title+" "+e.Amount)
				}
				if p.NextCursor == nil {
					break
				}
				cursor = *p.NextCursor
			}
			var got []string
			for cursor := ""; ; {
				var p ViewExpensePage
				viewer.must(200, "GET", view+"/expenses?limit=2&"+q+"&cursor="+cursor, nil, &p)
				for _, e := range p.Items {
					if e.Note != nil || e.Location != nil || e.HasReceipt {
						t.Fatalf("%+v", e)
					}
					got = append(got, e.Id+" "+e.Title+" "+e.Amount)
				}
				if p.NextCursor == nil {
					break
				}
				cursor = *p.NextCursor
			}
			// Notes are hidden, so the snapshot finds nothing by them.
			if q == "q=note" {
				want = nil
			}
			if !reflect.DeepEqual(want, got) {
				t.Fatalf("%s: %v != %v", q, got, want)
			}
		}
	}
	check()
	if code := c.errorCode(400, "GET", base+"/expenses?member=nope", nil); code != "invalid_member" {
		t.Error(code)
	}
	if code := viewer.errorCode(400, "GET", view+"/expenses?member=nope", nil); code != "invalid_member" {
		t.Error(code)
	}

	// Later changes do not show in it.
	c.member = ana
	c.must(204, "DELETE", base+"/expenses/"+lunch.Id, nil, nil)
	add("Later", "99", "2026-10-10T10:00:00Z", nil, ana, ana, cy)
	c.must(201, "POST", base+"/members", MemberInput{Name: "Dee"}, nil)
	var page ViewExpensePage
	viewer.must(200, "GET", view+"/expenses?q=Lunch", nil, &page)
	if len(page.Items) != 1 {
		t.Fatalf("%+v", page)
	}
	var vg ViewGroup
	viewer.must(200, "GET", view, nil, &vg)
	if len(vg.Members) != 3 {
		t.Fatalf("%+v", vg)
	}

	// A snapshot never shows receipts. It keeps no notes or places it does
	// not show, so they cannot be turned on later.
	if code := c.errorCode(400, "PUT", base+"/view-link", ViewLinkSettings{Show: ViewLinkShow{Expenses: true,
		Receipts: true}}); code != "invalid_show" {
		t.Error(code)
	}
	for _, sh := range []ViewLinkShow{{Expenses: true, Notes: true}, {Expenses: true, Places: true}} {
		if code := c.errorCode(400, "PUT", base+"/view-link", ViewLinkSettings{Show: sh}); code != "invalid_show" {
			t.Errorf("%+v: %s", sh, code)
		}
	}
	stored := func(key string) int {
		t.Helper()
		var n int
		err := s.db.QueryRow(context.Background(), `
			select count(*) from view_links, jsonb_array_elements(snapshot->'expenses') x
			where token = $1 and x ? $2`, link.Token, key).Scan(&n)
		if err != nil {
			t.Fatal(err)
		}
		return n
	}
	if stored("note") != 0 || stored("location") != 0 {
		t.Fatal("hidden notes or places stored")
	}
	viewer.must(404, "GET", view+"/expenses/"+lunch.Id+"/receipt", nil, nil)

	// One that shows them keeps them, until it stops showing them.
	c.must(204, "DELETE", base+"/view-link", nil, nil)
	c.must(201, "POST", base+"/view-link", ViewLinkCreate{Show: ViewLinkShow{Expenses: true, Notes: true, Places: true}}, &link)
	view = "/v/" + link.Token
	list := func() []string {
		t.Helper()
		var p ViewExpensePage
		viewer.must(200, "GET", view+"/expenses?limit=100", nil, &p)
		var ids []string
		for _, e := range p.Items {
			ids = append(ids, e.Id)
		}
		return ids
	}
	all := list()
	viewer.must(200, "GET", view+"/expenses?q=at%20train", nil, &page)
	if len(page.Items) != 1 || page.Items[0].Note == nil || *page.Items[0].Note != "note Train" ||
		page.Items[0].Location == nil || *page.Items[0].Location.Name != "at Train" {
		t.Fatalf("%+v", page)
	}
	n := stored("note")
	c.must(200, "PUT", base+"/view-link", ViewLinkSettings{Show: ViewLinkShow{Expenses: true, Places: true}}, nil)
	if n == 0 || stored("note") != 0 || stored("location") != n {
		t.Fatalf("notes %d, then %d; places %d", n, stored("note"), stored("location"))
	}
	if code := c.errorCode(400, "PUT", base+"/view-link", ViewLinkSettings{Show: ViewLinkShow{Expenses: true,
		Notes: true, Places: true}}); code != "invalid_show" {
		t.Error(code)
	}
	var after ViewExpensePage
	viewer.must(200, "GET", view+"/expenses?q=at%20train", nil, &after)
	if len(after.Items) != 1 || after.Items[0].Note != nil || after.Items[0].Location == nil {
		t.Fatalf("%+v", after)
	}
	if got := list(); !reflect.DeepEqual(got, all) {
		t.Fatalf("%v != %v", got, all)
	}
	viewer.must(404, "GET", view+"/stats", nil, nil)
}

func TestViewLinkAccountsAndPlans(t *testing.T) {
	ana, s, _ := adminClient(t, map[string]string{"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true",
		"BALNANA_LINK_GROUPS": "false"})
	u := register(ana, "ana@example.com", "Ana")
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &g)
	ben := ana.another()
	register(ben, "ben@example.com", "Ben")
	base := "/g/" + g.Token
	ben.must(200, "POST", base+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)
	stranger := ana.another()
	register(stranger, "cy@example.com", "Cy")
	for _, r := range []struct{ method, path string }{{"GET", "/view-link"}, {"POST", "/view-link"},
		{"PUT", "/view-link"}, {"DELETE", "/view-link"}} {
		body := any(nil)
		if r.method == "POST" {
			body = ViewLinkCreate{Live: true, Show: showAll}
		} else if r.method == "PUT" {
			body = ViewLinkSettings{Show: showAll}
		}
		if code := stranger.errorCode(403, r.method, base+r.path, body); code != "not_a_member" {
			t.Errorf("%s: %s", r.method, code)
		}
	}

	// Free plans have none.
	var refused struct {
		Code   string         `json:"code"`
		Params map[string]any `json:"params"`
	}
	ben.must(402, "POST", base+"/view-link", ViewLinkCreate{Live: true, Show: showAll}, &refused)
	if refused.Code != "plan_limit" || refused.Params["limit"] != "viewLink" {
		t.Fatalf("%+v", refused)
	}
	var gp GroupPlan
	ana.must(200, "GET", base+"/plan", nil, &gp)
	if gp.ViewLink {
		t.Fatalf("%+v", gp)
	}

	grant(t, s, u.Id, "plus")
	var mine MyPlan
	ana.must(200, "GET", "/me/plan", nil, &mine)
	if !mine.ViewLink {
		t.Fatalf("%+v", mine)
	}
	ana.must(200, "PUT", base+"/sponsor", nil, nil)
	ana.must(200, "GET", base+"/plan", nil, &gp)
	if !gp.ViewLink {
		t.Fatalf("%+v", gp)
	}

	// Any member manages it, not only the sponsor.
	var link ViewLink
	ben.must(201, "POST", base+"/view-link", ViewLinkCreate{Live: true, Show: showAll}, &link)
	view := "/v/" + link.Token
	ana.must(200, "PUT", base+"/view-link", ViewLinkSettings{Show: ViewLinkShow{Spending: true}}, nil)
	stranger.must(200, "GET", view, nil, nil)
	ana.another().must(200, "GET", view, nil, nil)

	// When the plan lapses the link pauses, and members can still change and
	// revoke it.
	exec(t, s, `delete from entitlements where user_id = $1`, u.Id)
	if code := stranger.errorCode(403, "GET", view, nil); code != "view_link_paused" {
		t.Error(code)
	}
	ben.must(200, "PUT", base+"/view-link", ViewLinkSettings{Show: showAll}, &link)
	if !link.Paused {
		t.Fatalf("%+v", link)
	}
	grant(t, s, u.Id, "plus")
	stranger.must(200, "GET", view, nil, nil)
	ben.must(204, "DELETE", base+"/view-link", nil, nil)
	stranger.must(404, "GET", view, nil, nil)
}
