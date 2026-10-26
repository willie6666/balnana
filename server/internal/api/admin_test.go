package api

import (
	"context"
	"log/slog"
	"net/http"
	"slices"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

const adminPassword = "correct horse battery"

// adminClient starts a server with env on a fresh database, as the server
// binary does, and returns a client for it.
func adminClient(t *testing.T, env map[string]string) (*client, *Server, *pgxpool.Pool) {
	t.Helper()
	pool := testDB(t)
	s := NewServer(baseConfig(t, env), pool, slog.New(slog.DiscardHandler), "test")
	if err := s.LoadSettings(context.Background()); err != nil {
		t.Fatal(err)
	}
	return &client{t: t, h: NewHandler(s, http.NotFoundHandler())}, s, pool
}

// asAdmin is a client sending the admin token.
func (c *client) asAdmin(token string) *client {
	a := c.another()
	a.header = http.Header{"X-Balnana-Admin": {token}}
	return a
}

func serverInfo(c *client) ServerInfo {
	c.t.Helper()
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	return info
}

func setting(t *testing.T, all AdminSettings, key string) AdminSetting {
	t.Helper()
	for _, s := range all.Settings {
		if s.Key == key {
			return s
		}
	}
	t.Fatalf("no setting %s", key)
	return AdminSetting{}
}

func setUp(c *client) string {
	c.t.Helper()
	var session AdminSession
	c.must(201, "POST", "/admin/setup", AdminSetupInput{Password: adminPassword}, &session)
	if session.Token == "" || time.Until(session.ExpiresAt) < time.Hour {
		c.t.Fatalf("session %+v", session)
	}
	return session.Token
}

func TestAdminSetup(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{})
	if err := s.PrepareAdmin(context.Background()); err != nil {
		t.Fatal(err)
	}
	if info := serverInfo(c); !info.SetupRequired || info.SetupCode {
		t.Fatalf("a new server needs setting up, without a code: %+v", info)
	}
	if code := c.errorCode(409, "POST", "/admin/login", AdminLoginInput{Password: adminPassword}); code != "setup_required" {
		t.Fatalf("login before setup: %s", code)
	}
	if code := c.errorCode(401, "GET", "/admin/settings", nil); code != "admin_required" {
		t.Fatalf("settings without a token: %s", code)
	}
	if code := c.errorCode(400, "POST", "/admin/setup", AdminSetupInput{Password: "short"}); code != "invalid_password" {
		t.Fatalf("short password: %s", code)
	}

	token := setUp(c)
	if code := c.errorCode(409, "POST", "/admin/setup", AdminSetupInput{Password: "someone else's"}); code != "already_set_up" {
		t.Fatalf("second setup: %s", code)
	}
	if info := serverInfo(c); info.SetupRequired {
		t.Fatal("still asks for setup")
	}
	c.asAdmin(token).must(200, "GET", "/admin/settings", nil, nil)
	if code := c.asAdmin("forged").errorCode(401, "GET", "/admin/settings", nil); code != "admin_required" {
		t.Fatalf("forged token: %s", code)
	}

	if code := c.errorCode(401, "POST", "/admin/login", AdminLoginInput{Password: "wrong password"}); code != "invalid_credentials" {
		t.Fatalf("wrong password: %s", code)
	}
	var session AdminSession
	c.must(200, "POST", "/admin/login", AdminLoginInput{Password: adminPassword}, &session)
	second := c.asAdmin(session.Token)
	second.must(200, "GET", "/admin/settings", nil, nil)
	second.must(204, "POST", "/admin/logout", nil, nil)
	second.errorCode(401, "GET", "/admin/settings", nil)
}

func TestAdminSetupCodeOnUpgrade(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{})
	createGroup(c, "Ana") // a server that was in use before administration existed
	if err := s.PrepareAdmin(context.Background()); err != nil {
		t.Fatal(err)
	}
	if info := serverInfo(c); !info.SetupRequired || !info.SetupCode {
		t.Fatalf("want a setup code: %+v", info)
	}
	var code string
	if err := s.db.QueryRow(context.Background(), `select setup_code from admin`).Scan(&code); err != nil {
		t.Fatal(err)
	}
	// Starting again keeps the code that was printed.
	if err := s.PrepareAdmin(context.Background()); err != nil {
		t.Fatal(err)
	}
	var again string
	_ = s.db.QueryRow(context.Background(), `select setup_code from admin`).Scan(&again)
	if again != code || len(code) != 8 {
		t.Fatalf("code %q then %q", code, again)
	}

	for _, wrong := range []*string{nil, ptr("AAAAAAAA")} {
		if e := c.errorCode(403, "POST", "/admin/setup", AdminSetupInput{Password: adminPassword, Code: wrong}); e != "invalid_setup_code" {
			t.Fatalf("code %v: %s", wrong, e)
		}
	}
	typed := strings.ToLower(code[:4]) + "-" + code[4:]
	c.must(201, "POST", "/admin/setup", AdminSetupInput{Password: adminPassword, Code: &typed}, nil)
	if info := serverInfo(c); info.SetupRequired || info.SetupCode {
		t.Fatalf("set up: %+v", info)
	}
}

