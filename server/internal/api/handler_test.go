package api

import (
	"bytes"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"balnana/internal/config"
)

func testHandler(t *testing.T, cfg *config.Config) http.Handler {
	t.Helper()
	return testHandlerDB(t, cfg, nil)
}

// testHandlerDB is testHandler on a database, for handlers that need one.
func testHandlerDB(t *testing.T, cfg *config.Config, pool *pgxpool.Pool) http.Handler {
	t.Helper()
	web := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { io.WriteString(w, "web") })
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	return NewHandler(NewServer(cfg, pool, log, "test"), web)
}

func baseConfig(t *testing.T, env map[string]string) *config.Config {
	t.Helper()
	env["BALNANA_DATABASE_URL"] = "postgres:///unused"
	for k, v := range env {
		t.Setenv(k, v)
	}
	cfg, err := config.Load()
	if err != nil {
		t.Fatal(err)
	}
	return cfg
}

func get(t *testing.T, h http.Handler, path string, header http.Header) *httptest.ResponseRecorder {
	t.Helper()
	req := httptest.NewRequest(http.MethodGet, path, nil)
	for k, v := range header {
		req.Header[k] = v
	}
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

func TestServerInfoLinkMode(t *testing.T) {
	h := testHandlerDB(t, baseConfig(t, map[string]string{
		"BALNANA_PUBLIC_URL":             "https://split.example.com/",
		"BALNANA_OAUTH_GOOGLE_CLIENT_ID": "id",
		"BALNANA_OAUTH_GOOGLE_SECRET":    "secret",
		"BALNANA_LINK_GROUPS":            "false",
		"BALNANA_SOURCE_URL":             "https://git.example.com/balnana",
	}), testDB(t))
	rec := get(t, h, "/api/v1/server-info", nil)
	if rec.Code != http.StatusOK {
		t.Fatalf("status %d", rec.Code)
	}
	var info ServerInfo
	if err := json.NewDecoder(rec.Body).Decode(&info); err != nil {
		t.Fatal(err)
	}
	// Account features are off in link mode, whatever else is configured.
	if info.Name != "balnana" || info.AuthMode != "link" || info.Password || len(info.OauthProviders) != 0 || !info.LinkGroups {
		t.Fatalf("unexpected info: %+v", info)
	}
	if info.PublicUrl != "https://split.example.com" {
		t.Fatalf("public url %q", info.PublicUrl)
	}
	if info.SourceUrl != "https://git.example.com/balnana" {
		t.Fatalf("source url %q", info.SourceUrl)
	}
	if !info.SetupRequired || info.SetupCode {
		t.Fatalf("a new server needs setting up, without a code: %+v", info)
	}
	if rec.Header().Get("Referrer-Policy") != "no-referrer" {
		t.Fatal("missing Referrer-Policy")
	}
	if rec.Header().Get("X-Frame-Options") != "DENY" || rec.Header().Get("Content-Security-Policy") != "frame-ancestors 'none'" {
		t.Fatal("other sites may frame the pages")
	}
}

func TestServerInfoAccountsMode(t *testing.T) {
	h := testHandlerDB(t, baseConfig(t, map[string]string{
		"BALNANA_AUTH_MODE":              "accounts",
		"BALNANA_OAUTH_GOOGLE_CLIENT_ID": "id",
		"BALNANA_OAUTH_GOOGLE_SECRET":    "secret",
		"BALNANA_LINK_GROUPS":            "false",
	}), testDB(t))
	var info ServerInfo
	if err := json.NewDecoder(get(t, h, "/api/v1/server-info", nil).Body).Decode(&info); err != nil {
		t.Fatal(err)
	}
	if info.AuthMode != "accounts" || !info.Password || info.LinkGroups || len(info.OauthProviders) != 1 {
		t.Fatalf("unexpected info: %+v", info)
	}
	if info.SourceUrl != config.UpstreamSourceURL {
		t.Fatalf("source url %q, want upstream", info.SourceUrl)
	}
}

func TestUnknownAPIPathIsJSON404(t *testing.T) {
	h := testHandler(t, baseConfig(t, map[string]string{}))
	rec := get(t, h, "/api/v1/nope", nil)
	if rec.Code != http.StatusNotFound || rec.Header().Get("Content-Type") != "application/json" {
		t.Fatalf("status %d, type %q", rec.Code, rec.Header().Get("Content-Type"))
	}
	if rec := get(t, h, "/g/abc", nil); rec.Body.String() != "web" || rec.Header().Get("X-Robots-Tag") == "" {
		t.Fatalf("group page: %q %v", rec.Body.String(), rec.Header())
	}
}

func TestCORS(t *testing.T) {
	h := testHandler(t, baseConfig(t, map[string]string{"BALNANA_CORS_ORIGINS": "http://localhost:5000"}))

	allowed := get(t, h, "/api/v1/nope", http.Header{"Origin": {"http://localhost:5000"}})
	if allowed.Header().Get("Access-Control-Allow-Origin") != "http://localhost:5000" {
		t.Fatal("allowed origin not echoed")
	}
	other := get(t, h, "/api/v1/nope", http.Header{"Origin": {"https://evil.example"}})
	if other.Header().Get("Access-Control-Allow-Origin") != "" {
		t.Fatal("unlisted origin allowed")
	}

	req := httptest.NewRequest(http.MethodOptions, "/api/v1/nope", nil)
	req.Header.Set("Origin", "http://localhost:5000")
	req.Header.Set("Access-Control-Request-Method", "POST")
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	if rec.Code != http.StatusNoContent || rec.Header().Get("Access-Control-Allow-Headers") == "" {
		t.Fatalf("preflight: %d %v", rec.Code, rec.Header())
	}
}

func TestMaskPath(t *testing.T) {
	for path, want := range map[string]string{
		"/api/v1/g/AAAAAAAAAAAAAAAAAAAAAA/expenses": "/api/v1/g/<token>/expenses",
		"/api/v1/g/AAAAAAAAAAAAAAAAAAAAAA":          "/api/v1/g/<token>",
		"/api/v1/auth/invites/invitation-secret":    "/api/v1/auth/invites/<token>",
		"/g/AAAAAAAAAAAAAAAAAAAAAA/expenses/new":    "/g/<token>/expenses/new",
		"/invite/invitation-secret":                 "/invite/<token>",
		"/api/v1/push/devices/private-device-token": "/api/v1/push/devices/<token>",
		"/api/v1/groups":                            "/api/v1/groups",
	} {
		if got := maskPath(path); got != want {
			t.Errorf("maskPath(%q) = %q, want %q", path, got, want)
		}
	}
}

// Group and invitation tokens are secrets: no log line may hold one.
func TestLogsHideSecrets(t *testing.T) {
	var logs bytes.Buffer
	log := slog.New(slog.NewTextHandler(&logs, &slog.HandlerOptions{Level: slog.LevelDebug}))
	h := NewHandler(NewServer(baseConfig(t, map[string]string{}), nil, log, "test"), http.NotFoundHandler())
	const group, invite = "SecretGroupTokenAAAAAA", "invitation-secret"

	req := httptest.NewRequest("POST", "/api/v1/g/"+group+"/expenses", strings.NewReader("{not json"))
	req.Header.Set("Content-Type", "application/json")
	h.ServeHTTP(httptest.NewRecorder(), req)
	h.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest("GET", "/api/v1/auth/invites/"+invite, nil))
	h.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest("GET", "/invite/"+invite, nil))

	if !strings.Contains(logs.String(), "bad request") {
		t.Fatalf("nothing logged: %s", logs.String())
	}
	if strings.Contains(logs.String(), group) || strings.Contains(logs.String(), invite) {
		t.Fatalf("secret in logs: %s", logs.String())
	}
}

