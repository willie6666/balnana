package api

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
)

// entitlementActive picks the entitlements (as e) in force now.
const entitlementActive = `e.revoked_at is null and e.starts_at <= now() and (e.expires_at is null or e.expires_at > now())`

// plan is what someone may use. A nil limit is no limit.
type plan struct {
	name      string
	isDefault bool
	receipts  *int
	recurring *int
	ownGroups *int
	sponsored *int
}

// userPlan is the plan userID has now: its best entitlement, or the default
// one. Its second result is when that plan ends, if it does.
func userPlan(ctx context.Context, q querier, userID string) (*plan, *time.Time, error) {
	var p plan
	var ends *time.Time
	err := q.QueryRow(ctx, `
		select p.name, p.is_default, p.receipts_per_group, p.recurring_per_group, p.own_groups, p.sponsored_groups,
		       e.expires_at
		from plans p
		left join entitlements e on e.plan_id = p.id and e.user_id = $1 and `+entitlementActive+`
		where p.is_default or e.id is not null
		order by e.id is not null desc, p.rank desc, e.expires_at desc nulls first
		limit 1`, userID).
		Scan(&p.name, &p.isDefault, &p.receipts, &p.recurring, &p.ownGroups, &p.sponsored, &ends)
	if err != nil {
		return nil, nil, err
	}
	return &p, ends, nil
}

// groupSponsor finds who sponsors the group: their account and member, while
// they are still in it.
func groupSponsor(ctx context.Context, q querier, g *group) (userID, memberID *string, err error) {
	err = q.QueryRow(ctx, `
		select m.user_id::text, m.id::text from groups g
		join members m on m.group_id = g.id and m.user_id = g.sponsor_user_id and m.left_at is null
		where g.id = $1`, g.id).Scan(&userID, &memberID)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil, nil
	}
	return userID, memberID, err
}

// groupPlan is the plan that applies to the whole group: its sponsor's, or
// the default one.
func groupPlan(ctx context.Context, q querier, g *group) (*plan, *string, error) {
	userID, memberID, err := groupSponsor(ctx, q, g)
	if err != nil {
		return nil, nil, err
	}
	// No account has the empty id, so this finds the default plan.
	id := nilUUID
	if userID != nil {
		id = *userID
	}
	p, _, err := userPlan(ctx, q, id)
	return p, memberID, err
}

const nilUUID = "00000000-0000-0000-0000-000000000000"

// planLimit is the refusal to add past a limit. What exists stays as it is:
// only adding stops.
func planLimit(limit string, max int) error {
	return &apiError{status: http.StatusPaymentRequired, code: "plan_limit", params: map[string]any{"limit": limit, "max": max}}
}

func countReceipts(ctx context.Context, q querier, groupID string) (n int, err error) {
	err = q.QueryRow(ctx, `
		select count(*) from receipts r join expenses e on e.id = r.expense_id
		where e.group_id = $1`, groupID).Scan(&n)
	return n, err
}

// countRecurring counts the paused and the ended too: either could carry on.
func countRecurring(ctx context.Context, q querier, groupID string) (n int, err error) {
	err = q.QueryRow(ctx, `select count(*) from recurring_expenses where group_id = $1`, groupID).Scan(&n)
	return n, err
}

func countOwnGroups(ctx context.Context, q querier, userID string) (n int, err error) {
	err = q.QueryRow(ctx, `
		select count(*) from members m join groups g on g.id = m.group_id
		where m.user_id = $1 and m.is_owner and m.left_at is null and g.archived_at is null`, userID).Scan(&n)
	return n, err
}

func countSponsored(ctx context.Context, q querier, userID string) (n int, err error) {
	err = q.QueryRow(ctx, `
		select count(*) from groups g
		join members m on m.group_id = g.id and m.user_id = g.sponsor_user_id and m.left_at is null
		where g.sponsor_user_id = $1 and g.archived_at is null`, userID).Scan(&n)
	return n, err
}

