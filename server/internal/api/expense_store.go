package api

import (
	"context"
	"errors"
	"strings"

	"github.com/jackc/pgx/v5"

	"balnana/internal/domain"
)

// maxGroupTotal caps what the live expenses and payments of a group add up
// to. Every balance and spending total is at most that sum, so it keeps them
// all far from int64 overflow.
const maxGroupTotal = 1000 * domain.MaxMinor

// groupTotal is what the group's live entries add up to. except leaves out
// an entry being replaced.
func groupTotal(ctx context.Context, q querier, groupID string, except *string) (int64, error) {
	var total int64
	err := q.QueryRow(ctx, `
		select coalesce(sum(amount), 0)::bigint from expenses
		where group_id = $1 and deleted_at is null and ($2::uuid is null or id <> $2::uuid)`,
		groupID, except).Scan(&total)
	return total, err
}

// checkGroupTotal refuses add more to the group's live entries when they
// would pass maxGroupTotal. except leaves out an entry being replaced.
func checkGroupTotal(ctx context.Context, q querier, groupID string, add int64, except *string) error {
	total, err := groupTotal(ctx, q, groupID, except)
	if err != nil {
		return err
	}
	return fitsGroupTotal(total, add)
}

// fitsGroupTotal refuses adding add to a group whose entries add up to total
// when that would pass maxGroupTotal.
func fitsGroupTotal(total, add int64) error {
	if total > maxGroupTotal-add {
		return domain.ErrAmountTooLarge
	}
	return nil
}

// partTables names where the payers and splits of one kind of row are kept.
// Only expense parts have a foreign_amount column.
type partTables struct {
	payers, splits, key string
	foreign             bool
}

var (
	expenseParts   = partTables{"expense_payers", "expense_splits", "expense_id", true}
	recurringParts = partTables{"recurring_expense_payers", "recurring_expense_splits", "recurring_id", false}
)

// foreignColumn is the foreign_amount column to select, or a null for parts
// without one.
func (t partTables) foreignColumn(alias string) string {
	if t.foreign {
		return alias + ".foreign_amount"
	}
	return "null::bigint"
}

func (t partTables) insert(ctx context.Context, tx pgx.Tx, id string, d *expenseData) error {
	if d.foreign != nil && !t.foreign {
		return errors.New("api: " + t.payers + " cannot hold foreign amounts")
	}
	column := ""
	if t.foreign {
		column = ", foreign_amount"
	}
	// foreign is a part's foreign amount, or null when the expense has none.
	foreign := func(amounts map[string]int64, m string) *int64 {
		if d.foreign == nil {
			return nil
		}
		v := amounts[m]
		return &v
	}
	var payers, splits map[string]int64
	if d.foreign != nil {
		payers, splits = d.foreign.payers, d.foreign.splits
	}
	for m, v := range d.payers {
		args, values := []any{id, m, v}, "$1, $2, $3"
		if t.foreign {
			args, values = append(args, foreign(payers, m)), values+", $4"
		}
		if _, err := tx.Exec(ctx, `insert into `+t.payers+` (`+t.key+`, member_id, amount`+column+`)
			values (`+values+`)`, args...); err != nil {
			return err
		}
	}
	for m, v := range d.splits {
		var share *string
		if s, ok := d.shares[m]; ok {
			share = &s
		}
		args, values := []any{id, m, v, share}, "$1, $2, $3, $4::text::numeric"
		if t.foreign {
			args, values = append(args, foreign(splits, m)), values+", $5"
		}
		if _, err := tx.Exec(ctx, `
			insert into `+t.splits+` (`+t.key+`, member_id, amount, share`+column+`)
			values (`+values+`)`, args...); err != nil {
			return err
		}
	}
	return nil
}

// replace swaps the payers and splits of id for d's.
func (t partTables) replace(ctx context.Context, tx pgx.Tx, id string, d *expenseData) error {
	for _, table := range []string{t.payers, t.splits} {
		if _, err := tx.Exec(ctx, `delete from `+table+` where `+t.key+` = $1`, id); err != nil {
			return err
		}
	}
	return t.insert(ctx, tx, id, d)
}

