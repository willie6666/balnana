package api

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"time"
	"unicode"
	"unicode/utf8"

	"github.com/jackc/pgx/v5"

	"balnana/internal/config"
	"balnana/internal/push"
)

// Push notifications: phones register the Web Push subscription their
// UnifiedPush distributor gave them, under an ID of their own (migrations
// 00006 and 00013), and after an expense changes, the members it involves
// hear about it on every phone they registered, except whoever made the
// change. A phone following a group by link hears only while that link
// works (migration 00007).

const (
	minDeviceID = 16
	maxDeviceID = 128
	// Phones register again on every start; one silent this long is gone.
	deviceKeep = 90 * 24 * time.Hour
	// Phones a group may have following it. Every change to it is a message
	// to each, from this server's address, so a client registering made-up
	// phones must not be able to make that unbounded.
	maxGroupDevices = 200
	pushTimeout     = 30 * time.Second
	// pushTTL is how long a push service keeps a message for a phone that
	// is offline.
	pushTTL = 24 * time.Hour
	// maxPushText caps each name and title a message carries, in characters,
	// so every message fits in one push.
	maxPushText = 100
	// maxPushParallel caps the messages one change sends at once.
	maxPushParallel = 8
)

// StartPush loads the server's VAPID key, making it the first time, and
// starts sending push notifications.
func (s *Server) StartPush(ctx context.Context) error {
	fresh, err := push.NewKey()
	if err != nil {
		return err
	}
	// Servers sharing the database may start together: the first key saved
	// is the one they all use.
	if _, err := s.db.Exec(ctx, `insert into vapid (private_key) values ($1) on conflict do nothing`, fresh.Bytes()); err != nil {
		return fmt.Errorf("push: saving the VAPID key: %w", err)
	}
	var saved []byte
	if err := s.db.QueryRow(ctx, `select private_key from vapid`).Scan(&saved); err != nil {
		return fmt.Errorf("push: loading the VAPID key: %w", err)
	}
	key, err := push.ParseKey(saved)
	if err != nil {
		return err
	}
	s.push = push.NewWebPush(key, s.pushSubject, s.conf().PushPrivateEndpoints)
	s.vapid = key.Public()
	return nil
}

// pushSubject is how a push service can reach whoever runs the server, as
// VAPID asks: the server's own address when it is https.
func (s *Server) pushSubject() string {
	cfg := s.conf()
	for _, u := range []*url.URL{cfg.PublicURL, cfg.SourceURL} {
		if u != nil && u.Scheme == "https" {
			return u.String()
		}
	}
	return config.UpstreamSourceURL
}

func validDeviceID(id string) bool {
	if len(id) < minDeviceID || len(id) > maxDeviceID {
		return false
	}
	for _, c := range id {
		if !('a' <= c && c <= 'z' || 'A' <= c && c <= 'Z' || '0' <= c && c <= '9' || c == '-' || c == '_') {
			return false
		}
	}
	return true
}

