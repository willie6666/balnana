package api

import (
	"context"
	"log/slog"
	"net/http"
	"regexp"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"balnana/internal/mail"
)

// fakeMail collects the messages a server sends.
type fakeMail chan mail.Message

func (f fakeMail) Send(_ context.Context, m mail.Message) error {
	f <- m
	return nil
}

// next waits for the next message to `to` and returns the link in it.
func (f fakeMail) next(t *testing.T, to string) string {
	t.Helper()
	select {
	case m := <-f:
		if !strings.EqualFold(m.To, to) {
			t.Fatalf("mail to %s, want %s", m.To, to)
		}
		link := regexp.MustCompile(`https?://\S+`).FindString(m.Body)
		if link == "" {
			t.Fatalf("no link in %q", m.Body)
		}
		return link
	case <-time.After(5 * time.Second):
		t.Fatalf("no mail to %s", to)
		return ""
	}
}

func (f fakeMail) none(t *testing.T) {
	t.Helper()
	select {
	case m := <-f:
		t.Fatalf("unexpected mail to %s: %s", m.To, m.Subject)
	case <-time.After(100 * time.Millisecond):
	}
}

// mailClient is an accounts client whose server sends email to a fakeMail.
func mailClient(t *testing.T, env map[string]string) (*client, fakeMail) {
	c, f, _ := mailServer(t, env)
	return c, f
}

// mailServer is mailClient that also returns its server.
func mailServer(t *testing.T, env map[string]string) (*client, fakeMail, *Server) {
	env["BALNANA_AUTH_MODE"] = "accounts"
	s := NewServer(baseConfig(t, env), testDB(t), slog.New(slog.DiscardHandler), "test")
	f := make(fakeMail, 10)
	s.settings.Load().mail = f
	return &client{t: t, h: NewHandler(s, http.NotFoundHandler())}, f, s
}

// takeAddress puts email on the account unverified, as changing it did while
// the server had no email: with email, a new address waits for its owner.
func takeAddress(t *testing.T, db *pgxpool.Pool, userID, email string) {
	t.Helper()
	if _, err := db.Exec(context.Background(), `update users set email = $2, email_verified = false where id = $1`,
		userID, email); err != nil {
		t.Fatal(err)
	}
}

// confirmEmail confirms the address on c's account through the email.
func confirmEmail(c *client, f fakeMail, email string) {
	c.t.Helper()
	c.must(204, "POST", "/me/verify-email", nil, nil)
	c.another().must(204, "POST", "/auth/verify-email", EmailToken{Token: lastPart(f.next(c.t, email))}, nil)
}

func lastPart(link string) string {
	return regexp.MustCompile(`[^/=]+$`).FindString(link)
}

func TestVerifyEmail(t *testing.T) {
	c, f := mailClient(t, map[string]string{})
	register(c, "ana@example.com", "Ana")
	c.must(204, "POST", "/me/verify-email", nil, nil)
	link := f.next(t, "ana@example.com")
	if want := "http://localhost:8080/verify-email?token="; link[:len(want)] != want {
		t.Fatal(link)
	}
	// Asking again within a minute sends nothing.
	c.must(204, "POST", "/me/verify-email", nil, nil)
	f.none(t)

	if code := c.another().errorCode(400, "POST", "/auth/verify-email", EmailToken{Token: "nonsense"}); code != "invalid_token" {
		t.Fatal(code)
	}
	c.another().must(204, "POST", "/auth/verify-email", EmailToken{Token: lastPart(link)}, nil)
	var me User
	c.must(200, "GET", "/me", nil, &me)
	if !me.EmailVerified {
		t.Fatal("not verified")
	}
	// A token works once.
	c.errorCode(400, "POST", "/auth/verify-email", EmailToken{Token: lastPart(link)})
}

