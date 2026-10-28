package api

import (
	"context"
	"crypto/rand"
	"crypto/subtle"
	"encoding/json"
	"errors"
	"maps"
	"net/http"
	"os"
	"slices"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"balnana/internal/config"
)

// The server's administrator: one password, set at /admin when the server is
// new, and the settings in config.Managed, saved in the database. An
// environment variable that is set wins over a saved setting.

const (
	adminLifetime = 12 * time.Hour
	// settingsLock serializes saving settings across servers sharing the
	// database (pg_advisory_xact_lock).
	settingsLock = 0x62616c6e // "baln"
	// settingsChannel is the Postgres channel that announces saved settings.
	settingsChannel = "balnana_settings"
	// androidPackage is the Android app's application ID (build.gradle.kts).
	androidPackage = "me.devvillie.balnana"
)

// Setup codes avoid letters and digits that look alike.
const setupCodeAlphabet = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"

// LoadSettings puts the saved settings in force on top of the environment.
// Saved settings that no longer fit the environment (say, a variable set
// since) are left out until an administrator fixes them.
func (s *Server) LoadSettings(ctx context.Context) error {
	stored, err := storedSettings(ctx, s.db)
	if err != nil {
		return err
	}
	cfg, err := config.LoadWith(stored)
	if err != nil {
		envOnly, envErr := config.Load()
		if envErr != nil {
			return errors.Join(err, envErr)
		}
		s.log.Error("saved settings do not fit the environment; using the environment alone until they are fixed at /admin", "err", err)
		cfg = envOnly
	}
	s.apply(cfg)
	return nil
}

// reloadSettings follows settings another server saved.
func (s *Server) reloadSettings(ctx context.Context) {
	if err := s.LoadSettings(ctx); err != nil {
		s.log.Error("reloading settings failed", "err", err)
	}
}

func storedSettings(ctx context.Context, q querier) (map[string]string, error) {
	rows, err := q.Query(ctx, `select key, value from settings`)
	if err != nil {
		return nil, err
	}
	stored := map[string]string{}
	for rows.Next() {
		var k, v string
		if err := rows.Scan(&k, &v); err != nil {
			return nil, err
		}
		stored[k] = v
	}
	return stored, rows.Err()
}

// PrepareAdmin runs at start. While no administrator password is set, it
// says so in the log, and when the server already holds data (it was set up
// before administration existed) makes the setup code that /admin asks for,
// so that whoever happens to open /admin first cannot take the server over.
func (s *Server) PrepareAdmin(ctx context.Context) error {
	tx, err := s.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)
	var needed bool
	var code *string
	err = tx.QueryRow(ctx, `select password_hash is null, setup_code from admin for update`).Scan(&needed, &code)
	if err != nil || !needed {
		return err
	}
	if code == nil {
		var data bool
		err := tx.QueryRow(ctx, `select exists (select 1 from users) or exists (select 1 from groups)`).Scan(&data)
		if err != nil {
			return err
		}
		if data {
			c := newSetupCode()
			if _, err := tx.Exec(ctx, `update admin set setup_code = $1`, c); err != nil {
				return err
			}
			code = &c
		}
	}
	if err := tx.Commit(ctx); err != nil {
		return err
	}
	admin := s.appLink("/admin", nil)
	if code != nil {
		s.log.Warn("no administrator password yet: open "+admin+" to set one, with this setup code", "setup_code", *code)
	} else {
		s.log.Warn("no administrator password yet: open " + admin + " to set one")
	}
	return nil
}

// ResetAdmin forgets the administrator password, for when it is lost, and
// signs every administrator out. /admin then asks for a new password and
// the setup code this returns, which only whoever runs it sees.
func ResetAdmin(ctx context.Context, db *pgxpool.Pool) (string, error) {
	code := newSetupCode()
	return code, pgx.BeginFunc(ctx, db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `update admin set password_hash = null, setup_code = $1`, code); err != nil {
			return err
		}
		_, err := tx.Exec(ctx, `delete from admin_sessions`)
		return err
	})
}

func newSetupCode() string {
	b := make([]byte, 8)
	_, _ = rand.Read(b)
	for i := range b {
		b[i] = setupCodeAlphabet[int(b[i])%len(setupCodeAlphabet)]
	}
	return string(b)
}

// sameSetupCode compares codes as people type them: any case, with spaces
// or dashes.
func sameSetupCode(want, got string) bool {
	got = strings.ToUpper(strings.NewReplacer(" ", "", "-", "").Replace(got))
	return subtle.ConstantTimeCompare([]byte(want), []byte(got)) == 1
}

