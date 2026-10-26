package api

import (
	"context"
	"strings"

	"github.com/jackc/pgx/v5"
)

// mayChange refuses changes to a member someone has claimed with their
// account, unless they make them themselves or own the group.
func mayChange(g *group, m *member) error {
	if m.userID != nil && (g.me == nil || *g.me != m.id) && !g.owner {
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
		active := 0
		for _, m := range members {
			if !m.left {
				active++
			}
		}
		if active >= maxMembers {
			return badRequest("too_many_members")
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
		if _, err := tx.Exec(ctx, `update members set left_at = now() where id = $1`, m.id); err != nil {
			return err
		}
		return logActivity(ctx, tx, g.id, who, "member.removed", &m.id, map[string]any{"name": m.name})
	})
	if err != nil {
		return nil, err
	}
	return RemoveMember204Response{}, nil
}
