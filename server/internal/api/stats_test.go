package api

import (
	"net/url"
	"slices"
	"testing"
)

// statsGroup makes a group with a few expenses and a payment:
//
//	Sep 30 23:30 UTC  Taxi      transport  30  Ana pays, Ana+Ben
//	Oct  1 19:00 UTC  Dinner    food       90  Ben pays, everyone, note "100% fun_night"
//	Oct 20 12:00 UTC  Groceries groceries  12  Ana pays, Ana+Cleo
//	Oct 21 08:00 UTC  Snacks    (none)      6  Cleo pays, Cleo
//	Oct 22 10:00 UTC  payment Ben -> Ana   15
func statsGroup(t *testing.T) (*client, string, [3]string) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben", "Cleo", "Dan")
	ana, ben, cleo := g.Members[0].Id, g.Members[1].Id, g.Members[2].Id
	base := "/g/" + g.Token
	add := func(title string, category *string, amount, at, payer string, note *string, split ...string) {
		in := ExpenseInput{Title: title, CategoryId: category, Amount: amount, OccurredAt: mustTime(t, at), Note: note,
			Payers: []PayerInput{{MemberId: payer, Amount: amount}}, SplitMethod: "equal"}
		for _, m := range split {
			in.Splits = append(in.Splits, Share{MemberId: m})
		}
		c.must(201, "POST", base+"/expenses", in, nil)
	}
	add("Taxi", ptr("transport"), "30", "2026-09-30T23:30:00Z", ana, nil, ana, ben)
	add("Dinner", ptr("food"), "90", "2026-10-01T19:00:00Z", ben, ptr("100% fun_night"), ana, ben, cleo)
	add("Groceries", ptr("groceries"), "12", "2026-10-20T12:00:00Z", ana, nil, ana, cleo)
	add("Snacks", nil, "6", "2026-10-21T08:00:00Z", cleo, nil, cleo)
	c.must(201, "POST", base+"/payments", PaymentInput{FromMemberId: ben, ToMemberId: ana, Amount: "15",
		OccurredAt: ptr(mustTime(t, "2026-10-22T10:00:00Z"))}, nil)
	return c, base, [3]string{ana, ben, cleo}
}

func titles(c *client, path string, q url.Values) []string {
	c.t.Helper()
	var page ExpensePage
	c.must(200, "GET", path+"?"+q.Encode(), nil, &page)
	out := []string{}
	for _, e := range page.Items {
		out = append(out, e.Title)
	}
	return out
}

func TestExpenseFilters(t *testing.T) {
	c, base, m := statsGroup(t)
	ana, ben, cleo := m[0], m[1], m[2]
	path := base + "/expenses"

	cases := []struct {
		name string
		q    url.Values
		want []string
	}{
		{"everything", url.Values{}, []string{"", "Snacks", "Groceries", "Dinner", "Taxi"}},
		{"title ignoring case", url.Values{"q": {"  tAX "}}, []string{"Taxi"}},
		{"note", url.Values{"q": {"fun"}}, []string{"Dinner"}},
		{"percent is literal", url.Values{"q": {"0%"}}, []string{"Dinner"}},
		{"underscore is literal", url.Values{"q": {"n_e"}}, []string{}},
		{"underscore matches itself", url.Values{"q": {"n_n"}}, []string{"Dinner"}},
		{"member who paid or shared", url.Values{"member": {cleo}}, []string{"Snacks", "Groceries", "Dinner"}},
		{"category", url.Values{"category": {"food"}}, []string{"Dinner"}},
		{"payments", url.Values{"kind": {"payment"}}, []string{""}},
		{"from is inclusive, to is not", url.Values{"from": {"2026-10-01T19:00:00Z"}, "to": {"2026-10-21T08:00:00Z"}},
			[]string{"Groceries", "Dinner"}},
		{"combined", url.Values{"member": {ana}, "kind": {"expense"}, "q": {"o"}}, []string{"Groceries"}},
		{"member and payment", url.Values{"member": {ben}, "kind": {"payment"}}, []string{""}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := titles(c, path, tc.q); !slices.Equal(got, tc.want) {
				t.Fatalf("got %q, want %q", got, tc.want)
			}
		})
	}

	// Pages keep the filter.
	var page ExpensePage
	c.must(200, "GET", path+"?member="+ana+"&limit=1", nil, &page)
	if len(page.Items) != 1 || page.Items[0].Title != "" || page.NextCursor == nil {
		t.Fatalf("first page: %+v", page)
	}
	c.must(200, "GET", path+"?member="+ana+"&limit=2&cursor="+*page.NextCursor, nil, &page)
	if len(page.Items) != 2 || page.Items[0].Title != "Groceries" || page.Items[1].Title != "Dinner" {
		t.Fatalf("second page: %+v", page)
	}

	if code := c.errorCode(400, "GET", path+"?member=nobody", nil); code != "invalid_member" {
		t.Fatalf("bad member: %q", code)
	}
	if code := c.errorCode(400, "GET", path+"?kind=gift", nil); code != "invalid_kind" {
		t.Fatalf("bad kind: %q", code)
	}
}

