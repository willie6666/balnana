package api

import (
	"context"
	"image"
	"testing"
	"time"
)

// featureOffIn wants a 409 feature_off for the named feature.
func featureOffIn(c *client, feature, method, path string, body any) {
	c.t.Helper()
	var e Error
	if got := c.call(method, path, body, &e); got != 409 || e.Code != "feature_off" || e.Params == nil ||
		(*e.Params)["feature"] != feature {
		c.t.Fatalf("%s %s: status %d, %+v", method, path, got, e)
	}
}

func TestGroupFeatures(t *testing.T) {
	c := newClient(t)
	var g Group
	c.must(201, "POST", "/groups", GroupCreate{Name: "Trip", Currency: "eur", Members: []string{"Ana", "Ben"},
		Features: &GroupFeaturesInput{Places: ptr(false)}}, &g)
	if g.Features != (GroupFeatures{ForeignCurrency: true, Recurring: true, Places: false, Receipts: true}) {
		t.Fatalf("created: %+v", g.Features)
	}
	// Left out, the others stay as they are.
	c.must(200, "PATCH", "/g/"+g.Token, GroupUpdate{Features: &GroupFeaturesInput{Receipts: ptr(false)}}, &g)
	if g.Features != (GroupFeatures{ForeignCurrency: true, Recurring: true, Places: false, Receipts: false}) {
		t.Fatalf("updated: %+v", g.Features)
	}
	c.must(200, "GET", "/g/"+g.Token, nil, &g)
	if g.Features.Places || g.Features.Receipts || !g.Features.Recurring {
		t.Fatalf("read: %+v", g.Features)
	}
	c.must(201, "POST", "/groups", GroupCreate{Name: "Home", Currency: "eur", Members: []string{"Ana"}}, &g)
	if g.Features != (GroupFeatures{ForeignCurrency: true, Recurring: true, Places: true, Receipts: true}) {
		t.Fatalf("default: %+v", g.Features)
	}
}

func TestFeaturesOffKeepWhatIsThere(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	base := "/g/" + g.Token
	in := ExpenseInput{
		Title: "Ramen", Amount: "6.43", OccurredAt: mustTime(t, "2026-10-01T12:00:00Z"),
		Foreign:     &ForeignInput{Currency: "JPY", Amount: "1000"},
		Location:    &Location{Name: ptr("Kyoto"), Point: &GeoPoint{Latitude: 35.0116, Longitude: 135.7681}},
		Payers:      []PayerInput{{MemberId: ana, Amount: "1000"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ana}, {MemberId: ben}},
	}
	var e Expense
	c.must(201, "POST", base+"/expenses", in, &e)
	png := pngBytes(t, image.NewRGBA(image.Rect(0, 0, 4, 4)))
	if rec := c.upload(base+"/expenses/"+e.Id+"/receipt", "image/png", png); rec.Code != 200 {
		t.Fatalf("receipt: %d %s", rec.Code, rec.Body)
	}
	c.must(200, "PATCH", base, GroupUpdate{Features: &GroupFeaturesInput{
		ForeignCurrency: ptr(false), Places: ptr(false), Receipts: ptr(false)}}, nil)

	// Nothing new...
	featureOffIn(c, "foreignCurrency", "POST", base+"/expenses", in)
	plain := in
	plain.Foreign = nil
	plain.Payers = []PayerInput{{MemberId: ana, Amount: "6.43"}}
	featureOffIn(c, "places", "POST", base+"/expenses", plain)
	plain.Location = nil
	var other Expense
	c.must(201, "POST", base+"/expenses", plain, &other)
	if rec := c.upload(base+"/expenses/"+other.Id+"/receipt", "image/png", png); rec.Code != 409 {
		t.Fatalf("receipt when off: %d %s", rec.Code, rec.Body)
	}

	// ...but what the expense had stays, and can go.
	edit := in
	edit.Title, edit.Version = "Ramen and gyoza", ptr(e.Version)
	c.must(200, "PUT", base+"/expenses/"+e.Id, edit, &e)
	if e.Foreign == nil || e.Location == nil || !e.HasReceipt {
		t.Fatalf("kept: %+v", e)
	}
	moved := edit
	moved.Location, moved.Version = &Location{Name: ptr("Osaka")}, ptr(e.Version)
	featureOffIn(c, "places", "PUT", base+"/expenses/"+e.Id, moved)
	moved.Location = nil
	var after Expense
	c.must(200, "PUT", base+"/expenses/"+e.Id, moved, &after)
	if after.Location != nil || after.Foreign == nil {
		t.Fatalf("location left: %+v", after)
	}
	c.must(204, "DELETE", base+"/expenses/"+e.Id+"/receipt", nil, nil)
}

func TestRecurringOff(t *testing.T) {
	c, s, pool := adminClient(t, map[string]string{})
	ctx := context.Background()
	g := createGroup(c, "Ana")
	ana := g.Members[0].Id
	base := "/g/" + g.Token
	c.member = ana
	now := time.Now().UTC().Truncate(time.Second)
	in := RecurringExpenseInput{
		Title: "Coffee", Amount: "3.00", StartsAt: now.Add(time.Hour),
		Payers:      []PayerInput{{MemberId: ana, Amount: "3.00"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ana}},
		Repeat: Repeat{Unit: Day, Every: 1},
	}
	var r, paused RecurringExpense
	c.must(201, "POST", base+"/recurring", in, &r)
	c.must(201, "POST", base+"/recurring", in, &paused)
	c.must(200, "PATCH", base+"/recurring/"+paused.Id, RecurringPause{Paused: true}, &paused)
	c.must(200, "PATCH", base, GroupUpdate{Features: &GroupFeaturesInput{Recurring: ptr(false)}}, nil)

	featureOffIn(c, "recurring", "POST", base+"/recurring", in)
	featureOffIn(c, "recurring", "PATCH", base+"/recurring/"+paused.Id, RecurringPause{Paused: false})
	// Three days came due while it was off: none is added.
	if _, err := pool.Exec(ctx, `
		update recurring_expenses set starts_at = starts_at - interval '3 days', next_at = next_at - interval '3 days'
		where id = $1`, r.Id); err != nil {
		t.Fatal(err)
	}
	if n, err := s.runRecurring(ctx, now); err != nil || n != 0 {
		t.Fatalf("added %d, err %v", n, err)
	}
	// An edit is kept, without adding what came due.
	edit := in
	edit.StartsAt, edit.Amount = now.Add(-71*time.Hour), "4.00"
	edit.Payers = []PayerInput{{MemberId: ana, Amount: "4.00"}}
	c.must(200, "GET", base+"/recurring/"+r.Id, nil, &r)
	edit.Version = ptr(r.Version)
	c.must(200, "PUT", base+"/recurring/"+r.Id, edit, &r)
	if got := recurringAdded(c, base, r.Id); len(got) != 0 {
		t.Fatalf("added on edit: %d", len(got))
	}

	// On again, what came due is skipped, as on resuming.
	c.must(200, "PATCH", base, GroupUpdate{Features: &GroupFeaturesInput{Recurring: ptr(true)}}, nil)
	c.must(200, "GET", base+"/recurring/"+r.Id, nil, &r)
	if r.NextAt == nil || !r.NextAt.After(now) || r.Paused {
		t.Fatalf("on again: %+v", r)
	}
	if n, err := s.runRecurring(ctx, time.Now()); err != nil || n != 0 {
		t.Fatalf("added %d, err %v", n, err)
	}
	c.must(200, "PATCH", base+"/recurring/"+paused.Id, RecurringPause{Paused: false}, &paused)
}
