package api

import (
	"context"
	"strconv"

	"github.com/jackc/pgx/v5"

	"balnana/internal/domain"
)

func (s *Server) GetBalances(ctx context.Context, req GetBalancesRequestObject) (GetBalancesResponseObject, error) {
	var g *group
	var members []member
	var nets map[string]int64
	// One snapshot, so every member a transfer names is in the list.
	err := s.groupSnapshot(ctx, req.Token, func(tx pgx.Tx, found *group) (err error) {
		g = found
		members, err = groupMembers(ctx, tx, g.id)
		if err != nil {
			return err
		}
		nets, err = groupNets(ctx, tx, g.id)
		return err
	})
	if err != nil {
		return nil, err
	}
	transfers, err := domain.Simplify(nets)
	if err != nil {
		return nil, err
	}
	out := Balances{Balances: []MemberBalance{}, Transfers: []Transfer{}}
	for _, m := range members {
		if m.left && nets[m.id] == 0 {
			continue
		}
		out.Balances = append(out.Balances, MemberBalance{MemberId: m.id, Amount: domain.FormatAmount(nets[m.id], g.digits)})
	}
	for _, t := range transfers {
		out.Transfers = append(out.Transfers, Transfer{FromMemberId: t.From, ToMemberId: t.To, Amount: domain.FormatAmount(t.Amount, g.digits)})
	}
	return GetBalances200JSONResponse(out), nil
}

func (s *Server) ListActivity(ctx context.Context, req ListActivityRequestObject) (ListActivityResponseObject, error) {
	g, err := s.groupByToken(ctx, s.db, req.Token, false)
	if err != nil {
		return nil, err
	}
	limit := pageSize(req.Params.Limit)
	var before *int64
	if req.Params.Cursor != nil && *req.Params.Cursor != "" {
		v, err := strconv.ParseInt(*req.Params.Cursor, 10, 64)
		if err != nil {
			return nil, badRequest("invalid_cursor")
		}
		before = &v
	}
	rows, err := s.db.Query(ctx, `
		select id, action, actor_member::text, subject_id::text, payload, created_at
		from activity_log
		where group_id = $1 and ($2::bigint is null or id < $2)
		order by id desc limit $3`, g.id, before, limit+1)
	if err != nil {
		return nil, err
	}
	var ids []int64
	items, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (Activity, error) {
		var a Activity
		var id int64
		err := row.Scan(&id, &a.Action, &a.ActorMemberId, &a.SubjectId, &a.Payload, &a.CreatedAt)
		a.Id = strconv.FormatInt(id, 10)
		ids = append(ids, id)
		return a, err
	})
	if err != nil {
		return nil, err
	}
	page := ActivityPage{Items: items}
	if len(items) > limit {
		page.Items = items[:limit]
		c := strconv.FormatInt(ids[limit-1], 10)
		page.NextCursor = &c
	}
	return ListActivity200JSONResponse(page), nil
}
