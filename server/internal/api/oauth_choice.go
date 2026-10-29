package api

import (
	"context"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"errors"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

// A provider sign-in with the address of an account nobody confirmed waits
// in oauth_pending for its person to say whether that account is theirs; an
// account adds a provider by signing in with it from the account page.

type oauthPending struct {
	provider, issuer, subject, email, userID, name string
	avatar, challenge                              *string
}

func loadPending(ctx context.Context, q querier, token string) (*oauthPending, error) {
	var p oauthPending
	err := q.QueryRow(ctx, `
		select provider, issuer, subject, email::text, user_id::text, name, avatar_url, challenge
		from oauth_pending where token_hash = $1 and expires_at > now()`, hashToken(token)).
		Scan(&p.provider, &p.issuer, &p.subject, &p.email, &p.userID, &p.name, &p.avatar, &p.challenge)
	if errors.Is(err, pgx.ErrNoRows) {
		noteMiss(ctx)
		return nil, badRequest("invalid_token")
	}
	return &p, err
}

// invitedAddress reports whether a live invitation went to email.
func invitedAddress(ctx context.Context, q querier, email string) (bool, error) {
	var invited bool
	err := q.QueryRow(ctx, `select exists (select 1 from invites where email = $1 and expires_at > now())`, email).
		Scan(&invited)
	return invited, err
}

func (s *Server) GetOAuthPending(ctx context.Context, req GetOAuthPendingRequestObject) (GetOAuthPendingResponseObject, error) {
	if err := s.requireAccounts(); err != nil {
		return nil, err
	}
	p, err := loadPending(ctx, s.db, req.Body.Token)
	if err != nil {
		return nil, err
	}
	out := OAuthPending{Email: p.email, Provider: p.provider}
	if err := s.db.QueryRow(ctx, `select password_hash is not null from users where id = $1`, p.userID).
		Scan(&out.HasPassword); err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return nil, err
	}
	invited, err := invitedAddress(ctx, s.db, p.email)
	if err != nil {
		return nil, err
	}
	var ae *apiError
	switch err := s.newAccountAllowed(ctx, s.db, p.userID, invited); {
	case err == nil:
		out.Signup = true
	case !errors.As(err, &ae):
		return nil, err
	}
	return GetOAuthPending200JSONResponse(out), nil
}

