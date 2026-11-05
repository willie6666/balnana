package api

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"slices"
	"strings"
	"sync"
	"testing"
	"time"
)

// fakePayPal answers as PayPal's REST API does, for the calls the server
// makes. Tests change its orders and subscriptions as a payer or PayPal would.
type fakePayPal struct {
	mu     sync.Mutex
	orders map[string]*fakeOrder
	subs   map[string]*paypalSubscription
	plans  []string       // the subscription plans PayPal has
	asked  map[string]any // the last order or subscription asked for
	n      int
}

type fakeOrder struct {
	status   string
	customID string
	amount   paypalMoney
	capture  string // the capture's status, once there is one
	paid     *paypalMoney
}

func (o *fakeOrder) json(id string) map[string]any {
	unit := map[string]any{"custom_id": o.customID}
	if o.capture != "" {
		paid := o.amount
		if o.paid != nil {
			paid = *o.paid
		}
		unit["payments"] = map[string]any{"captures": []map[string]any{{
			"id": "CAP-" + id, "status": o.capture, "amount": paid, "create_time": time.Now().UTC().Format(time.RFC3339),
		}}}
	}
	return map[string]any{
		"id": id, "status": o.status, "payer": map[string]any{"name": map[string]any{"given_name": "Ana", "surname": "Payer"}},
		"purchase_units": []any{unit},
		"links":          []paypalLink{{Rel: "payer-action", Href: "https://paypal.test/pay?token=" + id}},
	}
}

// paypalServer is billingServer that takes payments through a fake PayPal.
func paypalServer(t *testing.T) (*client, *Server, *fakePayPal) {
	t.Helper()
	c, _, s := billingServer(t)
	f := &fakePayPal{orders: map[string]*fakeOrder{}, subs: map[string]*paypalSubscription{}, plans: []string{"P-PLUS"}}
	mux := http.NewServeMux()
	reply := func(w http.ResponseWriter, status int, v any) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(status)
		_ = json.NewEncoder(w).Encode(v)
	}
	refuse := func(w http.ResponseWriter, status int, issue string) {
		reply(w, status, map[string]any{"name": "REFUSED", "details": []map[string]string{{"issue": issue}}})
	}
	mux.HandleFunc("POST /v2/checkout/orders", func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()
		var body struct {
			PurchaseUnits []struct {
				CustomID string      `json:"custom_id"`
				Amount   paypalMoney `json:"amount"`
			} `json:"purchase_units"`
		}
		raw, _ := io.ReadAll(r.Body)
		_ = json.Unmarshal(raw, &body)
		_ = json.Unmarshal(raw, &f.asked)
		f.n++
		id := fmt.Sprintf("ORDER%d", f.n)
		f.orders[id] = &fakeOrder{status: "PAYER_ACTION_REQUIRED", customID: body.PurchaseUnits[0].CustomID, amount: body.PurchaseUnits[0].Amount}
		reply(w, 200, f.orders[id].json(id))
	})
	mux.HandleFunc("GET /v2/checkout/orders/{id}", func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()
		o := f.orders[r.PathValue("id")]
		if o == nil {
			refuse(w, 404, "INVALID_RESOURCE_ID")
			return
		}
		reply(w, 200, o.json(r.PathValue("id")))
	})
	mux.HandleFunc("POST /v2/checkout/orders/{id}/capture", func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()
		o := f.orders[r.PathValue("id")]
		switch {
		case o == nil:
			refuse(w, 404, "INVALID_RESOURCE_ID")
		case o.status != "APPROVED":
			refuse(w, 422, "ORDER_ALREADY_CAPTURED")
		default:
			o.status, o.capture = "COMPLETED", "COMPLETED"
			reply(w, 201, o.json(r.PathValue("id")))
		}
	})
	mux.HandleFunc("GET /v2/payments/captures/{id}", func(w http.ResponseWriter, r *http.Request) {
		id, _ := strings.CutPrefix(r.PathValue("id"), "CAP-")
		reply(w, 200, map[string]any{"id": r.PathValue("id"),
			"supplementary_data": map[string]any{"related_ids": map[string]any{"order_id": id}}})
	})
	mux.HandleFunc("POST /v1/billing/subscriptions", func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()
		var body paypalSubscription
		_ = json.NewDecoder(r.Body).Decode(&body)
		if !slices.Contains(f.plans, body.PlanID) {
			refuse(w, 422, "RESOURCE_NOT_FOUND")
			return
		}
		f.n++
		body.ID, body.Status = fmt.Sprintf("I-SUB%d", f.n), "APPROVAL_PENDING"
		body.Links = []paypalLink{{Rel: "approve", Href: "https://paypal.test/subscribe?ba_token=" + body.ID}}
		f.subs[body.ID] = &body
		reply(w, 201, body)
	})
	mux.HandleFunc("GET /v1/billing/subscriptions/{id}", func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()
		sub := f.subs[r.PathValue("id")]
		if sub == nil {
			refuse(w, 404, "RESOURCE_NOT_FOUND")
			return
		}
		reply(w, 200, sub)
	})
	mux.HandleFunc("POST /v1/notifications/verify-webhook-signature", func(w http.ResponseWriter, r *http.Request) {
		var body struct {
			Sig       string          `json:"transmission_sig"`
			WebhookID string          `json:"webhook_id"`
			Event     json.RawMessage `json:"webhook_event"`
		}
		if json.NewDecoder(r.Body).Decode(&body) != nil || !json.Valid(body.Event) {
			refuse(w, 400, "INVALID_REQUEST")
			return
		}
		status := "FAILURE"
		if body.Sig == "good" && body.WebhookID == "WH-TEST" {
			status = "SUCCESS"
		}
		reply(w, 200, map[string]string{"verification_status": status})
	})
	fake := httptest.NewServer(mux)
	t.Cleanup(fake.Close)
	s.settings.Load().paypal = &paypalClient{http: fake.Client(), base: fake.URL, webhookID: "WH-TEST"}
	return c, s, f
}

