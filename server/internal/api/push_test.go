package api

import (
	"context"
	"log/slog"
	"net/http"
	"slices"
	"strings"
	"sync"
	"testing"

	"balnana/internal/push"
)

// fakePush keeps what would have gone to Firebase.
type fakePush struct {
	mu   sync.Mutex
	sent []push.Message
	gone map[string]bool
}

func (f *fakePush) Send(_ context.Context, m push.Message) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.gone[m.Device] {
		return push.ErrGone
	}
	f.sent = append(f.sent, m)
	return nil
}

// take waits for the server to finish sending and returns what it sent,
// sorted by device.
func (f *fakePush) take(s *Server) []push.Message {
	s.pushing.Wait()
	f.mu.Lock()
	defer f.mu.Unlock()
	out := f.sent
	f.sent = nil
	slices.SortFunc(out, func(a, b push.Message) int { return strings.Compare(a.Device, b.Device) })
	return out
}

func pushClient(t *testing.T, env map[string]string) (*client, *fakePush, *Server) {
	s := NewServer(baseConfig(t, env), testDB(t), slog.New(slog.DiscardHandler), "test")
	f := &fakePush{gone: map[string]bool{}}
	s.push = f
	return &client{t: t, h: NewHandler(s, http.NotFoundHandler())}, f, s
}

func follow(token, member string) PushDeviceInput {
	in := PushDeviceInput{}
	in.Groups = append(in.Groups, struct {
		MemberId string `json:"memberId"`
		Token    string `json:"token"`
	}{member, token})
	return in
}

func TestPushLinkMode(t *testing.T) {
	c, f, s := pushClient(t, map[string]string{})
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if !info.Push {
		t.Fatal("push is off")
	}
	g := createGroup(c, "Ana", "Ben", "Cy")
	ana, ben, cy := g.Members[0].Id, g.Members[1].Id, g.Members[2].Id
	c.must(204, "PUT", "/push/devices/ana-phone", follow(g.Token, ana), nil)
	c.must(204, "PUT", "/push/devices/ben-phone", follow(g.Token, ben), nil)
	// Unknown groups and members are left out quietly.
	in := follow(g.Token, cy)
	in.Groups = append(in.Groups, follow("x"+g.Token[1:], cy).Groups[0], follow(g.Token, "not-a-member").Groups[0])
	c.must(204, "PUT", "/push/devices/cy-phone", in, nil)
	if code := c.errorCode(400, "PUT", "/push/devices/"+strings.Repeat("a", maxDeviceToken+1), follow(g.Token, cy)); code == "" {
		t.Error("long device token")
	}

	base := "/g/" + g.Token
	c.member = ana
	pizza := ExpenseInput{
		Title:       "Pizza",
		Amount:      "10",
		OccurredAt:  mustTime(t, "2026-10-01T19:00:00Z"),
		Payers:      []PayerInput{{MemberId: ana, Amount: "10"}},
		SplitMethod: "equal",
		Splits:      []Share{{MemberId: ana}, {MemberId: ben}},
	}
	var e Expense
	c.must(201, "POST", base+"/expenses", pizza, &e)
	sent := f.take(s)
	if len(sent) != 1 {
		t.Fatalf("sent %+v", sent)
	}
	if m := sent[0]; m.Device != "ben-phone" || m.Title != "Trip" || m.BodyKey != "push_expense_added" ||
		!slices.Equal(m.BodyArgs, []string{"Ana", "Pizza", "10.00 EUR"}) || m.Tag != e.Id || m.Data["group"] != g.Token {
		t.Errorf("message %+v", m)
	}

	// A phone Firebase no longer knows is forgotten.
	f.gone["ben-phone"] = true
	pizza.Version = ptr(1)
	c.must(200, "PUT", base+"/expenses/"+e.Id, pizza, &e)
	if sent := f.take(s); len(sent) != 0 {
		t.Errorf("sent %+v", sent)
	}
	var left int
	if err := s.db.QueryRow(context.Background(), `select count(*) from push_devices where token = 'ben-phone'`).Scan(&left); err != nil || left != 0 {
		t.Errorf("ben-phone kept: %d %v", left, err)
	}

	c.member = ben
	c.must(201, "POST", base+"/payments", PaymentInput{Amount: "5", FromMemberId: cy, ToMemberId: ana}, nil)
	sent = f.take(s)
	if len(sent) != 2 || sent[0].Device != "ana-phone" || sent[1].Device != "cy-phone" ||
		sent[0].BodyKey != "push_payment_added" || !slices.Equal(sent[0].BodyArgs, []string{"Cy", "Ana", "5.00 EUR"}) {
		t.Errorf("payment sent %+v", sent)
	}

	// Without knowing who did it, everyone involved hears.
	c.member = ""
	c.must(204, "DELETE", base+"/expenses/"+e.Id, nil, nil)
	sent = f.take(s)
	if len(sent) != 1 || sent[0].Device != "ana-phone" || sent[0].BodyKey != "push_expense_deleted_anon" ||
		!slices.Equal(sent[0].BodyArgs, []string{"Pizza", "10.00 EUR"}) {
		t.Errorf("delete sent %+v", sent)
	}
	// Deleting it again changes nothing, so says nothing.
	c.must(204, "DELETE", base+"/expenses/"+e.Id, nil, nil)
	c.must(204, "DELETE", "/push/devices/ana-phone", nil, nil)
	c.must(200, "POST", base+"/expenses/"+e.Id+"/restore", nil, nil)
	pizza.Version = ptr(4)
	c.must(200, "PUT", base+"/expenses/"+e.Id, pizza, nil)
	if sent := f.take(s); len(sent) != 0 {
		t.Errorf("sent after removal %+v", sent)
	}
}

func TestPushOff(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana")
	if code := c.errorCode(404, "PUT", "/push/devices/phone", follow(g.Token, g.Members[0].Id)); code != "push_off" {
		t.Errorf("code %q", code)
	}
}

func TestPushAccounts(t *testing.T) {
	ana, f, s := pushClient(t, map[string]string{"BALNANA_AUTH_MODE": "accounts"})
	register(ana, "ana@example.com", "Ana")
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &g)
	ben := ana.another()
	register(ben, "ben@example.com", "Ben")
	ben.must(200, "POST", "/g/"+g.Token+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)

	// Signed in, the phone hears about the account's groups. Following a
	// group the link does not open counts for nothing.
	ana.must(204, "PUT", "/push/devices/ana-phone", PushDeviceInput{Groups: follow(g.Token, g.Members[0].Id).Groups}, nil)
	stranger := ana.another()
	stranger.must(204, "PUT", "/push/devices/stranger-phone", follow(g.Token, g.Members[0].Id), nil)

	pay := func() {
		ben.must(201, "POST", "/g/"+g.Token+"/payments", PaymentInput{Amount: "5", FromMemberId: g.Members[1].Id, ToMemberId: g.Members[0].Id}, nil)
	}
	pay()
	if sent := f.take(s); len(sent) != 1 || sent[0].Device != "ana-phone" {
		t.Fatalf("sent %+v", sent)
	}

	// Signing out ends it.
	ana.must(204, "POST", "/auth/logout", nil, nil)
	pay()
	if sent := f.take(s); len(sent) != 0 {
		t.Errorf("sent after sign-out %+v", sent)
	}
}
