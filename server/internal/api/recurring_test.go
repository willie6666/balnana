package api

import (
	"context"
	"fmt"
	"slices"
	"sync"
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

func TestContinueAt(t *testing.T) {
	day := func(s string) *time.Time {
		d := mustTime(t, s+"T09:00:00Z")
		return &d
	}
	for _, c := range []struct {
		name       string
		unit       RepeatUnit
		from, to   string // the old start and the new one
		last, next *time.Time
		want       *time.Time
	}{
		// The day moves later in the month: this month's is already added,
		// so it goes on next month.
		{"later", Month, "2026-01-01", "2026-01-15", day("2026-10-01"), day("2026-11-01"), day("2026-11-15")},
		// Earlier, to the occurrence nearest where it would have gone.
		{"earlier", Month, "2026-01-15", "2026-01-01", day("2026-10-15"), day("2026-11-15"), day("2026-11-01")},
		{"a little earlier", Month, "2026-01-15", "2026-01-10", day("2026-10-15"), day("2026-11-15"), day("2026-11-10")},
		// Resumed after skipping days: they stay skipped.
		{"skipped", Day, "2026-10-01", "2026-10-01", day("2026-10-05"), day("2026-10-20"), day("2026-10-20")},
		{"skipped and moved", Month, "2026-01-01", "2026-01-15", day("2026-06-01"), day("2026-10-01"), day("2026-10-15")},
		// Nothing added yet: it starts over.
		{"not started", Month, "2026-11-01", "2026-11-20", nil, day("2026-11-01"), day("2026-11-20")},
	} {
		r := &RecurringExpense{StartsAt: *day(c.from), TimeZone: "UTC", Repeat: Repeat{Unit: c.unit, Every: 1},
			LastAt: c.last, NextAt: c.next}
		sched := schedule{start: *day(c.to), loc: time.UTC, unit: c.unit, every: 1}
		got, err := continueAt(r, sched)
		if err != nil || got == nil || !got.Equal(*c.want) {
			t.Errorf("%s: %v, want %v (err %v)", c.name, got, c.want, err)
		}
	}
}

// recurringAdded lists the live expenses that recurring expense id added.
func recurringAdded(c *client, base, id string) []Expense {
	c.t.Helper()
	var page ExpensePage
	c.must(200, "GET", base+"/expenses", nil, &page)
	var out []Expense
	for _, e := range page.Items {
		if e.RecurringId != nil && *e.RecurringId == id && e.DeletedAt == nil {
			out = append(out, e)
		}
	}
	return out
}

func TestRecurringEditAfterResume(t *testing.T) {
	c, _, pool := adminClient(t, map[string]string{})
	ctx := context.Background()
	g := createGroup(c, "Ana")
	ana := g.Members[0].Id
	base := "/g/" + g.Token
	c.member = ana
	now := time.Now().UTC().Truncate(time.Second)
	in := RecurringExpenseInput{
		Title: "Coffee", Amount: "3.00", StartsAt: now.Add(-48 * time.Hour),
		Payers:      []PayerInput{{MemberId: ana, Amount: "3.00"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ana}},
		Repeat: Repeat{Unit: Day, Every: 1},
	}
	var r RecurringExpense
	c.must(201, "POST", base+"/recurring", in, &r)
	c.must(200, "PATCH", base+"/recurring/"+r.Id, RecurringPause{Paused: true}, &r)

	// As if all that happened ten days ago.
	if _, err := pool.Exec(ctx, `
		update recurring_expenses set starts_at = starts_at - interval '10 days', last_at = last_at - interval '10 days',
			next_at = next_at - interval '10 days', paused_at = paused_at - interval '10 days'
		where id = $1`, r.Id); err != nil {
		t.Fatal(err)
	}
	if _, err := pool.Exec(ctx, `
		update expenses set occurred_at = occurred_at - interval '10 days', recurring_due = recurring_due - interval '10 days'
		where recurring_id = $1`, r.Id); err != nil {
		t.Fatal(err)
	}

	c.must(200, "PATCH", base+"/recurring/"+r.Id, RecurringPause{Paused: false}, &r)
	if r.NextAt == nil || !r.NextAt.Equal(now.Add(24*time.Hour)) {
		t.Fatalf("resumed: %+v", r)
	}
	// An edit does not bring back the days it was paused.
	edit := in
	edit.StartsAt = r.StartsAt
	edit.Amount, edit.Payers = "4.00", []PayerInput{{MemberId: ana, Amount: "4.00"}}
	edit.Version = ptr(r.Version)
	c.must(200, "PUT", base+"/recurring/"+r.Id, edit, &r)
	if r.NextAt == nil || !r.NextAt.Equal(now.Add(24*time.Hour)) {
		t.Fatalf("edited: %+v", r)
	}
	if got := recurringAdded(c, base, r.Id); len(got) != 3 {
		t.Fatalf("added %d", len(got))
	}
}

func TestRecurringResumeAfterFailure(t *testing.T) {
	c, s, pool := adminClient(t, map[string]string{})
	ctx := context.Background()
	g := createGroup(c, "Ana", "Ben")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	base := "/g/" + g.Token
	c.member = ana
	in := RecurringExpenseInput{
		Title: "Gym", Amount: "30.00", StartsAt: time.Now().UTC().Truncate(time.Second).Add(time.Hour),
		Payers:      []PayerInput{{MemberId: ana, Amount: "30.00"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ana}, {MemberId: ben}},
		Repeat: Repeat{Unit: Month, Every: 1},
	}
	var r RecurringExpense
	c.must(201, "POST", base+"/recurring", in, &r)
	c.must(204, "DELETE", base+"/members/"+ben, nil, nil)
	// Its first occurrence came due an hour ago, and could not be added.
	if _, err := pool.Exec(ctx, `
		update recurring_expenses set starts_at = starts_at - interval '2 hours', next_at = next_at - interval '2 hours'
		where id = $1`, r.Id); err != nil {
		t.Fatal(err)
	}
	if n, err := s.runRecurring(ctx, time.Now()); err != nil || n != 0 {
		t.Fatalf("added %d, err %v", n, err)
	}
	c.must(200, "GET", base+"/recurring/"+r.Id, nil, &r)
	if !r.Paused {
		t.Fatal("not paused")
	}

	// Fixed and resumed, the occurrence that failed is added after all.
	edit := in
	edit.StartsAt = r.StartsAt
	edit.Splits = []Share{{MemberId: ana}}
	edit.Version = ptr(r.Version)
	c.must(200, "PUT", base+"/recurring/"+r.Id, edit, &r)
	if got := recurringAdded(c, base, r.Id); len(got) != 0 {
		t.Fatalf("added while paused: %+v", got)
	}
	c.must(200, "PATCH", base+"/recurring/"+r.Id, RecurringPause{Paused: false}, &r)
	got := recurringAdded(c, base, r.Id)
	if len(got) != 1 || !got[0].OccurredAt.Equal(r.StartsAt) || r.LastAt == nil || !r.LastAt.Equal(r.StartsAt) ||
		r.NextAt == nil || !r.NextAt.Equal(r.StartsAt.AddDate(0, 1, 0)) {
		t.Fatalf("resumed: %+v, added %+v", r, got)
	}
}

func TestRecurringResumeChecksGroupTotal(t *testing.T) {
	c, _, pool := adminClient(t, map[string]string{})
	ctx := context.Background()
	g := createGroup(c, "Ana")
	ana := g.Members[0].Id
	base := "/g/" + g.Token
	c.member = ana
	var e Expense
	c.must(201, "POST", base+"/expenses", ExpenseInput{
		Title: "Car", Amount: "10.00", OccurredAt: time.Now(), SplitMethod: "equal",
		Payers: []PayerInput{{MemberId: ana, Amount: "10.00"}}, Splits: []Share{{MemberId: ana}},
	}, &e)
	var r RecurringExpense
	c.must(201, "POST", base+"/recurring", RecurringExpenseInput{
		Title: "Phone", Amount: "5.00", StartsAt: time.Now().Add(time.Hour),
		Payers:      []PayerInput{{MemberId: ana, Amount: "5.00"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ana}},
		Repeat: Repeat{Unit: Month, Every: 1},
	}, &r)
	c.must(200, "PATCH", base+"/recurring/"+r.Id, RecurringPause{Paused: true}, &r)

	// The group's entries meanwhile add up to as much as they may.
	tx, err := pool.Begin(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer tx.Rollback(ctx)
	for _, table := range []string{"expenses set amount = $2 where id = $1",
		"expense_payers set amount = $2 where expense_id = $1", "expense_splits set amount = $2 where expense_id = $1"} {
		if _, err := tx.Exec(ctx, "update "+table, e.Id, int64(maxGroupTotal)); err != nil {
			t.Fatal(err)
		}
	}
	if err := tx.Commit(ctx); err != nil {
		t.Fatal(err)
	}
	if code := c.errorCode(400, "PATCH", base+"/recurring/"+r.Id, RecurringPause{Paused: false}); code != "amount_too_large" {
		t.Fatalf("resume: %q", code)
	}
}

func TestRecurringSchedulersAtOnce(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{})
	ctx := context.Background()
	start := time.Now().UTC().Truncate(time.Second).Add(time.Hour)
	for _, count := range []int{3, 2} {
		g := createGroup(c, "Ana")
		c.member = g.Members[0].Id
		for range count {
			c.must(201, "POST", "/g/"+g.Token+"/recurring", RecurringExpenseInput{
				Title: "Bread", Amount: "2.00", StartsAt: start,
				Payers:      []PayerInput{{MemberId: c.member, Amount: "2.00"}},
				SplitMethod: "equal", Splits: []Share{{MemberId: c.member}},
				Repeat: Repeat{Unit: Day, Every: 1},
			}, nil)
		}
	}

	// Four servers adding the same four days of five recurring expenses
	// add each once between them.
	at := start.Add(3*24*time.Hour + time.Minute)
	var wg sync.WaitGroup
	var mu sync.Mutex
	total := 0
	for range 4 {
		wg.Go(func() {
			n, err := s.runRecurring(ctx, at)
			if err != nil {
				t.Error(err)
			}
			mu.Lock()
			total += n
			mu.Unlock()
		})
	}
	wg.Wait()
	// One that found everything busy leaves it for the next round.
	n, err := s.runRecurring(ctx, at)
	if err != nil || total+n != 20 {
		t.Fatalf("added %d and then %d, err %v", total, n, err)
	}
	if n, err := s.runRecurring(ctx, at); err != nil || n != 0 {
		t.Fatalf("again: added %d, err %v", n, err)
	}
}

func TestRecurringCalendar(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{})
	ctx := context.Background()
	berlin, err := time.LoadLocation("Europe/Berlin")
	if err != nil {
		t.Fatal(err)
	}
	// Years from now, so none of it is due when it is set up.
	year := time.Now().Year() + 2
	leap := year
	for leap%4 != 0 || (leap%100 == 0 && leap%400 != 0) {
		leap++
	}
	summer := time.Date(year, 3, 31, 9, 30, 0, 0, berlin)
	for summer.Weekday() != time.Sunday {
		summer = summer.AddDate(0, 0, -1)
	}
	february := time.Date(year, 3, 0, 0, 0, 0, 0, time.UTC).Day()
	for _, c2 := range []struct {
		name  string
		start time.Time
		unit  RepeatUnit
		at    time.Time
		want  []string // local dates and times, in Berlin
	}{
		{"month end", time.Date(year, 1, 31, 9, 30, 0, 0, berlin), Month, time.Date(year, 5, 1, 0, 0, 0, 0, berlin), []string{
			fmt.Sprintf("%d-01-31 09:30", year), fmt.Sprintf("%d-02-%d 09:30", year, february),
			fmt.Sprintf("%d-03-31 09:30", year), fmt.Sprintf("%d-04-30 09:30", year),
		}},
		{"leap day", time.Date(leap, 2, 29, 12, 0, 0, 0, berlin), Year, time.Date(leap+4, 3, 1, 0, 0, 0, 0, berlin), []string{
			fmt.Sprintf("%d-02-29 12:00", leap), fmt.Sprintf("%d-02-28 12:00", leap+1), fmt.Sprintf("%d-02-28 12:00", leap+2),
			fmt.Sprintf("%d-02-28 12:00", leap+3), fmt.Sprintf("%d-02-29 12:00", leap+4),
		}},
		{"summer time", summer.AddDate(0, 0, -7), Week, summer.AddDate(0, 0, 8), []string{
			summer.AddDate(0, 0, -7).Format("2006-01-02 15:04"), summer.Format("2006-01-02 15:04"),
			summer.AddDate(0, 0, 7).Format("2006-01-02 15:04"),
		}},
	} {
		g := createGroup(c, "Ana")
		c.member = g.Members[0].Id
		base := "/g/" + g.Token
		var r RecurringExpense
		c.must(201, "POST", base+"/recurring", RecurringExpenseInput{
			Title: "Rent", Amount: "500.00", StartsAt: c2.start,
			Payers:      []PayerInput{{MemberId: c.member, Amount: "500.00"}},
			SplitMethod: "equal", Splits: []Share{{MemberId: c.member}},
			Repeat: Repeat{Unit: c2.unit, Every: 1}, TimeZone: ptr("Europe/Berlin"),
		}, &r)
		if n, err := s.runRecurring(ctx, c2.at); err != nil || n != len(c2.want) {
			t.Fatalf("%s: added %d, err %v", c2.name, n, err)
		}
		var got []string
		for _, e := range recurringAdded(c, base, r.Id) {
			got = append(got, e.OccurredAt.In(berlin).Format("2006-01-02 15:04"))
		}
		slices.Sort(got)
		if !slices.Equal(got, c2.want) {
			t.Errorf("%s: %v, want %v", c2.name, got, c2.want)
		}
		// Stopped, so later cases add only their own.
		c.must(204, "DELETE", base+"/recurring/"+r.Id, nil, nil)
	}
}

