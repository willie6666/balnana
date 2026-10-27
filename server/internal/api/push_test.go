package api

import (
	"bytes"
	"context"
	"crypto/ecdh"
	"encoding/base64"
	"encoding/json"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"reflect"
	"slices"
	"strings"
	"sync"
	"testing"
	"time"
	"unicode/utf8"

	"github.com/jackc/pgx/v5"

	"balnana/internal/push"
)

// fakePush keeps what would have been sent.
type fakePush struct {
	mu   sync.Mutex
	sent []sentPush
	gone map[string]bool
	// before, when set, runs first in every send; an error it returns is
	// the send's.
	before func(phone string) error
}

// sentPush is one message, to the phone named by the last part of its
// endpoint (see subscribe).
type sentPush struct {
	phone string
	push.Message
	n notification
}

func (f *fakePush) Send(_ context.Context, m push.Message) error {
	phone := m.Endpoint[strings.LastIndex(m.Endpoint, "/")+1:]
	if f.before != nil {
		if err := f.before(phone); err != nil {
			return err
		}
	}
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.gone[phone] {
		return push.ErrGone
	}
	sp := sentPush{phone: phone, Message: m}
	if err := json.Unmarshal(m.Payload, &sp.n); err != nil {
		panic(err)
	}
	f.sent = append(f.sent, sp)
	return nil
}

// take waits for the server to finish sending and returns what it sent,
// sorted by phone.
func (f *fakePush) take(s *Server) []sentPush {
	s.pushing.Wait()
	f.mu.Lock()
	defer f.mu.Unlock()
	out := f.sent
	f.sent = nil
	slices.SortFunc(out, func(a, b sentPush) int { return strings.Compare(a.phone, b.phone) })
	return out
}

func pushClient(t *testing.T, env map[string]string) (*client, *fakePush, *Server) {
	s := NewServer(baseConfig(t, env), testDB(t), slog.New(slog.DiscardHandler), "test")
	f := &fakePush{gone: map[string]bool{}}
	s.push = f
	s.vapid = "test-key"
	return &client{t: t, h: NewHandler(s, http.NotFoundHandler())}, f, s
}

// phoneKey is a sound P-256 public key for test subscriptions.
var phoneKey = sync.OnceValue(func() string {
	k, err := ecdh.P256().GenerateKey(nil)
	if err != nil {
		panic(err)
	}
	return base64.RawURLEncoding.EncodeToString(k.PublicKey().Bytes())
})

// deviceID is the ID phone registers under.
func deviceID(phone string) string { return phone + "-0123456789abcdef" }

func follow(token, member string) PushDeviceInput {
	in := PushDeviceInput{}
	in.Groups = append(in.Groups, struct {
		MemberId string `json:"memberId"`
		Token    string `json:"token"`
	}{member, token})
	return in
}

// subscribe registers phone, with a subscription whose endpoint ends in
// its name.
func subscribe(c *client, phone string, in PushDeviceInput) {
	c.t.Helper()
	in.Endpoint, in.P256dh, in.Auth = "https://push.example.com/up/"+phone, phoneKey(), "MDEyMzQ1Njc4OWFiY2RlZg"
	c.must(204, "PUT", "/push/devices/"+deviceID(phone), in, nil)
}