// order changes an order as the payer or PayPal would.
func (f *fakePayPal) order(id string, change func(*fakeOrder)) {
	f.mu.Lock()
	defer f.mu.Unlock()
	change(f.orders[id])
}

func (f *fakePayPal) sub(id string, change func(*paypalSubscription)) {
	f.mu.Lock()
	defer f.mu.Unlock()
	change(f.subs[id])
}

// paypalBack is where the server sends a payer coming back from PayPal.
func paypalBack(c *client, query string) string {
	c.t.Helper()
	if rec := c.do("GET", "/paypal/return?"+query, nil); rec.Code != http.StatusSeeOther {
		c.t.Fatalf("return: %d %s", rec.Code, rec.Body)
	}
	return c.location
}

// paypalEventTo posts a webhook event, signed as sig says.
func paypalEventTo(c *client, sig string, event map[string]any) int {
	c.t.Helper()
	hook := c.another()
	hook.header = http.Header{"Paypal-Transmission-Sig": {sig}}
	return hook.do("POST", "/webhooks/paypal", event).Code
}

func checkout(c *client, product string, app PayPalCheckoutRequestApp) string {
	c.t.Helper()
	var out PayPalCheckout
	c.must(200, "POST", "/me/paypal/checkout", PayPalCheckoutRequest{Product: product, App: app}, &out)
	return out.Url
}

func TestPayPalOff(t *testing.T) {
	c, _, _ := billingServer(t)
	register(c, "ana@example.test", "Ana")
	if info := serverInfo(c); info.Billing == nil || info.Billing.Paypal != nil {
		t.Fatalf("%+v", info.Billing)
	}
	if p := myPlanOf(c); p.Paypal != nil {
		t.Fatalf("%+v", p.Paypal)
	}
	c.errorCode(404, "POST", "/me/paypal/checkout", PayPalCheckoutRequest{Product: "plus90", App: PayPalCheckoutRequestAppWeb})
	if code := paypalEventTo(c, "good", map[string]any{"event_type": "CHECKOUT.ORDER.APPROVED"}); code != 404 {
		t.Fatal(code)
	}
	if got := paypalBack(c, "token=ORDER1&app=web"); got != "https://balnana.test/settings/plan?paypal=failed" {
		t.Fatal(got)
	}
}

