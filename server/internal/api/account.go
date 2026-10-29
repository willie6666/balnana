package api

import (
	"context"
	"errors"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"balnana/internal/config"
)

// confirmPassword checks the password of an account that has one, before a
// change that a stolen session alone must not make. It returns the hash it
// checked, nil for an account without a password, for lockAccount.
func (s *Server) confirmPassword(ctx context.Context, u *user, password *string) (*string, error) {
	var hash *string
	if err := s.db.QueryRow(ctx, `select password_hash from users where id = $1`, u.id).Scan(&hash); err != nil {
		return nil, err
	}
	if hash == nil {
		return nil, nil
	}
	release, err := s.holdGuess(ctx, u.id)
	if err != nil {
		return nil, err
	}
	if password == nil || !checkPassword(*hash, *password) {
		return nil, forbidden("wrong_password")
	}
	release()
	return hash, nil
}

// lockAccount locks u's row for a change confirmPassword allowed, and makes
// sure what allowed it still holds: the session is live and the password is
// the one checked. A reclaim or reset in between revokes both, and a request
// that started before it must not undo it.
func lockAccount(ctx context.Context, tx pgx.Tx, u *user, checked *string) error {
	if err := lockUsersTable(ctx, tx); err != nil {
		return err
	}
	var hash *string
	var live bool
	err := tx.QueryRow(ctx, `
		select password_hash,
		       exists (select 1 from sessions where id = $2 and user_id = $1 and expires_at > now())
		from users where id = $1 for update`, u.id, u.sessionID).Scan(&hash, &live)
	if errors.Is(err, pgx.ErrNoRows) {
		live = false
	} else if err != nil {
		return err
	}
	if !live || (hash == nil) != (checked == nil) || hash != nil && *hash != *checked {
		return &apiError{status: http.StatusUnauthorized, code: "sign_in_required"}
	}
	return nil
}

// lockUsersTable takes the table lock an update of users needs, before any
// row of it: a sign-up or OAuth sign-in holds the whole table while it waits
// for a row, so a row locked first and the table after could deadlock with it.
func lockUsersTable(ctx context.Context, tx pgx.Tx) error {
	_, err := tx.Exec(ctx, `lock table users in row exclusive mode`)
	return err
}

func (s *Server) ChangeEmail(ctx context.Context, req ChangeEmailRequestObject) (ChangeEmailResponseObject, error) {
	u, err := s.requireAccount(ctx)
	if err != nil {
		return nil, err
	}
	var email *string
	if strings.TrimSpace(req.Body.Email) != "" {
		e, err := cleanEmail(req.Body.Email)
		if err != nil {
			return nil, err
		}
		email = &e
	} else if u.username == nil {
		// The address is how this account signs in.
		return nil, badRequest("email_needed")
	}
	checked, err := s.confirmPassword(ctx, u, req.Body.Password)
	if err != nil {
		return nil, err
	}
	if email != nil && u.email != nil && strings.EqualFold(*email, *u.email) {
		// Back to the current address: a change waiting to be confirmed is
		// dropped, and the links sent for it stop working with it.
		if u.pending != nil {
			if _, err := s.db.Exec(ctx, `update users set pending_email = null where id = $1`, u.id); err != nil {
				return nil, err
			}
			u.pending = nil
		}
		return ChangeEmail200JSONResponse(u.api()), nil
	}
	// Each change emails the new address, so it is not a way to send spam;
	// without email, each tells whether an account has the address.
	if now := time.Now(); email != nil && !s.emails.take(u.id, 1, now) {
		return nil, limited(s.emails, u.id, now)
	}
	if email == nil || s.mailer() == nil {
		// Nothing can confirm the address, so it takes the old one's place now.
		err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
			if err := lockAccount(ctx, tx, u, checked); err != nil {
				return err
			}
			_, err := tx.Exec(ctx, `
				update users set email = $2, email_verified = false, pending_email = null where id = $1`, u.id, email)
			if pgErr := (*pgconn.PgError)(nil); errors.As(err, &pgErr) && pgErr.Code == "23505" {
				return conflict("email_taken")
			}
			if err != nil {
				return err
			}
			// Links sent to the old address must not verify the new one, nor
			// reset the password from there.
			_, err = tx.Exec(ctx, `delete from email_tokens where user_id = $1`, u.id)
			return err
		})
		if err != nil {
			return nil, err
		}
		u.email, u.verified, u.pending = email, false, nil
		return ChangeEmail200JSONResponse(u.api()), nil
	}
	// The new address waits until a link sent to it is opened; until then the
	// account keeps the old one, so a mistyped address never takes its place.
	var token string
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		// The account's row is locked first, as where tokens are used.
		if err := lockAccount(ctx, tx, u, checked); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `update users set pending_email = $2 where id = $1`, u.id, *email); err != nil {
			return err
		}
		var taken bool
		err := tx.QueryRow(ctx, `select exists (select 1 from users where email = $2 and id <> $1)`, u.id, *email).Scan(&taken)
		if err != nil {
			return err
		}
		if taken {
			return conflict("email_taken")
		}
		// A link sent a moment ago, to either address, gives way to this one.
		if _, err := tx.Exec(ctx, `delete from email_tokens where user_id = $1 and purpose = 'verify'`, u.id); err != nil {
			return err
		}
		token, err = newEmailToken(ctx, tx, u.id, *email, "verify", verifyLifetime)
		return err
	})
	if err != nil {
		return nil, err
	}
	u.pending = email
	s.sendMail(verifyMail(*email, u.name, s.appLink("/verify-email", url.Values{"token": {token}})))
	return ChangeEmail200JSONResponse(u.api()), nil
}

