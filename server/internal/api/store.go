package api

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"net/http"
	"strings"
	"time"
	"unicode"
	"unicode/utf8"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"balnana/internal/config"
	"balnana/internal/domain"
)

// snapshot runs fn in a read-only transaction that sees the database as it
// was when it began, so the separate queries in it agree with each other.
func (s *Server) snapshot(ctx context.Context, fn func(pgx.Tx) error) error {
	return pgx.BeginTxFunc(ctx, s.db, pgx.TxOptions{IsoLevel: pgx.RepeatableRead, AccessMode: pgx.ReadOnly}, fn)
}

// querier is what both the pool and a transaction offer.
type querier interface {
	Exec(ctx context.Context, sql string, args ...any) (pgconn.CommandTag, error)
	Query(ctx context.Context, sql string, args ...any) (pgx.Rows, error)
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
}

// Limits on what people type. Lengths are in characters.
const (
	maxNameLen    = 100
	maxTitleLen   = 200
	maxNoteLen    = 2000
	maxEmojiLen   = 16
	maxMembers    = 100
	maxPageSize   = 200
	defaultPage   = 50
	tokenBytes    = 16
	tokenLen      = 22 // base64url of tokenBytes, no padding
	maxShareValue = 99_999_999_9999
)

// group is a row of the groups table, plus what the request may do in it.
type group struct {
	id         string
	token      string
	name       string
	emoji      *string
	color      *int
	currency   string
	digits     int
	linkAccess bool
	createdAt  time.Time

	open  bool    // the link alone opens the group
	me    *string // accounts mode: the signed-in account's member
	owner bool    // ...who owns the group
}

const groupColumns = `id::text, token, name, emoji, color, currency, minor_digits, link_access, created_at`

func scanGroup(row pgx.Row) (*group, error) {
	var g group
	err := row.Scan(&g.id, &g.token, &g.name, &g.emoji, &g.color, &g.currency, &g.digits, &g.linkAccess, &g.createdAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, errNotFound
	}
	if err != nil {
		return nil, err
	}
	return &g, nil
}

// findGroup finds a live group by token and works out who is asking, without
// checking they may see it. Pass lock to hold the row until the transaction
// ends, so concurrent writes to one group queue up.
func (s *Server) findGroup(ctx context.Context, q querier, token string, lock bool) (*group, error) {
	if !validToken(token) {
		noteMiss(ctx)
		return nil, errNotFound
	}
	sql := `select ` + groupColumns + ` from groups where token = $1 and archived_at is null`
	if lock {
		sql += ` for update`
	}
	g, err := scanGroup(q.QueryRow(ctx, sql, token))
	if err == errNotFound {
		noteMiss(ctx)
	}
	if err != nil {
		return nil, err
	}
	if err := s.resolveAccess(ctx, q, g); err != nil {
		return nil, err
	}
	return g, nil
}

// resolveAccess fills in g.open, g.me and g.owner for this request.
func (s *Server) resolveAccess(ctx context.Context, q querier, g *group) error {
	accounts := s.conf().AuthMode == config.AuthModeAccounts
	g.open = !accounts || s.conf().LinkGroups && g.linkAccess
	g.me, g.owner = nil, false
	if !accounts {
		return nil
	}
	u, err := s.currentUser(ctx)
	if err != nil || u == nil {
		return err
	}
	var id string
	err = q.QueryRow(ctx, `
		select id::text, is_owner from members
		where group_id = $1 and user_id = $2 and left_at is null`, g.id, u.id).Scan(&id, &g.owner)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil
	}
	if err != nil {
		return err
	}
	g.me = &id
	return nil
}

// groupByToken finds a group the request may use: in link mode, or with link
// access, the token is enough; otherwise the signed-in account must be a
// member.
func (s *Server) groupByToken(ctx context.Context, q querier, token string, lock bool) (*group, error) {
	g, err := s.findGroup(ctx, q, token, lock)
	if err != nil {
		return nil, err
	}
	if g.open || g.me != nil {
		return g, nil
	}
	if u, err := s.currentUser(ctx); err != nil {
		return nil, err
	} else if u == nil {
		return nil, &apiError{status: http.StatusUnauthorized, code: "sign_in_required"}
	}
	return nil, forbidden("not_a_member")
}

func newToken() string {
	b := make([]byte, tokenBytes)
	_, _ = rand.Read(b) // never fails
	return base64.RawURLEncoding.EncodeToString(b)
}

func validToken(t string) bool {
	if len(t) != tokenLen {
		return false
	}
	for _, c := range t {
		if !(c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c >= '0' && c <= '9' || c == '-' || c == '_') {
			return false
		}
	}
	return true
}

// validUUID accepts the canonical 8-4-4-4-12 hex form, so bad ids become a
// 404 instead of a database error.
func validUUID(s string) bool {
	if len(s) != 36 {
		return false
	}
	for i, c := range s {
		switch i {
		case 8, 13, 18, 23:
			if c != '-' {
				return false
			}
		default:
			if !(c >= '0' && c <= '9' || c >= 'a' && c <= 'f' || c >= 'A' && c <= 'F') {
				return false
			}
		}
	}
	return true
}

