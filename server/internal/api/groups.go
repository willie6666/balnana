package api

import (
	"context"
	"errors"
	"net/http"
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
	symbol, err := cleanSymbol(in.Symbol)
	if err != nil {
		return nil, err
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
		if creator != nil {
			if err := s.checkOwnGroups(ctx, tx, creator.id); err != nil {
				return err
			}
		}
		g, err := scanGroup(tx.QueryRow(ctx, `
			insert into groups (token, name, emoji, color, currency, symbol, minor_digits, link_access)
			values ($1, $2, $3, $4, $5, $6, $7, $8)
			returning `+groupColumns, newToken(), name, emoji, in.Color, currency, symbol, digits, linkAccess))
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
	// The tokens are the ones this device saved, and a group it had may be
	// gone or its link reset meanwhile, which the app shows. However many,
	// they count as one miss, or a phone holding a few would be locked out
	// of the server by reloading its home page.
	misses := &missCount{}
	defer func() {
		if misses.n > 0 {
			noteMiss(ctx)
		}
	}()
	lookup := context.WithValue(ctx, missesKey{}, misses)
	out := GroupSummaryList{Missing: []string{}, Locked: []string{}}
	var groups []*group
	for _, item := range req.Body.Groups {
		g, err := s.groupByToken(lookup, s.db, item.Token, false)
		var ae *apiError
		if errors.As(err, &ae) && ae.status == http.StatusNotFound {
			out.Missing = append(out.Missing, item.Token)
			continue
		}
		// The group is there, but not open to this device as it is: the app
		// must not offer to forget it.
		if errors.As(err, &ae) && ae.status >= 400 && ae.status < 500 {
			out.Locked = append(out.Locked, item.Token)
			continue
		}
		if err != nil {
			return nil, err
		}
		if g.me == nil && item.MemberId != nil && validUUID(*item.MemberId) {
			g.me = item.MemberId // only to pick the balance shown
		}
		groups = append(groups, g)
	}
	var err error
	if out.Groups, err = summarize(ctx, s.db, groups); err != nil {
		return nil, err
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
		err := row.Scan(&g.id, &g.token, &g.name, &g.emoji, &g.color, &g.currency, &g.symbol, &g.digits, &g.linkAccess, &g.createdAt, &me, &g.owner)
		g.me = &me
		return &g, err
	})
	if err != nil {
		return nil, err
	}
	out := GroupSummaryList{Missing: []string{}, Locked: []string{}}
	if out.Groups, err = summarize(ctx, s.db, groups); err != nil {
		return nil, err
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

// summarize builds the Home cards of groups, each with the balance of its
// me when that is one of its members. However many groups, it takes three
// queries.
func summarize(ctx context.Context, q querier, groups []*group) ([]GroupSummary, error) {
	out := make([]GroupSummary, len(groups))
	if len(groups) == 0 {
		return out, nil
	}
	ids := make([]string, len(groups))
	var withMe, mes []string
	for i, g := range groups {
		ids[i] = g.id
		if g.me != nil {
			withMe, mes = append(withMe, g.id), append(mes, *g.me)
		}
	}

	type stats struct {
		count   int
		updated *time.Time
	}
	byGroup := make(map[string]stats, len(groups))
	rows, err := q.Query(ctx, `
		select g.id::text,
		       (select count(*) from members m where m.group_id = g.id and m.left_at is null),
		       (select max(created_at) from activity_log a where a.group_id = g.id)
		from unnest($1::uuid[]) g(id)`, ids)
	if err != nil {
		return nil, err
	}
	var id string
	var st stats
	if _, err := pgx.ForEachRow(rows, []any{&id, &st.count, &st.updated}, func() error {
		byGroup[id] = st
		return nil
	}); err != nil {
		return nil, err
	}

	// The balance of each group's member, reached through the group's
	// expenses, which are indexed by group.
	balances := map[string]int64{}
	if len(withMe) > 0 {
		rows, err := q.Query(ctx, `
			select m.group_id::text,
			       coalesce((select sum(p.amount) from expenses e join expense_payers p on p.expense_id = e.id
			                 where e.group_id = m.group_id and e.deleted_at is null and p.member_id = m.id), 0)::bigint
			     - coalesce((select sum(x.amount) from expenses e join expense_splits x on x.expense_id = e.id
			                 where e.group_id = m.group_id and e.deleted_at is null and x.member_id = m.id), 0)::bigint
			from unnest($1::uuid[], $2::uuid[]) t(group_id, member_id)
			join members m on m.group_id = t.group_id and m.id = t.member_id`, withMe, mes)
		if err != nil {
			return nil, err
		}
		var net int64
		if _, err := pgx.ForEachRow(rows, []any{&id, &net}, func() error {
			balances[id] = net
			return nil
		}); err != nil {
			return nil, err
		}
	}

	for i, g := range groups {
		st := byGroup[g.id]
		sum := GroupSummary{
			Token:       g.token,
			Name:        g.name,
			Emoji:       g.emoji,
			Color:       g.color,
			Currency:    g.currency,
			Symbol:      g.symbol,
			MinorDigits: g.digits,
			MemberCount: st.count,
			UpdatedAt:   g.createdAt,
		}
		if st.updated != nil {
			sum.UpdatedAt = *st.updated
		}
		if net, ok := balances[g.id]; ok {
			b := domain.FormatAmount(net, g.digits)
			sum.Balance = &b
		}
		out[i] = sum
	}
	return out, nil
}

func (s *Server) GetGroup(ctx context.Context, req GetGroupRequestObject) (GetGroupResponseObject, error) {
	var out Group
	// One snapshot, so the members, balances and categories agree.
	err := s.groupSnapshot(ctx, req.Token, func(tx pgx.Tx, g *group) (err error) {
		out, err = loadGroup(ctx, tx, g)
		return err
	})
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
	symbol, err := cleanSymbol(in.Symbol)
	if err != nil {
		return nil, err
	}
	clearSymbol := in.Symbol != nil && symbol == nil
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
				link_access = coalesce($6, link_access),
				symbol = case when $8 then null else coalesce($7, symbol) end
			where id = $1
			returning `+groupColumns, g.id, name, emoji, clearEmoji, in.Color, linkAccess, symbol, clearSymbol))
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
		// Invitations hand out the link, so they would hand out the new one.
		if _, err := tx.Exec(ctx, `delete from invites where group_id = $1`, g.id); err != nil {
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
			// A group whose owner has gone may be deleted by any member; one
			// that no account is in any more, by anyone its link opens it for.
			var owned, claimed bool
			err := tx.QueryRow(ctx, `
				select exists (select 1 from members
				               where group_id = $1 and is_owner and user_id is not null and left_at is null),
				       exists (select 1 from members
				               where group_id = $1 and user_id is not null and left_at is null)`,
				g.id).Scan(&owned, &claimed)
			if err != nil {
				return err
			}
			if g.me == nil && (!g.open || claimed) {
				return forbidden("not_a_member")
			}
			if owned {
				return forbidden("owner_only")
			}
		}
		// Archived: gone for everyone, but kept for a while (see
		// archiveKeep) so a mistake, or a link holder's mischief, can be
		// undone by the administrator.
		if _, err := tx.Exec(ctx, `update groups set archived_at = now() where id = $1`, g.id); err != nil {
			return err
		}
		// Open apps reload and find it gone.
		_, err = tx.Exec(ctx, `select pg_notify($1, $2)`, changeChannel, g.id)
		return err
	})
	if err != nil {
		return nil, err
	}
	s.log.Info("group archived")
	return DeleteGroup204Response{}, nil
}
