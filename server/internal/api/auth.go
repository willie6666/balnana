package api

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"net/http"
	"net/mail"
	"net/url"
	"regexp"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"balnana/internal/config"
)

const (
	sessionCookie   = "balnana_session"
	sessionLifetime = 90 * 24 * time.Hour
	// Sessions are extended at most this often, to spare the database a write
	// on every request.
	sessionTouchEvery = time.Hour
	maxEmailLen       = 254
	// A failed sign-in counts as this many misses for the rate limiter.
	loginMissWeight = 5
)

var (
	localeTag    = regexp.MustCompile(`^[a-zA-Z]{2,3}([-_][a-zA-Z0-9]{2,8}){0,3}$`)
	usernameRule = regexp.MustCompile(`^[a-z0-9][a-z0-9._-]{2,31}$`)
)

// user is the signed-in account.
type user struct {
	id          string
	email       *string
	username    *string
	verified    bool
	hasPassword bool
	name        string
	locale      *string
	sessionID   string
}

func (u *user) api() User {
	return User{
		Id:            u.id,
		Email:         u.email,
		Username:      u.username,
		EmailVerified: u.verified,
		HasPassword:   u.hasPassword,
		Name:          u.name,
		Locale:        u.locale,
	}
}

type authKey struct{}

// authState carries a request's session through the handlers: the token it
// came with, the account once looked up, and the response writer, so
// handlers can set or clear the session cookie.
type authState struct {
	token      string
	fromCookie bool
	// crossSite is set for a write that a browser says comes from another
	// site.
	crossSite bool
	loaded    bool
	user      *user
	w         http.ResponseWriter
}

// sessions finds the session token of API requests (a bearer token or the
// web app's cookie) and looks the account up. That happens here, before a
// handler holds a pool connection in a transaction: looking it up later
// would need a second connection, and enough such requests at once would
// wait on each other forever.
func (s *Server) sessions(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !strings.HasPrefix(r.URL.Path, BasePath+"/") || s.conf().AuthMode != config.AuthModeAccounts {
			next.ServeHTTP(w, r)
			return
		}
		st := &authState{w: w, crossSite: !safeMethod(r.Method) && !s.sameOrigin(r)}
		if bearer, ok := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer "); ok {
			st.token = strings.TrimSpace(bearer)
		} else if c, err := r.Cookie(sessionCookie); err == nil {
			st.token, st.fromCookie = c.Value, true
			if st.crossSite {
				writeError(w, http.StatusForbidden, "bad_origin")
				return
			}
		}
		ctx := context.WithValue(r.Context(), authKey{}, st)
		if st.token != "" {
			if _, err := s.currentUser(ctx); err != nil {
				writeHandlerError(s.log, w, r, err)
				return
			}
		}
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// cookieOrigin refuses to start a cookie session for another site: it
// could sign a visitor in to an account it controls (login CSRF). Only the
// web app on this server asks for cookies.
func cookieOrigin(ctx context.Context, cookie *bool) error {
	st, _ := ctx.Value(authKey{}).(*authState)
	if cookie != nil && *cookie && st != nil && st.crossSite {
		return forbidden("bad_origin")
	}
	return nil
}

func safeMethod(m string) bool {
	return m == http.MethodGet || m == http.MethodHead || m == http.MethodOptions
}

// sameOrigin guards cookie sessions against cross-site requests (on top of
// SameSite=Lax): browsers say where a request comes from.
func (s *Server) sameOrigin(r *http.Request) bool {
	if r.Header.Get("Sec-Fetch-Site") == "cross-site" {
		return false
	}
	origin := r.Header.Get("Origin")
	if origin == "" {
		return true
	}
	u, err := url.Parse(origin)
	if err != nil {
		return false
	}
	public := s.conf().PublicURL
	return u.Host == r.Host || u.Scheme == public.Scheme && u.Host == public.Host
}

