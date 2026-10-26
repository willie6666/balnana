package api

import (
	"context"

	"github.com/jackc/pgx/v5"
)

// Joining needs only the group's token and a signed-in account: the link is
// the invitation, whether or not the group has link access.

func (s *Server) GetJoinInfo(ctx context.Context, req GetJoinInfoRequestObject) (GetJoinInfoResponseObject, error) {
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	g, err := s.findGroup(ctx, s.db, req.Token, false)
	if err != nil {
		return nil, err
	}
	members, err := groupMembers(ctx, s.db, g.id)
	if err != nil {
		return nil, err
	}
	out := JoinInfo{
		Name:     g.name,
		Emoji:    g.emoji,
		Color:    g.color,
		Currency: g.currency,
		Member:   g.me != nil,
		Members:  []JoinMember{},
	}
	for _, m := range members {
		if !m.left {
			out.Members = append(out.Members, JoinMember{Id: m.id, Name: m.name, Color: m.color, Claimed: m.userID != nil})
		}
	}
	if out.InvitedMemberId, err = invitedMember(ctx, s.db, g, u); err != nil {
		return nil, err
	}
	return GetJoinInfo200JSONResponse(out), nil
}

func (s *Server) JoinGroup(ctx context.Context, req JoinGroupRequestObject) (JoinGroupResponseObject, error) {
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	in := req.Body
	var out Group
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.findGroup(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		if g.me == nil {
			if err := join(ctx, tx, g, u, in); err != nil {
				return err
			}
			if err := s.resolveAccess(ctx, tx, g); err != nil {
				return err
			}
		}
		out, err = loadGroup(ctx, tx, g)
		return err
	})
	if err != nil {
		return nil, err
	}
	return JoinGroup200JSONResponse(out), nil
}

// join makes u a member of g: the claimed member, the member u left behind
// before, or a new one.
func join(ctx context.Context, tx pgx.Tx, g *group, u *user, in *JoinInput) error {
	members, err := groupMembers(ctx, tx, g.id)
	if err != nil {
		return err
	}
	var old *member // the member u had before leaving, if any
	for i := range members {
		if m := &members[i]; m.userID != nil && *m.userID == u.id {
			old = m
		}
	}

	var m *member
	claimed := in.ClaimMemberId != nil && *in.ClaimMemberId != ""
	switch {
	case claimed:
		m = findMember(members, *in.ClaimMemberId)
		if m == nil || m.left {
			return errNotFound
		}
		if m.userID != nil {
			return conflict("member_claimed")
		}
		if old != nil {
			// One member per account and group: the old one stays in the
			// history, unlinked.
			if _, err := tx.Exec(ctx, `update members set user_id = null where id = $1`, old.id); err != nil {
				return err
			}
		}
		if _, err := tx.Exec(ctx, `update members set user_id = $2 where id = $1`, m.id, u.id); err != nil {
			return err
		}
	case old != nil:
		m = old
		if err := checkNameFree(members, m.name, m.id); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `update members set left_at = null where id = $1`, m.id); err != nil {
			return err
		}
	default:
		name := u.name
		if in.Name != nil && *in.Name != "" {
			if name, err = cleanName(*in.Name); err != nil {
				return err
			}
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
		m = &member{name: name}
		err := tx.QueryRow(ctx, `
			insert into members (group_id, display_name, user_id, created_at)
			values ($1, $2, $3, clock_timestamp()) returning id::text`, g.id, name, u.id).Scan(&m.id)
		if err != nil {
			return err
		}
	}
	if u.email != nil {
		if _, err := tx.Exec(ctx, `delete from invites where group_id = $1 and email = $2`, g.id, *u.email); err != nil {
			return err
		}
	}
	return logActivity(ctx, tx, g.id, &m.id, "member.joined", &m.id, map[string]any{"name": m.name, "claimed": claimed})
}
