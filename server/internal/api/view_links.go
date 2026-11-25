package api

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"sort"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"balnana/internal/domain"
)

// A view-only link shows a group to anyone who has it, without letting them
// change anything: live, or a snapshot of the group as it was when the link
// was made. A group has at most one. Members manage it under /g/{token}; the
// link itself opens /v/{viewToken}, which ignores sessions, acting members
// and group keys: making the link was the members' decision to show the group.

// maxViewSnapshot bounds a snapshot's document, serialized.
var maxViewSnapshot = 8 << 20

var (
	errViewExpired = &apiError{status: http.StatusGone, code: "view_link_expired"}
	errViewPaused  = &apiError{status: http.StatusForbidden, code: "view_link_paused"}
)

// viewLink is a row of the view_links table, without the snapshot.
type viewLink struct {
	id         string
	token      string
	show       ViewLinkShow
	snapshotAt *time.Time // nil for a live link
	createdAt  time.Time
	expiresAt  *time.Time
	viewedAt   *time.Time
}

const viewLinkColumns = `id::text, token, show_balances, show_expenses, show_spending, show_notes, show_places, ` +
	`show_receipts, snapshot_at, created_at, expires_at, last_viewed_at`

func (l *viewLink) columns(more ...any) []any {
	s := &l.show
	return append([]any{&l.id, &l.token, &s.Balances, &s.Expenses, &s.Spending, &s.Notes, &s.Places, &s.Receipts,
		&l.snapshotAt, &l.createdAt, &l.expiresAt, &l.viewedAt}, more...)
}

func (l *viewLink) live() bool { return l.snapshotAt == nil }

// groupViewLink is g's link, or nil.
func groupViewLink(ctx context.Context, q querier, groupID string, lock bool) (*viewLink, error) {
	sql := `select ` + viewLinkColumns + ` from view_links where group_id = $1`
	if lock {
		sql += ` for update`
	}
	var l viewLink
	err := q.QueryRow(ctx, sql, groupID).Scan(l.columns()...)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &l, nil
}

// viewLinkAllowed reports whether g's plan includes a view-only link. Without
// billing every group may have one.
func (s *Server) viewLinkAllowed(ctx context.Context, q querier, g *group) (bool, error) {
	if !s.conf().Billing {
		return true, nil
	}
	p, _, err := groupPlan(ctx, q, g)
	if err != nil {
		return false, err
	}
	return p.viewLink, nil
}

func (s *Server) toViewLink(ctx context.Context, q querier, g *group, l *viewLink) (ViewLink, error) {
	allowed, err := s.viewLinkAllowed(ctx, q, g)
	return ViewLink{
		Token:        l.token,
		Live:         l.live(),
		SnapshotAt:   l.snapshotAt,
		Show:         l.show,
		CreatedAt:    l.createdAt,
		ExpiresAt:    l.expiresAt,
		LastViewedAt: l.viewedAt,
		Paused:       !allowed,
	}, err
}

// checkShow refuses settings that show nothing but the header, or receipts
// in a snapshot, which has no photos.
func checkShow(show ViewLinkShow, live bool) error {
	if !show.Balances && !show.Expenses && !show.Spending || show.Receipts && !live {
		return badRequest("invalid_show")
	}
	return nil
}

// sameTime reports whether a and b are both unset or the same instant.
func sameTime(a, b *time.Time) bool {
	return a == nil && b == nil || a != nil && b != nil && a.Equal(*b)
}

func checkExpiry(at *time.Time) error {
	if at != nil && !at.After(time.Now()) {
		return badRequest("invalid_expiry")
	}
	return nil
}

func (s *Server) GetViewLink(ctx context.Context, req GetViewLinkRequestObject) (GetViewLinkResponseObject, error) {
	var out ViewLinkState
	err := s.groupSnapshot(ctx, req.Token, func(tx pgx.Tx, g *group) error {
		l, err := groupViewLink(ctx, tx, g.id, false)
		if err != nil || l == nil {
			return err
		}
		link, err := s.toViewLink(ctx, tx, g, l)
		out.Link = &link
		return err
	})
	if err != nil {
		return nil, err
	}
	return GetViewLink200JSONResponse(out), nil
}