// secretToken makes a session, email or invitation secret.
func secretToken() string {
	b := make([]byte, 32)
	_, _ = rand.Read(b)
	return base64.RawURLEncoding.EncodeToString(b)
}

func hashToken(token string) []byte {
	h := sha256.Sum256([]byte(token))
	return h[:]
}

// currentUser returns the signed-in account, or nil.
func (s *Server) currentUser(ctx context.Context) (*user, error) {
	st, _ := ctx.Value(authKey{}).(*authState)
	if st == nil || st.token == "" {
		return nil, nil
	}
	if st.loaded {
		return st.user, nil
	}
	var u user
	var lastUsed time.Time
	err := s.db.QueryRow(ctx, `
		select s.id::text, s.last_used_at, u.id::text, u.email::text, u.username::text, u.email_verified,
		       u.password_hash is not null, u.display_name, u.locale
		from sessions s join users u on u.id = s.user_id
		where s.token_hash = $1 and s.expires_at > now()`, hashToken(st.token)).
		Scan(&u.sessionID, &lastUsed, &u.id, &u.email, &u.username, &u.verified, &u.hasPassword, &u.name, &u.locale)
	switch {
	case errors.Is(err, pgx.ErrNoRows):
		st.loaded = true
		if st.fromCookie {
			s.clearSessionCookie(st)
		}
		return nil, nil
	case err != nil:
		return nil, err
	}
	if time.Since(lastUsed) > sessionTouchEvery {
		_, err := s.db.Exec(ctx, `update sessions set last_used_at = now(), expires_at = $2 where id = $1`,
			u.sessionID, time.Now().Add(sessionLifetime))
		if err != nil {
			return nil, err
		}
		if st.fromCookie {
			s.setSessionCookie(st, st.token)
		}
	}
	st.loaded, st.user = true, &u
	return &u, nil
}

// requireUser is currentUser for endpoints that need someone signed in.
func (s *Server) requireUser(ctx context.Context) (*user, error) {
	if err := s.requireAccounts(); err != nil {
		return nil, err
	}
	u, err := s.currentUser(ctx)
	if err == nil && u == nil {
		err = &apiError{status: http.StatusUnauthorized, code: "sign_in_required"}
	}
	return u, err
}

func (s *Server) requireAccounts() error {
	if s.conf().AuthMode != config.AuthModeAccounts {
		return forbidden("accounts_off")
	}
	return nil
}

func (s *Server) requirePasswords() error {
	if err := s.requireAccounts(); err != nil {
		return err
	}
	if !s.conf().Password {
		return forbidden("password_off")
	}
	return nil
}

// startSession signs userID in. With cookie, the token goes into the session
// cookie and nil is returned; otherwise the token is returned.
func (s *Server) startSession(ctx context.Context, q querier, userID string, cookie bool) (*string, error) {
	token := secretToken()
	_, err := q.Exec(ctx, `insert into sessions (user_id, token_hash, expires_at) values ($1, $2, $3)`,
		userID, hashToken(token), time.Now().Add(sessionLifetime))
	if err != nil {
		return nil, err
	}
	if st, _ := ctx.Value(authKey{}).(*authState); cookie && st != nil {
		s.setSessionCookie(st, token)
		return nil, nil
	}
	return &token, nil
}

func (s *Server) setSessionCookie(st *authState, token string) {
	http.SetCookie(st.w, &http.Cookie{
		Name:     sessionCookie,
		Value:    token,
		Path:     "/api/",
		MaxAge:   int(sessionLifetime.Seconds()),
		HttpOnly: true,
		Secure:   s.conf().PublicURL.Scheme == "https",
		SameSite: http.SameSiteLaxMode,
	})
}

func (s *Server) clearSessionCookie(st *authState) {
	http.SetCookie(st.w, &http.Cookie{
		Name:     sessionCookie,
		Path:     "/api/",
		MaxAge:   -1,
		HttpOnly: true,
		Secure:   s.conf().PublicURL.Scheme == "https",
		SameSite: http.SameSiteLaxMode,
	})
}