func TestPushLinkMode(t *testing.T) {
	c, f, s := pushClient(t, map[string]string{})
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if !info.Push || info.VapidPublicKey == nil || *info.VapidPublicKey != "test-key" {
		t.Fatalf("push %v, key %v", info.Push, info.VapidPublicKey)
	}
	g := createGroup(c, "Ana", "Ben", "Cy")
	ana, ben, cy := g.Members[0].Id, g.Members[1].Id, g.Members[2].Id
	subscribe(c, "ana-phone", follow(g.Token, ana))
	subscribe(c, "ben-phone", follow(g.Token, ben))
	// Unknown groups and members are left out quietly.
	in := follow(g.Token, cy)
	in.Groups = append(in.Groups, follow("x"+g.Token[1:], cy).Groups[0], follow(g.Token, "not-a-member").Groups[0])
	subscribe(c, "cy-phone", in)

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
	want := notification{Group: g.Token, Expense: e.Id, Title: "Trip", Key: "push_expense_added", Args: []string{"Ana", "Pizza", "10.00 EUR"}}
	if m := sent[0]; m.phone != "ben-phone" || !reflect.DeepEqual(m.n, want) || m.Topic != strings.ReplaceAll(e.Id, "-", "") ||
		len(m.Topic) != 32 || m.TTL != pushTTL || m.P256dh != phoneKey() {
		t.Errorf("message %+v", m)
	}

	// A phone whose subscription has ended is forgotten.
	f.gone["ben-phone"] = true
	pizza.Version = ptr(1)
	c.must(200, "PUT", base+"/expenses/"+e.Id, pizza, &e)
	if sent := f.take(s); len(sent) != 0 {
		t.Errorf("sent %+v", sent)
	}
	var left int
	if err := s.db.QueryRow(context.Background(), `select count(*) from push_devices where token = $1`, deviceID("ben-phone")).Scan(&left); err != nil || left != 0 {
		t.Errorf("ben-phone kept: %d %v", left, err)
	}

	c.member = ben
	c.must(201, "POST", base+"/payments", PaymentInput{Amount: "5", FromMemberId: cy, ToMemberId: ana}, nil)
	sent = f.take(s)
	if len(sent) != 2 || sent[0].phone != "ana-phone" || sent[1].phone != "cy-phone" ||
		sent[0].n.Key != "push_payment_added" || !slices.Equal(sent[0].n.Args, []string{"Cy", "Ana", "5.00 EUR"}) {
		t.Errorf("payment sent %+v", sent)
	}
	// A symbol the group picked stands in for the currency code.
	c.must(200, "PATCH", base, GroupUpdate{Symbol: ptr("€")}, nil)
	c.must(201, "POST", base+"/payments", PaymentInput{Amount: "5", FromMemberId: cy, ToMemberId: ana}, nil)
	if sent = f.take(s); len(sent) != 2 || !slices.Equal(sent[0].n.Args, []string{"Cy", "Ana", "€5.00"}) {
		t.Errorf("payment with symbol sent %+v", sent)
	}
	c.must(200, "PATCH", base, GroupUpdate{Symbol: ptr("NT$")}, nil)
	c.must(201, "POST", base+"/payments", PaymentInput{Amount: "5", FromMemberId: cy, ToMemberId: ana}, nil)
	if sent = f.take(s); len(sent) != 2 || sent[0].n.Args[2] != "NT$5.00" {
		t.Errorf("payment with symbol sent %+v", sent)
	}
	c.must(200, "PATCH", base, GroupUpdate{Symbol: ptr("TWD")}, nil)
	c.must(201, "POST", base+"/payments", PaymentInput{Amount: "5", FromMemberId: cy, ToMemberId: ana}, nil)
	if sent = f.take(s); len(sent) != 2 || sent[0].n.Args[2] != "TWD 5.00" {
		t.Errorf("payment with letter symbol sent %+v", sent)
	}
	c.must(200, "PATCH", base, GroupUpdate{Symbol: ptr("")}, nil)

	// Without knowing who did it, everyone involved hears.
	c.member = ""
	c.must(204, "DELETE", base+"/expenses/"+e.Id, nil, nil)
	sent = f.take(s)
	if len(sent) != 1 || sent[0].phone != "ana-phone" || sent[0].n.Key != "push_expense_deleted_anon" ||
		!slices.Equal(sent[0].n.Args, []string{"Pizza", "10.00 EUR"}) {
		t.Errorf("delete sent %+v", sent)
	}
	// Deleting it again changes nothing, so says nothing.
	c.must(204, "DELETE", base+"/expenses/"+e.Id, nil, nil)
	c.must(204, "DELETE", "/push/devices/"+deviceID("ana-phone"), nil, nil)
	c.must(200, "POST", base+"/expenses/"+e.Id+"/restore", nil, nil)
	pizza.Version = ptr(4)
	c.must(200, "PUT", base+"/expenses/"+e.Id, pizza, nil)
	if sent := f.take(s); len(sent) != 0 {
		t.Errorf("sent after removal %+v", sent)
	}
}