func (s *Server) CreateViewLink(ctx context.Context, req CreateViewLinkRequestObject) (CreateViewLinkResponseObject, error) {
	in := req.Body
	if err := checkShow(in.Show, in.Live); err != nil {
		return nil, err
	}
	if err := checkExpiry(in.ExpiresAt); err != nil {
		return nil, err
	}
	var out ViewLink
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		// The group stays locked, so no expense changes while a snapshot
		// reads it.
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		if err := s.mayManage(ctx, tx, g); err != nil {
			return err
		}
		if allowed, err := s.viewLinkAllowed(ctx, tx, g); err != nil {
			return err
		} else if !allowed {
			return planLimit("viewLink", 0)
		}
		if l, err := groupViewLink(ctx, tx, g.id, false); err != nil {
			return err
		} else if l != nil {
			return conflict("view_link_exists")
		}
		var doc []byte
		if !in.Live {
			if doc, err = buildViewSnapshot(ctx, tx, g, in.Show); err != nil {
				return err
			}
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		var l viewLink
		sh := in.Show
		err = tx.QueryRow(ctx, `
			insert into view_links (group_id, token, show_balances, show_expenses, show_spending, show_notes, show_places,
				show_receipts, snapshot, snapshot_at, expires_at)
			values ($1, $2, $3, $4, $5, $6, $7, $8, $9, case when $9::jsonb is null then null else now() end, $10)
			returning `+viewLinkColumns,
			g.id, newToken(), sh.Balances, sh.Expenses, sh.Spending, sh.Notes, sh.Places, sh.Receipts, doc, in.ExpiresAt).
			Scan(l.columns()...)
		if pgErr := (*pgconn.PgError)(nil); errors.As(err, &pgErr) && pgErr.Code == "23505" {
			return conflict("view_link_exists")
		} else if err != nil {
			return err
		}
		payload := map[string]any{"name": g.name, "live": in.Live}
		if err := logActivity(ctx, tx, g.id, who, "group.view_link_created", nil, payload); err != nil {
			return err
		}
		out, err = s.toViewLink(ctx, tx, g, &l)
		return err
	})
	if err != nil {
		return nil, err
	}
	return CreateViewLink201JSONResponse(out), nil
}

// UpdateViewLink changes what the link shows and when it ends, also while it
// is paused.
func (s *Server) UpdateViewLink(ctx context.Context, req UpdateViewLinkRequestObject) (UpdateViewLinkResponseObject, error) {
	in := req.Body
	var out ViewLink
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		if err := s.mayManage(ctx, tx, g); err != nil {
			return err
		}
		l, err := groupViewLink(ctx, tx, g.id, true)
		if err != nil {
			return err
		}
		if l == nil {
			return errNotFound
		}
		if err := checkShow(in.Show, l.live()); err != nil {
			return err
		}
		// A snapshot has no notes or places it does not show: what it left
		// out cannot come back.
		if !l.live() && (in.Show.Notes && !l.show.Notes || in.Show.Places && !l.show.Places) {
			return badRequest("invalid_show")
		}
		// An end date kept as it was may have passed: the link's other
		// settings still change.
		if !sameTime(in.ExpiresAt, l.expiresAt) {
			if err := checkExpiry(in.ExpiresAt); err != nil {
				return err
			}
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		sh := in.Show
		var drop []string
		if !l.live() && l.show.Notes && !sh.Notes {
			drop = append(drop, "note")
		}
		if !l.live() && l.show.Places && !sh.Places {
			drop = append(drop, "location")
		}
		err = tx.QueryRow(ctx, `
			update view_links set show_balances = $2, show_expenses = $3, show_spending = $4, show_notes = $5,
				show_places = $6, show_receipts = $7, expires_at = $8,
				snapshot = case when snapshot is null or cardinality($9::text[]) = 0 then snapshot
					else jsonb_set(snapshot, '{expenses}', (
						select coalesce(jsonb_agg(x - $9::text[] order by i), '[]'::jsonb)
						from jsonb_array_elements(snapshot->'expenses') with ordinality t(x, i)))
					end
			where id = $1
			returning `+viewLinkColumns,
			l.id, sh.Balances, sh.Expenses, sh.Spending, sh.Notes, sh.Places, sh.Receipts, in.ExpiresAt, drop).
			Scan(l.columns()...)
		if err != nil {
			return err
		}
		if err := logActivity(ctx, tx, g.id, who, "group.view_link_changed", nil, map[string]any{"name": g.name}); err != nil {
			return err
		}
		out, err = s.toViewLink(ctx, tx, g, l)
		return err
	})
	if err != nil {
		return nil, err
	}
	return UpdateViewLink200JSONResponse(out), nil
}