func TestPayPalOrder(t *testing.T) {
	c, s, f := paypalServer(t)
	exec(t, s, `insert into plan_products (provider, product, plan_id, days, min_amount, currency) values ('paypal', 'plus-90', 'plus', 90, 300, 'TWD')`)
	u := register(c, "ana@example.test", "Ana")
	if info := serverInfo(c); info.Billing == nil || info.Billing.Paypal == nil || !*info.Billing.Paypal {
		t.Fatalf("%+v", info.Billing)
	}
	p := myPlanOf(c)
	if p.Paypal == nil || len(p.Paypal.Offers) != 1 || len(p.Paypal.Subscribed) != 0 {
		t.Fatalf("%+v", p.Paypal)
	}
	if o := p.Paypal.Offers[0]; o.Product != "plus-90" || o.PlanName != "Plus" || o.Days != 90 || o.Subscription ||
		o.Amount == nil || *o.Amount != "300" || o.Currency == nil || *o.Currency != "TWD" {
		t.Fatalf("%+v", o)
	}

	c.errorCode(404, "POST", "/me/paypal/checkout", PayPalCheckoutRequest{Product: "nothing", App: PayPalCheckoutRequestAppWeb})
	c.errorCode(400, "POST", "/me/paypal/checkout", PayPalCheckoutRequest{Product: "plus-90", App: "ios"})
	if href := checkout(c, "plus-90", PayPalCheckoutRequestAppWeb); href != "https://paypal.test/pay?token=ORDER1" {
		t.Fatal(href)
	}
	unit := f.asked["purchase_units"].([]any)[0].(map[string]any)
	if unit["custom_id"] != u.Id || unit["amount"].(map[string]any)["value"] != "300" {
		t.Fatalf("%+v", unit)
	}
	ctx := f.asked["payment_source"].(map[string]any)["paypal"].(map[string]any)["experience_context"].(map[string]any)
	if ctx["return_url"] != "https://balnana.test/api/v1/paypal/return?app=web" {
		t.Fatalf("%+v", ctx)
	}

	// Back before paying, or having given up.
	if got := paypalBack(c, "token=ORDER1&app=web"); got != "https://balnana.test/settings/plan?paypal=pending" {
		t.Fatal(got)
	}
	if got := paypalBack(c, "token=ORDER1&app=android&cancel=1"); got != "balnana://app/settings/plan?paypal=cancelled" {
		t.Fatal(got)
	}
	// An order the server didn't start buys nothing.
	f.orders["ELSE"] = &fakeOrder{status: "APPROVED", customID: u.Id, amount: paypalMoney{"TWD", "300"}}
	if got := paypalBack(c, "token=ELSE&app=web"); got != "https://balnana.test/settings/plan?paypal=failed" {
		t.Fatal(got)
	}

	// Paid: the server captures it, once however often it hears.
	f.order("ORDER1", func(o *fakeOrder) { o.status = "APPROVED" })
	if got := paypalBack(c, "token=ORDER1&app=android"); got != "balnana://app/settings/plan?paypal=done" {
		t.Fatal(got)
	}
	p = myPlanOf(c)
	want := time.Now().AddDate(0, 0, 90)
	if !p.Paid || p.PlanName != "Plus" || p.ExpiresAt == nil || p.ExpiresAt.Sub(want).Abs() > time.Minute {
		t.Fatalf("%+v", p)
	}
	if code := paypalEventTo(c, "good", map[string]any{"event_type": "CHECKOUT.ORDER.APPROVED", "resource": map[string]any{"id": "ORDER1"}}); code != 200 {
		t.Fatal(code)
	}
	if got := paypalBack(c, "token=ORDER1&app=web"); got != "https://balnana.test/settings/plan?paypal=done" {
		t.Fatal(got)
	}
	if again := myPlanOf(c); !again.ExpiresAt.Equal(*p.ExpiresAt) {
		t.Fatal(again.ExpiresAt, p.ExpiresAt)
	}
	if state, who := paymentState(t, s, "CAP-ORDER1"); state != "applied" || who == nil || *who != u.Id {
		t.Fatal(state, who)
	}

	// Only PayPal's word counts.
	f.order("ORDER1", func(o *fakeOrder) { o.capture = "REFUNDED" })
	refund := map[string]any{"event_type": "PAYMENT.CAPTURE.REFUNDED", "resource": map[string]any{"id": "REFUND1",
		"links": []paypalLink{{Rel: "up", Href: "https://api.paypal.com/v2/payments/captures/CAP-ORDER1"}}}}
	if code := paypalEventTo(c, "forged", refund); code != 403 {
		t.Fatal(code)
	}
	if !myPlanOf(c).Paid {
		t.Fatal("refunded on a forged event")
	}
	// A refund takes back the time it bought.
	if code := paypalEventTo(c, "good", refund); code != 200 {
		t.Fatal(code)
	}
	if p := myPlanOf(c); p.Paid {
		t.Fatalf("%+v", p)
	}
	if state, _ := paymentState(t, s, "CAP-ORDER1"); state != "refunded" {
		t.Fatal(state)
	}

	// Paying other than was asked is left for the administrator.
	checkout(c, "plus-90", PayPalCheckoutRequestAppWeb)
	f.order("ORDER2", func(o *fakeOrder) { o.status, o.paid = "APPROVED", &paypalMoney{"TWD", "30"} })
	paypalBack(c, "token=ORDER2&app=web")
	if state, _ := paymentState(t, s, "CAP-ORDER2"); state != "unmatched" {
		t.Fatal(state)
	}
	if p := myPlanOf(c); p.Paid {
		t.Fatalf("%+v", p)
	}
}

