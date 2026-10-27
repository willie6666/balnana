package api

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"slices"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"balnana/internal/db"
	"balnana/internal/domain"
)

// These tests need PostgreSQL: they run when DATABASE_URL is set (for
// example postgres:///balnana?host=$PGHOST) and create a throwaway database
// for each test.
func testDB(t *testing.T) *pgxpool.Pool {
	t.Helper()
	return testDBConns(t, 0)
}

// testDBConns is testDB with a pool of at most maxConns connections (0 for
// pgx's default).
func testDBConns(t *testing.T, maxConns int32) *pgxpool.Pool {
	t.Helper()
	url := os.Getenv("DATABASE_URL")
	if url == "" {
		t.Skip("DATABASE_URL not set")
	}
	ctx := context.Background()
	admin, err := pgx.Connect(ctx, url)
	if err != nil {
		t.Skipf("no database: %v", err)
	}
	b := make([]byte, 6)
	_, _ = rand.Read(b)
	name := "balnana_test_" + hex.EncodeToString(b)
	if _, err := admin.Exec(ctx, "create database "+name); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		_, _ = admin.Exec(context.Background(), "drop database "+name+" with (force)")
		admin.Close(context.Background())
	})

	cfg, err := pgxpool.ParseConfig(url)
	if err != nil {
		t.Fatal(err)
	}
	cfg.ConnConfig.Database = name
	if maxConns > 0 {
		cfg.MaxConns = maxConns
	}
	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	if err := db.Migrate(ctx, pool, slog.New(slog.DiscardHandler)); err != nil {
		t.Fatal(err)
	}
	return pool
}

type client struct {
	t      *testing.T
	h      http.Handler
	member string
	token  string         // bearer session token
	jar    []*http.Cookie // cookies the server set
	header http.Header    // extra request headers
	// location is the Location header of the last answer.
	location string
}

func newClient(t *testing.T) *client {
	return newClientWith(t, map[string]string{})
}

// newClientWith starts a server with the given environment (on a fresh
// database) and returns a client for it.
func newClientWith(t *testing.T, env map[string]string) *client {
	pool := testDB(t)
	cfg := baseConfig(t, env)
	s := NewServer(cfg, pool, slog.New(slog.DiscardHandler), "test")
	return &client{t: t, h: NewHandler(s, http.NotFoundHandler())}
}

// another is a second client of the same server, with no session.
func (c *client) another() *client {
	return &client{t: c.t, h: c.h}
}

// call sends a request and decodes the JSON answer into out (when not nil).
// It returns the status code.
func (c *client) call(method, path string, body any, out any) int {
	c.t.Helper()
	var r io.Reader
	if body != nil {
		b, _ := json.Marshal(body)
		r = bytes.NewReader(b)
	}
	req := httptest.NewRequest(method, BasePath+path, r)
	req.Header.Set("Content-Type", "application/json")
	if c.member != "" {
		req.Header.Set("X-Balnana-Member", c.member)
	}
	if c.token != "" {
		req.Header.Set("Authorization", "Bearer "+c.token)
	}
	for _, ck := range c.jar {
		req.AddCookie(ck)
	}
	for k, v := range c.header {
		req.Header[k] = v
	}
	rec := httptest.NewRecorder()
	c.h.ServeHTTP(rec, req)
	c.location = rec.Header().Get("Location")
	for _, ck := range rec.Result().Cookies() {
		c.jar = slices.DeleteFunc(c.jar, func(old *http.Cookie) bool { return old.Name == ck.Name })
		if ck.MaxAge >= 0 {
			c.jar = append(c.jar, ck)
		}
	}
	if out != nil && rec.Body.Len() > 0 {
		if err := json.Unmarshal(rec.Body.Bytes(), out); err != nil {
			c.t.Fatalf("%s %s: decode %q: %v", method, path, rec.Body.String(), err)
		}
	}
	return rec.Code
}

