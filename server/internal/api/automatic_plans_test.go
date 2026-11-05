package api

import (
	"encoding/json"
	"net/http"
	"slices"
	"testing"
)

func TestAutomaticEmailPlans(t *testing.T) {
	c, mail, s := billingServer(t)
	ana := register(c, "ana@example.test", "Ana")
	p := myPlanOf(c)
	if p.PlanName != "Email unverified" || p.Paid || p.JoinedGroups.Limit == nil || *p.JoinedGroups.Limit != 5 ||
		p.ReceiptsPerGroup == nil || *p.ReceiptsPerGroup != 0 {
		t.Fatalf("unverified plan: %+v", p)
	}

	sponsor := c.another()
	ben := register(sponsor, "ben@example.test", "Ben")
	grant(t, s, ben.Id, "plus")
	g := createGroup(sponsor, "Ben", "Ana")
	base := "/g/" + g.Token
	sponsor.must(200, "PUT", base+"/sponsor", nil, nil)
	c.must(200, "POST", base+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)
	existing, fresh := receiptExpense(sponsor, g), receiptExpense(sponsor, g)
	path := func(e Expense) string { return base + "/expenses/" + e.Id + "/receipt" }
	photo := pngBytes(t, halves(8, 8))
	if rec := sponsor.upload(path(existing), "image/png", photo); rec.Code != http.StatusOK {
		t.Fatalf("sponsor upload: %d %s", rec.Code, rec.Body)
	}
	for _, e := range []Expense{existing, fresh} {
		rec := c.upload(path(e), "image/png", photo)
		var body Error
		if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
			t.Fatal(err)
		}
		if rec.Code != http.StatusPaymentRequired || body.Code != "plan_limit" || body.Params == nil || (*body.Params)["max"] != float64(0) {
			t.Fatalf("unverified upload: %d %s", rec.Code, rec.Body)
		}
	}
	for range 4 {
		createGroup(c, "Ana")
	}
	in := GroupCreate{Name: "Sixth", Currency: "EUR", Members: []string{"Ana"}}
	c.errorCode(402, "POST", "/groups", in)
	extra := createGroup(sponsor, "Ben", "Ana")
	c.errorCode(402, "POST", "/g/"+extra.Token+"/join", JoinInput{ClaimMemberId: &extra.Members[1].Id})
	c.must(200, "GET", base, nil, nil) // existing access remains

	// A granted plan takes precedence before email verification too.
	grant(t, s, ana.Id, "plus")
	if p := myPlanOf(c); !p.Paid || p.PlanName != "Plus" {
		t.Fatalf("grant: %+v", p)
	}
	if rec := c.upload(path(fresh), "image/png", photo); rec.Code != http.StatusOK {
		t.Fatalf("grant upload: %d %s", rec.Code, rec.Body)
	}
	exec(t, s, `update entitlements set revoked_at = now() where user_id = $1`, ana.Id)
	c.errorCode(402, "POST", "/groups", in)

	confirmEmail(c, mail, "ana@example.test")
	if p := myPlanOf(c); p.Paid || p.PlanName != "Free" || *p.JoinedGroups.Limit != 10 {
		t.Fatalf("verified: %+v", p)
	}
	c.must(201, "POST", "/groups", in, nil)
	if rec := c.upload(path(existing), "image/png", photo); rec.Code != http.StatusOK {
		t.Fatalf("verified replacement: %d %s", rec.Code, rec.Body)
	}
	// Losing verification uses the other automatic plan again.
	takeAddress(t, s.db, ana.Id, "new@example.test")
	if p := myPlanOf(c); p.PlanName != "Email unverified" || p.JoinedGroups.Used != 6 {
		t.Fatalf("changed email: %+v", p)
	}
	c.errorCode(402, "POST", "/groups", in)
}

func TestAdminAutomaticPlans(t *testing.T) {
	c, _, _ := adminClient(t, map[string]string{"BALNANA_AUTH_MODE": "accounts", "BALNANA_BILLING_ENABLED": "true"})
	admin := c.asAdmin(setUp(c))
	var catalog PlanCatalog
	admin.must(200, "GET", "/admin/plans", nil, &catalog)
	if catalog.UnverifiedPlanId == nil || *catalog.UnverifiedPlanId != "email-unverified" || catalog.VerifiedPlanId == nil || *catalog.VerifiedPlanId != "free" {
		t.Fatalf("defaults: %+v", catalog)
	}
	register(c, "ana@example.test", "Ana")
	// Selecting a high-rank plan automatically does not mark it as paid.
	catalog.UnverifiedPlanId = ptr("plus")
	catalog.VerifiedPlanId = ptr("plus")
	admin.must(200, "PUT", "/admin/plans", catalog, &catalog)
	if p := myPlanOf(c); p.Paid || p.PlanName != "Plus" || p.ExpiresAt != nil {
		t.Fatalf("automatic: %+v", p)
	}
	invalid := catalog
	invalid.VerifiedPlanId = ptr("missing")
	admin.errorCode(400, "PUT", "/admin/plans", invalid)
	invalid = catalog
	invalid.Plans = slices.DeleteFunc(slices.Clone(catalog.Plans), func(p Plan) bool { return p.Id == "plus" })
	admin.errorCode(400, "PUT", "/admin/plans", invalid)
	admin.must(200, "GET", "/admin/plans", nil, &catalog)
	if *catalog.VerifiedPlanId != "plus" || *catalog.UnverifiedPlanId != "plus" {
		t.Fatalf("rollback: %+v", catalog)
	}
	// Older clients omit these fields; an unrelated edit keeps assignments.
	legacy := catalog
	legacy.UnverifiedPlanId, legacy.VerifiedPlanId = nil, nil
	admin.must(200, "PUT", "/admin/plans", legacy, &catalog)
	if *catalog.VerifiedPlanId != "plus" || *catalog.UnverifiedPlanId != "plus" {
		t.Fatalf("legacy save: %+v", catalog)
	}
	// Switch references and remove the old automatic plan in one save.
	catalog.UnverifiedPlanId = ptr("free")
	catalog.VerifiedPlanId = ptr("free")
	catalog.Plans = slices.DeleteFunc(catalog.Plans, func(p Plan) bool { return p.Id == "email-unverified" })
	admin.must(200, "PUT", "/admin/plans", catalog, &catalog)
	if p := myPlanOf(c); p.Paid || p.PlanName != "Free" {
		t.Fatalf("reassigned: %+v", p)
	}
}
