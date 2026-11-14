package api

import (
	"context"
	"errors"
	"math/big"
	"net/http"
	"net/url"
	"regexp"
	"slices"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
)

// Payments through PayPal. The app asks for a checkout and opens the page
// PayPal gives; PayPal sends the payer back to /paypal/return and tells the
// server of every later change through its webhook. Either way the server
// only believes what the REST API says of the order or subscription.
//
// A product that is a PayPal plan ID ("P-...") is a subscription, whose
// entitlement runs to its next billing time. Any other is a one-off payment
// of its minAmount, which adds its days like a Ko-fi payment.

const (
	paypalPath       = BasePath + "/webhooks/paypal"
	paypalReturnPath = BasePath + "/paypal/return"
	// paypalGrace is how long past its next billing time a subscription
	// counts, as the renewal takes a while to arrive.
	paypalGrace = 2 * 24 * time.Hour
	// paypalPlanPath is where the app shows how a PayPal payment went.
	paypalPlanPath = "/settings/plan"
	// paypalApprovalWindow is how far back a new subscription checkout looks
	// for earlier ones that may have been approved, at most
	// paypalApprovalsAsked of them.
	paypalApprovalWindow = 24 * time.Hour
	paypalApprovalsAsked = 3
)

var (
	// paypalPlanID is a subscription plan's ID, as PayPal makes them.
	paypalPlanID = regexp.MustCompile(`^P-[0-9A-Z]{24}$`)
	// paypalID is what an order or subscription ID from outside may look
	// like before PayPal is asked about it.
	paypalID = regexp.MustCompile(`^[A-Za-z0-9-]{1,64}$`)
	// paypalWholeCurrencies take no decimals at PayPal.
	paypalWholeCurrencies = []string{"HUF", "JPY", "TWD"}
	// https://developer.paypal.com/api/codes/currency
	paypalCurrencies = []string{"AUD", "BRL", "CAD", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HUF", "ILS", "JPY",
		"MYR", "MXN", "NOK", "NZD", "PHP", "PLN", "RUB", "SEK", "SGD", "CHF", "THB", "TWD", "USD"}

	errPayPalUnavailable = &apiError{status: http.StatusServiceUnavailable, code: "paypal_unavailable"}
	errPayPalSubscribed  = conflict("paypal_subscribed")
)

// paypalSlots bounds the calls to PayPal under way, as playSlots does Google's.
var paypalSlots = make(chan struct{}, 5)

func paypalAmount(amount, currency string) string {
	if slices.Contains(paypalWholeCurrencies, currency) {
		amount, _, _ = strings.Cut(amount, ".")
	}
	return amount
}

// sameAmount says whether two decimal amounts are equal, however they are written.
func sameAmount(a, b string) bool {
	x, okX := new(big.Rat).SetString(a)
	y, okY := new(big.Rat).SetString(b)
	return okX && okY && x.Cmp(y) == 0
}

func validPayPalPrice(amount, currency string) bool {
	n, ok := new(big.Rat).SetString(amount)
	return ok && n.Sign() > 0 && decimalAmount.MatchString(amount) && slices.Contains(paypalCurrencies, currency) &&
		sameAmount(amount, paypalAmount(amount, currency))
}

// paypalSlot waits for one of paypalSlots; release gives it back.
func paypalSlot(ctx context.Context) (release func(), err error) {
	wait := time.NewTimer(playWait)
	defer wait.Stop()
	select {
	case paypalSlots <- struct{}{}:
		return func() { <-paypalSlots }, nil
	case <-wait.C:
		return nil, &apiError{status: http.StatusServiceUnavailable, code: "busy"}
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}

// paypalOffer is what the account can buy through PayPal, if anything.
func (s *Server) paypalOffer(ctx context.Context, q querier, userID string) (*PayPalBilling, error) {
	if s.settings.Load().paypal == nil {
		return nil, nil
	}
	rows, err := q.Query(ctx, `
		select p.product, pl.name, p.days, p.min_amount::text, p.currency
		from plan_products p join plans pl on pl.id = p.plan_id
		where p.provider = 'paypal' order by pl.rank, p.days, p.product`)
	if err != nil {
		return nil, err
	}
	offers, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (PayPalOffer, error) {
		var o PayPalOffer
		err := row.Scan(&o.Product, &o.PlanName, &o.Days, &o.Amount, &o.Currency)
		o.Subscription = paypalPlanID.MatchString(o.Product)
		if o.Subscription {
			o.Amount = nil // PayPal's plan has the price
		} else if o.Amount != nil && o.Currency != nil && validPayPalPrice(*o.Amount, *o.Currency) {
			a := paypalAmount(*o.Amount, *o.Currency)
			o.Amount = &a
		} else {
			o.Amount = nil
		}
		return o, err
	})
	if err != nil {
		return nil, err
	}
	// Checkout refuses an order without a price PayPal takes.
	offers = slices.DeleteFunc(offers, func(o PayPalOffer) bool { return !o.Subscription && o.Amount == nil })
	if len(offers) == 0 {
		return nil, nil
	}
	subscribed, err := paypalSubscribed(ctx, q, userID)
	if err != nil {
		return nil, err
	}
	return &PayPalBilling{Offers: offers, Subscribed: subscribed}, nil
}

