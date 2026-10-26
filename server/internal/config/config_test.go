package config

import (
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