func TestPayPalSubscription(t *testing.T) {
	c, s, f := paypalServer(t)
	exec(t, s, `insert into plan_products (provider, product, plan_id, days) values ('paypal', 'P-PLUS', 'plus', 30), ('paypal', 'P-GONE', 'plus', 30)`)
	u := register(c, "ana@example.test", "Ana")
	if o := myPlanOf(c).Paypal.Offers[0]; o.Product != "P-GONE" || !o.Subscription || o.Amount != nil {
		t.Fatalf("%+v", o)
	}
	// A plan PayPal no longer has.
	c.errorCode(404, "POST", "/me/paypal/checkout", PayPalCheckoutRequest{Product: "P-GONE", App: PayPalCheckoutRequestAppWeb})

	if href := checkout(c, "P-PLUS", PayPalCheckoutRequestAppAndroid); href != "https://paypal.test/subscribe?ba_token=I-SUB1" {
		t.Fatal(href)
	}
	if f.subs["I-SUB1"].CustomID != u.Id {
		t.Fatalf("%+v", f.subs["I-SUB1"])
	}
	// Not approved yet: starting again is fine.
	checkout(c, "P-PLUS", PayPalCheckoutRequestAppWeb)

	next := time.Now().AddDate(0, 0, 30).UTC().Truncate(time.Second)
	paid := func(at time.Time) {
		f.sub("I-SUB1", func(sub *paypalSubscription) {
			sub.Status = "ACTIVE"
			sub.BillingInfo.NextBillingTime = &next
			sub.BillingInfo.LastPayment = &struct {
				Amount paypalMoney `json:"amount"`
				Time   time.Time   `json:"time"`
			}{paypalMoney{"TWD", "100"}, at}
		})
	}
	paid(time.Now().UTC().Truncate(time.Second))
	if got := paypalBack(c, "subscription_id=I-SUB1&ba_token=x&token=y&app=android"); got != "balnana://app/settings/plan?paypal=done" {
		t.Fatal(got)
	}
	p := myPlanOf(c)
	if !p.Paid || p.PlanName != "Plus" || p.ExpiresAt == nil || !p.ExpiresAt.Equal(next.Add(paypalGrace)) {
		t.Fatalf("%+v want %v", p, next.Add(paypalGrace))
	}
	if !slices.Equal(p.Paypal.Subscribed, []string{"P-PLUS"}) {
		t.Fatal(p.Paypal.Subscribed)
	}
	if code := c.errorCode(409, "POST", "/me/paypal/checkout", PayPalCheckoutRequest{Product: "P-PLUS", App: PayPalCheckoutRequestAppWeb}); code != "paypal_subscribed" {
		t.Fatal(code)
	}

	// It renews.
	next = next.AddDate(0, 0, 30)
	paid(time.Now().UTC().Truncate(time.Second).Add(time.Hour))
	sale := map[string]any{"event_type": "PAYMENT.SALE.COMPLETED", "resource": map[string]any{"id": "SALE2", "billing_agreement_id": "I-SUB1"}}
	if code := paypalEventTo(c, "good", sale); code != 200 {
		t.Fatal(code)
	}
	if p := myPlanOf(c); !p.ExpiresAt.Equal(next.Add(paypalGrace)) {
		t.Fatal(p.ExpiresAt)
	}
	var payments int
	if err := s.db.QueryRow(t.Context(), `select count(*) from payment_events where provider = 'paypal' and state = 'applied'`).Scan(&payments); err != nil || payments != 2 {
		t.Fatal(payments, err)
	}

	// Cancelled, it keeps the time paid for and can be taken again.
	f.sub("I-SUB1", func(sub *paypalSubscription) { sub.Status = "CANCELLED" })
	if code := paypalEventTo(c, "good", map[string]any{"event_type": "BILLING.SUBSCRIPTION.CANCELLED", "resource": map[string]any{"id": "I-SUB1"}}); code != 200 {
		t.Fatal(code)
	}
	p = myPlanOf(c)
	if !p.Paid || !p.ExpiresAt.Equal(next.Add(paypalGrace)) || len(p.Paypal.Subscribed) != 0 {
		t.Fatalf("%+v", p)
	}
	checkout(c, "P-PLUS", PayPalCheckoutRequestAppWeb)

	// Someone else's subscription gives this account nothing.
	other := c.another()
	register(other, "ben@example.test", "Ben")
	if got := paypalBack(other, "subscription_id=I-SUB1&app=web"); got != "https://balnana.test/settings/plan?paypal=failed" {
		t.Fatal(got)
	}
	if p := myPlanOf(other); p.Paid {
		t.Fatalf("%+v", p)
	}
}

