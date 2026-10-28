package api

import (
	"context"
	"encoding/base64"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"

	"balnana/internal/domain"
)

const (
	kindExpense = "expense"
	kindPayment = "payment"
)

// expenseData is a validated expense, ready to store.
type expenseData struct {
	kind            string
	transactionType string
	title           string
	category        *string
	amount          int64
	occurredAt      time.Time
	note            *string
	location        *Location
	method          domain.SplitMethod
	payers          map[string]int64
	splits          map[string]int64
	shares          map[string]string // entered weight, 4 decimals
}

// Dates an expense may have: wide enough for any real one, and well inside
// what JSON and the database can carry.
const (
	minExpenseYear = 1900
	maxExpenseYear = 2999
)

// maxGroupTotal caps what the live expenses and payments of a group add up
// to. Every balance and spending total is at most that sum, so it keeps them
// all far from int64 overflow.
const maxGroupTotal = 1000 * domain.MaxMinor

// checkGroupTotal refuses add more to the group's live entries when they
// would pass maxGroupTotal. except leaves out an entry being replaced.
func checkGroupTotal(ctx context.Context, q querier, groupID string, add int64, except *string) error {
	var total int64
	err := q.QueryRow(ctx, `
		select coalesce(sum(amount), 0)::bigint from expenses
		where group_id = $1 and deleted_at is null and ($2::uuid is null or id <> $2::uuid)`,
		groupID, except).Scan(&total)
	if err != nil {
		return err
	}
	if total > maxGroupTotal-add {
		return domain.ErrAmountTooLarge
	}
	return nil
}

// validateExpense checks an expense against the group: every member must
// belong to it, payers must add up to the amount and the split must work.
// Members who left may only stay in an expense they were already part of
// (those in already), so no one gains a new balance after leaving. members
// is the group's, or nil to load them.
func validateExpense(ctx context.Context, q querier, g *group, kind string, in ExpenseInput,
	already map[string]bool, members []member) (*expenseData, error) {
	d := &expenseData{kind: kind, transactionType: "expense", occurredAt: in.OccurredAt, method: domain.SplitMethod(in.SplitMethod)}

	minTitle := 1
	if kind == kindPayment {
		minTitle = 0
	}
	title, ok := cleanText(in.Title, minTitle, maxTitleLen)
	if !ok || strings.Contains(title, "\n") {
		return nil, badRequest("invalid_title")
	}
	d.title = title

	if in.Note != nil {
		note, ok := cleanText(*in.Note, 0, maxNoteLen)
		if !ok {
			return nil, badRequest("invalid_note")
		}
		if note != "" {
			d.note = &note
		}
	}
	if in.Location != nil {
		loc, err := cleanLocation(*in.Location)
		if err != nil {
			return nil, err
		}
		d.location = loc
	}
	if y := in.OccurredAt.Year(); in.OccurredAt.IsZero() || y < minExpenseYear || y > maxExpenseYear {
		return nil, badRequest("invalid_date")
	}

	if in.CategoryId != nil && *in.CategoryId != "" {
		var exists bool
		if err := q.QueryRow(ctx, `
			select exists (select 1 from categories where id = $1 and (group_id is null or group_id = $2))`,
			*in.CategoryId, g.id).Scan(&exists); err != nil {
			return nil, err
		}
		if !exists {
			return nil, badRequest("invalid_category")
		}
		d.category = in.CategoryId
	}

	amount, err := domain.ParseAmount(in.Amount, g.digits)
	if err != nil {
		return nil, err
	}
	if amount <= 0 {
		return nil, domain.ErrInvalidAmount
	}
	d.amount = amount

	if members == nil {
		if members, err = groupMembers(ctx, q, g.id); err != nil {
			return nil, err
		}
	}
	known := func(id string) error {
		m := findMember(members, id)
		if m == nil {
			return badRequest("unknown_member")
		}
		if m.left && !already[id] {
			return badRequest("member_left")
		}
		return nil
	}

	if len(in.Payers) == 0 {
		return nil, badRequest("no_payers")
	}
	if len(in.Payers) > maxMembers || len(in.Splits) > maxMembers {
		return nil, badRequest("too_many_members")
	}
	d.payers = make(map[string]int64, len(in.Payers))
	var paid int64
	for _, p := range in.Payers {
		if err := known(p.MemberId); err != nil {
			return nil, err
		}
		if _, dup := d.payers[p.MemberId]; dup {
			return nil, domain.ErrDuplicateMember
		}
		v, err := domain.ParseAmount(p.Amount, g.digits)
		if err != nil {
			return nil, err
		}
		if v <= 0 {
			return nil, domain.ErrInvalidAmount
		}
		d.payers[p.MemberId] = v
		paid += v // each v <= MaxMinor and there are few: no overflow
	}
	if paid != amount {
		return nil, badRequest("payer_total")
	}

	parts := make([]domain.Part, 0, len(in.Splits))
	d.shares = map[string]string{}
	for _, sp := range in.Splits {
		if err := known(sp.MemberId); err != nil {
			return nil, err
		}
		value := ""
		if sp.Value != nil {
			value = strings.TrimSpace(*sp.Value)
		}
		if d.method == domain.SplitShares {
			w, err := domain.ParseAmount(value, 4)
			if err != nil || w < 0 || w > maxShareValue {
				return nil, domain.ErrInvalidShare
			}
			d.shares[sp.MemberId] = domain.FormatAmount(w, 4)
		}
		parts = append(parts, domain.Part{Member: sp.MemberId, Value: value})
	}
	d.splits, err = domain.Split(amount, g.digits, d.method, parts)
	if err != nil {
		return nil, err
	}

	if kind == kindPayment {
		if len(d.payers) != 1 || len(d.splits) != 1 || d.method != domain.SplitExact {
			return nil, badRequest("invalid_payment")
		}
		for from := range d.payers {
			if _, self := d.splits[from]; self {
				return nil, badRequest("invalid_payment")
			}
		}
	}
	return d, nil
}