func TestPasswordReset(t *testing.T) {
	c, f := mailClient(t, map[string]string{})
	register(c, "ana@example.com", "Ana")
	anon := c.another()
	// Unknown addresses look the same as known ones.
	anon.must(204, "POST", "/auth/password-reset", PasswordResetRequest{Email: "nobody@example.com"}, nil)
	f.none(t)
	anon.must(204, "POST", "/auth/password-reset", PasswordResetRequest{Email: "Ana@example.com"}, nil)
	token := lastPart(f.next(t, "ana@example.com"))

	if code := anon.errorCode(400, "POST", "/auth/password-reset/confirm", PasswordReset{Token: token, NewPassword: "short"}); code != "invalid_password" {
		t.Fatal(code)
	}
	anon.must(204, "POST", "/auth/password-reset/confirm", PasswordReset{Token: token, NewPassword: "new password"}, nil)
	if code := anon.errorCode(400, "POST", "/auth/password-reset/confirm", PasswordReset{Token: token, NewPassword: "other password"}); code != "invalid_token" {
		t.Fatal(code)
	}
	// Every session is signed out, and only the new password works.
	c.errorCode(401, "GET", "/me", nil)
	anon.errorCode(401, "POST", "/auth/login", LoginInput{Login: "ana@example.com", Password: "correct horse"})
	var s Session
	anon.must(200, "POST", "/auth/login", LoginInput{Login: "ana@example.com", Password: "new password"}, &s)
	if !s.User.EmailVerified {
		t.Fatal("reset did not verify the address")
	}
}

// A link works only for the address it was sent to. Changing the address
// deletes older links, but one made at the same moment could outlive that;
// here the address changes under a live link instead.
func TestEmailTokenBoundToAddress(t *testing.T) {
	c, f, s := mailServer(t, map[string]string{})
	ana := register(c, "ana@example.com", "Ana")
	c.must(204, "POST", "/me/verify-email", nil, nil)
	verify := lastPart(f.next(t, "ana@example.com"))
	c.another().must(204, "POST", "/auth/password-reset", PasswordResetRequest{Email: "ana@example.com"}, nil)
	reset := lastPart(f.next(t, "ana@example.com"))

	ctx := context.Background()
	if _, err := s.db.Exec(ctx, `update users set email = 'ben@example.com' where id = $1`, ana.Id); err != nil {
		t.Fatal(err)
	}
	if code := c.another().errorCode(400, "POST", "/auth/verify-email", EmailToken{Token: verify}); code != "invalid_token" {
		t.Fatal(code)
	}
	if code := c.another().errorCode(400, "POST", "/auth/password-reset/confirm", PasswordReset{Token: reset, NewPassword: "new password"}); code != "invalid_token" {
		t.Fatal(code)
	}
	var me User
	c.must(200, "GET", "/me", nil, &me)
	if me.EmailVerified {
		t.Fatal("verified an address the link never went to")
	}
	c.another().must(200, "POST", "/auth/login", LoginInput{Login: "ben@example.com", Password: "correct horse"}, nil)

	// Back to the address the links went to: they work again.
	if _, err := s.db.Exec(ctx, `update users set email = 'ana@example.com' where id = $1`, ana.Id); err != nil {
		t.Fatal(err)
	}
	c.another().must(204, "POST", "/auth/verify-email", EmailToken{Token: verify}, nil)
}

func TestEmailOff(t *testing.T) {
	c := accountsClient(t, map[string]string{})
	register(c, "ana@example.com", "Ana")
	if code := c.errorCode(403, "POST", "/me/verify-email", nil); code != "email_off" {
		t.Fatal(code)
	}
	if code := c.another().errorCode(403, "POST", "/auth/password-reset", PasswordResetRequest{Email: "ana@example.com"}); code != "email_off" {
		t.Fatal(code)
	}
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if info.Email {
		t.Fatal("email on without SMTP")
	}
}

