package api

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"net/url"
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
	ben.must(200, "GET", base+"/plan", nil, &plan)
	if plan.PlanName != "Free" || !plan.CanSponsor {
		t.Fatalf("%+v", plan)
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
	c, f, s := billingServer(t)
	kofiProducts(t, s)
	u := register(c, "ana@example.test", "Ana")
	sneak := c.another()
	register(sneak, "sneak@example.test", "Sneak")

	// A payment nobody can place waits, even for an unconfirmed address.
	exec(t, s, `update users set email = 'payer@example.test' where email = 'sneak@example.test'`)
	c.kofiOK(map[string]any{"message_id": "a", "amount": "3.00"})
	if state, who := paymentState(t, s, "a"); state != "unclaimed" || who != nil {
		t.Fatal(state, who)
	}
	if p := myPlanOf(sneak); p.Paid {
		t.Fatalf("an unconfirmed address got the plan: %+v", p)
	}
	exec(t, s, `update users set email = 'sneak@example.test' where email = 'payer@example.test'`)

	// Proving the address gives the account what waited for it.
	c.must(204, "POST", "/me/payment-email", PaymentEmailRequest{Email: "Payer@Example.test"}, nil)
	link := f.next(t, "payer@example.test")
	if !strings.Contains(link, "/payment-email") {
		t.Fatal(link)
	}
	token := EmailToken{Token: lastPart(link)}
	// Only for the account that asked.
	if code := sneak.errorCode(400, "POST", "/me/payment-email/confirm", token); code != "invalid_token" {
		t.Fatal(code)
	}
	var p MyPlan
	c.must(200, "POST", "/me/payment-email/confirm", token, &p)
	if !p.Paid || p.PlanName != "Plus" || p.ExpiresAt == nil || len(p.PaymentEmails) != 1 || !strings.EqualFold(p.PaymentEmails[0], "payer@example.test") {
		t.Fatalf("%+v", p)
	}
	if code := c.errorCode(400, "POST", "/me/payment-email/confirm", token); code != "invalid_token" {
		t.Fatal(code)
	}
	if state, who := paymentState(t, s, "a"); state != "applied" || who == nil || *who != u.Id {
		t.Fatal(state, who)
	}

	// From now on the address is enough; a repeat of a message counts once;
	// a one-off adds to what is left.
	before := *p.ExpiresAt
	c.kofiOK(map[string]any{"message_id": "b", "amount": "3.00"})
	c.kofiOK(map[string]any{"message_id": "b", "amount": "3.00"})
	p = myPlanOf(c)
	if d := p.ExpiresAt.Sub(before); d < 29*24*time.Hour || d > 31*24*time.Hour {
		t.Fatalf("added %v", d)
	}

	// Too little buys nothing, and a shop order isn't a plan, but they are kept.
	c.kofiOK(map[string]any{"message_id": "c", "amount": "2.99"})
	c.kofiOK(map[string]any{"message_id": "d", "type": "Shop Order", "amount": "50.00"})
	for _, id := range []string{"c", "d"} {
		if state, who := paymentState(t, s, id); state != "unmatched" || who == nil || *who != u.Id {
			t.Fatal(id, state, who)
		}
	}

	// Ko-fi documents a one-off tip as Tip, and its examples send Donation.
	c.kofiOK(map[string]any{"message_id": "e", "type": "Tip", "amount": "3.00"})
	if state, _ := paymentState(t, s, "e"); state != "applied" {
		t.Fatal(state)
	}
}

func TestKofiVerifiedAddressClaims(t *testing.T) {
	c, f, s := billingServer(t)
	kofiProducts(t, s)
	c.kofiOK(map[string]any{"message_id": "early", "email": "ana@example.test", "amount": "10.00"})
	register(c, "ana@example.test", "Ana")
	if p := myPlanOf(c); p.Paid {
		t.Fatalf("paid before confirming: %+v", p)
	}
	confirmEmail(c, f, "ana@example.test")
	if p := myPlanOf(c); !p.Paid {
		t.Fatalf("%+v", p)
	}
	if state, _ := paymentState(t, s, "early"); state != "applied" {
		t.Fatal(state)
	}
}

func TestKofiMembershipRenews(t *testing.T) {
	c, f, s := billingServer(t)
	kofiProducts(t, s)
	register(c, "ana@example.test", "Ana")
	confirmEmail(c, f, "ana@example.test")

	month := func(id string, paid time.Time) {
		c.kofiOK(map[string]any{"message_id": id, "type": "Subscription", "email": "ANA@example.test", "tier_name": "supporter",
			"amount": "4.00", "is_subscription_payment": true, "timestamp": paid.Format(time.RFC3339)})
	}
	start := time.Now().Add(-40 * 24 * time.Hour).UTC().Truncate(time.Second)
	month("late", time.Now().Add(-10*24*time.Hour).UTC().Truncate(time.Second))
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
	c.kofiOK(map[string]any{"message_id": "b", "email": "other@example.test"})
	var list PaymentList
	admin.must(200, "GET", "/admin/payments?state=unmatched", nil, &list)
	if list.Total != 2 || len(list.Payments) != 2 {
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
	if m := myPlanOf(c); !m.Paid || len(m.PaymentEmails) != 1 {
		t.Fatalf("%+v", m)
	}
	// The address is remembered for what comes next.
	c.kofiOK(map[string]any{"message_id": "c", "email": "other@example.test"})
	if state, who := paymentState(t, s, "c"); state != "unmatched" || who == nil {
		t.Fatal(state, who)
	}
}

func TestDeletedAccountKeepsPayments(t *testing.T) {
	c, f, s := billingServer(t)
	kofiProducts(t, s)
	register(c, "ana@example.test", "Ana")
	confirmEmail(c, f, "ana@example.test")
	c.kofiOK(map[string]any{"message_id": "a", "email": "ana@example.test", "amount": "9.00"})
	c.must(204, "POST", "/me/delete", AccountDelete{Password: ptr("correct horse")}, nil)
	state, who := paymentState(t, s, "a")
	if state != "applied" || who != nil {
		t.Fatal(state, who)
	}
}
