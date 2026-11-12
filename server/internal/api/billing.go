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
	paid      bool
	receipts  *int
	recurring *int
	joined    *int
	members   *int
	sponsored *int
	reminders bool
}

// userPlan is the best active entitlement, or the automatic plan for the
// account's current email verification status. With no account it returns
// the group default. Its second result is when an entitlement ends.
func userPlan(ctx context.Context, q querier, userID string) (*plan, *time.Time, error) {
	var p plan
	var ends *time.Time
	err := q.QueryRow(ctx, `
		select p.name, e.id is not null, p.receipts_per_group, p.recurring_per_group, p.joined_groups,
		       p.members_per_group, p.sponsored_groups, p.reminders, e.expires_at
		from plans p
		cross join automatic_plans a
		left join users u on u.id = $1
		left join entitlements e on e.plan_id = p.id and e.user_id = $1 and `+entitlementActive+`
		where (case when u.id is null then p.is_default
		       when u.email_verified then p.id = a.verified_plan_id
		       else p.id = a.unverified_plan_id end) or e.id is not null
		order by e.id is not null desc, p.rank desc, e.expires_at desc nulls first
		limit 1`, userID).
		Scan(&p.name, &p.paid, &p.receipts, &p.recurring, &p.joined, &p.members, &p.sponsored, &p.reminders, &ends)
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

// planLimit is the refusal to exceed a limit. Existing data stays as it is.
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

func countJoinedGroups(ctx context.Context, q querier, userID string) (n int, err error) {
	err = q.QueryRow(ctx, `
		select count(*) from members m join groups g on g.id = m.group_id
		where m.user_id = $1 and m.left_at is null and g.archived_at is null`, userID).Scan(&n)
	return n, err
}

// countMembers counts the people still in the group, with or without accounts.
func countMembers(ctx context.Context, q querier, groupID string) (n int, err error) {
	err = q.QueryRow(ctx, `select count(*) from members where group_id = $1 and left_at is null`, groupID).Scan(&n)
	return n, err
}

func countSponsored(ctx context.Context, q querier, userID string) (n int, err error) {
	err = q.QueryRow(ctx, `
		select count(*) from groups g
		join members m on m.group_id = g.id and m.user_id = g.sponsor_user_id and m.left_at is null
		where g.sponsor_user_id = $1 and g.archived_at is null`, userID).Scan(&n)
	return n, err
}

// checkReceiptLimit allows replacement at the group's quota, but not above it.
// New photos need room in the quota. In a write it needs the group locked.
func (s *Server) checkReceiptLimit(ctx context.Context, q querier, g *group, expenseID string) error {
	if !s.conf().Billing {
		return nil
	}
	// The uploader's zero-photo plan applies even in a sponsored group and
	// when replacing a photo. The group's quota is checked separately below.
	u, err := s.currentUser(ctx)
	if err != nil {
		return err
	}
	if u != nil {
		p, _, err := userPlan(ctx, q, u.id)
		if err != nil {
			return err
		}
		if p.receipts != nil && *p.receipts == 0 {
			return planLimit("receipts", 0)
		}
	}
	var replaces bool
	if err := q.QueryRow(ctx, `select exists (select 1 from receipts where expense_id = $1)`, expenseID).Scan(&replaces); err != nil {
		return err
	}
	p, _, err := groupPlan(ctx, q, g)
	if err != nil || p.receipts == nil {
		return err
	}
	n, err := countReceipts(ctx, q, g.id)
	if err != nil {
		return err
	}
	if n > *p.receipts || n == *p.receipts && !replaces {
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

// checkJoinedGroups refuses one more group to an account in all it may be in.
func (s *Server) checkJoinedGroups(ctx context.Context, tx pgx.Tx, userID string) error {
	if !s.conf().Billing {
		return nil
	}
	if err := holdAccount(ctx, tx, userID); err != nil {
		return err
	}
	p, _, err := userPlan(ctx, tx, userID)
	if err != nil || p.joined == nil {
		return err
	}
	n, err := countJoinedGroups(ctx, tx, userID)
	if err != nil {
		return err
	}
	if n >= *p.joined {
		return planLimit("joined_groups", *p.joined)
	}
	return nil
}

// checkNewGroup refuses a group of n people that its creator may not start. A
// group larger than the default plan allows is sponsored from the start, or
// nobody could import one, and so is one whose creator asks to share their
// plan with it: it returns who sponsors it, if anyone.
func (s *Server) checkNewGroup(ctx context.Context, tx pgx.Tx, creator *user, n int, share bool) (sponsor *string, err error) {
	if !s.conf().Billing {
		return nil, nil
	}
	if creator != nil {
		if err := s.checkJoinedGroups(ctx, tx, creator.id); err != nil {
			return nil, err
		}
	}
	free, _, err := userPlan(ctx, tx, nilUUID)
	if err != nil {
		return nil, err
	}
	// Too large for the default plan: only a sponsor's makes room for it.
	large := free.members != nil && n > *free.members
	if !large && (!share || creator == nil) {
		return nil, nil
	}
	if creator == nil {
		return nil, planLimit("members", *free.members)
	}
	p, _, err := userPlan(ctx, tx, creator.id)
	if err != nil {
		return nil, err
	}
	if p.members != nil && n > *p.members {
		return nil, planLimit("members", *p.members)
	}
	if p.sponsored != nil && *p.sponsored == 0 {
		if large {
			return nil, planLimit("members", *free.members)
		}
		return nil, planLimit("sponsored_groups", 0)
	}
	if room, err := hasRoomToSponsor(ctx, tx, creator.id, p); err != nil {
		return nil, err
	} else if !room {
		return nil, planLimit("sponsored_groups", *p.sponsored)
	}
	return &creator.id, nil
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
		Paid:              p.paid,
		ExpiresAt:         ends,
		ReceiptsPerGroup:  p.receipts,
		RecurringPerGroup: p.recurring,
		MembersPerGroup:   p.members,
		Reminders:         p.reminders,
		JoinedGroups:      Usage{Limit: p.joined},
		SponsoredGroups:   Usage{Limit: p.sponsored},
	}
	if out.JoinedGroups.Used, err = countJoinedGroups(ctx, q, userID); err != nil {
		return MyPlan{}, err
	}
	if out.SponsoredGroups.Used, err = countSponsored(ctx, q, userID); err != nil {
		return MyPlan{}, err
	}
	if out.Play, err = s.playOffer(ctx, q, userID); err != nil {
		return MyPlan{}, err
	}
	if out.Paypal, err = s.paypalOffer(ctx, q, userID); err != nil {
		return MyPlan{}, err
	}
	return out, nil
}

// ClaimPayment takes a Ko-fi payment by its transaction ID. Ko-fi shows the ID
// to the payer, and it can't be guessed.
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
		var owner *string
		var planned bool
		err := tx.QueryRow(ctx, `
			select id::text, state, user_id::text, plan_id is not null
			from payment_events where provider = 'kofi' and reference = $1
			order by paid_at desc limit 1 for update`, paymentReference(req.Body.Reference)).
			Scan(&id, &state, &owner, &planned)
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
		if !planned {
			// Nothing to give, but the administrator can see whose it is.
			noPlan = true
			_, err = tx.Exec(ctx, `update payment_events set user_id = coalesce(user_id, $1) where id = $2`, u.id, id)
			return err
		}
		if err := applyPayment(ctx, tx, id, u.id); err != nil {
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
		Members:         Usage{Limit: p.members},
		Receipts:        Usage{Limit: p.receipts},
		Recurring:       Usage{Limit: p.recurring},
		Reminders:       p.reminders,
	}
	if out.Members.Used, err = countMembers(ctx, q, g.id); err != nil {
		return GroupPlan{}, err
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
	// p is the sponsor's plan when there is one.
	if sponsor != nil && p.sponsors() {
		return out, nil
	}
	out.SponsorMemberId = nil // to everyone else, nobody sponsors it now
	u, err := s.currentUser(ctx)
	if err != nil || u == nil || g.me == nil {
		return out, err
	}
	mine, _, err := userPlan(ctx, q, u.id)
	if err != nil {
		return out, err
	}
	out.CanSponsor, err = hasRoomToSponsor(ctx, q, u.id, mine)
	return out, err
}

// sharedPlans says whose plan covers each of userID's groups, by group ID:
// their own, or another member's that still sponsors. Groups nobody's plan
// covers are left out.
func sharedPlans(ctx context.Context, q querier, userID string, groups []*group) (map[string]GroupSummarySharedPlan, error) {
	ids := make([]string, len(groups))
	for i, g := range groups {
		ids[i] = g.id
	}
	rows, err := q.Query(ctx, `
		select g.id::text, g.sponsor_user_id::text from groups g
		join members m on m.group_id = g.id and m.user_id = g.sponsor_user_id and m.left_at is null
		where g.id = any($1::uuid[])`, ids)
	if err != nil {
		return nil, err
	}
	sponsors := map[string]string{}
	var id, sponsor string
	if _, err := pgx.ForEachRow(rows, []any{&id, &sponsor}, func() error {
		sponsors[id] = sponsor
		return nil
	}); err != nil {
		return nil, err
	}
	out := map[string]GroupSummarySharedPlan{}
	covers := map[string]bool{}
	for id, sponsor := range sponsors {
		// The account's own stays theirs to stop, whatever their plan is now.
		if sponsor == userID {
			out[id] = Mine
			continue
		}
		covered, known := covers[sponsor]
		if !known {
			if covered, err = sponsorCovers(ctx, q, &sponsor); err != nil {
				return nil, err
			}
			covers[sponsor] = covered
		}
		if covered {
			out[id] = Other
		}
	}
	return out, nil
}

// sponsors reports whether the plan sponsors groups. A sponsor who stopped
// paying doesn't keep others from sponsoring theirs.
func (p *plan) sponsors() bool {
	return p.sponsored == nil || *p.sponsored > 0
}

// sponsorCovers reports whether userID, the group's sponsor if anyone, still
// has a plan that sponsors groups.
func sponsorCovers(ctx context.Context, q querier, userID *string) (bool, error) {
	if userID == nil {
		return false, nil
	}
	p, _, err := userPlan(ctx, q, *userID)
	if err != nil {
		return false, err
	}
	return p.sponsors(), nil
}

// hasRoomToSponsor reports whether userID, whose plan is p, may sponsor one
// more group.
func hasRoomToSponsor(ctx context.Context, q querier, userID string, p *plan) (bool, error) {
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
			if covered, err := sponsorCovers(ctx, tx, sponsor); err != nil {
				return err
			} else if covered {
				return conflict("already_sponsored")
			}
			p, _, err := userPlan(ctx, tx, u.id)
			if err != nil {
				return err
			}
			if room, err := hasRoomToSponsor(ctx, tx, u.id, p); err != nil {
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