// DeleteViewLink revokes the link, and a snapshot's data with it. Revoking a
// link that is gone already succeeds.
func (s *Server) DeleteViewLink(ctx context.Context, req DeleteViewLinkRequestObject) (DeleteViewLinkResponseObject, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		if err := s.mayManage(ctx, tx, g); err != nil {
			return err
		}
		tag, err := tx.Exec(ctx, `delete from view_links where group_id = $1`, g.id)
		if err != nil || tag.RowsAffected() == 0 {
			return err
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		return logActivity(ctx, tx, g.id, who, "group.view_link_revoked", nil, map[string]any{"name": g.name})
	})
	if err != nil {
		return nil, err
	}
	return DeleteViewLink204Response{}, nil
}

// viewSnapshot is the document a snapshot stores: the group as it was, with
// notes and places only while the link shows them. What the settings hide is
// left out when it is read.
type viewSnapshot struct {
	Version    int                  `json:"version"`
	Name       string               `json:"name"`
	Emoji      *string              `json:"emoji,omitempty"`
	Color      *int                 `json:"color,omitempty"`
	Currency   string               `json:"currency"`
	Symbol     *string              `json:"symbol,omitempty"`
	Digits     int                  `json:"minorDigits"`
	Members    []viewSnapshotMember `json:"members"`
	Categories []Category           `json:"categories"`
	// Live expenses with notes and places, newest first as /expenses lists
	// them.
	Expenses []ViewExpense `json:"expenses"`
}

type viewSnapshotMember struct {
	Id    string `json:"id"`
	Name  string `json:"name"`
	Color *int   `json:"color,omitempty"`
	Left  bool   `json:"left"`
	Net   int64  `json:"net"` // minor units
}

// buildViewSnapshot reads g, which the transaction has locked, into a
// snapshot's document, with notes and places only when show has them.
func buildViewSnapshot(ctx context.Context, q querier, g *group, show ViewLinkShow) ([]byte, error) {
	members, err := groupMembers(ctx, q, g.id)
	if err != nil {
		return nil, err
	}
	nets, err := groupNets(ctx, q, g.id)
	if err != nil {
		return nil, err
	}
	categories, err := groupCategories(ctx, q, g.id)
	if err != nil {
		return nil, err
	}
	expenses, err := loadExpenses(ctx, q, g.digits, `
		select `+expenseColumns+` from expenses
		where group_id = $1 and deleted_at is null
		order by occurred_at desc, id desc`, g.id)
	if err != nil {
		return nil, err
	}
	d := viewSnapshot{
		Version:    1,
		Name:       g.name,
		Emoji:      g.emoji,
		Color:      g.color,
		Currency:   g.currency,
		Symbol:     g.symbol,
		Digits:     g.digits,
		Members:    make([]viewSnapshotMember, 0, len(members)),
		Categories: categories,
		Expenses:   make([]ViewExpense, 0, len(expenses)),
	}
	for _, m := range members {
		d.Members = append(d.Members, viewSnapshotMember{Id: m.id, Name: m.name, Color: m.color, Left: m.left, Net: nets[m.id]})
	}
	kept := ViewLinkShow{Notes: show.Notes, Places: show.Places}
	for _, e := range expenses {
		v := toViewExpense(e, kept)
		v.HasReceipt = false
		d.Expenses = append(d.Expenses, v)
	}
	// The order paging relies on, whatever the database's collation.
	sort.SliceStable(d.Expenses, func(i, j int) bool { return newerExpense(&d.Expenses[i], &d.Expenses[j]) })
	raw, err := json.Marshal(d)
	if err != nil {
		return nil, err
	}
	if len(raw) > maxViewSnapshot {
		return nil, &apiError{status: http.StatusRequestEntityTooLarge, code: "too_large"}
	}
	return raw, nil
}

