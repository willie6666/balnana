package api

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"slices"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"

	"balnana/internal/config"
)

// fakePayPal answers as PayPal's REST API does, for the calls the server
// makes. Tests change its orders and subscriptions as a payer or PayPal would.
type fakePayPal struct {
	mu                      sync.Mutex
	orders                  map[string]*fakeOrder
	subs                    map[string]*paypalSubscription
	plans                   []string // the subscription plans PayPal has
	transactions            map[string][]paypalTransaction
	sales                   map[string]*fakeSale
	refunds                 map[string]string // refund ID to original sale ID
	refundStates            map[string]string
	transactionsUnavailable bool
	// captureRefusals remembers each declined capture's request ID, as PayPal
	// answers a repeat of one with the same refusal.
	captureRefusals map[string]string
	asked           map[string]any // the last order or subscription asked for
	n               int
	requests        []paypalTestRequest
}

type paypalTestRequest struct {
	Method   string          `json:"method"`
	Path     string          `json:"path"`
	Query    url.Values      `json:"query"`
	Header   http.Header     `json:"header"`
	Body     json.RawMessage `json:"body,omitempty"`
	Status   int             `json:"status"`
	Response json.RawMessage `json:"response,omitempty"`
}

type fakeSale struct {
	ID                 string    `json:"id"`
	State              string    `json:"state"`
	BillingAgreementID string    `json:"billing_agreement_id"`
	CreateTime         time.Time `json:"create_time"`
	ParentPayment      string    `json:"parent_payment"`
	Amount             struct {
		Total    string `json:"total"`
		Currency string `json:"currency"`
	} `json:"amount"`
}

type fakeOrder struct {
	status         string
	customID       string
	amount         paypalMoney
	capture        string // the capture's status, once there is one
	decline        string // the issue capturing it is refused with
	paid           *paypalMoney
	minimalCapture bool // replay an earlier response that used PayPal's default
}

func (o *fakeOrder) json(id string) map[string]any {
	unit := map[string]any{"custom_id": o.customID, "amount": o.amount}
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
	f := &fakePayPal{orders: map[string]*fakeOrder{}, subs: map[string]*paypalSubscription{}, plans: []string{"P-5ML4271244454362WXNWU5NQ"},
		transactions: map[string][]paypalTransaction{}, sales: map[string]*fakeSale{}, refunds: map[string]string{}, refundStates: map[string]string{},
		captureRefusals: map[string]string{}}
	mux := http.NewServeMux()
	reply := func(w http.ResponseWriter, status int, v any) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(status)
		_ = json.NewEncoder(w).Encode(v)
	}
	refuse := func(w http.ResponseWriter, status int, issue string) {
		w.Header().Set("PayPal-Debug-Id", "f0e1d2c3b4a59")
		reply(w, status, map[string]any{"name": "REFUSED", "details": []map[string]string{{"issue": issue}}})
	}
	mux.HandleFunc("POST /v2/checkout/orders", func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()
		if r.Header.Get("PayPal-Request-Id") == "" {
			refuse(w, 400, "PAYPAL_REQUEST_ID_REQUIRED")
			return
		}
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
		key := r.Header.Get("PayPal-Request-Id")
		switch {
		case o == nil:
			refuse(w, 404, "INVALID_RESOURCE_ID")
		case f.captureRefusals[key] != "":
			refuse(w, 422, f.captureRefusals[key])
		case o.decline != "":
			f.captureRefusals[key] = o.decline
			refuse(w, 422, o.decline)
		case o.status != "APPROVED":
			refuse(w, 422, "ORDER_ALREADY_CAPTURED")
		default:
			o.status, o.capture = "COMPLETED", "COMPLETED"
			if o.minimalCapture || r.Header.Get("Prefer") != "return=representation" {
				reply(w, 201, map[string]any{"id": r.PathValue("id"), "status": "COMPLETED", "links": []paypalLink{{Rel: "self", Href: "https://api-m.paypal.com/v2/checkout/orders/" + r.PathValue("id")}}})
			} else {
				reply(w, 201, o.json(r.PathValue("id")))
			}
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
		reply(w, 201, fakePayPalSubscriptionJSON(&body))
	})
	mux.HandleFunc("GET /v1/billing/subscriptions/{id}", func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()
		sub := f.subs[r.PathValue("id")]
		if sub == nil {
			refuse(w, 404, "RESOURCE_NOT_FOUND")
			return
		}
		reply(w, 200, fakePayPalSubscriptionJSON(sub))
	})
	mux.HandleFunc("GET /v1/billing/subscriptions/{id}/transactions", func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()
		if f.transactionsUnavailable {
			refuse(w, 503, "UNAVAILABLE")
			return
		}
		start, err1 := time.Parse(time.RFC3339, r.URL.Query().Get("start_time"))
		end, err2 := time.Parse(time.RFC3339, r.URL.Query().Get("end_time"))
		if err1 != nil || err2 != nil {
			refuse(w, 400, "BAD_TIME_RANGE")
			return
		}
		var list []paypalTransaction
		for _, payment := range f.transactions[r.PathValue("id")] {
			if !payment.Time.Before(start) && !payment.Time.After(end) {
				list = append(list, payment)
			}
		}
		reply(w, 200, map[string]any{"transactions": list})
	})
	mux.HandleFunc("GET /v1/payments/sale/{id}", func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()
		if sale := f.sales[r.PathValue("id")]; sale != nil {
			reply(w, 200, sale)
		} else {
			refuse(w, 404, "NOT_FOUND")
		}
	})
	mux.HandleFunc("GET /v1/payments/refund/{id}", func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()
		if sale := f.refunds[r.PathValue("id")]; sale != "" {
			state := f.refundStates[r.PathValue("id")]
			if state == "" {
				state = "completed"
			}
			reply(w, 200, map[string]string{"id": r.PathValue("id"), "state": state, "sale_id": sale})
		} else {
			refuse(w, 404, "NOT_FOUND")
		}
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
		if body.Sig == "good" && body.WebhookID == "6JK70417LH900261Y" {
			status = "SUCCESS"
		}
		reply(w, 200, map[string]string{"verification_status": status})
	})
	fake := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		body, err := io.ReadAll(r.Body)
		if err != nil {
			t.Error(err)
			w.WriteHeader(500)
			return
		}
		r.Body = io.NopCloser(bytes.NewReader(body))
		f.mu.Lock()
		request := len(f.requests)
		f.requests = append(f.requests, paypalTestRequest{Method: r.Method, Path: r.URL.Path, Query: r.URL.Query(), Header: r.Header.Clone(), Body: body})
		f.mu.Unlock()
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, r)
		f.mu.Lock()
		f.requests[request].Status, f.requests[request].Response = rec.Code, append([]byte(nil), rec.Body.Bytes()...)
		f.mu.Unlock()
		for key, values := range rec.Header() {
			w.Header()[key] = values
		}
		w.WriteHeader(rec.Code)
		_, _ = w.Write(rec.Body.Bytes())
	}))
	t.Cleanup(fake.Close)
	s.settings.Load().paypal = &paypalClient{http: fake.Client(), base: fake.URL, webhookID: "6JK70417LH900261Y"}
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
	if paid := f.subs[id].BillingInfo.LastPayment; paid != nil {
		for _, payment := range f.transactions[id] {
			if payment.Time.Equal(paid.Time) {
				return
			}
		}
		payment := paypalTransaction{ID: fmt.Sprintf("SALE-%s-%d", id, len(f.transactions[id])+1), Status: "COMPLETED", Time: paid.Time}
		payment.Amount.Gross = paid.Amount
		f.transactions[id] = append(f.transactions[id], payment)
		sale := &fakeSale{ID: payment.ID, State: "completed", BillingAgreementID: id, CreateTime: paid.Time, ParentPayment: "PAY-TEST"}
		sale.Amount.Total, sale.Amount.Currency = paid.Amount.Value, paid.Amount.Currency
		f.sales[payment.ID] = sale
	}
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
	hook.header = http.Header{
		"Paypal-Transmission-Sig":  {sig},
		"Paypal-Auth-Algo":         {"SHA256withRSA"},
		"Paypal-Cert-Url":          {"https://api-m.sandbox.paypal.com/v1/notifications/certs/CERT-TEST"},
		"Paypal-Transmission-Id":   {"8b4e4f10-c66f-11ed-afa1-0242ac120002"},
		"Paypal-Transmission-Time": {time.Now().UTC().Format(time.RFC3339)},
	}
	full := map[string]any{
		"id": "WH-8PT597110X687430L-KW908805XS166301R", "create_time": time.Now().UTC().Format(time.RFC3339),
		"resource_type": "sale", "summary": "Payment status changed", "resource": map[string]any{},
		"links": []paypalLink{{Rel: "self", Href: "https://api-m.paypal.com/v1/notifications/webhooks-events/WH-TEST"}},
	}
	for key, value := range event {
		full[key] = value
	}
	return hook.do("POST", "/webhooks/paypal", full).Code
}