// Someone who made an account with another person's address loses it when
// that person registers with an invitation sent there.
func TestInviteReclaimsAccount(t *testing.T) {
	ana, f := mailClient(t, map[string]string{})
	register(ana, "ana@example.com", "Ana")
	confirmEmail(ana, f, "ana@example.com")
	g := createGroup(ana, "Ana", "Ben")
	mallory := ana.another()
	taken := register(mallory, "ben@example.com", "Mallory")

	ana.must(204, "POST", "/g/"+g.Token+"/invites", InviteInput{Email: "ben@example.com"}, nil)
	token := lastPart(f.next(t, "ben@example.com"))
	ben := ana.another()
	if code := ben.errorCode(409, "POST", "/auth/register", RegisterInput{Email: ptr("ben@example.com"), Password: "12345678", Name: "Ben"}); code != "email_taken" {
		t.Fatal(code)
	}
	var s Session
	ben.must(201, "POST", "/auth/register", RegisterInput{Email: ptr("ben@example.com"), Password: "12345678", Name: "Ben", Invite: &token}, &s)
	if s.User.Id != taken.Id || !s.User.EmailVerified || s.User.Name != "Ben" {
		t.Fatalf("session = %+v", s)
	}
	mallory.errorCode(401, "GET", "/me", nil)
	mallory.another().errorCode(401, "POST", "/auth/login", LoginInput{Login: "ben@example.com", Password: "correct horse"})
}

func TestInvites(t *testing.T) {
	ana, f := mailClient(t, map[string]string{"BALNANA_AUTH_SIGNUP": "invite_only"})
	register(ana, "ana@example.com", "Ana")
	// Only a confirmed address sends invitations.
	if code := ana.errorCode(403, "POST", "/g/"+createGroup(ana, "Ana").Token+"/invites", InviteInput{Email: "ben@example.com"}); code != "email_unverified" {
		t.Fatal(code)
	}
	confirmEmail(ana, f, "ana@example.com")
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &g)
	path := "/g/" + g.Token
	benID := g.Members[1].Id

	if code := ana.errorCode(409, "POST", path+"/invites", InviteInput{Email: "x@example.com", MemberId: &g.Members[0].Id}); code != "member_claimed" {
		t.Fatal(code)
	}
	ana.must(204, "POST", path+"/invites", InviteInput{Email: "Ben@Example.com", MemberId: &benID}, nil)
	link := f.next(t, "ben@example.com")
	token := lastPart(link)
	if want := "http://localhost:8080/invite/" + token; link != want {
		t.Fatal(link)
	}

	ben := ana.another()
	var invite InviteInfo
	ben.must(200, "GET", "/auth/invites/"+token, nil, &invite)
	if !strings.EqualFold(invite.Email, "ben@example.com") || invite.GroupToken != g.Token || invite.GroupName != "Flat" || invite.InvitedBy == nil || *invite.InvitedBy != "Ana" {
		t.Fatalf("invite = %+v", invite)
	}
	ben.errorCode(404, "GET", "/auth/invites/nonsense", nil)

	// Without the link, or for another address, signing up stays closed.
	if code := ben.errorCode(403, "POST", "/auth/register", RegisterInput{Email: ptr("ben@example.com"), Password: "12345678", Name: "Ben"}); code != "signup_closed" {
		t.Fatal(code)
	}
	if code := ben.errorCode(403, "POST", "/auth/register", RegisterInput{Email: ptr("eve@example.com"), Password: "12345678", Name: "Eve", Invite: &token}); code != "signup_closed" {
		t.Fatal(code)
	}
	var s Session
	ben.must(201, "POST", "/auth/register", RegisterInput{Email: ptr("ben@example.com"), Password: "12345678", Name: "Benjamin", Invite: &token}, &s)
	if !s.User.EmailVerified {
		t.Fatal("invited account not verified")
	}
	ben.token = *s.Token

	// The join page suggests the member Ben was invited as.
	var info JoinInfo
	ben.must(200, "GET", path+"/join", nil, &info)
	if info.InvitedMemberId == nil || *info.InvitedMemberId != benID {
		t.Fatalf("invitedMemberId = %v", info.InvitedMemberId)
	}
	var joined Group
	ben.must(200, "POST", path+"/join", JoinInput{ClaimMemberId: &benID}, &joined)
	ben.errorCode(404, "GET", "/auth/invites/"+token, nil)

	// Only members invite.
	cy := ana.another()
	ana.must(204, "POST", path+"/invites", InviteInput{Email: "cy@example.com"}, nil)
	cyToken := lastPart(f.next(t, "cy@example.com"))
	cy.must(201, "POST", "/auth/register", RegisterInput{Email: ptr("cy@example.com"), Password: "12345678", Name: "Cy", Invite: &cyToken}, &s)
	cy.token = *s.Token
	if code := cy.errorCode(403, "POST", "/g/"+g.Token+"/invites", InviteInput{Email: "dee@example.com"}); code != "not_a_member" {
		t.Fatal(code)
	}

	// An invitation hands out the link, so resetting it withdraws them all.
	ana.must(200, "GET", "/auth/invites/"+cyToken, nil, nil)
	ana.must(200, "POST", path+"/reset-link", nil, nil)
	if code := cy.errorCode(404, "GET", "/auth/invites/"+cyToken, nil); code != "not_found" {
		t.Fatal(code)
	}
}