// A subscription that turns out gone after the phone replaced it takes
// only itself away, not the phone's new one.
func TestPushGoneAfterNewSubscription(t *testing.T) {
	c, f, s := pushClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	subscribe(c, "ben-phone", follow(g.Token, ben))

	sending, release := make(chan struct{}), make(chan struct{})
	f.before = func(phone string) error {
		if phone != "ben-phone" {
			return nil
		}
		close(sending)
		<-release
		return push.ErrGone
	}
	c.member = ana
	c.must(201, "POST", "/g/"+g.Token+"/expenses", ExpenseInput{
		Title:       "Pizza",
		Amount:      "10",
		OccurredAt:  mustTime(t, "2026-10-01T19:00:00Z"),
		Payers:      []PayerInput{{MemberId: ana, Amount: "10"}},
		SplitMethod: "equal",
		Splits:      []Share{{MemberId: ana}, {MemberId: ben}},
	}, nil)
	<-sending
	in := follow(g.Token, ben)
	in.Endpoint, in.P256dh, in.Auth = "https://push.example.com/up/ben-phone-2", phoneKey(), "MDEyMzQ1Njc4OWFiY2RlZg"
	c.must(204, "PUT", "/push/devices/"+deviceID("ben-phone"), in, nil)
	close(release)
	f.take(s)

	var endpoint string
	err := s.db.QueryRow(context.Background(), `select endpoint from push_devices where token = $1`, deviceID("ben-phone")).Scan(&endpoint)
	if err != nil || endpoint != in.Endpoint {
		t.Fatalf("endpoint %q, %v", endpoint, err)
	}
}

// A phone whose push service hangs holds back no other phone's message.
func TestPushStuckPhone(t *testing.T) {
	c, f, s := pushClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben", "Cy")
	ana, ben, cy := g.Members[0].Id, g.Members[1].Id, g.Members[2].Id
	subscribe(c, "ben-phone", follow(g.Token, ben))
	subscribe(c, "cy-phone", follow(g.Token, cy))

	release, cyGot := make(chan struct{}), make(chan struct{})
	f.before = func(phone string) error {
		if phone == "ben-phone" {
			<-release
		} else {
			close(cyGot)
		}
		return nil
	}
	defer f.take(s)
	defer close(release)
	c.member = ana
	c.must(201, "POST", "/g/"+g.Token+"/expenses", ExpenseInput{
		Title:       "Pizza",
		Amount:      "30",
		OccurredAt:  mustTime(t, "2026-10-01T19:00:00Z"),
		Payers:      []PayerInput{{MemberId: ana, Amount: "30"}},
		SplitMethod: "equal",
		Splits:      []Share{{MemberId: ana}, {MemberId: ben}, {MemberId: cy}},
	}, nil)
	select {
	case <-cyGot:
	case <-time.After(10 * time.Second):
		t.Fatal("cy-phone waited on ben-phone")
	}
}

// Long names are cut short so every message fits in one push.
func TestPushClipsText(t *testing.T) {
	c, f, s := pushClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben")
	subscribe(c, "ben-phone", follow(g.Token, g.Members[1].Id))
	long := strings.Repeat("\u9999\u8549", 100) // multi-byte, so clipping counts characters
	c.member = g.Members[0].Id
	c.must(201, "POST", "/g/"+g.Token+"/expenses", ExpenseInput{
		Title:       long,
		Amount:      "10",
		OccurredAt:  mustTime(t, "2026-10-01T19:00:00Z"),
		Payers:      []PayerInput{{MemberId: g.Members[0].Id, Amount: "10"}},
		SplitMethod: "equal",
		Splits:      []Share{{MemberId: g.Members[1].Id}},
	}, nil)
	sent := f.take(s)
	if len(sent) != 1 {
		t.Fatalf("sent %+v", sent)
	}
	if title := sent[0].n.Args[1]; utf8.RuneCountInString(title) != maxPushText || !strings.HasSuffix(title, "…") {
		t.Errorf("title %q", title)
	}
	if len(sent[0].Payload) > push.MaxPayload {
		t.Errorf("payload %d bytes", len(sent[0].Payload))
	}
}