// Optional fields are omitted as in PayPal's API, rather than emitted as null
// by the production projection struct. Populated billing info requires a balance.
func fakePayPalSubscriptionJSON(sub *paypalSubscription) map[string]any {
	data, _ := json.Marshal(sub)
	var out map[string]any
	_ = json.Unmarshal(data, &out)
	if sub.Subscriber.Name.String() == "" {
		delete(out, "subscriber")
	}
	if sub.BillingInfo.LastPayment == nil && sub.BillingInfo.CycleExecutions == nil {
		delete(out, "billing_info")
	} else {
		billing := out["billing_info"].(map[string]any)
		if sub.BillingInfo.NextBillingTime == nil {
			delete(billing, "next_billing_time")
		}
		if sub.BillingInfo.CycleExecutions == nil {
			delete(billing, "cycle_executions")
		}
		currency := "TWD"
		if sub.BillingInfo.LastPayment == nil {
			delete(billing, "last_payment") // a free trial has paid nothing yet
		} else {
			currency = sub.BillingInfo.LastPayment.Amount.Currency
		}
		if sub.BillingInfo.LastFailedPayment == nil {
			delete(billing, "last_failed_payment")
		} else {
			billing["last_failed_payment"].(map[string]any)["amount"] = paypalMoney{Value: "100", Currency: currency}
		}
		if sub.BillingInfo.OutstandingBalance.Value == "" {
			billing["outstanding_balance"] = paypalMoney{Value: "0", Currency: currency}
		}
	}
	return out
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
	exec(t, s, `insert into plan_products (provider, product, plan_id, days) values ('paypal', 'P-5ML4271244454362WXNWU5NQ', 'plus', 30), ('paypal', 'P-3ML4271244454362WXNWU5NQ', 'plus', 30)`)
	u := register(c, "ana@example.test", "Ana")
	if o := myPlanOf(c).Paypal.Offers[0]; o.Product != "P-3ML4271244454362WXNWU5NQ" || !o.Subscription || o.Amount != nil {
		t.Fatalf("%+v", o)
	}
	// A plan PayPal no longer has.
	c.errorCode(404, "POST", "/me/paypal/checkout", PayPalCheckoutRequest{Product: "P-3ML4271244454362WXNWU5NQ", App: PayPalCheckoutRequestAppWeb})

	if href := checkout(c, "P-5ML4271244454362WXNWU5NQ", PayPalCheckoutRequestAppAndroid); href != "https://paypal.test/subscribe?ba_token=I-SUB1" {
		t.Fatal(href)
	}
	if f.subs["I-SUB1"].CustomID != u.Id {
		t.Fatalf("%+v", f.subs["I-SUB1"])
	}
	// Not approved yet: starting again is fine.
	checkout(c, "P-5ML4271244454362WXNWU5NQ", PayPalCheckoutRequestAppWeb)

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
	if !slices.Equal(p.Paypal.Subscribed, []string{"P-5ML4271244454362WXNWU5NQ"}) {
		t.Fatal(p.Paypal.Subscribed)
	}
	if code := c.errorCode(409, "POST", "/me/paypal/checkout", PayPalCheckoutRequest{Product: "P-5ML4271244454362WXNWU5NQ", App: PayPalCheckoutRequestAppWeb}); code != "paypal_subscribed" {
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
	checkout(c, "P-5ML4271244454362WXNWU5NQ", PayPalCheckoutRequestAppWeb)

	// A return URL credits only the subscription's original account.
	other := c.another()
	register(other, "ben@example.test", "Ben")
	if got := paypalBack(other, "subscription_id=I-SUB1&app=web"); got != "https://balnana.test/settings/plan?paypal=done" {
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
		{{Provider: Paypal, Product: "P-SHORT", PlanId: "plus", Days: 30, MinAmount: ptr("10.00"), Currency: ptr("USD")}},
		{{Provider: Paypal, Product: "plus-zero", PlanId: "plus", Days: 90, MinAmount: ptr("0.00"), Currency: ptr("USD")}},
		{{Provider: Paypal, Product: "plus-btc", PlanId: "plus", Days: 90, MinAmount: ptr("10.00"), Currency: ptr("BTC")}},
		{{Provider: Paypal, Product: "plus-90", PlanId: "plus", Days: 90}},                                                // no price
		{{Provider: Paypal, Product: "plus-90", PlanId: "plus", Days: 90, MinAmount: ptr("99.50"), Currency: ptr("TWD")}}, // TWD has no cents
		{{Provider: Paypal, Product: "P-5ML4271244454362WXNWU5NQ", PlanId: "plus", Days: 30}, {Provider: Paypal, Product: "P-5ML4271244454362WXNWU5NQ", PlanId: "plus", Days: 30}},
	} {
		catalog.Products = bad
		if code := admin.errorCode(400, "PUT", "/admin/plans", catalog); code != "invalid_plan" {
			t.Fatal(code)
		}
	}
	catalog.Products = []PlanProduct{
		{Provider: Paypal, Product: "P-5ML4271244454362WXNWU5NQ", PlanId: "plus", Days: 30},
		{Provider: Paypal, Product: "plus-90", PlanId: "plus", Days: 90, MinAmount: ptr("300.00"), Currency: ptr("TWD")},
		{Provider: Paypal, Product: "plus-usd", PlanId: "plus", Days: 90, MinAmount: ptr("9.99"), Currency: ptr("USD")},
	}
	admin.must(200, "PUT", "/admin/plans", catalog, &catalog)
	if len(catalog.Products) != 3 {
		t.Fatalf("%+v", catalog.Products)
	}
}

func paidPayPalSubscription(t *testing.T) (*client, *Server, *fakePayPal, time.Time) {
	t.Helper()
	c, s, f := paypalServer(t)
	exec(t, s, `insert into plan_products (provider, product, plan_id, days) values ('paypal', 'P-5ML4271244454362WXNWU5NQ', 'plus', 30)`)
	register(c, "ana@example.test", "Ana")
	checkout(c, "P-5ML4271244454362WXNWU5NQ", PayPalCheckoutRequestAppWeb)
	paid := time.Now().UTC().Truncate(time.Second)
	f.pay("I-SUB1", paid, paid.AddDate(0, 0, 30))
	return c, s, f, paid
}

func (f *fakePayPal) pay(id string, at, next time.Time) {
	f.sub(id, func(sub *paypalSubscription) {
		sub.Status = "ACTIVE"
		sub.BillingInfo.NextBillingTime = &next
		sub.BillingInfo.LastPayment = &struct {
			Amount paypalMoney `json:"amount"`
			Time   time.Time   `json:"time"`
		}{paypalMoney{"TWD", "100"}, at}
	})
}

func subscriptionEvent(c *client, kind string) int {
	return paypalEventTo(c, "good", map[string]any{"event_type": kind, "resource": map[string]string{"id": "I-SUB1"}})
}

func TestPayPalFailedRenewalKeepsPaidPeriod(t *testing.T) {
	c, _, f, paid := paidPayPalSubscription(t)
	paypalBack(c, "subscription_id=I-SUB1&app=web")
	before := *myPlanOf(c).ExpiresAt
	f.sub("I-SUB1", func(sub *paypalSubscription) {
		next := paid.AddDate(0, 0, 60)
		sub.BillingInfo.NextBillingTime = &next
		sub.BillingInfo.FailedPaymentsCount = 1
		sub.BillingInfo.OutstandingBalance = paypalMoney{"TWD", "100"}
	})
	for range 2 {
		if code := subscriptionEvent(c, "BILLING.SUBSCRIPTION.PAYMENT.FAILED"); code != 200 {
			t.Fatal(code)
		}
		if after := myPlanOf(c).ExpiresAt; after == nil || !after.Equal(before) {
			t.Fatal(before, after)
		}
	}
}

func TestPayPalFirstSyncAfterFailedRenewal(t *testing.T) {
	for _, failure := range []string{"balance", "count", "last_attempt"} {
		t.Run(failure, func(t *testing.T) {
			c, _, f, _ := paidPayPalSubscription(t)
			paid := time.Now().UTC().Truncate(time.Second).AddDate(0, 0, -40)
			f.pay("I-SUB1", paid, paid.AddDate(0, 0, 60))
			f.sub("I-SUB1", func(sub *paypalSubscription) {
				switch failure {
				case "balance":
					sub.BillingInfo.OutstandingBalance = paypalMoney{"TWD", "100"}
				case "count":
					sub.BillingInfo.FailedPaymentsCount = 1
				case "last_attempt":
					sub.BillingInfo.LastFailedPayment = &struct {
						Time time.Time `json:"time"`
					}{paid.AddDate(0, 0, 30)}
				}
			})
			paypalBack(c, "subscription_id=I-SUB1&app=web")
			if p := myPlanOf(c); p.Paid {
				t.Fatalf("unpaid period granted: %+v", p)
			}
		})
	}
}

func TestPayPalPaidPeriodSurvivesCancellationBeforeSync(t *testing.T) {
	for _, status := range []string{"CANCELLED", "SUSPENDED", "EXPIRED"} {
		t.Run(status, func(t *testing.T) {
			c, _, f, paid := paidPayPalSubscription(t)
			f.sub("I-SUB1", func(sub *paypalSubscription) { sub.Status = status; sub.BillingInfo.NextBillingTime = nil })
			if code := subscriptionEvent(c, "BILLING.SUBSCRIPTION."+status); code != 200 {
				t.Fatal(code)
			}
			p := myPlanOf(c)
			if !p.Paid || p.ExpiresAt == nil || !p.ExpiresAt.Equal(paid.AddDate(0, 0, 30).Add(paypalGrace)) {
				t.Fatalf("%+v", p)
			}
		})
	}
}

func (f *fakePayPal) refundSale(saleID, state string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.sales[saleID].State = state
	f.refunds["REFUND1"] = saleID
}

func saleRefundEvent(c *client, kind, id string) int {
	// No billing_agreement_id: PayPal's refund resource points to the sale.
	return paypalEventTo(c, "good", map[string]any{"event_type": kind, "resource": map[string]string{"id": id}})
}

func TestPayPalSubscriptionRefund(t *testing.T) {
	for _, timing := range []string{"after_payment", "before_payment", "reversed", "transaction_list_lags"} {
		t.Run(timing, func(t *testing.T) {
			c, s, f, _ := paidPayPalSubscription(t)
			const saleID = "SALE-I-SUB1-1"
			if timing != "before_payment" {
				paypalBack(c, "subscription_id=I-SUB1&app=web")
			}
			f.refundSale(saleID, "refunded")
			kind, id := "PAYMENT.SALE.REFUNDED", "REFUND1"
			if timing == "reversed" {
				f.refundSale(saleID, "denied")
				kind, id = "PAYMENT.SALE.REVERSED", saleID
			}
			if timing != "transaction_list_lags" {
				f.mu.Lock()
				f.transactions["I-SUB1"][0].Status = "REFUNDED"
				f.mu.Unlock()
			}
			for range 2 {
				if code := saleRefundEvent(c, kind, id); code != 200 {
					t.Fatal(code)
				}
				if state, _ := paymentState(t, s, saleID); state != "refunded" {
					t.Fatal(state)
				}
				if p := myPlanOf(c); p.Paid {
					t.Fatalf("refunded time remains: %+v", p)
				}
			}
			// A delayed successful-payment webhook must not resurrect access.
			if code := paypalEventTo(c, "good", map[string]any{"event_type": "PAYMENT.SALE.COMPLETED", "resource": map[string]string{"id": saleID, "billing_agreement_id": "I-SUB1"}}); code != 200 {
				t.Fatal(code)
			}
			if myPlanOf(c).Paid {
				t.Fatal("refunded subscription restored")
			}
			var n int
			if err := s.db.QueryRow(t.Context(), `select count(*) from payment_events where provider = 'paypal'`).Scan(&n); err != nil || n != 1 {
				t.Fatal(n, err)
			}
		})
	}
}

func TestPayPalRefundKeepsOtherPaidPeriods(t *testing.T) {
	c, s, f, paid := paidPayPalSubscription(t)
	paypalBack(c, "subscription_id=I-SUB1&app=web")
	firstEnd := *myPlanOf(c).ExpiresAt
	f.pay("I-SUB1", paid.Add(time.Hour), paid.AddDate(0, 0, 60))
	paypalBack(c, "subscription_id=I-SUB1&app=web")
	secondEnd := *myPlanOf(c).ExpiresAt
	f.refundSale("SALE-I-SUB1-1", "refunded")
	if code := saleRefundEvent(c, "PAYMENT.SALE.REFUNDED", "REFUND1"); code != 200 {
		t.Fatal(code)
	}
	if p := myPlanOf(c); p.ExpiresAt == nil || !p.ExpiresAt.Equal(secondEnd) {
		t.Fatalf("older refund shortened later renewal: %+v", p)
	}
	f.refundSale("SALE-I-SUB1-2", "refunded")
	if code := saleRefundEvent(c, "PAYMENT.SALE.REFUNDED", "REFUND1"); code != 200 {
		t.Fatal(code)
	}
	if myPlanOf(c).Paid {
		t.Fatal("both periods refunded but still paid")
	}
	// A genuinely new payment after a refund can renew the subscription.
	f.pay("I-SUB1", paid.Add(2*time.Hour), paid.AddDate(0, 0, 90))
	paypalBack(c, "subscription_id=I-SUB1&app=web")
	if p := myPlanOf(c); !p.Paid || !p.ExpiresAt.After(firstEnd) {
		t.Fatalf("new payment did not renew: %+v", p)
	}
	if state, _ := paymentState(t, s, "SALE-I-SUB1-3"); state != "applied" {
		t.Fatal(state)
	}
}

func TestPayPalRefundLatestPeriodRestoresPreviousEnd(t *testing.T) {
	c, _, f, paid := paidPayPalSubscription(t)
	paypalBack(c, "subscription_id=I-SUB1&app=web")
	firstEnd := *myPlanOf(c).ExpiresAt
	f.pay("I-SUB1", paid.Add(time.Hour), paid.AddDate(0, 0, 60))
	paypalBack(c, "subscription_id=I-SUB1&app=web")
	f.refundSale("SALE-I-SUB1-2", "refunded")
	if code := saleRefundEvent(c, "PAYMENT.SALE.REFUNDED", "REFUND1"); code != 200 {
		t.Fatal(code)
	}
	if p := myPlanOf(c); p.ExpiresAt == nil || !p.ExpiresAt.Equal(firstEnd) {
		t.Fatalf("%+v", p)
	}
}

func TestPayPalRefundChecksNativeSale(t *testing.T) {
	c, s, f, _ := paidPayPalSubscription(t)
	paypalBack(c, "subscription_id=I-SUB1&app=web")
	before := *myPlanOf(c).ExpiresAt
	f.refundSale("SALE-I-SUB1-1", "partially_refunded")
	if code := saleRefundEvent(c, "PAYMENT.SALE.REFUNDED", "REFUND1"); code != 200 {
		t.Fatal(code)
	}
	if p := myPlanOf(c); p.ExpiresAt == nil || !p.ExpiresAt.Equal(before) {
		t.Fatal(p)
	}
	f.refundSale("SALE-I-SUB1-1", "completed")
	if code := saleRefundEvent(c, "PAYMENT.SALE.REFUNDED", "REFUND1"); code != 500 {
		t.Fatal(code)
	}
	if state, _ := paymentState(t, s, "SALE-I-SUB1-1"); state != "applied" {
		t.Fatal(state)
	}
	f.refundSale("SALE-I-SUB1-1", "refunded")
	if code := paypalEventTo(c, "forged", map[string]any{"event_type": "PAYMENT.SALE.REFUNDED", "resource": map[string]string{"id": "REFUND1"}}); code != 403 {
		t.Fatal(code)
	}
	if !myPlanOf(c).Paid {
		t.Fatal("forged refund removed access")
	}
}

func TestPayPalTransactionListFailureRetries(t *testing.T) {
	c, _, f, _ := paidPayPalSubscription(t)
	f.transactionsUnavailable = true
	if code := subscriptionEvent(c, "BILLING.SUBSCRIPTION.ACTIVATED"); code != 500 {
		t.Fatal(code)
	}
	if myPlanOf(c).Paid {
		t.Fatal("unverified transaction granted access")
	}
	f.transactionsUnavailable = false
	if code := subscriptionEvent(c, "BILLING.SUBSCRIPTION.ACTIVATED"); code != 200 {
		t.Fatal(code)
	}
	if !myPlanOf(c).Paid {
		t.Fatal("retry lost successful payment")
	}
}

func TestPayPalLegacyPaymentAdoptsSaleID(t *testing.T) {
	c, s, f, paid := paidPayPalSubscription(t)
	paypalBack(c, "subscription_id=I-SUB1&app=web")
	before := *myPlanOf(c).ExpiresAt
	exec(t, s, `update payment_events set event_id = $1 where event_id = 'SALE-I-SUB1-1'`, "I-SUB1@"+paid.Format(time.RFC3339))
	f.refundSale("SALE-I-SUB1-1", "refunded")
	if code := saleRefundEvent(c, "PAYMENT.SALE.REFUNDED", "REFUND1"); code != 200 {
		t.Fatal(code)
	}
	if state, _ := paymentState(t, s, "SALE-I-SUB1-1"); state != "refunded" {
		t.Fatal(state)
	}
	if p := myPlanOf(c); p.Paid {
		t.Fatal(p, before)
	}
}

func TestPayPalConcurrentRefundAndRenewal(t *testing.T) {
	c, s, f, paid := paidPayPalSubscription(t)
	paypalBack(c, "subscription_id=I-SUB1&app=web")
	next := paid.AddDate(0, 0, 60)
	f.pay("I-SUB1", paid.Add(time.Hour), next)
	f.refundSale("SALE-I-SUB1-1", "refunded")
	codes := make(chan int, 2)
	go func() { codes <- saleRefundEvent(c.another(), "PAYMENT.SALE.REFUNDED", "REFUND1") }()
	go func() { codes <- subscriptionEvent(c.another(), "BILLING.SUBSCRIPTION.ACTIVATED") }()
	for range 2 {
		if code := <-codes; code != 200 {
			t.Fatal(code)
		}
	}
	if p := myPlanOf(c); !p.Paid || p.ExpiresAt == nil || !p.ExpiresAt.Equal(next.Add(paypalGrace)) {
		t.Fatalf("%+v", p)
	}
	if state, _ := paymentState(t, s, "SALE-I-SUB1-1"); state != "refunded" {
		t.Fatal(state)
	}
	if state, _ := paymentState(t, s, "SALE-I-SUB1-2"); state != "applied" {
		t.Fatal(state)
	}
}

// PayPal's default capture response contains no purchase_units. Full data is
// requested explicitly, and an old cached minimal response is fetched again.
// https://developer.paypal.com/api/orders/v2/orders-capture
func TestPayPalCaptureMinimalReplay(t *testing.T) {
	c, s, f := paypalServer(t)
	exec(t, s, `insert into plan_products (provider,product,plan_id,days,min_amount,currency) values ('paypal','plus90','plus',90,300,'TWD')`)
	register(c, "ana@example.test", "Ana")
	checkout(c, "plus90", PayPalCheckoutRequestAppWeb)
	f.order("ORDER1", func(o *fakeOrder) { o.status = "APPROVED"; o.minimalCapture = true })
	if got := paypalBack(c, "token=ORDER1&app=web"); got != "https://balnana.test/settings/plan?paypal=done" {
		t.Fatal(got)
	}
	if !myPlanOf(c).Paid {
		t.Fatal("minimal capture response lost its payment")
	}
	for _, r := range f.requests {
		if r.Method == "POST" && strings.HasPrefix(r.Path, "/v2/checkout/orders") {
			if r.Header.Get("Prefer") != "return=representation" || r.Header.Get("PayPal-Request-Id") == "" {
				t.Fatalf("missing checkout headers: %+v", r)
			}
		}
	}
}

func TestPayPalCreatesHaveDistinctRequestIDs(t *testing.T) {
	c, s, f, _ := paidPayPalSubscription(t)
	exec(t, s, `insert into plan_products (provider,product,plan_id,days,min_amount,currency) values ('paypal','plus90','plus',90,300,'TWD')`)
	checkout(c, "plus90", PayPalCheckoutRequestAppWeb)
	checkout(c, "plus90", PayPalCheckoutRequestAppWeb)
	seen := map[string]bool{}
	for _, r := range f.requests {
		if r.Method == "POST" && (r.Path == "/v2/checkout/orders" || r.Path == "/v1/billing/subscriptions") {
			id := r.Header.Get("PayPal-Request-Id")
			if id == "" || len(id) > 38 || seen[id] {
				t.Fatalf("bad create request ID: %q", id)
			}
			seen[id] = true
			if r.Header.Get("Prefer") != "return=representation" {
				t.Fatal(r.Header)
			}
		}
	}
	if len(seen) != 3 {
		t.Fatal(seen)
	}
}

func TestPayPalRefundPendingRetries(t *testing.T) {
	c, _, f, _ := paidPayPalSubscription(t)
	paypalBack(c, "subscription_id=I-SUB1&app=web")
	f.refundSale("SALE-I-SUB1-1", "refunded")
	for _, row := range []struct {
		state  string
		status int
	}{{"pending", 500}, {"cancelled", 200}, {"failed", 200}} {
		f.mu.Lock()
		f.refundStates["REFUND1"] = row.state
		f.mu.Unlock()
		if code := saleRefundEvent(c, "PAYMENT.SALE.REFUNDED", "REFUND1"); code != row.status {
			t.Fatal(row, code)
		}
		if !myPlanOf(c).Paid {
			t.Fatal("incomplete refund removed access")
		}
	}
	f.mu.Lock()
	f.refundStates["REFUND1"] = "completed"
	f.mu.Unlock()
	if code := saleRefundEvent(c, "PAYMENT.SALE.REFUNDED", "REFUND1"); code != 200 {
		t.Fatal(code)
	}
	if myPlanOf(c).Paid {
		t.Fatal("completed refund did not remove access")
	}
}

// The token exchange uses HTTP Basic plus a form, and REST calls use Bearer.
// https://developer.paypal.com/api/rest/authentication/
func TestPayPalOAuthContract(t *testing.T) {
	var tokenCalls, orderCalls int
	fake := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		switch r.URL.Path {
		case "/v1/oauth2/token":
			tokenCalls++
			id, secret, ok := r.BasicAuth()
			if !ok || id != "test-client" || secret != "test-secret" || r.Method != "POST" {
				t.Error("bad token authentication")
			}
			if r.Header.Get("Content-Type") != "application/x-www-form-urlencoded" {
				t.Error(r.Header)
			}
			if err := r.ParseForm(); err != nil || r.Form.Get("grant_type") != "client_credentials" {
				t.Error("bad token grant", err)
			}
			_, _ = io.WriteString(w, `{"access_token":"test-access","token_type":"Bearer","expires_in":3600}`)
		case "/v2/checkout/orders/5O190127TN364715T":
			orderCalls++
			if r.Header.Get("Authorization") != "Bearer test-access" {
				t.Error("bad REST authentication")
			}
			_, _ = io.WriteString(w, `{"id":"5O190127TN364715T","status":"CREATED"}`)
		default:
			t.Error(r.URL.Path)
			w.WriteHeader(404)
		}
	}))
	defer fake.Close()
	cfg := &config.Config{PayPalClientID: "test-client", PayPalSecret: "test-secret", PayPalSandbox: true}
	if p := newPayPalClient(cfg); p.base != paypalSandbox {
		t.Fatal(p.base)
	}
	cfg.PayPalSandbox = false
	if p := newPayPalClient(cfg); p.base != paypalLive {
		t.Fatal(p.base)
	}
	pp := payPalClientAt(cfg, fake.URL)
	for range 2 {
		var order paypalOrder
		if err := pp.call(t.Context(), "GET", "/v2/checkout/orders/5O190127TN364715T", nil, "", &order); err != nil {
			t.Fatal(err)
		}
	}
	if tokenCalls != 1 || orderCalls != 2 {
		t.Fatal(tokenCalls, orderCalls)
	}
}

