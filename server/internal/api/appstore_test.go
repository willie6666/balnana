package api

import (
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/base64"
	"encoding/json"
	"math/big"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/go-jose/go-jose/v4"
)

const appStoreTestBundle = "com.balnana.test"

// fakeApple signs App Store data as Apple does: a leaf and an intermediate
// with Apple's markings under a root of its own, sent along in x5c.
type fakeApple struct {
	t     *testing.T
	roots *x509.CertPool
	key   *ecdsa.PrivateKey
	x5c   []string
}

func newFakeApple(t *testing.T, mark bool) *fakeApple {
	t.Helper()
	newKey := func() *ecdsa.PrivateKey {
		k, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
		if err != nil {
			t.Fatal(err)
		}
		return k
	}
	serial := int64(0)
	issue := func(tmpl *x509.Certificate, parent *x509.Certificate, key, parentKey *ecdsa.PrivateKey) *x509.Certificate {
		serial++
		tmpl.SerialNumber = big.NewInt(serial)
		tmpl.NotBefore = time.Now().Add(-time.Hour)
		tmpl.NotAfter = time.Now().Add(time.Hour)
		if parent == nil {
			parent = tmpl
		}
		der, err := x509.CreateCertificate(rand.Reader, tmpl, parent, &key.PublicKey, parentKey)
		if err != nil {
			t.Fatal(err)
		}
		c, err := x509.ParseCertificate(der)
		if err != nil {
			t.Fatal(err)
		}
		return c
	}
	ext := func(id []int) []pkix.Extension {
		if !mark {
			return nil
		}
		return []pkix.Extension{{Id: id, Value: []byte{5, 0}}}
	}
	rootKey, midKey, leafKey := newKey(), newKey(), newKey()
	root := issue(&x509.Certificate{Subject: pkix.Name{CommonName: "Test Root"}, IsCA: true, BasicConstraintsValid: true,
		KeyUsage: x509.KeyUsageCertSign}, nil, rootKey, rootKey)
	mid := issue(&x509.Certificate{Subject: pkix.Name{CommonName: "Test WWDR"}, IsCA: true, BasicConstraintsValid: true,
		KeyUsage: x509.KeyUsageCertSign, ExtraExtensions: ext(oidAppleWWDRIntermediate)}, root, midKey, rootKey)
	leaf := issue(&x509.Certificate{Subject: pkix.Name{CommonName: "Test App Store"}, KeyUsage: x509.KeyUsageDigitalSignature,
		ExtraExtensions: ext(oidAppStoreReceiptSigner)}, mid, leafKey, midKey)
	roots := x509.NewCertPool()
	roots.AddCert(root)
	var x5c []string
	for _, c := range []*x509.Certificate{leaf, mid, root} {
		x5c = append(x5c, base64.StdEncoding.EncodeToString(c.Raw))
	}
	return &fakeApple{t: t, roots: roots, key: leafKey, x5c: x5c}
}

func (f *fakeApple) sign(payload map[string]any) string {
	f.t.Helper()
	if _, set := payload["signedDate"]; !set {
		payload["signedDate"] = time.Now().UnixMilli()
	}
	opts := (&jose.SignerOptions{}).WithHeader("x5c", f.x5c)
	signer, err := jose.NewSigner(jose.SigningKey{Algorithm: jose.ES256, Key: f.key}, opts)
	if err != nil {
		f.t.Fatal(err)
	}
	data, _ := json.Marshal(payload)
	jws, err := signer.Sign(data)
	if err != nil {
		f.t.Fatal(err)
	}
	out, err := jws.CompactSerialize()
	if err != nil {
		f.t.Fatal(err)
	}
	return out
}

func (f *fakeApple) client(sandbox bool) *appStoreClient {
	return &appStoreClient{bundleID: appStoreTestBundle, sandbox: sandbox, roots: f.roots}
}