func insertParts(ctx context.Context, tx pgx.Tx, expenseID string, d *expenseData) error {
	for m, v := range d.payers {
		if _, err := tx.Exec(ctx, `insert into expense_payers (expense_id, member_id, amount) values ($1, $2, $3)`, expenseID, m, v); err != nil {
			return err
		}
	}
	for m, v := range d.splits {
		var share *string
		if s, ok := d.shares[m]; ok {
			share = &s
		}
		if _, err := tx.Exec(ctx, `
			insert into expense_splits (expense_id, member_id, amount, share)
			values ($1, $2, $3, $4::text::numeric)`, expenseID, m, v, share); err != nil {
			return err
		}
	}
	return nil
}

func (d *expenseData) payload(digits int) map[string]any {
	return map[string]any{"title": d.title, "amount": domain.FormatAmount(d.amount, digits), "kind": d.kind}
}

// cleanLocation checks where an expense happened. A location with neither a
// name nor a point is none.
func cleanLocation(in Location) (*Location, error) {
	var out Location
	if in.Name != nil {
		name, ok := cleanText(*in.Name, 0, maxTitleLen)
		if !ok || strings.Contains(name, "\n") {
			return nil, badRequest("invalid_location")
		}
		if name != "" {
			out.Name = &name
		}
	}
	if p := in.Point; p != nil {
		// NaN fails both comparisons, so it is refused too.
		if !(p.Latitude >= -90 && p.Latitude <= 90 && p.Longitude >= -180 && p.Longitude <= 180) {
			return nil, badRequest("invalid_location")
		}
		out.Point = &GeoPoint{Latitude: p.Latitude, Longitude: p.Longitude}
	}
	if out.Name == nil && out.Point == nil {
		return nil, nil
	}
	return &out, nil
}

