package api

import (
	"context"
	"slices"
	"testing"
)

func comparisonIDs(comparison *PlanComparison) []string {
	if comparison == nil {
		return nil
	}
	ids := make([]string, len(comparison.Plans))
	for i, p := range comparison.Plans {
		ids[i] = p.Id
	}
	return ids
}

func TestPlanComparison(t *testing.T) {
	c, _, s := billingServer(t)
	u := register(c, "ana@example.test", "Ana")
	kofiProducts(t, s)
	exec(t, s, `insert into plans (id, name, rank) values ('private', 'Private grant', 20), ('play-only', 'Play', 30), ('paypal-only', 'PayPal', 40)`)
	exec(t, s, `insert into plan_products (provider, product, plan_id, days) values ('play', 'play-product', 'play-only', 30), ('paypal', 'P-PAYPAL', 'paypal-only', 30)`)
	exec(t, s, `update plans set members_per_group = 7 where id = 'free'`)
	exec(t, s, `update plans set members_per_group = null, reminders = true where id = 'plus'`)
	p := myPlanOf(c)
	comparison := p.Comparison
	if got := comparisonIDs(comparison); !slices.Equal(got, []string{"email-unverified", "free", "plus"}) {
		t.Fatalf("comparison plans: %v", got)
	}
	if comparison.CurrentPlanId != "email-unverified" || comparison.UnverifiedPlanId == nil ||
		*comparison.UnverifiedPlanId != "email-unverified" || comparison.VerifiedPlanId == nil || *comparison.VerifiedPlanId != "free" {
		t.Fatalf("automatic plans: %+v", comparison)
	}
	for _, option := range comparison.Plans {
		switch option.Id {
		case "free":
			if option.Limits.MembersPerGroup == nil || *option.Limits.MembersPerGroup != 7 {
				t.Fatalf("configured member limit: %+v", option.Limits)
			}
		case "plus":
			if option.Limits.MembersPerGroup == nil || *option.Limits.MembersPerGroup != maxMembers || option.Limits.Reminders == nil || !*option.Limits.Reminders {
				t.Fatalf("effective limits: %+v", option.Limits)
			}
		}
	}

	// A private grant is visible to its holder, without listing other private plans.
	grant(t, s, u.Id, "private")
	comparison = myPlanOf(c).Comparison
	if comparison.CurrentPlanId != "private" || !slices.Equal(comparisonIDs(comparison), []string{"free", "plus", "private"}) {
		t.Fatalf("granted comparison: %+v", comparison)
	}

	// Only configured payment providers add their purchasable plans.
	comparison, err := s.planComparison(context.Background(), s.db, "free", true, false, &PayPalBilling{
		Offers: []PayPalOffer{{Product: "P-PAYPAL"}},
	})
	if err != nil {
		t.Fatal(err)
	}
	if !slices.Equal(comparisonIDs(comparison), []string{"free", "plus", "play-only", "paypal-only"}) {
		t.Fatalf("enabled provider plans: %v", comparisonIDs(comparison))
	}
}

func TestPlanComparisonWithoutPaymentProviders(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{
		"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true",
	})
	register(c, "ana@example.test", "Ana")
	kofiProducts(t, s)
	if got := comparisonIDs(myPlanOf(c).Comparison); !slices.Equal(got, []string{"email-unverified", "free"}) {
		t.Fatalf("inactive Ko-fi must not advertise a plan: %v", got)
	}
}

func TestPlanComparisonAfterAdminRevocation(t *testing.T) {
	c, s, _ := adminClient(t, map[string]string{
		"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true",
		"BALNANA_KOFI_URL":   "https://ko-fi.com/balnana",
		"BALNANA_KOFI_TOKEN": kofiTestToken,
		"BALNANA_PUBLIC_URL": "https://balnana.test/",
	})
	u := register(c, "ana@example.test", "Ana")
	kofiProducts(t, s)
	admin := c.asAdmin(setUp(c))
	var entitlement Entitlement
	admin.must(201, "POST", "/admin/users/"+u.Id+"/entitlements", EntitlementGrant{PlanId: "plus"}, &entitlement)
	if p := myPlanOf(c); p.Comparison == nil || p.Comparison.CurrentPlanId != "plus" {
		t.Fatalf("granted plan: %+v", p.Comparison)
	}
	admin.must(204, "DELETE", "/admin/entitlements/"+entitlement.Id, nil, nil)
	p := myPlanOf(c)
	if p.Paid || p.Comparison == nil || p.Comparison.CurrentPlanId == "plus" || !slices.Contains(comparisonIDs(p.Comparison), "plus") {
		t.Fatalf("revoking an entitlement must keep the purchasable plan: %+v", p.Comparison)
	}
	var catalog PlanCatalog
	admin.must(200, "GET", "/admin/plans", nil, &catalog)
	if len(catalog.Products) != 3 {
		t.Fatalf("revocation changed the products: %+v", catalog.Products)
	}
}

