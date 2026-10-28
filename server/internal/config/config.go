// Package config loads server settings from BALNANA_* environment variables
// and, for the settings in Managed, from what an administrator saved at
// /admin. See .env.example at the repo root for the full list.
package config

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"log/slog"
	"net/mail"
	"net/url"
	"os"
	"regexp"
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
	// AllowPlaintext sends mail without TLS to a server that does not offer
	// STARTTLS. Off, mail goes unencrypted only to this machine.
	AllowPlaintext bool
}

func (s SMTP) Enabled() bool { return s.Host != "" }

type OAuthClient struct {
	ClientID     string
	ClientSecret string
	// TrustEmail lets the provider's word that someone owns an address
	// stand for proof: their sign-in joins the account with that address.
	// Off, an address with an account must be linked from that account.
	TrustEmail bool
}

// OIDC is an OpenID Connect provider, one of BALNANA_OAUTH_OIDC_PROVIDERS.
type OIDC struct {
	OAuthClient
	// ID names the provider in its settings and its redirect URI.
	ID     string
	Issuer string
	Name   string // shown on the sign-in button
}

// oidcID is an OpenID Connect provider's ID. It has no underscores, so each
// one has settings of its own (see OIDCKey).
var oidcID = regexp.MustCompile(`^[a-z0-9][a-z0-9-]{0,31}$`)

// The settings of each OpenID Connect provider, as OIDCKey names them.
var oidcFields = []Setting{
	{Key: "ISSUER"},
	{Key: "CLIENT_ID"},
	{Key: "SECRET", Secret: true},
	{Key: "NAME"},
	{Key: "TRUST_EMAIL", Default: "false"},
}

// OIDCKey is the setting field (ISSUER, CLIENT_ID, ...) of the OpenID
// Connect provider id: BALNANA_OAUTH_OIDC_<ID>_<FIELD>.
func OIDCKey(id, field string) string {
	return "BALNANA_OAUTH_OIDC_" + strings.ToUpper(strings.ReplaceAll(id, "-", "_")) + "_" + field
}

// UpstreamSourceURL is the official Balnana repository, the default source link.
const UpstreamSourceURL = "https://github.com/willie6666/balnana"

// DefaultMapTiles is OpenStreetMap's own tile server, fine for light use under
// its tile usage policy.
const DefaultMapTiles = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"

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
	// MapTiles is the template ({z}/{x}/{y}) the app loads map tiles from;
	// empty turns maps off.
	MapTiles string
	// MapAttribution credits the map data, shown on every map.
	MapAttribution string

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
	// RequireVerified keeps an account whose address is not confirmed from
	// everything but confirming it, so it never holds anything a provider
	// sign-in with that address would take over.
	RequireVerified bool
	Signup          Signup
	LinkGroups      bool
	SMTP            SMTP
	Google          *OAuthClient
	OIDC            []OIDC

	// Push sends Web Push notifications to the app through UnifiedPush.
	Push bool
	// PushPrivateEndpoints lets phones subscribe with an http endpoint or one
	// on a private address, such as a ntfy server on the same network.
	PushPrivateEndpoints bool

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
	{Key: "BALNANA_MAP_TILES", Default: DefaultMapTiles},
	{Key: "BALNANA_MAP_ATTRIBUTION", Default: "© OpenStreetMap contributors"},
	{Key: "BALNANA_AUTH_MODE", Default: string(AuthModeLink)},
	{Key: "BALNANA_AUTH_PASSWORD", Default: "true"},
	{Key: "BALNANA_AUTH_REQUIRE_EMAIL", Default: "true"},
	{Key: "BALNANA_AUTH_REQUIRE_VERIFIED", Default: "false"},
	{Key: "BALNANA_AUTH_SIGNUP", Default: string(SignupOpen)},
	{Key: "BALNANA_LINK_GROUPS", Default: "true"},
	{Key: "BALNANA_SMTP_HOST"},
	{Key: "BALNANA_SMTP_PORT", Default: "587"},
	{Key: "BALNANA_SMTP_USER"},
	{Key: "BALNANA_SMTP_PASSWORD", Secret: true},
	{Key: "BALNANA_SMTP_FROM"},
	{Key: "BALNANA_OAUTH_GOOGLE_CLIENT_ID"},
	{Key: "BALNANA_OAUTH_GOOGLE_SECRET", Secret: true},
	{Key: "BALNANA_OAUTH_GOOGLE_TRUST_EMAIL", Default: "true"},
	// Each provider listed has the settings in oidcFields; see OIDCKey.
	{Key: "BALNANA_OAUTH_OIDC_PROVIDERS"},
	{Key: "BALNANA_ANDROID_CERT_SHA256"},
}

