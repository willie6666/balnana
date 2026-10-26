// Package config loads server settings from BALNANA_* environment variables
// and, for the settings in Managed, from what an administrator saved at
// /admin. See .env.example at the repo root for the full list.
package config

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/mail"
	"net/url"
	"os"
	"slices"
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

// FCMAccount is the Firebase service account that sends push notifications.
type FCMAccount struct {
	ProjectID   string `json:"project_id"`
	ClientEmail string `json:"client_email"`
	PrivateKey  string `json:"private_key"`
	TokenURI    string `json:"token_uri"`
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
	// PrivacyURL is the server's own privacy policy; nil shows the app's
	// built-in one.
	PrivacyURL *url.URL

	// WebDir serves the Flutter web build from disk instead of the embedded copy.
	WebDir string
	// CORSOrigins lists extra web origins allowed to call the API ("*" allows any).
	CORSOrigins []string
	// RateLimit caps API requests per client per minute (0: no cap).
	RateLimit int
	// TrustProxy takes the client address from X-Forwarded-For / X-Real-IP,
	// for servers behind a reverse proxy.
	TrustProxy bool

	AuthMode AuthMode
	Password bool
	// RequireEmail false lets password accounts sign up with a username and
	// no email address.
	RequireEmail bool
	Signup       Signup
	LinkGroups   bool
	SMTP         SMTP
	Google       *OAuthClient
	OIDC         *OIDC

	// FCM sends push notifications to the Android app; nil turns them off.
	FCM *FCMAccount

	// AndroidCertSHA256 lists the signing certificates of Android builds that
	// may open this server's links (App Links), as AB:CD:... fingerprints.
	AndroidCertSHA256 []string
}

// Setting is one setting an administrator can change at /admin.
type Setting struct {
	Key     string
	Default string
	// Secret values are never sent back to the admin page.
	Secret bool
}

// Managed lists the settings an administrator can change at /admin, in the
// order the page shows them. One given as an environment variable stays as
// the environment says.
var Managed = []Setting{
	{Key: "BALNANA_PUBLIC_URL", Default: "http://localhost:8080"},
	{Key: "BALNANA_SOURCE_URL", Default: UpstreamSourceURL},
	{Key: "BALNANA_PRIVACY_URL"},
	{Key: "BALNANA_AUTH_MODE", Default: string(AuthModeLink)},
	{Key: "BALNANA_AUTH_PASSWORD", Default: "true"},
	{Key: "BALNANA_AUTH_REQUIRE_EMAIL", Default: "true"},
	{Key: "BALNANA_AUTH_SIGNUP", Default: string(SignupOpen)},
	{Key: "BALNANA_LINK_GROUPS", Default: "true"},
	{Key: "BALNANA_SMTP_HOST"},
	{Key: "BALNANA_SMTP_PORT", Default: "587"},
	{Key: "BALNANA_SMTP_USER"},
	{Key: "BALNANA_SMTP_PASSWORD", Secret: true},
	{Key: "BALNANA_SMTP_FROM"},
	{Key: "BALNANA_OAUTH_GOOGLE_CLIENT_ID"},
	{Key: "BALNANA_OAUTH_GOOGLE_SECRET", Secret: true},
	{Key: "BALNANA_OAUTH_OIDC_ISSUER"},
	{Key: "BALNANA_OAUTH_OIDC_CLIENT_ID"},
	{Key: "BALNANA_OAUTH_OIDC_SECRET", Secret: true},
	{Key: "BALNANA_OAUTH_OIDC_NAME", Default: "OpenID Connect"},
	{Key: "BALNANA_ANDROID_CERT_SHA256"},
}

// ManagedSetting finds key in Managed.
func ManagedSetting(key string) (Setting, bool) {
	for _, m := range Managed {
		if m.Key == key {
			return m, true
		}
	}
	return Setting{}, false
}

// FieldError is a problem with one setting.
type FieldError struct {
	Key string
	msg string
}

func (e *FieldError) Error() string { return e.msg }

