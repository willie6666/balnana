package config

import (
	"slices"
	"strings"
	"testing"
)

func envMap(m map[string]string) func(string) string {
	return func(k string) string { return m[k] }
}

func TestDefaults(t *testing.T) {
	c, err := load(envMap(map[string]string{"BALNANA_DATABASE_URL": "postgres:///x"}))
	if err != nil {
		t.Fatal(err)
	}
	if c.AuthMode != AuthModeLink || c.Listen != ":8080" || !c.LinkGroups || c.SMTP.Enabled() {
		t.Fatalf("unexpected defaults: %+v", c)
	}
	if c.PublicURL.String() != "http://localhost:8080" {
		t.Fatalf("public url = %s", c.PublicURL)
	}
	if c.SourceURL.String() != UpstreamSourceURL {
		t.Fatalf("source url = %s", c.SourceURL)
	}
}

func TestSourceURL(t *testing.T) {
	c, err := load(envMap(map[string]string{
		"BALNANA_DATABASE_URL": "postgres:///x",
		"BALNANA_SOURCE_URL":   "https://git.example.com/balnana",
	}))
	if err != nil {
		t.Fatal(err)
	}
	if c.SourceURL.String() != "https://git.example.com/balnana" {
		t.Fatalf("source url = %s", c.SourceURL)
	}
	for _, bad := range []string{"git.example.com/balnana", "ftp://example.com/src", "https://"} {
		_, err := load(envMap(map[string]string{"BALNANA_DATABASE_URL": "postgres:///x", "BALNANA_SOURCE_URL": bad}))
		if err == nil || !strings.Contains(err.Error(), "BALNANA_SOURCE_URL") {
			t.Errorf("%q: want error, got %v", bad, err)
		}
	}
}

func TestDatabaseURLFallback(t *testing.T) {
	c, err := load(envMap(map[string]string{"DATABASE_URL": "postgres:///y"}))
	if err != nil {
		t.Fatal(err)
	}
	if c.DatabaseURL != "postgres:///y" {
		t.Fatalf("got %q", c.DatabaseURL)
	}
}

func TestDatabasePassword(t *testing.T) {
	c, err := load(envMap(map[string]string{
		"BALNANA_DATABASE_URL":      "postgres://balnana@db:5432/balnana?sslmode=disable",
		"BALNANA_DATABASE_PASSWORD": "p@ss/w:rd#?",
	}))
	if err != nil {
		t.Fatal(err)
	}
	if c.DatabaseURL != "postgres://balnana:p%40ss%2Fw%3Ard%23%3F@db:5432/balnana?sslmode=disable" {
		t.Fatalf("got %q", c.DatabaseURL)
	}
}

func TestReportsAllErrors(t *testing.T) {
	_, err := load(envMap(map[string]string{
		"BALNANA_AUTH_MODE":  "magic",
		"BALNANA_PUBLIC_URL": "example.com",
		"BALNANA_SMTP_HOST":  "smtp.example.com",
	}))
	if err == nil {
		t.Fatal("expected error")
	}
	for _, want := range []string{"BALNANA_DATABASE_URL", "BALNANA_AUTH_MODE", "BALNANA_PUBLIC_URL", "BALNANA_SMTP_FROM"} {
		if !strings.Contains(err.Error(), want) {
			t.Errorf("error does not mention %s: %v", want, err)
		}
	}
}

func TestAccountsModeNeedsSignInMethod(t *testing.T) {
	base := map[string]string{
		"BALNANA_DATABASE_URL":  "postgres:///x",
		"BALNANA_AUTH_MODE":     "accounts",
		"BALNANA_AUTH_PASSWORD": "false",
	}
	if _, err := load(envMap(base)); err == nil {
		t.Fatal("expected error without any sign-in method")
	}
	base["BALNANA_OAUTH_OIDC_ISSUER"] = "https://id.example.com"
	base["BALNANA_OAUTH_OIDC_CLIENT_ID"] = "id"
	base["BALNANA_OAUTH_OIDC_SECRET"] = "secret"
	base["BALNANA_OAUTH_OIDC_NAME"] = "Authentik"
	c, err := load(envMap(base))
	if err != nil {
		t.Fatal(err)
	}
	ps := c.OAuthProviders()
	if len(ps) != 1 || ps[0].ID != "oidc" || ps[0].Name != "Authentik" {
		t.Fatalf("providers = %+v", ps)
	}
}

func TestCORSOrigins(t *testing.T) {
	c, err := load(envMap(map[string]string{
		"BALNANA_DATABASE_URL": "postgres:///x",
		"BALNANA_CORS_ORIGINS": " http://localhost:5000/ , https://a.example ,",
	}))
	if err != nil {
		t.Fatal(err)
	}
	if strings.Join(c.CORSOrigins, "|") != "http://localhost:5000|https://a.example" {
		t.Fatalf("got %v", c.CORSOrigins)
	}
}