func TestPushRegistration(t *testing.T) {
	c, _, s := pushClient(t, map[string]string{})
	g := createGroup(c, "Ana")
	good := follow(g.Token, g.Members[0].Id)
	good.Endpoint, good.P256dh, good.Auth = "https://push.example.com/up/a", phoneKey(), "MDEyMzQ1Njc4OWFiY2RlZg"
	for name, c2 := range map[string]struct {
		device string
		edit   func(*PushDeviceInput)
		code   string
	}{
		"short id":    {"abc", func(*PushDeviceInput) {}, "invalid_device"},
		"long id":     {strings.Repeat("a", maxDeviceID+1), func(*PushDeviceInput) {}, "invalid_device"},
		"odd id":      {"phone.0123456789abcdef", func(*PushDeviceInput) {}, "invalid_device"},
		"http":        {deviceID("p"), func(in *PushDeviceInput) { in.Endpoint = "http://push.example.com/up/a" }, "invalid_subscription"},
		"private":     {deviceID("p"), func(in *PushDeviceInput) { in.Endpoint = "https://10.0.0.1/up/a" }, "invalid_subscription"},
		"bad key":     {deviceID("p"), func(in *PushDeviceInput) { in.P256dh = "AAAA" }, "invalid_subscription"},
		"bad auth":    {deviceID("p"), func(in *PushDeviceInput) { in.Auth = "" }, "invalid_subscription"},
		"no endpoint": {deviceID("p"), func(in *PushDeviceInput) { in.Endpoint = "" }, "invalid_subscription"},
	} {
		in := good
		c2.edit(&in)
		if code := c.errorCode(400, "PUT", "/push/devices/"+c2.device, in); code != c2.code {
			t.Errorf("%s: %q", name, code)
		}
	}

	// The same subscription under a new ID replaces the old one.
	c.must(204, "PUT", "/push/devices/"+deviceID("old"), good, nil)
	c.must(204, "PUT", "/push/devices/"+deviceID("new"), good, nil)
	var ids []string
	rows, err := s.db.Query(context.Background(), `select token from push_devices`)
	if err == nil {
		ids, err = pgx.CollectRows(rows, pgx.RowTo[string])
	}
	if err != nil || !slices.Equal(ids, []string{deviceID("new")}) {
		t.Errorf("devices %v %v", ids, err)
	}

	// Private endpoints are fine when the server allows them.
	c, _, _ = pushClient(t, map[string]string{"BALNANA_PUSH_PRIVATE_ENDPOINTS": "true"})
	good.Endpoint = "http://192.168.1.2:8080/up/a"
	c.must(204, "PUT", "/push/devices/"+deviceID("lan"), good, nil)
}

// The server makes its VAPID key once and keeps it; every server sharing
// the database uses the same one.
func TestStartPush(t *testing.T) {
	pool := testDB(t)
	cfg := baseConfig(t, map[string]string{"BALNANA_PUBLIC_URL": "https://split.example.com"})
	a := NewServer(cfg, pool, slog.New(slog.DiscardHandler), "test")
	b := NewServer(cfg, pool, slog.New(slog.DiscardHandler), "test")
	if err := a.StartPush(context.Background()); err != nil {
		t.Fatal(err)
	}
	if err := b.StartPush(context.Background()); err != nil {
		t.Fatal(err)
	}
	if a.vapid == "" || a.vapid != b.vapid {
		t.Fatalf("keys %q %q", a.vapid, b.vapid)
	}
	if a.pushSubject() != "https://split.example.com" {
		t.Errorf("subject %q", a.pushSubject())
	}
	c := &client{t: t, h: NewHandler(a, http.NotFoundHandler())}
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if !info.Push || info.VapidPublicKey == nil || *info.VapidPublicKey != a.vapid {
		t.Errorf("push %v, key %v", info.Push, info.VapidPublicKey)
	}
}

