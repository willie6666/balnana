package api

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"net/url"
	"regexp"
	"slices"
	"strings"
	"testing"
	"time"
)

const kofiTestToken = "kofi-secret"

// billingServer is a charging server with email and a Ko-fi connection.
func billingServer(t *testing.T) (*client, fakeMail, *Server) {
	t.Helper()
	return mailServer(t, map[string]string{
		"BALNANA_BILLING_ENABLED": "true",
		"BALNANA_KOFI_TOKEN":      kofiTestToken,
		"BALNANA_KOFI_URL":        "https://ko-fi.com/balnana",
	})
}

func exec(t *testing.T, s *Server, sql string, args ...any) {
	t.Helper()
	if _, err := s.db.Exec(context.Background(), sql, args...); err != nil {
		t.Fatal(err)
	}
}

// grant gives the account a plan directly.
func grant(t *testing.T, s *Server, userID, plan string) {
	t.Helper()
	exec(t, s, `insert into entitlements (user_id, plan_id, source) values ($1, $2, 'admin')`, userID, plan)
}

// kofi posts a Ko-fi webhook. Fields overrule a donation's defaults.
func (c *client) kofi(fields map[string]any) *httptest.ResponseRecorder {
	c.t.Helper()
	ev := map[string]any{
		"verification_token": kofiTestToken, "message_id": fmt.Sprintf("m-%d", time.Now().UnixNano()),
		"timestamp": time.Now().UTC().Format(time.RFC3339), "type": "Donation", "from_name": "Payer",
		"email": "payer@example.test", "amount": "5.00", "currency": "USD", "is_subscription_payment": false,
	}
	for k, v := range fields {
		ev[k] = v
	}
	data, err := json.Marshal(ev)
	if err != nil {
		c.t.Fatal(err)
	}
	req := httptest.NewRequest("POST", kofiPath, strings.NewReader(url.Values{"data": {string(data)}}.Encode()))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	rec := httptest.NewRecorder()
	c.h.ServeHTTP(rec, req)
	return rec
}

func (c *client) kofiOK(fields map[string]any) {
	c.t.Helper()
	if rec := c.kofi(fields); rec.Code != http.StatusOK {
		c.t.Fatalf("webhook: %d %s", rec.Code, rec.Body)
	}
}

func myPlanOf(c *client) MyPlan {
	c.t.Helper()
	var p MyPlan
	c.must(200, "GET", "/me/plan", nil, &p)
	return p
}

// kofiProducts sells the plus plan: 35 days by tier, 30 for 3 USD or more.
func kofiProducts(t *testing.T, s *Server) {
	t.Helper()
	exec(t, s, `insert into plan_products (provider, product, plan_id, days) values ('kofi', 'Supporter', 'plus', 35)`)
	exec(t, s, `insert into plan_products (provider, plan_id, days, min_amount, currency) values ('kofi', 'plus', 30, 3, 'USD')`)
}

func paymentState(t *testing.T, s *Server, eventID string) (state string, userID *string) {
	t.Helper()
	err := s.db.QueryRow(context.Background(), `select state, user_id::text from payment_events where event_id = $1`, eventID).
		Scan(&state, &userID)
	if err != nil {
		t.Fatal(err)
	}
	return state, userID
}

func TestBillingOff(t *testing.T) {
	c := accountsClient(t, map[string]string{})
	register(c, "ana@example.test", "Ana")
	if serverInfo(c).Billing != nil {
		t.Fatal("billing shown while off")
	}
	if code := c.errorCode(404, "GET", "/me/plan", nil); code != "billing_off" {
		t.Fatal(code)
	}
	g := createGroup(c, "Ana", "Ben")
	if code := c.errorCode(404, "PUT", "/g/"+g.Token+"/sponsor", nil); code != "billing_off" {
		t.Fatal(code)
	}
	if rec := c.kofi(nil); rec.Code != http.StatusNotFound {
		t.Fatalf("webhook with no token: %d", rec.Code)
	}
}

func TestBillingNeedsAccounts(t *testing.T) {
	c, _, s := billingServer(t)
	if info := serverInfo(c); info.Billing == nil || info.Billing.KofiUrl == nil || *info.Billing.KofiUrl != "https://ko-fi.com/balnana" {
		t.Fatalf("%+v", info.Billing)
	}
	u := register(c, "ana@example.test", "Ana")
	p := myPlanOf(c)
	if p.PlanName != "Free" || p.Paid || p.ExpiresAt != nil || p.OwnGroups.Used != 0 || p.OwnGroups.Limit == nil {
		t.Fatalf("%+v", p)
	}
	grant(t, s, u.Id, "plus")
	if p := myPlanOf(c); p.PlanName != "Plus" || !p.Paid {
		t.Fatalf("%+v", p)
	}
}

