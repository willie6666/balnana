package api

import (
	"context"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha1"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base32"
	"encoding/binary"
	"errors"
	"fmt"
	"math/big"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"

	"balnana/internal/mail"
)

// Two-step sign-in: an account with a password may also ask for a code when
// signing in with it, from an authenticator app (TOTP, RFC 6238), by email,
// or both, in which case either code does. Signing in through a provider
// asks for none: the provider has its own second step.

const (
	totpPeriod = 30 * time.Second
	totpDigits = 6
	// totpSkew is how many periods before and after now a code may be from,
	// for clocks that disagree a little.
	totpSkew = 1

	recoveryCodes   = 8
	recoveryCodeLen = 10

	loginCodeLifetime = 10 * time.Minute
	// loginCodeTries is how many wrong codes an emailed code survives.
	loginCodeTries = 5
	maxCodeLen     = 32
)

var (
	errInvalidCode = &apiError{status: http.StatusUnauthorized, code: "invalid_code"}
	totpEncoding   = base32.StdEncoding.WithPadding(base32.NoPadding)
)

// twoFactorFlags reads whether the users row aliased u asks for a code from
// an authenticator app, and for one by email.
const twoFactorFlags = `coalesce((select t.totp_enabled from two_factor t where t.user_id = u.id), false),
	coalesce((select t.email from two_factor t where t.user_id = u.id), false)`

func newTotpSecret() string {
	b := make([]byte, 20)
	_, _ = rand.Read(b)
	return totpEncoding.EncodeToString(b)
}

// totpCode is the code of secret for a time step.
func totpCode(secret []byte, step int64) string {
	var counter [8]byte
	binary.BigEndian.PutUint64(counter[:], uint64(step))
	mac := hmac.New(sha1.New, secret)
	mac.Write(counter[:])
	sum := mac.Sum(nil)
	at := sum[len(sum)-1] & 0x0f
	n := binary.BigEndian.Uint32(sum[at:at+4]) & 0x7fffffff
	return fmt.Sprintf("%0*d", totpDigits, n%1_000_000)
}

// totpMatch finds the time step code is the secret's code for, among the
// steps around now and after used, the step of the last code taken.
func totpMatch(secret, code string, now time.Time, used *int64) (int64, bool) {
	key, err := totpEncoding.DecodeString(secret)
	if err != nil || len(code) != totpDigits {
		return 0, false
	}
	current := now.Unix() / int64(totpPeriod.Seconds())
	found, ok := int64(0), false
	// Every step is tried, so how long it takes says nothing of which matched.
	for step := current - totpSkew; step <= current+totpSkew; step++ {
		if subtle.ConstantTimeCompare([]byte(totpCode(key, step)), []byte(code)) == 1 && (used == nil || step > *used) && !ok {
			found, ok = step, true
		}
	}
	return found, ok
}

// totpURI is what an authenticator app reads from a QR code.
func totpURI(secret, account string) string {
	q := url.Values{"secret": {secret}, "issuer": {"Balnana"}}
	return "otpauth://totp/" + url.PathEscape("Balnana:"+account) + "?" + q.Encode()
}

// cleanCode takes a code as people type it: any case, with spaces or dashes.
func cleanCode(code *string) string {
	if code == nil {
		return ""
	}
	c := strings.ToUpper(strings.NewReplacer(" ", "", "-", "").Replace(strings.TrimSpace(*code)))
	if len(c) > maxCodeLen {
		return ""
	}
	return c
}

// codeHash keeps a recovery or emailed code. The account goes in, so the
// same code is a different hash for each.
func codeHash(userID, code string) []byte {
	h := sha256.Sum256([]byte(userID + ":" + code))
	return h[:]
}

// newRecoveryCodes replaces the account's recovery codes and returns the new
// ones, as shown to their owner: ABCDE-FGHJK.
func newRecoveryCodes(ctx context.Context, tx pgx.Tx, userID string) ([]string, error) {
	if _, err := tx.Exec(ctx, `delete from recovery_codes where user_id = $1`, userID); err != nil {
		return nil, err
	}
	codes := make([]string, recoveryCodes)
	for i := range codes {
		b := make([]byte, recoveryCodeLen)
		for j := range b {
			n, err := rand.Int(rand.Reader, big.NewInt(int64(len(setupCodeAlphabet))))
			if err != nil {
				return nil, err
			}
			b[j] = setupCodeAlphabet[n.Int64()]
		}
		code := string(b)
		if _, err := tx.Exec(ctx, `insert into recovery_codes (user_id, code_hash) values ($1, $2) on conflict do nothing`,
			userID, codeHash(userID, code)); err != nil {
			return nil, err
		}
		codes[i] = code[:recoveryCodeLen/2] + "-" + code[recoveryCodeLen/2:]
	}
	return codes, nil
}