func (s *Server) FinishOAuthPending(ctx context.Context, req FinishOAuthPendingRequestObject) (FinishOAuthPendingResponseObject, error) {
	if err := s.requireAccounts(); err != nil {
		return nil, err
	}
	in := req.Body
	if err := cookieOrigin(ctx, in.Cookie); err != nil {
		return nil, err
	}
	p, err := loadPending(ctx, s.db, in.Token)
	if err != nil {
		return nil, err
	}
	// Only who started the sign-in answers: the app with its verifier, or
	// the browser with the token in its cookie.
	if p.challenge != nil {
		var sum [32]byte
		if in.Verifier != nil {
			sum = sha256.Sum256([]byte(*in.Verifier))
		}
		if in.Verifier == nil || base64.RawURLEncoding.EncodeToString(sum[:]) != *p.challenge {
			noteMiss(ctx)
			return nil, badRequest("invalid_token")
		}
	} else if c := req.Params.BalnanaOauth; c == nil || subtle.ConstantTimeCompare([]byte(*c), []byte(in.Token)) != 1 {
		noteMiss(ctx)
		return nil, badRequest("invalid_token")
	}

	// The password is checked outside the lock, as hashing is slow, and must
	// still be the account's under it.
	var checked *string
	if in.Choice == OAuthPendingFinishChoiceLink {
		if err := s.db.QueryRow(ctx, `select password_hash from users where id = $1`, p.userID).Scan(&checked); err != nil &&
			!errors.Is(err, pgx.ErrNoRows) {
			return nil, err
		}
		release, err := s.holdGuess(ctx, p.userID)
		if err != nil {
			return nil, err
		}
		if checked == nil {
			checkPassword(dummyHash, "")
		}
		if checked == nil || in.Password == nil || !checkPassword(*checked, *in.Password) {
			return nil, forbidden("wrong_password")
		}
		release()
	}

	var u *user
	var token string
	stale := badRequest("invalid_token")
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `lock table users in share row exclusive mode`); err != nil {
			return err
		}
		tag, err := tx.Exec(ctx, `delete from oauth_pending where token_hash = $1 and expires_at > now()`, hashToken(in.Token))
		if err != nil {
			return err
		}
		if tag.RowsAffected() == 0 {
			return stale
		}
		// The account must be as it was asked about: still unconfirmed, with
		// the address, and for link the password checked.
		var hash *string
		err = tx.QueryRow(ctx, `
			select password_hash from users where id = $1 and email = $2 and not email_verified for update`,
			p.userID, p.email).Scan(&hash)
		if errors.Is(err, pgx.ErrNoRows) {
			return stale
		}
		if err != nil {
			return err
		}
		userID := p.userID
		switch in.Choice {
		case OAuthPendingFinishChoiceLink:
			if hash == nil || *hash != *checked {
				return stale
			}
			if _, err := tx.Exec(ctx, `update users set email_verified = true where id = $1`, userID); err != nil {
				return err
			}
		case OAuthPendingFinishChoiceTakeOver:
			if err := s.takeOver(ctx, tx, userID); err != nil {
				return err
			}
		case OAuthPendingFinishChoiceNewAccount:
			invited, err := invitedAddress(ctx, tx, p.email)
			if err != nil {
				return err
			}
			if err := s.newAccountAllowed(ctx, tx, userID, invited); err != nil {
				return err
			}
			// The old account keeps going without the address, and the links
			// sent to it stop working.
			_, err = tx.Exec(ctx, `update users set email = null, email_verified = false where id = $1`, userID)
			if err != nil {
				return err
			}
			if _, err := tx.Exec(ctx, `delete from email_tokens where user_id = $1`, userID); err != nil {
				return err
			}
			err = tx.QueryRow(ctx, `
				insert into users (email, email_verified, display_name, avatar_url)
				values ($1, true, $2, $3) returning id::text`, p.email, p.name, p.avatar).Scan(&userID)
			if err != nil {
				return err
			}
		default:
			return badRequest("invalid_choice")
		}
		_, err = tx.Exec(ctx, `insert into oauth_identities (provider, issuer, subject, user_id) values ($1, $2, $3, $4)`,
			p.provider, p.issuer, p.subject, userID)
		if pgErr := (*pgconn.PgError)(nil); errors.As(err, &pgErr) && pgErr.Code == "23505" {
			// Signed in another way meanwhile.
			return stale
		}
		if err != nil {
			return err
		}
		if u, err = loadUser(ctx, tx, userID); err != nil {
			return err
		}
		token, err = startSession(ctx, tx, userID)
		return err
	})
	if err != nil {
		return nil, err
	}
	if p.challenge == nil {
		s.setOAuthCookie(ctx, "", -1)
	}
	return FinishOAuthPending200JSONResponse(Session{Token: s.handOut(ctx, token, in.Cookie != nil && *in.Cookie), User: u.api()}), nil
}

// newAccountAllowed reports whether a sign-in may make an account of its
// own, leaving oldID without the address: only when sign-up is open to it,
// and oldID still has another way in, a username or a provider.
func (s *Server) newAccountAllowed(ctx context.Context, q querier, oldID string, invited bool) error {
	if err := s.signupAllowed(ctx, q, invited); err != nil {
		return err
	}
	var other bool
	err := q.QueryRow(ctx, `
		select username is not null or exists (select 1 from oauth_identities where user_id = $1)
		from users where id = $1`, oldID).Scan(&other)
	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return err
	}
	if !other {
		return badRequest("email_needed")
	}
	return nil
}

func loadUser(ctx context.Context, q querier, id string) (*user, error) {
	u := user{id: id}
	err := q.QueryRow(ctx, `
		select email::text, pending_email::text, username::text, email_verified, password_hash is not null,
		       display_name, locale
		from users where id = $1`, id).
		Scan(&u.email, &u.pending, &u.username, &u.verified, &u.hasPassword, &u.name, &u.locale)
	return &u, err
}