// must is call that fails the test unless the status is want.
func (c *client) must(want int, method, path string, body any, out any) {
	c.t.Helper()
	var raw json.RawMessage
	got := c.call(method, path, body, &raw)
	if got != want {
		c.t.Fatalf("%s %s: status %d, want %d: %s", method, path, got, want, raw)
	}
	if out != nil {
		if err := json.Unmarshal(raw, out); err != nil {
			c.t.Fatal(err)
		}
	}
}

// errorCode expects a failure with the given status and returns its code.
func (c *client) errorCode(want int, method, path string, body any) string {
	c.t.Helper()
	var e Error
	got := c.call(method, path, body, &e)
	if got != want {
		c.t.Fatalf("%s %s: status %d, want %d (code %q)", method, path, got, want, e.Code)
	}
	return e.Code
}

func createGroup(c *client, names ...string) Group {
	c.t.Helper()
	var g Group
	c.must(201, "POST", "/groups", GroupCreate{Name: "Trip", Currency: "eur", Members: names}, &g)
	return g
}

func ptr[T any](v T) *T { return &v }

func TestCreateAndReadGroup(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben", "Cleo")
	if len(g.Token) != tokenLen || g.Currency != "EUR" || g.MinorDigits != 2 || g.Symbol != nil {
		t.Fatalf("group: %+v", g)
	}
	var dollars Group
	c.must(201, "POST", "/groups", GroupCreate{Name: "Taipei", Currency: "TWD", Symbol: ptr("$"), Members: []string{"Ana"}}, &dollars)
	if dollars.Symbol == nil || *dollars.Symbol != "$" {
		t.Fatalf("symbol: %+v", dollars)
	}
	if len(g.Members) != 3 || g.Members[0].Name != "Ana" || g.Members[2].Name != "Cleo" {
		t.Fatalf("members out of order: %+v", g.Members)
	}
	if g.Members[0].Balance != "0.00" {
		t.Fatalf("balance %q", g.Members[0].Balance)
	}

	var got Group
	c.must(200, "GET", "/g/"+g.Token, nil, &got)
	if got.Name != "Trip" || len(got.Members) != 3 {
		t.Fatalf("got %+v", got)
	}

	for _, path := range []string{"/g/short", "/g/AAAAAAAAAAAAAAAAAAAAAA", "/g/" + g.Token + "/expenses/not-a-uuid"} {
		if code := c.errorCode(404, "GET", path, nil); code != "not_found" {
			t.Errorf("%s: code %q", path, code)
		}
	}
}

func TestCreateGroupValidation(t *testing.T) {
	c := newClient(t)
	cases := []struct {
		in   GroupCreate
		code string
	}{
		{GroupCreate{Name: " ", Currency: "EUR", Members: []string{"A"}}, "invalid_name"},
		{GroupCreate{Name: "X", Currency: "EURO", Members: []string{"A"}}, "invalid_currency"},
		{GroupCreate{Name: "X", Currency: "EUR", Members: nil}, "no_members"},
		{GroupCreate{Name: "X", Currency: "EUR", Members: []string{"Ana", "ana"}}, "duplicate_name"},
		{GroupCreate{Name: "X", Currency: "EUR", Members: []string{"A"}, MinorDigits: ptr(5)}, "invalid_minor_digits"},
		{GroupCreate{Name: "X", Currency: "EUR", Members: []string{"A"}, Color: ptr(0x1000000)}, "invalid_color"},
	}
	for _, tc := range cases {
		if code := c.errorCode(400, "POST", "/groups", tc.in); code != tc.code {
			t.Errorf("%+v: code %q, want %q", tc.in, code, tc.code)
		}
	}
}

