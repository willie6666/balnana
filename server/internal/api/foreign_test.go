package api

import (
	"context"
	"errors"
	"reflect"
	"slices"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5/pgconn"
)

// foreignParts lists an expense's payers or splits as "amount/foreign amount".
func foreignParts[T Payer | SplitPart](list []T) []string {
	out := make([]string, len(list))
	for i, p := range list {
		var amount string
		var foreign *string
		switch p := any(p).(type) {
		case Payer:
			amount, foreign = p.Amount, p.ForeignAmount
		case SplitPart:
			amount, foreign = p.Amount, p.ForeignAmount
		}
		out[i] = amount + "/"
		if foreign != nil {
			out[i] += *foreign
		}
	}
	return out
}

func TestForeignExpense(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben", "Cleo")
	ana, ben, cleo := g.Members[0].Id, g.Members[1].Id, g.Members[2].Id
	base := "/g/" + g.Token
	// 1,000 yen came to 6.43 euros on the card.
	in := ExpenseInput{
		Title:       "Ramen",
		Amount:      "6.43",
		Foreign:     &ForeignInput{Currency: " jpy ", Amount: "1000"},
		OccurredAt:  mustTime(t, "2026-10-01T12:00:00Z"),
		Payers:      []PayerInput{{MemberId: ana, Amount: "600"}, {MemberId: ben, Amount: "400"}},
		SplitMethod: "exact",
		Splits:      []Share{{MemberId: ana, Value: ptr("334")}, {MemberId: ben, Value: ptr("333")}, {MemberId: cleo, Value: ptr("333")}},
	}
	var e Expense
	c.must(201, "POST", base+"/expenses", in, &e)
	if e.Amount != "6.43" || e.Foreign == nil || *e.Foreign != (Foreign{Currency: "JPY", MinorDigits: 0, Amount: "1000"}) {
		t.Fatalf("expense: %+v %+v", e, e.Foreign)
	}
	// The euros are spread like the yen: 3.858 and 2.572 round to 3.86 and 2.57.
	if got := foreignParts(e.Payers); !slices.Equal(got, []string{"3.86/600", "2.57/400"}) {
		t.Errorf("payers %v", got)
	}
	// 2.14762 + 2.14119 * 2: the largest remainder takes the extra cent.
	if got := foreignParts(e.Splits); !slices.Equal(got, []string{"2.15/334", "2.14/333", "2.14/333"}) {
		t.Errorf("splits %v", got)
	}

	// Balances are in euros.
	var b Balances
	c.must(200, "GET", base+"/balances", nil, &b)
	want := map[string]string{ana: "1.71", ben: "0.43", cleo: "-2.14"}
	for _, m := range b.Balances {
		if want[m.MemberId] != string(m.Amount) {
			t.Errorf("balance %s: %s", m.MemberId, m.Amount)
		}
	}

	var page ExpensePage
	c.must(200, "GET", base+"/expenses", nil, &page)
	if len(page.Items) != 1 || !reflect.DeepEqual(page.Items[0].Foreign, e.Foreign) {
		t.Fatalf("list: %+v", page.Items)
	}
	var acts ActivityPage
	c.must(200, "GET", base+"/activity?limit=1", nil, &acts)
	if p := acts.Items[0].Payload; p["foreignAmount"] != "1000" || p["foreignCurrency"] != "JPY" {
		t.Errorf("activity payload %+v", p)
	}

	// An edit can drop the foreign amount ...
	plain := ExpenseInput{
		Title: "Ramen", Amount: "6.43", OccurredAt: in.OccurredAt, Version: ptr(1),
		Payers:      []PayerInput{{MemberId: ana, Amount: "6.43"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ben}},
	}
	id, e := e.Id, Expense{} // decode afresh: a field left out stays as it was
	c.must(200, "PUT", base+"/expenses/"+id, plain, &e)
	if e.Foreign != nil || !slices.Equal(foreignParts(e.Payers), []string{"6.43/"}) ||
		!slices.Equal(foreignParts(e.Splits), []string{"6.43/"}) {
		t.Errorf("plain edit: %+v %v %v", e.Foreign, foreignParts(e.Payers), foreignParts(e.Splits))
	}
	// ... and add one back, here with three decimals.
	in.Version = ptr(2)
	in.Foreign = &ForeignInput{Currency: "KWD", Amount: "2.1"}
	in.Payers = []PayerInput{{MemberId: cleo, Amount: "2.100"}}
	in.Splits = []Share{{MemberId: ana, Value: ptr("0.8")}, {MemberId: ben, Value: ptr("0.7")}, {MemberId: cleo, Value: ptr("0.6")}}
	e = Expense{}
	c.must(200, "PUT", base+"/expenses/"+id, in, &e)
	if e.Foreign == nil || *e.Foreign != (Foreign{Currency: "KWD", MinorDigits: 3, Amount: "2.100"}) ||
		!slices.Equal(foreignParts(e.Payers), []string{"6.43/2.100"}) ||
		!slices.Equal(foreignParts(e.Splits), []string{"2.45/0.800", "2.14/0.700", "1.84/0.600"}) {
		t.Errorf("foreign edit: %+v %v %v", e.Foreign, foreignParts(e.Payers), foreignParts(e.Splits))
	}
}

