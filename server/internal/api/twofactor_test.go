package api

import (
	"encoding/base32"
	"regexp"
	"slices"
	"testing"
	"time"
)

func TestTotpCode(t *testing.T) {
	// RFC 6238, appendix B, with its last six digits.
	key := []byte("12345678901234567890")
	for at, want := range map[int64]string{59: "287082", 1111111109: "081804", 1234567890: "005924", 2000000000: "279037"} {
		if got := totpCode(key, at/30); got != want {
			t.Errorf("at %d: %s, want %s", at, got, want)
		}
	}
	secret := base32.StdEncoding.WithPadding(base32.NoPadding).EncodeToString(key)
	now := time.Unix(1111111109, 0)
	step := now.Unix() / 30
	if got, ok := totpMatch(secret, "081804", now, nil); !ok || got != step {
		t.Fatal(got, ok)
	}
	// A clock one period off is close enough; a code already taken is not.
	if _, ok := totpMatch(secret, "081804", now.Add(30*time.Second), nil); !ok {
		t.Fatal("the period before was refused")
	}
	if _, ok := totpMatch(secret, "081804", now.Add(90*time.Second), nil); ok {
		t.Fatal("an old code was taken")
	}
	if _, ok := totpMatch(secret, "081804", now, &step); ok {
		t.Fatal("a code was taken twice")
	}
}

// codeNow is the code an authenticator app with secret shows.
func codeNow(t *testing.T, secret string) string {
	t.Helper()
	key, err := totpEncoding.DecodeString(secret)
	if err != nil {
		t.Fatal(err)
	}
	return totpCode(key, time.Now().Unix()/30)
}

func twoFactorMethods(c *client, in LoginInput) []string {
	c.t.Helper()
	var e Error
	if got := c.call("POST", "/auth/login", in, &e); got != 401 || e.Code != "two_factor_required" {
		c.t.Fatalf("status %d %+v", got, e)
	}
	return toStrings((*e.Params)["methods"])
}

