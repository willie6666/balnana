package api

import (
	"context"
	"slices"
	"strings"

	"github.com/jackc/pgx/v5"
)

// mayChange refuses changes to a member someone has claimed with their
// account, unless they make them themselves or own the group. In link mode
// there are no accounts to tell them apart, and anyone with the link may.
func mayChange(g *group, m *member) error {
	if g.accounts && m.userID != nil && (g.me == nil || *g.me != m.id) && !g.owner {
		return forbidden("not_allowed")
	}
	return nil
}

// cleanPayDetails checks a member's payment details. Each is one line, as a
// value with a line break would show in a share message as something else.
func cleanPayDetails(in []PaymentDetail) ([]PaymentDetail, error) {
	if len(in) > maxPayDetails {
		return nil, badRequest("invalid_payment_details")
	}
	out := make([]PaymentDetail, len(in))
	for i, d := range in {
		label, ok := cleanText(d.Label, 1, maxPayLabel)
		value, ok2 := cleanText(d.Value, 1, maxPayValue)
		if !ok || !ok2 || strings.Contains(label+value, "\n") {
			return nil, badRequest("invalid_payment_details")
		}
		out[i] = PaymentDetail{Label: label, Value: value}
	}
	return out, nil
}

// mayChangePay refuses a change to how a member is paid unless, in accounts
// mode, it is their own account making it: not even the group's owner may,
// or they could send someone's debtors to an account of their choosing.
func mayChangePay(g *group, m *member) error {
	if g.accounts && (g.me == nil || *g.me != m.id || m.userID == nil) {
		return forbidden("not_allowed")
	}
	return nil
}

// checkNameFree refuses a name another current member already uses.
func checkNameFree(members []member, name, except string) error {
	for _, m := range members {
		if !m.left && m.id != except && strings.EqualFold(m.name, name) {
			return conflict("duplicate_name")
		}
	}
	return nil
}

// checkRoom refuses one more current member when the group is full: a new
// member, or one who left coming back. It needs the group locked.
func (s *Server) checkRoom(ctx context.Context, q querier, g *group, members []member) error {
	active := 0
	for _, m := range members {
		if !m.left {
			active++
		}
	}
	if active >= maxMembers {
		return badRequest("too_many_members")
	}
	if !s.conf().Billing {
		return nil
	}
	p, _, err := groupPlan(ctx, q, g)
	if err != nil || p.members == nil {
		return err
	}
	if active >= *p.members {
		return planLimit("members", *p.members)
	}
	return nil
}

func (s *Server) AddMember(ctx context.Context, req AddMemberRequestObject) (AddMemberResponseObject, error) {
	name, err := cleanName(req.Body.Name)
	if err != nil {
		return nil, err
	}
	if err := validColor(req.Body.Color); err != nil {
		return nil, err
	}
	var pay []PaymentDetail
	if req.Body.PaymentDetails != nil {
		if pay, err = cleanPayDetails(*req.Body.PaymentDetails); err != nil {
			return nil, err
		}
	}
	var out Member
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		// Nobody's account is theirs yet.
		if len(pay) > 0 && g.accounts {
			return forbidden("not_allowed")
		}
		members, err := groupMembers(ctx, tx, g.id)
		if err != nil {
			return err
		}
		if err := checkNameFree(members, name, ""); err != nil {
			return err
		}
		if err := s.checkRoom(ctx, tx, g, members); err != nil {
			return err
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		m := member{name: name, color: req.Body.Color, pay: pay}
		err = tx.QueryRow(ctx, `
			insert into members (group_id, display_name, color, payment_details, created_at)
			values ($1, $2, $3, $4, clock_timestamp()) returning id::text`, g.id, name, req.Body.Color, listed(pay)).Scan(&m.id)
		if err != nil {
			return err
		}
		if who == nil {
			// Someone joining as a new member is the one acting.
			who = &m.id
		}
		if err := logActivity(ctx, tx, g.id, who, "member.added", &m.id, map[string]any{"name": name}); err != nil {
			return err
		}
		out = toMember(m, nil, g.digits)
		return nil
	})
	if err != nil {
		return nil, err
	}
	return AddMember201JSONResponse(out), nil
}

