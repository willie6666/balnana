package api

import (
	"context"
	"errors"
	"regexp"
	"slices"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"

	"balnana/internal/config"
	"balnana/internal/domain"
)

var currencyCode = regexp.MustCompile(`^[A-Z]{3}$`)

func (s *Server) CreateGroup(ctx context.Context, req CreateGroupRequestObject) (CreateGroupResponseObject, error) {
	var creator *user
	linkAccess := true
	if s.conf().AuthMode == config.AuthModeAccounts {
		u, err := s.requireUser(ctx)
		if err != nil {
			return nil, err
		}
		creator = u
		linkAccess = s.conf().LinkGroups && req.Body.LinkAccess != nil && *req.Body.LinkAccess
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
	if err := s.limitCreates(ctx); err != nil {
		return nil, err
	}

	var out Group
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := scanGroup(tx.QueryRow(ctx, `
			insert into groups (token, name, emoji, color, currency, minor_digits, link_access)
			values ($1, $2, $3, $4, $5, $6, $7)
			returning `+groupColumns, newToken(), name, emoji, in.Color, currency, digits, linkAccess))
		if err != nil {
			return err
		}
		var first *string
		for i, n := range names {
			var id string
			var userID *string
			if i == 0 && creator != nil {
				userID = &creator.id
			}
			// clock_timestamp keeps the given order; now() is fixed per transaction.
			err := tx.QueryRow(ctx, `
				insert into members (group_id, display_name, is_owner, user_id, created_at)
				values ($1, $2, $3, $4, clock_timestamp()) returning id::text`, g.id, n, i == 0, userID).Scan(&id)
			if err != nil {
				return err
			}
			if i == 0 {
				first = &id
			}
		}
		if err := logActivity(ctx, tx, g.id, first, "group.created", nil, map[string]any{"name": name}); err != nil {
			return err
		}
		if err := s.resolveAccess(ctx, tx, g); err != nil {
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
		var ae *apiError
		if errors.As(err, &ae) && ae.status >= 400 && ae.status < 500 {
			out.Missing = append(out.Missing, item.Token)
			continue
		}
		if err != nil {
			return nil, err
		}
		me := g.me
		if me == nil && item.MemberId != nil && validUUID(*item.MemberId) {
			me = item.MemberId
		}
		sum, err := summarize(ctx, s.db, g, me)
		if err != nil {
			return nil, err
		}
		out.Groups = append(out.Groups, sum)
	}
	return GetGroupSummaries200JSONResponse(out), nil
}

func (s *Server) GetMyGroups(ctx context.Context, _ GetMyGroupsRequestObject) (GetMyGroupsResponseObject, error) {
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	rows, err := s.db.Query(ctx, `
		select `+prefixed("g.", groupColumns)+`, m.id::text, m.is_owner
		from members m join groups g on g.id = m.group_id
		where m.user_id = $1 and m.left_at is null and g.archived_at is null
		order by g.created_at`, u.id)
	if err != nil {
		return nil, err
	}
	groups, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*group, error) {
		var g group
		var me string
		err := row.Scan(&g.id, &g.token, &g.name, &g.emoji, &g.color, &g.currency, &g.digits, &g.linkAccess, &g.createdAt, &me, &g.owner)
		g.me = &me
		return &g, err
	})
	if err != nil {
		return nil, err
	}
	out := GroupSummaryList{Groups: []GroupSummary{}, Missing: []string{}}
	for _, g := range groups {
		sum, err := summarize(ctx, s.db, g, g.me)
		if err != nil {
			return nil, err
		}
		out.Groups = append(out.Groups, sum)
	}
	slices.SortStableFunc(out.Groups, func(a, b GroupSummary) int { return b.UpdatedAt.Compare(a.UpdatedAt) })
	return GetMyGroups200JSONResponse(out), nil
}

// prefixed qualifies each column of a column list, for joins.
func prefixed(prefix, columns string) string {
	cols := strings.Split(columns, ", ")
	for i, c := range cols {
		cols[i] = prefix + c
	}
	return strings.Join(cols, ", ")
}