func (s *Server) AdminSetup(ctx context.Context, req AdminSetupRequestObject) (AdminSetupResponseObject, error) {
	in := req.Body
	if err := validPassword(in.Password); err != nil {
		return nil, err
	}
	hash := hashPassword(in.Password)
	tx, err := s.db.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	var set bool
	var code *string
	if err := tx.QueryRow(ctx, `select password_hash is not null, setup_code from admin for update`).Scan(&set, &code); err != nil {
		return nil, err
	}
	if set {
		return nil, conflict("already_set_up")
	}
	if code != nil && (in.Code == nil || !sameSetupCode(*code, *in.Code)) {
		for range loginMissWeight {
			noteMiss(ctx)
		}
		return nil, forbidden("invalid_setup_code")
	}
	if _, err := tx.Exec(ctx, `update admin set password_hash = $1, setup_code = null`, hash); err != nil {
		return nil, err
	}
	session, err := startAdminSession(ctx, tx)
	if err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	s.log.Info("administrator password set")
	return AdminSetup201JSONResponse(session), nil
}

func (s *Server) AdminLogin(ctx context.Context, req AdminLoginRequestObject) (AdminLoginResponseObject, error) {
	var hash *string
	if err := s.db.QueryRow(ctx, `select password_hash from admin`).Scan(&hash); err != nil {
		return nil, err
	}
	if hash == nil {
		return nil, conflict("setup_required")
	}
	if !checkPassword(*hash, req.Body.Password) {
		for range loginMissWeight {
			noteMiss(ctx)
		}
		return nil, &apiError{status: http.StatusUnauthorized, code: "invalid_credentials"}
	}
	var session AdminSession
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if err := lockAdmin(ctx, tx, *hash, nil); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `delete from admin_sessions where expires_at < now()`); err != nil {
			return err
		}
		var err error
		session, err = startAdminSession(ctx, tx)
		return err
	})
	if err != nil {
		return nil, err
	}
	return AdminLogin200JSONResponse(session), nil
}

// lockAdmin locks the administrator's row for a change a password check
// allowed, and makes sure that password, and the session [token] when there
// is one, still hold. A reset or password change in between supersedes them.
func lockAdmin(ctx context.Context, tx pgx.Tx, checked string, token *string) error {
	var hash *string
	var live bool
	var tokenHash []byte
	if token != nil {
		tokenHash = hashToken(*token)
	}
	err := tx.QueryRow(ctx, `
		select password_hash,
		       $1::bytea is null or exists (select 1 from admin_sessions where token_hash = $1 and expires_at > now())
		from admin for update`, tokenHash).Scan(&hash, &live)
	if err != nil {
		return err
	}
	if hash == nil || *hash != checked {
		return &apiError{status: http.StatusUnauthorized, code: "invalid_credentials"}
	}
	if !live {
		return &apiError{status: http.StatusUnauthorized, code: "admin_required"}
	}
	return nil
}

func startAdminSession(ctx context.Context, q querier) (AdminSession, error) {
	token := secretToken()
	expires := time.Now().Add(adminLifetime).UTC().Truncate(time.Second)
	_, err := q.Exec(ctx, `insert into admin_sessions (token_hash, expires_at) values ($1, $2)`, hashToken(token), expires)
	return AdminSession{Token: token, ExpiresAt: expires}, err
}

// requireAdmin checks the X-Balnana-Admin token.
func (s *Server) requireAdmin(ctx context.Context, token *string) error {
	if token == nil || *token == "" {
		return &apiError{status: http.StatusUnauthorized, code: "admin_required"}
	}
	var ok bool
	err := s.db.QueryRow(ctx, `
		select exists (select 1 from admin_sessions where token_hash = $1 and expires_at > now())`,
		hashToken(*token)).Scan(&ok)
	if err != nil {
		return err
	}
	if !ok {
		noteMiss(ctx)
		return &apiError{status: http.StatusUnauthorized, code: "admin_required"}
	}
	return nil
}

func (s *Server) AdminLogout(ctx context.Context, req AdminLogoutRequestObject) (AdminLogoutResponseObject, error) {
	if t := req.Params.XBalnanaAdmin; t != nil {
		if _, err := s.db.Exec(ctx, `delete from admin_sessions where token_hash = $1`, hashToken(*t)); err != nil {
			return nil, err
		}
	}
	return AdminLogout204Response{}, nil
}