func TestStats(t *testing.T) {
	c, base, m := statsGroup(t)
	ana, ben, cleo := m[0], m[1], m[2]

	var s GroupStats
	c.must(200, "GET", base+"/stats", nil, &s)
	if s.Total != "138.00" || s.Count != 4 {
		t.Fatalf("total: %+v", s)
	}
	cats := []CategoryStats{
		{CategoryId: ptr("food"), Amount: "90.00", Count: 1},
		{CategoryId: ptr("transport"), Amount: "30.00", Count: 1},
		{CategoryId: ptr("groceries"), Amount: "12.00", Count: 1},
		{Amount: "6.00", Count: 1},
	}
	if !slices.EqualFunc(s.Categories, cats, func(a, b CategoryStats) bool {
		return a.Amount == b.Amount && a.Count == b.Count && (a.CategoryId == nil) == (b.CategoryId == nil) &&
			(a.CategoryId == nil || *a.CategoryId == *b.CategoryId)
	}) {
		t.Fatalf("categories: %+v", s.Categories)
	}
	// Dan never took part, and the payment does not count.
	members := []MemberStats{
		{MemberId: ana, Paid: "42.00", Share: "51.00"},
		{MemberId: ben, Paid: "90.00", Share: "45.00"},
		{MemberId: cleo, Paid: "6.00", Share: "42.00"},
	}
	if !slices.Equal(s.Members, members) {
		t.Fatalf("members: %+v", s.Members)
	}
	months := []MonthStats{{Month: "2026-09", Amount: "30.00"}, {Month: "2026-10", Amount: "108.00"}}
	if !slices.Equal(s.Months, months) {
		t.Fatalf("months: %+v", s.Months)
	}

	// In Taipei the taxi was already in October.
	c.must(200, "GET", base+"/stats?utcOffset=480", nil, &s)
	if !slices.Equal(s.Months, []MonthStats{{Month: "2026-10", Amount: "138.00"}}) {
		t.Fatalf("months at +8: %+v", s.Months)
	}

	c.must(200, "GET", base+"/stats?from=2026-10-02T00:00:00Z", nil, &s)
	if s.Total != "18.00" || s.Count != 2 || len(s.Categories) != 2 || len(s.Members) != 2 {
		t.Fatalf("from Oct 2: %+v", s)
	}

	c.must(200, "GET", base+"/stats?to=2026-01-01T00:00:00Z", nil, &s)
	if s.Total != "0.00" || s.Count != 0 || s.Categories == nil || s.Members == nil || s.Months == nil {
		t.Fatalf("nothing: %+v", s)
	}

	if code := c.errorCode(400, "GET", base+"/stats?utcOffset=900", nil); code != "invalid_offset" {
		t.Fatalf("bad offset: %q", code)
	}
	c.errorCode(404, "GET", "/g/not-a-group/stats", nil)
}