func TestReceiptLimit(t *testing.T) {
	c, _, s := billingServer(t)
	exec(t, s, `update plans set receipts_per_group = 1 where is_default`)
	register(c, "ana@example.test", "Ana")
	g := createGroup(c, "Ana", "Ben")
	first, second := receiptExpense(c, g), receiptExpense(c, g)
	path := func(e Expense) string { return "/g/" + g.Token + "/expenses/" + e.Id + "/receipt" }
	photo := pngBytes(t, halves(8, 8))
	if rec := c.upload(path(first), "image/png", photo); rec.Code != http.StatusOK {
		t.Fatalf("%d %s", rec.Code, rec.Body)
	}
	// Replacing the photo adds none.
	if rec := c.upload(path(first), "image/png", photo); rec.Code != http.StatusOK {
		t.Fatalf("%d %s", rec.Code, rec.Body)
	}
	rec := c.upload(path(second), "image/png", photo)
	var body Error
	if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
		t.Fatal(err)
	}
	if rec.Code != http.StatusPaymentRequired || body.Code != "plan_limit" || body.Params == nil ||
		(*body.Params)["limit"] != "receipts" || (*body.Params)["max"] != float64(1) {
		t.Fatalf("%d %s", rec.Code, rec.Body)
	}
	// Removing one makes room, and a deleted expense's photo doesn't count.
	c.must(204, "DELETE", "/g/"+g.Token+"/expenses/"+first.Id, nil, nil)
	if rec := c.upload(path(second), "image/png", photo); rec.Code != http.StatusOK {
		t.Fatalf("%d %s", rec.Code, rec.Body)
	}
	var plan GroupPlan
	c.must(200, "GET", "/g/"+g.Token+"/plan", nil, &plan)
	if plan.Receipts.Used != 1 || *plan.Receipts.Limit != 1 {
		t.Fatalf("%+v", plan)
	}
	// Bringing the deleted one back would be one too many, until there's room.
	if code := c.errorCode(402, "POST", "/g/"+g.Token+"/expenses/"+first.Id+"/restore", nil); code != "plan_limit" {
		t.Fatal(code)
	}
	c.must(204, "DELETE", "/g/"+g.Token+"/expenses/"+second.Id, nil, nil)
	c.must(200, "POST", "/g/"+g.Token+"/expenses/"+first.Id+"/restore", nil, nil)
}

func TestRecurringLimit(t *testing.T) {
	c, _, s := billingServer(t)
	exec(t, s, `update plans set recurring_per_group = 1 where is_default`)
	register(c, "ana@example.test", "Ana")
	g := createGroup(c, "Ana")
	ana := g.Members[0].Id
	base := "/g/" + g.Token
	in := RecurringExpenseInput{
		Title: "Rent", Amount: "3.00", StartsAt: time.Now().Add(24 * time.Hour).UTC().Truncate(time.Second),
		Payers:      []PayerInput{{MemberId: ana, Amount: "3.00"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ana}},
		Repeat: Repeat{Unit: Month, Every: 1},
	}
	var r RecurringExpense
	c.must(201, "POST", base+"/recurring", in, &r)
	if code := c.errorCode(402, "POST", base+"/recurring", in); code != "plan_limit" {
		t.Fatal(code)
	}
	// Pausing doesn't make room, as it can carry on.
	c.must(200, "PATCH", base+"/recurring/"+r.Id, RecurringPause{Paused: true}, nil)
	c.errorCode(402, "POST", base+"/recurring", in)
	c.must(204, "DELETE", base+"/recurring/"+r.Id, nil, nil)
	c.must(201, "POST", base+"/recurring", in, nil)
}

func TestOwnGroupLimit(t *testing.T) {
	c, _, s := billingServer(t)
	exec(t, s, `update plans set own_groups = 1 where is_default`)
	u := register(c, "ana@example.test", "Ana")
	g := createGroup(c, "Ana")
	in := GroupCreate{Name: "More", Currency: "EUR", Members: []string{"Ana"}}
	if code := c.errorCode(402, "POST", "/groups", in); code != "plan_limit" {
		t.Fatal(code)
	}
	// An expired plan stops adding and leaves everything where it was.
	grant(t, s, u.Id, "plus")
	var second Group
	c.must(201, "POST", "/groups", in, &second)
	exec(t, s, `update entitlements set expires_at = now() - interval '1 second', starts_at = now() - interval '1 day'`)
	c.errorCode(402, "POST", "/groups", in)
	c.must(200, "GET", "/g/"+second.Token, nil, nil)
	if p := myPlanOf(c); p.Paid || p.OwnGroups.Used != 2 {
		t.Fatalf("%+v", p)
	}
	// Archiving makes room.
	c.must(204, "DELETE", "/g/"+g.Token, nil, nil)
	c.must(204, "DELETE", "/g/"+second.Token, nil, nil)
	c.must(201, "POST", "/groups", in, nil)
}

