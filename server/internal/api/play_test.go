package api

import (
	"context"
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"encoding/base64"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/coreos/go-oidc/v3/oidc"
	"github.com/go-jose/go-jose/v4"
	"github.com/go-jose/go-jose/v4/jwt"
)

const (
	playTestPackage = "me.devvillie.test"
	playTestPusher  = "push@balnana.iam.gserviceaccount.com"
)

// fakePlay is Google's side: the purchases it knows, by token, and what it
// was asked to acknowledge.
type fakePlay struct {
	mu       sync.Mutex
	subs     map[string]map[string]any
	acks     []string
	down     bool
	key      *rsa.PrivateKey
	audience string
}

func (f *fakePlay) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.down {
		http.Error(w, "unavailable", http.StatusServiceUnavailable)
		return
	}
	prefix := "/" + playTestPackage + "/purchases/"
	token, ok := strings.CutPrefix(r.URL.EscapedPath(), prefix+"subscriptionsv2/tokens/")
	if ok && r.Method == "GET" {
		sub := f.subs[token]
		if sub == nil {
			http.Error(w, "gone", http.StatusGone)
			return
		}
		writeJSON(w, 200, sub)
		return
	}
	path, ok := strings.CutPrefix(r.URL.EscapedPath(), prefix+"subscriptions/")
	if token, found := strings.CutSuffix(path, ":acknowledge"); ok && found && r.Method == "POST" {
		_, token, _ = strings.Cut(token, "/tokens/")
		f.acks = append(f.acks, token)
		f.subs[token]["acknowledgementState"] = "ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED"
		w.WriteHeader(200)
		return
	}
	http.NotFound(w, r)
}

// buy adds a subscription as Google shows it. Fields overrule an active,
// unacknowledged one for a month.
func (f *fakePlay) buy(token, product, order string, account *string, fields map[string]any) {
	f.mu.Lock()
	defer f.mu.Unlock()
	sub := map[string]any{
		"subscriptionState":    "SUBSCRIPTION_STATE_ACTIVE",
		"acknowledgementState": "ACKNOWLEDGEMENT_STATE_PENDING",
		"lineItems": []map[string]any{{
			"productId": product, "latestSuccessfulOrderId": order,
			"expiryTime": time.Now().Add(30 * 24 * time.Hour).UTC().Format(time.RFC3339),
		}},
	}
	if account != nil {
		sub["externalAccountIdentifiers"] = map[string]any{"obfuscatedExternalAccountId": *account}
	}
	for k, v := range fields {
		sub[k] = v
	}
	f.subs[token] = sub
}

func (f *fakePlay) set(token string, fields map[string]any) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for k, v := range fields {
		f.subs[token][k] = v
	}
}

func (f *fakePlay) acked() []string {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.acks
}

// playServer is a charging server selling the plus plan as "plus_monthly",
// with a Google of its own.
func playServer(t *testing.T) (*client, *fakePlay, *Server) {
	t.Helper()
	c, _, s := billingServer(t)
	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	f := &fakePlay{subs: map[string]map[string]any{}, key: key, audience: "https://balnana.test" + playPath}
	srv := httptest.NewServer(f)
	t.Cleanup(srv.Close)
	s.settings.Load().play = &playClient{
		packageName: playTestPackage,
		http:        srv.Client(),
		base:        srv.URL + "/",
		pushAccount: playTestPusher,
		push: oidc.NewVerifier(googleIssuer, &oidc.StaticKeySet{PublicKeys: []crypto.PublicKey{key.Public()}},
			&oidc.Config{ClientID: f.audience}),
	}
	exec(t, s, `insert into plan_products (provider, product, plan_id, days) values ('play', 'plus_monthly', 'plus', 30)`)
	return c, f, s
}

func (f *fakePlay) sign(t *testing.T, key *rsa.PrivateKey, audience, email string) string {
	t.Helper()
	signer, err := jose.NewSigner(jose.SigningKey{Algorithm: jose.RS256, Key: key}, (&jose.SignerOptions{}).WithType("JWT"))
	if err != nil {
		t.Fatal(err)
	}
	token, err := jwt.Signed(signer).Claims(map[string]any{
		"iss": googleIssuer, "aud": audience, "email": email, "email_verified": true,
		"exp": time.Now().Add(time.Hour).Unix(), "iat": time.Now().Unix(),
	}).Serialize()
	if err != nil {
		t.Fatal(err)
	}
	return token
}

