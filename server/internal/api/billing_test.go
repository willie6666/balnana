package api

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"net/url"
	"slices"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
)

const kofiTestToken = "kofi-secret"

// billingServer is a charging server with email and a Ko-fi connection.
func billingServer(t *testing.T) (*client, fakeMail, *Server) {
	t.Helper()
	return mailServer(t, map[string]string{
		"BALNANA_BILLING_ENABLED": "true",
		"BALNANA_KOFI_TOKEN":      kofiTestToken,
		"BALNANA_KOFI_URL":        "https://ko-fi.com/balnana",
		"BALNANA_PUBLIC_URL":      "https://balnana.test/",
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

// kofiProducts sells the plus plan: 90 and 360 days by shop item, 30 for a
// tip of 3 USD or more.
func kofiProducts(t *testing.T, s *Server) {
	t.Helper()
	exec(t, s, `insert into plan_products (provider, product, plan_id, days) values ('kofi', 'plus90', 'plus', 90), ('kofi', 'plus360', 'plus', 360)`)
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
	c, f, s := billingServer(t)
	if info := serverInfo(c); info.Billing == nil || info.Billing.KofiUrl == nil || *info.Billing.KofiUrl != "https://ko-fi.com/balnana" {
		t.Fatalf("%+v", info.Billing)
	}
	u := register(c, "ana@example.test", "Ana")
	confirmEmail(c, f, "ana@example.test")
	p := myPlanOf(c)
	if p.PlanName != "Free" || p.Paid || p.ExpiresAt != nil || p.JoinedGroups.Used != 0 ||
		p.JoinedGroups.Limit == nil || *p.JoinedGroups.Limit != 10 || p.MembersPerGroup == nil || *p.MembersPerGroup != 15 {
		t.Fatalf("%+v", p)
	}
	grant(t, s, u.Id, "plus")
	if p := myPlanOf(c); p.PlanName != "Plus" || !p.Paid ||
		p.JoinedGroups.Limit == nil || *p.JoinedGroups.Limit != 50 || p.MembersPerGroup == nil || *p.MembersPerGroup != 100 {
		t.Fatalf("%+v", p)
	}
}

func TestReceiptLimit(t *testing.T) {
	c, f, s := billingServer(t)
	exec(t, s, `update plans set receipts_per_group = 1 where is_default`)
	register(c, "ana@example.test", "Ana")
	confirmEmail(c, f, "ana@example.test")
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
	// A deleted expense keeps its photo, and the photo its place: otherwise
	// deleting and restoring would go past the limit for free.
	c.must(204, "DELETE", "/g/"+g.Token+"/expenses/"+first.Id, nil, nil)
	if rec := c.upload(path(second), "image/png", photo); rec.Code != http.StatusPaymentRequired {
		t.Fatalf("%d %s", rec.Code, rec.Body)
	}
	var plan GroupPlan
	c.must(200, "GET", "/g/"+g.Token+"/plan", nil, &plan)
	if plan.Receipts.Used != 1 || *plan.Receipts.Limit != 1 {
		t.Fatalf("%+v", plan)
	}
	if rec := c.do("GET", "/g/"+g.Token+"/expenses/"+first.Id+"/receipt", nil); rec.Code != http.StatusNotFound {
		t.Fatalf("a deleted expense's photo: %d", rec.Code)
	}
	var back Expense
	c.must(200, "POST", "/g/"+g.Token+"/expenses/"+first.Id+"/restore", nil, &back)
	if !back.HasReceipt {
		t.Fatal("the photo stays with the expense")
	}

	// Once the photo is gone for good there is room again.
	c.must(204, "DELETE", "/g/"+g.Token+"/expenses/"+first.Id, nil, nil)
	if _, err := s.sweepExpired(context.Background()); err != nil {
		t.Fatal(err)
	}
	if rec := c.upload(path(second), "image/png", photo); rec.Code != http.StatusPaymentRequired {
		t.Fatalf("too soon: %d %s", rec.Code, rec.Body)
	}
	exec(t, s, `update expenses set deleted_at = $2 where id = $1`, first.Id, time.Now().Add(-receiptKeep-time.Hour))
	if _, err := s.sweepExpired(context.Background()); err != nil {
		t.Fatal(err)
	}
	if rec := c.upload(path(second), "image/png", photo); rec.Code != http.StatusOK {
		t.Fatalf("%d %s", rec.Code, rec.Body)
	}
	c.must(200, "POST", "/g/"+g.Token+"/expenses/"+first.Id+"/restore", nil, &back)
	if back.HasReceipt {
		t.Fatal("the photo was swept")
	}
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

func TestJoinedGroupLimit(t *testing.T) {
	c, f, s := billingServer(t)
	exec(t, s, `update plans set joined_groups = 1 where is_default`)
	u := register(c, "ana@example.test", "Ana")
	confirmEmail(c, f, "ana@example.test")
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
	if p := myPlanOf(c); p.Paid || p.JoinedGroups.Used != 2 {
		t.Fatalf("%+v", p)
	}
	// Archiving makes room.
	c.must(204, "DELETE", "/g/"+g.Token, nil, nil)
	c.must(204, "DELETE", "/g/"+second.Token, nil, nil)
	c.must(201, "POST", "/groups", in, nil)
}

func TestSponsor(t *testing.T) {
	c, f, s := billingServer(t)
	exec(t, s, `update plans set receipts_per_group = 1 where is_default`)
	exec(t, s, `update plans set receipts_per_group = 2, sponsored_groups = 1 where id = 'plus'`)
	anaUser := register(c, "ana@example.test", "Ana")
	confirmEmail(c, f, "ana@example.test")
	ben := c.another()
	benUser := register(ben, "ben@example.test", "Ben")
	confirmEmail(ben, f, "ben@example.test")
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

	// A member gone without the sponsor being cleared counts for nothing.
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

func TestKofiPaymentsWaitForClaims(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	u := register(c, "ana@example.test", "Ana")
	claim := func(tx string) MyPlan {
		t.Helper()
		var p MyPlan
		c.must(200, "POST", "/me/payments/claim", PaymentClaim{Reference: tx}, &p)
		return p
	}

	// Nothing reaches an account by itself, whatever the message or address.
	c.kofiOK(map[string]any{"message_id": "a", "type": kofiShopOrder, "amount": "3.00", "message": "for ana@example.test",
		"shop_items": []map[string]any{{"direct_link_code": "plus90", "quantity": 1}}, "kofi_transaction_id": "tx-a"})
	if state, who := paymentState(t, s, "a"); state != "unclaimed" || who != nil {
		t.Fatal(state, who)
	}
	if p := myPlanOf(c); p.Paid {
		t.Fatalf("%+v", p)
	}
	p := claim("tx-a")
	want := time.Now().AddDate(0, 0, 90)
	if !p.Paid || p.PlanName != "Plus" || p.ExpiresAt == nil || p.ExpiresAt.Sub(want).Abs() > time.Minute {
		t.Fatalf("%+v", p)
	}
	if state, who := paymentState(t, s, "a"); state != "applied" || who == nil || *who != u.Id {
		t.Fatal(state, who)
	}

	// A repeat of a message counts once, and the next payment adds to what is left.
	for range 2 {
		c.kofiOK(map[string]any{"message_id": "b", "type": kofiShopOrder, "amount": "10.00",
			"shop_items": []map[string]any{{"direct_link_code": "PLUS360", "quantity": 1}}, "kofi_transaction_id": "tx-b"})
	}
	before := *p.ExpiresAt
	p = claim("tx-b")
	if d := p.ExpiresAt.Sub(before); d != 360*24*time.Hour {
		t.Fatalf("added %v", d)
	}

	// Two of an item buy twice the time.
	c.kofiOK(map[string]any{"message_id": "c", "type": kofiShopOrder, "amount": "6.00",
		"shop_items": []map[string]any{{"direct_link_code": "plus90", "quantity": 2}}, "kofi_transaction_id": "tx-c"})
	before = *p.ExpiresAt
	if d := claim("tx-c").ExpiresAt.Sub(before); d != 180*24*time.Hour {
		t.Fatalf("added %v", d)
	}

	// Too little buys nothing, nor does an item not on sale, but they are kept.
	c.kofiOK(map[string]any{"message_id": "d", "amount": "2.99"})
	c.kofiOK(map[string]any{"message_id": "e", "type": kofiShopOrder, "amount": "50.00",
		"shop_items": []map[string]any{{"direct_link_code": "sticker", "quantity": 1}}})
	for _, id := range []string{"d", "e"} {
		if state, who := paymentState(t, s, id); state != "unmatched" || who != nil {
			t.Fatal(id, state, who)
		}
	}

	// Ko-fi documents a one-off tip as Tip, and its examples send Donation.
	c.kofiOK(map[string]any{"message_id": "f", "type": "Tip", "amount": "3.00"})
	if state, _ := paymentState(t, s, "f"); state != "unclaimed" {
		t.Fatal(state)
	}
	// A membership buys nothing by itself.
	c.kofiOK(map[string]any{"message_id": "g", "type": "Subscription", "tier_name": "plus90", "amount": "4.00",
		"is_subscription_payment": true})
	if state, _ := paymentState(t, s, "g"); state != "unmatched" {
		t.Fatal(state)
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
	c.kofiOK(map[string]any{"message_id": "a", "amount": "3.00", "kofi_transaction_id": strings.ToUpper(id)})

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

	// Nothing on sale matches: it's left for the administrator, who can see whose it is.
	const small = "1a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d"
	c.kofiOK(map[string]any{"message_id": "c", "amount": "1.00", "kofi_transaction_id": small})
	if code := c.errorCode(409, "POST", "/me/payments/claim", claim(small)); code != "payment_no_plan" {
		t.Fatal(code)
	}
	if state, who := paymentState(t, s, "c"); state != "unmatched" || who == nil || *who != u.Id {
		t.Fatal(state, who)
	}
	if code := other.errorCode(409, "POST", "/me/payments/claim", claim(small)); code != "payment_applied" {
		t.Fatal(code)
	}

	// Trying IDs is limited, counting the two above.
	for range claimBurst - 2 {
		other.errorCode(404, "POST", "/me/payments/claim", claim("nothing"))
	}
	if code := other.errorCode(429, "POST", "/me/payments/claim", claim("nothing")); code != "rate_limited" {
		t.Fatal(code)
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

// A claim long after the payment gives all the time it bought, from now.
func TestLateClaimGivesTheTimePaidFor(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	register(c, "ana@example.test", "Ana")
	long := time.Now().AddDate(0, 0, -120).UTC().Format(time.RFC3339)
	c.kofiOK(map[string]any{"message_id": "old", "type": kofiShopOrder, "amount": "3.00", "timestamp": long,
		"shop_items": []map[string]any{{"direct_link_code": "plus90", "quantity": 1}}, "kofi_transaction_id": "tx-old"})
	var p MyPlan
	c.must(200, "POST", "/me/payments/claim", PaymentClaim{Reference: "tx-old"}, &p)
	want := time.Now().AddDate(0, 0, 90)
	if !p.Paid || p.ExpiresAt == nil || p.ExpiresAt.Sub(want).Abs() > time.Minute {
		t.Fatalf("%+v", p)
	}
}

func TestKofiItemCode(t *testing.T) {
	for in, want := range map[string]string{
		"A1B2C3": "A1B2C3", " https://ko-fi.com/s/A1B2C3 ": "A1B2C3", "ko-fi.com/s/A1B2C3/?ref=x": "A1B2C3",
		"Supporter": "Supporter",
	} {
		if got := kofiItemCode(in); got != want {
			t.Errorf("%q: %q", in, got)
		}
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
		"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true", "BALNANA_PUBLIC_URL": "https://balnana.test/",
		"BALNANA_KOFI_TOKEN": kofiTestToken, "BALNANA_KOFI_URL": "https://ko-fi.com/balnana",
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

func TestAdminPlans(t *testing.T) {
	c, _, _ := adminClient(t, map[string]string{"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true"})
	admin := c.asAdmin(setUp(c))
	var catalog PlanCatalog
	admin.must(200, "GET", "/admin/plans", nil, &catalog)
	if len(catalog.Plans) != 3 {
		t.Fatalf("%+v", catalog)
	}
	bad := catalog
	bad.Plans = []Plan{catalog.Plans[0], catalog.Plans[1]}
	bad.Plans[0].IsDefault, bad.Plans[1].IsDefault = true, true
	if code := admin.errorCode(400, "PUT", "/admin/plans", bad); code != "invalid_plan" {
		t.Fatal(code)
	}
	gold := Plan{Id: "gold", Name: "Gold", Rank: 20, Limits: PlanLimits{Reminders: ptr(true)}}
	catalog.Plans = append(catalog.Plans, gold)
	catalog.Products = []PlanProduct{{Provider: Kofi, Product: "Gold tier", PlanId: "gold", Days: 35}}
	admin.must(200, "PUT", "/admin/plans", catalog, &catalog)
	if len(catalog.Plans) != 4 || len(catalog.Products) != 1 || catalog.Plans[3].Limits.Reminders == nil ||
		!*catalog.Plans[3].Limits.Reminders || *catalog.Plans[0].Limits.Reminders {
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
	without.Plans = catalog.Plans[:3]
	without.Products = []PlanProduct{}
	if code := admin.errorCode(409, "PUT", "/admin/plans", without); code != "plan_in_use" {
		t.Fatal(code)
	}
	admin.must(200, "GET", "/admin/plans", nil, &catalog)
	if len(catalog.Plans) != 4 || len(catalog.Products) != 1 {
		t.Fatalf("a refused change must change nothing: %+v", catalog)
	}
	admin.must(204, "DELETE", "/admin/entitlements/"+e.Id, nil, nil)
	if p := myPlanOf(c); p.Paid {
		t.Fatalf("%+v", p)
	}
}

func TestAdminAssignsPayment(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{
		"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true", "BALNANA_PUBLIC_URL": "https://balnana.test/",
		"BALNANA_KOFI_TOKEN": kofiTestToken, "BALNANA_KOFI_URL": "https://ko-fi.com/balnana",
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
	// A refunded payment gives nothing.
	exec(t, s, `update payment_events set state = 'refunded' where id = $1`, list.Payments[1].Id)
	if code := admin.errorCode(409, "POST", "/admin/payments/"+list.Payments[1].Id+"/assign", in); code != "payment_refunded" {
		t.Fatal(code)
	}
}

func TestDeletedAccountKeepsPayments(t *testing.T) {
	c, _, s := billingServer(t)
	kofiProducts(t, s)
	register(c, "ana@example.test", "Ana")
	c.kofiOK(map[string]any{"message_id": "a", "amount": "9.00", "kofi_transaction_id": "tx-a"})
	c.must(200, "POST", "/me/payments/claim", PaymentClaim{Reference: "tx-a"}, nil)
	c.must(204, "POST", "/me/delete", AccountDelete{Password: ptr("correct horse")}, nil)
	state, who := paymentState(t, s, "a")
	if state != "applied" || who != nil {
		t.Fatal(state, who)
	}
}

// Leaving a group ends sponsoring it for good: coming back by the link would
// otherwise pay for it again past the plan's limit.
func TestSponsorDoesNotComeBackWithItsMember(t *testing.T) {
	c, _, s := billingServer(t)
	register(c, "ana@example.test", "Ana")
	ben := c.another()
	bu := register(ben, "ben@example.test", "Ben")
	grant(t, s, bu.Id, "plus")
	var g Group
	c.must(201, "POST", "/groups", GroupCreate{Name: "Trip", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &g)
	base := "/g/" + g.Token
	ben.must(200, "POST", base+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)
	ben.must(200, "PUT", base+"/sponsor", nil, nil)

	ben.must(204, "DELETE", base+"/members/"+g.Members[1].Id, nil, nil)
	ben.must(200, "POST", base+"/join", JoinInput{}, nil)
	var plan GroupPlan
	c.must(200, "GET", base+"/plan", nil, &plan)
	if plan.PlanName != "Free" || plan.SponsorMemberId != nil {
		t.Fatalf("%+v", plan)
	}
	if p := myPlanOf(ben); p.SponsoredGroups.Used != 0 {
		t.Fatalf("%+v", p)
	}
}

// Taking over a group nobody with an account is left in makes the joiner its
// owner, which counts against their plan as creating one does.
func TestJoiningAnEmptyGroupCountsAsOwningIt(t *testing.T) {
	c, f, s := billingServer(t)
	register(c, "ana@example.test", "Ana")
	var g Group
	c.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &g)
	path := "/g/" + g.Token
	c.must(204, "DELETE", path+"/members/"+g.Members[0].Id, nil, nil)

	exec(t, s, `update plans set joined_groups = 1 where is_default`)
	ben := c.another()
	register(ben, "ben@example.test", "Ben")
	confirmEmail(ben, f, "ben@example.test")
	ben.must(201, "POST", "/groups", GroupCreate{Name: "Mine", Currency: "EUR", Members: []string{"Ben"}}, nil)
	if code := ben.errorCode(402, "POST", path+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}); code != "plan_limit" {
		t.Fatalf("code %q", code)
	}

	// Below the limit it joins, and owns it.
	exec(t, s, `update plans set joined_groups = 2 where is_default`)
	ben.must(200, "POST", path+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)
	if p := myPlanOf(ben); p.JoinedGroups.Used != 2 {
		t.Fatalf("%+v", p)
	}
}

// Every way into a group counts, not only making one, and leaving makes room.
func TestJoinedGroupsCountEveryWayIn(t *testing.T) {
	c, f, s := billingServer(t)
	register(c, "ana@example.test", "Ana")
	var claim, plain Group
	c.must(201, "POST", "/groups", GroupCreate{Name: "Claim", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &claim)
	c.must(201, "POST", "/groups", GroupCreate{Name: "Plain", Currency: "EUR", Members: []string{"Ana"}}, &plain)
	full := func(b *client, path string, in JoinInput) {
		t.Helper()
		var refused struct {
			Code   string         `json:"code"`
			Params map[string]any `json:"params"`
		}
		b.must(402, "POST", path, in, &refused)
		if refused.Code != "plan_limit" || refused.Params["limit"] != "joined_groups" {
			t.Fatalf("%+v", refused)
		}
	}

	exec(t, s, `update plans set joined_groups = 1 where is_default`)
	ben := c.another()
	register(ben, "ben@example.test", "Ben")
	confirmEmail(ben, f, "ben@example.test")
	ben.must(201, "POST", "/groups", GroupCreate{Name: "Mine", Currency: "EUR", Members: []string{"Ben"}}, nil)
	full(ben, "/g/"+plain.Token+"/join", JoinInput{})
	full(ben, "/g/"+claim.Token+"/join", JoinInput{ClaimMemberId: &claim.Members[1].Id})

	exec(t, s, `update plans set joined_groups = 2 where is_default`)
	var joined Group
	ben.must(200, "POST", "/g/"+plain.Token+"/join", JoinInput{}, &joined)
	if p := myPlanOf(ben); p.JoinedGroups.Used != 2 {
		t.Fatalf("%+v", p)
	}
	// Someone over a lowered limit keeps their groups and can still open them,
	// but what they left doesn't come back.
	exec(t, s, `update plans set joined_groups = 1 where is_default`)
	ben.must(200, "POST", "/g/"+plain.Token+"/join", JoinInput{}, nil) // already in
	ben.must(200, "GET", "/g/"+plain.Token, nil, nil)
	var me string
	for _, m := range joined.Members {
		if m.Name == "Ben" {
			me = m.Id
		}
	}
	ben.must(204, "DELETE", "/g/"+plain.Token+"/members/"+me, nil, nil)
	full(ben, "/g/"+plain.Token+"/join", JoinInput{})
	if p := myPlanOf(ben); p.JoinedGroups.Used != 1 {
		t.Fatalf("%+v", p)
	}
}

func TestMemberLimit(t *testing.T) {
	c, _, s := billingServer(t)
	exec(t, s, `update plans set members_per_group = 2 where is_default`)
	exec(t, s, `update plans set members_per_group = 4 where id = 'plus'`)
	u := register(c, "ana@example.test", "Ana")
	limited := func(b *client, want string, max float64, method, path string, in any) {
		t.Helper()
		var refused struct {
			Code   string         `json:"code"`
			Params map[string]any `json:"params"`
		}
		b.must(402, method, path, in, &refused)
		if refused.Code != "plan_limit" || refused.Params["limit"] != want || refused.Params["max"] != max {
			t.Fatalf("%+v", refused)
		}
	}
	three := GroupCreate{Name: "Trip", Currency: "EUR", Members: []string{"Ana", "Ben", "Cy"}}
	limited(c, "members", 2, "POST", "/groups", three)

	var g Group
	c.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &g)
	path := "/g/" + g.Token
	limited(c, "members", 2, "POST", path+"/members", MemberInput{Name: "Cy"})
	var gp GroupPlan
	c.must(200, "GET", path+"/plan", nil, &gp)
	if gp.Members.Used != 2 || gp.Members.Limit == nil || *gp.Members.Limit != 2 {
		t.Fatalf("%+v", gp)
	}

	// A place held by a name is taken: claiming it adds nobody, joining would.
	ben := c.another()
	register(ben, "ben@example.test", "Ben")
	ben.must(200, "POST", path+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)
	cy := c.another()
	register(cy, "cy@example.test", "Cy")
	limited(cy, "members", 2, "POST", path+"/join", JoinInput{})

	// Someone leaving makes room, and someone coming back takes it again.
	ben.must(204, "DELETE", path+"/members/"+g.Members[1].Id, nil, nil)
	c.must(201, "POST", path+"/members", MemberInput{Name: "Cy"}, nil)
	limited(ben, "members", 2, "POST", path+"/join", JoinInput{})

	// A sponsor's plan is the group's.
	grant(t, s, u.Id, "plus")
	c.must(200, "PUT", path+"/sponsor", nil, nil)
	c.must(201, "POST", path+"/members", MemberInput{Name: "Dee"}, nil)
	c.must(201, "POST", path+"/members", MemberInput{Name: "Eli"}, nil)
	limited(c, "members", 4, "POST", path+"/members", MemberInput{Name: "Flo"})

	// Past the limit again, it keeps everyone and only adding stops.
	c.must(200, "DELETE", path+"/sponsor", nil, nil)
	limited(c, "members", 2, "POST", path+"/members", MemberInput{Name: "Flo"})
	var after Group
	c.must(200, "GET", path, nil, &after)
	if len(after.Members) != 5 {
		t.Fatalf("%+v", after.Members)
	}
}

// A plan that allows a larger group can start one, which then uses a place of
// the plan: it couldn't be sponsored in time for anything added at once.
func TestLargeNewGroupStartsSponsored(t *testing.T) {
	c, _, s := billingServer(t)
	exec(t, s, `update plans set members_per_group = 2 where is_default`)
	exec(t, s, `update plans set members_per_group = 4, sponsored_groups = 1 where id = 'plus'`)
	u := register(c, "ana@example.test", "Ana")
	grant(t, s, u.Id, "plus")

	three := GroupCreate{Name: "Trip", Currency: "EUR", Members: []string{"Ana", "Ben", "Cy"}}
	var g Group
	c.must(201, "POST", "/groups", three, &g)
	var gp GroupPlan
	c.must(200, "GET", "/g/"+g.Token+"/plan", nil, &gp)
	if gp.PlanName != "Plus" || gp.SponsorMemberId == nil || *gp.SponsorMemberId != g.Members[0].Id {
		t.Fatalf("%+v", gp)
	}
	// A small group doesn't need the plan, and past its places a large one
	// can't start.
	var small Group
	c.must(201, "POST", "/groups", GroupCreate{Name: "Small", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &small)
	var smallPlan GroupPlan
	c.must(200, "GET", "/g/"+small.Token+"/plan", nil, &smallPlan)
	if smallPlan.SponsorMemberId != nil {
		t.Fatalf("%+v", smallPlan)
	}
	var refused struct {
		Params map[string]any `json:"params"`
	}
	c.must(402, "POST", "/groups", three, &refused)
	if refused.Params["limit"] != "sponsored_groups" {
		t.Fatalf("%+v", refused)
	}
	five := GroupCreate{Name: "Big", Currency: "EUR", Members: []string{"Ana", "Ben", "Cy", "Dee", "Eli"}}
	c.must(402, "POST", "/groups", five, &refused)
	if refused.Params["limit"] != "members" || refused.Params["max"] != float64(4) {
		t.Fatalf("%+v", refused)
	}
}

func TestKofiMixedPlanOrderNeedsManualAssignment(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{
		"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true", "BALNANA_PUBLIC_URL": "https://balnana.test/",
		"BALNANA_KOFI_TOKEN": kofiTestToken, "BALNANA_KOFI_URL": "https://ko-fi.com/balnana",
	})
	admin := c.asAdmin(setUp(c))
	user := register(c, "ana@example.test", "Ana")
	kofiProducts(t, s)
	exec(t, s, `insert into plans (id,name,rank) values ('gold','Gold',20)`)
	exec(t, s, `insert into plan_products (provider,product,plan_id,days) values ('kofi','gold90','gold',90)`)
	for _, items := range [][]kofiShopItem{
		{{Code: "plus90", Quantity: 1}, {Code: "gold90", Quantity: 2}},
		{{Code: "gold90", Quantity: 2}, {Code: "plus90", Quantity: 1}},
	} {
		id := fmt.Sprintf("mixed-%s", items[0].Code)
		c.kofiOK(map[string]any{"message_id": id, "type": kofiShopOrder, "kofi_transaction_id": id, "shop_items": items})
		if state, _ := paymentState(t, s, id); state != "unmatched" {
			t.Fatal(state)
		}
		if code := c.errorCode(409, "POST", "/me/payments/claim", PaymentClaim{Reference: id}); code != "payment_no_plan" {
			t.Fatal(code)
		}
		if myPlanOf(c).Paid {
			t.Fatal("mixed basket was partially applied")
		}
	}
	var list PaymentList
	admin.must(200, "GET", "/admin/payments?state=unmatched", nil, &list)
	if list.Total != 2 {
		t.Fatal(list)
	}
	for _, p := range list.Payments {
		if p.PlanId != nil || p.Days != nil || p.Items == nil || len(*p.Items) != 2 {
			t.Fatalf("incomplete manual payment: %+v", p)
		}
		for _, item := range *p.Items {
			if item.Product == "gold90" && item.Quantity != 2 || item.Product == "plus90" && item.Quantity != 1 {
				t.Fatal(item)
			}
		}
	}
	var assigned Payment
	admin.must(200, "POST", "/admin/payments/"+list.Payments[0].Id+"/assign", PaymentAssign{UserId: user.Id, PlanId: ptr("gold"), Days: ptr(270)}, &assigned)
	if assigned.State != "applied" || assigned.Items == nil || len(*assigned.Items) != 2 {
		t.Fatal(assigned)
	}
	if p := myPlanOf(c); !p.Paid || p.PlanName != "Gold" {
		t.Fatal(p)
	}
}

func TestHandPlacedPlayPaymentsAddUp(t *testing.T) {
	c, _, s := billingServer(t)
	u := register(c, "ana@example.test", "Ana")
	ctx := t.Context()
	for _, id := range []string{"GPA.1", "GPA.2"} {
		exec(t, s, `insert into payment_events (provider, event_id, kind, state, plan_id, days, paid_at)
			values ('play', $1, 'Subscription', 'unclaimed', 'plus', 30, now())`, id)
		err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
			var paymentID string
			if err := tx.QueryRow(ctx, `select id::text from payment_events where event_id = $1`, id).Scan(&paymentID); err != nil {
				return err
			}
			if err := holdAccount(ctx, tx, u.Id); err != nil {
				return err
			}
			return applyPayment(ctx, tx, paymentID, u.Id)
		})
		if err != nil {
			t.Fatal(err)
		}
	}
	var n int
	var expires time.Time
	err := s.db.QueryRow(ctx, `select count(*), max(expires_at) from entitlements where user_id = $1`, u.Id).Scan(&n, &expires)
	if err != nil {
		t.Fatal(err)
	}
	if want := time.Now().AddDate(0, 0, 60); n != 1 || expires.Sub(want).Abs() > time.Minute {
		t.Fatal(n, expires)
	}
}