// checkReceiptLimit refuses a photo the group has no room for. One replacing
// the expense's photo adds nothing. In a write it needs the group locked.
func (s *Server) checkReceiptLimit(ctx context.Context, q querier, g *group, expenseID string) error {
	var replaces bool
	if err := q.QueryRow(ctx, `select exists (select 1 from receipts where expense_id = $1)`, expenseID).Scan(&replaces); err != nil || replaces {
		return err
	}
	if !s.conf().Billing {
		return nil
	}
	p, _, err := groupPlan(ctx, q, g)
	if err != nil || p.receipts == nil {
		return err
	}
	n, err := countReceipts(ctx, q, g.id)
	if err != nil {
		return err
	}
	if n >= *p.receipts {
		return planLimit("receipts", *p.receipts)
	}
	return nil
}

// checkRecurringLimit refuses a repeating expense the group has no room for.
// It needs the group locked.
func (s *Server) checkRecurringLimit(ctx context.Context, q querier, g *group) error {
	if !s.conf().Billing {
		return nil
	}
	p, _, err := groupPlan(ctx, q, g)
	if err != nil || p.recurring == nil {
		return err
	}
	n, err := countRecurring(ctx, q, g.id)
	if err != nil {
		return err
	}
	if n >= *p.recurring {
		return planLimit("recurring", *p.recurring)
	}
	return nil
}

// holdAccount holds the account's row until the transaction ends, so that
// counting what it has and adding to it happen one at a time.
func holdAccount(ctx context.Context, tx pgx.Tx, userID string) error {
	if err := lockUsersTable(ctx, tx); err != nil {
		return err
	}
	_, err := tx.Exec(ctx, `select 1 from users where id = $1 for no key update`, userID)
	return err
}

// checkOwnGroups refuses a new group to an account that owns all it may.
func (s *Server) checkOwnGroups(ctx context.Context, tx pgx.Tx, userID string) error {
	if !s.conf().Billing {
		return nil
	}
	if err := holdAccount(ctx, tx, userID); err != nil {
		return err
	}
	p, _, err := userPlan(ctx, tx, userID)
	if err != nil || p.ownGroups == nil {
		return err
	}
	n, err := countOwnGroups(ctx, tx, userID)
	if err != nil {
		return err
	}
	if n >= *p.ownGroups {
		return planLimit("own_groups", *p.ownGroups)
	}
	return nil
}

func (s *Server) requireBilling() error {
	if !s.conf().Billing {
		return &apiError{status: http.StatusNotFound, code: "billing_off"}
	}
	return nil
}

func (s *Server) GetMyPlan(ctx context.Context, _ GetMyPlanRequestObject) (GetMyPlanResponseObject, error) {
	if err := s.requireBilling(); err != nil {
		return nil, err
	}
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	out, err := s.myPlan(ctx, s.db, u.id)
	if err != nil {
		return nil, err
	}
	return GetMyPlan200JSONResponse(out), nil
}

func (s *Server) myPlan(ctx context.Context, q querier, userID string) (MyPlan, error) {
	p, ends, err := userPlan(ctx, q, userID)
	if err != nil {
		return MyPlan{}, err
	}
	out := MyPlan{
		PlanName:          p.name,
		Paid:              !p.isDefault,
		ExpiresAt:         ends,
		ReceiptsPerGroup:  p.receipts,
		RecurringPerGroup: p.recurring,
		OwnGroups:         Usage{Limit: p.ownGroups},
		SponsoredGroups:   Usage{Limit: p.sponsored},
	}
	if out.OwnGroups.Used, err = countOwnGroups(ctx, q, userID); err != nil {
		return MyPlan{}, err
	}
	if out.SponsoredGroups.Used, err = countSponsored(ctx, q, userID); err != nil {
		return MyPlan{}, err
	}
	if out.Play, err = s.playOffer(ctx, q, userID); err != nil {
		return MyPlan{}, err
	}
	if cfg := s.conf(); cfg.KofiToken != "" && cfg.KofiURL != nil {
		if out.PaymentCode, err = paymentCode(ctx, q, userID); err != nil {
			return MyPlan{}, err
		}
	}
	return out, nil
}

// paymentCode is the account's code for payment messages. Most accounts never
// pay, so it's made when first shown.
func paymentCode(ctx context.Context, q querier, userID string) (*string, error) {
	var code *string
	err := q.QueryRow(ctx, `select payment_code from users where id = $1`, userID).Scan(&code)
	if err != nil || code != nil {
		return code, err
	}
	err = q.QueryRow(ctx, `
		update users set payment_code = coalesce(payment_code, $2) where id = $1
		returning payment_code`, userID, newPaymentCode()).Scan(&code)
	return code, err
}