// ErrorKeys lists the settings an error from Load or LoadWith is about.
func ErrorKeys(err error) []string {
	var keys []string
	var walk func(error)
	walk = func(err error) {
		if fe, ok := err.(*FieldError); ok {
			if !slices.Contains(keys, fe.Key) {
				keys = append(keys, fe.Key)
			}
			return
		}
		if j, ok := err.(interface{ Unwrap() []error }); ok {
			for _, e := range j.Unwrap() {
				walk(e)
			}
		}
	}
	walk(err)
	return keys
}

// Environment reports whether key is set as an environment variable, which
// an administrator then cannot change.
func Environment(key string) bool {
	return strings.TrimSpace(os.Getenv(key)) != ""
}

// Load reads the environment alone. It returns every problem at once so a
// misconfigured container fails with one complete message.
func Load() (*Config, error) {
	return LoadWith(nil)
}

// LoadWith reads the environment, and stored (the settings an administrator
// saved) for the Managed settings the environment leaves unset.
func LoadWith(stored map[string]string) (*Config, error) {
	c, err := load(func(key string) string {
		if v := os.Getenv(key); strings.TrimSpace(v) != "" {
			return v
		}
		if _, ok := ManagedSetting(key); ok {
			return stored[key]
		}
		return ""
	})
	if err != nil {
		return nil, err
	}
	return c, nil
}

// Startup checks what the server needs before it can read stored settings:
// the database, where to listen, logging and the other settings only the
// environment sets. Problems with Managed settings wait for LoadWith, as
// stored settings may complete them.
func Startup() (*Config, error) {
	c, err := load(os.Getenv)
	var errs []error
	for _, e := range unwrapAll(err) {
		if fe, ok := e.(*FieldError); ok {
			if _, managed := ManagedSetting(fe.Key); managed {
				continue
			}
		}
		errs = append(errs, e)
	}
	if len(errs) > 0 {
		return nil, errors.Join(errs...)
	}
	return c, nil
}

func unwrapAll(err error) []error {
	if err == nil {
		return nil
	}
	if j, ok := err.(interface{ Unwrap() []error }); ok {
		return j.Unwrap()
	}
	return []error{err}
}