// locationColumns splits a location into its location_name, latitude and
// longitude columns.
func locationColumns(l *Location) (name *string, lat, lng *float64) {
	if l == nil {
		return nil, nil, nil
	}
	if l.Point != nil {
		lat, lng = &l.Point.Latitude, &l.Point.Longitude
	}
	return l.Name, lat, lng
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
			created_by_member, transaction_type, location_name, latitude, longitude)
		values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) returning id::text`,
		g.id, d.kind, d.title, d.category, d.amount, g.currency, string(d.method), d.occurredAt, d.note, who,
		d.transactionType, place, lat, lng).Scan(&id)
	if err != nil {
		return "", err
	}
	return id, insertParts(ctx, tx, id, d)
}

const expenseColumns = `id::text, kind::text, title, category_id, amount, occurred_at, note, split_method::text,
	created_by_member::text, created_at, updated_at, deleted_at, version, transaction_type,
	exists (select 1 from receipts r where r.expense_id = expenses.id), location_name, latitude, longitude,
	recurring_id::text`

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
		var place *string
		var lat, lng *float64
		err := row.Scan(&e.Id, &kind, &e.Title, &e.CategoryId, &amount, &e.OccurredAt, &e.Note, &method,
			&e.CreatedBy, &e.CreatedAt, &e.UpdatedAt, &e.DeletedAt, &e.Version, &e.TransactionType, &e.HasReceipt,
			&place, &lat, &lng, &e.RecurringId)
		if place != nil || lat != nil {
			e.Location = &Location{Name: place}
			if lat != nil && lng != nil {
				e.Location.Point = &GeoPoint{Latitude: *lat, Longitude: *lng}
			}
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

	rows, err = q.Query(ctx, `
		select p.expense_id::text, p.member_id::text, p.amount
		from expense_payers p join members m on m.id = p.member_id
		where p.expense_id = any($1::uuid[]) order by m.created_at, m.id`, ids)
	if err != nil {
		return nil, err
	}
	var eid, mid string
	var amount int64
	_, err = pgx.ForEachRow(rows, []any{&eid, &mid, &amount}, func() error {
		e := index[eid]
		e.Payers = append(e.Payers, Payer{MemberId: mid, Amount: domain.FormatAmount(amount, digits)})
		return nil
	})
	if err != nil {
		return nil, err
	}

	rows, err = q.Query(ctx, `
		select s.expense_id::text, s.member_id::text, s.amount, s.share::text
		from expense_splits s join members m on m.id = s.member_id
		where s.expense_id = any($1::uuid[]) order by m.created_at, m.id`, ids)
	if err != nil {
		return nil, err
	}
	var share *string
	_, err = pgx.ForEachRow(rows, []any{&eid, &mid, &amount, &share}, func() error {
		e := index[eid]
		part := SplitPart{MemberId: mid, Amount: domain.FormatAmount(amount, digits)}
		if share != nil {
			v := trimShare(*share)
			part.Share = &v
		}
		e.Splits = append(e.Splits, part)
		return nil
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

// Expense cursors are opaque to clients: "<occurred_at>|<id>" in base64url.
func encodeExpenseCursor(e Expense) string {
	return base64.RawURLEncoding.EncodeToString([]byte(e.OccurredAt.Format(time.RFC3339Nano) + "|" + e.Id))
}

func decodeExpenseCursor(c string) (time.Time, string, error) {
	raw, err := base64.RawURLEncoding.DecodeString(c)
	if err != nil {
		return time.Time{}, "", badRequest("invalid_cursor")
	}
	at, id, ok := strings.Cut(string(raw), "|")
	t, err := time.Parse(time.RFC3339Nano, at)
	if !ok || err != nil || !validUUID(id) {
		return time.Time{}, "", badRequest("invalid_cursor")
	}
	return t, id, nil
}

func (s *Server) ListExpenses(ctx context.Context, req ListExpensesRequestObject) (ListExpensesResponseObject, error) {
	g, err := s.groupByToken(ctx, s.db, req.Token, false)
	if err != nil {
		return nil, err
	}
	limit := pageSize(req.Params.Limit)
	var afterAt *time.Time
	var afterID *string
	if req.Params.Cursor != nil && *req.Params.Cursor != "" {
		t, id, err := decodeExpenseCursor(*req.Params.Cursor)
		if err != nil {
			return nil, err
		}
		afterAt, afterID = &t, &id
	}
	f := expenseFilter{q: req.Params.Q, member: req.Params.Member, category: req.Params.Category,
		from: req.Params.From, to: req.Params.To}
	if req.Params.Kind != nil {
		k := string(*req.Params.Kind)
		if k != kindExpense && k != kindPayment {
			return nil, badRequest("invalid_kind")
		}
		f.kind = &k
	}
	where, args, err := f.where(g.id)
	if err != nil {
		return nil, err
	}
	n := len(args)
	args = append(args, afterAt, afterID, limit+1)
	// Payers and splits come from separate queries, which must see the
	// same version of each expense.
	var list []Expense
	err = s.snapshot(ctx, func(tx pgx.Tx) (err error) {
		list, err = loadExpenses(ctx, tx, g.digits, fmt.Sprintf(`
			select `+expenseColumns+` from expenses
			where %s
			  and ($%d::timestamptz is null or (occurred_at, id) < ($%d::timestamptz, $%d::uuid))
			order by occurred_at desc, id desc
			limit $%d`, where, n+1, n+1, n+2, n+3), args...)
		return err
	})
	if err != nil {
		return nil, err
	}
	page := ExpensePage{Items: list}
	if len(list) > limit {
		page.Items = list[:limit]
		c := encodeExpenseCursor(list[limit-1])
		page.NextCursor = &c
	}
	return ListExpenses200JSONResponse(page), nil
}

func (s *Server) CreateExpense(ctx context.Context, req CreateExpenseRequestObject) (CreateExpenseResponseObject, error) {
	var out Expense
	var g *group
	var who *string
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		g, err = s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		d, err := validateExpense(ctx, tx, g, kindExpense, *req.Body, nil, nil)
		if err != nil {
			return err
		}
		if err := checkGroupTotal(ctx, tx, g.id, d.amount, nil); err != nil {
			return err
		}
		who, err = actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		id, err := insertExpense(ctx, tx, g, who, d, d.payload(g.digits))
		if err != nil {
			return err
		}
		out, err = loadExpense(ctx, tx, g, id)
		return err
	})
	if err != nil {
		return nil, err
	}
	s.notifyExpense(g, who, "added", out)
	return CreateExpense201JSONResponse(out), nil
}

func (s *Server) CreatePayment(ctx context.Context, req CreatePaymentRequestObject) (CreatePaymentResponseObject, error) {
	in := req.Body
	occurred := time.Now()
	if in.OccurredAt != nil {
		occurred = *in.OccurredAt
	}
	var out Expense
	var g *group
	var who *string
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		g, err = s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		d, err := validateExpense(ctx, tx, g, kindPayment, ExpenseInput{
			Amount:      in.Amount,
			OccurredAt:  occurred,
			Payers:      []PayerInput{{MemberId: in.FromMemberId, Amount: in.Amount}},
			SplitMethod: SplitMethod(domain.SplitExact),
			Splits:      []Share{{MemberId: in.ToMemberId, Value: &in.Amount}},
		}, nil, nil)
		if err != nil {
			return err
		}
		if err := checkGroupTotal(ctx, tx, g.id, d.amount, nil); err != nil {
			return err
		}
		who, err = actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		payload := d.payload(g.digits)
		members, err := groupMembers(ctx, tx, g.id)
		if err != nil {
			return err
		}
		payload["from"] = findMember(members, in.FromMemberId).name
		payload["to"] = findMember(members, in.ToMemberId).name
		id, err := insertExpense(ctx, tx, g, who, d, payload)
		if err != nil {
			return err
		}
		out, err = loadExpense(ctx, tx, g, id)
		return err
	})
	if err != nil {
		return nil, err
	}
	s.notifyExpense(g, who, "added", out)
	return CreatePayment201JSONResponse(out), nil
}

func (s *Server) GetExpense(ctx context.Context, req GetExpenseRequestObject) (GetExpenseResponseObject, error) {
	var out Expense
	err := s.groupSnapshot(ctx, req.Token, func(tx pgx.Tx, g *group) (err error) {
		out, err = loadExpense(ctx, tx, g, req.ExpenseId)
		return err
	})
	if err != nil {
		return nil, err
	}
	return GetExpense200JSONResponse(out), nil
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

func (s *Server) UpdateExpense(ctx context.Context, req UpdateExpenseRequestObject) (UpdateExpenseResponseObject, error) {
	if req.Body.Version == nil {
		return nil, badRequest("version_required")
	}
	var out Expense
	var g *group
	var who *string
	var before map[string]bool
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		g, err = s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		kind, version, deleted, _, err := lockExpense(ctx, tx, g, req.ExpenseId)
		if err != nil {
			return err
		}
		if deleted {
			return errNotFound
		}
		if version != *req.Body.Version {
			return &apiError{status: 409, code: "expense_version_conflict", params: map[string]any{"version": version}}
		}
		before, err = expenseMembers(ctx, tx, req.ExpenseId)
		if err != nil {
			return err
		}
		d, err := validateExpense(ctx, tx, g, kind, *req.Body, before, nil)
		if err != nil {
			return err
		}
		if err := checkGroupTotal(ctx, tx, g.id, d.amount, &req.ExpenseId); err != nil {
			return err
		}
		who, err = actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		place, lat, lng := locationColumns(d.location)
		_, err = tx.Exec(ctx, `
			update expenses set title = $2, category_id = $3, amount = $4, split_method = $5,
				occurred_at = $6, note = $7, location_name = $8, latitude = $9, longitude = $10,
				updated_at = now(), version = version + 1
			where id = $1`, req.ExpenseId, d.title, d.category, d.amount, string(d.method), d.occurredAt, d.note,
			place, lat, lng)
		if err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `delete from expense_payers where expense_id = $1`, req.ExpenseId); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `delete from expense_splits where expense_id = $1`, req.ExpenseId); err != nil {
			return err
		}
		if err := insertParts(ctx, tx, req.ExpenseId, d); err != nil {
			return err
		}
		if err := logActivity(ctx, tx, g.id, who, "expense.updated", &req.ExpenseId, d.payload(g.digits)); err != nil {
			return err
		}
		out, err = loadExpense(ctx, tx, g, req.ExpenseId)
		return err
	})
	if err != nil {
		return nil, err
	}
	// Someone the edit took out of the expense sees their balance change too.
	earlier := make([]string, 0, len(before))
	for id := range before {
		earlier = append(earlier, id)
	}
	s.notifyExpense(g, who, "edited", out, earlier...)
	return UpdateExpense200JSONResponse(out), nil
}

// noneLeft fails with member_left when someone in the expense has left.
func noneLeft(ctx context.Context, q querier, id string) error {
	var left bool
	err := q.QueryRow(ctx, `
		select exists (
			select 1 from members m
			where m.left_at is not null and m.id in (
				select member_id from expense_payers where expense_id = $1
				union select member_id from expense_splits where expense_id = $1))`, id).Scan(&left)
	if err != nil {
		return err
	}
	if left {
		return &apiError{status: 409, code: "member_left"}
	}
	return nil
}

// setDeleted deletes or restores an expense. Doing it twice changes nothing.
func (s *Server) setDeleted(ctx context.Context, token, id string, header *string, del bool) (Expense, error) {
	var out Expense
	var g *group
	var who *string
	changed := false
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		g, err = s.groupByToken(ctx, tx, token, true)
		if err != nil {
			return err
		}
		_, _, deleted, _, err := lockExpense(ctx, tx, g, id)
		if err != nil {
			return err
		}
		if deleted != del {
			if !del {
				// Restoring would give back a balance to whoever left since.
				if err := noneLeft(ctx, tx, id); err != nil {
					return err
				}
				var amount int64
				if err := tx.QueryRow(ctx, `select amount from expenses where id = $1`, id).Scan(&amount); err != nil {
					return err
				}
				if err := checkGroupTotal(ctx, tx, g.id, amount, nil); err != nil {
					return err
				}
			}
			changed = true
			who, err = actor(ctx, tx, g, header)
			if err != nil {
				return err
			}
			_, err = tx.Exec(ctx, `
				update expenses set deleted_at = case when $2 then now() end, version = version + 1
				where id = $1`, id, del)
			if err != nil {
				return err
			}
			e, err := loadExpense(ctx, tx, g, id)
			if err != nil {
				return err
			}
			action := "expense.restored"
			if del {
				action = "expense.deleted"
			}
			payload := map[string]any{"title": e.Title, "amount": e.Amount, "kind": string(e.Kind)}
			if err := logActivity(ctx, tx, g.id, who, action, &id, payload); err != nil {
				return err
			}
		}
		out, err = loadExpense(ctx, tx, g, id)
		return err
	})
	if err == nil && changed && del {
		s.notifyExpense(g, who, "deleted", out)
	}
	return out, err
}

func (s *Server) DeleteExpense(ctx context.Context, req DeleteExpenseRequestObject) (DeleteExpenseResponseObject, error) {
	if _, err := s.setDeleted(ctx, req.Token, req.ExpenseId, req.Params.XBalnanaMember, true); err != nil {
		return nil, err
	}
	return DeleteExpense204Response{}, nil
}

func (s *Server) RestoreExpense(ctx context.Context, req RestoreExpenseRequestObject) (RestoreExpenseResponseObject, error) {
	out, err := s.setDeleted(ctx, req.Token, req.ExpenseId, req.Params.XBalnanaMember, false)
	if err != nil {
		return nil, err
	}
	return RestoreExpense200JSONResponse(out), nil
}