func TestSponsor(t *testing.T) {
	c, _, s := billingServer(t)
	exec(t, s, `update plans set receipts_per_group = 1 where is_default`)
	exec(t, s, `update plans set receipts_per_group = 2, sponsored_groups = 1 where id = 'plus'`)
	anaUser := register(c, "ana@example.test", "Ana")
	ben := c.another()
	benUser := register(ben, "ben@example.test", "Ben")
	var g, other Group
	c.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &g)
	c.must(201, "POST", "/groups", GroupCreate{Name: "Trip", Currency: "EUR", Members: []string{"Ana"}}, &other)
	base := "/g/" + g.Token
	ben.must(200, "POST", base+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)

	// Sponsoring takes a plan that does.
	if code := c.errorCode(402, "PUT", base+"/sponsor", nil); code != "plan_limit" {
		t.Fatal(code)
	}
	grant(t, s, anaUser.Id, "plus")
	var plan GroupPlan
	c.must(200, "GET", base+"/plan", nil, &plan)
	if !plan.CanSponsor || plan.PlanName != "Free" {
		t.Fatalf("%+v", plan)
	}
	c.must(200, "PUT", base+"/sponsor", nil, &plan)
	if plan.PlanName != "Plus" || plan.SponsorMemberId == nil || *plan.SponsorMemberId != g.Members[0].Id || *plan.Receipts.Limit != 2 {
		t.Fatalf("%+v", plan)
	}
	c.must(200, "PUT", base+"/sponsor", nil, nil) // doing it twice changes nothing

	// Its plan's room is used up, and someone else can't take it over.
	if code := c.errorCode(402, "PUT", "/g/"+other.Token+"/sponsor", nil); code != "plan_limit" {
		t.Fatal(code)
	}
	if p := myPlanOf(c); p.SponsoredGroups.Used != 1 {
		t.Fatalf("%+v", p)
	}
	grant(t, s, benUser.Id, "plus")
	if code := ben.errorCode(409, "PUT", base+"/sponsor", nil); code != "already_sponsored" {
		t.Fatal(code)
	}
	if code := ben.errorCode(403, "DELETE", base+"/sponsor", nil); code != "not_allowed" {
		t.Fatal(code)
	}

	// A sponsor without a plan stops counting, and another member can step in.
	exec(t, s, `update entitlements set revoked_at = now() where user_id = $1`, anaUser.Id)
	var lapsed GroupPlan
	ben.must(200, "GET", base+"/plan", nil, &lapsed)
	if lapsed.PlanName != "Free" || !lapsed.CanSponsor || lapsed.SponsorMemberId != nil {
		t.Fatalf("%+v", lapsed)
	}
	// To the one who stopped paying it stays theirs to stop.
	var own GroupPlan
	c.must(200, "GET", base+"/plan", nil, &own)
	if own.SponsorMemberId == nil || *own.SponsorMemberId != g.Members[0].Id {
		t.Fatalf("%+v", own)
	}
	ben.must(200, "PUT", base+"/sponsor", nil, &plan)
	if plan.SponsorMemberId == nil || *plan.SponsorMemberId != g.Members[1].Id {
		t.Fatalf("%+v", plan)
	}

	// Leaving ends it, without anything to clean up.
	var ended GroupPlan
	ben.must(200, "DELETE", base+"/sponsor", nil, &ended)
	if ended.SponsorMemberId != nil {
		t.Fatalf("%+v", ended)
	}
	ben.must(200, "PUT", base+"/sponsor", nil, nil)
	exec(t, s, `update members set left_at = now() where id = $1`, g.Members[1].Id)
	var left GroupPlan
	c.must(200, "GET", base+"/plan", nil, &left)
	if left.PlanName != "Free" || left.SponsorMemberId != nil {
		t.Fatalf("%+v", left)
	}
	if p := myPlanOf(ben); p.SponsoredGroups.Used != 0 {
		t.Fatalf("%+v", p)
	}
}