// push delivers a notification as Pub/Sub would, signed with token.
func (c *client) push(token string, notification map[string]any) int {
	c.t.Helper()
	data, err := json.Marshal(notification)
	if err != nil {
		c.t.Fatal(err)
	}
	body, _ := json.Marshal(map[string]any{
		"message":      map[string]any{"data": base64.StdEncoding.EncodeToString(data), "messageId": "1"},
		"subscription": "projects/x/subscriptions/y",
	})
	req := httptest.NewRequest("POST", playPath, strings.NewReader(string(body)))
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	rec := httptest.NewRecorder()
	c.h.ServeHTTP(rec, req)
	return rec.Code
}

// notify tells the server something happened to the subscription.
func (c *client) notify(f *fakePlay, token string, want int) {
	c.t.Helper()
	got := c.push(f.sign(c.t, f.key, f.audience, playTestPusher), map[string]any{
		"packageName":              playTestPackage,
		"subscriptionNotification": map[string]any{"notificationType": 2, "purchaseToken": token},
	})
	if got != want {
		c.t.Fatalf("notification: status %d, want %d", got, want)
	}
}

func (c *client) reportPlay(token string) MyPlan {
	c.t.Helper()
	var p MyPlan
	c.must(200, "POST", "/me/play/purchases", PlayPurchaseRequest{PurchaseToken: token}, &p)
	return p
}

func TestPlayPurchase(t *testing.T) {
	c, f, s := playServer(t)
	ana := register(c, "ana@example.test", "Ana")
	if p := myPlanOf(c); p.Paid || p.Play == nil || len(p.Play.Subscribed) != 0 || p.Play.Products[0] != "plus_monthly" ||
		p.Play.AccountId != playAccountID(ana.Id) || p.Play.PackageName != playTestPackage {
		t.Fatalf("before buying: %+v", p)
	}
	f.buy("token-1", "plus_monthly", "GPA.1", &[]string{playAccountID(ana.Id)}[0], nil)
	p := c.reportPlay("token-1")
	if !p.Paid || p.PlanName != "Plus" || p.ExpiresAt == nil || p.Play.Subscribed[0] != "plus_monthly" {
		t.Fatalf("after buying: %+v", p)
	}
	if got := f.acked(); len(got) != 1 || got[0] != "token-1" {
		t.Fatalf("acknowledged %v", got)
	}
	if state, user := paymentState(t, s, "GPA.1"); state != "applied" || user == nil || *user != ana.Id {
		t.Fatalf("payment %s %v", state, user)
	}

	// Telling it again repeats nothing.
	c.reportPlay("token-1")
	c.notify(f, "token-1", 200)
	if got := f.acked(); len(got) != 1 {
		t.Fatalf("acknowledged %v", got)
	}
	var n int
	if err := s.db.QueryRow(context.Background(), `select count(*) from entitlements where user_id = $1`, ana.Id).Scan(&n); err != nil || n != 1 {
		t.Fatalf("%d entitlements, %v", n, err)
	}

	// A renewal moves the end, and is a payment of its own.
	end := time.Now().Add(60 * 24 * time.Hour).UTC().Truncate(time.Second)
	f.set("token-1", map[string]any{"lineItems": []map[string]any{{
		"productId": "plus_monthly", "latestSuccessfulOrderId": "GPA.1..0", "expiryTime": end.Format(time.RFC3339),
	}}})
	c.notify(f, "token-1", 200)
	if p := myPlanOf(c); p.ExpiresAt == nil || !p.ExpiresAt.Equal(end) {
		t.Fatalf("after renewing: %+v", p)
	}
	if state, _ := paymentState(t, s, "GPA.1..0"); state != "applied" {
		t.Fatalf("renewal %s", state)
	}

	// Cancelled, it runs to the end of what was paid for.
	f.set("token-1", map[string]any{"subscriptionState": "SUBSCRIPTION_STATE_CANCELED"})
	c.notify(f, "token-1", 200)
	if p := myPlanOf(c); !p.Paid {
		t.Fatal("cancelled ended it early")
	}
	// Revoked or on hold, it doesn't, and recovering brings it back.
	f.set("token-1", map[string]any{"subscriptionState": "SUBSCRIPTION_STATE_ON_HOLD"})
	c.notify(f, "token-1", 200)
	if p := myPlanOf(c); p.Paid || len(p.Play.Subscribed) != 0 {
		t.Fatalf("on hold: %+v", p)
	}
	f.set("token-1", map[string]any{"subscriptionState": "SUBSCRIPTION_STATE_ACTIVE"})
	c.notify(f, "token-1", 200)
	if p := myPlanOf(c); !p.Paid {
		t.Fatal("recovering didn't bring it back")
	}
	f.set("token-1", map[string]any{"subscriptionState": "SUBSCRIPTION_STATE_EXPIRED"})
	c.notify(f, "token-1", 200)
	if p := myPlanOf(c); p.Paid {
		t.Fatal("expired kept it")
	}
}