func TestExpensesAndBalances(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben", "Cleo")
	ana, ben, cleo := g.Members[0].Id, g.Members[1].Id, g.Members[2].Id
	c.member = ana
	base := "/g/" + g.Token

	dinner := ExpenseInput{
		Title:       "Dinner",
		CategoryId:  ptr("food"),
		Amount:      "100",
		OccurredAt:  mustTime(t, "2026-10-01T19:00:00Z"),
		Payers:      []PayerInput{{MemberId: ana, Amount: "100.00"}},
		SplitMethod: "equal",
		Splits:      []Share{{MemberId: ana}, {MemberId: ben}, {MemberId: cleo}},
	}
	var e Expense
	c.must(201, "POST", base+"/expenses", dinner, &e)
	if e.Amount != "100.00" || e.Version != 1 || e.CreatedBy == nil || *e.CreatedBy != ana || len(e.Splits) != 3 {
		t.Fatalf("expense: %+v", e)
	}
	var sum int
	for _, s := range e.Splits {
		switch s.Amount {
		case "33.33":
			sum += 3333
		case "33.34":
			sum += 3334
		default:
			t.Fatalf("split %q", s.Amount)
		}
	}
	if sum != 10000 {
		t.Fatalf("splits add up to %d", sum)
	}

	var b Balances
	c.must(200, "GET", base+"/balances", nil, &b)
	if len(b.Balances) != 3 || len(b.Transfers) != 2 {
		t.Fatalf("balances: %+v", b)
	}
	for _, tr := range b.Transfers {
		if tr.ToMemberId != ana {
			t.Fatalf("transfer %+v should go to Ana", tr)
		}
	}

	// Ben pays Ana back.
	var p Expense
	c.must(201, "POST", base+"/payments", PaymentInput{FromMemberId: ben, ToMemberId: ana, Amount: "33.33"}, &p)
	if p.Kind != "payment" || p.SplitMethod != "exact" {
		t.Fatalf("payment: %+v", p)
	}
	if code := c.errorCode(400, "POST", base+"/payments", PaymentInput{FromMemberId: ben, ToMemberId: ben, Amount: "1"}); code != "invalid_payment" {
		t.Fatalf("self payment: %q", code)
	}

	// Percent split with shares remembered.
	pct := dinner
	pct.Title = "Tickets"
	pct.SplitMethod = "percent"
	pct.Splits = []Share{{MemberId: ana, Value: ptr("50")}, {MemberId: ben, Value: ptr("25")}, {MemberId: cleo, Value: ptr("25")}}
	var tickets Expense
	c.must(201, "POST", base+"/expenses", pct, &tickets)
	if tickets.Splits[0].Share == nil || *tickets.Splits[0].Share != "50" || tickets.Splits[0].Amount != "50.00" {
		t.Fatalf("percent split: %+v", tickets.Splits)
	}

	// Editing needs the current version.
	edit := dinner
	edit.Title = "Dinner out"
	if code := c.errorCode(400, "PUT", base+"/expenses/"+e.Id, edit); code != "version_required" {
		t.Fatalf("code %q", code)
	}
	edit.Version = ptr(1)
	var edited Expense
	c.must(200, "PUT", base+"/expenses/"+e.Id, edit, &edited)
	if edited.Version != 2 || edited.Title != "Dinner out" {
		t.Fatalf("edited: %+v", edited)
	}
	if code := c.errorCode(409, "PUT", base+"/expenses/"+e.Id, edit); code != "expense_version_conflict" {
		t.Fatalf("stale edit: %q", code)
	}

	// Listing pages through everything, newest first.
	var page ExpensePage
	c.must(200, "GET", base+"/expenses?limit=2", nil, &page)
	if len(page.Items) != 2 || page.NextCursor == nil {
		t.Fatalf("page 1: %d items, cursor %v", len(page.Items), page.NextCursor)
	}
	if page.Items[0].Id != p.Id {
		t.Fatalf("the payment (dated now) should come first")
	}
	var rest ExpensePage
	c.must(200, "GET", base+"/expenses?limit=2&cursor="+*page.NextCursor, nil, &rest)
	if len(rest.Items) != 1 || rest.NextCursor != nil {
		t.Fatalf("page 2: %+v", rest)
	}

	// Delete and restore.
	c.must(204, "DELETE", base+"/expenses/"+tickets.Id, nil, nil)
	c.must(204, "DELETE", base+"/expenses/"+tickets.Id, nil, nil)
	var deleted Expense
	c.must(200, "GET", base+"/expenses/"+tickets.Id, nil, &deleted)
	if deleted.DeletedAt == nil {
		t.Fatal("deletedAt not set")
	}
	c.must(200, "GET", base+"/expenses", nil, &page)
	if len(page.Items) != 2 {
		t.Fatalf("deleted expense still listed")
	}
	var restored Expense
	c.must(200, "POST", base+"/expenses/"+tickets.Id+"/restore", nil, &restored)
	if restored.DeletedAt != nil {
		t.Fatal("still deleted")
	}

	// Balances always add up to zero.
	c.must(200, "GET", base+"/balances", nil, &b)
	var total int64
	for _, mb := range b.Balances {
		total += minor(t, mb.Amount)
	}
	if total != 0 {
		t.Fatalf("balances add up to %d: %+v", total, b.Balances)
	}

	var acts ActivityPage
	c.must(200, "GET", base+"/activity?limit=3", nil, &acts)
	if len(acts.Items) != 3 || acts.NextCursor == nil || acts.Items[0].Action != "expense.restored" {
		t.Fatalf("activity: %+v", acts)
	}
	if acts.Items[0].ActorMemberId == nil || *acts.Items[0].ActorMemberId != ana {
		t.Fatalf("actor: %+v", acts.Items[0])
	}
}

