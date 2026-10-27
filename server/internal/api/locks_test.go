package api

import (
	"context"
	"log/slog"
	"net/http"
	"strings"
	"testing"
	"time"

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
			first, second, _, _ := racing(t, f.env(map[string]string{}), func(sql string) {
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
	first, second, mail, _ := racing(t, f.env(map[string]string{}), func(sql string) {
		if !fired && strings.Contains(sql, "for share") {
			fired = true
			reclaim()
		}
	})
	unvouched := map[string]any{"sub": "m", "email": "mallory@example.com", "email_verified": false, "name": "Mallory"}
	f.login(first, "/groups", unvouched)
	var taken User
	first.must(200, "POST", "/me/email", EmailChange{Email: "ana@example.com"}, &taken)
	mail.next(t, "ana@example.com") // the link to verify it
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