func TestPayPalBadRequestIsNotMissingResource(t *testing.T) {
	for _, code := range []int{400, 401, 403, 404, 422, 500} {
		if got := paypalNotFound(paypalRefusal{status: code}); got != (code == 404) {
			t.Fatal(code, got)
		}
	}
}

func TestPayPalDeclinedCaptureSendsPayerBack(t *testing.T) {
	c, s, f := paypalServer(t)
	exec(t, s, `insert into plan_products (provider, product, plan_id, days, min_amount, currency) values ('paypal', 'plus-90', 'plus', 90, 300, 'TWD')`)
	register(c, "ana@example.test", "Ana")
	checkout(c, "plus-90", PayPalCheckoutRequestAppWeb)
	f.order("ORDER1", func(o *fakeOrder) { o.status, o.decline = "APPROVED", "INSTRUMENT_DECLINED" })
	if got := paypalBack(c, "token=ORDER1&app=web"); got != "https://paypal.test/pay?token=ORDER1" {
		t.Fatal(got)
	}
	// Paying another way, the next capture isn't taken for a repeat of the first.
	f.order("ORDER1", func(o *fakeOrder) { o.decline = "" })
	if got := paypalBack(c, "token=ORDER1&app=web"); got != "https://balnana.test/settings/plan?paypal=done" {
		t.Fatal(got)
	}
	if !myPlanOf(c).Paid {
		t.Fatal("paid on the second try, but no time")
	}

	// Refused outright, there is nothing to go back for.
	checkout(c, "plus-90", PayPalCheckoutRequestAppWeb)
	f.order("ORDER2", func(o *fakeOrder) { o.status, o.decline = "APPROVED", "TRANSACTION_REFUSED" })
	if got := paypalBack(c, "token=ORDER2&app=android"); got != "balnana://app/settings/plan?paypal=failed" {
		t.Fatal(got)
	}
}