func (s *Server) RegisterPushDevice(ctx context.Context, req RegisterPushDeviceRequestObject) (RegisterPushDeviceResponseObject, error) {
	if s.push == nil {
		return nil, &apiError{status: http.StatusNotFound, code: "push_off"}
	}
	if !validDeviceID(req.Device) {
		return nil, badRequest("invalid_device")
	}
	sub := push.Subscription{Endpoint: req.Body.Endpoint, P256dh: req.Body.P256dh, Auth: req.Body.Auth}
	if push.Check(sub, s.conf().PushPrivateEndpoints) != nil {
		return nil, badRequest("invalid_subscription")
	}
	if len(req.Body.Groups) > maxPageSize {
		return nil, badRequest("too_many_groups")
	}
	var session *string
	if u, err := s.currentUser(ctx); err != nil {
		return nil, err
	} else if u != nil {
		session = &u.sessionID
	}
	var known bool
	if err := s.db.QueryRow(ctx, `select exists (select 1 from push_devices where token = $1)`, req.Device).Scan(&known); err != nil {
		return nil, err
	}
	if !known {
		if err := s.limitDevices(ctx); err != nil {
			return nil, err
		}
	}
	type follow struct{ group, member, link string }
	var follows []follow
	for _, item := range req.Body.Groups {
		g, err := s.findGroup(ctx, s.db, item.Token, false)
		var ae *apiError
		if errors.As(err, &ae) && ae.status >= 400 && ae.status < 500 {
			continue
		}
		if err != nil {
			return nil, err
		}
		if !g.open || !validUUID(item.MemberId) {
			continue
		}
		var ok bool
		err = s.db.QueryRow(ctx, `
			select exists (select 1 from members where id = $1 and group_id = $2 and left_at is null)`,
			item.MemberId, g.id).Scan(&ok)
		if err != nil {
			return nil, err
		}
		if ok {
			follows = append(follows, follow{g.id, item.MemberId, item.Token})
		}
	}
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		_, err := tx.Exec(ctx, `
			insert into push_devices (token, session_id, endpoint, p256dh, auth) values ($1, $2, $3, $4, $5)
			on conflict (token) do update set session_id = excluded.session_id, endpoint = excluded.endpoint,
				p256dh = excluded.p256dh, auth = excluded.auth, updated_at = now()`,
			req.Device, session, sub.Endpoint, sub.P256dh, sub.Auth)
		if err != nil {
			return err
		}
		// An app that lost its ID registers again under a new one; the
		// subscription is still the same phone.
		if _, err := tx.Exec(ctx, `delete from push_devices where endpoint = $1 and token <> $2`, sub.Endpoint, req.Device); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `delete from push_follows where device = $1`, req.Device); err != nil {
			return err
		}
		for _, f := range follows {
			// A group already full keeps the phones that came first.
			_, err := tx.Exec(ctx, `
				insert into push_follows (device, group_id, member_id, link_token)
				select $1, $2, $3, $4
				where (select count(*) from push_follows where group_id = $2) < $5
				on conflict do nothing`, req.Device, f.group, f.member, f.link, maxGroupDevices)
			if err != nil {
				return err
			}
		}
		_, err = tx.Exec(ctx, `delete from push_devices where updated_at < $1`, time.Now().Add(-deviceKeep))
		return err
	})
	if err != nil {
		return nil, err
	}
	return RegisterPushDevice204Response{}, nil
}

func (s *Server) RemovePushDevice(ctx context.Context, req RemovePushDeviceRequestObject) (RemovePushDeviceResponseObject, error) {
	if _, err := s.db.Exec(ctx, `delete from push_devices where token = $1`, req.Device); err != nil {
		return nil, err
	}
	return RemovePushDevice204Response{}, nil
}

// FinishPushes waits for the notifications still being sent.
func (s *Server) FinishPushes() { s.pushing.Wait() }

// notifyExpense tells the phones of the members e involves, and of those in
// earlier (whom an edit took out of it), about action ("added", "edited" or
// "deleted"), leaving out who made the change. It runs after the change is
// committed, in the background, and never fails it.
func (s *Server) notifyExpense(g *group, who *string, action string, e Expense, earlier ...string) {
	if s.push == nil {
		return
	}
	s.pushing.Add(1)
	go func() {
		defer s.pushing.Done()
		ctx, cancel := context.WithTimeout(context.Background(), pushTimeout)
		defer cancel()
		if err := s.sendExpense(ctx, g, who, action, e, earlier); err != nil {
			s.log.Warn("push failed", "group", g.id, "err", err)
		}
	}()
}