// addIdentity adds a provider identity to the account that asked for it
// from its account page. An address the provider vouches for that is the
// account's own is confirmed with it. The users table must be locked.
func addIdentity(ctx context.Context, tx pgx.Tx, userID, provider, issuer, subject string, vouched *string) error {
	var email *string
	var verified bool
	err := tx.QueryRow(ctx, `select email::text, email_verified from users where id = $1 for update`, userID).
		Scan(&email, &verified)
	if errors.Is(err, pgx.ErrNoRows) {
		return badRequest("invalid_token")
	}
	if err != nil {
		return err
	}
	var owner string
	err = tx.QueryRow(ctx, `
		select user_id::text from oauth_identities where provider = $1 and issuer = $2 and subject = $3`,
		provider, issuer, subject).Scan(&owner)
	switch {
	case err == nil && owner != userID:
		return conflict("identity_taken")
	case err == nil:
	case !errors.Is(err, pgx.ErrNoRows):
		return err
	default:
		_, err := tx.Exec(ctx, `insert into oauth_identities (provider, issuer, subject, user_id) values ($1, $2, $3, $4)`,
			provider, issuer, subject, userID)
		if pgErr := (*pgconn.PgError)(nil); errors.As(err, &pgErr) && pgErr.Code == "23505" {
			return conflict("identity_taken")
		}
		if err != nil {
			return err
		}
	}
	if !verified && email != nil && vouched != nil && strings.EqualFold(*email, *vouched) {
		if _, err := tx.Exec(ctx, `update users set email_verified = true where id = $1`, userID); err != nil {
			return err
		}
	}
	return nil
}

func (s *Server) GetMyOAuth(ctx context.Context, _ GetMyOAuthRequestObject) (GetMyOAuthResponseObject, error) {
	u, err := s.requireAccount(ctx)
	if err != nil {
		return nil, err
	}
	rows, _ := s.db.Query(ctx, `select distinct provider from oauth_identities where user_id = $1 order by provider`, u.id)
	providers, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil {
		return nil, err
	}
	return GetMyOAuth200JSONResponse(OAuthLinks{Providers: providers}), nil
}

func (s *Server) LinkOAuth(ctx context.Context, req LinkOAuthRequestObject) (LinkOAuthResponseObject, error) {
	u, err := s.requireAccount(ctx)
	if err != nil {
		return nil, err
	}
	if _, err := s.oauthProvider(req.Provider); err != nil {
		return nil, err
	}
	checked, err := s.confirmPassword(ctx, u, req.Body.Password)
	if err != nil {
		return nil, err
	}
	ticket := secretToken()
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if err := lockAccount(ctx, tx, u, checked); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `delete from oauth_link_tickets where expires_at < now()`); err != nil {
			return err
		}
		_, err := tx.Exec(ctx, `insert into oauth_link_tickets (ticket_hash, user_id, expires_at) values ($1, $2, $3)`,
			hashToken(ticket), u.id, time.Now().Add(oauthLifetime))
		return err
	})
	if err != nil {
		return nil, err
	}
	return LinkOAuth200JSONResponse(OAuthLinkTicket{Ticket: ticket}), nil
}

func (s *Server) UnlinkOAuth(ctx context.Context, req UnlinkOAuthRequestObject) (UnlinkOAuthResponseObject, error) {
	u, err := s.requireAccount(ctx)
	if err != nil {
		return nil, err
	}
	cfg := s.conf()
	var others []string
	for _, p := range cfg.OAuthProviders() {
		if p.ID != req.Provider {
			others = append(others, p.ID)
		}
	}
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if err := lockUsersTable(ctx, tx); err != nil {
			return err
		}
		// Some way in must be left: a password, while passwords sign in, or
		// another provider that is still offered.
		var password, other bool
		err := tx.QueryRow(ctx, `
			select password_hash is not null,
			       exists (select 1 from oauth_identities where user_id = $1 and provider = any($2))
			from users where id = $1 for update`, u.id, others).Scan(&password, &other)
		if err != nil {
			return err
		}
		if !(password && cfg.Password) && !other {
			return conflict("last_sign_in_method")
		}
		tag, err := tx.Exec(ctx, `delete from oauth_identities where user_id = $1 and provider = $2`, u.id, req.Provider)
		if err == nil && tag.RowsAffected() == 0 {
			return errNotFound
		}
		return err
	})
	if err != nil {
		return nil, err
	}
	return UnlinkOAuth204Response{}, nil
}
