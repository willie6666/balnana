package api

import (
	"context"
	"regexp"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"

	"balnana/internal/config"
	"balnana/internal/domain"
)

var currencyCode = regexp.MustCompile(`^[A-Z]{3}$`)

func (s *Server) CreateGroup(ctx context.Context, req CreateGroupRequestObject) (CreateGroupResponseObject, error) {
	if s.cfg.AuthMode == config.AuthModeAccounts {
		return nil, forbidden("sign_in_required")
	}
	in := req.Body
	name, err := cleanName(in.Name)
	if err != nil {
		return nil, err
	}
	emoji, err := cleanEmoji(in.Emoji)
	if err != nil {
		return nil, err
	}
	if err := validColor(in.Color); err != nil {
		return nil, err
	}
	currency := strings.ToUpper(strings.TrimSpace(in.Currency))
	if !currencyCode.MatchString(currency) {
		return nil, badRequest("invalid_currency")
	}
	digits := 2
	if in.MinorDigits != nil {
		digits = *in.MinorDigits
	}
	if digits < 0 || digits > domain.MaxDigits {
		return nil, badRequest("invalid_minor_digits")
	}
	if len(in.Members) == 0 {
		return nil, badRequest("no_members")
	}
	if len(in.Members) > maxMembers {
		return nil, badRequest("too_many_members")
	}
	names := make([]string, 0, len(in.Members))
	for _, raw := range in.Members {
		n, err := cleanName(raw)
		if err != nil {
			return nil, err
		}
		for _, other := range names {
			if strings.EqualFold(other, n) {
				return nil, badRequest("duplicate_name")
			}
		}
		names = append(names, n)
	}

	var out Group
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := scanGroup(tx.QueryRow(ctx, `
			insert into groups (token, name, emoji, color, currency, minor_digits)
			values ($1, $2, $3, $4, $5, $6)
			returning `+groupColumns, newToken(), name, emoji, in.Color, currency, digits))
		if err != nil {
			return err
		}
		var creator *string
		for i, n := range names {
			var id string
			// clock_timestamp keeps the given order; now() is fixed per transaction.
			err := tx.QueryRow(ctx, `
				insert into members (group_id, display_name, is_owner, created_at)
				values ($1, $2, $3, clock_timestamp()) returning id::text`, g.id, n, i == 0).Scan(&id)
			if err != nil {
				return err
			}
			if i == 0 {
				creator = &id
			}
		}
		if err := logActivity(ctx, tx, g.id, creator, "group.created", nil, map[string]any{"name": name}); err != nil {
			return err
		}
		out, err = loadGroup(ctx, tx, g)
		return err
	})
	if err != nil {
		return nil, err
	}
	return CreateGroup201JSONResponse(out), nil
}

func (s *Server) GetGroupSummaries(ctx context.Context, req GetGroupSummariesRequestObject) (GetGroupSummariesResponseObject, error) {
	if len(req.Body.Groups) > maxPageSize {
		return nil, badRequest("too_many_groups")
	}
	out := GroupSummaryList{Groups: []GroupSummary{}, Missing: []string{}}
	for _, item := range req.Body.Groups {
		g, err := s.groupByToken(ctx, s.db, item.Token, false)
		if err == errNotFound {
			out.Missing = append(out.Missing, item.Token)
			continue
		}
		if err != nil {
			return nil, err
		}
		sum := GroupSummary{
			Token:       g.token,
			Name:        g.name,
			Emoji:       g.emoji,
			Color:       g.color,
			Currency:    g.currency,
			MinorDigits: g.digits,
		}
		var updated *time.Time
		err = s.db.QueryRow(ctx, `
			select (select count(*) from members where group_id = $1 and left_at is null),
			       (select max(created_at) from activity_log where group_id = $1)`, g.id).
			Scan(&sum.MemberCount, &updated)
		if err != nil {
			return nil, err
		}
		sum.UpdatedAt = g.createdAt
		if updated != nil {
			sum.UpdatedAt = *updated
		}
		if item.MemberId != nil && validUUID(*item.MemberId) {
			members, err := groupMembers(ctx, s.db, g.id)
			if err != nil {
				return nil, err
			}
			if m := findMember(members, *item.MemberId); m != nil {
				nets, err := groupNets(ctx, s.db, g.id)
				if err != nil {
					return nil, err
				}
				b := domain.FormatAmount(nets[m.id], g.digits)
				sum.Balance = &b
			}
		}
		out.Groups = append(out.Groups, sum)
	}
	return GetGroupSummaries200JSONResponse(out), nil
}

func (s *Server) GetGroup(ctx context.Context, req GetGroupRequestObject) (GetGroupResponseObject, error) {
	g, err := s.groupByToken(ctx, s.db, req.Token, false)
	if err != nil {
		return nil, err
	}
	out, err := loadGroup(ctx, s.db, g)
	if err != nil {
		return nil, err
	}
	return GetGroup200JSONResponse(out), nil
}

func (s *Server) UpdateGroup(ctx context.Context, req UpdateGroupRequestObject) (UpdateGroupResponseObject, error) {
	in := req.Body
	var name *string
	if in.Name != nil {
		n, err := cleanName(*in.Name)
		if err != nil {
			return nil, err
		}
		name = &n
	}
	if err := validColor(in.Color); err != nil {
		return nil, err
	}
	emoji, err := cleanEmoji(in.Emoji)
	if err != nil {
		return nil, err
	}
	clearEmoji := in.Emoji != nil && emoji == nil

	var out Group
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		who, err := actor(ctx, tx, g.id, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		g, err = scanGroup(tx.QueryRow(ctx, `
			update groups set
				name = coalesce($2, name),
				emoji = case when $4 then null else coalesce($3, emoji) end,
				color = coalesce($5, color)
			where id = $1
			returning `+groupColumns, g.id, name, emoji, clearEmoji, in.Color))
		if err != nil {
			return err
		}
		if err := logActivity(ctx, tx, g.id, who, "group.updated", nil, map[string]any{"name": g.name}); err != nil {
			return err
		}
		out, err = loadGroup(ctx, tx, g)
		return err
	})
	if err != nil {
		return nil, err
	}
	return UpdateGroup200JSONResponse(out), nil
}

func (s *Server) ResetGroupLink(ctx context.Context, req ResetGroupLinkRequestObject) (ResetGroupLinkResponseObject, error) {
	var out Group
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		who, err := actor(ctx, tx, g.id, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		g, err = scanGroup(tx.QueryRow(ctx, `update groups set token = $2 where id = $1 returning `+groupColumns, g.id, newToken()))
		if err != nil {
			return err
		}
		if err := logActivity(ctx, tx, g.id, who, "group.link_reset", nil, nil); err != nil {
			return err
		}
		out, err = loadGroup(ctx, tx, g)
		return err
	})
	if err != nil {
		return nil, err
	}
	return ResetGroupLink200JSONResponse(out), nil
}
