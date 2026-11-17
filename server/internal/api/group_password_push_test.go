package api

import (
	"context"
	"strings"
	"testing"
	"time"

	"balnana/migrations"
)

func TestPushPasswordRacingRegistration(t *testing.T) {
	for _, protected := range []bool{false, true} {
		name := "set"
		if protected {
			name = "change"
		}
		t.Run(name, func(t *testing.T) {
			c, sent, s := pushClient(t, map[string]string{})
			g := createGroup(c, "Ana", "Ben")
			base := "/g/" + g.Token
			var old *string
			if protected {
				var key GroupKey
				c.must(200, "PUT", base+"/password", GroupPasswordInput{Password: "before"}, &key)
				old = &key.Key
				c = c.withKey(key.Key)
			}
			in := follow(g.Token, g.Members[1].Id)
			in.Groups[0].Key = old
			subscribe(c, "old-phone", in)
			subscribe(c, "racing-phone", PushDeviceInput{})

			ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
			defer cancel()
			tx, err := s.db.Begin(ctx)
			if err != nil {
				t.Fatal(err)
			}
			defer tx.Rollback(context.Background())
			if _, err := tx.Exec(ctx, `select 1 from push_devices where token = $1 for update`, deviceID("racing-phone")); err != nil {
				t.Fatal(err)
			}
			in.Endpoint, in.P256dh, in.Auth = "https://push.example.com/up/racing-phone", phoneKey(), "MDEyMzQ1Njc4OWFiY2RlZg"
			done := make(chan error, 1)
			go func() {
				_, err := s.RegisterPushDevice(ctx, RegisterPushDeviceRequestObject{Device: deviceID("racing-phone"), Body: &in})
				done <- err
			}()
			// Validation has finished, but the registration cannot write its
			// follow until after the password change has deleted old follows.
			for deadline := time.Now().Add(5 * time.Second); ; time.Sleep(5 * time.Millisecond) {
				var waiting bool
				err := s.db.QueryRow(ctx, `
					select exists (select 1 from pg_stat_activity
					where datname = current_database() and wait_event_type = 'Lock'
					and query like '%insert into push_devices%')`).Scan(&waiting)
				if err != nil {
					t.Fatal(err)
				}
				if waiting {
					break
				}
				if time.Now().After(deadline) {
					t.Fatal("registration did not reach the device lock")
				}
			}
			var fresh GroupKey
			c.must(200, "PUT", base+"/password", GroupPasswordInput{Password: "after"}, &fresh)
			if err := tx.Commit(ctx); err != nil {
				t.Fatal(err)
			}
			if err := <-done; err != nil {
				t.Fatal(err)
			}
			if code := c.errorCode(403, "GET", base, nil); code != "password_required" {
				t.Fatal(code)
			}
			c = c.withKey(fresh.Key)
			current := follow(g.Token, g.Members[1].Id)
			current.Groups[0].Key = &fresh.Key
			subscribe(c, "current-phone", current)
			c.member = g.Members[0].Id
			c.must(201, "POST", base+"/expenses", transfer(g.Members[0].Id, g.Members[1].Id, "5"), nil)
			if messages := sent.take(s); len(messages) != 1 || messages[0].phone != "current-phone" {
				t.Fatalf("revoked phones received pushes: %+v", messages)
			}
		})
	}
}

func TestPushRemovingPasswordKeepsFollows(t *testing.T) {
	c, sent, s := pushClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben")
	base := "/g/" + g.Token
	var key GroupKey
	c.must(200, "PUT", base+"/password", GroupPasswordInput{Password: "before"}, &key)
	c = c.withKey(key.Key)
	c.member = g.Members[0].Id
	in := follow(g.Token, g.Members[1].Id)
	in.Groups[0].Key = &key.Key
	subscribe(c, "ben-phone", in)
	for _, phase := range []string{"protected", "removed", "removed again"} {
		if phase != "protected" {
			c.must(204, "DELETE", base+"/password", nil, nil)
		}
		c.must(201, "POST", base+"/expenses", transfer(g.Members[0].Id, g.Members[1].Id, "5"), nil)
		if messages := sent.take(s); len(messages) != 1 || messages[0].phone != "ben-phone" {
			t.Fatalf("%s: authorized phone stopped receiving pushes: %+v", phase, messages)
		}
	}
}

func TestPushPasswordMigration(t *testing.T) {
	c, _, s := pushClient(t, map[string]string{})
	protected := createGroup(c, "Ana", "Ben")
	open := createGroup(c, "Ana", "Ben")
	var key GroupKey
	c.must(200, "PUT", "/g/"+protected.Token+"/password", GroupPasswordInput{Password: "secret"}, &key)
	in := follow(protected.Token, protected.Members[1].Id)
	in.Groups[0].Key = &key.Key
	subscribe(c, "protected-phone", in)
	subscribe(c, "open-phone", follow(open.Token, open.Members[1].Id))

	ctx := context.Background()
	// Recreate the old schema: those follows carry no proof of which
	// password authorized them, even if they were registered after rotation.
	if _, err := s.db.Exec(ctx, `alter table push_follows drop column password_hash`); err != nil {
		t.Fatal(err)
	}
	sql, err := migrations.FS.ReadFile("00048_push_password.sql")
	if err != nil {
		t.Fatal(err)
	}
	up, _, _ := strings.Cut(string(sql), "-- +goose Down")
	if _, err := s.db.Exec(ctx, up); err != nil {
		t.Fatal(err)
	}
	var kept string
	if err := s.db.QueryRow(ctx, `select device from push_follows`).Scan(&kept); err != nil {
		t.Fatal(err)
	}
	if kept != deviceID("open-phone") {
		t.Fatalf("migration kept an unverifiable protected follow: %q", kept)
	}
	var count int
	if err := s.db.QueryRow(ctx, `select count(*) from push_follows`).Scan(&count); err != nil || count != 1 {
		t.Fatalf("migration kept %d follows, want 1: %v", count, err)
	}
	// Entering the current password restores a protected follow normally.
	subscribe(c, "protected-phone", in)
	g, err := s.findGroup(ctx, s.db, protected.Token, false)
	if err != nil {
		t.Fatal(err)
	}
	devices, err := s.pushDevices(ctx, g, []string{protected.Members[1].Id})
	if err != nil || len(devices) != 1 || devices[0].id != deviceID("protected-phone") {
		t.Fatalf("follow after migration: %v, %v", devices, err)
	}
}