func (s *Server) sendExpense(ctx context.Context, g *group, who *string, action string, e Expense,
	earlier []string) error {
	if e.Kind == ExpenseKindPayment && action != "added" {
		return nil
	}
	involved := map[string]bool{}
	for _, id := range earlier {
		involved[id] = true
	}
	for _, p := range e.Payers {
		involved[p.MemberId] = true
	}
	for _, p := range e.Splits {
		involved[p.MemberId] = true
	}
	if who != nil {
		delete(involved, *who)
	}
	if len(involved) == 0 {
		return nil
	}
	ids := make([]string, 0, len(involved))
	for id := range involved {
		ids = append(ids, id)
	}
	devices, err := s.pushDevices(ctx, g, ids)
	if err != nil || len(devices) == 0 {
		return err
	}
	members, err := groupMembers(ctx, s.db, g.id)
	if err != nil {
		return err
	}
	name := func(id string) string {
		if m := findMember(members, id); m != nil {
			return m.name
		}
		return ""
	}
	amount := e.Amount + " " + g.currency
	if g.symbol != nil {
		// As the app shows it: a symbol ending in a letter is spaced from the number.
		sep := ""
		if r, _ := utf8.DecodeLastRuneInString(*g.symbol); unicode.IsLetter(r) {
			sep = " "
		}
		amount = *g.symbol + sep + e.Amount
	}
	if f := e.Foreign; f != nil {
		amount = f.Amount + " " + f.Currency + " (" + amount + ")"
	}
	n := notification{Group: g.token, Expense: e.Id, Title: clip(g.name)}
	switch {
	case e.Kind == ExpenseKindPayment:
		n.Key, n.Args = "push_payment_added", []string{name(e.Payers[0].MemberId), name(e.Splits[0].MemberId), amount}
	case who == nil || name(*who) == "":
		n.Key, n.Args = "push_expense_"+action+"_anon", []string{e.Title, amount}
	default:
		n.Key, n.Args = "push_expense_"+action, []string{name(*who), e.Title, amount}
	}
	for i := range n.Args {
		n.Args[i] = clip(n.Args[i])
	}
	payload, err := json.Marshal(n)
	if err != nil {
		return err
	}
	// Each phone's push service is its own server, which may be slow or
	// unreachable: one that is must not use up the time the others have.
	var wg sync.WaitGroup
	sem := make(chan struct{}, maxPushParallel)
	for _, d := range devices {
		sem <- struct{}{}
		wg.Add(1)
		go func() {
			defer func() { <-sem; wg.Done() }()
			s.sendTo(ctx, g, d, payload, e.Id)
		}()
	}
	wg.Wait()
	return nil
}

// sendTo sends payload to the phone d, forgetting its subscription if it
// has ended.
func (s *Server) sendTo(ctx context.Context, g *group, d pushDevice, payload []byte, expense string) {
	err := s.push.Send(ctx, push.Message{
		Subscription: d.sub,
		Payload:      payload,
		// A later change to the expense replaces this one if it is still
		// waiting.
		Topic:   strings.ReplaceAll(expense, "-", ""),
		Urgency: "normal",
		TTL:     pushTTL,
	})
	if errors.Is(err, push.ErrGone) {
		// Only the subscription that is gone: the phone may have registered
		// a new one while this was on its way.
		_, err = s.db.Exec(ctx, `
			delete from push_devices where token = $1 and endpoint = $2 and p256dh = $3 and auth = $4`,
			d.id, d.sub.Endpoint, d.sub.P256dh, d.sub.Auth)
	}
	if err != nil {
		s.log.Warn("push failed", "group", g.id, "err", err)
	}
}

// notification is what a push message carries. The app shows it in the
// phone's language: Key names one of its strings and Args fill it in.
type notification struct {
	Group   string   `json:"g"`
	Expense string   `json:"e"`
	Title   string   `json:"t"`
	Key     string   `json:"k"`
	Args    []string `json:"a"`
}

// clip shortens s to maxPushText characters.
func clip(s string) string {
	if utf8.RuneCountInString(s) <= maxPushText {
		return s
	}
	return string([]rune(s)[:maxPushText-1]) + "…"
}

type pushDevice struct {
	id  string
	sub push.Subscription
}

// pushDevices lists the phones of the members of g listed in ids: those
// following the group by its current link while the link opens it, and
// those signed in to a member's account. A follow made with a link that has
// since been reset is left out, even when it was made while the reset ran.
func (s *Server) pushDevices(ctx context.Context, g *group, ids []string) ([]pushDevice, error) {
	linkOpen := g.open
	rows, err := s.db.Query(ctx, `
		select d.token, d.endpoint, d.p256dh, d.auth from push_devices d
		where d.token in (
			select f.device from push_follows f
			join groups g on g.id = f.group_id and g.token = f.link_token
			where $3 and f.group_id = $1 and f.member_id = any($2::uuid[])
			union
			select d.token from push_devices d
			join sessions se on se.id = d.session_id and se.expires_at > now()
			join members m on m.user_id = se.user_id and m.left_at is null
			where m.group_id = $1 and m.id = any($2::uuid[]))`, g.id, ids, linkOpen)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(row pgx.CollectableRow) (pushDevice, error) {
		var d pushDevice
		err := row.Scan(&d.id, &d.sub.Endpoint, &d.sub.P256dh, &d.sub.Auth)
		return d, err
	})
}