func TestPush(t *testing.T) {
	c, err := load(envMap(map[string]string{"BALNANA_DATABASE_URL": "postgres:///x"}))
	if err != nil {
		t.Fatal(err)
	}
	if !c.Push || c.PushPrivateEndpoints {
		t.Fatalf("defaults: push %v, private endpoints %v", c.Push, c.PushPrivateEndpoints)
	}
	c, err = load(envMap(map[string]string{
		"BALNANA_DATABASE_URL":           "postgres:///x",
		"BALNANA_PUSH":                   "false",
		"BALNANA_PUSH_PRIVATE_ENDPOINTS": "true",
	}))
	if err != nil {
		t.Fatal(err)
	}
	if c.Push || !c.PushPrivateEndpoints {
		t.Fatalf("push %v, private endpoints %v", c.Push, c.PushPrivateEndpoints)
	}
}

func TestStoredSettings(t *testing.T) {
	t.Setenv("BALNANA_DATABASE_URL", "postgres:///x")
	t.Setenv("BALNANA_PUBLIC_URL", "https://env.example.com")
	stored := map[string]string{
		"BALNANA_PUBLIC_URL":   "https://stored.example.com",
		"BALNANA_AUTH_MODE":    "accounts",
		"BALNANA_SMTP_HOST":    "smtp.example.com",
		"BALNANA_SMTP_FROM":    "Balnana <b@example.com>",
		"BALNANA_RATE_LIMIT":   "1", // not managed: ignored
		"BALNANA_DATABASE_URL": "postgres:///stolen",
	}
	c, err := LoadWith(stored)
	if err != nil {
		t.Fatal(err)
	}
	if c.PublicURL.String() != "https://env.example.com" {
		t.Errorf("the environment must win, got %s", c.PublicURL)
	}
	if c.AuthMode != AuthModeAccounts || !c.SMTP.Enabled() {
		t.Errorf("stored settings not used: %+v", c)
	}
	if c.RateLimit != 600 || c.DatabaseURL != "postgres:///x" {
		t.Errorf("unmanaged settings came from storage: %+v", c)
	}
	if !Environment("BALNANA_PUBLIC_URL") || Environment("BALNANA_AUTH_MODE") {
		t.Error("Environment reports the wrong settings")
	}
}

func TestErrorKeys(t *testing.T) {
	t.Setenv("BALNANA_DATABASE_URL", "postgres:///x")
	_, err := LoadWith(map[string]string{
		"BALNANA_SMTP_HOST":              "smtp.example.com",
		"BALNANA_SMTP_PORT":              "70000",
		"BALNANA_OAUTH_GOOGLE_CLIENT_ID": "id",
		"BALNANA_ANDROID_CERT_SHA256":    "nope",
		"BALNANA_AUTH_MODE":              "accounts",
		"BALNANA_AUTH_PASSWORD":          "false",
		"BALNANA_OAUTH_OIDC_ISSUER":      "issuer",
		"BALNANA_OAUTH_OIDC_CLIENT_ID":   "id",
		"BALNANA_OAUTH_OIDC_SECRET":      "secret",
	})
	keys := ErrorKeys(err)
	slices.Sort(keys)
	want := []string{
		"BALNANA_ANDROID_CERT_SHA256", "BALNANA_OAUTH_GOOGLE_SECRET", "BALNANA_OAUTH_OIDC_ISSUER",
		"BALNANA_SMTP_FROM", "BALNANA_SMTP_PORT",
	}
	if !slices.Equal(keys, want) {
		t.Fatalf("keys = %v, want %v (err %v)", keys, want, err)
	}
}

func TestStartupLeavesManagedSettingsForLater(t *testing.T) {
	t.Setenv("BALNANA_DATABASE_URL", "postgres:///x")
	t.Setenv("BALNANA_AUTH_MODE", "accounts")
	t.Setenv("BALNANA_AUTH_PASSWORD", "false")
	if _, err := Startup(); err != nil {
		t.Fatalf("a stored OAuth provider may complete this: %v", err)
	}
	if _, err := Load(); err == nil {
		t.Fatal("the environment alone has no sign-in method")
	}
	t.Setenv("BALNANA_RATE_LIMIT", "-1")
	if _, err := Startup(); err == nil || !strings.Contains(err.Error(), "BALNANA_RATE_LIMIT") {
		t.Fatalf("want a rate limit error, got %v", err)
	}
}

func TestAndroidFingerprints(t *testing.T) {
	colons := "14:6D:E9:83:C5:73:06:50:D8:EE:B9:95:2F:34:FC:64:16:A0:83:42:E6:1D:BE:A8:8A:04:96:B2:3F:CF:44:E5"
	plain := strings.ToLower(strings.ReplaceAll(colons, ":", ""))
	c, err := load(envMap(map[string]string{
		"BALNANA_DATABASE_URL":        "postgres:///x",
		"BALNANA_ANDROID_CERT_SHA256": colons + ", " + plain,
	}))
	if err != nil {
		t.Fatal(err)
	}
	if !slices.Equal(c.AndroidCertSHA256, []string{colons, colons}) {
		t.Fatalf("got %v", c.AndroidCertSHA256)
	}
}
