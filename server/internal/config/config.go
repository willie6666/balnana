// Package config loads server settings from BALNANA_* environment variables.
// See .env.example at the repo root for the full list.
package config

import (
	"errors"
	"fmt"
	"log/slog"
	"net/url"
	"os"
	"strconv"
	"strings"
)

type AuthMode string

const (
	AuthModeLink     AuthMode = "link"
	AuthModeAccounts AuthMode = "accounts"
)

type Signup string

const (
	SignupOpen       Signup = "open"
	SignupInviteOnly Signup = "invite_only"
	SignupClosed     Signup = "closed"
)

type SMTP struct {
	Host     string
	Port     int
	User     string
	Password string
	From     string
}

func (s SMTP) Enabled() bool { return s.Host != "" }

type OAuthClient struct {
	ClientID     string
	ClientSecret string
}

type OIDC struct {
	OAuthClient
	Issuer string
	Name   string // shown on the sign-in button
}

// UpstreamSourceURL is the official Balnana repository, the default source link.
const UpstreamSourceURL = "https://github.com/willie6666/balnana"

type Config struct {
	Listen      string
	DatabaseURL string
	PublicURL   *url.URL
	LogLevel    slog.Level

	// SourceURL is where users can get this server's source code, as the AGPL
	// asks of anyone running a modified version.
	SourceURL *url.URL

	// WebDir serves the Flutter web build from disk instead of the embedded copy.
	WebDir string
	// CORSOrigins lists extra web origins allowed to call the API ("*" allows any).
	CORSOrigins []string
	// RateLimit caps API requests per client per minute (0: no cap).
	RateLimit int
	// TrustProxy takes the client address from X-Forwarded-For / X-Real-IP,
	// for servers behind a reverse proxy.
	TrustProxy bool

	AuthMode   AuthMode
	Password   bool
	Signup     Signup
	LinkGroups bool
	SMTP       SMTP
	Google     *OAuthClient
	OIDC       *OIDC
}

// Load reads the environment. It returns every problem at once so a
// misconfigured container fails with one complete message.
func Load() (*Config, error) {
	return load(os.Getenv)
}

