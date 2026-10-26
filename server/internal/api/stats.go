package api

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"

	"balnana/internal/domain"
)

// expenseFilter narrows the expenses of a group. Unset fields match everything.
type expenseFilter struct {
	q        *string
	member   *string
	category *string
	kind     *string
	from, to *time.Time
}

// likeEscaper makes user text literal inside a LIKE pattern.
var likeEscaper = strings.NewReplacer(`\`, `\\`, `%`, `\%`, `_`, `\_`)

// where returns the SQL condition on the expenses table and its arguments,
// numbered from $1, which is the group ID.
func (f expenseFilter) where(groupID string) (string, []any, error) {
	conds := []string{"group_id = $1", "deleted_at is null"}
	args := []any{groupID}
	arg := func(v any) string {
		args = append(args, v)
		return fmt.Sprintf("$%d", len(args))
	}
	if f.q != nil {
		if q := strings.TrimSpace(*f.q); q != "" {
			p := arg("%" + likeEscaper.Replace(q) + "%")
			conds = append(conds, fmt.Sprintf("(title ilike %s or coalesce(note, '') ilike %s)", p, p))
		}
	}
	if f.member != nil && *f.member != "" {
		if !validUUID(*f.member) {
			return "", nil, badRequest("invalid_member")
		}
		p := arg(*f.member)
		conds = append(conds, fmt.Sprintf(`(exists (select 1 from expense_payers x where x.expense_id = expenses.id and x.member_id = %s)
			or exists (select 1 from expense_splits x where x.expense_id = expenses.id and x.member_id = %s))`, p, p))
	}
	if f.category != nil && *f.category != "" {
		conds = append(conds, "category_id = "+arg(*f.category))
	}
	if f.kind != nil {
		conds = append(conds, "kind = "+arg(*f.kind)+"::expense_kind")
	}
	if f.from != nil {
		conds = append(conds, "occurred_at >= "+arg(*f.from))
	}
	if f.to != nil {
		conds = append(conds, "occurred_at < "+arg(*f.to))
	}
	return strings.Join(conds, " and "), args, nil
}

func (s *Server) GetStats(ctx context.Context, req GetStatsRequestObject) (GetStatsResponseObject, error) {
	offset := 0
	if req.Params.UtcOffset != nil {
		offset = *req.Params.UtcOffset
	}
	if offset < -840 || offset > 840 {
		return nil, badRequest("invalid_offset")
	}
	g, err := s.groupByToken(ctx, s.db, req.Token, false)
	if err != nil {
		return nil, err
	}
	kind := kindExpense
	where, args, err := expenseFilter{kind: &kind, from: req.Params.From, to: req.Params.To}.where(g.id)
	if err != nil {
		return nil, err
	}

	out := GroupStats{Categories: []CategoryStats{}, Members: []MemberStats{}, Months: []MonthStats{}}
	err = pgx.BeginTxFunc(ctx, s.db, pgx.TxOptions{IsoLevel: pgx.RepeatableRead, AccessMode: pgx.ReadOnly},
		func(tx pgx.Tx) error {
			var total int64
			err := tx.QueryRow(ctx, `select coalesce(sum(amount), 0)::bigint, count(*) from expenses where `+where, args...).
				Scan(&total, &out.Count)
			if err != nil {
				return err
			}
			out.Total = domain.FormatAmount(total, g.digits)

			rows, err := tx.Query(ctx, `
				select category_id, sum(amount)::bigint as total, count(*) from expenses where `+where+`
				group by category_id order by total desc, category_id nulls last`, args...)
			if err != nil {
				return err
			}
			out.Categories, err = pgx.CollectRows(rows, func(row pgx.CollectableRow) (CategoryStats, error) {
				var c CategoryStats
				var amount int64
				err := row.Scan(&c.CategoryId, &amount, &c.Count)
				c.Amount = domain.FormatAmount(amount, g.digits)
				return c, err
			})
			if err != nil {
				return err
			}

			rows, err = tx.Query(ctx, `
				with e as (select id from expenses where `+where+`),
				paid as (select member_id, sum(amount) as amount from expense_payers
					where expense_id in (select id from e) group by member_id),
				share as (select member_id, sum(amount) as amount from expense_splits
					where expense_id in (select id from e) group by member_id)
				select m.id::text, coalesce(paid.amount, 0)::bigint, coalesce(share.amount, 0)::bigint
				from members m
				left join paid on paid.member_id = m.id
				left join share on share.member_id = m.id
				where m.group_id = $1 and (paid.amount is not null or share.amount is not null)
				order by m.created_at, m.id`, args...)
			if err != nil {
				return err
			}
			out.Members, err = pgx.CollectRows(rows, func(row pgx.CollectableRow) (MemberStats, error) {
				var m MemberStats
				var paid, share int64
				err := row.Scan(&m.MemberId, &paid, &share)
				m.Paid = domain.FormatAmount(paid, g.digits)
				m.Share = domain.FormatAmount(share, g.digits)
				return m, err
			})
			if err != nil {
				return err
			}

			n := len(args) + 1
			rows, err = tx.Query(ctx, fmt.Sprintf(`
				select to_char((occurred_at at time zone 'UTC') + make_interval(mins => $%d), 'YYYY-MM') as month,
					sum(amount)::bigint
				from expenses where %s
				group by month order by month`, n, where), append(args, offset)...)
			if err != nil {
				return err
			}
			out.Months, err = pgx.CollectRows(rows, func(row pgx.CollectableRow) (MonthStats, error) {
				var m MonthStats
				var amount int64
				err := row.Scan(&m.Month, &amount)
				m.Amount = domain.FormatAmount(amount, g.digits)
				return m, err
			})
			return err
		})
	if err != nil {
		return nil, err
	}
	return GetStats200JSONResponse(out), nil
}