func TestPlayPurchaseBelongsToItsAccount(t *testing.T) {
	c, f, s := playServer(t)
	ana := register(c, "ana@example.test", "Ana")
	bob := &client{t: t, h: c.h}
	register(bob, "bob@example.test", "Bob")

	f.buy("anas", "plus_monthly", "GPA.1", &[]string{playAccountID(ana.Id)}[0], nil)
	if got := bob.errorCode(409, "POST", "/me/play/purchases", PlayPurchaseRequest{PurchaseToken: "anas"}); got != "play_other_account" {
		t.Fatalf("code %q", got)
	}
	if p := myPlanOf(bob); p.Paid {
		t.Fatal("Bob got Ana's purchase")
	}
	if len(f.acked()) != 0 {
		t.Fatal("acknowledged for the wrong account")
	}

	// From the store, with nothing to say whose it is, the token is the proof,
	// and only once.
	f.buy("store", "plus_monthly", "GPA.2", nil, nil)
	if p := bob.reportPlay("store"); !p.Paid {
		t.Fatal("reporter didn't get it")
	}
	if got := c.errorCode(409, "POST", "/me/play/purchases", PlayPurchaseRequest{PurchaseToken: "store"}); got != "play_other_account" {
		t.Fatalf("code %q", got)
	}

	if got := c.errorCode(400, "POST", "/me/play/purchases", PlayPurchaseRequest{PurchaseToken: "nobody-knows"}); got != "invalid_purchase" {
		t.Fatalf("code %q", got)
	}
	f.down = true
	if got := c.errorCode(503, "POST", "/me/play/purchases", PlayPurchaseRequest{PurchaseToken: "anas"}); got != "play_unavailable" {
		t.Fatalf("code %q", got)
	}
	f.down = false

	// A subscription someone came back to from the store is theirs again.
	f.buy("back", "plus_monthly", "GPA.3", nil, map[string]any{"outOfAppPurchaseContext": map[string]any{"expiredPurchaseToken": "store"}})
	c.notify(f, "back", 200)
	if state, user := paymentState(t, s, "GPA.3"); state != "applied" || user == nil || *user == ana.Id {
		t.Fatalf("payment %s %v", state, user)
	}
}

func TestPlayNotificationAloneGrants(t *testing.T) {
	c, f, s := playServer(t)
	ana := register(c, "ana@example.test", "Ana")
	// The app died before reporting it.
	f.buy("token-1", "plus_monthly", "GPA.1", &[]string{playAccountID(ana.Id)}[0], nil)
	c.notify(f, "token-1", 200)
	if p := myPlanOf(c); !p.Paid {
		t.Fatal("not granted")
	}
	if len(f.acked()) != 1 {
		t.Fatal("not acknowledged")
	}

	// Nobody to give it to yet: it waits for the app, unacknowledged.
	f.buy("token-2", "plus_monthly", "GPA.2", nil, nil)
	c.notify(f, "token-2", 200)
	if len(f.acked()) != 1 {
		t.Fatal("acknowledged with no owner")
	}
	// Google forgot it, or was never told: nothing to retry.
	c.notify(f, "unknown", 200)

	// A plan change follows its account, and the old purchase ends.
	f.buy("token-3", "plus_monthly", "GPA.3", nil, map[string]any{"linkedPurchaseToken": "token-1"})
	c.notify(f, "token-3", 200)
	var active int
	if err := s.db.QueryRow(context.Background(), `select count(*) from entitlements e where e.user_id = $1 and `+entitlementActive,
		ana.Id).Scan(&active); err != nil || active != 1 {
		t.Fatalf("%d active, %v", active, err)
	}
	if p := myPlanOf(c); !p.Paid {
		t.Fatal("the change lost the plan")
	}

	// A refund arrives as its own kind of notification.
	f.set("token-3", map[string]any{"subscriptionState": "SUBSCRIPTION_STATE_EXPIRED"})
	code := c.push(f.sign(t, f.key, f.audience, playTestPusher), map[string]any{
		"packageName":                playTestPackage,
		"voidedPurchaseNotification": map[string]any{"purchaseToken": "token-3", "productType": 1},
	})
	if p := myPlanOf(c); code != 200 || p.Paid {
		t.Fatalf("refund: status %d, %+v", code, p)
	}
}