func TestChangeEmailWaitsForConfirmation(t *testing.T) {
	c, f := mailClient(t, map[string]string{})
	register(c, "ana@example.com", "Ana")
	register(c.another(), "ben@example.com", "Ben")
	pw := ptr("correct horse")

	if code := c.errorCode(409, "POST", "/me/email", EmailChange{Email: "Ben@example.com", Password: pw}); code != "email_taken" {
		t.Fatal(code)
	}
	var me User
	c.must(200, "POST", "/me/email", EmailChange{Email: "ana@example.org", Password: pw}, &me)
	if *me.Email != "ana@example.com" || me.PendingEmail == nil || *me.PendingEmail != "ana@example.org" {
		t.Fatalf("me = %+v", me)
	}
	link := f.next(t, "ana@example.org")
	// Until the link is opened the old address is the one that signs in.
	c.another().must(200, "POST", "/auth/login", LoginInput{Login: "ana@example.com", Password: "correct horse"}, nil)
	c.another().errorCode(401, "POST", "/auth/login", LoginInput{Login: "ana@example.org", Password: "correct horse"})
	// Asking for a new link sends it to the pending address.
	c.must(204, "POST", "/me/verify-email", nil, nil)
	f.none(t) // within a minute of the last one

	c.another().must(204, "POST", "/auth/verify-email", EmailToken{Token: lastPart(link)}, nil)
	me = User{} // fields left out of the answer stay as they were otherwise
	c.must(200, "GET", "/me", nil, &me)
	if *me.Email != "ana@example.org" || !me.EmailVerified || me.PendingEmail != nil {
		t.Fatalf("me = %+v", me)
	}
	c.another().must(200, "POST", "/auth/login", LoginInput{Login: "ana@example.org", Password: "correct horse"}, nil)

	// Going back to the current address drops a pending one, and its link.
	c.must(200, "POST", "/me/email", EmailChange{Email: "typo@example.con", Password: pw}, &me)
	link = f.next(t, "typo@example.con")
	me = User{}
	c.must(200, "POST", "/me/email", EmailChange{Email: "ana@example.org", Password: pw}, &me)
	if me.PendingEmail != nil || !me.EmailVerified {
		t.Fatalf("me = %+v", me)
	}
	if code := c.another().errorCode(400, "POST", "/auth/verify-email", EmailToken{Token: lastPart(link)}); code != "invalid_token" {
		t.Fatal(code)
	}

	// An address taken while it was pending is not handed over.
	c.must(200, "POST", "/me/email", EmailChange{Email: "cy@example.com", Password: pw}, nil)
	link = f.next(t, "cy@example.com")
	register(c.another(), "cy@example.com", "Cy")
	if code := c.another().errorCode(409, "POST", "/auth/verify-email", EmailToken{Token: lastPart(link)}); code != "email_taken" {
		t.Fatal(code)
	}
	c.must(200, "GET", "/me", nil, &me)
	if *me.Email != "ana@example.org" {
		t.Fatalf("me = %+v", me)
	}
}

func TestChangeEmailLimit(t *testing.T) {
	c, f := mailClient(t, map[string]string{})
	register(c, "ana@example.com", "Ana")
	for i := range emailChangeBurst {
		c.must(200, "POST", "/me/email", EmailChange{Email: string(rune('a'+i)) + "@example.org", Password: ptr("correct horse")}, nil)
		f.next(t, string(rune('a'+i))+"@example.org")
	}
	if code := c.errorCode(429, "POST", "/me/email", EmailChange{Email: "z@example.org", Password: ptr("correct horse")}); code != "rate_limited" {
		t.Fatal(code)
	}
	f.none(t)
}