// load always returns a Config, partly filled when there are errors.
func load(getenv func(string) string) (*Config, error) {
	e := env{get: getenv}
	c := &Config{
		Listen:       e.str("BALNANA_LISTEN", ":8080"),
		DatabaseURL:  e.str("BALNANA_DATABASE_URL", getenv("DATABASE_URL")),
		WebDir:       e.str("BALNANA_WEB_DIR", ""),
		CORSOrigins:  e.list("BALNANA_CORS_ORIGINS"),
		RateLimit:    e.int("BALNANA_RATE_LIMIT", 600),
		TrustProxy:   e.bool("BALNANA_TRUST_PROXY", false),
		AuthMode:     AuthMode(e.managed("BALNANA_AUTH_MODE")),
		Password:     e.managedBool("BALNANA_AUTH_PASSWORD"),
		RequireEmail: e.managedBool("BALNANA_AUTH_REQUIRE_EMAIL"),
		Signup:       Signup(e.managed("BALNANA_AUTH_SIGNUP")),
		LinkGroups:   e.managedBool("BALNANA_LINK_GROUPS"),
		SMTP: SMTP{
			Host:     e.managed("BALNANA_SMTP_HOST"),
			Port:     e.int("BALNANA_SMTP_PORT", 587),
			User:     e.managed("BALNANA_SMTP_USER"),
			Password: e.managed("BALNANA_SMTP_PASSWORD"),
			From:     e.managed("BALNANA_SMTP_FROM"),
		},
	}

	if c.DatabaseURL == "" {
		e.fail("BALNANA_DATABASE_URL", "BALNANA_DATABASE_URL is required")
	} else if pw := getenv("BALNANA_DATABASE_PASSWORD"); pw != "" {
		// Given apart, the password needs no escaping to go into the URL.
		u, err := url.Parse(c.DatabaseURL)
		if err != nil || (u.Scheme != "postgres" && u.Scheme != "postgresql") {
			e.fail("BALNANA_DATABASE_PASSWORD", "BALNANA_DATABASE_PASSWORD needs a postgres:// BALNANA_DATABASE_URL")
		} else {
			u.User = url.UserPassword(u.User.Username(), pw)
			c.DatabaseURL = u.String()
		}
	}

	publicURL := e.managed("BALNANA_PUBLIC_URL")
	if u, err := url.Parse(publicURL); err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Host == "" {
		e.fail("BALNANA_PUBLIC_URL", "BALNANA_PUBLIC_URL must be an absolute http(s) URL, got %q", publicURL)
	} else {
		u.Path = strings.TrimSuffix(u.Path, "/")
		c.PublicURL = u
	}

	sourceURL := e.managed("BALNANA_SOURCE_URL")
	if u, err := url.Parse(sourceURL); err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Host == "" {
		e.fail("BALNANA_SOURCE_URL", "BALNANA_SOURCE_URL must be an absolute http(s) URL, got %q", sourceURL)
	} else {
		c.SourceURL = u
	}

	if privacyURL := e.managed("BALNANA_PRIVACY_URL"); privacyURL != "" {
		if u, err := url.Parse(privacyURL); err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Host == "" {
			e.fail("BALNANA_PRIVACY_URL", "BALNANA_PRIVACY_URL must be an absolute http(s) URL, got %q", privacyURL)
		} else {
			c.PrivacyURL = u
		}
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
		e.fail("BALNANA_LOG_LEVEL", "BALNANA_LOG_LEVEL must be debug, info, warn or error, got %q", lvl)
	}

	switch c.AuthMode {
	case AuthModeLink, AuthModeAccounts:
	default:
		e.fail("BALNANA_AUTH_MODE", "BALNANA_AUTH_MODE must be link or accounts, got %q", c.AuthMode)
	}
	switch c.Signup {
	case SignupOpen, SignupInviteOnly, SignupClosed:
	default:
		e.fail("BALNANA_AUTH_SIGNUP", "BALNANA_AUTH_SIGNUP must be open, invite_only or closed, got %q", c.Signup)
	}

	if c.RateLimit < 0 {
		e.fail("BALNANA_RATE_LIMIT", "BALNANA_RATE_LIMIT must be 0 (no limit) or more, got %d", c.RateLimit)
	}

	if c.SMTP.Port < 1 || c.SMTP.Port > 65535 {
		e.fail("BALNANA_SMTP_PORT", "BALNANA_SMTP_PORT must be a port number, got %d", c.SMTP.Port)
	}
	if c.SMTP.Enabled() {
		if _, err := mail.ParseAddress(c.SMTP.From); err != nil {
			e.fail("BALNANA_SMTP_FROM", "BALNANA_SMTP_FROM must be an address such as \"Balnana <balnana@example.com>\" when BALNANA_SMTP_HOST is set, got %q", c.SMTP.From)
		}
	}

	if id := e.managed("BALNANA_OAUTH_GOOGLE_CLIENT_ID"); id != "" {
		c.Google = &OAuthClient{ClientID: id, ClientSecret: e.managed("BALNANA_OAUTH_GOOGLE_SECRET")}
		if c.Google.ClientSecret == "" {
			e.fail("BALNANA_OAUTH_GOOGLE_SECRET", "BALNANA_OAUTH_GOOGLE_SECRET is required when BALNANA_OAUTH_GOOGLE_CLIENT_ID is set")
		}
	}
	if issuer := e.managed("BALNANA_OAUTH_OIDC_ISSUER"); issuer != "" {
		c.OIDC = &OIDC{
			OAuthClient: OAuthClient{
				ClientID:     e.managed("BALNANA_OAUTH_OIDC_CLIENT_ID"),
				ClientSecret: e.managed("BALNANA_OAUTH_OIDC_SECRET"),
			},
			Issuer: issuer,
			Name:   e.managed("BALNANA_OAUTH_OIDC_NAME"),
		}
		if u, err := url.Parse(issuer); err != nil || u.Scheme != "https" && u.Scheme != "http" || u.Host == "" {
			e.fail("BALNANA_OAUTH_OIDC_ISSUER", "BALNANA_OAUTH_OIDC_ISSUER must be an absolute http(s) URL, got %q", issuer)
		}
		if c.OIDC.ClientID == "" {
			e.fail("BALNANA_OAUTH_OIDC_CLIENT_ID", "BALNANA_OAUTH_OIDC_CLIENT_ID is required when BALNANA_OAUTH_OIDC_ISSUER is set")
		}
		if c.OIDC.ClientSecret == "" {
			e.fail("BALNANA_OAUTH_OIDC_SECRET", "BALNANA_OAUTH_OIDC_SECRET is required when BALNANA_OAUTH_OIDC_ISSUER is set")
		}
	}

	if path := e.str("BALNANA_FCM_CREDENTIALS", ""); path != "" {
		if a, err := loadFCMAccount(path); err != nil {
			e.fail("BALNANA_FCM_CREDENTIALS", "BALNANA_FCM_CREDENTIALS: %v", err)
		} else {
			c.FCM = a
		}
	}

	if c.AuthMode == AuthModeAccounts && !c.Password && c.Google == nil && c.OIDC == nil {
		e.fail("BALNANA_AUTH_MODE", "accounts mode needs at least one sign-in method: BALNANA_AUTH_PASSWORD=true or an OAuth provider")
	}

	for _, f := range e.list("BALNANA_ANDROID_CERT_SHA256") {
		if fp, ok := fingerprint(f); ok {
			c.AndroidCertSHA256 = append(c.AndroidCertSHA256, fp)
		} else {
			e.fail("BALNANA_ANDROID_CERT_SHA256", "BALNANA_ANDROID_CERT_SHA256 must list SHA-256 certificate fingerprints (64 hex digits each), got %q", f)
		}
	}

	if len(e.errs) > 0 {
		return c, errors.Join(e.errs...)
	}
	return c, nil
}