func TestExpenseValidation(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben")
	other := createGroup(c, "Zed")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	ok := ExpenseInput{
		Title:       "Taxi",
		Amount:      "10.00",
		OccurredAt:  mustTime(t, "2026-10-01T10:00:00Z"),
		Payers:      []PayerInput{{MemberId: ana, Amount: "10.00"}},
		SplitMethod: "equal",
		Splits:      []Share{{MemberId: ana}, {MemberId: ben}},
	}
	cases := map[string]func(e *ExpenseInput){
		"invalid_title":     func(e *ExpenseInput) { e.Title = "  " },
		"too_many_decimals": func(e *ExpenseInput) { e.Amount = "10.001" },
		"invalid_amount":    func(e *ExpenseInput) { e.Amount = "0" },
		"payer_total":       func(e *ExpenseInput) { e.Payers[0].Amount = "9.99" },
		"no_payers":         func(e *ExpenseInput) { e.Payers = nil },
		"unknown_member":    func(e *ExpenseInput) { e.Splits = []Share{{MemberId: other.Members[0].Id}} },
		"duplicate_member":  func(e *ExpenseInput) { e.Splits = []Share{{MemberId: ana}, {MemberId: ana}} },
		"exact_total":       func(e *ExpenseInput) { e.SplitMethod = "exact"; e.Splits = []Share{{MemberId: ana, Value: ptr("3")}} },
		"percent_total": func(e *ExpenseInput) {
			e.SplitMethod = "percent"
			e.Splits = []Share{{MemberId: ana, Value: ptr("99")}}
		},
		"invalid_category": func(e *ExpenseInput) { e.CategoryId = ptr("nope") },
		"no_members":       func(e *ExpenseInput) { e.Splits = nil },
		"invalid_share":    func(e *ExpenseInput) { e.SplitMethod = "shares"; e.Splits = []Share{{MemberId: ana, Value: ptr("x")}} },
		"amount_too_large": func(e *ExpenseInput) { e.Amount = "99999999999999999" },
	}
	for want, mutate := range cases {
		in := ok
		in.Payers = append([]PayerInput(nil), ok.Payers...)
		mutate(&in)
		if code := c.errorCode(400, "POST", "/g/"+g.Token+"/expenses", in); code != want {
			t.Errorf("%s: got %q", want, code)
		}
	}
}

