package api

import (
	"context"
	"errors"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
)

// Subscription transactions carry real sale IDs, unlike billing_info.last_payment.
// Keep those IDs so a refund can find its payment even without an agreement ID.
type paypalTransaction struct {
	ID     string    `json:"id"`
	Status string    `json:"status"`
	Time   time.Time `json:"time"`
	Amount struct {
		Gross paypalMoney `json:"gross_amount"`
	} `json:"amount_with_breakdown"`
}

func (p *paypalClient) subscriptionPayment(ctx context.Context, sub *paypalSubscription) (*paypalTransaction, error) {
	paid := sub.BillingInfo.LastPayment
	query := url.Values{
		"start_time": {paid.Time.Add(-time.Minute).UTC().Format(time.RFC3339)},
		"end_time":   {paid.Time.Add(time.Minute).UTC().Format(time.RFC3339)},
	}
	var out struct {
		Transactions []paypalTransaction `json:"transactions"`
	}
	if err := p.call(ctx, http.MethodGet, "/v1/billing/subscriptions/"+url.PathEscape(sub.ID)+"/transactions?"+query.Encode(), nil, "", &out); err != nil {
		return nil, err
	}
	for _, payment := range out.Transactions {
		if paypalID.MatchString(payment.ID) && payment.Time.Equal(paid.Time) &&
			strings.EqualFold(payment.Amount.Gross.Currency, paid.Amount.Currency) && sameAmount(payment.Amount.Gross.Value, paid.Amount.Value) {
			return &payment, nil
		}
	}
	// The transaction list may trail the subscription details. Retry instead
	// of acknowledging a payment that could no longer be reconciled later.
	return nil, errors.New("paypal: last subscription payment is not in its transactions yet")
}

// subscriptionUntil is evaluated once for each successful payment. A later
// billing attempt (including a failed one) cannot move that payment's period.
func subscriptionUntil(sub *paypalSubscription, paidAt time.Time, days int) time.Time {
	until := paidAt.AddDate(0, 0, days).Add(paypalGrace)
	billing := sub.BillingInfo
	if billing.NextBillingTime != nil && billing.NextBillingTime.After(paidAt) &&
		billing.FailedPaymentsCount == 0 && (billing.OutstandingBalance.Value == "" || sameAmount(billing.OutstandingBalance.Value, "0")) &&
		(billing.LastFailedPayment == nil || billing.LastFailedPayment.Time.Before(paidAt)) {
		until = billing.NextBillingTime.Add(paypalGrace)
	}
	return until
}

func (s *Server) syncPayPalSubscription(ctx context.Context, pp *paypalClient, subID string) (string, error) {
	return s.syncPayPalSubscriptionRefund(ctx, pp, subID, nil)
}

// An optional refund is processed under the same subscription lock as renewals,
// so delayed payment notifications cannot restore refunded access.
func (s *Server) syncPayPalSubscriptionRefund(ctx context.Context, pp *paypalClient, subID string, refund *paypalTransaction) (outcome string, err error) {
	release, err := paypalSlot(ctx)
	if err != nil {
		return "", err
	}
	defer release()
	outcome = paypalFailed
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `select pg_advisory_xact_lock(hashtextextended($1, 0))`, "paypal:"+subID); err != nil {
			return err
		}
		var userID string
		var entitlement *string
		err := tx.QueryRow(ctx, `select user_id::text, entitlement_id::text from paypal_subscriptions where subscription_id = $1`, subID).Scan(&userID, &entitlement)
		if errors.Is(err, pgx.ErrNoRows) {
			return nil
		}
		if err != nil {
			return err
		}
		var sub paypalSubscription
		if err := pp.call(ctx, http.MethodGet, "/v1/billing/subscriptions/"+url.PathEscape(subID)+"?fields=last_failed_payment", nil, "", &sub); err != nil {
			if paypalNotFound(err) {
				return nil
			}
			return err
		}
		if sub.CustomID != userID || sub.ID != subID {
			return nil
		}
		if err := holdAccount(ctx, tx, userID); err != nil {
			return err
		}
		planID, days, err := matchProduct(ctx, tx, payment{provider: "paypal", product: &sub.PlanID})
		if err != nil {
			return err
		}
		switch sub.Status {
		case "ACTIVE", "APPROVAL_PENDING", "APPROVED":
			outcome = paypalPending
		}
		paid := sub.BillingInfo.LastPayment
		if paid != nil && !paid.Time.IsZero() {
			payment, err := pp.subscriptionPayment(ctx, &sub)
			if err != nil {
				return err
			}
			// A verified refund can arrive before the transaction list changes.
			if refund != nil && payment.ID == refund.ID {
				payment = refund
			}
			if err := recordPayPalSubscriptionPayment(ctx, tx, &sub, payment, userID, planID, days, &entitlement); err != nil {
				return err
			}
			if payment.Status == "COMPLETED" || payment.Status == "PARTIALLY_REFUNDED" {
				outcome = paypalDone
			}
		}
		if refund != nil {
			if err := recordPayPalSubscriptionPayment(ctx, tx, &sub, refund, userID, planID, days, &entitlement); err != nil {
				return err
			}
		}
		_, err = tx.Exec(ctx, `update paypal_subscriptions set product = $2, entitlement_id = $3, state = $4 where subscription_id = $1`, subID, sub.PlanID, entitlement, sub.Status)
		return err
	})
	return outcome, err
}