func TestRecurringAccess(t *testing.T) {
	ana := accountsClient(t, map[string]string{})
	register(ana, "ana@example.com", "Ana")
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana"}}, &g)
	me := g.Members[0].Id
	base := "/g/" + g.Token
	in := RecurringExpenseInput{
		Title: "Rent", Amount: "500.00", StartsAt: time.Now().Add(time.Hour),
		Payers:      []PayerInput{{MemberId: me, Amount: "500.00"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: me}},
		Repeat: Repeat{Unit: Month, Every: 1},
	}
	var r RecurringExpense
	ana.must(201, "POST", base+"/recurring", in, &r)
	edit := in
	edit.Version = ptr(r.Version)

	anon := ana.another()
	ben := ana.another()
	register(ben, "ben@example.com", "Ben")
	for _, who := range []struct {
		c      *client
		status int
		code   string
	}{{anon, 401, "sign_in_required"}, {ben, 403, "not_a_member"}} {
		for _, req := range []struct {
			method, path string
			body         any
		}{
			{"GET", base + "/recurring", nil},
			{"POST", base + "/recurring", in},
			{"GET", base + "/recurring/" + r.Id, nil},
			{"PUT", base + "/recurring/" + r.Id, edit},
			{"PATCH", base + "/recurring/" + r.Id, RecurringPause{Paused: true}},
			{"DELETE", base + "/recurring/" + r.Id, nil},
		} {
			if code := who.c.errorCode(who.status, req.method, req.path, req.body); code != who.code {
				t.Errorf("%s %s: %q, want %q", req.method, req.path, code, who.code)
			}
		}
	}
	ana.must(200, "GET", base+"/recurring/"+r.Id, nil, &r)
	if r.Paused || r.Version != *edit.Version {
		t.Fatalf("changed: %+v", r)
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

	// A device that knows only its offset sends that.
	for _, zone := range []string{"UTC+15:00", "UTC+5", "UTC+05:30x", "UTC+"} {
		in := valid()
		in.TimeZone = &zone
		if got := c.errorCode(400, "POST", base+"/recurring", in); got != "invalid_time_zone" {
			t.Errorf("%s: got %q", zone, got)
		}
	}
	in := valid()
	in.StartsAt = time.Date(2026, 1, 31, 23, 0, 0, 0, time.UTC).AddDate(time.Now().Year()-2026+1, 0, 0)
	in.TimeZone = ptr("UTC+05:30")
	var r RecurringExpense
	c.must(201, "POST", base+"/recurring", in, &r)
	if r.TimeZone != "UTC+05:30" || r.NextAt == nil || !r.NextAt.Equal(in.StartsAt) {
		t.Fatalf("by offset: %+v", r)
	}
	// Its months end in that zone: the 1st there, not January 31 in UTC.
	if s, err := scheduleOf(&r); err != nil || s.at(1).Format("01-02 15:04") != "03-01 04:30" {
		t.Fatalf("by offset, a month on: %v, err %v", s.at(1), err)
	}

	// One that ends on its first day adds that and stops.
	in = valid()
	in.EndsOn = ptr(time.Now().UTC().Format(dateLayout))
	r = RecurringExpense{}
	c.must(201, "POST", base+"/recurring", in, &r)
	if r.NextAt != nil || r.LastAt == nil || *r.EndsOn != *in.EndsOn {
		t.Fatalf("ended: %+v", r)
	}
	c.must(404, "GET", base+"/recurring/not-an-id", nil, nil)
}