// ClaimPayment takes a payment by its transaction ID, for payers who left no
// code. Ko-fi shows the ID to the payer, and it can't be guessed.
func (s *Server) ClaimPayment(ctx context.Context, req ClaimPaymentRequestObject) (ClaimPaymentResponseObject, error) {
	if err := s.requireBilling(); err != nil {
		return nil, err
	}
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	if now := time.Now(); !s.claims.take(u.id, 1, now) {
		return nil, limited(s.claims, u.id, now)
	}
	var out MyPlan
	var noPlan bool
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if err := holdAccount(ctx, tx, u.id); err != nil {
			return err
		}
		var id, state string
		var owner, email *string
		var planned, recurring bool
		err := tx.QueryRow(ctx, `
			select id::text, state, user_id::text, email::text, plan_id is not null, recurring
			from payment_events where provider = 'kofi' and reference = $1
			order by paid_at desc limit 1 for update`, paymentReference(req.Body.Reference)).
			Scan(&id, &state, &owner, &email, &planned, &recurring)
		if errors.Is(err, pgx.ErrNoRows) {
			return errPaymentNotFound
		}
		if err != nil {
			return err
		}
		// Someone else's, even with nothing given yet; or that of a deleted account.
		if owner != nil && *owner != u.id || owner == nil && state == "applied" {
			return conflict("payment_applied")
		}
		if recurring && email != nil {
			if err := rememberPaymentEmail(ctx, tx, *email, u.id); err != nil {
				return err
			}
		}
		if !planned {
			// Nothing to give, but the administrator can see whose it is.
			noPlan = true
			_, err = tx.Exec(ctx, `update payment_events set user_id = coalesce(user_id, $1) where id = $2`, u.id, id)
			if err != nil {
				return err
			}
			return claimPayments(ctx, tx, u.id)
		}
		if err := applyPayment(ctx, tx, id, u.id, true); err != nil {
			return err
		}
		if err := claimPayments(ctx, tx, u.id); err != nil {
			return err
		}
		out, err = s.myPlan(ctx, tx, u.id)
		return err
	})
	if err != nil {
		return nil, err
	}
	if noPlan {
		return nil, conflict("payment_no_plan")
	}
	return ClaimPayment200JSONResponse(out), nil
}

// rememberPaymentEmail sends the address's next subscription payments to
// userID, whoever had them before.
func rememberPaymentEmail(ctx context.Context, q querier, email, userID string) error {
	_, err := q.Exec(ctx, `
		insert into payment_emails (email, user_id) values ($1, $2)
		on conflict (email) do update set user_id = excluded.user_id, created_at = now()`, email, userID)
	return err
}

// adoptPaymentEmail is rememberPaymentEmail for a code in a message, which can
// be anyone's: a gift doesn't take the payments of a Ko-fi plan still running.
func adoptPaymentEmail(ctx context.Context, q querier, email, userID string) error {
	_, err := q.Exec(ctx, `
		insert into payment_emails (email, user_id) values ($1, $2)
		on conflict (email) do update set user_id = excluded.user_id, created_at = now()
		where not exists (
			select 1 from entitlements e
			where e.user_id = payment_emails.user_id and e.source = 'kofi' and `+entitlementActive+`)`, email, userID)
	return err
}

func (s *Server) GetGroupPlan(ctx context.Context, req GetGroupPlanRequestObject) (GetGroupPlanResponseObject, error) {
	if err := s.requireBilling(); err != nil {
		return nil, err
	}
	g, err := s.groupByToken(ctx, s.db, req.Token, false)
	if err != nil {
		return nil, err
	}
	out, err := s.groupPlanFor(ctx, s.db, g)
	if err != nil {
		return nil, err
	}
	return GetGroupPlan200JSONResponse(out), nil
}