func newerExpense(a, b *ViewExpense) bool {
	if !a.OccurredAt.Equal(b.OccurredAt) {
		return a.OccurredAt.After(b.OccurredAt)
	}
	return a.Id > b.Id
}

// toViewExpense is e as a link that shows show sees it: never who added it.
func toViewExpense(e Expense, show ViewLinkShow) ViewExpense {
	v := ViewExpense{
		Id:              e.Id,
		TransactionType: ViewExpenseTransactionType(e.TransactionType),
		Title:           e.Title,
		CategoryId:      e.CategoryId,
		Amount:          e.Amount,
		OccurredAt:      e.OccurredAt,
		SplitMethod:     e.SplitMethod,
		Payers:          e.Payers,
		Splits:          e.Splits,
		CreatedAt:       e.CreatedAt,
		UpdatedAt:       e.UpdatedAt,
		HasReceipt:      show.Receipts && e.HasReceipt,
		Foreign:         e.Foreign,
	}
	if show.Notes {
		v.Note = e.Note
	}
	if show.Places {
		v.Location = e.Location
	}
	return v
}

// hideExpense leaves out of a snapshot's expense what show hides.
func hideExpense(v ViewExpense, show ViewLinkShow) ViewExpense {
	if !show.Notes {
		v.Note = nil
	}
	if !show.Places {
		v.Location = nil
	}
	v.HasReceipt = false
	return v
}

// openView finds the link a view token names and the group it shows, and
// checks it works now. With doc, it also reads a snapshot's document. What
// the link shows comes back as it applies: notes, places and receipts only
// with expenses, and receipts only live, in a group that keeps them.
func (s *Server) openView(ctx context.Context, token string, doc bool) (*viewLink, *group, *viewSnapshot, error) {
	if !validToken(token) {
		noteMiss(ctx)
		return nil, nil, nil, errNotFound
	}
	snapshot := `null::jsonb`
	if doc {
		snapshot = `l.snapshot`
	}
	// Whether the group's plan includes the link, as viewLinkAllowed finds
	// it, in the same query.
	allowed := `true`
	if s.conf().Billing {
		allowed = `coalesce((` + userPlanQuery(`p.view_link`, `sp.user_id`) + `), false)`
	}
	var l viewLink
	var g group
	var raw []byte
	var ok bool
	err := s.db.QueryRow(ctx, `
		select `+prefixed("l.", viewLinkColumns)+`, `+prefixed("g.", groupColumns)+`, `+snapshot+`, `+allowed+`
		from view_links l join groups g on g.id = l.group_id
		left join members sp on sp.group_id = g.id and sp.user_id = g.sponsor_user_id and sp.left_at is null
		where l.token = $1 and g.archived_at is null`, token).Scan(l.columns(g.columns(&raw, &ok)...)...)
	if errors.Is(err, pgx.ErrNoRows) {
		noteMiss(ctx)
		return nil, nil, nil, errNotFound
	}
	if err != nil {
		return nil, nil, nil, err
	}
	if l.expiresAt != nil && !l.expiresAt.After(time.Now()) {
		return nil, nil, nil, errViewExpired
	}
	if !ok {
		return nil, nil, nil, errViewPaused
	}
	sh := &l.show
	if !sh.Expenses {
		sh.Notes, sh.Places, sh.Receipts = false, false, false
	}
	if !l.live() || !g.features.Receipts {
		sh.Receipts = false
	}
	var d *viewSnapshot
	if raw != nil {
		d = new(viewSnapshot)
		if err := json.Unmarshal(raw, d); err != nil {
			return nil, nil, nil, err
		}
	}
	return &l, &g, d, nil
}

