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

// readerZone is the time zone the reader counts dates in: the named IANA zone,
// which knows when daylight saving time began and ended, or else one fixed
// offset in minutes east of UTC, which older apps send.
func readerZone(utcOffset *int, timeZone *string) (*time.Location, error) {
	if timeZone != nil && *timeZone != "" {
		loc, err := time.LoadLocation(*timeZone)
		if err != nil || *timeZone == "Local" || len(*timeZone) > 64 {
			return nil, badRequest("invalid_time_zone")
		}
		return loc, nil
	}
	offset := 0
	if utcOffset != nil {
		offset = *utcOffset
	}
	if offset < -840 || offset > 840 {
		return nil, badRequest("invalid_offset")
	}
	return time.FixedZone("", offset*60), nil
}

func (s *Server) GetStats(ctx context.Context, req GetStatsRequestObject) (GetStatsResponseObject, error) {
	zone, err := readerZone(req.Params.UtcOffset, req.Params.TimeZone)
	if err != nil {
		return nil, err
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

	where += " and transaction_type <> 'income'"
	const netAmount = "case when transaction_type = 'refund' then -amount else amount end"
	out := GroupStats{Categories: []CategoryStats{}, Members: []MemberStats{}, Months: []MonthStats{}}
	err = pgx.BeginTxFunc(ctx, s.db, pgx.TxOptions{IsoLevel: pgx.RepeatableRead, AccessMode: pgx.ReadOnly},
		func(tx pgx.Tx) error {
			var total int64
			err := tx.QueryRow(ctx, `select coalesce(sum(`+netAmount+`), 0)::bigint, count(*) from expenses where `+where, args...).
				Scan(&total, &out.Count)
			if err != nil {
				return err
			}
			out.Total = domain.FormatAmount(total, g.digits)

			rows, err := tx.Query(ctx, `
				select category_id, sum(`+netAmount+`)::bigint as total, count(*) from expenses where `+where+`
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
				with e as (select id, transaction_type from expenses where `+where+`),
				parts as (
					select p.member_id, p.amount,
						case when e.transaction_type = 'refund' then 'share' else 'paid' end as side,
						case when e.transaction_type = 'refund' then -1 else 1 end as sign
					from expense_payers p join e on e.id = p.expense_id
					union all
					select p.member_id, p.amount,
						case when e.transaction_type = 'refund' then 'paid' else 'share' end,
						case when e.transaction_type = 'refund' then -1 else 1 end
					from expense_splits p join e on e.id = p.expense_id),
				paid as (select member_id, sum(amount * sign) as amount from parts
					where side = 'paid' group by member_id),
				share as (select member_id, sum(amount * sign) as amount from parts
					where side = 'share' group by member_id)
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

			// Each expense falls in the month it was in where the reader is,
			// under the offset in force when it happened.
			n := len(args) + 1
			local, arg := fmt.Sprintf("occurred_at at time zone $%d", n), any(zone.String())
			if zone.String() == "" { // a fixed offset
				_, offset := time.Now().In(zone).Zone()
				local, arg = fmt.Sprintf("(occurred_at at time zone 'UTC') + make_interval(secs => $%d)", n), offset
			}
			rows, err = tx.Query(ctx, fmt.Sprintf(`
				select to_char(%s, 'YYYY-MM') as month, sum(%s)::bigint
				from expenses where %s
				group by month order by month`, local, netAmount, where), append(args, arg)...)
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