// transaction is a month of a subscription as StoreKit hands it over. Fields
// overrule the defaults.
func (f *fakeApple) transaction(id, original, product, account string, fields map[string]any) string {
	now := time.Now()
	t := map[string]any{
		"transactionId": id, "originalTransactionId": original, "bundleId": appStoreTestBundle,
		"productId": product, "type": "Auto-Renewable Subscription", "environment": "Production",
		"purchaseDate": now.UnixMilli(), "expiresDate": now.Add(30 * 24 * time.Hour).UnixMilli(),
		"price": 4990, "currency": "USD",
	}
	if account != "" {
		t["appAccountToken"] = account
	}
	for k, v := range fields {
		t[k] = v
	}
	return f.sign(t)
}

func TestAppStoreVerify(t *testing.T) {
	f := newFakeApple(t, true)
	a := f.client(false)
	if tr, err := a.transaction(f.transaction("1", "1", "plus_monthly", "", nil)); err != nil || tr.ProductID != "plus_monthly" {
		t.Fatalf("good transaction: %+v, %v", tr, err)
	}
	bad := map[string]string{
		"another app": f.transaction("1", "1", "p", "", map[string]any{"bundleId": "com.other"}),
		"sandbox":     f.transaction("1", "1", "p", "", map[string]any{"environment": "Sandbox"}),
		"not a sub":   f.transaction("1", "1", "p", "", map[string]any{"type": "Consumable"}),
		"future":      f.transaction("1", "1", "p", "", map[string]any{"signedDate": time.Now().Add(time.Hour).UnixMilli()}),
		"garbage":     "a.b.c",
	}
	// Signed under a root that isn't the one trusted.
	other := newFakeApple(t, true)
	bad["other root"] = other.transaction("1", "1", "p", "", nil)
	// Apple's root alone, without the App Store's markings, is not enough.
	unmarked := newFakeApple(t, false)
	unmarked.roots = f.roots
	bad["unmarked"] = unmarked.transaction("1", "1", "p", "", nil)
	// The payload changed after signing.
	parts := strings.Split(f.transaction("1", "1", "p", "", nil), ".")
	forged, _ := json.Marshal(map[string]any{"transactionId": "2", "signedDate": time.Now().UnixMilli()})
	bad["forged"] = parts[0] + "." + base64.RawURLEncoding.EncodeToString(forged) + "." + parts[2]
	for name, signed := range bad {
		if _, err := a.transaction(signed); err != errAppStorePurchase {
			t.Errorf("%s: %v", name, err)
		}
	}
	if _, err := (&appStoreClient{bundleID: appStoreTestBundle, sandbox: true, roots: f.roots}).
		transaction(f.transaction("1", "1", "p", "", map[string]any{"environment": "Sandbox"})); err != nil {
		t.Errorf("sandbox when taken: %v", err)
	}
	// Apple's own root parses.
	if newAppStoreClient(baseConfig(t, map[string]string{"BALNANA_APPLE_BUNDLE_ID": "com.balnana.app"})) == nil {
		t.Fatal("no client")
	}
}

func TestAppStorePaidUntil(t *testing.T) {
	end := time.Now().Add(time.Hour).Truncate(time.Millisecond)
	tr := appStoreTransaction{ExpiresDate: end.UnixMilli()}
	if got := tr.paidUntil(0); !got.Equal(end) {
		t.Fatalf("active: %v", got)
	}
	if got := tr.paidUntil(end.Add(time.Hour).UnixMilli()); !got.Equal(end.Add(time.Hour)) {
		t.Fatalf("grace: %v", got)
	}
	for _, gone := range []appStoreTransaction{
		{ExpiresDate: end.UnixMilli(), RevocationDate: 1},
		{ExpiresDate: end.UnixMilli(), IsUpgraded: true},
		{},
	} {
		if got := gone.paidUntil(0); !got.IsZero() {
			t.Fatalf("%+v: %v", gone, got)
		}
	}
}

func TestAppStoreAccountTokenIsAUUID(t *testing.T) {
	got := appStoreAccountToken("6f1c2d6e-0000-4000-8000-000000000000")
	if len(got) != 36 || strings.Count(got, "-") != 4 || got != strings.ToLower(got) {
		t.Fatalf("token %q", got)
	}
	if got == appStoreAccountToken("6f1c2d6e-0000-4000-8000-000000000001") {
		t.Fatal("two accounts share a token")
	}
}