func TestPayPalCatalog(t *testing.T) {
	c, _, _ := adminClient(t, map[string]string{"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true"})
	admin := c.asAdmin(setUp(c))
	var catalog PlanCatalog
	admin.must(200, "GET", "/admin/plans", nil, &catalog)
	for _, bad := range [][]PlanProduct{
		{{Provider: Paypal, Product: "plus-90", PlanId: "plus", Days: 90}},                                                // no price
		{{Provider: Paypal, Product: "plus-90", PlanId: "plus", Days: 90, MinAmount: ptr("99.50"), Currency: ptr("TWD")}}, // TWD has no cents
		{{Provider: Paypal, Product: "P-PLUS", PlanId: "plus", Days: 30}, {Provider: Paypal, Product: "P-PLUS", PlanId: "plus", Days: 30}},
	} {
		catalog.Products = bad
		if code := admin.errorCode(400, "PUT", "/admin/plans", catalog); code != "invalid_plan" {
			t.Fatal(code)
		}
	}
	catalog.Products = []PlanProduct{
		{Provider: Paypal, Product: "P-PLUS", PlanId: "plus", Days: 30},
		{Provider: Paypal, Product: "plus-90", PlanId: "plus", Days: 90, MinAmount: ptr("300.00"), Currency: ptr("TWD")},
		{Provider: Paypal, Product: "plus-usd", PlanId: "plus", Days: 90, MinAmount: ptr("9.99"), Currency: ptr("USD")},
	}
	admin.must(200, "PUT", "/admin/plans", catalog, &catalog)
	if len(catalog.Products) != 3 {
		t.Fatalf("%+v", catalog.Products)
	}
}
