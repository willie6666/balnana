package api

import (
	"encoding/json"
	"os"
	"testing"
	"time"
)

// PAYPAL_CONTRACT_OUTPUT exports the actual test HTTP exchanges for validation
// against PayPal's independently downloaded OpenAPI schemas (see testdata/paypal/README.md).
func TestPayPalContractFixtures(t *testing.T) {
	c, s, f := paypalServer(t)
	exec(t, s, `insert into plan_products (provider,product,plan_id,days,min_amount,currency)
		values ('paypal','plus90','plus',90,300,'TWD'), ('paypal','P-5ML4271244454362WXNWU5NQ','plus',30,null,null)`)
	register(c, "ana@example.test", "Ana")
	checkout(c, "plus90", PayPalCheckoutRequestAppWeb)
	f.order("ORDER1", func(o *fakeOrder) { o.status = "APPROVED" })
	paypalBack(c, "token=ORDER1&app=web")
	checkout(c, "P-5ML4271244454362WXNWU5NQ", PayPalCheckoutRequestAppWeb)
	paid := time.Now().UTC().Truncate(time.Second)
	f.pay("I-SUB2", paid, paid.AddDate(0, 0, 30))
	paypalBack(c, "subscription_id=I-SUB2&app=web")
	f.refundSale("SALE-I-SUB2-1", "refunded")
	f.mu.Lock()
	f.refundStates["REFUND1"] = "pending"
	f.mu.Unlock()
	if code := saleRefundEvent(c, "PAYMENT.SALE.REFUNDED", "REFUND1"); code != 500 {
		t.Fatal(code)
	}
	f.mu.Lock()
	f.refundStates["REFUND1"] = "completed"
	f.mu.Unlock()
	if code := saleRefundEvent(c, "PAYMENT.SALE.REFUNDED", "REFUND1"); code != 200 {
		t.Fatal(code)
	}
	f.pay("I-SUB2", paid.Add(time.Hour), paid.AddDate(0, 0, 60))
	paypalBack(c, "subscription_id=I-SUB2&app=web")
	f.refundSale("SALE-I-SUB2-2", "denied")
	if code := saleRefundEvent(c, "PAYMENT.SALE.REVERSED", "SALE-I-SUB2-2"); code != 200 {
		t.Fatal(code)
	}
	f.order("ORDER1", func(o *fakeOrder) { o.capture = "REFUNDED" })
	if code := paypalEventTo(c, "good", map[string]any{"event_type": "PAYMENT.CAPTURE.REFUNDED", "resource": map[string]any{
		"id": "REFUND2", "links": []paypalLink{{Rel: "up", Href: "https://api-m.paypal.com/v2/payments/captures/CAP-ORDER1"}},
	}}); code != 200 {
		t.Fatal(code)
	}
	if myPlanOf(c).Paid {
		t.Fatal("contract fixture refunds left access")
	}
	if path := os.Getenv("PAYPAL_CONTRACT_OUTPUT"); path != "" {
		f.mu.Lock()
		data, err := json.MarshalIndent(f.requests, "", "  ")
		f.mu.Unlock()
		if err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(path, data, 0600); err != nil {
			t.Fatal(err)
		}
	}
}