func TestForeignExpenseValidation(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	base := "/g/" + g.Token
	ok := func() ExpenseInput {
		return ExpenseInput{
			Title: "Taxi", Amount: "10.00", Foreign: &ForeignInput{Currency: "JPY", Amount: "1600"},
			OccurredAt:  mustTime(t, "2026-10-01T10:00:00Z"),
			Payers:      []PayerInput{{MemberId: ana, Amount: "1600"}},
			SplitMethod: "equal", Splits: []Share{{MemberId: ana}, {MemberId: ben}},
		}
	}
	c.must(201, "POST", base+"/expenses", ok(), nil)
	cases := map[string]func(e *ExpenseInput){
		"invalid_currency":  func(e *ExpenseInput) { e.Foreign.Currency = "EUR" }, // the group's own
		"too_many_decimals": func(e *ExpenseInput) { e.Foreign.Amount = "1600.5" },
		"invalid_amount":    func(e *ExpenseInput) { e.Foreign.Amount = "0" },
		// Payers are entered in the foreign currency.
		"payer_total": func(e *ExpenseInput) { e.Payers[0].Amount = "10.00" },
		// A yen of 1,600 is not a cent.
		"payer_too_small": func(e *ExpenseInput) {
			e.Amount = "0.01"
			e.Payers = []PayerInput{{MemberId: ana, Amount: "1599"}, {MemberId: ben, Amount: "1"}}
		},
	}
	for _, currency := range []string{"", "JP", "J1Y", "eu"} {
		cases["invalid_currency "+currency] = func(e *ExpenseInput) { e.Foreign.Currency = currency }
	}
	for name, mutate := range cases {
		in := ok()
		mutate(&in)
		want, _, _ := strings.Cut(name, " ")
		if code := c.errorCode(400, "POST", base+"/expenses", in); code != want {
			t.Errorf("%s: got %q", name, code)
		}
	}

	// Payments stay in the group's currency.
	var p Expense
	c.must(201, "POST", base+"/payments", PaymentInput{FromMemberId: ben, ToMemberId: ana, Amount: "5.00"}, &p)
	edit := ExpenseInput{
		Title: p.Title, Amount: "5.00", Foreign: &ForeignInput{Currency: "JPY", Amount: "800"},
		OccurredAt: p.OccurredAt, Version: &p.Version,
		Payers:      []PayerInput{{MemberId: ben, Amount: "800"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ana}},
	}
	if code := c.errorCode(400, "PUT", base+"/expenses/"+p.Id, edit); code != "invalid_payment" {
		t.Errorf("foreign payment: %q", code)
	}
}