// cleanEmail checks an address and returns it trimmed. Only the bare
// address is accepted ("a@b.example", not "A <a@b.example>").
func cleanEmail(s string) (string, error) {
	s = strings.TrimSpace(s)
	a, err := mail.ParseAddress(s)
	if err != nil || a.Address != s || len(s) > maxEmailLen {
		return "", badRequest("invalid_email")
	}
	return s, nil
}

// cleanUsername checks a username and returns it trimmed and in lower case.
// It never holds "@", so it cannot be mistaken for an address.
func cleanUsername(s *string) (string, error) {
	if s == nil {
		return "", badRequest("invalid_username")
	}
	v := strings.ToLower(strings.TrimSpace(*s))
	if !usernameRule.MatchString(v) {
		return "", badRequest("invalid_username")
	}
	return v, nil
}

func cleanLocale(l *string) (*string, error) {
	if l == nil || *l == "" {
		return nil, nil
	}
	if !localeTag.MatchString(*l) {
		return nil, badRequest("invalid_locale")
	}
	return l, nil
}

// signupAllowed applies BALNANA_AUTH_SIGNUP to a new account, invited or
// not. The first account on a server is always allowed, so closed servers
// can start.
func (s *Server) signupAllowed(ctx context.Context, q querier, invited bool) error {
	if s.conf().Signup == config.SignupOpen {
		return nil
	}
	var first bool
	if err := q.QueryRow(ctx, `select not exists (select 1 from users)`).Scan(&first); err != nil {
		return err
	}
	if first || s.conf().Signup == config.SignupInviteOnly && invited {
		return nil
	}
	return forbidden("signup_closed")
}

func (s *Server) Register(ctx context.Context, req RegisterRequestObject) (RegisterResponseObject, error) {
	if err := s.requirePasswords(); err != nil {
		return nil, err
	}
	if err := cookieOrigin(ctx, req.Body.Cookie); err != nil {
		return nil, err
	}
	in := req.Body
	// Without a required address the account is known by its username, and
	// may still give an address for invitations and password resets.
	var email, username *string
	if in.Email != nil && (s.conf().RequireEmail || strings.TrimSpace(*in.Email) != "") {
		e, err := cleanEmail(*in.Email)
		if err != nil {
			return nil, err
		}
		email = &e
	}
	if s.conf().RequireEmail {
		if email == nil {
			return nil, badRequest("invalid_email")
		}
	} else {
		u, err := cleanUsername(in.Username)
		if err != nil {
			return nil, err
		}
		username = &u
	}
	if err := validPassword(in.Password); err != nil {
		return nil, err
	}
	name, err := cleanName(in.Name)
	if err != nil {
		return nil, err
	}
	locale, err := cleanLocale(in.Locale)
	if err != nil {
		return nil, err
	}
	hash := hashPassword(in.Password)
	var out Session
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		// One sign-up at a time, so two "first accounts" cannot race.
		if _, err := tx.Exec(ctx, `lock table users in share row exclusive mode`); err != nil {
			return err
		}
		// An invitation link reached this address, which verifies it.
		invited := false
		if email != nil {
			invited, err = validInvite(ctx, tx, in.Invite, *email)
			if err != nil {
				return err
			}
		}
		if err := s.signupAllowed(ctx, tx, invited); err != nil {
			return err
		}
		u := user{email: email, username: username, verified: invited, hasPassword: true, name: name, locale: locale}
		err = tx.QueryRow(ctx, `
			insert into users (email, username, email_verified, password_hash, display_name, locale)
			values ($1, $2, $3, $4, $5, $6) returning id::text`, email, username, invited, hash, name, locale).Scan(&u.id)
		if pgErr := (*pgconn.PgError)(nil); errors.As(err, &pgErr) && pgErr.Code == "23505" {
			if pgErr.ConstraintName == "users_username_key" {
				return conflict("username_taken")
			}
			return conflict("email_taken")
		}
		if err != nil {
			return err
		}
		out.User = u.api()
		out.Token, err = s.startSession(ctx, tx, u.id, in.Cookie != nil && *in.Cookie)
		return err
	})
	if err != nil {
		return nil, err
	}
	return Register201JSONResponse(out), nil
}