func TestAdminSettings(t *testing.T) {
	c, _, _ := adminClient(t, map[string]string{"BALNANA_SOURCE_URL": "https://git.example.com/balnana"})
	admin := c.asAdmin(setUp(c))

	var all AdminSettings
	admin.must(200, "GET", "/admin/settings", nil, &all)
	if src := setting(t, all, "BALNANA_SOURCE_URL"); !src.Locked || src.Value == nil || *src.Value != "https://git.example.com/balnana" {
		t.Fatalf("source url: %+v", src)
	}
	if mode := setting(t, all, "BALNANA_AUTH_MODE"); mode.Locked || mode.Set || mode.Default != "link" {
		t.Fatalf("auth mode: %+v", mode)
	}

	// Nothing is saved when anything is wrong.
	var e Error
	got := admin.call("PUT", "/admin/settings", AdminSettingsInput{Values: map[string]string{
		"BALNANA_AUTH_MODE":    "accounts",
		"BALNANA_SMTP_HOST":    "smtp.example.com",
		"BALNANA_SOURCE_URL":   "https://elsewhere.example.com",
		"BALNANA_DATABASE_URL": "postgres:///other",
	}}, &e)
	if got != 400 || e.Code != "invalid_settings" {
		t.Fatalf("status %d %+v", got, e)
	}
	if keys := (*e.Params)["keys"]; !slices.Equal(toStrings(keys), []string{"BALNANA_DATABASE_URL", "BALNANA_SOURCE_URL"}) {
		t.Fatalf("keys %v", keys)
	}
	got = admin.call("PUT", "/admin/settings", AdminSettingsInput{Values: map[string]string{
		"BALNANA_AUTH_MODE": "accounts",
		"BALNANA_SMTP_HOST": "smtp.example.com",
	}}, &e)
	if got != 400 || !slices.Equal(toStrings((*e.Params)["keys"]), []string{"BALNANA_SMTP_FROM"}) {
		t.Fatalf("status %d %+v", got, e)
	}
	if info := serverInfo(c); info.AuthMode != "link" {
		t.Fatal("a refused change was applied")
	}

	// A good change applies at once.
	admin.must(200, "PUT", "/admin/settings", AdminSettingsInput{Values: map[string]string{
		"BALNANA_AUTH_MODE":     "accounts",
		"BALNANA_SMTP_HOST":     "smtp.example.com",
		"BALNANA_SMTP_FROM":     "Balnana <balnana@example.com>",
		"BALNANA_SMTP_PASSWORD": "mail secret",
		"BALNANA_PUBLIC_URL":    " https://split.example.com/ ",
	}}, &all)
	if pw := setting(t, all, "BALNANA_SMTP_PASSWORD"); !pw.Secret || !pw.Set || pw.Value != nil {
		t.Fatalf("secret sent back: %+v", pw)
	}
	info := serverInfo(c)
	if info.AuthMode != "accounts" || !info.Email || info.PublicUrl != "https://split.example.com" {
		t.Fatalf("not applied: %+v", info)
	}
	// Accounts mode is in force for requests, too.
	if code := c.errorCode(401, "POST", "/groups", GroupCreate{Name: "Trip", Currency: "EUR", Members: []string{"Ana"}}); code != "sign_in_required" {
		t.Fatalf("create group signed out: %s", code)
	}

	// Leaving a secret out keeps it; an empty value returns to the default.
	admin.must(200, "PUT", "/admin/settings", AdminSettingsInput{Values: map[string]string{"BALNANA_AUTH_MODE": ""}}, &all)
	if pw := setting(t, all, "BALNANA_SMTP_PASSWORD"); !pw.Set {
		t.Fatal("secret lost")
	}
	if info := serverInfo(c); info.AuthMode != "link" || !info.Email {
		t.Fatalf("after reset: %+v", info)
	}
}

func toStrings(v any) []string {
	var out []string
	for _, x := range v.([]any) {
		out = append(out, x.(string))
	}
	return out
}