func (s *Server) GetView(ctx context.Context, req GetViewRequestObject) (GetViewResponseObject, error) {
	l, g, d, err := s.openView(ctx, req.ViewToken, true)
	if err != nil {
		return nil, err
	}
	out := ViewGroup{Live: l.live(), AsOf: l.snapshotAt, Show: l.show, Members: []ViewMember{}}
	var members []viewSnapshotMember
	if d != nil {
		out.Name, out.Emoji, out.Color, out.Currency, out.Symbol, out.MinorDigits =
			d.Name, d.Emoji, d.Color, d.Currency, d.Symbol, d.Digits
		out.Categories, members = d.Categories, d.Members
	} else {
		out.Name, out.Emoji, out.Color, out.Currency, out.Symbol, out.MinorDigits =
			g.name, g.emoji, g.color, g.currency, g.symbol, g.digits
		err := s.snapshot(ctx, func(tx pgx.Tx) error {
			list, err := groupMembers(ctx, tx, g.id)
			if err != nil {
				return err
			}
			nets, err := groupNets(ctx, tx, g.id)
			if err != nil {
				return err
			}
			for _, m := range list {
				members = append(members, viewSnapshotMember{Id: m.id, Name: m.name, Color: m.color, Left: m.left, Net: nets[m.id]})
			}
			out.Categories, err = groupCategories(ctx, tx, g.id)
			return err
		})
		if err != nil {
			return nil, err
		}
	}
	if out.Categories == nil {
		out.Categories = []Category{}
	}
	nets := map[string]int64{}
	for _, m := range members {
		v := ViewMember{Id: m.Id, Name: m.Name, Color: m.Color, Left: m.Left}
		if l.show.Balances {
			b := domain.FormatAmount(m.Net, out.MinorDigits)
			v.Balance, nets[m.Id] = &b, m.Net
		}
		out.Members = append(out.Members, v)
	}
	if l.show.Balances {
		transfers, err := domain.Simplify(nets)
		if err != nil {
			return nil, err
		}
		list := make([]Transfer, 0, len(transfers))
		for _, t := range transfers {
			list = append(list, Transfer{FromMemberId: t.From, ToMemberId: t.To, Amount: domain.FormatAmount(t.Amount, out.MinorDigits)})
		}
		out.Transfers = &list
	}
	// When it was last opened, to the hour: one write an hour at most.
	hour := time.Now().UTC().Truncate(time.Hour)
	if l.viewedAt == nil || l.viewedAt.Before(hour) {
		_, err := s.db.Exec(ctx, `
			update view_links set last_viewed_at = $2
			where id = $1 and (last_viewed_at is null or last_viewed_at < $2)`, l.id, hour)
		if err != nil {
			// Only bookkeeping: the group shows all the same.
			s.log.WarnContext(ctx, "view link not marked as opened", "err", err)
		}
	}
	return GetView200JSONResponse(out), nil
}

func (s *Server) ListViewExpenses(ctx context.Context, req ListViewExpensesRequestObject) (ListViewExpensesResponseObject, error) {
	l, g, d, err := s.openView(ctx, req.ViewToken, true)
	if err != nil {
		return nil, err
	}
	if !l.show.Expenses {
		return nil, errNotFound
	}
	p := req.Params
	f := expenseFilter{q: p.Q, member: p.Member, category: p.Category, from: p.From, to: p.To,
		noNotes: !l.show.Notes, noPlaces: !l.show.Places}
	if d != nil {
		out, err := d.page(f, p.Cursor, p.Limit, l.show)
		if err != nil {
			return nil, err
		}
		return ListViewExpenses200JSONResponse(out), nil
	}
	page, err := s.expensePage(ctx, g, f, p.Cursor, p.Limit)
	if err != nil {
		return nil, err
	}
	out := ViewExpensePage{Items: make([]ViewExpense, 0, len(page.Items)), NextCursor: page.NextCursor}
	for _, e := range page.Items {
		out.Items = append(out.Items, toViewExpense(e, l.show))
	}
	return ListViewExpenses200JSONResponse(out), nil
}