func (s *Server) UpdateMember(ctx context.Context, req UpdateMemberRequestObject) (UpdateMemberResponseObject, error) {
	name, err := cleanName(req.Body.Name)
	if err != nil {
		return nil, err
	}
	if err := validColor(req.Body.Color); err != nil {
		return nil, err
	}
	var pay []PaymentDetail
	if req.Body.PaymentDetails != nil {
		if pay, err = cleanPayDetails(*req.Body.PaymentDetails); err != nil {
			return nil, err
		}
	}
	var out Member
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		members, err := groupMembers(ctx, tx, g.id)
		if err != nil {
			return err
		}
		m := findMember(members, req.MemberId)
		if m == nil {
			return errNotFound
		}
		if err := mayChange(g, m); err != nil {
			return err
		}
		// The same list sent back with a new name is no change to them.
		if pay == nil || slices.Equal(pay, m.pay) {
			pay = m.pay
		} else if err := mayChangePay(g, m); err != nil {
			return err
		}
		if err := checkNameFree(members, name, m.id); err != nil {
			return err
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		color := m.color
		if req.Body.Color != nil {
			color = req.Body.Color
		}
		oldName := m.name
		m.name, m.color, m.pay = name, color, pay
		if _, err := tx.Exec(ctx, `update members set display_name = $2, color = $3, payment_details = $4 where id = $1`, m.id, name, color, listed(pay)); err != nil {
			return err
		}
		if err := logActivity(ctx, tx, g.id, who, "member.updated", &m.id, map[string]any{"name": name, "oldName": oldName}); err != nil {
			return err
		}
		nets, err := groupNets(ctx, tx, g.id)
		if err != nil {
			return err
		}
		out = toMember(*m, nets, g.digits)
		return nil
	})
	if err != nil {
		return nil, err
	}
	return UpdateMember200JSONResponse(out), nil
}

func (s *Server) RemoveMember(ctx context.Context, req RemoveMemberRequestObject) (RemoveMemberResponseObject, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		members, err := groupMembers(ctx, tx, g.id)
		if err != nil {
			return err
		}
		m := findMember(members, req.MemberId)
		if m == nil {
			return errNotFound
		}
		if m.left {
			return nil
		}
		if err := mayChange(g, m); err != nil {
			return err
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		// Coming back by the link does not make them an owner again, and an
		// invitation to be them no longer works.
		if _, err := tx.Exec(ctx, `update members set left_at = now(), is_owner = false where id = $1`, m.id); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `delete from invites where member_id = $1`, m.id); err != nil {
			return err
		}
		// Their plan stops paying for the group, and coming back does not start
		// it again: that takes sponsoring the group anew, within their limits.
		if m.userID != nil {
			if _, err := tx.Exec(ctx, `update groups set sponsor_user_id = null where id = $1 and sponsor_user_id = $2`, g.id, *m.userID); err != nil {
				return err
			}
		}
		// The last owner leaving hands the group on, as deleting the account
		// does, to whoever joined with an account first.
		_, err = tx.Exec(ctx, `
			update members set is_owner = true where id = (
				select id from members
				where group_id = $1 and user_id is not null and left_at is null
				order by created_at limit 1)
			  and not exists (select 1 from members
			                  where group_id = $1 and is_owner and user_id is not null and left_at is null)`, g.id)
		if err != nil {
			return err
		}
		return logActivity(ctx, tx, g.id, who, "member.removed", &m.id, map[string]any{"name": m.name})
	})
	if err != nil {
		return nil, err
	}
	return RemoveMember204Response{}, nil
}