func TestKofiWebhookChecks(t *testing.T) {
	c, _, s := billingServer(t)
	if rec := c.kofi(map[string]any{"verification_token": "wrong"}); rec.Code != http.StatusForbidden {
		t.Fatalf("wrong token: %d", rec.Code)
	}
	if rec := c.kofi(map[string]any{"message_id": ""}); rec.Code != http.StatusBadRequest {
		t.Fatalf("no id: %d", rec.Code)
	}
	req := httptest.NewRequest("POST", kofiPath, strings.NewReader("data=nope"))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	rec := httptest.NewRecorder()
	c.h.ServeHTTP(rec, req)
	if rec.Code != http.StatusBadRequest {
		t.Fatalf("not JSON: %d", rec.Code)
	}
	// Only this path takes a form.
	req = httptest.NewRequest("POST", BasePath+"/me/plan", strings.NewReader("a=b"))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	rec = httptest.NewRecorder()
	c.h.ServeHTTP(rec, req)
	if rec.Code == http.StatusOK || !strings.Contains(rec.Body.String(), "not_json") {
		t.Fatalf("form elsewhere: %d %s", rec.Code, rec.Body)
	}
	var n int
	if err := s.db.QueryRow(context.Background(), `select count(*) from payment_events`).Scan(&n); err != nil || n != 0 {
		t.Fatal(n, err)
	}
}

func TestKofiPaymentsReachAccounts(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	u := register(c, "ana@example.test", "Ana")
	code := *myPlanOf(c).PaymentCode
	if !regexp.MustCompile(`^BAL-[2-9A-HJKMNP-TV-Z]{8}$`).MatchString(code) {
		t.Fatal(code)
	}
	if again := *myPlanOf(c).PaymentCode; again != code {
		t.Fatal(again, code)
	}

	// The code reaches the account whatever the address, however it's written,
	// and without the message being kept.
	c.kofiOK(map[string]any{"message_id": "a", "email": "payer@example.test", "amount": "3.00",
		"message": "thanks! " + strings.ToLower(strings.Replace(code, "-", "", 1)) + "."})
	if state, who := paymentState(t, s, "a"); state != "applied" || who == nil || *who != u.Id {
		t.Fatal(state, who)
	}
	p := myPlanOf(c)
	if !p.Paid || p.PlanName != "Plus" || p.ExpiresAt == nil {
		t.Fatalf("%+v", p)
	}

	// A repeat of a message counts once, and a one-off adds to what is left.
	before := *p.ExpiresAt
	c.kofiOK(map[string]any{"message_id": "b", "amount": "3.00", "message": code})
	c.kofiOK(map[string]any{"message_id": "b", "amount": "3.00", "message": code})
	p = myPlanOf(c)
	if d := p.ExpiresAt.Sub(before); d < 29*24*time.Hour || d > 31*24*time.Hour {
		t.Fatalf("added %v", d)
	}

	// Too little buys nothing, and a shop order isn't a plan, but they are kept.
	c.kofiOK(map[string]any{"message_id": "c", "amount": "2.99", "message": code})
	c.kofiOK(map[string]any{"message_id": "d", "type": "Shop Order", "amount": "50.00", "message": code})
	for _, id := range []string{"c", "d"} {
		if state, who := paymentState(t, s, id); state != "unmatched" || who == nil || *who != u.Id {
			t.Fatal(id, state, who)
		}
	}

	// Ko-fi documents a one-off tip as Tip, and its examples send Donation.
	c.kofiOK(map[string]any{"message_id": "e", "type": "Tip", "amount": "3.00", "message": code})
	if state, _ := paymentState(t, s, "e"); state != "applied" {
		t.Fatal(state)
	}

	// A code nobody has places nothing.
	c.kofiOK(map[string]any{"message_id": "f", "amount": "3.00", "message": "BAL-22222222"})
	if state, who := paymentState(t, s, "f"); state != "unclaimed" || who != nil {
		t.Fatal(state, who)
	}
}

func TestKofiNeverGoesByAccountEmail(t *testing.T) {
	c, f, s := billingServer(t)
	kofiProducts(t, s)
	u := register(c, "ana@example.test", "Ana")
	confirmEmail(c, f, "ana@example.test")
	c.kofiOK(map[string]any{"message_id": "a", "email": "ana@example.test", "amount": "10.00"})
	c.kofiOK(map[string]any{"message_id": "b", "email": "ana@example.test", "amount": "4.00", "is_subscription_payment": true})
	if p := myPlanOf(c); p.Paid {
		t.Fatalf("%+v", p)
	}

	// Nor does a one-off from an address the account took a payment from.
	exec(t, s, `insert into payment_emails (email, user_id) values ('ana@example.test', $1)`, u.Id)
	c.kofiOK(map[string]any{"message_id": "c", "email": "ana@example.test", "amount": "10.00"})
	if state, who := paymentState(t, s, "c"); state != "unclaimed" || who != nil {
		t.Fatal(state, who)
	}
}