func TestPayPalReversedPayments(t *testing.T) {
	c, s, f := paypalServer(t)
	exec(t, s, `insert into plan_products (provider, product, plan_id, days, min_amount, currency) values ('paypal', 'plus-90', 'plus', 90, 300, 'TWD')`)
	register(c, "ana@example.test", "Ana")
	checkout(c, "plus-90", PayPalCheckoutRequestAppWeb)
	f.order("ORDER1", func(o *fakeOrder) { o.status = "APPROVED" })
	paypalBack(c, "token=ORDER1&app=web")
	f.order("ORDER1", func(o *fakeOrder) { o.capture = "REVERSED" })
	reversal := map[string]any{"event_type": "PAYMENT.CAPTURE.REVERSED", "resource": map[string]any{"id": "REFUND1",
		"links": []paypalLink{{Rel: "up", Href: "https://api.paypal.com/v2/payments/captures/CAP-ORDER1"}}}}
	if code := paypalEventTo(c, "good", reversal); code != 200 {
		t.Fatal(code)
	}
	if state, _ := paymentState(t, s, "CAP-ORDER1"); state != "refunded" || myPlanOf(c).Paid {
		t.Fatal(state)
	}

	c, s, f, _ = paidPayPalSubscription(t)
	paypalBack(c, "subscription_id=I-SUB1&app=web")
	f.mu.Lock()
	f.sales["SALE-I-SUB1-1"].State = "reversed"
	f.mu.Unlock()
	if code := saleRefundEvent(c, "PAYMENT.SALE.REVERSED", "SALE-I-SUB1-1"); code != 200 {
		t.Fatal(code)
	}
	if state, _ := paymentState(t, s, "SALE-I-SUB1-1"); state != "refunded" || myPlanOf(c).Paid {
		t.Fatal(state)
	}
}