func TestTotpSignIn(t *testing.T) {
	c, _, s := mailServer(t, map[string]string{})
	register(c, "ana@example.com", "Ana")
	login := LoginInput{Login: "ana@example.com", Password: "correct horse"}

	// Adding the app takes the password, and asks for nothing until a code
	// from it shows the app has the key.
	if code := c.errorCode(403, "POST", "/me/two-factor/totp", PasswordConfirm{Password: ptr("wrong password")}); code != "wrong_password" {
		t.Fatal(code)
	}
	var setup TotpSetup
	c.must(200, "POST", "/me/two-factor/totp", PasswordConfirm{Password: ptr("correct horse")}, &setup)
	if !regexp.MustCompile(`^otpauth://totp/Balnana:ana@example\.com\?issuer=Balnana&secret=[A-Z2-7]{32}$`).MatchString(setup.Uri) {
		t.Fatal(setup.Uri)
	}
	c.another().must(200, "POST", "/auth/login", login, nil)
	if code := c.errorCode(400, "POST", "/me/two-factor/totp/confirm", TotpConfirm{Code: "000000"}); code != "invalid_code" && codeNow(t, setup.Secret) != "000000" {
		t.Fatal(code)
	}
	var recovery RecoveryCodes
	c.must(200, "POST", "/me/two-factor/totp/confirm", TotpConfirm{Code: codeNow(t, setup.Secret)}, &recovery)
	if len(recovery.Codes) != recoveryCodes || !regexp.MustCompile(`^[A-Z2-9]{5}-[A-Z2-9]{5}$`).MatchString(recovery.Codes[0]) {
		t.Fatalf("%v", recovery.Codes)
	}
	var me User
	c.must(200, "GET", "/me", nil, &me)
	if !me.Totp || me.EmailTwoFactor {
		t.Fatalf("%+v", me)
	}
	if code := c.errorCode(409, "POST", "/me/two-factor/totp", PasswordConfirm{Password: ptr("correct horse")}); code != "totp_on" {
		t.Fatal(code)
	}

	// The password alone no longer signs in, and a wrong password says
	// nothing of the second step.
	web := c.another()
	if methods := twoFactorMethods(web, login); !slices.Equal(methods, []string{"totp"}) {
		t.Fatal(methods)
	}
	if code := web.errorCode(401, "POST", "/auth/login", LoginInput{Login: "ana@example.com", Password: "wrong password", Code: ptr("123456")}); code != "invalid_credentials" {
		t.Fatal(code)
	}
	// The code that turned the app on was taken then, so only a later one
	// signs in: a recovery code does meanwhile, once.
	withCode := login
	withCode.Code = ptr(codeNow(t, setup.Secret))
	if code := web.errorCode(401, "POST", "/auth/login", withCode); code != "invalid_code" {
		t.Fatal(code)
	}
	withCode.Code = ptr(" " + recovery.Codes[0][:5] + " " + recovery.Codes[0][6:] + " ")
	var session Session
	web.must(200, "POST", "/auth/login", withCode, &session)
	if session.Token == nil || !session.User.Totp {
		t.Fatalf("%+v", session)
	}
	if code := web.errorCode(401, "POST", "/auth/login", withCode); code != "invalid_code" {
		t.Fatal(code)
	}
	// A code of a later period signs in.
	exec(t, s, `update two_factor set totp_used_step = totp_used_step - 5`)
	withCode.Code = ptr(codeNow(t, setup.Secret))
	web.must(200, "POST", "/auth/login", withCode, nil)
	if code := web.errorCode(401, "POST", "/auth/login", withCode); code != "invalid_code" {
		t.Fatal("a code signed in twice: " + code)
	}

	// Turning it off takes the password, and the recovery codes go with it.
	if code := c.errorCode(403, "POST", "/me/two-factor/totp/disable", PasswordConfirm{}); code != "wrong_password" {
		t.Fatal(code)
	}
	c.must(200, "POST", "/me/two-factor/totp/disable", PasswordConfirm{Password: ptr("correct horse")}, &me)
	if me.Totp {
		t.Fatalf("%+v", me)
	}
	web.must(200, "POST", "/auth/login", login, nil)
	withCode.Code = &recovery.Codes[1]
	web.must(200, "POST", "/auth/login", withCode, nil) // a code nobody asks for is not looked at
}