func (s *Server) GetViewStats(ctx context.Context, req GetViewStatsRequestObject) (GetViewStatsResponseObject, error) {
	zone, err := readerZone(nil, req.Params.TimeZone)
	if err != nil {
		return nil, err
	}
	l, g, d, err := s.openView(ctx, req.ViewToken, true)
	if err != nil {
		return nil, err
	}
	if !l.show.Spending {
		return nil, errNotFound
	}
	var out GroupStats
	if d != nil {
		out, err = d.stats(req.Params.From, req.Params.To, zone)
	} else {
		out, err = s.groupStats(ctx, g, req.Params.From, req.Params.To, zone)
	}
	if err != nil {
		return nil, err
	}
	return GetViewStats200JSONResponse(out), nil
}

func (s *Server) GetViewReceipt(ctx context.Context, req GetViewReceiptRequestObject) (GetViewReceiptResponseObject, error) {
	l, g, _, err := s.openView(ctx, req.ViewToken, false)
	if err != nil {
		return nil, err
	}
	if !l.show.Receipts {
		return nil, errNotFound
	}
	data, err := s.receiptPhoto(ctx, g.id, req.ExpenseId)
	if err != nil {
		return nil, err
	}
	return GetViewReceipt200ImagejpegResponse{Body: bytes.NewReader(data), ContentLength: int64(len(data))}, nil
}

// filter is the snapshot's expenses that f lets through, as the expenseFilter
// SQL would find them in the group, newest first.
func (d *viewSnapshot) filter(f expenseFilter) ([]ViewExpense, error) {
	var q string
	if f.q != nil {
		q = strings.ToLower(strings.TrimSpace(*f.q))
	}
	var member string
	if f.member != nil && *f.member != "" {
		if !validUUID(*f.member) {
			return nil, badRequest("invalid_member")
		}
		member = strings.ToLower(*f.member)
	}
	has := func(s *string) bool { return s != nil && strings.Contains(strings.ToLower(*s), q) }
	var out []ViewExpense
	for _, e := range d.Expenses {
		if q != "" && !has(&e.Title) && (f.noNotes || !has(e.Note)) &&
			(f.noPlaces || e.Location == nil || !has(e.Location.Name)) {
			continue
		}
		if member != "" && !hasMember(e, member) {
			continue
		}
		if f.category != nil && *f.category != "" && (e.CategoryId == nil || *e.CategoryId != *f.category) {
			continue
		}
		if f.from != nil && e.OccurredAt.Before(*f.from) || f.to != nil && !e.OccurredAt.Before(*f.to) {
			continue
		}
		out = append(out, e)
	}
	return out, nil
}

func hasMember(e ViewExpense, member string) bool {
	for _, p := range e.Payers {
		if p.MemberId == member {
			return true
		}
	}
	for _, p := range e.Splits {
		if p.MemberId == member {
			return true
		}
	}
	return false
}

// page is a page of the snapshot's expenses, with the cursors /expenses uses.
func (d *viewSnapshot) page(f expenseFilter, cursor *string, size *int, show ViewLinkShow) (ViewExpensePage, error) {
	limit := pageSize(size)
	list, err := d.filter(f)
	if err != nil {
		return ViewExpensePage{}, err
	}
	if cursor != nil && *cursor != "" {
		at, id, err := decodeExpenseCursor(*cursor)
		if err != nil {
			return ViewExpensePage{}, err
		}
		after := ViewExpense{OccurredAt: at, Id: strings.ToLower(id)}
		list = list[sort.Search(len(list), func(i int) bool { return newerExpense(&after, &list[i]) }):]
	}
	out := ViewExpensePage{Items: make([]ViewExpense, 0, min(limit, len(list)))}
	for _, e := range list[:min(limit, len(list))] {
		out.Items = append(out.Items, hideExpense(e, show))
	}
	if len(list) > limit {
		c := expenseCursor(list[limit-1].OccurredAt, list[limit-1].Id)
		out.NextCursor = &c
	}
	return out, nil
}