// A payment the transaction list doesn't show yet mustn't leave the
// subscription looking unapproved, or the payer could start a second one.
func TestPayPalUnreconciledSubscriptionStillCounts(t *testing.T) {
	c, _, f, _ := paidPayPalSubscription(t)
	f.transactionsUnavailable = true
	if got := paypalBack(c, "subscription_id=I-SUB1&app=web"); got != "https://balnana.test/settings/plan?paypal=pending" {
		t.Fatal(got)
	}
	if p := myPlanOf(c); p.Paid || !slices.Equal(p.Paypal.Subscribed, []string{"P-5ML4271244454362WXNWU5NQ"}) {
		t.Fatalf("%+v", p)
	}
	c.errorCode(409, "POST", "/me/paypal/checkout", PayPalCheckoutRequest{Product: "P-5ML4271244454362WXNWU5NQ", App: PayPalCheckoutRequestAppWeb})
	f.transactionsUnavailable = false
	if code := subscriptionEvent(c, "BILLING.SUBSCRIPTION.ACTIVATED"); code != 200 {
		t.Fatal(code)
	}
	if !myPlanOf(c).Paid {
		t.Fatal("the payment was never taken in")
	}
}

// Approved at PayPal, but neither the payer's return nor an event came: a new
// checkout asks PayPal first.
func TestPayPalCheckoutFindsUnreportedApproval(t *testing.T) {
	c, _, f, _ := paidPayPalSubscription(t)
	c.errorCode(409, "POST", "/me/paypal/checkout", PayPalCheckoutRequest{Product: "P-5ML4271244454362WXNWU5NQ", App: PayPalCheckoutRequestAppWeb})
	if p := myPlanOf(c); !p.Paid {
		t.Fatalf("%+v", p)
	}
	f.mu.Lock()
	defer f.mu.Unlock()
	if len(f.subs) != 1 {
		t.Fatal(len(f.subs))
	}
}

