package api

import (
	"context"
	"testing"
	"time"
)

func TestScheduleAt(t *testing.T) {
	berlin, err := time.LoadLocation("Europe/Berlin")
	if err != nil {
		t.Fatal(err)
	}
	monthly := schedule{start: time.Date(2026, 1, 31, 9, 30, 0, 0, berlin), loc: berlin, unit: Month, every: 1}
	for n, want := range []string{"2026-01-31", "2026-02-28", "2026-03-31", "2026-04-30"} {
		if got := monthly.at(n).Format(dateLayout); got != want {
			t.Errorf("monthly %d: %s, want %s", n, got, want)
		}
	}
	leap := schedule{start: time.Date(2028, 2, 29, 12, 0, 0, 0, berlin), loc: berlin, unit: Year, every: 1}
	if got := leap.at(1).Format(dateLayout); got != "2029-02-28" {
		t.Errorf("a year after Feb 29: %s", got)
	}
	if got := leap.at(4).Format(dateLayout); got != "2032-02-29" {
		t.Errorf("four years after Feb 29: %s", got)
	}

	// Weekly across the switch to summer time keeps 9:30 local.
	weekly := schedule{start: time.Date(2026, 3, 22, 9, 30, 0, 0, berlin), loc: berlin, unit: Week, every: 1}
	if got := weekly.at(1); got.Hour() != 9 || got.Minute() != 30 || got.Day() != 29 {
		t.Errorf("weekly across summer time: %v", got)
	}

	// after finds the first occurrence later than a time, also far along.
	every3 := schedule{start: time.Date(2026, 1, 1, 8, 0, 0, 0, time.UTC), loc: time.UTC, unit: Day, every: 3}
	for _, c := range []struct{ after, want string }{
		{"2025-06-01T00:00:00Z", "2026-01-01T08:00:00Z"},
		{"2026-01-01T08:00:00Z", "2026-01-04T08:00:00Z"},
		{"2026-01-04T07:59:59Z", "2026-01-04T08:00:00Z"},
		{"2027-01-01T00:00:00Z", "2027-01-02T08:00:00Z"}, // day 366 is a multiple of 3
	} {
		got := every3.after(mustTime(t, c.after))
		if got == nil || !got.Equal(mustTime(t, c.want)) {
			t.Errorf("after %s: %v, want %s", c.after, got, c.want)
		}
	}
	quarterly := schedule{start: time.Date(2026, 1, 15, 0, 0, 0, 0, time.UTC), loc: time.UTC, unit: Month, every: 3}
	if got := quarterly.after(mustTime(t, "2026-10-15T00:00:00Z")); got == nil || got.Format(dateLayout) != "2027-01-15" {
		t.Errorf("quarterly: %v", got)
	}

	// Nothing after the last day.
	quarterly.end = "2027-01-14"
	if got := quarterly.after(mustTime(t, "2026-10-15T00:00:00Z")); got != nil {
		t.Errorf("after the end: %v", got)
	}
	if n := quarterly.due(quarterly.first(), mustTime(t, "2030-01-01T00:00:00Z")); n != 4 {
		t.Errorf("due until the end: %d", n)
	}
}

func TestRecurringExpenses(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{})
	ctx := context.Background()
	g := createGroup(c, "Ana", "Ben")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	base := "/g/" + g.Token
	c.member = ana
	now := time.Now().UTC().Truncate(time.Second)
	rent := RecurringExpenseInput{
		Title: "Rent", Amount: "10.00", StartsAt: now.Add(-48 * time.Hour),
		Payers:      []PayerInput{{MemberId: ana, Amount: "10.00"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ana}, {MemberId: ben}},
		Repeat: Repeat{Unit: Day, Every: 1}, TimeZone: ptr("Europe/Berlin"),
	}

	// Occurrences already due are added straight away.
	var r RecurringExpense
	c.must(201, "POST", base+"/recurring", rent, &r)
	if r.CreatedBy == nil || *r.CreatedBy != ana || r.NextAt == nil || !r.NextAt.Equal(now.Add(24*time.Hour)) ||
		r.LastAt == nil || !r.LastAt.Equal(now) {
		t.Fatalf("created: %+v", r)
	}
	recurringOnes := func() []Expense {
		var page ExpensePage
		c.must(200, "GET", base+"/expenses", nil, &page)
		var out []Expense
		for _, e := range page.Items {
			if e.RecurringId != nil && *e.RecurringId == r.Id && e.DeletedAt == nil {
				out = append(out, e)
			}
		}
		return out
	}
	if got := recurringOnes(); len(got) != 3 || got[0].CreatedBy == nil || *got[0].CreatedBy != ana {
		t.Fatalf("added straight away: %+v", got)
	}

	// The job adds each occurrence once, however often it runs.
	run := func(at time.Time, want int) {
		t.Helper()
		n, err := s.runRecurring(ctx, at)
		if err != nil || n != want {
			t.Fatalf("run at %v: added %d, want %d, err %v", at, n, want, err)
		}
	}
	run(now, 0)
	run(now.Add(25*time.Hour), 1)
	run(now.Add(25*time.Hour), 0)
	if got := recurringOnes(); len(got) != 4 || !got[0].OccurredAt.Equal(now.Add(24*time.Hour)) {
		t.Fatalf("after a day: %+v", got)
	}
	// Two missed days are caught up.
	run(now.Add(73*time.Hour), 2)

	var page ActivityPage
	c.must(200, "GET", base+"/activity", nil, &page)
	if a := page.Items[0]; a.Action != "expense.created" || a.Payload["recurring"] != true || a.ActorMemberId == nil {
		t.Fatalf("activity: %+v", a)
	}

	// Paused, nothing is added; resumed, the missed days are skipped.
	c.must(200, "PATCH", base+"/recurring/"+r.Id, RecurringPause{Paused: true}, &r)
	run(now.Add(200*time.Hour), 0)
	c.must(200, "PATCH", base+"/recurring/"+r.Id, RecurringPause{Paused: false}, &r)
	if r.Paused || r.NextAt == nil || !r.NextAt.After(time.Now()) {
		t.Fatalf("resumed: %+v", r)
	}

	// An edit changes what later occurrences add, and goes on from the
	// latest one added, still counted from the start.
	edit := rent
	edit.Amount, edit.Payers = "12.00", []PayerInput{{MemberId: ana, Amount: "12.00"}}
	edit.Repeat = Repeat{Unit: Week, Every: 2}
	edit.Version = ptr(r.Version - 1)
	if code := c.errorCode(409, "PUT", base+"/recurring/"+r.Id, edit); code != "recurring_version_conflict" {
		t.Fatalf("stale edit: %q", code)
	}
	edit.Version = ptr(r.Version)
	c.must(200, "PUT", base+"/recurring/"+r.Id, edit, &r)
	if r.Amount != "12.00" || r.Repeat.Unit != Week || r.NextAt == nil || !r.NextAt.Equal(now.Add(-48*time.Hour+14*24*time.Hour)) {
		t.Fatalf("edited: %+v", r)
	}

	var list []RecurringExpense
	c.must(200, "GET", base+"/recurring", nil, &list)
	if len(list) != 1 || list[0].Id != r.Id || len(list[0].Splits) != 2 {
		t.Fatalf("list: %+v", list)
	}

	// Stopping keeps what it added.
	c.must(204, "DELETE", base+"/recurring/"+r.Id, nil, nil)
	c.must(404, "GET", base+"/recurring/"+r.Id, nil, nil)
	var expenses ExpensePage
	c.must(200, "GET", base+"/expenses", nil, &expenses)
	if len(expenses.Items) != 6 || expenses.Items[0].RecurringId != nil {
		t.Fatalf("after deleting: %d expenses", len(expenses.Items))
	}
}

