package api

import (
	"context"
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
// member, or one who left coming back.
func checkRoom(members []member) error {
	active := 0
	for _, m := range members {
		if !m.left {
			active++
		}
	}
	if active >= maxMembers {
		return badRequest("too_many_members")
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
		if err := checkNameFree(members, name, ""); err != nil {
			return err
		}
		if err := checkRoom(members); err != nil {
			return err
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		m := member{name: name, color: req.Body.Color}
		err = tx.QueryRow(ctx, `
			insert into members (group_id, display_name, color, created_at)
			values ($1, $2, $3, clock_timestamp()) returning id::text`, g.id, name, req.Body.Color).Scan(&m.id)
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
		if _, err := tx.Exec(ctx, `update members set display_name = $2, color = $3 where id = $1`, m.id, name, color); err != nil {
			return err
		}
		if err := logActivity(ctx, tx, g.id, who, "member.updated", &m.id, map[string]any{"name": name, "oldName": m.name}); err != nil {
			return err
		}
		nets, err := groupNets(ctx, tx, g.id)
		if err != nil {
			return err
		}
		m.name, m.color = name, color
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
		nets, err := groupNets(ctx, tx, g.id)
		if err != nil {
			return err
		}
		if nets[m.id] != 0 {
			return conflict("member_has_balance")
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