func (s *Server) Login(ctx context.Context, req LoginRequestObject) (LoginResponseObject, error) {
	if err := s.requirePasswords(); err != nil {
		return nil, err
	}
	if err := cookieOrigin(ctx, req.Body.Cookie); err != nil {
		return nil, err
	}
	in := req.Body
	var u user
	var hash *string
	err := s.db.QueryRow(ctx, `
		select id::text, email::text, username::text, email_verified, password_hash, display_name, locale
		from users where email = $1 or username = $1`, strings.TrimSpace(in.Login)).
		Scan(&u.id, &u.email, &u.username, &u.verified, &hash, &u.name, &u.locale)
	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return nil, err
	}
	if hash == nil {
		checkPassword(dummyHash, in.Password)
	}
	if hash == nil || !checkPassword(*hash, in.Password) {
		for range loginMissWeight {
			noteMiss(ctx)
		}
		return nil, &apiError{status: http.StatusUnauthorized, code: "invalid_credentials"}
	}
	u.hasPassword = true
	token, err := s.startSession(ctx, s.db, u.id, in.Cookie != nil && *in.Cookie)
	if err != nil {
		return nil, err
	}
	return Login200JSONResponse(Session{Token: token, User: u.api()}), nil
}

func (s *Server) Logout(ctx context.Context, _ LogoutRequestObject) (LogoutResponseObject, error) {
	if err := s.requireAccounts(); err != nil {
		return nil, err
	}
	st, _ := ctx.Value(authKey{}).(*authState)
	if st != nil && st.token != "" {
		if _, err := s.db.Exec(ctx, `delete from sessions where token_hash = $1`, hashToken(st.token)); err != nil {
			return nil, err
		}
		if st.fromCookie {
			s.clearSessionCookie(st)
		}
	}
	return Logout204Response{}, nil
}

func (s *Server) GetMe(ctx context.Context, _ GetMeRequestObject) (GetMeResponseObject, error) {
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	return GetMe200JSONResponse(u.api()), nil
}

func (s *Server) UpdateMe(ctx context.Context, req UpdateMeRequestObject) (UpdateMeResponseObject, error) {
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	in := req.Body
	if in.Name != nil {
		if u.name, err = cleanName(*in.Name); err != nil {
			return nil, err
		}
	}
	if in.Locale != nil {
		if u.locale, err = cleanLocale(in.Locale); err != nil {
			return nil, err
		}
	}
	if _, err := s.db.Exec(ctx, `update users set display_name = $2, locale = $3 where id = $1`, u.id, u.name, u.locale); err != nil {
		return nil, err
	}
	return UpdateMe200JSONResponse(u.api()), nil
}

func (s *Server) ChangePassword(ctx context.Context, req ChangePasswordRequestObject) (ChangePasswordResponseObject, error) {
	if err := s.requirePasswords(); err != nil {
		return nil, err
	}
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	in := req.Body
	if err := validPassword(in.NewPassword); err != nil {
		return nil, err
	}
	if u.hasPassword {
		var hash string
		if err := s.db.QueryRow(ctx, `select password_hash from users where id = $1`, u.id).Scan(&hash); err != nil {
			return nil, err
		}
		if in.CurrentPassword == nil || !checkPassword(hash, *in.CurrentPassword) {
			for range loginMissWeight {
				noteMiss(ctx)
			}
			return nil, forbidden("wrong_password")
		}
	}
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `update users set password_hash = $2 where id = $1`, u.id, hashPassword(in.NewPassword)); err != nil {
			return err
		}
		_, err := tx.Exec(ctx, `delete from sessions where user_id = $1 and id <> $2`, u.id, u.sessionID)
		return err
	})
	if err != nil {
		return nil, err
	}
	return ChangePassword204Response{}, nil
}