// stats sums up the snapshot as groupStats sums up a group.
func (d *viewSnapshot) stats(from, to *time.Time, zone *time.Location) (GroupStats, error) {
	list, err := d.filter(expenseFilter{from: from, to: to})
	if err != nil {
		return GroupStats{}, err
	}
	type category struct {
		id     *string
		amount int64
		count  int
	}
	var total int64
	var count int
	categories := map[string]*category{}
	paid, share, parts := map[string]int64{}, map[string]int64{}, map[string]bool{}
	months := map[string]int64{}
	amount := func(m Money) (int64, error) { return domain.ParseAmount(m, d.Digits) }
	for _, e := range list {
		if e.TransactionType == ViewExpenseTransactionTypeIncome || e.CategoryId != nil && *e.CategoryId == categoryTransfer {
			continue
		}
		refund := e.TransactionType == ViewExpenseTransactionTypeRefund
		sign := int64(1)
		if refund {
			sign = -1
		}
		a, err := amount(e.Amount)
		if err != nil {
			return GroupStats{}, err
		}
		total += sign * a
		count++
		key := "\x00" // no category
		if e.CategoryId != nil {
			key = *e.CategoryId
		}
		c := categories[key]
		if c == nil {
			c = &category{id: e.CategoryId}
			categories[key] = c
		}
		c.amount += sign * a
		c.count++
		months[e.OccurredAt.In(zone).Format("2006-01")] += sign * a
		// A refund pays back: its payers' shares and its splits' payments
		// go down.
		for _, p := range e.Payers {
			a, err := amount(p.Amount)
			if err != nil {
				return GroupStats{}, err
			}
			parts[p.MemberId] = true
			if refund {
				share[p.MemberId] -= a
			} else {
				paid[p.MemberId] += a
			}
		}
		for _, p := range e.Splits {
			a, err := amount(p.Amount)
			if err != nil {
				return GroupStats{}, err
			}
			parts[p.MemberId] = true
			if refund {
				paid[p.MemberId] -= a
			} else {
				share[p.MemberId] += a
			}
		}
	}
	out := GroupStats{
		Total:      domain.FormatAmount(total, d.Digits),
		Count:      count,
		Categories: make([]CategoryStats, 0, len(categories)),
		Members:    []MemberStats{},
		Months:     make([]MonthStats, 0, len(months)),
	}
	sorted := make([]*category, 0, len(categories))
	for _, c := range categories {
		sorted = append(sorted, c)
	}
	sort.Slice(sorted, func(i, j int) bool {
		a, b := sorted[i], sorted[j]
		switch {
		case a.amount != b.amount:
			return a.amount > b.amount
		case a.id == nil || b.id == nil:
			return b.id == nil && a.id != nil
		}
		return *a.id < *b.id
	})
	for _, c := range sorted {
		out.Categories = append(out.Categories, CategoryStats{CategoryId: c.id, Amount: domain.FormatAmount(c.amount, d.Digits), Count: c.count})
	}
	for _, m := range d.Members {
		if parts[m.Id] {
			out.Members = append(out.Members, MemberStats{MemberId: m.Id, Paid: domain.FormatAmount(paid[m.Id], d.Digits),
				Share: domain.FormatAmount(share[m.Id], d.Digits)})
		}
	}
	for month, a := range months {
		out.Months = append(out.Months, MonthStats{Month: month, Amount: domain.FormatAmount(a, d.Digits)})
	}
	sort.Slice(out.Months, func(i, j int) bool { return out.Months[i].Month < out.Months[j].Month })
	return out, nil
}
