package api

import (
	"context"
	"errors"
	"fmt"
	"net/url"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"

	"balnana/internal/mail"
)

const (
	verifyLifetime = 48 * time.Hour
	resetLifetime  = time.Hour
	inviteLifetime = 30 * 24 * time.Hour
)

// sendMail delivers m in the background, so a slow mail server never holds
// up a request, and how long a request takes reveals nothing.
func (s *Server) sendMail(m mail.Message) {
	mailer := s.mailer()
	if mailer == nil {
		return
	}
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), time.Minute)
		defer cancel()
		if err := mailer.Send(ctx, m); err != nil {
			s.log.Warn("sending email failed", "err", err)
		}
	}()
}

func (s *Server) requireEmail() error {
	if s.mailer() == nil {
		return forbidden("email_off")
	}
	return nil
}

// appLink is a link into the web app.
func (s *Server) appLink(path string, query url.Values) string {
	u := *s.conf().PublicURL
	u.Path = strings.TrimSuffix(u.Path, "/") + path
	u.RawQuery = query.Encode()
	return u.String()
}

// newEmailToken makes a verification or reset token for userID, replacing
// older ones. It returns "" when one was made within the last minute, so
// nobody can flood an inbox.
func newEmailToken(ctx context.Context, q querier, userID, purpose string, lifetime time.Duration) (string, error) {
	var recent bool
	err := q.QueryRow(ctx, `
		select exists (select 1 from email_tokens
		               where user_id = $1 and purpose = $2 and created_at > now() - interval '1 minute')`,
		userID, purpose).Scan(&recent)
	if err != nil || recent {
		return "", err
	}
	if _, err := q.Exec(ctx, `delete from email_tokens where user_id = $1 and purpose = $2`, userID, purpose); err != nil {
		return "", err
	}
	token := secretToken()
	_, err = q.Exec(ctx, `insert into email_tokens (token_hash, user_id, purpose, expires_at) values ($1, $2, $3, $4)`,
		hashToken(token), userID, purpose, time.Now().Add(lifetime))
	return token, err
}

// useEmailToken spends a token and returns its account.
func useEmailToken(ctx context.Context, q querier, token, purpose string) (string, error) {
	var userID string
	var live bool
	err := q.QueryRow(ctx, `
		delete from email_tokens where token_hash = $1 and purpose = $2
		returning user_id::text, expires_at > now()`, hashToken(token), purpose).Scan(&userID, &live)
	if errors.Is(err, pgx.ErrNoRows) || err == nil && !live {
		noteMiss(ctx)
		return "", badRequest("invalid_token")
	}
	return userID, err
}

func (s *Server) SendVerifyEmail(ctx context.Context, _ SendVerifyEmailRequestObject) (SendVerifyEmailResponseObject, error) {
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	if err := s.requireEmail(); err != nil {
		return nil, err
	}
	if u.verified || u.email == nil {
		return SendVerifyEmail204Response{}, nil
	}
	token, err := newEmailToken(ctx, s.db, u.id, "verify", verifyLifetime)
	if err != nil {
		return nil, err
	}
	if token != "" {
		s.sendMail(verifyMail(*u.email, u.name, s.appLink("/verify-email", url.Values{"token": {token}})))
	}
	return SendVerifyEmail204Response{}, nil
}

func (s *Server) VerifyEmail(ctx context.Context, req VerifyEmailRequestObject) (VerifyEmailResponseObject, error) {
	if err := s.requireAccounts(); err != nil {
		return nil, err
	}
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		userID, err := useEmailToken(ctx, tx, req.Body.Token, "verify")
		if err != nil {
			return err
		}
		_, err = tx.Exec(ctx, `update users set email_verified = true where id = $1`, userID)
		return err
	})
	if err != nil {
		return nil, err
	}
	return VerifyEmail204Response{}, nil
}

func (s *Server) RequestPasswordReset(ctx context.Context, req RequestPasswordResetRequestObject) (RequestPasswordResetResponseObject, error) {
	if err := s.requirePasswords(); err != nil {
		return nil, err
	}
	if err := s.requireEmail(); err != nil {
		return nil, err
	}
	email, err := cleanEmail(req.Body.Email)
	if err != nil {
		return nil, err
	}
	var userID, name string
	err = s.db.QueryRow(ctx, `select id::text, email::text, display_name from users where email = $1`, email).Scan(&userID, &email, &name)
	if errors.Is(err, pgx.ErrNoRows) {
		return RequestPasswordReset204Response{}, nil
	}
	if err != nil {
		return nil, err
	}
	token, err := newEmailToken(ctx, s.db, userID, "reset", resetLifetime)
	if err != nil {
		return nil, err
	}
	if token != "" {
		s.sendMail(resetMail(email, name, s.appLink("/reset-password", url.Values{"token": {token}})))
	}
	return RequestPasswordReset204Response{}, nil
}

func (s *Server) ResetPassword(ctx context.Context, req ResetPasswordRequestObject) (ResetPasswordResponseObject, error) {
	if err := s.requirePasswords(); err != nil {
		return nil, err
	}
	in := req.Body
	if err := validPassword(in.NewPassword); err != nil {
		return nil, err
	}
	hash := hashPassword(in.NewPassword)
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		userID, err := useEmailToken(ctx, tx, in.Token, "reset")
		if err != nil {
			return err
		}
		// The email reached its owner, so the address is verified too.
		if _, err := tx.Exec(ctx, `update users set password_hash = $2, email_verified = true where id = $1`, userID, hash); err != nil {
			return err
		}
		_, err = tx.Exec(ctx, `delete from sessions where user_id = $1`, userID)
		return err
	})
	if err != nil {
		return nil, err
	}
	return ResetPassword204Response{}, nil
}