func TestRecurringPausesWhenMemberLeaves(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{})
	ctx := context.Background()
	g := createGroup(c, "Ana", "Ben")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	base := "/g/" + g.Token
	in := RecurringExpenseInput{
		Title: "Gym", Amount: "30.00", StartsAt: time.Now().Add(time.Hour),
		Payers:      []PayerInput{{MemberId: ana, Amount: "30.00"}},
		SplitMethod: "exact", Splits: []Share{{MemberId: ana, Value: ptr("10.00")}, {MemberId: ben, Value: ptr("20.00")}},
		Repeat: Repeat{Unit: Month, Every: 1},
	}
	var r RecurringExpense
	c.must(201, "POST", base+"/recurring", in, &r)
	if r.TimeZone != "UTC" || r.LastAt != nil || r.NextAt == nil {
		t.Fatalf("created: %+v", r)
	}
	c.must(204, "DELETE", base+"/members/"+ben, nil, nil)

	if n, err := s.runRecurring(ctx, time.Now().Add(2*time.Hour)); err != nil || n != 0 {
		t.Fatalf("added %d, err %v", n, err)
	}
	c.must(200, "GET", base+"/recurring/"+r.Id, nil, &r)
	if !r.Paused {
		t.Fatal("not paused")
	}
	var page ActivityPage
	c.must(200, "GET", base+"/activity", nil, &page)
	if a := page.Items[0]; a.Action != "recurring.paused" || a.Payload["reason"] != "member_left" || a.ActorMemberId != nil {
		t.Fatalf("activity: %+v", a)
	}
	if code := c.errorCode(400, "PATCH", base+"/recurring/"+r.Id, RecurringPause{Paused: false}); code != "member_left" {
		t.Fatalf("resume: %q", code)
	}
}

func TestRecurringValidation(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana")
	ana := g.Members[0].Id
	base := "/g/" + g.Token
	valid := func() RecurringExpenseInput {
		return RecurringExpenseInput{
			Title: "Phone", Amount: "5.00", StartsAt: time.Now(),
			Payers:      []PayerInput{{MemberId: ana, Amount: "5.00"}},
			SplitMethod: "equal", Splits: []Share{{MemberId: ana}},
			Repeat: Repeat{Unit: Month, Every: 1},
		}
	}
	for code, change := range map[string]func(*RecurringExpenseInput){
		"invalid_repeat":    func(in *RecurringExpenseInput) { in.Repeat.Every = 0 },
		"invalid_time_zone": func(in *RecurringExpenseInput) { in.TimeZone = ptr("Mars/Olympus") },
		"invalid_end":       func(in *RecurringExpenseInput) { in.EndsOn = ptr("2000-01-01") },
		"too_many_due": func(in *RecurringExpenseInput) {
			in.StartsAt = time.Now().Add(-200 * 24 * time.Hour)
			in.Repeat.Unit = Day
		},
		"payer_total": func(in *RecurringExpenseInput) { in.Amount = "6.00" },
	} {
		in := valid()
		change(&in)
		if got := c.errorCode(400, "POST", base+"/recurring", in); got != code {
			t.Errorf("%s: got %q", code, got)
		}
	}

	// One that ends on its first day adds that and stops.
	in := valid()
	in.EndsOn = ptr(time.Now().UTC().Format(dateLayout))
	var r RecurringExpense
	c.must(201, "POST", base+"/recurring", in, &r)
	if r.NextAt != nil || r.LastAt == nil || *r.EndsOn != *in.EndsOn {
		t.Fatalf("ended: %+v", r)
	}
	c.must(404, "GET", base+"/recurring/not-an-id", nil, nil)
}