func load(getenv func(string) string) (*Config, error) {
	e := env{get: getenv}
	c := &Config{
		Listen:      e.str("BALNANA_LISTEN", ":8080"),
		DatabaseURL: e.str("BALNANA_DATABASE_URL", getenv("DATABASE_URL")),
		WebDir:      e.str("BALNANA_WEB_DIR", ""),
		CORSOrigins: e.list("BALNANA_CORS_ORIGINS"),
		RateLimit:   e.int("BALNANA_RATE_LIMIT", 600),
		TrustProxy:  e.bool("BALNANA_TRUST_PROXY", false),
		AuthMode:    AuthMode(e.str("BALNANA_AUTH_MODE", string(AuthModeLink))),
		Password:    e.bool("BALNANA_AUTH_PASSWORD", true),
		Signup:      Signup(e.str("BALNANA_AUTH_SIGNUP", string(SignupOpen))),
		LinkGroups:  e.bool("BALNANA_LINK_GROUPS", true),
		SMTP: SMTP{
			Host:     e.str("BALNANA_SMTP_HOST", ""),
			Port:     e.int("BALNANA_SMTP_PORT", 587),
			User:     e.str("BALNANA_SMTP_USER", ""),
			Password: e.str("BALNANA_SMTP_PASSWORD", ""),
			From:     e.str("BALNANA_SMTP_FROM", ""),
		},
	}

	if c.DatabaseURL == "" {
		e.fail("BALNANA_DATABASE_URL is required")
	}

	publicURL := e.str("BALNANA_PUBLIC_URL", "http://localhost:8080")
	if u, err := url.Parse(publicURL); err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Host == "" {
		e.fail("BALNANA_PUBLIC_URL must be an absolute http(s) URL, got %q", publicURL)
	} else {
		u.Path = strings.TrimSuffix(u.Path, "/")
		c.PublicURL = u
	}

	sourceURL := e.str("BALNANA_SOURCE_URL", UpstreamSourceURL)
	if u, err := url.Parse(sourceURL); err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Host == "" {
		e.fail("BALNANA_SOURCE_URL must be an absolute http(s) URL, got %q", sourceURL)
	} else {
		c.SourceURL = u
	}

	switch lvl := strings.ToLower(e.str("BALNANA_LOG_LEVEL", "info")); lvl {
	case "debug":
		c.LogLevel = slog.LevelDebug
	case "info":
		c.LogLevel = slog.LevelInfo
	case "warn":
		c.LogLevel = slog.LevelWarn
	case "error":
		c.LogLevel = slog.LevelError
	default:
		e.fail("BALNANA_LOG_LEVEL must be debug, info, warn or error, got %q", lvl)
	}

	switch c.AuthMode {
	case AuthModeLink, AuthModeAccounts:
	default:
		e.fail("BALNANA_AUTH_MODE must be link or accounts, got %q", c.AuthMode)
	}
	switch c.Signup {
	case SignupOpen, SignupInviteOnly, SignupClosed:
	default:
		e.fail("BALNANA_AUTH_SIGNUP must be open, invite_only or closed, got %q", c.Signup)
	}

	if c.RateLimit < 0 {
		e.fail("BALNANA_RATE_LIMIT must be 0 (no limit) or more, got %d", c.RateLimit)
	}

	if c.SMTP.Enabled() && c.SMTP.From == "" {
		e.fail("BALNANA_SMTP_FROM is required when BALNANA_SMTP_HOST is set")
	}

	if id := e.str("BALNANA_OAUTH_GOOGLE_CLIENT_ID", ""); id != "" {
		c.Google = &OAuthClient{ClientID: id, ClientSecret: e.str("BALNANA_OAUTH_GOOGLE_SECRET", "")}
		if c.Google.ClientSecret == "" {
			e.fail("BALNANA_OAUTH_GOOGLE_SECRET is required when BALNANA_OAUTH_GOOGLE_CLIENT_ID is set")
		}
	}
	if issuer := e.str("BALNANA_OAUTH_OIDC_ISSUER", ""); issuer != "" {
		c.OIDC = &OIDC{
			OAuthClient: OAuthClient{
				ClientID:     e.str("BALNANA_OAUTH_OIDC_CLIENT_ID", ""),
				ClientSecret: e.str("BALNANA_OAUTH_OIDC_SECRET", ""),
			},
			Issuer: issuer,
			Name:   e.str("BALNANA_OAUTH_OIDC_NAME", "OpenID Connect"),
		}
		if c.OIDC.ClientID == "" || c.OIDC.ClientSecret == "" {
			e.fail("BALNANA_OAUTH_OIDC_CLIENT_ID and BALNANA_OAUTH_OIDC_SECRET are required when BALNANA_OAUTH_OIDC_ISSUER is set")
		}
	}

	if c.AuthMode == AuthModeAccounts && !c.Password && c.Google == nil && c.OIDC == nil {
		e.fail("accounts mode needs at least one sign-in method: BALNANA_AUTH_PASSWORD=true or an OAuth provider")
	}

	if len(e.errs) > 0 {
		return nil, errors.Join(e.errs...)
	}
	return c, nil
}

// OAuthProvider is a sign-in provider shown in the app.
type OAuthProvider struct {
	ID   string
	Name string
}

func (c *Config) OAuthProviders() []OAuthProvider {
	var ps []OAuthProvider
	if c.Google != nil {
		ps = append(ps, OAuthProvider{ID: "google", Name: "Google"})
	}
	if c.OIDC != nil {
		ps = append(ps, OAuthProvider{ID: "oidc", Name: c.OIDC.Name})
	}
	return ps
}

type env struct {
	get  func(string) string
	errs []error
}

func (e *env) fail(format string, args ...any) {
	e.errs = append(e.errs, fmt.Errorf(format, args...))
}

func (e *env) str(key, def string) string {
	if v := strings.TrimSpace(e.get(key)); v != "" {
		return v
	}
	return def
}

func (e *env) bool(key string, def bool) bool {
	v := e.str(key, "")
	if v == "" {
		return def
	}
	b, err := strconv.ParseBool(v)
	if err != nil {
		e.fail("%s must be true or false, got %q", key, v)
		return def
	}
	return b
}

func (e *env) int(key string, def int) int {
	v := e.str(key, "")
	if v == "" {
		return def
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		e.fail("%s must be an integer, got %q", key, v)
		return def
	}
	return n
}

func (e *env) list(key string) []string {
	var out []string
	for _, part := range strings.Split(e.str(key, ""), ",") {
		if part = strings.TrimSpace(part); part != "" {
			out = append(out, strings.TrimSuffix(part, "/"))
		}
	}
	return out
}