// fingerprint normalizes a SHA-256 certificate fingerprint to AB:CD:...,
// the form Android's assetlinks.json wants. keytool and apksigner print it
// with colons; some tools leave them out.
func fingerprint(s string) (string, bool) {
	h := strings.ToUpper(strings.ReplaceAll(s, ":", ""))
	b, err := hex.DecodeString(h)
	if err != nil || len(b) != sha256.Size {
		return "", false
	}
	parts := make([]string, len(b))
	for i := range b {
		parts[i] = h[2*i : 2*i+2]
	}
	return strings.Join(parts, ":"), true
}

// loadFCMAccount reads a service account key file downloaded from the
// Firebase console (Project settings, Service accounts).
func loadFCMAccount(path string) (*FCMAccount, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var a struct {
		Type string `json:"type"`
		FCMAccount
	}
	if err := json.Unmarshal(data, &a); err != nil {
		return nil, fmt.Errorf("%s is not a service account key: %v", path, err)
	}
	if a.Type != "service_account" || a.ProjectID == "" || a.ClientEmail == "" || a.PrivateKey == "" {
		return nil, fmt.Errorf("%s is not a service account key", path)
	}
	if a.TokenURI == "" {
		a.TokenURI = "https://oauth2.googleapis.com/token"
	}
	return &a.FCMAccount, nil
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

func (e *env) fail(key, format string, args ...any) {
	e.errs = append(e.errs, &FieldError{Key: key, msg: fmt.Sprintf(format, args...)})
}

// managed reads a Managed setting, falling back on its default.
func (e *env) managed(key string) string {
	m, _ := ManagedSetting(key)
	return e.str(key, m.Default)
}

func (e *env) managedBool(key string) bool {
	m, _ := ManagedSetting(key)
	def, _ := strconv.ParseBool(m.Default)
	return e.bool(key, def)
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
		e.fail(key, "%s must be true or false, got %q", key, v)
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
		e.fail(key, "%s must be an integer, got %q", key, v)
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