func TestPlanComparisonUsesPayPalOffers(t *testing.T) {
	c, s, _ := paypalServer(t)
	exec(t, s, `insert into plans (id, name, rank) values ('subscription', 'Subscription', 20), ('unavailable', 'Unavailable', 30)`)
	exec(t, s, `insert into plan_products (provider, product, plan_id, days, min_amount, currency) values
		('paypal', 'plus-90', 'plus', 90, 300, 'TWD'),
		('paypal', 'P-5ML4271244454362WXNWU5NQ', 'subscription', 30, null, null),
		('paypal', 'invalid-price', 'unavailable', 90, 300.50, 'TWD')`)
	u := register(c, "ana@example.test", "Ana")
	p := myPlanOf(c)
	if p.Paypal == nil || len(p.Paypal.Offers) != 2 {
		t.Fatalf("valid PayPal offers: %+v", p.Paypal)
	}
	if got := comparisonIDs(p.Comparison); !slices.Equal(got, []string{"email-unverified", "free", "plus", "subscription"}) {
		t.Fatalf("comparison must include only the valid PayPal offers: %v", got)
	}
	c.errorCode(404, "POST", "/me/paypal/checkout", PayPalCheckoutRequest{Product: "invalid-price", App: PayPalCheckoutRequestAppWeb})

	// An unavailable product must not hide a plan the account already holds.
	grant(t, s, u.Id, "unavailable")
	p = myPlanOf(c)
	if p.Comparison.CurrentPlanId != "unavailable" || !slices.Contains(comparisonIDs(p.Comparison), "unavailable") {
		t.Fatalf("current plan must remain visible: %+v", p.Comparison)
	}
}

func TestPlanMemberLimitsMatchComparison(t *testing.T) {
	c, _, s := billingServer(t)
	u := register(c, "ana@example.test", "Ana")
	grant(t, s, u.Id, "plus")
	g := createGroup(c, "Ana")
	base := "/g/" + g.Token
	c.must(200, "PUT", base+"/sponsor", nil, nil)
	for _, tc := range []struct {
		name  string
		limit *int
		want  int
	}{
		{"unlimited", nil, maxMembers},
		{"above server cap", ptr(500), maxMembers},
		{"at server cap", ptr(maxMembers), maxMembers},
		{"below server cap", ptr(7), 7},
		{"zero", ptr(0), 0},
	} {
		t.Run(tc.name, func(t *testing.T) {
			exec(t, s, `update plans set members_per_group = $1 where id = 'plus'`, tc.limit)
			p := myPlanOf(c)
			if p.MembersPerGroup == nil || *p.MembersPerGroup != tc.want {
				t.Fatalf("summary member limit: %v, want %d", p.MembersPerGroup, tc.want)
			}
			found := false
			for _, option := range p.Comparison.Plans {
				if option.Id == p.Comparison.CurrentPlanId {
					found = true
					if option.Limits.MembersPerGroup == nil || *option.Limits.MembersPerGroup != tc.want {
						t.Fatalf("comparison member limit: %v, want %d", option.Limits.MembersPerGroup, tc.want)
					}
				}
			}
			if !found {
				t.Fatal("current plan missing from comparison")
			}
			var groupPlan GroupPlan
			c.must(200, "GET", base+"/plan", nil, &groupPlan)
			if groupPlan.Members.Limit == nil || *groupPlan.Members.Limit != tc.want {
				t.Fatalf("group member limit: %v, want %d", groupPlan.Members.Limit, tc.want)
			}
		})
	}
}
