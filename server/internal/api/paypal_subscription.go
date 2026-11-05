package api

import (
	"context"
	"errors"
	"net/http"
	"net/url"
	"slices"
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
	// Nothing says the two times agree to the second: the payment in the
	// window nearest the time is it, one for the same amount first.
	var found *paypalTransaction
	for i := range out.Transactions {
		payment := &out.Transactions[i]
		if !paypalID.MatchString(payment.ID) || !strings.EqualFold(payment.Amount.Gross.Currency, paid.Amount.Currency) {
			continue
		}
		if found == nil {
			found = payment
			continue
		}
		same, sameFound := sameAmount(payment.Amount.Gross.Value, paid.Amount.Value), sameAmount(found.Amount.Gross.Value, paid.Amount.Value)
		if same && !sameFound || same == sameFound && payment.Time.Sub(paid.Time).Abs() < found.Time.Sub(paid.Time).Abs() {
			found = payment
		}
	}
	if found != nil {
		return found, nil
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

// inTrial says whether the subscription is in its trial: its plan has one,
// no regular cycle has been billed, and nothing it owes has failed.
func (sub *paypalSubscription) inTrial(now time.Time) bool {
	billing := sub.BillingInfo
	if sub.Status != "ACTIVE" || billing.NextBillingTime == nil || !billing.NextBillingTime.After(now) ||
		billing.FailedPaymentsCount > 0 || billing.OutstandingBalance.Value != "" && !sameAmount(billing.OutstandingBalance.Value, "0") {
		return false
	}
	trial := false
	for _, cycle := range billing.CycleExecutions {
		switch cycle.TenureType {
		case "TRIAL":
			trial = true
		case "REGULAR":
			if cycle.CyclesCompleted > 0 {
				return false
			}
		}
	}
	return trial
}

// hadTrial says whether the subscription got as far as its plan's trial, if
// the plan has one.
func (sub *paypalSubscription) hadTrial() bool {
	switch sub.Status {
	case "ACTIVE", "SUSPENDED", "CANCELLED", "EXPIRED":
	default:
		return false
	}
	return slices.ContainsFunc(sub.BillingInfo.CycleExecutions, func(cycle paypalCycleExecution) bool { return cycle.TenureType == "TRIAL" })
}

// grantPayPalTrial gives the plan until the trial's end, to one subscription
// per account: cancelling and subscribing again doesn't start another.
func grantPayPalTrial(ctx context.Context, tx pgx.Tx, sub *paypalSubscription, userID, planID string, entitlement **string) (bool, error) {
	var tried bool
	err := tx.QueryRow(ctx, `select exists (select 1 from paypal_subscriptions
        where user_id = $1 and subscription_id <> $2 and trial_until is not null)`, userID, sub.ID).Scan(&tried)
	if err != nil || tried {
		return false, err
	}
	until := sub.BillingInfo.NextBillingTime.Add(paypalGrace)
	if *entitlement == nil {
		err = tx.QueryRow(ctx, `insert into entitlements (user_id, plan_id, source, expires_at)
            values ($1, $2, 'paypal', $3) returning id::text`, userID, planID, until).Scan(entitlement)
	} else {
		_, err = tx.Exec(ctx, `update entitlements set plan_id = $2, expires_at = greatest(expires_at, $3) where id = $1`, **entitlement, planID, until)
	}
	if err != nil {
		return false, err
	}
	_, err = tx.Exec(ctx, `update paypal_subscriptions set entitlement_id = $2, trial_until = greatest(trial_until, $3)
        where subscription_id = $1`, sub.ID, *entitlement, until)
	return err == nil, err
}

func (s *Server) syncPayPalSubscription(ctx context.Context, pp *paypalClient, subID string) (string, error) {
	return s.syncPayPalSubscriptionRefund(ctx, pp, subID, nil)
}

// cancelPayPalSubscriptions stops the account's PayPal subscriptions before it
// is deleted: PayPal would go on billing for an account that is gone. One
// PayPal doesn't know, or can't cancel as it no longer runs, is done with.
func (s *Server) cancelPayPalSubscriptions(ctx context.Context, userID string) error {
	rows, err := s.db.Query(ctx, `select subscription_id from paypal_subscriptions
        where user_id = $1 and (state is null or state = any($2))`, userID, []string{"APPROVAL_PENDING", "APPROVED", "ACTIVE", "SUSPENDED"})
	if err != nil {
		return err
	}
	ids, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil || len(ids) == 0 {
		return err
	}
	pp := s.settings.Load().paypal
	if pp == nil {
		s.log.Warn("deleting an account whose paypal subscriptions PayPal isn't set up to cancel", "subscriptions", ids)
		return nil
	}
	release, err := paypalSlot(ctx)
	if err != nil {
		return err
	}
	defer release()
	for _, id := range ids {
		err := pp.call(ctx, http.MethodPost, "/v1/billing/subscriptions/"+url.PathEscape(id)+"/cancel",
			map[string]string{"reason": "The Balnana account was deleted."}, "", nil)
		var refused paypalRefusal
		if err != nil && !paypalNotFound(err) && !(errors.As(err, &refused) && refused.status == http.StatusUnprocessableEntity) {
			s.log.Error("cancelling a paypal subscription failed", "subscription", id, "err", err)
			return errPayPalUnavailable
		}
	}
	return nil
}

// An optional refund is processed under the same subscription lock as renewals,
// so delayed payment notifications cannot restore refunded access.
func (s *Server) syncPayPalSubscriptionRefund(ctx context.Context, pp *paypalClient, subID string, refund *paypalTransaction) (outcome string, err error) {
	outcome = paypalFailed
	var userID string
	err = s.db.QueryRow(ctx, `select user_id::text from paypal_subscriptions where subscription_id = $1`, subID).Scan(&userID)
	if errors.Is(err, pgx.ErrNoRows) {
		return outcome, nil // only the server's own take a turn at PayPal
	}
	if err != nil {
		return "", err
	}
	release, err := paypalSlot(ctx)
	if err != nil {
		return "", err
	}
	defer release()
	// PayPal is asked everything before the transaction, which would keep
	// the account's other payments waiting on PayPal.
	asked := time.Now()
	var sub paypalSubscription
	if err := pp.call(ctx, http.MethodGet, "/v1/billing/subscriptions/"+url.PathEscape(subID)+"?fields=last_failed_payment", nil, "", &sub); err != nil {
		if paypalNotFound(err) {
			return outcome, nil
		}
		return "", err
	}
	if sub.CustomID != userID || sub.ID != subID {
		return outcome, nil
	}
	// unreconciled fails the sync once what could be taken in is: PayPal
	// sends the event again, or the payer's return says it is pending.
	var unreconciled error
	var last *paypalTransaction
	if paid := sub.BillingInfo.LastPayment; paid != nil && !paid.Time.IsZero() {
		last, unreconciled = pp.subscriptionPayment(ctx, &sub)
	}
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `select pg_advisory_xact_lock(hashtextextended($1, 0))`, "paypal:"+subID); err != nil {
			return err
		}
		var entitlement *string
		err := tx.QueryRow(ctx, `select entitlement_id::text from paypal_subscriptions where subscription_id = $1`, subID).Scan(&entitlement)
		if errors.Is(err, pgx.ErrNoRows) {
			return nil // its account was deleted meanwhile
		}
		if err != nil {
			return err
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
		if last != nil {
			// A verified refund can arrive before the transaction list changes.
			if refund != nil && last.ID == refund.ID {
				last = refund
			}
			if err := recordPayPalSubscriptionPayment(ctx, tx, &sub, last, true, userID, planID, days, &entitlement); err != nil {
				return err
			}
			if last.Status == "COMPLETED" || last.Status == "PARTIALLY_REFUNDED" {
				outcome = paypalDone
			}
		}
		if refund != nil {
			if err := recordPayPalSubscriptionPayment(ctx, tx, &sub, refund, false, userID, planID, days, &entitlement); err != nil {
				return err
			}
		}
		if planID != nil && sub.inTrial(asked) {
			granted, err := grantPayPalTrial(ctx, tx, &sub, userID, *planID, &entitlement)
			if err != nil {
				return err
			}
			if granted {
				outcome = paypalDone
			}
		} else if sub.hadTrial() {
			// A trial no sync saw while it ran was still the account's one.
			if _, err := tx.Exec(ctx, `update paypal_subscriptions set trial_until = coalesce(trial_until, $2) where subscription_id = $1`, subID, asked); err != nil {
				return err
			}
		}
		// The state is kept even when the last payment is still to be found,
		// so the account can't start a second subscription meanwhile. A sync
		// that asked PayPal later has stored a newer one already.
		_, err = tx.Exec(ctx, `update paypal_subscriptions set product = $2, entitlement_id = $3, state = $4, synced_at = $5
			where subscription_id = $1 and (synced_at is null or synced_at <= $5)`, subID, sub.PlanID, entitlement, sub.Status, asked)
		if err != nil {
			return err
		}
		return s.warnPayPalSubscriptions(ctx, tx, userID)
	})
	if err == nil {
		err = unreconciled
	}
	return outcome, err
}

