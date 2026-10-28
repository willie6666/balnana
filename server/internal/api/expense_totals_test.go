package api

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgconn"
)

func TestExpenseTotalsConstraint(t *testing.T) {
	c, _, pool := adminClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben")
	c.member = g.Members[0].Id
	var first, second Expense
	create := func(payer, receiver string, out *Expense) {
		c.must(201, "POST", "/g/"+g.Token+"/expenses", ExpenseInput{
			Title: "Dinner", Amount: "10.00", OccurredAt: time.Now(), SplitMethod: "equal",
			Payers: []PayerInput{{MemberId: payer, Amount: "10.00"}}, Splits: []Share{{MemberId: receiver}},
		}, out)
	}
	create(g.Members[0].Id, g.Members[1].Id, &first)
	create(g.Members[1].Id, g.Members[0].Id, &second)
	ctx := context.Background()

	for _, tc := range []struct {
		name, sql string
		args      []any
	}{
		{"parent amount", `update expenses set amount = 900 where id = $1`, []any{first.Id}},
		{"payer amount", `update expense_payers set amount = 900 where expense_id = $1`, []any{first.Id}},
		{"split amount", `update expense_splits set amount = 900 where expense_id = $1`, []any{first.Id}},
		{"deleted payer", `delete from expense_payers where expense_id = $1`, []any{first.Id}},
		{"deleted split", `delete from expense_splits where expense_id = $1`, []any{first.Id}},
		{"extra payer", `insert into expense_payers values ($1, $2, 1)`, []any{first.Id, g.Members[1].Id}},
		{"extra split", `insert into expense_splits (expense_id, member_id, amount) values ($1, $2, 1)`, []any{first.Id, g.Members[0].Id}},
		{"moved payer", `update expense_payers set expense_id = $2 where expense_id = $1`, []any{first.Id, second.Id}},
		{"moved split", `update expense_splits set expense_id = $2 where expense_id = $1`, []any{first.Id, second.Id}},
		{"missing parts", `insert into expenses (group_id, title, amount, currency, split_method, occurred_at)
			select group_id, 'Empty', 1000, currency, 'equal', now() from expenses where id = $1`, []any{first.Id}},
	} {
		t.Run(tc.name, func(t *testing.T) {
			tx, err := pool.Begin(ctx)
			if err != nil {
				t.Fatal(err)
			}
			defer tx.Rollback(ctx)
			// Parts can be temporarily inconsistent within the transaction.
			if _, err := tx.Exec(ctx, tc.sql, tc.args...); err != nil {
				t.Fatalf("constraint fired before commit: %v", err)
			}
			err = tx.Commit(ctx)
			var pg *pgconn.PgError
			if !errors.As(err, &pg) || pg.Code != "23514" || pg.ConstraintName != "expense_totals" {
				t.Fatalf("wanted expense_totals violation at commit, got %v", err)
			}
		})
	}

	// A normal full rewrite succeeds even though its intermediate rows differ.
	tx, err := pool.Begin(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer tx.Rollback(ctx)
	for _, sql := range []string{
		`update expenses set amount = 2000 where id = $1`,
		`delete from expense_payers where expense_id = $1`,
		`insert into expense_payers (expense_id, member_id, amount)
		 select id, (select member_id from expense_splits where expense_id = $1 limit 1), amount from expenses where id = $1`,
		`update expense_splits set amount = 2000 where expense_id = $1`,
	} {
		if _, err := tx.Exec(ctx, sql, first.Id); err != nil {
			t.Fatal(err)
		}
	}
	if err := tx.Commit(ctx); err != nil {
		t.Fatalf("balanced rewrite rejected: %v", err)
	}
	// Removing the parent must not reject its cascading child deletions.
	if _, err := pool.Exec(ctx, `delete from groups where token = $1`, g.Token); err != nil {
		t.Fatalf("group cascade rejected: %v", err)
	}
}