func TestForeignTotalsConstraint(t *testing.T) {
	c, _, pool := adminClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	var foreign, plain Expense
	c.must(201, "POST", "/g/"+g.Token+"/expenses", ExpenseInput{
		Title: "Sushi", Amount: "10.00", Foreign: &ForeignInput{Currency: "JPY", Amount: "1600"},
		OccurredAt: mustTime(t, "2026-10-01T10:00:00Z"), SplitMethod: "equal",
		Payers: []PayerInput{{MemberId: ana, Amount: "1600"}}, Splits: []Share{{MemberId: ana}, {MemberId: ben}},
	}, &foreign)
	c.must(201, "POST", "/g/"+g.Token+"/expenses", ExpenseInput{
		Title: "Tea", Amount: "10.00", OccurredAt: mustTime(t, "2026-10-01T10:00:00Z"), SplitMethod: "equal",
		Payers: []PayerInput{{MemberId: ana, Amount: "10.00"}}, Splits: []Share{{MemberId: ben}},
	}, &plain)
	ctx := context.Background()

	for _, tc := range []struct {
		name, sql string
		id        string
	}{
		{"foreign total", `update expenses set foreign_amount = 1700 where id = $1`, foreign.Id},
		{"foreign payer", `update expense_payers set foreign_amount = 1500 where expense_id = $1`, foreign.Id},
		{"foreign split", `update expense_splits set foreign_amount = 900 where expense_id = $1 and amount = 500`, foreign.Id},
		{"missing foreign split", `update expense_splits set foreign_amount = null where expense_id = $1`, foreign.Id},
		{"foreign part on a plain expense", `update expense_payers set foreign_amount = 5 where expense_id = $1`, plain.Id},
		{"dropped foreign amount", `update expenses set foreign_currency = null, foreign_digits = null, foreign_amount = null
			where id = $1`, foreign.Id},
	} {
		t.Run(tc.name, func(t *testing.T) {
			tx, err := pool.Begin(ctx)
			if err != nil {
				t.Fatal(err)
			}
			defer tx.Rollback(ctx)
			if _, err := tx.Exec(ctx, tc.sql, tc.id); err != nil {
				t.Fatalf("constraint fired before commit: %v", err)
			}
			err = tx.Commit(ctx)
			var pg *pgconn.PgError
			if !errors.As(err, &pg) || pg.Code != "23514" || pg.ConstraintName != "expense_totals" {
				t.Fatalf("wanted expense_totals violation at commit, got %v", err)
			}
		})
	}

	// The currency, its digits and the amount are there together or not at all.
	_, err := pool.Exec(ctx, `update expenses set foreign_digits = null where id = $1`, foreign.Id)
	var pg *pgconn.PgError
	if !errors.As(err, &pg) || pg.ConstraintName != "expenses_foreign_check" {
		t.Fatalf("wanted expenses_foreign_check, got %v", err)
	}
}

func TestPushForeignAmount(t *testing.T) {
	c, f, s := pushClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	subscribe(c, "ben-phone", follow(g.Token, ben))
	c.member = ana
	c.must(201, "POST", "/g/"+g.Token+"/expenses", ExpenseInput{
		Title: "Sushi", Amount: "10.00", Foreign: &ForeignInput{Currency: "JPY", Amount: "1600"},
		OccurredAt: mustTime(t, "2026-10-01T10:00:00Z"), SplitMethod: "equal",
		Payers: []PayerInput{{MemberId: ana, Amount: "1600"}}, Splits: []Share{{MemberId: ana}, {MemberId: ben}},
	}, nil)
	if sent := f.take(s); len(sent) != 1 || !slices.Equal(sent[0].n.Args, []string{"Ana", "Sushi", "1600 JPY (10.00 EUR)"}) {
		t.Errorf("sent %+v", sent)
	}
}
