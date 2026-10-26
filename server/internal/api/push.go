package api

import (
	"context"
	"errors"
	"net/http"
	"time"

	"github.com/jackc/pgx/v5"

	"balnana/internal/push"
)

// Push notifications: phones register their Firebase token (migration
// 00006), and after an expense changes, the members it involves hear about
// it on every phone they registered, except whoever made the change.

const (
	maxDeviceToken = 4096
	// Phones register again on every start; one silent this long is gone.
	deviceKeep  = 90 * 24 * time.Hour
	pushTimeout = 30 * time.Second
)

func (s *Server) RegisterPushDevice(ctx context.Context, req RegisterPushDeviceRequestObject) (RegisterPushDeviceResponseObject, error) {
	if s.push == nil {
		return nil, &apiError{status: http.StatusNotFound, code: "push_off"}
	}
	if req.Device == "" || len(req.Device) > maxDeviceToken {
		return nil, badRequest("invalid_device")
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
	type follow struct{ group, member string }
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
			follows = append(follows, follow{g.id, item.MemberId})
		}
	}
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		_, err := tx.Exec(ctx, `
			insert into push_devices (token, session_id) values ($1, $2)
			on conflict (token) do update set session_id = excluded.session_id, updated_at = now()`, req.Device, session)
		if err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `delete from push_follows where device = $1`, req.Device); err != nil {
			return err
		}
		for _, f := range follows {
			_, err := tx.Exec(ctx, `
				insert into push_follows (device, group_id, member_id) values ($1, $2, $3)
				on conflict do nothing`, req.Device, f.group, f.member)
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

// notifyExpense tells the phones of the members e involves about action
// ("added", "edited" or "deleted"), leaving out who made the change. It runs
// after the change is committed, in the background, and never fails it.
func (s *Server) notifyExpense(g *group, who *string, action string, e Expense) {
	if s.push == nil {
		return
	}
	s.pushing.Add(1)
	go func() {
		defer s.pushing.Done()
		ctx, cancel := context.WithTimeout(context.Background(), pushTimeout)
		defer cancel()
		if err := s.sendExpense(ctx, g, who, action, e); err != nil {
			s.log.Warn("push failed", "group", g.id, "err", err)
		}
	}()
}

func (s *Server) sendExpense(ctx context.Context, g *group, who *string, action string, e Expense) error {
	if e.Kind == ExpenseKindPayment && action != "added" {
		return nil
	}
	involved := map[string]bool{}
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
	var key string
	var args []string
	switch {
	case e.Kind == ExpenseKindPayment:
		key, args = "push_payment_added", []string{name(e.Payers[0].MemberId), name(e.Splits[0].MemberId), amount}
	case who == nil || name(*who) == "":
		key, args = "push_expense_"+action+"_anon", []string{e.Title, amount}
	default:
		key, args = "push_expense_"+action, []string{name(*who), e.Title, amount}
	}
	for _, d := range devices {
		err := s.push.Send(ctx, push.Message{
			Device:   d,
			Title:    g.name,
			BodyKey:  key,
			BodyArgs: args,
			Tag:      e.Id,
			Data:     map[string]string{"group": g.token, "expense": e.Id},
		})
		if errors.Is(err, push.ErrGone) {
			_, err = s.db.Exec(ctx, `delete from push_devices where token = $1`, d)
		}
		if err != nil {
			s.log.Warn("push failed", "group", g.id, "err", err)
		}
	}
	return nil
}

// pushDevices lists the phones of the members of g listed in ids: those
// following the group by link while the link opens it, and those signed in
// to a member's account.
func (s *Server) pushDevices(ctx context.Context, g *group, ids []string) ([]string, error) {
	linkOpen := g.open
	rows, err := s.db.Query(ctx, `
		select f.device from push_follows f
		where $3 and f.group_id = $1 and f.member_id = any($2::uuid[])
		union
		select d.token from push_devices d
		join sessions se on se.id = d.session_id and se.expires_at > now()
		join members m on m.user_id = se.user_id and m.left_at is null
		where m.group_id = $1 and m.id = any($2::uuid[])`, g.id, ids, linkOpen)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, pgx.RowTo[string])
}
