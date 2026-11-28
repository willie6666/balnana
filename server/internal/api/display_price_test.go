package api

import (
	"strings"
	"testing"
)

func TestAdminDisplayPrice(t *testing.T) {
	c, _, _ := adminClient(t, map[string]string{"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true"})
	admin := c.asAdmin(setUp(c))
	var catalog PlanCatalog
	admin.must(200, "GET", "/admin/plans", nil, &catalog)
	catalog.Products = []PlanProduct{
		{Provider: Kofi, Product: "plus91", PlanId: "plus", Days: 91, DisplayPrice: ptr("  US$5 ")},
		{Provider: Paypal, Product: "P-5ML4271244454362WXNWU5NQ", PlanId: "plus", Days: 91, DisplayPrice: ptr(strings.Repeat("元", maxPriceLen))},
		{Provider: Kofi, Product: "plus365", PlanId: "plus", Days: 365, DisplayPrice: ptr("   ")},
	}
	// A fresh one: decoding into the one sent would keep what the answer leaves out.
	var saved PlanCatalog
	admin.must(200, "PUT", "/admin/plans", catalog, &saved)
	catalog = saved
	prices := map[string]*string{}
	for _, p := range catalog.Products {
		prices[p.Product] = p.DisplayPrice
	}
	if got := prices["plus91"]; got == nil || *got != "US$5" {
		t.Fatalf("trimmed price: %v", got)
	}
	if prices["plus365"] != nil || prices["P-5ML4271244454362WXNWU5NQ"] == nil {
		t.Fatalf("prices: %+v", catalog.Products)
	}
	for _, bad := range []PlanProduct{
		{Provider: Play, Product: "plus_monthly", PlanId: "plus", Days: 30, DisplayPrice: ptr("US$5")},
		{Provider: Appstore, Product: "plus_monthly", PlanId: "plus", Days: 30, DisplayPrice: ptr("US$5")},
		{Provider: Kofi, Product: "x", PlanId: "plus", Days: 30, DisplayPrice: ptr(strings.Repeat("元", maxPriceLen+1))},
		{Provider: Kofi, Product: "x", PlanId: "plus", Days: 30, DisplayPrice: ptr("US$5\nfree")},
	} {
		in := catalog
		in.Products = []PlanProduct{bad}
		if code := admin.errorCode(400, "PUT", "/admin/plans", in); code != "invalid_plan" {
			t.Fatalf("%+v: %s", bad, code)
		}
	}
}

func TestKofiOffers(t *testing.T) {
	c, _, s := billingServer(t)
	register(c, "ana@example.test", "Ana")
	if p := myPlanOf(c); p.Kofi != nil {
		t.Fatalf("nothing configured: %+v", p.Kofi)
	}
	exec(t, s, `insert into plans (id, name, rank) values ('gold', 'Gold', 20)`)
	// Two products for 91 days, of which one has its price worded; a tip and a
	// shop item without an amount for others.
	exec(t, s, `insert into plan_products (provider, product, plan_id, days, min_amount, currency, display_price) values
		('kofi', 'gold365', 'gold', 365, null, null, null),
		('kofi', '', 'plus', 91, 5, 'USD', null),
		('kofi', 'plus91', 'plus', 91, null, null, 'US$5'),
		('kofi', '', 'plus', 365, 18, 'USD', null)`)
	p := myPlanOf(c)
	if p.Kofi == nil || len(p.Kofi.Offers) != 3 {
		t.Fatalf("offers: %+v", p.Kofi)
	}
	short, year, gold := p.Kofi.Offers[0], p.Kofi.Offers[1], p.Kofi.Offers[2]
	if short.PlanName != "Plus" || short.Days != 91 || short.DisplayPrice == nil || *short.DisplayPrice != "US$5" {
		t.Fatalf("worded price wins: %+v", short)
	}
	if year.Days != 365 || year.DisplayPrice != nil || year.Amount == nil || *year.Amount != "18.00" || *year.Currency != "USD" {
		t.Fatalf("amount: %+v", year)
	}
	if gold.PlanName != "Gold" || gold.Amount != nil || gold.DisplayPrice != nil {
		t.Fatalf("no price: %+v", gold)
	}
}

func TestKofiOffersNeedItsPage(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true"})
	register(c, "ana@example.test", "Ana")
	kofiProducts(t, s)
	if p := myPlanOf(c); p.Kofi != nil {
		t.Fatalf("no Ko-fi page: %+v", p.Kofi)
	}
}

func TestPayPalDisplayPrice(t *testing.T) {
	c, s, _ := paypalServer(t)
	exec(t, s, `insert into plan_products (provider, product, plan_id, days, min_amount, currency, display_price) values
		('paypal', 'plus-91', 'plus', 91, 5, 'USD', 'US$5'),
		('paypal', 'P-5ML4271244454362WXNWU5NQ', 'plus', 365, null, null, 'US$18')`)
	register(c, "ana@example.test", "Ana")
	p := myPlanOf(c)
	if p.Paypal == nil || len(p.Paypal.Offers) != 2 {
		t.Fatalf("offers: %+v", p.Paypal)
	}
	once, subscription := p.Paypal.Offers[0], p.Paypal.Offers[1]
	// The amount charged stays what it is.
	if once.DisplayPrice == nil || *once.DisplayPrice != "US$5" || once.Amount == nil || *once.Amount != "5.00" {
		t.Fatalf("one-off: %+v", once)
	}
	if !subscription.Subscription || subscription.DisplayPrice == nil || *subscription.DisplayPrice != "US$18" || subscription.Amount != nil {
		t.Fatalf("subscription: %+v", subscription)
	}
}
