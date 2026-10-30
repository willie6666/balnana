package api

import (
	"context"
	"errors"
	"regexp"
	"slices"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

const (
	// maxAdminPayments is how many payments one listing shows.
	maxAdminPayments = 200
	maxPlanLimit     = 100_000_000
	maxPlanDays      = 36_500
)

var planID = regexp.MustCompile(`^[a-z0-9][a-z0-9-]{0,31}$`)

var errInvalidPlan = badRequest("invalid_plan")

func planCatalog(ctx context.Context, q querier) (PlanCatalog, error) {
	rows, err := q.Query(ctx, `
		select id, name, rank, is_default, receipts_per_group, recurring_per_group, own_groups, sponsored_groups
		from plans order by rank, id`)
	if err != nil {
		return PlanCatalog{}, err
	}
	plans, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (Plan, error) {
		var p Plan
		err := row.Scan(&p.Id, &p.Name, &p.Rank, &p.IsDefault, &p.Limits.ReceiptsPerGroup, &p.Limits.RecurringPerGroup,
			&p.Limits.OwnGroups, &p.Limits.SponsoredGroups)
		return p, err
	})
	if err != nil {
		return PlanCatalog{}, err
	}
	rows, err = q.Query(ctx, `
		select provider, product, plan_id, days, min_amount::text, currency
		from plan_products order by provider, product, min_amount`)
	if err != nil {
		return PlanCatalog{}, err
	}
	products, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (PlanProduct, error) {
		var p PlanProduct
		err := row.Scan(&p.Provider, &p.Product, &p.PlanId, &p.Days, &p.MinAmount, &p.Currency)
		return p, err
	})
	if err != nil {
		return PlanCatalog{}, err
	}
	return PlanCatalog{Plans: plans, Products: products}, nil
}

func (s *Server) GetAdminPlans(ctx context.Context, req GetAdminPlansRequestObject) (GetAdminPlansResponseObject, error) {
	if err := s.requireAdmin(ctx, req.Params.XBalnanaAdmin); err != nil {
		return nil, err
	}
	out, err := planCatalog(ctx, s.db)
	if err != nil {
		return nil, err
	}
	return GetAdminPlans200JSONResponse(out), nil
}

func validLimit(n *int) bool { return n == nil || *n >= 0 && *n <= maxPlanLimit }

// validateCatalog checks c, and tidies what people type.
func validateCatalog(c *PlanCatalog) error {
	defaults := 0
	ids := make([]string, 0, len(c.Plans))
	for i := range c.Plans {
		p := &c.Plans[i]
		p.Name = strings.TrimSpace(p.Name)
		if !planID.MatchString(p.Id) || p.Name == "" || utf8.RuneCountInString(p.Name) > maxNameLen || slices.Contains(ids, p.Id) ||
			!validLimit(p.Limits.ReceiptsPerGroup) || !validLimit(p.Limits.RecurringPerGroup) ||
			!validLimit(p.Limits.OwnGroups) || !validLimit(p.Limits.SponsoredGroups) {
			return errInvalidPlan
		}
		if p.IsDefault {
			defaults++
		}
		ids = append(ids, p.Id)
	}
	if defaults != 1 {
		return errInvalidPlan
	}
	for i := range c.Products {
		p := &c.Products[i]
		p.Product = strings.TrimSpace(p.Product)
		if !slices.Contains(ids, p.PlanId) || p.Days < 1 || p.Days > maxPlanDays ||
			p.Provider != Kofi && p.Provider != Play {
			return errInvalidPlan
		}
		if p.MinAmount != nil && !decimalAmount.MatchString(*p.MinAmount) || p.Currency != nil && !currencyCode.MatchString(*p.Currency) {
			return errInvalidPlan
		}
		// Without a name, the amount is all there is to go by.
		if p.Product == "" && (p.Provider != Kofi || p.MinAmount == nil || p.Currency == nil) {
			return errInvalidPlan
		}
	}
	return nil
}

