package api

import (
	"context"
	"errors"
	"net/http"
	"net/url"
	"slices"
	"strconv"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
)

// paypalDeclines are the capture refusals that mean the payer's money
// didn't come; PayPal wants all but the last sent back to pay another way.
var paypalDeclines = []string{"INSTRUMENT_DECLINED", "PAYER_ACTION_REQUIRED", "REDIRECT_PAYER_FOR_ALTERNATE_FUNDING", "TRANSACTION_REFUSED"}

// syncPayPalOrder captures the order if it waits for that and takes in what
// it paid, under one lock per order. Orders the server didn't start are none
// of its business.
// A declined capture leaves retry as the page to send the payer back to.
func (s *Server) syncPayPalOrder(ctx context.Context, pp *paypalClient, orderID string) (outcome, retry string, err error) {
	outcome = paypalFailed
	var userID, product, amount, currency string
	var planID *string
	var days, attempts int
	err = s.db.QueryRow(ctx, `
		select user_id::text, product, plan_id, days, amount::text, currency, capture_attempts
		from paypal_orders where order_id = $1`, orderID).
		Scan(&userID, &product, &planID, &days, &amount, &currency, &attempts)
	if errors.Is(err, pgx.ErrNoRows) {
		return outcome, "", nil // only the server's own take a turn at PayPal
	}
	if err != nil {
		return "", "", err
	}
	release, err := paypalSlot(ctx)
	if err != nil {
		return "", "", err
	}
	defer release()
	// PayPal is asked everything before the transaction, which would keep
	// the account's other payments waiting on PayPal. Two syncs of the order
	// at once capture it with the same request ID, which PayPal does once.
	var order paypalOrder
	if err := pp.call(ctx, http.MethodGet, "/v2/checkout/orders/"+url.PathEscape(orderID), nil, "", &order); err != nil {
		if paypalNotFound(err) {
			return outcome, "", nil
		}
		return "", "", err
	}
	if order.Status == "APPROVED" {
		requestID := "capture-" + orderID
		if attempts > 0 {
			requestID += "-" + strconv.Itoa(attempts)
		}
		err := pp.call(ctx, http.MethodPost, "/v2/checkout/orders/"+url.PathEscape(orderID)+"/capture",
			[]byte("{}"), requestID, &order)
		var refused paypalRefusal
		switch {
		case errors.As(err, &refused) && slices.Contains(paypalDeclines, refused.issue):
			// Kept at once, whatever happens next, so the payer's next try
			// isn't answered with this refusal again.
			tag, err := s.db.Exec(ctx, `update paypal_orders set capture_attempts = capture_attempts + 1
				where order_id = $1 and capture_attempts = $2`, orderID, attempts)
			if err != nil {
				return "", "", err
			}
			if tag.RowsAffected() == 0 {
				// Another sync tried again since: see how that went.
				if err := pp.call(ctx, http.MethodGet, "/v2/checkout/orders/"+url.PathEscape(orderID), nil, "", &order); err != nil {
					return "", "", err
				}
				break
			}
			if refused.issue == "TRANSACTION_REFUSED" {
				return outcome, "", nil
			}
			// PayPal asks for the payer to be sent back to choose another
			// way to pay; the order's page is where they approved it.
			if err := pp.call(ctx, http.MethodGet, "/v2/checkout/orders/"+url.PathEscape(orderID), nil, "", &order); err != nil {
				return "", "", err
			}
			if retry = linkTo(order.Links, "payer-action", "approve"); retry != "" {
				outcome = paypalPending
			}
			return outcome, retry, nil
		case errors.As(err, &refused) && refused.status == http.StatusUnprocessableEntity:
			// Captured already, most likely: see what it is now.
			if err := pp.call(ctx, http.MethodGet, "/v2/checkout/orders/"+url.PathEscape(orderID), nil, "", &order); err != nil {
				return "", "", err
			}
		case err != nil:
			return "", "", err
		}
	}
	switch order.Status {
	case "CREATED", "SAVED", "APPROVED", "PAYER_ACTION_REQUIRED":
		return paypalPending, "", nil
	case "COMPLETED":
	default:
		return outcome, "", nil
	}
	if len(order.PurchaseUnits) == 0 || len(order.PurchaseUnits[0].Payments.Captures) == 0 {
		// A replay may use a minimal response cached by an earlier caller.
		if err := pp.call(ctx, http.MethodGet, "/v2/checkout/orders/"+url.PathEscape(orderID), nil, "", &order); err != nil {
			return "", "", err
		}
		if len(order.PurchaseUnits) == 0 || len(order.PurchaseUnits[0].Payments.Captures) == 0 {
			return paypalPending, "", nil
		}
	}
	unit := order.PurchaseUnits[0]
	capture := unit.Payments.Captures[0]
	// A reversed payment, as after a chargeback, gives the time back as a
	// refund does; PayPal shows it as REFUNDED or, at times, REVERSED.
	negative := capture.Status == "REFUNDED" || capture.Status == "REVERSED"
	switch {
	case capture.Status == "PENDING":
		return paypalPending, "", nil
	case capture.Status == "COMPLETED", capture.Status == "PARTIALLY_REFUNDED", negative:
	default:
		return outcome, "", nil
	}
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `select pg_advisory_xact_lock(hashtextextended($1, 0))`, "paypal:"+orderID); err != nil {
			return err
		}
		if err := holdAccount(ctx, tx, userID); err != nil {
			return err
		}
		state := "unclaimed"
		switch {
		case negative:
			state = "refunded"
		case planID == nil || unit.CustomID != userID ||
			!strings.EqualFold(capture.Amount.Currency, currency) || !sameAmount(capture.Amount.Value, amount):
			// Not what was asked for: an administrator sees it among the payments.
			state, planID = "unmatched", nil
		}
		paidAt := capture.CreateTime
		if paidAt.IsZero() {
			paidAt = time.Now()
		}
		var paymentID, recorded string
		err := tx.QueryRow(ctx, `
			insert into payment_events (provider, event_id, kind, payer_name, amount, currency, product,
			                            state, plan_id, days, user_id, paid_at, reference)
			values ('paypal', $1, 'Order', $2, $3::numeric, $4, $5, $6, $7, $8, $9, $10, $11)
			on conflict (provider, event_id) do update set provider = excluded.provider -- to return the row
			returning id::text, state`,
			capture.ID, optional(order.Payer.Name.String()), capture.Amount.Value, strings.ToUpper(capture.Amount.Currency),
			product, state, planID, days, userID, paidAt, orderID).Scan(&paymentID, &recorded)
		if err != nil {
			return err
		}
		if negative {
			return refundPayment(ctx, tx, paymentID)
		}
		if recorded == "unclaimed" {
			return applyPayment(ctx, tx, paymentID, userID)
		}
		return nil
	})
	if err != nil {
		return "", "", err
	}
	if negative {
		return outcome, "", nil
	}
	return paypalDone, "", nil
}