// summarize builds a group's Home card, with me's balance when me is a member.
func summarize(ctx context.Context, q querier, g *group, me *string) (GroupSummary, error) {
	sum := GroupSummary{
		Token:       g.token,
		Name:        g.name,
		Emoji:       g.emoji,
		Color:       g.color,
		Currency:    g.currency,
		MinorDigits: g.digits,
	}
	var updated *time.Time
	err := q.QueryRow(ctx, `
		select (select count(*) from members where group_id = $1 and left_at is null),
		       (select max(created_at) from activity_log where group_id = $1)`, g.id).
		Scan(&sum.MemberCount, &updated)
	if err != nil {
		return sum, err
	}
	sum.UpdatedAt = g.createdAt
	if updated != nil {
		sum.UpdatedAt = *updated
	}
	if me == nil {
		return sum, nil
	}
	members, err := groupMembers(ctx, q, g.id)
	if err != nil {
		return sum, err
	}
	if m := findMember(members, *me); m != nil {
		nets, err := groupNets(ctx, q, g.id)
		if err != nil {
			return sum, err
		}
		b := domain.FormatAmount(nets[m.id], g.digits)
		sum.Balance = &b
	}
	return sum, nil
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
	accounts := s.conf().AuthMode == config.AuthModeAccounts
	if in.LinkAccess != nil && accounts && *in.LinkAccess && !s.conf().LinkGroups {
		return nil, forbidden("link_groups_off")
	}

	var out Group
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		var linkAccess *bool
		if in.LinkAccess != nil && accounts && *in.LinkAccess != g.linkAccess {
			if !g.owner {
				return forbidden("owner_only")
			}
			linkAccess = in.LinkAccess
		}
		g, err = scanGroup(tx.QueryRow(ctx, `
			update groups set
				name = coalesce($2, name),
				emoji = case when $4 then null else coalesce($3, emoji) end,
				color = coalesce($5, color),
				link_access = coalesce($6, link_access)
			where id = $1
			returning `+groupColumns, g.id, name, emoji, clearEmoji, in.Color, linkAccess))
		if err != nil {
			return err
		}
		if err := s.resolveAccess(ctx, tx, g); err != nil {
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
		// Whoever holds the link of a group open by link may use it, but
		// only its members may lock the others out.
		if s.conf().AuthMode == config.AuthModeAccounts && g.me == nil {
			return forbidden("not_a_member")
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		g, err = scanGroup(tx.QueryRow(ctx, `update groups set token = $2 where id = $1 returning `+groupColumns, g.id, newToken()))
		if err != nil {
			return err
		}
		if err := s.resolveAccess(ctx, tx, g); err != nil {
			return err
		}
		// Phones following by the old link hear nothing more (see pushDevices).
		if _, err := tx.Exec(ctx, `delete from push_follows where group_id = $1 and link_token <> $2`, g.id, g.token); err != nil {
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

func (s *Server) DeleteGroup(ctx context.Context, req DeleteGroupRequestObject) (DeleteGroupResponseObject, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		if s.conf().AuthMode == config.AuthModeAccounts && !g.owner {
			if g.me == nil {
				return forbidden("not_a_member")
			}
			// A group whose owner has gone may be deleted by any member.
			var owned bool
			err := tx.QueryRow(ctx, `
				select exists (select 1 from members
				               where group_id = $1 and is_owner and user_id is not null and left_at is null)`,
				g.id).Scan(&owned)
			if err != nil {
				return err
			}
			if owned {
				return forbidden("owner_only")
			}
		}
		if _, err := tx.Exec(ctx, `delete from groups where id = $1`, g.id); err != nil {
			return err
		}
		// Open apps reload and find it gone.
		_, err = tx.Exec(ctx, `select pg_notify($1, $2)`, changeChannel, g.id)
		return err
	})
	if err != nil {
		return nil, err
	}
	s.log.Info("group deleted")
	return DeleteGroup204Response{}, nil
}