func (s *Server) UpdateAdminPlans(ctx context.Context, req UpdateAdminPlansRequestObject) (UpdateAdminPlansResponseObject, error) {
	if err := s.requireAdmin(ctx, req.Params.XBalnanaAdmin); err != nil {
		return nil, err
	}
	c := *req.Body
	if err := validateCatalog(&c); err != nil {
		return nil, err
	}
	var out PlanCatalog
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		// One at a time, and the old default out of the new one's way.
		if _, err := tx.Exec(ctx, `lock table plans in share row exclusive mode`); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `delete from plan_products`); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `update plans set is_default = false where is_default`); err != nil {
			return err
		}
		ids := make([]string, len(c.Plans))
		for i, p := range c.Plans {
			ids[i] = p.Id
			_, err := tx.Exec(ctx, `
				insert into plans (id, name, rank, is_default, receipts_per_group, recurring_per_group, own_groups, sponsored_groups)
				values ($1, $2, $3, $4, $5, $6, $7, $8)
				on conflict (id) do update set name = excluded.name, rank = excluded.rank, is_default = excluded.is_default,
					receipts_per_group = excluded.receipts_per_group, recurring_per_group = excluded.recurring_per_group,
					own_groups = excluded.own_groups, sponsored_groups = excluded.sponsored_groups`,
				p.Id, p.Name, p.Rank, p.IsDefault, p.Limits.ReceiptsPerGroup, p.Limits.RecurringPerGroup,
				p.Limits.OwnGroups, p.Limits.SponsoredGroups)
			if err != nil {
				return err
			}
		}
		for _, p := range c.Products {
			_, err := tx.Exec(ctx, `
				insert into plan_products (provider, product, plan_id, days, min_amount, currency)
				values ($1, $2, $3, $4, $5::numeric, $6)`, string(p.Provider), p.Product, p.PlanId, p.Days, p.MinAmount, p.Currency)
			// The index knows the same product however its amount is written.
			if pgErr := (*pgconn.PgError)(nil); errors.As(err, &pgErr) && pgErr.Code == "23505" {
				return errInvalidPlan
			}
			if err != nil {
				return err
			}
		}
		_, err := tx.Exec(ctx, `delete from plans where not (id = any($1))`, ids)
		if pgErr := (*pgconn.PgError)(nil); errors.As(err, &pgErr) && pgErr.Code == "23503" {
			return conflict("plan_in_use")
		}
		if err != nil {
			return err
		}
		// A payment waiting for a plan that is gone needs an administrator now.
		_, err = tx.Exec(ctx, `update payment_events set state = 'unmatched' where state = 'unclaimed' and plan_id is null`)
		if err != nil {
			return err
		}
		out, err = planCatalog(ctx, tx)
		return err
	})
	if err != nil {
		return nil, err
	}
	s.log.Info("plans changed by the administrator")
	return UpdateAdminPlans200JSONResponse(out), nil
}

func (s *Server) ListAdminEntitlements(ctx context.Context, req ListAdminEntitlementsRequestObject) (ListAdminEntitlementsResponseObject, error) {
	if err := s.requireAdmin(ctx, req.Params.XBalnanaAdmin); err != nil {
		return nil, err
	}
	if !validUUID(req.UserId) {
		return nil, errNotFound
	}
	rows, err := s.db.Query(ctx, entitlementSelect+` where e.user_id = $1 order by e.created_at desc`, req.UserId)
	if err != nil {
		return nil, err
	}
	list, err := pgx.CollectRows(rows, scanEntitlement)
	if err != nil {
		return nil, err
	}
	return ListAdminEntitlements200JSONResponse(EntitlementList{Entitlements: list}), nil
}

const entitlementSelect = `
	select e.id::text, e.plan_id, p.name, e.source, e.note, e.starts_at, e.expires_at, e.revoked_at, e.created_at
	from entitlements e join plans p on p.id = e.plan_id`

func scanEntitlement(row pgx.CollectableRow) (Entitlement, error) {
	var e Entitlement
	err := row.Scan(&e.Id, &e.PlanId, &e.PlanName, &e.Source, &e.Note, &e.StartsAt, &e.ExpiresAt, &e.RevokedAt, &e.CreatedAt)
	return e, err
}

func (s *Server) GrantAdminEntitlement(ctx context.Context, req GrantAdminEntitlementRequestObject) (GrantAdminEntitlementResponseObject, error) {
	if err := s.requireAdmin(ctx, req.Params.XBalnanaAdmin); err != nil {
		return nil, err
	}
	if !validUUID(req.UserId) {
		return nil, errNotFound
	}
	note := cleanNote(req.Body.Note)
	if note != nil && utf8.RuneCountInString(*note) > maxNoteLen {
		return nil, badRequest("invalid_note")
	}
	var expires *time.Time
	if d := req.Body.Days; d != nil {
		if *d < 1 || *d > maxPlanDays {
			return nil, errInvalidPlan
		}
		t := time.Now().AddDate(0, 0, *d)
		expires = &t
	}
	var id string
	err := s.db.QueryRow(ctx, `
		insert into entitlements (user_id, plan_id, source, note, expires_at)
		select u.id, p.id, 'admin', $3, $4 from users u, plans p where u.id = $1 and p.id = $2
		returning id::text`, req.UserId, req.Body.PlanId, note, expires).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, errNotFound
	}
	if err != nil {
		return nil, err
	}
	rows, err := s.db.Query(ctx, entitlementSelect+` where e.id = $1`, id)
	if err != nil {
		return nil, err
	}
	e, err := pgx.CollectExactlyOneRow(rows, scanEntitlement)
	if err != nil {
		return nil, err
	}
	s.log.Info("plan granted by the administrator", "user", req.UserId, "plan", req.Body.PlanId)
	return GrantAdminEntitlement201JSONResponse(e), nil
}