func (s *Server) groupPlanFor(ctx context.Context, q querier, g *group) (GroupPlan, error) {
	p, sponsor, err := groupPlan(ctx, q, g)
	if err != nil {
		return GroupPlan{}, err
	}
	out := GroupPlan{
		PlanName:        p.name,
		SponsorMemberId: sponsor,
		Receipts:        Usage{Limit: p.receipts},
		Recurring:       Usage{Limit: p.recurring},
	}
	if out.Receipts.Used, err = countReceipts(ctx, q, g.id); err != nil {
		return GroupPlan{}, err
	}
	if out.Recurring.Used, err = countRecurring(ctx, q, g.id); err != nil {
		return GroupPlan{}, err
	}
	// A sponsor who stopped paying still sees the group as theirs, to stop.
	if sponsor != nil && g.me != nil && *sponsor == *g.me {
		return out, nil
	}
	covered, err := sponsorCovers(ctx, q, g)
	if err != nil || covered {
		return out, err
	}
	out.SponsorMemberId = nil // to everyone else, nobody sponsors it now
	u, err := s.currentUser(ctx)
	if err != nil || u == nil || g.me == nil {
		return out, err
	}
	out.CanSponsor, err = hasRoomToSponsor(ctx, q, u.id)
	return out, err
}

// sponsorCovers reports whether the group's sponsor still has a plan that
// sponsors groups. One who stopped paying doesn't keep others from it.
func sponsorCovers(ctx context.Context, q querier, g *group) (bool, error) {
	userID, _, err := groupSponsor(ctx, q, g)
	if err != nil || userID == nil {
		return false, err
	}
	p, _, err := userPlan(ctx, q, *userID)
	if err != nil {
		return false, err
	}
	return p.sponsored == nil || *p.sponsored > 0, nil
}

func hasRoomToSponsor(ctx context.Context, q querier, userID string) (bool, error) {
	p, _, err := userPlan(ctx, q, userID)
	if err != nil {
		return false, err
	}
	if p.sponsored == nil {
		return true, nil
	}
	n, err := countSponsored(ctx, q, userID)
	return n < *p.sponsored, err
}

func (s *Server) SponsorGroup(ctx context.Context, req SponsorGroupRequestObject) (SponsorGroupResponseObject, error) {
	if err := s.requireBilling(); err != nil {
		return nil, err
	}
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	var out GroupPlan
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		// The account before the group, as deleting an account takes them.
		if err := holdAccount(ctx, tx, u.id); err != nil {
			return err
		}
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		if g.me == nil {
			return forbidden("not_a_member")
		}
		sponsor, _, err := groupSponsor(ctx, tx, g)
		if err != nil {
			return err
		}
		if sponsor == nil || *sponsor != u.id {
			if covered, err := sponsorCovers(ctx, tx, g); err != nil {
				return err
			} else if covered {
				return conflict("already_sponsored")
			}
			p, _, err := userPlan(ctx, tx, u.id)
			if err != nil {
				return err
			}
			if room, err := hasRoomToSponsor(ctx, tx, u.id); err != nil {
				return err
			} else if !room {
				return planLimit("sponsored_groups", *p.sponsored)
			}
			if _, err := tx.Exec(ctx, `update groups set sponsor_user_id = $1 where id = $2`, u.id, g.id); err != nil {
				return err
			}
			if _, err := tx.Exec(ctx, `select pg_notify($1, $2)`, changeChannel, g.id); err != nil {
				return err
			}
		}
		out, err = s.groupPlanFor(ctx, tx, g)
		return err
	})
	if err != nil {
		return nil, err
	}
	return SponsorGroup200JSONResponse(out), nil
}

func (s *Server) UnsponsorGroup(ctx context.Context, req UnsponsorGroupRequestObject) (UnsponsorGroupResponseObject, error) {
	if err := s.requireBilling(); err != nil {
		return nil, err
	}
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	var out GroupPlan
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		sponsor, _, err := groupSponsor(ctx, tx, g)
		if err != nil {
			return err
		}
		if sponsor != nil && *sponsor != u.id {
			return forbidden("not_allowed")
		}
		if _, err := tx.Exec(ctx, `update groups set sponsor_user_id = null where id = $1`, g.id); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `select pg_notify($1, $2)`, changeChannel, g.id); err != nil {
			return err
		}
		out, err = s.groupPlanFor(ctx, tx, g)
		return err
	})
	if err != nil {
		return nil, err
	}
	return UnsponsorGroup200JSONResponse(out), nil
}

// cleanNote trims what an administrator wrote about an entitlement.
func cleanNote(note *string) *string {
	if note == nil {
		return nil
	}
	if t := strings.TrimSpace(*note); t != "" {
		return &t
	}
	return nil
}