// load reads the payers and splits of the rows ids, in member order, and
// hands each to its row with its foreign amount in minor units, if any.
func (t partTables) load(ctx context.Context, q querier, digits int, ids []string,
	payer func(id string, p Payer, foreign *int64), split func(id string, p SplitPart, foreign *int64)) error {
	rows, err := q.Query(ctx, `
		select p.`+t.key+`::text, p.member_id::text, p.amount, `+t.foreignColumn("p")+`
		from `+t.payers+` p join members m on m.id = p.member_id
		where p.`+t.key+` = any($1::uuid[]) order by m.created_at, m.id`, ids)
	if err != nil {
		return err
	}
	var id, mid string
	var amount int64
	var foreign *int64
	_, err = pgx.ForEachRow(rows, []any{&id, &mid, &amount, &foreign}, func() error {
		payer(id, Payer{MemberId: mid, Amount: domain.FormatAmount(amount, digits)}, foreign)
		return nil
	})
	if err != nil {
		return err
	}

	rows, err = q.Query(ctx, `
		select s.`+t.key+`::text, s.member_id::text, s.amount, s.share::text, `+t.foreignColumn("s")+`
		from `+t.splits+` s join members m on m.id = s.member_id
		where s.`+t.key+` = any($1::uuid[]) order by m.created_at, m.id`, ids)
	if err != nil {
		return err
	}
	var share *string
	_, err = pgx.ForEachRow(rows, []any{&id, &mid, &amount, &share, &foreign}, func() error {
		part := SplitPart{MemberId: mid, Amount: domain.FormatAmount(amount, digits)}
		if share != nil {
			v := trimShare(*share)
			part.Share = &v
		}
		split(id, part, foreign)
		return nil
	})
	return err
}

// insertExpense stores a validated expense and logs it.
func insertExpense(ctx context.Context, tx pgx.Tx, g *group, who *string, d *expenseData, payload map[string]any) (string, error) {
	id, err := storeExpense(ctx, tx, g, who, d)
	if err != nil {
		return "", err
	}
	return id, logActivity(ctx, tx, g.id, who, "expense.created", &id, payload)
}

// storeExpense stores a validated expense without logging it.
func storeExpense(ctx context.Context, tx pgx.Tx, g *group, who *string, d *expenseData) (string, error) {
	var id string
	place, lat, lng := locationColumns(d.location)
	err := tx.QueryRow(ctx, `
		insert into expenses (group_id, kind, title, category_id, amount, currency, split_method, occurred_at, note,
			created_by_member, transaction_type, location_name, latitude, longitude,
			client_key, foreign_currency, foreign_digits, foreign_amount)
		values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18) returning id::text`,
		append([]any{g.id, d.kind, d.title, d.category, d.amount, g.currency, string(d.method), d.occurredAt, d.note, who,
			d.transactionType, place, lat, lng, d.clientKey}, foreignColumns(d.foreign)...)...).Scan(&id)
	if err != nil {
		return "", err
	}
	return id, expenseParts.insert(ctx, tx, id, d)
}

// foreignColumns splits an expense's foreign amount into its foreign_currency,
// foreign_digits and foreign_amount columns.
func foreignColumns(f *foreignData) []any {
	if f == nil {
		return []any{nil, nil, nil}
	}
	return []any{f.currency, f.digits, f.amount}
}

const expenseColumns = `id::text, kind::text, title, category_id, amount, occurred_at, note, split_method::text,
	created_by_member::text, created_at, updated_at, deleted_at, version, transaction_type,
	exists (select 1 from receipts r where r.expense_id = expenses.id), location_name, latitude, longitude,
	recurring_id::text, foreign_currency::text, foreign_digits, foreign_amount`