func TestClaimPayment(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	u := register(c, "ana@example.test", "Ana")
	other := c.another()
	register(other, "ben@example.test", "Ben")
	const id = "0a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d"
	claim := func(reference string) PaymentClaim { return PaymentClaim{Reference: reference} }

	if code := c.errorCode(404, "POST", "/me/payments/claim", claim(id)); code != "payment_not_found" {
		t.Fatal(code)
	}
	c.kofiOK(map[string]any{"message_id": "a", "email": "payer@example.test", "amount": "3.00",
		"kofi_transaction_id": strings.ToUpper(id)})

	// The ID, or the link with it in, in any case.
	var p MyPlan
	c.must(200, "POST", "/me/payments/claim", claim("https://ko-fi.com/Home/CoffeeShop?txid="+strings.ToUpper(id)), &p)
	if !p.Paid || p.PlanName != "Plus" {
		t.Fatalf("%+v", p)
	}
	if state, who := paymentState(t, s, "a"); state != "applied" || who == nil || *who != u.Id {
		t.Fatal(state, who)
	}

	// Once, and only for one account.
	ends := *p.ExpiresAt
	c.must(200, "POST", "/me/payments/claim", claim(" "+id+"\n"), &p)
	if !p.ExpiresAt.Equal(ends) {
		t.Fatal(p.ExpiresAt, ends)
	}
	if code := other.errorCode(409, "POST", "/me/payments/claim", claim(id)); code != "payment_applied" {
		t.Fatal(code)
	}

	// A claim of a one-off teaches nothing about the address.
	c.kofiOK(map[string]any{"message_id": "b", "email": "payer@example.test", "amount": "3.00"})
	if state, _ := paymentState(t, s, "b"); state != "unclaimed" {
		t.Fatal(state)
	}

	// Nothing on sale matches: it's left for the administrator, who can see whose it is.
	const small = "1a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d"
	c.kofiOK(map[string]any{"message_id": "c", "amount": "1.00", "kofi_transaction_id": small})
	if code := c.errorCode(409, "POST", "/me/payments/claim", claim(small)); code != "payment_no_plan" {
		t.Fatal(code)
	}
	if state, who := paymentState(t, s, "c"); state != "unmatched" || who == nil || *who != u.Id {
		t.Fatal(state, who)
	}

	// Trying IDs is limited.
	for range claimBurst - 1 {
		other.errorCode(404, "POST", "/me/payments/claim", claim("nothing"))
	}
	if code := other.errorCode(429, "POST", "/me/payments/claim", claim("nothing")); code != "rate_limited" {
		t.Fatal(code)
	}
}

func TestClaimTakesTheSubscription(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	u := register(c, "ana@example.test", "Ana")
	subscription := func(id string) {
		c.kofiOK(map[string]any{"message_id": id, "type": "Subscription", "tier_name": "supporter", "amount": "4.00",
			"is_subscription_payment": true, "kofi_transaction_id": "tx-" + id})
	}
	// Claiming one payment brings the months that waited, and the months to come.
	subscription("a")
	subscription("b")
	c.must(200, "POST", "/me/payments/claim", PaymentClaim{Reference: "tx-a"}, nil)
	subscription("c")
	for _, id := range []string{"a", "b", "c"} {
		if state, who := paymentState(t, s, id); state != "applied" || who == nil || *who != u.Id {
			t.Fatal(id, state, who)
		}
	}
}

func TestPaymentCodeIn(t *testing.T) {
	const want = "BAL-ABCD2345"
	for _, message := range []string{
		"BAL-ABCD2345", "thanks! bal-abcd2345.", "BALABCD2345", "BAL ABCD2345", "BAL ABCD2345", "BAL–ABCD2345",
		"BAL—ABCD2345", "BAL－ABCD2345", "謝謝BAL-ABCD2345感謝",
	} {
		if got := paymentCodeIn(message); got == nil || *got != want {
			t.Errorf("%q: %v", message, got)
		}
	}
	for _, message := range []string{"", "bal mitzvahs", "global abcd2345", "BAL--ABCD2345", "BAL-ABCD23456", "BAL-ABCD234"} {
		if got := paymentCodeIn(message); got != nil {
			t.Errorf("%q: %v", message, *got)
		}
	}
}

func TestKofiSampleIsNotClaimable(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	register(c, "ana@example.test", "Ana")
	c.kofiOK(map[string]any{"message_id": "test", "amount": "3.00", "kofi_transaction_id": kofiSampleTransaction})
	if code := c.errorCode(404, "POST", "/me/payments/claim", PaymentClaim{Reference: kofiSampleTransaction}); code != "payment_not_found" {
		t.Fatal(code)
	}
	if state, who := paymentState(t, s, "test"); state != "unclaimed" || who != nil {
		t.Fatal(state, who)
	}
}