// appStoreServer is a charging server selling the plus plan as
// "plus_monthly" in the App Store, signed by an Apple of its own.
func appStoreServer(t *testing.T) (*client, *fakeApple, *Server) {
	t.Helper()
	c, _, s := billingServer(t)
	f := newFakeApple(t, true)
	s.settings.Load().appStore = f.client(false)
	exec(t, s, `insert into plan_products (provider, product, plan_id, days) values ('appstore', 'plus_monthly', 'plus', 30)`)
	return c, f, s
}

func (c *client) reportAppStore(signed string) MyPlan {
	c.t.Helper()
	var p MyPlan
	c.must(200, "POST", "/me/appstore/purchases", AppStorePurchaseRequest{SignedTransaction: signed}, &p)
	return p
}

// appStoreNotify sends a notification as Apple would, and returns the status.
func (c *client) appStoreNotify(f *fakeApple, kind, signedTransaction string) int {
	c.t.Helper()
	payload := f.sign(map[string]any{
		"notificationType": kind, "notificationUUID": "n-" + secretToken(),
		"data": map[string]any{"bundleId": appStoreTestBundle, "environment": "Production",
			"signedTransactionInfo": signedTransaction},
	})
	body, _ := json.Marshal(map[string]string{"signedPayload": payload})
	req := httptest.NewRequest("POST", appStorePath, strings.NewReader(string(body)))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()
	c.h.ServeHTTP(rec, req)
	return rec.Code
}

func TestAppStorePurchase(t *testing.T) {
	c, f, s := appStoreServer(t)
	ana := register(c, "ana@example.test", "Ana")
	token := appStoreAccountToken(ana.Id)
	if p := myPlanOf(c); p.Paid || p.AppStore == nil || p.AppStore.AccountToken != token ||
		len(p.AppStore.Products) != 1 || p.AppStore.Products[0] != "plus_monthly" || len(p.AppStore.Subscribed) != 0 {
		t.Fatalf("before buying: %+v", p.AppStore)
	}
	var stored string
	if err := s.db.QueryRow(context.Background(), `select appstore_account_token::text from users where id = $1`, ana.Id).
		Scan(&stored); err != nil || stored != token {
		t.Fatalf("database token %q, app token %q, %v", stored, token, err)
	}

	first := f.transaction("1000", "1000", "plus_monthly", strings.ToUpper(token), nil)
	p := c.reportAppStore(first)
	if !p.Paid || p.PlanName != "Plus" || p.ExpiresAt == nil || len(p.AppStore.Subscribed) != 1 {
		t.Fatalf("after buying: %+v", p)
	}
	if state, user := paymentState(t, s, "1000"); state != "applied" || user == nil || *user != ana.Id {
		t.Fatalf("payment %s %v", state, user)
	}
	// Telling it again repeats nothing.
	c.reportAppStore(first)
	if code := c.appStoreNotify(f, "SUBSCRIBED", first); code != 200 {
		t.Fatalf("notification %d", code)
	}
	var n int
	if err := s.db.QueryRow(context.Background(), `select count(*) from entitlements where user_id = $1`, ana.Id).Scan(&n); err != nil || n != 1 {
		t.Fatalf("%d entitlements, %v", n, err)
	}

	// A renewal moves the end, and is a payment of its own.
	end := time.Now().Add(60 * 24 * time.Hour).Truncate(time.Millisecond)
	renewal := f.transaction("1001", "1000", "plus_monthly", token, map[string]any{
		"purchaseDate": time.Now().Add(time.Minute).UnixMilli(), "expiresDate": end.UnixMilli(),
	})
	if code := c.appStoreNotify(f, "DID_RENEW", renewal); code != 200 {
		t.Fatalf("renewal %d", code)
	}
	if p := myPlanOf(c); p.ExpiresAt == nil || !p.ExpiresAt.Equal(end) {
		t.Fatalf("after renewing: %+v", p.ExpiresAt)
	}
	// The first month, told of late, doesn't take the renewal back.
	c.reportAppStore(first)
	if p := myPlanOf(c); p.ExpiresAt == nil || !p.ExpiresAt.Equal(end) {
		t.Fatalf("an old transaction moved the end: %+v", p.ExpiresAt)
	}
	// A refund ends it.
	refunded := f.transaction("1001", "1000", "plus_monthly", token, map[string]any{
		"purchaseDate": time.Now().Add(time.Minute).UnixMilli(), "expiresDate": end.UnixMilli(),
		"revocationDate": time.Now().UnixMilli(),
	})
	if code := c.appStoreNotify(f, "REFUND", refunded); code != 200 {
		t.Fatalf("refund %d", code)
	}
	if p := myPlanOf(c); p.Paid || len(p.AppStore.Subscribed) != 0 {
		t.Fatalf("refunded: %+v", p)
	}
	if state, _ := paymentState(t, s, "1001"); state != "refunded" {
		t.Fatalf("refunded payment %s", state)
	}
}