// loadExpenses runs a query selecting expenseColumns and attaches payers and splits.
func loadExpenses(ctx context.Context, q querier, digits int, sql string, args ...any) ([]Expense, error) {
	rows, err := q.Query(ctx, sql, args...)
	if err != nil {
		return nil, err
	}
	list, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (Expense, error) {
		var e Expense
		var kind, method string
		var amount int64
		var place, foreignCurrency *string
		var lat, lng *float64
		var foreignDigits *int
		var foreignAmount *int64
		err := row.Scan(&e.Id, &kind, &e.Title, &e.CategoryId, &amount, &e.OccurredAt, &e.Note, &method,
			&e.CreatedBy, &e.CreatedAt, &e.UpdatedAt, &e.DeletedAt, &e.Version, &e.TransactionType, &e.HasReceipt,
			&place, &lat, &lng, &e.RecurringId, &foreignCurrency, &foreignDigits, &foreignAmount)
		e.Location = locationOf(place, lat, lng)
		if foreignCurrency != nil && foreignDigits != nil && foreignAmount != nil {
			e.Foreign = &Foreign{Currency: *foreignCurrency, MinorDigits: *foreignDigits,
				Amount: domain.FormatAmount(*foreignAmount, *foreignDigits)}
		}
		e.Kind = ExpenseKind(kind)
		e.SplitMethod = SplitMethod(method)
		e.Amount = domain.FormatAmount(amount, digits)
		e.Payers = []Payer{}
		e.Splits = []SplitPart{}
		return e, err
	})
	if err != nil || len(list) == 0 {
		return list, err
	}

	index := make(map[string]*Expense, len(list))
	ids := make([]string, len(list))
	for i := range list {
		index[list[i].Id] = &list[i]
		ids[i] = list[i].Id
	}
	// foreignOf formats a part's foreign amount in its expense's currency.
	foreignOf := func(id string, v *int64) *string {
		f := index[id].Foreign
		if f == nil || v == nil {
			return nil
		}
		s := domain.FormatAmount(*v, f.MinorDigits)
		return &s
	}
	err = expenseParts.load(ctx, q, digits, ids,
		func(id string, p Payer, foreign *int64) {
			p.ForeignAmount = foreignOf(id, foreign)
			index[id].Payers = append(index[id].Payers, p)
		},
		func(id string, p SplitPart, foreign *int64) {
			p.ForeignAmount = foreignOf(id, foreign)
			index[id].Splits = append(index[id].Splits, p)
		})
	return list, err
}

// trimShare drops trailing zeros of a numeric(12,4): "33.3300" -> "33.33".
func trimShare(s string) string {
	if !strings.Contains(s, ".") {
		return s
	}
	s = strings.TrimRight(s, "0")
	return strings.TrimSuffix(s, ".")
}

func loadExpense(ctx context.Context, q querier, g *group, id string) (Expense, error) {
	if !validUUID(id) {
		return Expense{}, errNotFound
	}
	list, err := loadExpenses(ctx, q, g.digits, `select `+expenseColumns+` from expenses where id = $1 and group_id = $2`, id, g.id)
	if err != nil {
		return Expense{}, err
	}
	if len(list) == 0 {
		return Expense{}, errNotFound
	}
	return list[0], nil
}

// sentBefore finds what an earlier try of a create request added, or "" when
// there is none. The caller holds the group's lock, so two tries cannot both
// miss it.
func sentBefore(ctx context.Context, tx pgx.Tx, table, groupID string, key *IdempotencyKey) (string, error) {
	if key == nil {
		return "", nil
	}
	var id string
	err := tx.QueryRow(ctx, `select id::text from `+table+` where group_id = $1 and client_key = $2`, groupID, *key).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", nil
	}
	return id, err
}

// expenseMembers returns who pays or shares in an expense.
func expenseMembers(ctx context.Context, q querier, id string) (map[string]bool, error) {
	rows, err := q.Query(ctx, `
		select member_id::text from expense_payers where expense_id = $1
		union select member_id::text from expense_splits where expense_id = $1`, id)
	if err != nil {
		return nil, err
	}
	ids, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil {
		return nil, err
	}
	set := make(map[string]bool, len(ids))
	for _, id := range ids {
		set[id] = true
	}
	return set, nil
}

// lockExpense reads an expense's kind, version and deleted state, holding the row.
func lockExpense(ctx context.Context, tx pgx.Tx, g *group, id string) (kind string, version int, deleted bool, title string, err error) {
	if !validUUID(id) {
		return "", 0, false, "", errNotFound
	}
	err = tx.QueryRow(ctx, `
		select kind::text, version, deleted_at is not null, title
		from expenses where id = $1 and group_id = $2 for update`, id, g.id).Scan(&kind, &version, &deleted, &title)
	if errors.Is(err, pgx.ErrNoRows) {
		err = errNotFound
	}
	return
}