func TestPlayProductNotOnSale(t *testing.T) {
	c, f, s := playServer(t)
	ana := register(c, "ana@example.test", "Ana")
	f.buy("token-1", "other", "GPA.1", &[]string{playAccountID(ana.Id)}[0], nil)
	if p := c.reportPlay("token-1"); p.Paid {
		t.Fatal("granted")
	}
	// Left unacknowledged, Google refunds it.
	if len(f.acked()) != 0 {
		t.Fatal("acknowledged")
	}
	if state, _ := paymentState(t, s, "GPA.1"); state != "unmatched" {
		t.Fatalf("payment %s", state)
	}
	// Put on sale in time, it counts after all.
	exec(t, s, `insert into plan_products (provider, product, plan_id, days) values ('play', 'other', 'plus', 30)`)
	if p := c.reportPlay("token-1"); !p.Paid {
		t.Fatal("not granted")
	}
	if state, _ := paymentState(t, s, "GPA.1"); state != "applied" {
		t.Fatalf("payment %s", state)
	}
}

func TestPlayAdminRevokeStands(t *testing.T) {
	c, f, s := playServer(t)
	ana := register(c, "ana@example.test", "Ana")
	f.buy("token-1", "plus_monthly", "GPA.1", &[]string{playAccountID(ana.Id)}[0], nil)
	c.reportPlay("token-1")
	exec(t, s, `update entitlements set revoked_at = now() where user_id = $1`, ana.Id)
	c.notify(f, "token-1", 200)
	if p := myPlanOf(c); p.Paid {
		t.Fatal("a notification undid the revocation")
	}
}

func TestPlayWebhookChecks(t *testing.T) {
	c, f, _ := playServer(t)
	ana := register(c, "ana@example.test", "Ana")
	f.buy("token-1", "plus_monthly", "GPA.1", &[]string{playAccountID(ana.Id)}[0], nil)
	note := map[string]any{"packageName": playTestPackage, "subscriptionNotification": map[string]any{"purchaseToken": "token-1"}}

	other, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	for name, token := range map[string]string{
		"nothing":       "",
		"not a token":   "garbage",
		"wrong key":     f.sign(t, other, f.audience, playTestPusher),
		"wrong address": f.sign(t, f.key, "https://elsewhere.test"+playPath, playTestPusher),
		"wrong account": f.sign(t, f.key, f.audience, "attacker@evil.iam.gserviceaccount.com"),
	} {
		if got := c.push(token, note); got != 403 {
			t.Errorf("%s: status %d", name, got)
		}
	}
	good := f.sign(t, f.key, f.audience, playTestPusher)
	// Someone else's app, and Play Console's test: fine, and nothing to do.
	c.push(good, map[string]any{"packageName": "other.app", "subscriptionNotification": map[string]any{"purchaseToken": "token-1"}})
	if got := c.push(good, map[string]any{"packageName": playTestPackage, "testNotification": map[string]any{"version": "1.0"}}); got != 200 {
		t.Fatalf("test notification: status %d", got)
	}
	if p := myPlanOf(c); p.Paid {
		t.Fatal("granted without a good notification")
	}
	if got := c.push(good, note); got != 200 {
		t.Fatalf("status %d", got)
	}
	if p := myPlanOf(c); !p.Paid {
		t.Fatal("not granted")
	}
}

func TestPlayOff(t *testing.T) {
	c, _, _ := billingServer(t)
	register(c, "ana@example.test", "Ana")
	if p := myPlanOf(c); p.Play != nil {
		t.Fatalf("play %+v", p.Play)
	}
	if got := c.push("anything", map[string]any{}); got != 404 {
		t.Fatalf("status %d", got)
	}
	c.must(404, "POST", "/me/play/purchases", PlayPurchaseRequest{PurchaseToken: "x"}, nil)
}