// ManagedSetting finds key in Managed, or among the settings any OpenID
// Connect provider would have.
func ManagedSetting(key string) (Setting, bool) {
	for _, m := range Managed {
		if m.Key == key {
			return m, true
		}
	}
	if rest, ok := strings.CutPrefix(key, "BALNANA_OAUTH_OIDC_"); ok {
		for _, f := range oidcFields {
			id, ok := strings.CutSuffix(rest, "_"+f.Key)
			if ok && oidcID.MatchString(strings.ToLower(strings.ReplaceAll(id, "_", "-"))) {
				return Setting{Key: key, Default: f.Default, Secret: f.Secret}, true
			}
		}
	}
	return Setting{}, false
}

// ManagedFor is Managed with the settings of each OpenID Connect provider
// that lookup (the environment, then what was saved) lists, after the list.
func ManagedFor(lookup func(string) string) []Setting {
	var out []Setting
	for _, m := range Managed {
		out = append(out, m)
		if m.Key == "BALNANA_OAUTH_OIDC_PROVIDERS" {
			for _, id := range splitList(lookup(m.Key)) {
				if !oidcID.MatchString(id) {
					continue
				}
				for _, f := range oidcFields {
					out = append(out, Setting{Key: OIDCKey(id, f.Key), Default: f.Default, Secret: f.Secret})
				}
			}
		}
	}
	return out
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
		Listen:          e.str("BALNANA_LISTEN", ":8080"),
		DatabaseURL:     e.str("BALNANA_DATABASE_URL", getenv("DATABASE_URL")),
		WebDir:          e.str("BALNANA_WEB_DIR", ""),
		CORSOrigins:     e.list("BALNANA_CORS_ORIGINS"),
		RateLimit:       e.int("BALNANA_RATE_LIMIT", 600),
		TrustProxy:      e.bool("BALNANA_TRUST_PROXY", false),
		Push:            e.bool("BALNANA_PUSH", true),
		AuthMode:        AuthMode(e.managed("BALNANA_AUTH_MODE")),
		Password:        e.managedBool("BALNANA_AUTH_PASSWORD"),
		RequireEmail:    e.managedBool("BALNANA_AUTH_REQUIRE_EMAIL"),
		RequireVerified: e.managedBool("BALNANA_AUTH_REQUIRE_VERIFIED"),
		Signup:          Signup(e.managed("BALNANA_AUTH_SIGNUP")),
		LinkGroups:      e.managedBool("BALNANA_LINK_GROUPS"),
		SMTP: SMTP{
			Host:     e.managed("BALNANA_SMTP_HOST"),
			Port:     e.int("BALNANA_SMTP_PORT", 587),
			User:     e.managed("BALNANA_SMTP_USER"),
			Password: e.managed("BALNANA_SMTP_PASSWORD"),
			From:     e.managed("BALNANA_SMTP_FROM"),
			// Only from the environment: it lowers the protection of the
			// links in emails, which /admin should not do in passing.
			AllowPlaintext: e.bool("BALNANA_SMTP_ALLOW_PLAINTEXT", false),
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

	if tiles := e.managed("BALNANA_MAP_TILES"); tiles != "" && !strings.EqualFold(tiles, "off") {
		u, err := url.Parse(strings.NewReplacer("{z}", "0", "{x}", "0", "{y}", "0").Replace(tiles))
		if err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Host == "" ||
			!strings.Contains(tiles, "{z}") || !strings.Contains(tiles, "{x}") || !strings.Contains(tiles, "{y}") {
			e.fail("BALNANA_MAP_TILES",
				"BALNANA_MAP_TILES must be an http(s) URL with {z}, {x} and {y}, or off, got %q", tiles)
		} else {
			c.MapTiles = tiles
			c.MapAttribution = e.managed("BALNANA_MAP_ATTRIBUTION")
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
		c.Google = &OAuthClient{
			ClientID:     id,
			ClientSecret: e.managed("BALNANA_OAUTH_GOOGLE_SECRET"),
			TrustEmail:   e.managedBool("BALNANA_OAUTH_GOOGLE_TRUST_EMAIL"),
		}
		if c.Google.ClientSecret == "" {
			e.fail("BALNANA_OAUTH_GOOGLE_SECRET", "BALNANA_OAUTH_GOOGLE_SECRET is required when BALNANA_OAUTH_GOOGLE_CLIENT_ID is set")
		}
	}
	for _, id := range e.list("BALNANA_OAUTH_OIDC_PROVIDERS") {
		if !oidcID.MatchString(id) || id == "google" {
			e.fail("BALNANA_OAUTH_OIDC_PROVIDERS", "BALNANA_OAUTH_OIDC_PROVIDERS must list IDs of lower case letters, digits and dashes, other than google, got %q", id)
			continue
		}
		if slices.ContainsFunc(c.OIDC, func(o OIDC) bool { return o.ID == id }) {
			e.fail("BALNANA_OAUTH_OIDC_PROVIDERS", "BALNANA_OAUTH_OIDC_PROVIDERS lists %q twice", id)
			continue
		}
		key := func(field string) string { return OIDCKey(id, field) }
		o := OIDC{
			OAuthClient: OAuthClient{
				ClientID:     e.managed(key("CLIENT_ID")),
				ClientSecret: e.managed(key("SECRET")),
				TrustEmail:   e.managedBool(key("TRUST_EMAIL")),
			},
			ID:     id,
			Issuer: e.managed(key("ISSUER")),
			Name:   e.str(key("NAME"), id),
		}
		if u, err := url.Parse(o.Issuer); err != nil || u.Scheme != "https" && u.Scheme != "http" || u.Host == "" {
			e.fail(key("ISSUER"), "%s must be an absolute http(s) URL, got %q", key("ISSUER"), o.Issuer)
		}
		if o.ClientID == "" {
			e.fail(key("CLIENT_ID"), "%s is required when BALNANA_OAUTH_OIDC_PROVIDERS lists %s", key("CLIENT_ID"), id)
		}
		if o.ClientSecret == "" {
			e.fail(key("SECRET"), "%s is required when BALNANA_OAUTH_OIDC_PROVIDERS lists %s", key("SECRET"), id)
		}
		c.OIDC = append(c.OIDC, o)
	}

	// Confirming an address takes an email. An account without an address
	// has nothing to confirm and is not held back.
	if c.RequireVerified && c.AuthMode == AuthModeAccounts && !c.SMTP.Enabled() {
		e.fail("BALNANA_AUTH_REQUIRE_VERIFIED", "BALNANA_AUTH_REQUIRE_VERIFIED needs email: set BALNANA_SMTP_HOST")
	}

	c.PushPrivateEndpoints = e.bool("BALNANA_PUSH_PRIVATE_ENDPOINTS", false)

	if c.AuthMode == AuthModeAccounts && !c.Password && c.Google == nil && len(c.OIDC) == 0 {
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
	for _, o := range c.OIDC {
		ps = append(ps, OAuthProvider{ID: o.ID, Name: o.Name})
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
	return splitList(e.str(key, ""))
}

func splitList(s string) []string {
	var out []string
	for _, part := range strings.Split(s, ",") {
		if part = strings.TrimSpace(part); part != "" {
			out = append(out, strings.TrimSuffix(part, "/"))
		}
	}
	return out
}