func TestAdminPassword(t *testing.T) {
	c, _, _ := adminClient(t, map[string]string{})
	first := c.asAdmin(setUp(c))
	var session AdminSession
	c.must(200, "POST", "/admin/login", AdminLoginInput{Password: adminPassword}, &session)
	second := c.asAdmin(session.Token)

	if code := first.errorCode(403, "POST", "/admin/password", PasswordChange{CurrentPassword: ptr("nope"), NewPassword: "a new password"}); code != "wrong_password" {
		t.Fatalf("wrong current password: %s", code)
	}
	if code := first.errorCode(400, "POST", "/admin/password", PasswordChange{CurrentPassword: ptr(adminPassword), NewPassword: "short"}); code != "invalid_password" {
		t.Fatalf("short password: %s", code)
	}
	first.must(204, "POST", "/admin/password", PasswordChange{CurrentPassword: ptr(adminPassword), NewPassword: "a new password"}, nil)
	first.must(200, "GET", "/admin/settings", nil, nil)
	second.errorCode(401, "GET", "/admin/settings", nil)
	c.errorCode(401, "POST", "/admin/login", AdminLoginInput{Password: adminPassword})
	c.must(200, "POST", "/admin/login", AdminLoginInput{Password: "a new password"}, nil)
}

func TestAssetLinks(t *testing.T) {
	c, _, _ := adminClient(t, map[string]string{})
	admin := c.asAdmin(setUp(c))
	if rec := get(t, c.h, "/.well-known/assetlinks.json", nil); rec.Code != 404 {
		t.Fatalf("without fingerprints: %d", rec.Code)
	}
	fp := strings.Repeat("ab", 32)
	admin.must(200, "PUT", "/admin/settings", AdminSettingsInput{Values: map[string]string{"BALNANA_ANDROID_CERT_SHA256": fp}}, nil)
	rec := get(t, c.h, "/.well-known/assetlinks.json", nil)
	body := rec.Body.String()
	if rec.Code != 200 || rec.Header().Get("Content-Type") != "application/json" ||
		!strings.Contains(body, `"package_name":"io.github.willie6666.balnana"`) ||
		!strings.Contains(body, strings.TrimSuffix(strings.Repeat("AB:", 32), ":")) {
		t.Fatalf("%d %s", rec.Code, body)
	}
}

// Servers sharing a database follow settings saved through any of them.
func TestSettingsReachOtherServers(t *testing.T) {
	c, _, pool := adminClient(t, map[string]string{})
	admin := c.asAdmin(setUp(c))

	other := NewServer(baseConfig(t, map[string]string{}), pool, slog.New(slog.DiscardHandler), "test")
	ctx, cancel := context.WithCancel(context.Background())
	go other.ListenForChanges(ctx)
	t.Cleanup(func() {
		cancel()
		<-other.hub.done
	})
	<-other.hub.ready
	oc := &client{t: t, h: NewHandler(other, http.NotFoundHandler())}

	admin.must(200, "PUT", "/admin/settings", AdminSettingsInput{Values: map[string]string{"BALNANA_AUTH_MODE": "accounts"}}, nil)
	deadline := time.Now().Add(5 * time.Second)
	for serverInfo(oc).AuthMode != "accounts" {
		if time.Now().After(deadline) {
			t.Fatal("the other server kept the old settings")
		}
		time.Sleep(20 * time.Millisecond)
	}
}

func TestResetAdmin(t *testing.T) {
	c, _, pool := adminClient(t, map[string]string{})
	token := setUp(c)
	code, err := ResetAdmin(context.Background(), pool)
	if err != nil {
		t.Fatal(err)
	}
	if info := serverInfo(c); !info.SetupRequired || !info.SetupCode {
		t.Fatalf("a reset server needs setting up with the code: %+v", info)
	}
	if e := c.asAdmin(token).errorCode(401, "GET", "/admin/settings", nil); e != "admin_required" {
		t.Fatal("administrators stay signed in after a reset")
	}
	if e := c.errorCode(403, "POST", "/admin/setup", AdminSetupInput{Password: "a new password"}); e != "invalid_setup_code" {
		t.Fatal(e)
	}
	c.must(201, "POST", "/admin/setup", AdminSetupInput{Password: "a new password", Code: &code}, nil)
	c.must(200, "POST", "/admin/login", AdminLoginInput{Password: "a new password"}, nil)
}

func TestSweepExpired(t *testing.T) {
	c, s, pool := adminClient(t, map[string]string{})
	token := setUp(c)
	ctx := context.Background()
	if _, err := pool.Exec(ctx, `insert into admin_sessions (token_hash, expires_at) values ('\x00', now() - interval '1 second')`); err != nil {
		t.Fatal(err)
	}
	n, err := s.sweepExpired(ctx)
	if err != nil || n != 1 {
		t.Fatalf("swept %d rows, err %v", n, err)
	}
	c.asAdmin(token).must(200, "GET", "/admin/settings", nil, nil)
}