// secondStep asks for the code of an account that signs in with two steps,
// once its password was right. It returns what to refuse the sign-in with:
// two_factor_required when no code came, invalid_code for a wrong one, nil to
// go on. The caller's transaction is committed either way, so a wrong guess
// at an emailed code stays counted. u holds the account as read under its
// lock in tx.
func (s *Server) secondStep(ctx context.Context, tx pgx.Tx, u *user, code *string) (*apiError, error) {
	var secret *string
	var used *int64
	err := tx.QueryRow(ctx, `
		select totp_secret, totp_enabled, totp_used_step, email from two_factor where user_id = $1 for update`, u.id).
		Scan(&secret, &u.totp, &used, &u.emailCodes)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	totp := u.totp && secret != nil
	byEmail := s.emailsCodes(u)
	var methods []string
	if totp {
		methods = append(methods, "totp")
	}
	if byEmail {
		methods = append(methods, "email")
	}
	if len(methods) == 0 {
		return nil, nil
	}
	c := cleanCode(code)
	if c == "" {
		return &apiError{status: http.StatusUnauthorized, code: "two_factor_required", params: map[string]any{"methods": methods}}, nil
	}
	if totp {
		if step, ok := totpMatch(*secret, c, time.Now(), used); ok {
			_, err := tx.Exec(ctx, `update two_factor set totp_used_step = $2 where user_id = $1`, u.id, step)
			return nil, err
		}
		tag, err := tx.Exec(ctx, `delete from recovery_codes where user_id = $1 and code_hash = $2`, u.id, codeHash(u.id, c))
		if err != nil || tag.RowsAffected() > 0 {
			return nil, err
		}
	}
	if byEmail {
		if ok, err := takeLoginCode(ctx, tx, u.id, c); err != nil || ok {
			return nil, err
		}
	}
	return errInvalidCode, nil
}

// emailsCodes reports whether u, which chose codes by email, can get one: it
// needs a confirmed address and a server that sends email. An account that
// lost either signs in without, rather than not at all.
func (s *Server) emailsCodes(u *user) bool {
	return u.emailCodes && u.email != nil && u.verified && s.mailer() != nil
}

// takeLoginCode spends the code emailed to the account, if code is it. A
// wrong one counts against it, and after loginCodeTries it is good no more.
func takeLoginCode(ctx context.Context, tx pgx.Tx, userID, code string) (bool, error) {
	var hash []byte
	var live bool
	err := tx.QueryRow(ctx, `
		select code_hash, expires_at > now() and attempts < $2 from login_codes where user_id = $1 for update`,
		userID, loginCodeTries).Scan(&hash, &live)
	if errors.Is(err, pgx.ErrNoRows) || err == nil && !live {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	if subtle.ConstantTimeCompare(hash, codeHash(userID, code)) != 1 {
		_, err := tx.Exec(ctx, `update login_codes set attempts = attempts + 1 where user_id = $1`, userID)
		return false, err
	}
	_, err = tx.Exec(ctx, `delete from login_codes where user_id = $1`, userID)
	return err == nil, err
}

// EmailLoginCode emails a sign-in code to an account that takes them, once
// its password is right, at most one a minute.
func (s *Server) EmailLoginCode(ctx context.Context, req EmailLoginCodeRequestObject) (EmailLoginCodeResponseObject, error) {
	if err := s.requirePasswords(); err != nil {
		return nil, err
	}
	u, hash, release, err := s.checkLogin(ctx, req.Body.Login, req.Body.Password)
	if err != nil {
		return nil, err
	}
	var code string
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if err := lockLogin(ctx, tx, u, hash); err != nil {
			return err
		}
		err := tx.QueryRow(ctx, `select email from two_factor where user_id = $1 for update`, u.id).Scan(&u.emailCodes)
		if err != nil && !errors.Is(err, pgx.ErrNoRows) {
			return err
		}
		if !s.emailsCodes(u) {
			return badRequest("two_factor_off")
		}
		var recent bool
		err = tx.QueryRow(ctx, `
			select exists (select 1 from login_codes where user_id = $1 and created_at > now() - interval '1 minute')`,
			u.id).Scan(&recent)
		if err != nil || recent {
			return err
		}
		n, err := rand.Int(rand.Reader, big.NewInt(1_000_000))
		if err != nil {
			return err
		}
		code = fmt.Sprintf("%06d", n.Int64())
		_, err = tx.Exec(ctx, `
			insert into login_codes (user_id, code_hash, expires_at) values ($1, $2, $3)
			on conflict (user_id) do update set code_hash = excluded.code_hash, attempts = 0,
				expires_at = excluded.expires_at, created_at = now()`,
			u.id, codeHash(u.id, code), time.Now().Add(loginCodeLifetime))
		return err
	})
	// The password was right, whatever else is: only a wrong one is a guess.
	if err != errBadLogin {
		release()
	}
	if err != nil {
		return nil, err
	}
	if code != "" {
		s.sendMail(loginCodeMail(*u.email, u.name, code))
	}
	return EmailLoginCode204Response{}, nil
}

// requireTwoFactor is requireAccount for the settings of two-step sign-in,
// which only an account that signs in with a password has a use for.
func (s *Server) requireTwoFactor(ctx context.Context) (*user, error) {
	if err := s.requirePasswords(); err != nil {
		return nil, err
	}
	u, err := s.requireAccount(ctx)
	if err == nil && !u.hasPassword {
		err = badRequest("password_needed")
	}
	return u, err
}