// kofiMonth posts a subscription payment. Fields overrule its defaults.
func (c *client) kofiMonth(id string, fields map[string]any) {
	c.t.Helper()
	ev := map[string]any{"message_id": id, "type": "Subscription", "tier_name": "supporter", "amount": "4.00",
		"is_subscription_payment": true, "kofi_transaction_id": "tx-" + id}
	for k, v := range fields {
		ev[k] = v
	}
	c.kofiOK(ev)
}

func TestGiftLeavesTheSubscriptionAlone(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	ana := register(c, "ana@example.test", "Ana")
	code := *myPlanOf(c).PaymentCode
	other := c.another()
	ben := register(other, "ben@example.test", "Ben")
	gift := *myPlanOf(other).PaymentCode
	owner := func(id, want string) {
		t.Helper()
		if state, who := paymentState(t, s, id); state != "applied" || who == nil || *who != want {
			t.Fatal(id, state, who)
		}
	}

	c.kofiMonth("own", map[string]any{"message": code})
	c.kofiMonth("gift", map[string]any{"message": gift})
	c.kofiMonth("next", nil)
	owner("gift", ben.Id)
	owner("next", ana.Id)

	// With nothing running there, a code moves the address.
	exec(t, s, `update entitlements set expires_at = now() - interval '1 day' where user_id = $1`, ana.Id)
	c.kofiMonth("moved", map[string]any{"message": gift})
	c.kofiMonth("after", nil)
	owner("after", ben.Id)
}

func TestNamingTheAccountBringsWhatWaited(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	u := register(c, "ana@example.test", "Ana")
	code := *myPlanOf(c).PaymentCode
	owned := func(id string) {
		t.Helper()
		if state, who := paymentState(t, s, id); state != "applied" || who == nil || *who != u.Id {
			t.Fatal(id, state, who)
		}
	}

	c.kofiMonth("a", nil)
	c.kofiMonth("b", map[string]any{"message": code})
	owned("a")
	owned("b")

	// So does claiming a payment that bought nothing, from another address.
	c.kofiMonth("c", map[string]any{"email": "second@example.test"})
	c.kofiMonth("d", map[string]any{"email": "second@example.test", "tier_name": "Unknown", "amount": "1.00"})
	if code := c.errorCode(409, "POST", "/me/payments/claim", PaymentClaim{Reference: "tx-d"}); code != "payment_no_plan" {
		t.Fatal(code)
	}
	owned("c")
}

func TestLateClaimGivesTheTimePaidFor(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	register(c, "ana@example.test", "Ana")
	long := func(days int) string { return time.Now().AddDate(0, 0, -days).UTC().Format(time.RFC3339) }

	// Its 35 days ended while it waited, and those that also did add nothing more.
	c.kofiMonth("old", map[string]any{"timestamp": long(90)})
	c.kofiMonth("older", map[string]any{"timestamp": long(120)})
	var p MyPlan
	c.must(200, "POST", "/me/payments/claim", PaymentClaim{Reference: "tx-old"}, &p)
	want := time.Now().Add(35 * 24 * time.Hour)
	if !p.Paid || p.ExpiresAt == nil || p.ExpiresAt.Sub(want).Abs() > time.Minute {
		t.Fatalf("%+v", p)
	}

	// One still running keeps its date.
	before := *p.ExpiresAt
	c.kofiMonth("recent", map[string]any{"timestamp": long(10), "email": "second@example.test"})
	c.must(200, "POST", "/me/payments/claim", PaymentClaim{Reference: "tx-recent"}, &p)
	if !p.ExpiresAt.Equal(before) {
		t.Fatal(p.ExpiresAt, before)
	}
}

func TestClaimLeavesAnotherAccountsPaymentAlone(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	u := register(c, "ana@example.test", "Ana")
	other := c.another()
	register(other, "ben@example.test", "Ben")

	c.kofiMonth("a", map[string]any{"tier_name": "Unknown", "amount": "1.00"})
	if code := c.errorCode(409, "POST", "/me/payments/claim", PaymentClaim{Reference: "tx-a"}); code != "payment_no_plan" {
		t.Fatal(code)
	}
	if code := other.errorCode(409, "POST", "/me/payments/claim", PaymentClaim{Reference: "tx-a"}); code != "payment_applied" {
		t.Fatal(code)
	}
	c.kofiMonth("b", nil)
	if state, who := paymentState(t, s, "b"); state != "applied" || who == nil || *who != u.Id {
		t.Fatal(state, who)
	}
}

func TestPaymentCodeNeedsKofi(t *testing.T) {
	c := accountsClient(t, map[string]string{"BALNANA_BILLING_ENABLED": "true"})
	register(c, "ana@example.test", "Ana")
	if p := myPlanOf(c); p.PaymentCode != nil {
		t.Fatalf("%+v", p)
	}
}

