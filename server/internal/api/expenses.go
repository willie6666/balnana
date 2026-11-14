package api

import (
	"context"
	"encoding/base64"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"

	"balnana/internal/domain"
)

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
	expense, err := s.createExpense(ctx, req.Token, kindExpense, *req.Body, req.Params.IdempotencyKey, req.Params.XBalnanaMember)
	if err != nil {
		return nil, err
	}
	return CreateExpense201JSONResponse(expense), nil
}

func (s *Server) CreatePayment(ctx context.Context, req CreatePaymentRequestObject) (CreatePaymentResponseObject, error) {
	in := req.Body
	occurred := time.Now()
	if in.OccurredAt != nil {
		occurred = *in.OccurredAt
	}
	payment, err := s.createExpense(ctx, req.Token, kindPayment, ExpenseInput{
		Amount:      in.Amount,
		OccurredAt:  occurred,
		Payers:      []PayerInput{{MemberId: in.FromMemberId, Amount: in.Amount}},
		SplitMethod: SplitMethod(domain.SplitExact),
		Splits:      []Share{{MemberId: in.ToMemberId, Value: &in.Amount}},
	}, req.Params.IdempotencyKey, req.Params.XBalnanaMember)
	if err != nil {
		return nil, err
	}
	return CreatePayment201JSONResponse(payment), nil
}

func (s *Server) createExpense(ctx context.Context, token, kind string, in ExpenseInput, key *IdempotencyKey, memberHeader *string) (Expense, error) {
	var out Expense
	var g *group
	var who *string
	var created bool
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		g, err = s.groupByToken(ctx, tx, token, true)
		if err != nil {
			return err
		}
		id, err := sentBefore(ctx, tx, "expenses", g.id, key)
		if err != nil {
			return err
		}
		if id != "" {
			out, err = loadExpense(ctx, tx, g, id)
			return err
		}
		members, err := groupMembers(ctx, tx, g.id)
		if err != nil {
			return err
		}
		d, err := validateExpense(ctx, tx, g, kind, in, members)
		if err != nil {
			return err
		}
		if err := checkFeatures(g, d, nil, false); err != nil {
			return err
		}
		if err := checkGroupTotal(ctx, tx, g.id, d.amount, nil); err != nil {
			return err
		}
		who, err = actor(ctx, tx, g, memberHeader)
		if err != nil {
			return err
		}
		payload := d.payload(g.digits)
		if kind == kindPayment {
			payload["from"] = findMember(members, in.Payers[0].MemberId).name
			payload["to"] = findMember(members, in.Splits[0].MemberId).name
		}
		d.clientKey = key
		id, err = insertExpense(ctx, tx, g, who, d, payload)
		if err != nil {
			return err
		}
		out, err = loadExpense(ctx, tx, g, id)
		created = true
		return err
	})
	if err != nil {
		return Expense{}, err
	}
	if created {
		s.notifyExpense(g, who, "added", out)
	}
	return out, nil
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
		d, err := validateExpense(ctx, tx, g, kind, *req.Body, nil)
		if err != nil {
			return err
		}
		if !g.features.ForeignCurrency || !g.features.Places {
			was, err := loadExpense(ctx, tx, g, req.ExpenseId)
			if err != nil {
				return err
			}
			if err := checkFeatures(g, d, was.Location, was.Foreign != nil); err != nil {
				return err
			}
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
				foreign_currency = $11, foreign_digits = $12, foreign_amount = $13,
				updated_at = now(), version = version + 1
			where id = $1`, append([]any{req.ExpenseId, d.title, d.category, d.amount, string(d.method), d.occurredAt, d.note,
			place, lat, lng}, foreignColumns(d.foreign)...)...)
		if err != nil {
			return err
		}
		if err := expenseParts.replace(ctx, tx, req.ExpenseId, d); err != nil {
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