func TestMembersSummariesAndLinkReset(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	base := "/g/" + g.Token

	var dan Member
	c.must(201, "POST", base+"/members", MemberInput{Name: "Dan"}, &dan)
	if code := c.errorCode(409, "POST", base+"/members", MemberInput{Name: "dan"}); code != "duplicate_name" {
		t.Fatalf("code %q", code)
	}
	var renamed Member
	c.must(200, "PATCH", base+"/members/"+dan.Id, MemberInput{Name: "Daniel", Color: ptr(0xE8A800)}, &renamed)
	if renamed.Name != "Daniel" || renamed.Color == nil {
		t.Fatalf("renamed: %+v", renamed)
	}

	c.must(201, "POST", base+"/expenses", ExpenseInput{
		Title: "Cake", Amount: "6", OccurredAt: mustTime(t, "2026-10-02T10:00:00Z"),
		Payers: []PayerInput{{MemberId: ana, Amount: "6"}}, SplitMethod: "equal",
		Splits: []Share{{MemberId: ana}, {MemberId: ben}},
	}, nil)
	if code := c.errorCode(409, "DELETE", base+"/members/"+ben, nil); code != "member_has_balance" {
		t.Fatalf("code %q", code)
	}
	c.must(204, "DELETE", base+"/members/"+dan.Id, nil, nil)
	c.must(200, "GET", base, nil, &g)
	if !g.Members[2].Left {
		t.Fatal("Dan should have left")
	}

	var sums GroupSummaryList
	c.must(200, "POST", "/groups/summaries", GroupSummaryRequest{Groups: []struct {
		MemberId *string `json:"memberId,omitempty"`
		Token    string  `json:"token"`
	}{{Token: g.Token, MemberId: &ben}, {Token: "AAAAAAAAAAAAAAAAAAAAAA"}}}, &sums)
	if len(sums.Groups) != 1 || len(sums.Missing) != 1 {
		t.Fatalf("summaries: %+v", sums)
	}
	if s := sums.Groups[0]; s.MemberCount != 2 || s.Balance == nil || *s.Balance != "-3.00" {
		t.Fatalf("summary: %+v", s)
	}

	var reset Group
	c.must(200, "POST", base+"/reset-link", nil, &reset)
	if reset.Token == g.Token {
		t.Fatal("token unchanged")
	}
	c.errorCode(404, "GET", base, nil)
	c.must(200, "GET", "/g/"+reset.Token, nil, nil)

	var upd Group
	c.must(200, "PATCH", "/g/"+reset.Token, GroupUpdate{Name: ptr("Lisbon"), Emoji: ptr("🏖️")}, &upd)
	if upd.Name != "Lisbon" || upd.Emoji == nil {
		t.Fatalf("update: %+v", upd)
	}
	var cleared Group
	c.must(200, "PATCH", "/g/"+reset.Token, GroupUpdate{Emoji: ptr("")}, &cleared)
	if cleared.Emoji != nil || cleared.Name != "Lisbon" {
		t.Fatalf("clear emoji: %+v", cleared)
	}

	var dollar Group
	c.must(200, "PATCH", "/g/"+reset.Token, GroupUpdate{Symbol: ptr(" $ ")}, &dollar)
	if dollar.Symbol == nil || *dollar.Symbol != "$" || dollar.Emoji != nil {
		t.Fatalf("symbol: %+v", dollar)
	}
	c.must(200, "PATCH", "/g/"+reset.Token, GroupUpdate{Name: ptr("Porto")}, &dollar)
	if dollar.Symbol == nil || *dollar.Symbol != "$" {
		t.Fatalf("symbol kept: %+v", dollar)
	}
	if code := c.errorCode(400, "PATCH", "/g/"+reset.Token, GroupUpdate{Symbol: ptr("much too long")}); code != "invalid_symbol" {
		t.Fatalf("long symbol: %s", code)
	}
	var plain Group
	c.must(200, "PATCH", "/g/"+reset.Token, GroupUpdate{Symbol: ptr("")}, &plain)
	if plain.Symbol != nil {
		t.Fatalf("clear symbol: %+v", plain)
	}
}