// cleanText trims s and checks its length. Control characters are refused.
func cleanText(s string, min, max int) (string, bool) {
	s = strings.TrimSpace(s)
	n := utf8.RuneCountInString(s)
	if n < min || n > max || !utf8.ValidString(s) {
		return "", false
	}
	for _, r := range s {
		if unicode.IsControl(r) && r != '\n' {
			return "", false
		}
	}
	return s, true
}

func cleanName(s string) (string, error) {
	name, ok := cleanText(s, 1, maxNameLen)
	if !ok || strings.Contains(name, "\n") {
		return "", badRequest("invalid_name")
	}
	return name, nil
}

func validColor(c *int) error {
	if c != nil && (*c < 0 || *c > 0xFFFFFF) {
		return badRequest("invalid_color")
	}
	return nil
}

// cleanEmoji returns nil for an empty value.
func cleanEmoji(e *string) (*string, error) {
	if e == nil {
		return nil, nil
	}
	v, ok := cleanText(*e, 0, maxEmojiLen)
	if !ok || strings.Contains(v, "\n") {
		return nil, badRequest("invalid_emoji")
	}
	if v == "" {
		return nil, nil
	}
	return &v, nil
}

// member is a row of the members table.
type member struct {
	id     string
	name   string
	color  *int
	left   bool
	owner  bool
	userID *string
}

func groupMembers(ctx context.Context, q querier, groupID string) ([]member, error) {
	rows, err := q.Query(ctx, `
		select id::text, display_name, color, left_at is not null, is_owner, user_id::text
		from members where group_id = $1 order by created_at, id`, groupID)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(row pgx.CollectableRow) (member, error) {
		var m member
		err := row.Scan(&m.id, &m.name, &m.color, &m.left, &m.owner, &m.userID)
		return m, err
	})
}

func findMember(members []member, id string) *member {
	for i := range members {
		if members[i].id == id {
			return &members[i]
		}
	}
	return nil
}

// groupNets returns each member's net balance in minor units: what they paid
// minus their share. Members without expenses are absent (zero).
func groupNets(ctx context.Context, q querier, groupID string) (map[string]int64, error) {
	rows, err := q.Query(ctx, `
		select member_id::text, sum(amount)::bigint from (
			select p.member_id, p.amount
			from expense_payers p join expenses e on e.id = p.expense_id
			where e.group_id = $1 and e.deleted_at is null
			union all
			select s.member_id, -s.amount
			from expense_splits s join expenses e on e.id = s.expense_id
			where e.group_id = $1 and e.deleted_at is null
		) t group by member_id`, groupID)
	if err != nil {
		return nil, err
	}
	nets := map[string]int64{}
	var id string
	var net int64
	_, err = pgx.ForEachRow(rows, []any{&id, &net}, func() error {
		nets[id] = net
		return nil
	})
	return nets, err
}

func toMember(m member, nets map[string]int64, digits int) Member {
	return Member{
		Id:      m.id,
		Name:    m.name,
		Color:   m.color,
		Left:    m.left,
		Owner:   m.owner,
		Claimed: m.userID != nil,
		Balance: domain.FormatAmount(nets[m.id], digits),
	}
}

// loadGroup builds the full Group response.
func loadGroup(ctx context.Context, q querier, g *group) (Group, error) {
	members, err := groupMembers(ctx, q, g.id)
	if err != nil {
		return Group{}, err
	}
	nets, err := groupNets(ctx, q, g.id)
	if err != nil {
		return Group{}, err
	}
	categories, err := groupCategories(ctx, q, g.id)
	if err != nil {
		return Group{}, err
	}
	out := Group{
		Token:       g.token,
		Name:        g.name,
		Emoji:       g.emoji,
		Color:       g.color,
		Currency:    g.currency,
		MinorDigits: g.digits,
		CreatedAt:   g.createdAt,
		Members:     make([]Member, 0, len(members)),
		Categories:  categories,
		LinkAccess:  g.open,
		MyMemberId:  g.me,
	}
	for _, m := range members {
		out.Members = append(out.Members, toMember(m, nets, g.digits))
	}
	return out, nil
}

// actor is who is acting in the group: the signed-in account's member, or
// else the member named by the X-Balnana-Member header (link rules), or nil.
func actor(ctx context.Context, q querier, g *group, header *string) (*string, error) {
	if g.me != nil {
		return g.me, nil
	}
	if header == nil || !validUUID(*header) {
		return nil, nil
	}
	var id string
	err := q.QueryRow(ctx, `select id::text from members where id = $1 and group_id = $2`, *header, g.id).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &id, nil
}

// logActivity records what happened. The payload holds names and amounts as
// they were, so the app can render the entry in any language later.
func logActivity(ctx context.Context, q querier, groupID string, actor *string, action string, subject *string, payload map[string]any) error {
	if payload == nil {
		payload = map[string]any{}
	}
	_, err := q.Exec(ctx, `
		insert into activity_log (group_id, actor_member, action, subject_id, payload)
		values ($1, $2, $3, $4, $5)`, groupID, actor, action, subject, payload)
	return err
}

func pageSize(limit *int) int {
	switch {
	case limit == nil:
		return defaultPage
	case *limit < 1:
		return 1
	case *limit > maxPageSize:
		return maxPageSize
	}
	return *limit
}