func (s *Server) RevokeAdminEntitlement(ctx context.Context, req RevokeAdminEntitlementRequestObject) (RevokeAdminEntitlementResponseObject, error) {
	if err := s.requireAdmin(ctx, req.Params.XBalnanaAdmin); err != nil {
		return nil, err
	}
	if !validUUID(req.EntitlementId) {
		return nil, errNotFound
	}
	tag, err := s.db.Exec(ctx, `update entitlements set revoked_at = coalesce(revoked_at, now()) where id = $1`, req.EntitlementId)
	if err != nil {
		return nil, err
	}
	if tag.RowsAffected() == 0 {
		return nil, errNotFound
	}
	s.log.Info("entitlement revoked by the administrator", "entitlement", req.EntitlementId)
	return RevokeAdminEntitlement204Response{}, nil
}

const paymentSelect = `
	select pe.id::text, pe.provider, pe.kind, pe.state, pe.email::text, pe.payer_name, pe.amount::text, pe.currency,
	       pe.product, pe.plan_id, pe.days, pe.user_id::text, u.display_name, pe.paid_at, pe.reference
	from payment_events pe left join users u on u.id = pe.user_id`

func scanPayment(row pgx.CollectableRow) (Payment, error) {
	var p Payment
	err := row.Scan(&p.Id, &p.Provider, &p.Kind, &p.State, &p.Email, &p.PayerName, &p.Amount, &p.Currency,
		&p.Product, &p.PlanId, &p.Days, &p.UserId, &p.UserName, &p.PaidAt, &p.Reference)
	return p, err
}

func (s *Server) ListAdminPayments(ctx context.Context, req ListAdminPaymentsRequestObject) (ListAdminPaymentsResponseObject, error) {
	if err := s.requireAdmin(ctx, req.Params.XBalnanaAdmin); err != nil {
		return nil, err
	}
	state := ""
	if req.Params.State != nil {
		state = string(*req.Params.State)
	}
	const match = `($1 = '' or pe.state = $1)`
	out := PaymentList{}
	if err := s.db.QueryRow(ctx, `select count(*) from payment_events pe where `+match, state).Scan(&out.Total); err != nil {
		return nil, err
	}
	rows, err := s.db.Query(ctx, paymentSelect+` where `+match+` order by pe.created_at desc limit $2`, state, maxAdminPayments)
	if err != nil {
		return nil, err
	}
	if out.Payments, err = pgx.CollectRows(rows, scanPayment); err != nil {
		return nil, err
	}
	return ListAdminPayments200JSONResponse(out), nil
}

func (s *Server) AssignAdminPayment(ctx context.Context, req AssignAdminPaymentRequestObject) (AssignAdminPaymentResponseObject, error) {
	if err := s.requireAdmin(ctx, req.Params.XBalnanaAdmin); err != nil {
		return nil, err
	}
	if !validUUID(req.PaymentId) || !validUUID(req.Body.UserId) {
		return nil, errNotFound
	}
	if d := req.Body.Days; d != nil && (*d < 1 || *d > maxPlanDays) {
		return nil, errInvalidPlan
	}
	var out Payment
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if err := holdAccount(ctx, tx, req.Body.UserId); err != nil {
			return err
		}
		var state string
		var email, plan *string
		var days *int
		var recurring bool
		err := tx.QueryRow(ctx, `select state, email::text, plan_id, days, recurring from payment_events where id = $1 for update`,
			req.PaymentId).Scan(&state, &email, &plan, &days, &recurring)
		if errors.Is(err, pgx.ErrNoRows) {
			return errNotFound
		}
		if err != nil {
			return err
		}
		if state == "applied" {
			return conflict("payment_applied")
		}
		if req.Body.PlanId != nil {
			plan = req.Body.PlanId
		}
		if req.Body.Days != nil {
			days = req.Body.Days
		}
		if plan == nil || days == nil {
			return errInvalidPlan
		}
		var known bool
		err = tx.QueryRow(ctx, `select exists (select 1 from users where id = $1) and exists (select 1 from plans where id = $2)`,
			req.Body.UserId, *plan).Scan(&known)
		if err != nil {
			return err
		}
		if !known {
			return errNotFound
		}
		_, err = tx.Exec(ctx, `update payment_events set plan_id = $1, days = $2 where id = $3`, *plan, *days, req.PaymentId)
		if err != nil {
			return err
		}
		if err := applyPayment(ctx, tx, req.PaymentId, req.Body.UserId, true); err != nil {
			return err
		}
		if recurring && email != nil {
			if err := rememberPaymentEmail(ctx, tx, *email, req.Body.UserId); err != nil {
				return err
			}
			if err := claimPayments(ctx, tx, req.Body.UserId); err != nil {
				return err
			}
		}
		rows, err := tx.Query(ctx, paymentSelect+` where pe.id = $1`, req.PaymentId)
		if err != nil {
			return err
		}
		out, err = pgx.CollectExactlyOneRow(rows, scanPayment)
		return err
	})
	if err != nil {
		return nil, err
	}
	s.log.Info("payment assigned by the administrator", "payment", req.PaymentId, "user", req.Body.UserId)
	return AssignAdminPayment200JSONResponse(out), nil
}