func (s *Server) InviteToGroup(ctx context.Context, req InviteToGroupRequestObject) (InviteToGroupResponseObject, error) {
	if _, err := s.requireUser(ctx); err != nil {
		return nil, err
	}
	if err := s.requireEmail(); err != nil {
		return nil, err
	}
	in := req.Body
	email, err := cleanEmail(in.Email)
	if err != nil {
		return nil, err
	}
	var g *group
	var inviter string
	token := secretToken()
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if g, err = s.groupByToken(ctx, tx, req.Token, true); err != nil {
			return err
		}
		if g.me == nil {
			return forbidden("not_a_member")
		}
		members, err := groupMembers(ctx, tx, g.id)
		if err != nil {
			return err
		}
		inviter = findMember(members, *g.me).name
		var memberID *string
		if in.MemberId != nil && *in.MemberId != "" {
			m := findMember(members, *in.MemberId)
			if m == nil || m.left {
				return errNotFound
			}
			if m.userID != nil {
				return conflict("member_claimed")
			}
			memberID = &m.id
		}
		if _, err := tx.Exec(ctx, `delete from invites where group_id = $1 and email = $2`, g.id, email); err != nil {
			return err
		}
		_, err = tx.Exec(ctx, `
			insert into invites (group_id, email, member_id, invited_by, token_hash, expires_at)
			values ($1, $2, $3, $4, $5, $6)`,
			g.id, email, memberID, g.me, hashToken(token), time.Now().Add(inviteLifetime))
		return err
	})
	if err != nil {
		return nil, err
	}
	s.sendMail(inviteMail(email, inviter, g.name, s.appLink("/invite/"+token, nil)))
	return InviteToGroup204Response{}, nil
}

func (s *Server) GetInvite(ctx context.Context, req GetInviteRequestObject) (GetInviteResponseObject, error) {
	if err := s.requireAccounts(); err != nil {
		return nil, err
	}
	var out InviteInfo
	err := s.db.QueryRow(ctx, `
		select i.email::text, g.token, g.name, m.display_name
		from invites i
		join groups g on g.id = i.group_id and g.archived_at is null
		left join members m on m.id = i.invited_by
		where i.token_hash = $1 and i.expires_at > now()`, hashToken(req.InviteToken)).
		Scan(&out.Email, &out.GroupToken, &out.GroupName, &out.InvitedBy)
	if errors.Is(err, pgx.ErrNoRows) {
		noteMiss(ctx)
		return nil, errNotFound
	}
	if err != nil {
		return nil, err
	}
	// Following the link proves a signed-in account with this address owns it.
	if u, err := s.currentUser(ctx); err != nil {
		return nil, err
	} else if u != nil && !u.verified {
		if _, err := s.db.Exec(ctx, `update users set email_verified = true where id = $1 and email = $2`, u.id, out.Email); err != nil {
			return nil, err
		}
	}
	return GetInvite200JSONResponse(out), nil
}

// validInvite reports whether token is a live invitation for email.
func validInvite(ctx context.Context, q querier, token *string, email string) (bool, error) {
	if token == nil || *token == "" {
		return false, nil
	}
	var ok bool
	err := q.QueryRow(ctx, `
		select exists (select 1 from invites where token_hash = $1 and email = $2 and expires_at > now())`,
		hashToken(*token), email).Scan(&ok)
	return ok, err
}

// invitedMember is the unclaimed member u was invited to g as, if any.
func invitedMember(ctx context.Context, q querier, g *group, u *user) (*string, error) {
	if u.email == nil || !u.verified {
		return nil, nil
	}
	var id string
	err := q.QueryRow(ctx, `
		select m.id::text from invites i join members m on m.id = i.member_id
		where i.group_id = $1 and i.email = $2 and i.expires_at > now()
		  and m.user_id is null and m.left_at is null
		order by i.created_at desc limit 1`, g.id, *u.email).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &id, nil
}

// The emails are in English for now, like the rest of the server.

func verifyMail(to, name, link string) mail.Message {
	return mail.Message{
		To:      to,
		Subject: "Confirm your email for Balnana",
		Body: fmt.Sprintf(`Hi %s,

Confirm that this is your email address by opening this link:

%s

The link works for 48 hours. If you didn't create a Balnana account, you can ignore this email.
`, name, link),
	}
}

func resetMail(to, name, link string) mail.Message {
	return mail.Message{
		To:      to,
		Subject: "Reset your Balnana password",
		Body: fmt.Sprintf(`Hi %s,

Someone asked to reset the password of the Balnana account for this address. To choose a new password, open this link:

%s

The link works for one hour. If it wasn't you, ignore this email; your password stays the same.
`, name, link),
	}
}

func inviteMail(to, inviter, group, link string) mail.Message {
	return mail.Message{
		To:      to,
		Subject: fmt.Sprintf("%s invited you to %s on Balnana", inviter, group),
		Body: fmt.Sprintf(`Hi,

%s invited you to join "%s" on Balnana, where you can keep track of shared expenses together.

Open this link to join:

%s

The link works for 30 days.
`, inviter, group, link),
	}
}
