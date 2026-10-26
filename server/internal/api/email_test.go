package api

import (
	"context"
	"log/slog"
	"net/http"
	"regexp"
	"strings"
	"testing"
	"time"

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
	env["BALNANA_AUTH_MODE"] = "accounts"
	s := NewServer(baseConfig(t, env), testDB(t), slog.New(slog.DiscardHandler), "test")
	f := make(fakeMail, 10)
	s.settings.Load().mail = f
	return &client{t: t, h: NewHandler(s, http.NotFoundHandler())}, f
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

func TestInvites(t *testing.T) {
	ana, f := mailClient(t, map[string]string{"BALNANA_AUTH_SIGNUP": "invite_only"})
	register(ana, "ana@example.com", "Ana")
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
}
