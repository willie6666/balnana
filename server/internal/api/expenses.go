package api

import (
	"context"
	"encoding/base64"
	"errors"
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
	kind       string
	title      string
	category   *string
	amount     int64
	occurredAt time.Time
	note       *string
	method     domain.SplitMethod
	payers     map[string]int64
	splits     map[string]int64
	shares     map[string]string // entered percentage or weight, 4 decimals
}

// validateExpense checks an expense against the group: every member must
// belong to it, payers must add up to the amount and the split must work.
func validateExpense(ctx context.Context, q querier, g *group, kind string, in ExpenseInput) (*expenseData, error) {
	d := &expenseData{kind: kind, occurredAt: in.OccurredAt, method: domain.SplitMethod(in.SplitMethod)}

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
	if in.OccurredAt.IsZero() {
		return nil, badRequest("invalid_date")
	}

	if in.CategoryId != nil && *in.CategoryId != "" {
		var exists bool
		if err := q.QueryRow(ctx, `select exists (select 1 from categories where id = $1)`, *in.CategoryId).Scan(&exists); err != nil {
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

	members, err := groupMembers(ctx, q, g.id)
	if err != nil {
		return nil, err
	}
	known := func(id string) error {
		if findMember(members, id) == nil {
			return badRequest("unknown_member")
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
		if d.method == domain.SplitPercent || d.method == domain.SplitShares {
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
	err := tx.QueryRow(ctx, `
		insert into expenses (group_id, kind, title, category_id, amount, currency, split_method, occurred_at, note, created_by_member)
		values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) returning id::text`,
		g.id, d.kind, d.title, d.category, d.amount, g.currency, string(d.method), d.occurredAt, d.note, who).Scan(&id)
	if err != nil {
		return "", err
	}
	return id, insertParts(ctx, tx, id, d)
}

const expenseColumns = `id::text, kind::text, title, category_id, amount, occurred_at, note, split_method::text,
	created_by_member::text, created_at, updated_at, deleted_at, version`

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
		err := row.Scan(&e.Id, &kind, &e.Title, &e.CategoryId, &amount, &e.OccurredAt, &e.Note, &method,
			&e.CreatedBy, &e.CreatedAt, &e.UpdatedAt, &e.DeletedAt, &e.Version)
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
	list, err := loadExpenses(ctx, s.db, g.digits, `
		select `+expenseColumns+` from expenses
		where group_id = $1 and deleted_at is null
		  and ($2::timestamptz is null or (occurred_at, id) < ($2::timestamptz, $3::uuid))
		order by occurred_at desc, id desc
		limit $4`, g.id, afterAt, afterID, limit+1)
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
		d, err := validateExpense(ctx, tx, g, kindExpense, *req.Body)
		if err != nil {
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
		})
		if err != nil {
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
	g, err := s.groupByToken(ctx, s.db, req.Token, false)
	if err != nil {
		return nil, err
	}
	out, err := loadExpense(ctx, s.db, g, req.ExpenseId)
	if err != nil {
		return nil, err
	}
	return GetExpense200JSONResponse(out), nil
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
		d, err := validateExpense(ctx, tx, g, kind, *req.Body)
		if err != nil {
			return err
		}
		who, err = actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		_, err = tx.Exec(ctx, `
			update expenses set title = $2, category_id = $3, amount = $4, split_method = $5,
				occurred_at = $6, note = $7, updated_at = now(), version = version + 1
			where id = $1`, req.ExpenseId, d.title, d.category, d.amount, string(d.method), d.occurredAt, d.note)
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
	s.notifyExpense(g, who, "edited", out)
	return UpdateExpense200JSONResponse(out), nil
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