// paypalSubscribed are the products the account has a subscription to that
// still runs, or would if its payments came through. One to a plan without
// the trial is to the product with it.
func paypalSubscribed(ctx context.Context, q querier, userID string) ([]string, error) {
	rows, err := q.Query(ctx, `
		select distinct coalesce(p.product, s.product) from paypal_subscriptions s
		left join plan_products p on p.provider = 'paypal' and p.without_trial = s.product
		where s.user_id = $1 and s.state = any($2) order by 1`,
		userID, []string{"APPROVED", "ACTIVE", "SUSPENDED"})
	if err != nil {
		return nil, err
	}
	subscribed, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if subscribed == nil {
		subscribed = []string{}
	}
	return subscribed, err
}

func (s *Server) CreatePayPalCheckout(ctx context.Context, req CreatePayPalCheckoutRequestObject) (CreatePayPalCheckoutResponseObject, error) {
	if err := s.requireBilling(); err != nil {
		return nil, err
	}
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	pp := s.settings.Load().paypal
	if pp == nil {
		return nil, errNotFound
	}
	app := req.Body.App
	if app != PayPalCheckoutRequestAppWeb && app != PayPalCheckoutRequestAppAndroid {
		return nil, badRequest("bad_request")
	}
	var planID, planName, amount, currency, withoutTrial *string
	var days int
	err = s.db.QueryRow(ctx, `
		select p.plan_id, pl.name, p.days, p.min_amount::text, p.currency, p.without_trial
		from plan_products p join plans pl on pl.id = p.plan_id
		where p.provider = 'paypal' and p.product = $1`, req.Body.Product).
		Scan(&planID, &planName, &days, &amount, &currency, &withoutTrial)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, errNotFound
	}
	if err != nil {
		return nil, err
	}
	subscription := paypalPlanID.MatchString(req.Body.Product)
	if !subscription && (amount == nil || currency == nil || !validPayPalPrice(*amount, *currency)) {
		return nil, errNotFound // the admin page doesn't allow it
	}
	if subscription {
		subscribed, err := paypalSubscribed(ctx, s.db, u.id)
		if err != nil {
			return nil, err
		}
		if slices.Contains(subscribed, req.Body.Product) {
			return nil, errPayPalSubscribed
		}
	}
	if now := time.Now(); !s.checkouts.take(u.id, 1, now) {
		return nil, limited(s.checkouts, u.id, now)
	}
	if subscription {
		// The payer may have approved an earlier one whose return and events
		// haven't come yet; a second would be charged as well.
		subscribed, err := s.refreshPayPalApprovals(ctx, pp, u.id, req.Body.Product, withoutTrial)
		if err != nil {
			return nil, err
		}
		if subscribed {
			return nil, errPayPalSubscribed
		}
	}
	back := strings.TrimSuffix(s.conf().PublicURL.String(), "/") + paypalReturnPath + "?app=" + string(app)
	var href string
	if subscription {
		plan := req.Body.Product
		// PayPal would give the trial again; access is given once an account.
		if withoutTrial != nil {
			var trialled bool
			err = s.db.QueryRow(ctx, `select exists (select 1 from paypal_subscriptions
				where user_id = $1 and trial_until is not null)`, u.id).Scan(&trialled)
			if err != nil {
				return nil, err
			}
			if trialled {
				plan = *withoutTrial
			}
		}
		href, err = s.startPayPalSubscription(ctx, pp, u.id, plan, back)
	} else {
		href, err = s.startPayPalOrder(ctx, pp, u.id, req.Body.Product, *planID, *planName, days, *amount, *currency, back)
	}
	var known *apiError
	switch {
	case errors.As(err, &known):
		return nil, err
	case err != nil:
		s.log.Error("starting a paypal checkout failed", "err", err)
		return nil, errPayPalUnavailable
	}
	return CreatePayPalCheckout200JSONResponse{Url: href}, nil
}

// refreshPayPalApprovals asks PayPal about the account's recent subscriptions
// to product, or its plan without the trial, that were waiting for approval,
// and says whether one now runs.
func (s *Server) refreshPayPalApprovals(ctx context.Context, pp *paypalClient, userID, product string, withoutTrial *string) (bool, error) {
	plans := []string{product}
	if withoutTrial != nil {
		plans = append(plans, *withoutTrial)
	}
	rows, err := s.db.Query(ctx, `
		select subscription_id from paypal_subscriptions
		where user_id = $1 and product = any($2) and state = 'APPROVAL_PENDING' and created_at > $3
		order by created_at desc limit $4`, userID, plans, time.Now().Add(-paypalApprovalWindow), paypalApprovalsAsked)
	if err != nil {
		return false, err
	}
	ids, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil {
		return false, err
	}
	for _, id := range ids {
		// The state is kept even when its payment isn't found yet.
		if _, err := s.syncPayPalSubscription(ctx, pp, id); err != nil {
			s.log.Warn("asking paypal about a subscription failed", "err", err)
		}
	}
	if len(ids) == 0 {
		return false, nil
	}
	subscribed, err := paypalSubscribed(ctx, s.db, userID)
	return slices.Contains(subscribed, product), err
}