func (s *Server) ChangeAdminPassword(ctx context.Context, req ChangeAdminPasswordRequestObject) (ChangeAdminPasswordResponseObject, error) {
	token := req.Params.XBalnanaAdmin
	if err := s.requireAdmin(ctx, token); err != nil {
		return nil, err
	}
	in := req.Body
	var hash *string
	if err := s.db.QueryRow(ctx, `select password_hash from admin`).Scan(&hash); err != nil {
		return nil, err
	}
	if hash == nil || in.CurrentPassword == nil || !checkPassword(*hash, *in.CurrentPassword) {
		for range loginMissWeight {
			noteMiss(ctx)
		}
		return nil, forbidden("wrong_password")
	}
	if err := validPassword(in.NewPassword); err != nil {
		return nil, err
	}
	next := hashPassword(in.NewPassword)
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if err := lockAdmin(ctx, tx, *hash, token); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `update admin set password_hash = $1`, next); err != nil {
			return err
		}
		_, err := tx.Exec(ctx, `delete from admin_sessions where token_hash <> $1`, hashToken(*token))
		return err
	})
	if err != nil {
		return nil, err
	}
	s.log.Info("administrator password changed")
	return ChangeAdminPassword204Response{}, nil
}

func (s *Server) GetAdminSettings(ctx context.Context, req GetAdminSettingsRequestObject) (GetAdminSettingsResponseObject, error) {
	if err := s.requireAdmin(ctx, req.Params.XBalnanaAdmin); err != nil {
		return nil, err
	}
	stored, err := storedSettings(ctx, s.db)
	if err != nil {
		return nil, err
	}
	return GetAdminSettings200JSONResponse(adminSettings(stored)), nil
}

func (s *Server) UpdateAdminSettings(ctx context.Context, req UpdateAdminSettingsRequestObject) (UpdateAdminSettingsResponseObject, error) {
	if err := s.requireAdmin(ctx, req.Params.XBalnanaAdmin); err != nil {
		return nil, err
	}
	values := req.Body.Values
	var bad []string
	for k := range values {
		if _, ok := config.ManagedSetting(k); !ok || config.Environment(k) {
			bad = append(bad, k)
		}
	}
	if len(bad) > 0 {
		return nil, invalidSettings(bad)
	}

	var cfg *config.Config
	var stored map[string]string
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `select pg_advisory_xact_lock($1)`, settingsLock); err != nil {
			return err
		}
		var err error
		if stored, err = storedSettings(ctx, tx); err != nil {
			return err
		}
		for k, v := range values {
			if v = strings.TrimSpace(v); v == "" {
				delete(stored, k)
			} else {
				stored[k] = v
			}
		}
		if cfg, err = config.LoadWith(stored); err != nil {
			return invalidSettings(config.ErrorKeys(err))
		}
		for k := range values {
			if v, ok := stored[k]; ok {
				_, err = tx.Exec(ctx, `
					insert into settings (key, value) values ($1, $2)
					on conflict (key) do update set value = excluded.value, updated_at = now()`, k, v)
			} else {
				_, err = tx.Exec(ctx, `delete from settings where key = $1`, k)
			}
			if err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	s.apply(cfg)
	s.log.Info("settings changed", "keys", slices.Sorted(maps.Keys(values)))
	return UpdateAdminSettings200JSONResponse(adminSettings(stored)), nil
}

func invalidSettings(keys []string) error {
	slices.Sort(keys)
	return &apiError{status: http.StatusBadRequest, code: "invalid_settings", params: map[string]any{"keys": keys}}
}

// adminSettings describes every Managed setting, with those of each listed
// OpenID Connect provider: what is in force (secrets left out), whether the
// environment sets it, and its default.
func adminSettings(stored map[string]string) AdminSettings {
	out := AdminSettings{Settings: []AdminSetting{}}
	lookup := func(key string) string {
		if config.Environment(key) {
			return strings.TrimSpace(os.Getenv(key))
		}
		return stored[key]
	}
	for _, m := range config.ManagedFor(lookup) {
		v := lookup(m.Key)
		locked := config.Environment(m.Key)
		item := AdminSetting{Key: m.Key, Default: m.Default, Locked: locked, Secret: m.Secret, Set: v != ""}
		if v != "" && !m.Secret {
			item.Value = &v
		}
		out.Settings = append(out.Settings, item)
	}
	return out
}

// assetLinks lets Android builds signed with the configured certificates
// open this server's links in the app without asking (App Links).
func (s *Server) assetLinks(w http.ResponseWriter, r *http.Request) {
	fingerprints := s.conf().AndroidCertSHA256
	if len(fingerprints) == 0 {
		http.NotFound(w, r)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode([]map[string]any{{
		"relation": []string{"delegate_permission/common.handle_all_urls"},
		"target": map[string]any{
			"namespace":                "android_app",
			"package_name":             androidPackage,
			"sha256_cert_fingerprints": fingerprints,
		},
	}})
}