// Bodies are limited before any handler or account lookup runs, whether
// their size is declared or not.
func TestBodyLimits(t *testing.T) {
	big := `{"name":"Trip","currency":"EUR","members":["Ana"],"x":"` + strings.Repeat("a", maxBody) + `"}`
	send := func(h http.Handler, body io.Reader, header http.Header) int {
		req := httptest.NewRequest("POST", "/api/v1/groups", body)
		req.Header.Set("Content-Type", "application/json")
		for k, v := range header {
			req.Header[k] = v
		}
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, req)
		return rec.Code
	}
	// No database: reaching a handler would panic into a 500.
	link := testHandler(t, baseConfig(t, map[string]string{}))
	if code := send(link, strings.NewReader(big), nil); code != http.StatusRequestEntityTooLarge {
		t.Errorf("declared size: %d", code)
	}
	chunked := io.MultiReader(strings.NewReader(big)) // unknown length
	if code := send(link, chunked, nil); code != http.StatusRequestEntityTooLarge {
		t.Errorf("chunked: %d", code)
	}
	accounts := testHandler(t, baseConfig(t, map[string]string{"BALNANA_AUTH_MODE": "accounts"}))
	if code := send(accounts, strings.NewReader(big), http.Header{"Authorization": {"Bearer some-session"}}); code != http.StatusRequestEntityTooLarge {
		t.Errorf("signed in: %d", code)
	}
}