func TestKofiPaymentOutlivesItsPlan(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	c.kofiOK(map[string]any{"message_id": "early", "amount": "10.00", "kofi_transaction_id": "tx"})
	exec(t, s, `delete from plan_products`)
	exec(t, s, `delete from plans where id = 'plus'`)

	// It gives nothing, and doesn't stand in the way of the account.
	u := register(c, "ana@example.test", "Ana")
	if code := c.errorCode(409, "POST", "/me/payments/claim", PaymentClaim{Reference: "tx"}); code != "payment_no_plan" {
		t.Fatal(code)
	}
	if p := myPlanOf(c); p.Paid {
		t.Fatalf("%+v", p)
	}
	if state, who := paymentState(t, s, "early"); state != "unclaimed" || who == nil || *who != u.Id {
		t.Fatal(state, who)
	}
}

func TestDeletingAPlanShowsItsWaitingPayments(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{
		"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true", "BALNANA_KOFI_TOKEN": kofiTestToken,
	})
	admin := c.asAdmin(setUp(c))
	kofiProducts(t, s)
	c.kofiOK(map[string]any{"message_id": "early", "amount": "10.00"})
	var catalog PlanCatalog
	admin.must(200, "GET", "/admin/plans", nil, &catalog)
	kept := catalog
	kept.Plans = slices.DeleteFunc(slices.Clone(catalog.Plans), func(p Plan) bool { return p.Id == "plus" })
	kept.Products = []PlanProduct{}
	admin.must(200, "PUT", "/admin/plans", kept, nil)
	if state, _ := paymentState(t, s, "early"); state != "unmatched" {
		t.Fatal(state)
	}
}

func TestKofiMembershipRenews(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	register(c, "ana@example.test", "Ana")
	code := *myPlanOf(c).PaymentCode

	subscription := func(id string, paid time.Time, message string) {
		c.kofiOK(map[string]any{"message_id": id, "type": "Subscription", "email": "PAYER@example.test", "tier_name": "supporter",
			"amount": "4.00", "is_subscription_payment": true, "timestamp": paid.Format(time.RFC3339), "message": message})
	}
	month := func(id string, paid time.Time) { subscription(id, paid, "") }
	start := time.Now().Add(-40 * 24 * time.Hour).UTC().Truncate(time.Second)
	// The first payment names the account; the ones after it have no message.
	subscription("late", time.Now().Add(-10*24*time.Hour).UTC().Truncate(time.Second), code)
	p := myPlanOf(c)
	want := time.Now().Add(25 * 24 * time.Hour)
	if !p.Paid || p.ExpiresAt == nil || p.ExpiresAt.Sub(want).Abs() > time.Minute {
		t.Fatalf("%+v", p)
	}
	// A renewal runs from its payment: an old one doesn't shorten or stack.
	before := *p.ExpiresAt
	month("old", start)
	if p := myPlanOf(c); !p.ExpiresAt.Equal(before) {
		t.Fatalf("%v, want %v", p.ExpiresAt, before)
	}
	month("now", time.Now().UTC().Truncate(time.Second))
	want = time.Now().Add(35 * 24 * time.Hour)
	if p := myPlanOf(c); p.ExpiresAt.Sub(want).Abs() > time.Minute {
		t.Fatalf("%v, want %v", p.ExpiresAt, want)
	}
	var n int
	if err := s.db.QueryRow(context.Background(), `select count(*) from entitlements`).Scan(&n); err != nil || n != 1 {
		t.Fatal(n, err)
	}
}