func TestPayPalSweepKeepsApprovedSubscriptions(t *testing.T) {
	c, s, f := paypalServer(t)
	exec(t, s, `insert into plan_products (provider, product, plan_id, days) values ('paypal', 'P-5ML4271244454362WXNWU5NQ', 'plus', 30)`)
	register(c, "ana@example.test", "Ana")
	for range 3 {
		checkout(c, "P-5ML4271244454362WXNWU5NQ", PayPalCheckoutRequestAppWeb)
	}
	// Approved, but its first payment hasn't come; one given up on; one
	// never approved.
	f.sub("I-SUB1", func(sub *paypalSubscription) { sub.Status = "SUSPENDED" })
	f.sub("I-SUB2", func(sub *paypalSubscription) { sub.Status = "CANCELLED" })
	for _, id := range []string{"I-SUB1", "I-SUB2"} {
		paypalBack(c, "subscription_id="+id+"&app=web")
	}
	exec(t, s, `update paypal_subscriptions set created_at = now() - interval '60 days'`)
	if _, err := s.sweepExpired(t.Context()); err != nil {
		t.Fatal(err)
	}
	var kept []string
	rows, err := s.db.Query(t.Context(), `select subscription_id from paypal_subscriptions order by subscription_id`)
	if err == nil {
		kept, err = pgx.CollectRows(rows, pgx.RowTo[string])
	}
	if err != nil || !slices.Equal(kept, []string{"I-SUB1"}) {
		t.Fatal(kept, err)
	}
}

