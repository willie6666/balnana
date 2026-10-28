package api

import (
	"context"
	"log/slog"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// racing is two servers on one database, as two instances behind a load
// balancer are. The second one's connections run before ahead of each
// statement they send, so another request can be made at a precise moment.
func racing(t *testing.T, env map[string]string, before func(sql string)) (first, second *client, mail fakeMail, db *pgxpool.Pool) {
	t.Helper()
	env["BALNANA_AUTH_MODE"] = "accounts"
	db = testDB(t)
	cfg := baseConfig(t, env)
	log := slog.New(slog.DiscardHandler)
	mail = make(fakeMail, 10)
	s := NewServer(cfg, db, log, "test")
	s.settings.Load().mail = mail
	traced := db.Config()
	traced.ConnConfig.Tracer = &exportBarrier{before: before}
	other, err := pgxpool.NewWithConfig(context.Background(), traced)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(other.Close)
	return &client{t: t, h: NewHandler(s, http.NotFoundHandler())},
		&client{t: t, h: NewHandler(NewServer(cfg, other, log, "test"), http.NotFoundHandler())}, mail, db
}

// A password checked just before the address owner takes the account back
// signs nobody in: neither when they come first, nor when they come while
// the session is being made.
func TestLoginRacingTakeover(t *testing.T) {
	for _, boundary := range []string{"for share", "insert into sessions"} {
		t.Run(boundary, func(t *testing.T) {
			f := newFakeIdP(t)
			var first *client
			takeover := make(chan string, 1)
			fired := false
			first, second, _, _ := racing(t, verifiedOnly(f.env(map[string]string{})), func(sql string) {
				if fired || !strings.Contains(sql, boundary) {
					return
				}
				fired = true
				go func() {
					ana := first.another()
					ana.call("GET", "/auth/oauth/oidc/start?app=web&next=/groups", nil, nil)
					ana.call("GET", f.approve(ana, person("a", "ana@example.com", "Ana")), nil, nil)
					takeover <- ana.location
				}()
				if boundary == "for share" {
					takeover <- <-takeover
				} else {
					// Long enough for the sign-in to reach the account's lock.
					time.Sleep(200 * time.Millisecond)
				}
			})
			register(first, "ana@example.com", "Mallory")

			mallory := second.another()
			var out Session
			status := mallory.call("POST", "/auth/login", LoginInput{Login: "ana@example.com", Password: "correct horse"}, &out)
			if !fired {
				t.Fatal("never raced")
			}
			if location := <-takeover; oauthError(t, location) != "" {
				t.Fatalf("takeover: %s", location)
			}
			if status == http.StatusOK {
				mallory.token = *out.Token
				mallory.errorCode(401, "GET", "/me", nil)
			} else if status != http.StatusUnauthorized {
				t.Fatalf("login: status %d", status)
			}
		})
	}
}

// Asking for a new link while the last one is being used waits for it, and
// neither request fails.
func TestPasswordResetRacingResend(t *testing.T) {
	var first *client
	resent := make(chan int, 1)
	fired := false
	first, second, mail, db := racing(t, map[string]string{}, func(sql string) {
		if fired || !strings.Contains(sql, "update users set password_hash") {
			return
		}
		fired = true
		go func() {
			resent <- first.another().call("POST", "/auth/password-reset", PasswordResetRequest{Email: "ana@example.com"}, nil)
		}()
		// Long enough for the request to reach the account's lock.
		time.Sleep(200 * time.Millisecond)
	})
	ana := register(first, "ana@example.com", "Ana")
	first.must(204, "POST", "/auth/password-reset", PasswordResetRequest{Email: "ana@example.com"}, nil)
	token := lastPart(mail.next(t, "ana@example.com"))
	// Old enough that the resend is not held back as too soon.
	if _, err := db.Exec(context.Background(), `update email_tokens set created_at = now() - interval '2 minutes' where user_id = $1`, ana.Id); err != nil {
		t.Fatal(err)
	}

	second.must(204, "POST", "/auth/password-reset/confirm", PasswordReset{Token: token, NewPassword: "new password"}, nil)
	if !fired {
		t.Fatal("never raced")
	}
	if status := <-resent; status != http.StatusNoContent {
		t.Fatalf("resend: status %d", status)
	}
	second.another().must(200, "POST", "/auth/login", LoginInput{Login: "ana@example.com", Password: "new password"}, nil)
}

// An OAuth sign-in whose identity is dropped as it goes, by the address owner
// taking the account back, reaches the account no more.
func TestOAuthRacingReclaim(t *testing.T) {
	f := newFakeIdP(t)
	var reclaim func()
	fired := false
	first, second, mail, db := racing(t, f.env(map[string]string{}), func(sql string) {
		if !fired && strings.Contains(sql, "for share") {
			fired = true
			reclaim()
		}
	})
	unvouched := map[string]any{"sub": "m", "email": "mallory@example.com", "email_verified": false, "name": "Mallory"}
	f.login(first, "/groups", unvouched)
	var taken User
	first.must(200, "GET", "/me", nil, &taken)
	takeAddress(t, db, taken.Id, "ana@example.com")
	first.another().must(204, "POST", "/auth/password-reset", PasswordResetRequest{Email: "ana@example.com"}, nil)
	token := lastPart(mail.next(t, "ana@example.com"))
	status := 0
	reclaim = func() {
		status = first.another().call("POST", "/auth/password-reset/confirm", PasswordReset{Token: token, NewPassword: "new password"}, nil)
	}

	mallory := second.another()
	if e := oauthError(t, f.login(mallory, "/groups", unvouched)); e != "" {
		t.Fatal(e)
	}
	if !fired || status != http.StatusNoContent {
		t.Fatalf("fired=%v reset status %d", fired, status)
	}
	var me User
	mallory.must(200, "GET", "/me", nil, &me)
	if me.Id == taken.Id {
		t.Fatal("Mallory signed in to the account taken back")
	}
}

// A password change checked before the address owner takes the account back
// changes nothing after it: the session it came on is gone.
func TestPasswordChangeRacingReclaim(t *testing.T) {
	f := newFakeIdP(t)
	var first *client
	fired := false
	first, second, _, _ := racing(t, verifiedOnly(f.env(map[string]string{})), func(sql string) {
		// Where lockAccount begins, after the password was checked.
		if fired || !strings.Contains(sql, "lock table users in row exclusive mode") {
			return
		}
		fired = true
		owner := first.another()
		if e := oauthError(t, f.login(owner, "/groups", person("owner", "owner@example.com", "Owner"))); e != "" {
			t.Fatal(e)
		}
	})
	register(first, "owner@example.com", "Mallory")
	second.token = first.token
	code := second.errorCode(401, "POST", "/me/password",
		PasswordChange{CurrentPassword: ptr("correct horse"), NewPassword: "mallory's new password"})
	if !fired || code != "sign_in_required" {
		t.Fatalf("fired=%v code %s", fired, code)
	}
	first.another().errorCode(401, "POST", "/auth/login", LoginInput{Login: "owner@example.com", Password: "mallory's new password"})
}

// The old administrator password starts no session once reset-admin has
// taken it away, however late in the sign-in the reset comes.
func TestAdminLoginRacingReset(t *testing.T) {
	fired := false
	var reset func()
	first, second, _, db := racing(t, map[string]string{}, func(sql string) {
		if !fired && strings.Contains(sql, "from admin for update") {
			fired = true
			reset()
		}
	})
	setUp(first)
	reset = func() {
		if _, err := ResetAdmin(context.Background(), db); err != nil {
			t.Fatal(err)
		}
	}
	code := second.errorCode(401, "POST", "/admin/login", AdminLoginInput{Password: adminPassword})
	if !fired || code != "invalid_credentials" {
		t.Fatalf("fired=%v code %s", fired, code)
	}
}

// Someone joining an open group as its last owner deletes their account
// waits for the deletion, then owns the group.
func TestDeleteAccountRacingJoin(t *testing.T) {
	var ben *client
	var token string
	joined := make(chan int, 1)
	fired := false
	first, second, _, _ := racing(t, map[string]string{}, func(sql string) {
		if fired || !strings.Contains(sql, "update members set user_id = null, is_owner = false") {
			return
		}
		fired = true
		go func() { joined <- ben.call("POST", "/g/"+token+"/join", JoinInput{}, nil) }()
		// Long enough for the join to reach the group's lock.
		time.Sleep(200 * time.Millisecond)
	})
	register(first, "ana@example.com", "Ana")
	ben = first.another()
	register(ben, "ben@example.com", "Ben")
	var g Group
	first.must(201, "POST", "/groups", GroupCreate{Name: "Open", Currency: "EUR", Members: []string{"Ana"}, LinkAccess: ptr(true)}, &g)
	token = g.Token
	second.token = first.token
	second.must(204, "POST", "/me/delete", AccountDelete{Password: ptr("correct horse")}, nil)
	if status := <-joined; !fired || status != http.StatusOK {
		t.Fatalf("fired=%v join status %d", fired, status)
	}
	ben.must(200, "GET", "/g/"+token, nil, &g)
	owned := false
	for _, m := range g.Members {
		owned = owned || m.Owner && m.Claimed && !m.Left
	}
	if !owned {
		t.Fatal("the group has no owner")
	}
}

// A join that holds the group as the account deletion reaches it is seen by
// the deletion, which keeps the group for the one who joined.
func TestDeleteAccountWaitsForJoin(t *testing.T) {
	reached := make(chan struct{})
	fired := false
	first, second, _, db := racing(t, map[string]string{}, func(sql string) {
		if !fired && strings.Contains(sql, "order by id for update") {
			fired = true
			close(reached)
		}
	})
	register(first, "ana@example.com", "Ana")
	ben := first.another()
	bu := register(ben, "ben@example.com", "Ben")
	var g Group
	first.must(201, "POST", "/groups", GroupCreate{Name: "Shared", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &g)
	ctx := context.Background()
	tx, err := db.Begin(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = tx.Rollback(ctx) }()
	var id string
	if err := tx.QueryRow(ctx, `select id::text from groups where token = $1 for update`, g.Token).Scan(&id); err != nil {
		t.Fatal(err)
	}
	second.token = first.token
	done := make(chan int, 1)
	go func() { done <- second.call("POST", "/me/delete", AccountDelete{Password: ptr("correct horse")}, nil) }()
	<-reached
	for deadline := time.Now().Add(5 * time.Second); ; time.Sleep(5 * time.Millisecond) {
		var waiting bool
		err := db.QueryRow(ctx, `
			select exists (select 1 from pg_stat_activity where datname = current_database()
			               and wait_event_type = 'Lock' and query like '%order by id for update%')`).Scan(&waiting)
		if err != nil {
			t.Fatal(err)
		}
		if waiting {
			break
		}
		if time.Now().After(deadline) {
			t.Fatal("the deletion did not wait for the group")
		}
	}
	// What JoinGroup does, on the group it holds.
	if err := join(ctx, tx, &group{id: id}, &user{id: bu.Id, name: "Ben"}, &JoinInput{ClaimMemberId: &g.Members[1].Id}); err != nil {
		t.Fatal(err)
	}
	if err := tx.Commit(ctx); err != nil {
		t.Fatal(err)
	}
	if status := <-done; status != http.StatusNoContent {
		t.Fatalf("delete: status %d", status)
	}
	ben.must(200, "GET", "/g/"+g.Token, nil, nil)
}

// A password change holding the account and an OAuth sign-in reclaiming it
// take the users table in the same order, so one waits for the other
// instead of both failing on a deadlock.
func TestAccountLockOrderWithReclaim(t *testing.T) {
	c, _, pool := adminClient(t, map[string]string{"BALNANA_AUTH_MODE": "accounts"})
	u := register(c, "ana@example.com", "Ana")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	var hash, sessionID string
	err := pool.QueryRow(ctx, `
		select u.password_hash, se.id::text from users u join sessions se on se.user_id = u.id where u.id = $1`,
		u.Id).Scan(&hash, &sessionID)
	if err != nil {
		t.Fatal(err)
	}
	first, err := pool.Begin(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = first.Rollback(context.Background()) }()
	if err := lockAccount(ctx, first, &user{id: u.Id, sessionID: sessionID}, &hash); err != nil {
		t.Fatal(err)
	}
	reclaimed := make(chan error, 1)
	go func() {
		// What oauthUserTx does to reclaim an unverified account.
		reclaimed <- pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
			if _, err := tx.Exec(ctx, `lock table users in share row exclusive mode`); err != nil {
				return err
			}
			_, err := tx.Exec(ctx, `update users set email_verified = true, password_hash = null where id = $1`, u.Id)
			return err
		})
	}()
	time.Sleep(200 * time.Millisecond) // let the reclaim reach its lock
	// What ChangePassword does after lockAccount.
	if _, err := first.Exec(ctx, `update users set password_hash = $2 where id = $1`, u.Id, hash); err != nil {
		t.Fatalf("password change: %v", err)
	}
	if err := first.Commit(ctx); err != nil {
		t.Fatal(err)
	}
	if err := <-reclaimed; err != nil {
		t.Fatalf("reclaim: %v", err)
	}
}