func mustTime(t *testing.T, s string) time.Time {
	t.Helper()
	v, err := time.Parse(time.RFC3339, s)
	if err != nil {
		t.Fatal(err)
	}
	return v
}

func minor(t *testing.T, s string) int64 {
	t.Helper()
	v, err := domain.ParseAmount(strings.TrimPrefix(s, "-"), 2)
	if err != nil {
		t.Fatal(err)
	}
	if strings.HasPrefix(s, "-") {
		return -v
	}
	return v
}

// Someone who left gains no new balance: new expenses and payments may not
// name them, and a deleted expense with them stays deleted, but expenses they
// were already in can still be edited.
func TestDepartedMembers(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben", "Cy")
	ana, ben, cy := g.Members[0].Id, g.Members[1].Id, g.Members[2].Id
	base := "/g/" + g.Token
	expense := func(title, amount string, splits ...string) ExpenseInput {
		in := ExpenseInput{
			Title: title, Amount: amount, OccurredAt: mustTime(t, "2026-01-01T00:00:00Z"),
			Payers: []PayerInput{{MemberId: ana, Amount: amount}}, SplitMethod: "equal",
		}
		for _, id := range splits {
			in.Splits = append(in.Splits, Share{MemberId: id})
		}
		return in
	}
	var taxi, gone, lunch Expense
	c.must(201, "POST", base+"/expenses", expense("Taxi", "10.00", ana, cy), &taxi)
	c.must(201, "POST", base+"/expenses", expense("Snacks", "2.00", ana, cy), &gone)
	c.must(204, "DELETE", base+"/expenses/"+gone.Id, nil, nil)
	c.must(201, "POST", base+"/expenses", expense("Lunch", "6.00", ana, ben), &lunch)
	c.must(201, "POST", base+"/payments", PaymentInput{FromMemberId: cy, ToMemberId: ana, Amount: "5.00"}, nil)
	c.must(204, "DELETE", base+"/members/"+cy, nil, nil)

	if code := c.errorCode(400, "POST", base+"/expenses", expense("Dinner", "4.00", ana, cy)); code != "member_left" {
		t.Fatalf("new expense: %q", code)
	}
	for _, p := range []PaymentInput{{FromMemberId: cy, ToMemberId: ana}, {FromMemberId: ana, ToMemberId: cy}} {
		p.Amount = "1.00"
		if code := c.errorCode(400, "POST", base+"/payments", p); code != "member_left" {
			t.Fatalf("payment %+v: %q", p, code)
		}
	}
	add := expense("Lunch", "6.00", ana, ben, cy)
	add.Version = ptr(lunch.Version)
	if code := c.errorCode(400, "PUT", base+"/expenses/"+lunch.Id, add); code != "member_left" {
		t.Fatalf("adding to an expense: %q", code)
	}
	if code := c.errorCode(409, "POST", base+"/expenses/"+gone.Id+"/restore", nil); code != "member_left" {
		t.Fatalf("restore: %q", code)
	}

	edit := expense("Taxi home", "10.00", ana, cy)
	edit.Version = ptr(taxi.Version)
	c.must(200, "PUT", base+"/expenses/"+taxi.Id, edit, nil)
	var b Balances
	c.must(200, "GET", base+"/balances", nil, &b)
	for _, m := range b.Balances {
		if m.MemberId == cy && m.Amount != "0.00" {
			t.Fatalf("cy's balance %s", m.Amount)
		}
	}
}
