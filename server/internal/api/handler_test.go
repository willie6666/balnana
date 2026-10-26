package api

import (
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"balnana/internal/config"
)

func testHandler(t *testing.T, cfg *config.Config) http.Handler {
	t.Helper()
	web := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { io.WriteString(w, "web") })
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	return NewHandler(NewServer(cfg, nil, log, "test"), web)
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
	h := testHandler(t, baseConfig(t, map[string]string{
		"BALNANA_PUBLIC_URL":             "https://split.example.com/",
		"BALNANA_OAUTH_GOOGLE_CLIENT_ID": "id",
		"BALNANA_OAUTH_GOOGLE_SECRET":    "secret",
		"BALNANA_LINK_GROUPS":            "false",
		"BALNANA_SOURCE_URL":             "https://git.example.com/balnana",
	}))
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
	if rec.Header().Get("Referrer-Policy") != "no-referrer" {
		t.Fatal("missing Referrer-Policy")
	}
}

func TestServerInfoAccountsMode(t *testing.T) {
	h := testHandler(t, baseConfig(t, map[string]string{
		"BALNANA_AUTH_MODE":              "accounts",
		"BALNANA_OAUTH_GOOGLE_CLIENT_ID": "id",
		"BALNANA_OAUTH_GOOGLE_SECRET":    "secret",
		"BALNANA_LINK_GROUPS":            "false",
	}))
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

	allowed := get(t, h, "/api/v1/server-info", http.Header{"Origin": {"http://localhost:5000"}})
	if allowed.Header().Get("Access-Control-Allow-Origin") != "http://localhost:5000" {
		t.Fatal("allowed origin not echoed")
	}
	other := get(t, h, "/api/v1/server-info", http.Header{"Origin": {"https://evil.example"}})
	if other.Header().Get("Access-Control-Allow-Origin") != "" {
		t.Fatal("unlisted origin allowed")
	}

	req := httptest.NewRequest(http.MethodOptions, "/api/v1/server-info", nil)
	req.Header.Set("Origin", "http://localhost:5000")
	req.Header.Set("Access-Control-Request-Method", "POST")
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	if rec.Code != http.StatusNoContent || rec.Header().Get("Access-Control-Allow-Headers") == "" {
		t.Fatalf("preflight: %d %v", rec.Code, rec.Header())
	}
}