func TestAppStorePurchaseBelongsToItsAccount(t *testing.T) {
	c, f, _ := appStoreServer(t)
	ana := register(c, "ana@example.test", "Ana")
	bob := &client{t: t, h: c.h}
	register(bob, "bob@example.test", "Bob")
	signed := f.transaction("2000", "2000", "plus_monthly", appStoreAccountToken(ana.Id), nil)
	// Bob can't take Ana's purchase, not even before she reports it.
	bob.must(409, "POST", "/me/appstore/purchases", AppStorePurchaseRequest{SignedTransaction: signed}, nil)
	if p := myPlanOf(bob); p.Paid {
		t.Fatal("bob got ana's plan")
	}
	if p := c.reportAppStore(signed); !p.Paid {
		t.Fatal("ana didn't get her plan")
	}
}

func TestAppStoreNotificationAloneGrants(t *testing.T) {
	c, f, _ := appStoreServer(t)
	ana := register(c, "ana@example.test", "Ana")
	// Without the app's word, the account token says whose it is.
	if code := c.appStoreNotify(f, "SUBSCRIBED", f.transaction("3000", "3000", "plus_monthly", appStoreAccountToken(ana.Id), nil)); code != 200 {
		t.Fatalf("notification %d", code)
	}
	if p := myPlanOf(c); !p.Paid {
		t.Fatal("notification didn't grant")
	}
	// Without one, nothing says whose it is: it waits for the app.
	if code := c.appStoreNotify(f, "SUBSCRIBED", f.transaction("3001", "3001", "plus_monthly", "", nil)); code != 200 {
		t.Fatalf("unowned notification %d", code)
	}
}

func TestAppStoreWebhookChecks(t *testing.T) {
	c, f, _ := appStoreServer(t)
	other := newFakeApple(t, true)
	if code := c.appStoreNotify(other, "SUBSCRIBED", f.transaction("4000", "4000", "plus_monthly", "", nil)); code != 403 {
		t.Fatalf("notification signed by someone else: %d", code)
	}
	req := httptest.NewRequest("POST", appStorePath, strings.NewReader("{"))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()
	c.h.ServeHTTP(rec, req)
	if rec.Code != 400 {
		t.Fatalf("bad body: %d", rec.Code)
	}
	// A test notification carries no transaction.
	body, _ := json.Marshal(map[string]string{"signedPayload": f.sign(map[string]any{
		"notificationType": "TEST", "data": map[string]any{"bundleId": appStoreTestBundle},
	})})
	req = httptest.NewRequest("POST", appStorePath, strings.NewReader(string(body)))
	req.Header.Set("Content-Type", "application/json")
	rec = httptest.NewRecorder()
	c.h.ServeHTTP(rec, req)
	if rec.Code != 200 {
		t.Fatalf("test notification: %d", rec.Code)
	}
}

func TestAppStoreOff(t *testing.T) {
	c, _, s := billingServer(t)
	register(c, "ana@example.test", "Ana")
	if s.settings.Load().appStore != nil {
		t.Fatal("app store on without a bundle ID")
	}
	if p := myPlanOf(c); p.AppStore != nil {
		t.Fatalf("offered %+v", p.AppStore)
	}
	c.must(404, "POST", "/me/appstore/purchases", AppStorePurchaseRequest{SignedTransaction: "a.b.c"}, nil)
}