// warnPayPalSubscriptions tells the administrator of an account paying for
// two subscriptions at once, as when it approved two checkouts in two tabs.
// Which one to cancel and refund is theirs to say.
func (s *Server) warnPayPalSubscriptions(ctx context.Context, tx pgx.Tx, userID string) error {
	rows, err := tx.Query(ctx, `select subscription_id from paypal_subscriptions
        where user_id = $1 and state = any($2) order by created_at`, userID, []string{"APPROVED", "ACTIVE", "SUSPENDED"})
	if err != nil {
		return err
	}
	running, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err == nil && len(running) > 1 {
		s.log.Warn("an account has more than one paypal subscription running", "user", userID, "subscriptions", running)
	}
	return err
}

// latest says payment is the subscription's last_payment, whose period its
// billing info tells.
func recordPayPalSubscriptionPayment(ctx context.Context, tx pgx.Tx, sub *paypalSubscription, payment *paypalTransaction, latest bool, userID string, planID *string, days *int, entitlement **string) error {
	refunded := payment.Status == "REFUNDED"
	if !refunded && payment.Status != "COMPLETED" && payment.Status != "PARTIALLY_REFUNDED" {
		return nil
	}
	// Adopt records created before real sale IDs were kept. They were named
	// for the last_payment time, and one already adopted stays as it is.
	at := payment.Time
	if latest {
		at = sub.BillingInfo.LastPayment.Time
	}
	legacy := sub.ID + "@" + at.UTC().Format(time.RFC3339)
	if _, err := tx.Exec(ctx, `update payment_events set event_id = $1
        where provider = 'paypal' and event_id = $2
          and not exists (select 1 from payment_events where provider = 'paypal' and event_id = $1)`, payment.ID, legacy); err != nil {
		return err
	}
	state := "unmatched"
	var until *time.Time
	if planID != nil && days != nil {
		state = "unclaimed"
		end := payment.Time.AddDate(0, 0, *days).Add(paypalGrace)
		if latest {
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
		switch refund.State {
		case "cancelled", "failed":
			return nil
		case "completed":
		default:
			return errors.New("paypal: sale refund has not completed yet")
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
	// The Sale schema has no 'reversed' state, yet PayPal reports it for a
	// reversed sale; a reversal may also show as denied, and refunded covers
	// completed money reversals.
	negative := sale.State == "refunded" || sale.State == "reversed" ||
		ev.EventType == "PAYMENT.SALE.REVERSED" && sale.State == "denied"
	if sale.ID != saleID || !negative {
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