func TestAdminPlans(t *testing.T) {
	c, _, _ := adminClient(t, map[string]string{"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true"})
	admin := c.asAdmin(setUp(c))
	var catalog PlanCatalog
	admin.must(200, "GET", "/admin/plans", nil, &catalog)
	if len(catalog.Plans) != 2 {
		t.Fatalf("%+v", catalog)
	}
	bad := catalog
	bad.Plans = []Plan{catalog.Plans[0], catalog.Plans[1]}
	bad.Plans[0].IsDefault, bad.Plans[1].IsDefault = true, true
	if code := admin.errorCode(400, "PUT", "/admin/plans", bad); code != "invalid_plan" {
		t.Fatal(code)
	}
	gold := Plan{Id: "gold", Name: "Gold", Rank: 20}
	catalog.Plans = append(catalog.Plans, gold)
	catalog.Products = []PlanProduct{{Provider: Kofi, Product: "Gold tier", PlanId: "gold", Days: 35}}
	admin.must(200, "PUT", "/admin/plans", catalog, &catalog)
	if len(catalog.Plans) != 3 || len(catalog.Products) != 1 {
		t.Fatalf("%+v", catalog)
	}
	// No name needs an amount to go by.
	withEmpty := catalog
	withEmpty.Products = []PlanProduct{{Provider: Kofi, PlanId: "gold", Days: 35}}
	admin.errorCode(400, "PUT", "/admin/plans", withEmpty)
	// However the amount is written, it is the same product.
	repeated := catalog
	repeated.Products = []PlanProduct{
		{Provider: Kofi, PlanId: "gold", Days: 35, MinAmount: ptr("3"), Currency: ptr("USD")},
		{Provider: Kofi, PlanId: "gold", Days: 35, MinAmount: ptr("3.00"), Currency: ptr("USD")},
	}
	if code := admin.errorCode(400, "PUT", "/admin/plans", repeated); code != "invalid_plan" {
		t.Fatal(code)
	}
	admin.must(200, "GET", "/admin/plans", nil, &catalog)
	if len(catalog.Products) != 1 {
		t.Fatalf("a refused change must change nothing: %+v", catalog)
	}

	// A plan someone has stays until they don't.
	u := register(c, "ana@example.test", "Ana")
	var e Entitlement
	admin.must(201, "POST", "/admin/users/"+u.Id+"/entitlements", EntitlementGrant{PlanId: "gold", Days: ptr(30), Note: ptr("  thanks ")}, &e)
	if e.PlanName != "Gold" || e.ExpiresAt == nil || e.Note == nil || *e.Note != "thanks" {
		t.Fatalf("%+v", e)
	}
	var users AdminUserList
	admin.must(200, "GET", "/admin/users", nil, &users)
	if users.Users[0].PlanName == nil || *users.Users[0].PlanName != "Gold" {
		t.Fatalf("%+v", users.Users[0])
	}
	without := catalog
	without.Plans = catalog.Plans[:2]
	without.Products = []PlanProduct{}
	if code := admin.errorCode(409, "PUT", "/admin/plans", without); code != "plan_in_use" {
		t.Fatal(code)
	}
	admin.must(200, "GET", "/admin/plans", nil, &catalog)
	if len(catalog.Plans) != 3 || len(catalog.Products) != 1 {
		t.Fatalf("a refused change must change nothing: %+v", catalog)
	}
	admin.must(204, "DELETE", "/admin/entitlements/"+e.Id, nil, nil)
	if p := myPlanOf(c); p.Paid {
		t.Fatalf("%+v", p)
	}
}

func TestAdminAssignsPayment(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{
		"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true", "BALNANA_KOFI_TOKEN": kofiTestToken,
	})
	admin := c.asAdmin(setUp(c))
	u := register(c, "ana@example.test", "Ana")
	c.kofiOK(map[string]any{"message_id": "a", "email": "other@example.test", "from_name": "Ana's dad"})
	c.kofiOK(map[string]any{"message_id": "b", "email": "other@example.test", "is_subscription_payment": true,
		"kofi_transaction_id": "tx"})
	var list PaymentList
	admin.must(200, "GET", "/admin/payments?state=unmatched", nil, &list)
	if list.Total != 2 || len(list.Payments) != 2 || list.Payments[0].Reference == nil || *list.Payments[0].Reference != "tx" {
		t.Fatalf("%+v", list)
	}
	id := list.Payments[0].Id
	in := PaymentAssign{UserId: u.Id}
	if code := admin.errorCode(400, "POST", "/admin/payments/"+id+"/assign", in); code != "invalid_plan" {
		t.Fatal(code)
	}
	in.PlanId, in.Days = ptr("plus"), ptr(30)
	var p Payment
	admin.must(200, "POST", "/admin/payments/"+id+"/assign", in, &p)
	if p.State != "applied" || p.UserId == nil || *p.UserId != u.Id || p.UserName == nil {
		t.Fatalf("%+v", p)
	}
	if code := admin.errorCode(409, "POST", "/admin/payments/"+id+"/assign", in); code != "payment_applied" {
		t.Fatal(code)
	}
	if m := myPlanOf(c); !m.Paid {
		t.Fatalf("%+v", m)
	}
	// A subscription's address is remembered for what comes next.
	c.kofiOK(map[string]any{"message_id": "c", "email": "other@example.test", "is_subscription_payment": true})
	if state, who := paymentState(t, s, "c"); state != "unmatched" || who == nil {
		t.Fatal(state, who)
	}
}

func TestDeletedAccountKeepsPayments(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	register(c, "ana@example.test", "Ana")
	c.kofiOK(map[string]any{"message_id": "a", "amount": "9.00", "message": *myPlanOf(c).PaymentCode})
	c.must(204, "POST", "/me/delete", AccountDelete{Password: ptr("correct horse")}, nil)
	state, who := paymentState(t, s, "a")
	if state != "applied" || who != nil {
		t.Fatal(state, who)
	}
}