func TestEmailTwoFactor(t *testing.T) {
	c, f, s := mailServer(t, map[string]string{})
	register(c, "ana@example.com", "Ana")
	login := LoginInput{Login: "ana@example.com", Password: "correct horse"}
	on := EmailTwoFactor{Enabled: true, Password: ptr("correct horse")}

	// Codes only go to an address its owner confirmed.
	if code := c.errorCode(403, "PUT", "/me/two-factor/email", on); code != "email_unverified" {
		t.Fatal(code)
	}
	confirmEmail(c, f, "ana@example.com")
	if code := c.errorCode(403, "PUT", "/me/two-factor/email", EmailTwoFactor{Enabled: true}); code != "wrong_password" {
		t.Fatal(code)
	}
	var me User
	c.must(200, "PUT", "/me/two-factor/email", on, &me)
	if !me.EmailTwoFactor || me.Totp {
		t.Fatalf("%+v", me)
	}

	web := c.another()
	if methods := twoFactorMethods(web, login); !slices.Equal(methods, []string{"email"}) {
		t.Fatal(methods)
	}
	if code := web.errorCode(401, "POST", "/auth/login/email-code", LoginInput{Login: "ana@example.com", Password: "wrong password"}); code != "invalid_credentials" {
		t.Fatal(code)
	}
	web.must(204, "POST", "/auth/login/email-code", login, nil)
	var code string
	select {
	case m := <-f:
		code = regexp.MustCompile(`\n(\d{6})\n`).FindStringSubmatch(m.Body)[1]
	case <-time.After(5 * time.Second):
		t.Fatal("no code sent")
	}
	// Asking again within the minute sends nothing more.
	web.must(204, "POST", "/auth/login/email-code", login, nil)
	s.FinishMail()
	if len(f) != 0 {
		t.Fatal("a second code was sent")
	}

	wrong := login
	wrong.Code = ptr("000000")
	if code == "000000" {
		wrong.Code = ptr("000001")
	}
	if got := web.errorCode(401, "POST", "/auth/login", wrong); got != "invalid_code" {
		t.Fatal(got)
	}
	var tries int
	if err := s.db.QueryRow(t.Context(), `select attempts from login_codes`).Scan(&tries); err != nil || tries != 1 {
		t.Fatal(tries, err)
	}
	right := login
	right.Code = &code
	web.must(200, "POST", "/auth/login", right, nil)
	if got := web.errorCode(401, "POST", "/auth/login", right); got != "invalid_code" {
		t.Fatal("a code signed in twice: " + got)
	}

	// Too many wrong guesses spend the code.
	exec(t, s, `update login_codes set created_at = now() - interval '2 minutes'`)
	web.must(204, "POST", "/auth/login/email-code", login, nil)
	select {
	case m := <-f:
		code = regexp.MustCompile(`\n(\d{6})\n`).FindStringSubmatch(m.Body)[1]
	case <-time.After(5 * time.Second):
		t.Fatal("no code sent")
	}
	exec(t, s, `update login_codes set attempts = $1`, loginCodeTries)
	right.Code = &code
	if got := web.errorCode(401, "POST", "/auth/login", right); got != "invalid_code" {
		t.Fatal(got)
	}

	// Off again, the password is enough.
	c.must(200, "PUT", "/me/two-factor/email", EmailTwoFactor{Enabled: false, Password: ptr("correct horse")}, &me)
	if me.EmailTwoFactor {
		t.Fatalf("%+v", me)
	}
	if got := web.errorCode(400, "POST", "/auth/login/email-code", login); got != "two_factor_off" {
		t.Fatal(got)
	}
	web.must(200, "POST", "/auth/login", login, nil)
}

// An account that can no longer be sent a code signs in without one.
func TestEmailTwoFactorNeedsEmail(t *testing.T) {
	c, f, s := mailServer(t, map[string]string{})
	register(c, "ana@example.com", "Ana")
	confirmEmail(c, f, "ana@example.com")
	c.must(200, "PUT", "/me/two-factor/email", EmailTwoFactor{Enabled: true, Password: ptr("correct horse")}, nil)
	login := LoginInput{Login: "ana@example.com", Password: "correct horse"}
	twoFactorMethods(c.another(), login)
	s.settings.Load().mail = nil
	c.another().must(200, "POST", "/auth/login", login, nil)
}

// Whoever made an account with someone else's address must not keep its
// owner out with an authenticator app of their own.
func TestReclaimDropsTwoFactor(t *testing.T) {
	c, f, _ := mailServer(t, map[string]string{})
	register(c, "ana@example.com", "Mallory")
	var setup TotpSetup
	c.must(200, "POST", "/me/two-factor/totp", PasswordConfirm{Password: ptr("correct horse")}, &setup)
	c.must(200, "POST", "/me/two-factor/totp/confirm", TotpConfirm{Code: codeNow(t, setup.Secret)}, nil)

	owner := c.another()
	owner.must(204, "POST", "/auth/password-reset", PasswordResetRequest{Email: "ana@example.com"}, nil)
	token := lastPart(f.next(t, "ana@example.com"))
	owner.must(204, "POST", "/auth/password-reset/confirm", PasswordReset{Token: token, NewPassword: "battery staple"}, nil)
	owner.must(200, "POST", "/auth/login", LoginInput{Login: "ana@example.com", Password: "battery staple"}, nil)
}