func recordPayPalSubscriptionPayment(ctx context.Context, tx pgx.Tx, sub *paypalSubscription, payment *paypalTransaction, userID string, planID *string, days *int, entitlement **string) error {
	refunded := payment.Status == "REFUNDED" || payment.Status == "REVERSED"
	if !refunded && payment.Status != "COMPLETED" && payment.Status != "PARTIALLY_REFUNDED" {
		return nil
	}
	// Adopt records created before real sale IDs were kept.
	legacy := sub.ID + "@" + payment.Time.UTC().Format(time.RFC3339)
	if _, err := tx.Exec(ctx, `update payment_events set event_id = $1
        where provider = 'paypal' and event_id = $2`, payment.ID, legacy); err != nil {
		return err
	}
	state := "unmatched"
	var until *time.Time
	if planID != nil && days != nil {
		state = "unclaimed"
		end := payment.Time.AddDate(0, 0, *days).Add(paypalGrace)
		if paid := sub.BillingInfo.LastPayment; paid != nil && paid.Time.Equal(payment.Time) {
			end = subscriptionUntil(sub, payment.Time, *days)
		}
		until = &end
	}
	var id, recorded string
	var storedUntil *time.Time
	err := tx.QueryRow(ctx, `insert into payment_events
        (provider, event_id, kind, payer_name, amount, currency, product, recurring, state, plan_id, days, user_id, paid_at, reference, paid_until)
        values ('paypal', $1, 'Subscription', $2, $3::numeric, $4, $5, true, $6, $7, $8, $9, $10, $11, $12)
        on conflict (provider, event_id) do update set provider = excluded.provider
        returning id::text, state, paid_until`, payment.ID, optional(sub.Subscriber.Name.String()), payment.Amount.Gross.Value,
		strings.ToUpper(payment.Amount.Gross.Currency), sub.PlanID, state, planID, days, userID, payment.Time, sub.ID, until).Scan(&id, &recorded, &storedUntil)
	if err != nil {
		return err
	}
	if refunded {
		return refundPayment(ctx, tx, id)
	}
	if recorded == "applied" || recorded == "refunded" || until == nil {
		return nil
	}
	if storedUntil != nil {
		until = storedUntil
	}
	if *entitlement == nil {
		err = tx.QueryRow(ctx, `insert into entitlements (user_id, plan_id, source, expires_at)
            values ($1, $2, 'paypal', $3) returning id::text`, userID, *planID, *until).Scan(entitlement)
	} else {
		_, err = tx.Exec(ctx, `update entitlements set plan_id = $2, expires_at = greatest(expires_at, $3) where id = $1`, **entitlement, *planID, *until)
	}
	if err != nil {
		return err
	}
	// Make the subscription link visible to refundPayment in this transaction.
	if _, err := tx.Exec(ctx, `update paypal_subscriptions set entitlement_id = $2 where subscription_id = $1`, sub.ID, *entitlement); err != nil {
		return err
	}
	_, err = tx.Exec(ctx, `update payment_events set state = 'applied', plan_id = $2, days = $3, entitlement_id = $4, paid_until = $5 where id = $1`, id, planID, days, *entitlement, until)
	return err
}

// Sale refunds are v1 resources even for the current Subscriptions API. Read
// the refund and original sale from PayPal; webhook fields alone grant nothing.
func (s *Server) refundPayPalSale(ctx context.Context, pp *paypalClient, ev *paypalEvent) error {
	saleID := ev.Resource.ID
	if ev.EventType == "PAYMENT.SALE.REFUNDED" {
		if !paypalID.MatchString(ev.Resource.ID) {
			return nil
		}
		var refund struct {
			State  string `json:"state"`
			SaleID string `json:"sale_id"`
		}
		if err := pp.call(ctx, http.MethodGet, "/v1/payments/refund/"+url.PathEscape(ev.Resource.ID), nil, "", &refund); err != nil {
			return err
		}
		if refund.State != "completed" {
			return nil
		}
		saleID = refund.SaleID
	} else if ev.Resource.SaleID != "" {
		saleID = ev.Resource.SaleID
	}
	if !paypalID.MatchString(saleID) {
		return nil
	}
	var sale struct {
		ID                 string    `json:"id"`
		State              string    `json:"state"`
		BillingAgreementID string    `json:"billing_agreement_id"`
		CreateTime         time.Time `json:"create_time"`
		Amount             struct {
			Total    string `json:"total"`
			Currency string `json:"currency"`
		} `json:"amount"`
	}
	if err := pp.call(ctx, http.MethodGet, "/v1/payments/sale/"+url.PathEscape(saleID), nil, "", &sale); err != nil {
		return err
	}
	if sale.State == "partially_refunded" {
		// Partial refunds leave the purchased period in force.
		return nil
	}
	if sale.ID != saleID || sale.State != "refunded" && sale.State != "reversed" {
		return errors.New("paypal: sale refund is not reflected in the sale yet")
	}
	subID := sale.BillingAgreementID
	if subID == "" {
		err := s.db.QueryRow(ctx, `select reference from payment_events where provider = 'paypal' and event_id = $1`, saleID).Scan(&subID)
		if errors.Is(err, pgx.ErrNoRows) {
			return nil
		}
		if err != nil {
			return err
		}
	}
	if !paypalID.MatchString(subID) || sale.CreateTime.IsZero() {
		return errors.New("paypal: refunded sale has no subscription or time")
	}
	payment := &paypalTransaction{ID: saleID, Status: "REFUNDED", Time: sale.CreateTime}
	payment.Amount.Gross = paypalMoney{Currency: sale.Amount.Currency, Value: sale.Amount.Total}
	_, err := s.syncPayPalSubscriptionRefund(ctx, pp, subID, payment)
	return err
}