func TestPayPalWebhookNeedsPayPalHeaders(t *testing.T) {
	c, _, f := paypalServer(t)
	hook := c.another()
	hook.header = http.Header{"Paypal-Transmission-Sig": {"good"}, "Paypal-Cert-Url": {"https://evil.test/cert"}}
	if code := hook.do("POST", "/webhooks/paypal", map[string]any{"event_type": "PAYMENT.SALE.COMPLETED"}).Code; code != 403 {
		t.Fatal(code)
	}
	f.mu.Lock()
	defer f.mu.Unlock()
	if len(f.requests) != 0 {
		t.Fatalf("asked paypal: %+v", f.requests)
	}
}

func TestPayPalRefusalNamesDebugID(t *testing.T) {
	_, s, _ := paypalServer(t)
	err := s.settings.Load().paypal.call(t.Context(), http.MethodGet, "/v2/checkout/orders/NONE", nil, "", nil)
	if !strings.Contains(fmt.Sprint(err), "f0e1d2c3b4a59") {
		t.Fatal(err)
	}
}

// trial starts a subscription's free trial at PayPal, to end at next.
func (f *fakePayPal) trial(id string, next time.Time) {
	f.sub(id, func(sub *paypalSubscription) {
		sub.Status = "ACTIVE"
		sub.BillingInfo.NextBillingTime = &next
		sub.BillingInfo.CycleExecutions = []paypalCycleExecution{{TenureType: "TRIAL", CyclesCompleted: 1}, {TenureType: "REGULAR"}}
	})
}