func (s *Server) DeleteMe(ctx context.Context, req DeleteMeRequestObject) (DeleteMeResponseObject, error) {
	u, err := s.requireAccount(ctx)
	if err != nil {
		return nil, err
	}
	checked, err := s.confirmPassword(ctx, u, req.Body.Password)
	if err != nil {
		return nil, err
	}
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if err := lockAccount(ctx, tx, u, checked); err != nil {
			return err
		}
		return s.deleteAccount(ctx, tx, u.id)
	})
	if err != nil {
		return nil, err
	}
	if st, _ := ctx.Value(authKey{}).(*authState); st != nil && st.fromCookie {
		s.clearSessionCookie(st)
	}
	s.log.Info("account deleted by its owner")
	return DeleteMe204Response{}, nil
}

// deleteAccount deletes userID. Its members stay in their groups, unclaimed,
// so the groups' balances and history still add up; whoever is left in a
// group can rename or claim them. Ownership passes to the account that has
// been in the group longest. A group that no other account could reach
// afterwards is deleted with it; one its link still opens stays.
func (s *Server) deleteAccount(ctx context.Context, tx pgx.Tx, userID string) error {
	if err := lockUsersTable(ctx, tx); err != nil {
		return err
	}
	// The account's row first: a member it is joining as waits on it, so the
	// groups found next are all of them.
	if _, err := tx.Exec(ctx, `select 1 from users where id = $1 for update`, userID); err != nil {
		return err
	}
	rows, err := tx.Query(ctx, `select distinct group_id::text from members where user_id = $1`, userID)
	if err != nil {
		return err
	}
	groups, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil {
		return err
	}
	// Then the groups, as their writes lock them, so a join or leave that is
	// under way has finished and the statements below see it.
	if _, err := tx.Exec(ctx, `select 1 from groups where id = any($1::uuid[]) order by id for update`, groups); err != nil {
		return err
	}
	_, err = tx.Exec(ctx, `
		update members set is_owner = true where id in (
			select distinct on (m.group_id) m.id
			from members m
			join members me on me.group_id = m.group_id and me.user_id = $1 and me.is_owner
			where m.user_id is not null and m.user_id <> $1 and m.left_at is null
			  and not exists (select 1 from members o
			                  where o.group_id = m.group_id and o.is_owner and o.left_at is null
			                    and o.user_id is not null and o.user_id <> $1)
			order by m.group_id, m.created_at)`, userID)
	if err != nil {
		return err
	}
	// The same rule as resolveAccess: in link mode every link opens its group.
	cfg := s.conf()
	_, err = tx.Exec(ctx, `
		delete from groups g
		where g.id = any($1::uuid[]) and not $2 and not ($3 and g.link_access)
		  and not exists (select 1 from members o
		                  where o.group_id = g.id and o.user_id is not null and o.user_id <> $4 and o.left_at is null)`,
		groups, cfg.AuthMode != config.AuthModeAccounts, cfg.LinkGroups, userID)
	if err != nil {
		return err
	}
	if _, err := tx.Exec(ctx, `update members set user_id = null, is_owner = false where user_id = $1`, userID); err != nil {
		return err
	}
	tag, err := tx.Exec(ctx, `delete from users where id = $1`, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return errNotFound
	}
	// Open apps reload the groups, to show the member unclaimed.
	_, err = tx.Exec(ctx, `select pg_notify($1, g) from unnest($2::text[]) g`, changeChannel, groups)
	return err
}