func TestPushOff(t *testing.T) {
	c := newClient(t)
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if info.Push || info.VapidPublicKey != nil {
		t.Errorf("push %v, key %v", info.Push, info.VapidPublicKey)
	}
	g := createGroup(c, "Ana")
	if code := c.errorCode(404, "PUT", "/push/devices/"+deviceID("phone"), follow(g.Token, g.Members[0].Id)); code != "push_off" {
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
	subscribe(ana, "ana-phone", follow(g.Token, g.Members[0].Id))
	stranger := ana.another()
	subscribe(stranger, "stranger-phone", follow(g.Token, g.Members[0].Id))

	pay := func() {
		ben.must(201, "POST", "/g/"+g.Token+"/payments", PaymentInput{Amount: "5", FromMemberId: g.Members[1].Id, ToMemberId: g.Members[0].Id}, nil)
	}
	pay()
	if sent := f.take(s); len(sent) != 1 || sent[0].phone != "ana-phone" {
		t.Fatalf("sent %+v", sent)
	}

	// A new link changes nothing for accounts.
	var reset Group
	ana.must(200, "POST", "/g/"+g.Token+"/reset-link", nil, &reset)
	g.Token = reset.Token
	pay()
	if sent := f.take(s); len(sent) != 1 || sent[0].phone != "ana-phone" || sent[0].n.Group != reset.Token {
		t.Fatalf("sent after reset %+v", sent)
	}

	// Signing out ends it.
	ana.must(204, "POST", "/auth/logout", nil, nil)
	pay()
	if sent := f.take(s); len(sent) != 0 {
		t.Errorf("sent after sign-out %+v", sent)
	}
}

// Resetting the link cuts off phones that only had the old one, even one
// whose registration overlapped the reset; accounts keep hearing.
func TestPushLinkReset(t *testing.T) {
	c, f, s := pushClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	subscribe(c, "old-phone", follow(g.Token, ben))
	var reset Group
	c.must(200, "POST", "/g/"+g.Token+"/reset-link", nil, &reset)
	c.errorCode(404, "GET", "/g/"+g.Token, nil)

	// A registration that read the old link before the reset but wrote after.
	_, err := s.db.Exec(context.Background(), `
		with d as (
			insert into push_devices (token, endpoint, p256dh, auth)
			values ('late-phone-0123456789', 'https://push.example.com/up/late-phone', $4, 'MDEyMzQ1Njc4OWFiY2RlZg')
			returning token)
		insert into push_follows (device, group_id, member_id, link_token)
		select d.token, g.id, $2, $3 from d, groups g where g.token = $1`, reset.Token, ben, g.Token, phoneKey())
	if err != nil {
		t.Fatal(err)
	}
	subscribe(c, "new-phone", follow(reset.Token, ben))

	c.member = ana
	c.must(201, "POST", "/g/"+reset.Token+"/payments", PaymentInput{Amount: "5", FromMemberId: ana, ToMemberId: ben}, nil)
	sent := f.take(s)
	if len(sent) != 1 || sent[0].phone != "new-phone" {
		t.Fatalf("sent %+v", sent)
	}
	var left int
	if err := s.db.QueryRow(context.Background(), `select count(*) from push_follows where device = $1`, deviceID("old-phone")).Scan(&left); err != nil || left != 0 {
		t.Errorf("old follow kept: %d %v", left, err)
	}
}

// A device token lets whoever has it change what the phone hears, so no log
// line may hold one, whether the request works or not.
func TestPushLogsHideDevices(t *testing.T) {
	var logs bytes.Buffer
	log := slog.New(slog.NewTextHandler(&logs, &slog.HandlerOptions{Level: slog.LevelDebug}))
	s := NewServer(baseConfig(t, map[string]string{}), testDB(t), log, "test")
	s.push = &fakePush{gone: map[string]bool{}}
	h := NewHandler(s, http.NotFoundHandler())
	const device = "private-device-token"
	for _, body := range []string{"{not json", `{"groups":[]}`, `{"endpoint":"https://push.example.com/x","groups":[{"token":"x","memberId":"y"}]}`} {
		req := httptest.NewRequest("PUT", "/api/v1/push/devices/"+device, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		h.ServeHTTP(httptest.NewRecorder(), req)
	}
	h.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest("DELETE", "/api/v1/push/devices/"+device, nil))
	if !strings.Contains(logs.String(), "/push/devices/<token>") {
		t.Fatalf("nothing logged: %s", logs.String())
	}
	if strings.Contains(logs.String(), device) {
		t.Fatalf("device token in logs: %s", logs.String())
	}
}