func TestPayPalTrial(t *testing.T) {
	c, s, f := paypalServer(t)
	exec(t, s, `insert into plan_products (provider, product, plan_id, days) values ('paypal', 'P-5ML4271244454362WXNWU5NQ', 'plus', 30)`)
	register(c, "ana@example.test", "Ana")
	checkout(c, "P-5ML4271244454362WXNWU5NQ", PayPalCheckoutRequestAppWeb)
	end := time.Now().AddDate(0, 0, 7).UTC().Truncate(time.Second)
	f.trial("I-SUB1", end)
	if got := paypalBack(c, "subscription_id=I-SUB1&app=web"); got != "https://balnana.test/settings/plan?paypal=done" {
		t.Fatal(got)
	}
	p := myPlanOf(c)
	if !p.Paid || p.PlanName != "Plus" || p.ExpiresAt == nil || !p.ExpiresAt.Equal(end.Add(paypalGrace)) {
		t.Fatalf("%+v", p)
	}

	// The trial over, the first payment carries it on.
	next := end.AddDate(0, 0, 30)
	f.pay("I-SUB1", end, next)
	f.sub("I-SUB1", func(sub *paypalSubscription) {
		sub.BillingInfo.CycleExecutions = []paypalCycleExecution{{TenureType: "TRIAL", CyclesCompleted: 1}, {TenureType: "REGULAR", CyclesCompleted: 1}}
	})
	if code := paypalEventTo(c, "good", map[string]any{"event_type": "PAYMENT.SALE.COMPLETED",
		"resource": map[string]any{"id": "SALE-I-SUB1-1", "billing_agreement_id": "I-SUB1"}}); code != 200 {
		t.Fatal(code)
	}
	if p := myPlanOf(c); !p.ExpiresAt.Equal(next.Add(paypalGrace)) {
		t.Fatal(p.ExpiresAt)
	}
}

func TestPayPalTrialOncePerAccount(t *testing.T) {
	c, s, f := paypalServer(t)
	exec(t, s, `insert into plan_products (provider, product, plan_id, days) values ('paypal', 'P-5ML4271244454362WXNWU5NQ', 'plus', 30)`)
	register(c, "ana@example.test", "Ana")
	checkout(c, "P-5ML4271244454362WXNWU5NQ", PayPalCheckoutRequestAppWeb)
	end := time.Now().AddDate(0, 0, 7).UTC().Truncate(time.Second)
	f.trial("I-SUB1", end)
	paypalBack(c, "subscription_id=I-SUB1&app=web")
	// Cancelled in the trial, it lasts to the trial's end.
	f.sub("I-SUB1", func(sub *paypalSubscription) { sub.Status = "CANCELLED" })
	if code := subscriptionEvent(c, "BILLING.SUBSCRIPTION.CANCELLED"); code != 200 {
		t.Fatal(code)
	}
	if p := myPlanOf(c); !p.Paid || !p.ExpiresAt.Equal(end.Add(paypalGrace)) {
		t.Fatalf("%+v", p)
	}
	// Subscribing again doesn't give a second trial.
	checkout(c, "P-5ML4271244454362WXNWU5NQ", PayPalCheckoutRequestAppWeb)
	f.trial("I-SUB2", end.AddDate(0, 0, 7))
	if got := paypalBack(c, "subscription_id=I-SUB2&app=web"); got != "https://balnana.test/settings/plan?paypal=pending" {
		t.Fatal(got)
	}
	if p := myPlanOf(c); !p.ExpiresAt.Equal(end.Add(paypalGrace)) {
		t.Fatal(p.ExpiresAt)
	}
}