// refundPayment takes back the time a payment gave, as far as it is left.
func refundPayment(ctx context.Context, tx pgx.Tx, paymentID string) error {
	var state string
	var entitlement *string
	var days *int
	err := tx.QueryRow(ctx, `select state, entitlement_id::text, days from payment_events where id = $1 for update`,
		paymentID).Scan(&state, &entitlement, &days)
	if err != nil || state == "refunded" {
		return err
	}
	_, err = tx.Exec(ctx, `update payment_events set state = 'refunded' where id = $1`, paymentID)
	if err != nil || state != "applied" || entitlement == nil {
		return err
	}
	var subscription bool
	err = tx.QueryRow(ctx, `select exists (select 1 from paypal_subscriptions where entitlement_id = $1)`, *entitlement).Scan(&subscription)
	if err != nil {
		return err
	}
	if subscription {
		// Other paid periods keep their own end; refunding an older period
		// must not take time from a later, successful renewal.
		_, err = tx.Exec(ctx, `update entitlements e set expires_at = least(e.expires_at,
            coalesce((select max(p.paid_until) from payment_events p
                      where p.entitlement_id = e.id and p.state = 'applied'), now()))
            where e.id = $1`, *entitlement)
	} else if days != nil {
		_, err = tx.Exec(ctx, `update entitlements
            set expires_at = least(expires_at, greatest(now(), expires_at - make_interval(days => $2)))
            where id = $1`, *entitlement, *days)
	}
	return err
}