func (s *Server) startPayPalOrder(ctx context.Context, pp *paypalClient, userID, product, planID, planName string, days int, amount, currency, back string) (string, error) {
	type experience struct {
		BrandName          string `json:"brand_name"`
		ShippingPreference string `json:"shipping_preference"`
		UserAction         string `json:"user_action"`
		PaymentMethod      string `json:"payment_method_preference"`
		ReturnURL          string `json:"return_url"`
		CancelURL          string `json:"cancel_url"`
	}
	body := map[string]any{
		"intent": "CAPTURE",
		"purchase_units": []map[string]any{{
			"custom_id":   userID,
			"description": planName,
			"amount":      paypalMoney{Currency: currency, Value: paypalAmount(amount, currency)},
		}},
		"payment_source": map[string]any{"paypal": map[string]any{"experience_context": experience{
			BrandName:          "Balnana",
			ShippingPreference: "NO_SHIPPING",
			UserAction:         "PAY_NOW",
			PaymentMethod:      "IMMEDIATE_PAYMENT_REQUIRED",
			ReturnURL:          back,
			CancelURL:          back + "&cancel=1",
		}}},
	}
	var order paypalOrder
	if err := pp.call(ctx, http.MethodPost, "/v2/checkout/orders", body, uuid.NewString(), &order); err != nil {
		return "", err
	}
	href := linkTo(order.Links, "payer-action", "approve")
	if order.ID == "" || href == "" {
		return "", errors.New("paypal: an order without a page to pay on")
	}
	_, err := s.db.Exec(ctx, `
		insert into paypal_orders (order_id, user_id, product, plan_id, days, amount, currency)
		values ($1, $2, $3, $4, $5, $6::numeric, $7)`,
		order.ID, userID, product, planID, days, amount, currency)
	return href, err
}

func (s *Server) startPayPalSubscription(ctx context.Context, pp *paypalClient, userID, product, back string) (string, error) {
	body := map[string]any{
		"plan_id":   product,
		"custom_id": userID,
		"application_context": map[string]any{
			"brand_name":          "Balnana",
			"shipping_preference": "NO_SHIPPING",
			"user_action":         "SUBSCRIBE_NOW",
			"return_url":          back,
			"cancel_url":          back + "&cancel=1",
		},
	}
	var sub paypalSubscription
	if err := pp.call(ctx, http.MethodPost, "/v1/billing/subscriptions", body, uuid.NewString(), &sub); err != nil {
		var refused paypalRefusal
		if errors.As(err, &refused) && refused.status == http.StatusUnprocessableEntity {
			return "", errNotFound // a plan PayPal doesn't have, or not active
		}
		return "", err
	}
	href := linkTo(sub.Links, "approve")
	if sub.ID == "" || href == "" {
		return "", errors.New("paypal: a subscription without a page to approve it on")
	}
	_, err := s.db.Exec(ctx, `
		insert into paypal_subscriptions (subscription_id, user_id, product, state) values ($1, $2, $3, $4)`,
		sub.ID, userID, product, sub.Status)
	return href, err
}

// How a checkout went, as the app's plan page is told.
const (
	paypalDone      = "done"
	paypalPending   = "pending"
	paypalCancelled = "cancelled"
	paypalFailed    = "failed"
)

// PayPalReturn is where PayPal sends the payer back to. It takes in what they
// paid, without waiting for the webhook, and sends them on to the app.
func (s *Server) PayPalReturn(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	outcome := paypalFailed
	pp := s.settings.Load().paypal
	sub, order := q.Get("subscription_id"), q.Get("token")
	switch {
	case pp == nil:
	case q.Get("cancel") != "":
		outcome = paypalCancelled
	case paypalID.MatchString(sub):
		o, err := s.syncPayPalSubscription(r.Context(), pp, sub)
		if err != nil {
			s.log.Error("taking a paypal subscription failed", "err", err)
			o = paypalPending // the webhook brings it in
		}
		outcome = o
	case paypalID.MatchString(order):
		o, retry, err := s.syncPayPalOrder(r.Context(), pp, order)
		if err != nil {
			s.log.Error("taking a paypal order failed", "err", err)
			o = paypalPending
		}
		if retry != "" {
			http.Redirect(w, r, retry, http.StatusSeeOther)
			return
		}
		outcome = o
	}
	back := url.Values{"paypal": {outcome}}
	target := s.appLink(paypalPlanPath, back)
	if q.Get("app") == "android" {
		target = androidApp + paypalPlanPath + "?" + back.Encode()
	}
	http.Redirect(w, r, target, http.StatusSeeOther)
}