func (s *Server) SetupTotp(ctx context.Context, req SetupTotpRequestObject) (SetupTotpResponseObject, error) {
	u, err := s.requireTwoFactor(ctx)
	if err != nil {
		return nil, err
	}
	checked, err := s.confirmPassword(ctx, u, req.Body.Password)
	if err != nil {
		return nil, err
	}
	secret := newTotpSecret()
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if err := lockAccount(ctx, tx, u, checked); err != nil {
			return err
		}
		var on bool
		err := tx.QueryRow(ctx, `select totp_enabled from two_factor where user_id = $1 for update`, u.id).Scan(&on)
		if err != nil && !errors.Is(err, pgx.ErrNoRows) {
			return err
		}
		if on {
			return conflict("totp_on")
		}
		_, err = tx.Exec(ctx, `
			insert into two_factor (user_id, totp_secret) values ($1, $2)
			on conflict (user_id) do update set totp_secret = excluded.totp_secret, totp_used_step = null`, u.id, secret)
		return err
	})
	if err != nil {
		return nil, err
	}
	account := u.name
	if u.email != nil {
		account = *u.email
	} else if u.username != nil {
		account = *u.username
	}
	return SetupTotp200JSONResponse{Secret: secret, Uri: totpURI(secret, account)}, nil
}

func (s *Server) ConfirmTotp(ctx context.Context, req ConfirmTotpRequestObject) (ConfirmTotpResponseObject, error) {
	u, err := s.requireTwoFactor(ctx)
	if err != nil {
		return nil, err
	}
	var codes []string
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var secret *string
		var on bool
		err := tx.QueryRow(ctx, `select totp_secret, totp_enabled from two_factor where user_id = $1 for update`, u.id).
			Scan(&secret, &on)
		if errors.Is(err, pgx.ErrNoRows) || err == nil && secret == nil {
			return badRequest("totp_not_started")
		}
		if err != nil {
			return err
		}
		if on {
			return conflict("totp_on")
		}
		step, ok := totpMatch(*secret, cleanCode(&req.Body.Code), time.Now(), nil)
		if !ok {
			return badRequest("invalid_code")
		}
		if _, err := tx.Exec(ctx, `update two_factor set totp_enabled = true, totp_used_step = $2 where user_id = $1`, u.id, step); err != nil {
			return err
		}
		codes, err = newRecoveryCodes(ctx, tx, u.id)
		return err
	})
	if err != nil {
		return nil, err
	}
	return ConfirmTotp200JSONResponse{Codes: codes}, nil
}

func (s *Server) DisableTotp(ctx context.Context, req DisableTotpRequestObject) (DisableTotpResponseObject, error) {
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
		if _, err := tx.Exec(ctx, `
			update two_factor set totp_secret = null, totp_enabled = false, totp_used_step = null where user_id = $1`, u.id); err != nil {
			return err
		}
		_, err := tx.Exec(ctx, `delete from recovery_codes where user_id = $1`, u.id)
		return err
	})
	if err != nil {
		return nil, err
	}
	u.totp = false
	return DisableTotp200JSONResponse(u.api()), nil
}

func (s *Server) SetEmailTwoFactor(ctx context.Context, req SetEmailTwoFactorRequestObject) (SetEmailTwoFactorResponseObject, error) {
	on := req.Body.Enabled
	u, err := s.requireAccount(ctx)
	if on && err == nil {
		u, err = s.requireTwoFactor(ctx)
	}
	if err != nil {
		return nil, err
	}
	if on {
		if err := s.requireEmail(); err != nil {
			return nil, err
		}
	}
	checked, err := s.confirmPassword(ctx, u, req.Body.Password)
	if err != nil {
		return nil, err
	}
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if err := lockAccount(ctx, tx, u, checked); err != nil {
			return err
		}
		if !on {
			if _, err := tx.Exec(ctx, `update two_factor set email = false where user_id = $1`, u.id); err != nil {
				return err
			}
			_, err := tx.Exec(ctx, `delete from login_codes where user_id = $1`, u.id)
			return err
		}
		// The address is read under the lock: a code must reach its owner.
		var confirmed bool
		err := tx.QueryRow(ctx, `select email is not null and email_verified from users where id = $1`, u.id).Scan(&confirmed)
		if err != nil {
			return err
		}
		if !confirmed {
			return forbidden("email_unverified")
		}
		_, err = tx.Exec(ctx, `
			insert into two_factor (user_id, email) values ($1, true)
			on conflict (user_id) do update set email = true`, u.id)
		return err
	})
	if err != nil {
		return nil, err
	}
	u.emailCodes = on
	return SetEmailTwoFactor200JSONResponse(u.api()), nil
}

func loginCodeMail(to, name, code string) mail.Message {
	return mail.Message{
		To:      to,
		Subject: "Your Balnana sign-in code",
		Body: fmt.Sprintf(`Hi %s,

Your code to sign in to Balnana is:

%s

It works for 10 minutes. If you didn't try to sign in, someone knows your password: change it now.
`, name, code),
	}
}
