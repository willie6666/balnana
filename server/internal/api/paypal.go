package api

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math/big"
	"net/http"
	"net/url"
	"regexp"
	"slices"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/clientcredentials"

	"balnana/internal/config"
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
	paypalLive       = "https://api-m.paypal.com"
	paypalSandbox    = "https://api-m.sandbox.paypal.com"
	paypalTimeout    = 15 * time.Second
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

	// paypalDeclines are the capture refusals that mean the payer's money
	// didn't come; PayPal wants all but the last sent back to pay another way.
	paypalDeclines = []string{"INSTRUMENT_DECLINED", "PAYER_ACTION_REQUIRED", "REDIRECT_PAYER_FOR_ALTERNATE_FUNDING", "TRANSACTION_REFUSED"}

	errPayPalUnavailable = &apiError{status: http.StatusServiceUnavailable, code: "paypal_unavailable"}
	errPayPalSubscribed  = conflict("paypal_subscribed")
)

// paypalSlots bounds the calls to PayPal under way, as playSlots does Google's.
var paypalSlots = make(chan struct{}, 5)

// paypalRefusal is an answer from the REST API other than a success.
type paypalRefusal struct {
	status int
	issue  string // the first detail's issue, such as INSTRUMENT_DECLINED
	// debugID is what PayPal's support asks for about the call.
	debugID string
}

func (e paypalRefusal) Error() string {
	return fmt.Sprintf("paypal: %d %s %s (debug ID %s)", e.status, http.StatusText(e.status), e.issue, e.debugID)
}

// paypalClient talks to PayPal for one REST app.
type paypalClient struct {
	http      *http.Client
	base      string
	webhookID string
}

// newPayPalClient is nil until the REST app's credentials are set.
func newPayPalClient(cfg *config.Config) *paypalClient {
	if cfg.PayPalClientID == "" || cfg.PayPalSecret == "" {
		return nil
	}
	base := paypalLive
	if cfg.PayPalSandbox {
		base = paypalSandbox
	}
	return payPalClientAt(cfg, base)
}

func payPalClientAt(cfg *config.Config, base string) *paypalClient {
	key := clientcredentials.Config{
		ClientID:     cfg.PayPalClientID,
		ClientSecret: cfg.PayPalSecret,
		TokenURL:     base + "/v1/oauth2/token",
		AuthStyle:    oauth2.AuthStyleInHeader,
	}
	// As for Google Play: fetching the token ignores the call's context.
	tokens := context.WithValue(context.Background(), oauth2.HTTPClient, &http.Client{Timeout: paypalTimeout})
	return &paypalClient{http: key.Client(tokens), base: base, webhookID: cfg.PayPalWebhookID}
}

// call sends body, if any, as JSON and decodes the answer into out.
// requestID makes a repeat of the call do nothing new at PayPal.
func (p *paypalClient) call(ctx context.Context, method, path string, body any, requestID string, out any) error {
	ctx, cancel := context.WithTimeout(ctx, paypalTimeout)
	defer cancel()
	var r io.Reader
	switch b := body.(type) {
	case nil:
	case []byte:
		r = bytes.NewReader(b)
	default:
		data, err := json.Marshal(b)
		if err != nil {
			return err
		}
		r = bytes.NewReader(data)
	}
	req, err := http.NewRequestWithContext(ctx, method, p.base+path, r)
	if err != nil {
		return err
	}
	// The Subscriptions schema requires this header even on its GET methods.
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	if method == http.MethodPost && (strings.HasPrefix(path, "/v2/checkout/orders") || path == "/v1/billing/subscriptions") {
		// These endpoints default to id/status/links. Capture reconciliation
		// needs purchase_units and its payments in the response as well.
		req.Header.Set("Prefer", "return=representation")
	}
	if requestID != "" {
		req.Header.Set("PayPal-Request-Id", requestID)
	}
	resp, err := p.http.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode >= 300 {
		var refused struct {
			Details []struct {
				Issue string `json:"issue"`
			} `json:"details"`
		}
		_ = json.NewDecoder(io.LimitReader(resp.Body, maxBody)).Decode(&refused)
		e := paypalRefusal{status: resp.StatusCode, debugID: resp.Header.Get("PayPal-Debug-Id")}
		if len(refused.Details) > 0 {
			e.issue = refused.Details[0].Issue
		}
		return e
	}
	if out == nil {
		return nil
	}
	return json.NewDecoder(io.LimitReader(resp.Body, maxBody)).Decode(out)
}

// paypalNotFound says whether PayPal doesn't know what was asked about.
func paypalNotFound(err error) bool {
	var refused paypalRefusal
	return errors.As(err, &refused) && refused.status == http.StatusNotFound
}

type paypalMoney struct {
	Currency string `json:"currency_code"`
	Value    string `json:"value"`
}

type paypalLink struct {
	Href string `json:"href"`
	Rel  string `json:"rel"`
}

type paypalName struct {
	GivenName string `json:"given_name"`
	Surname   string `json:"surname"`
}

func (n paypalName) String() string {
	return strings.TrimSpace(n.GivenName + " " + n.Surname)
}

type paypalOrder struct {
	ID     string `json:"id"`
	Status string `json:"status"`
	Payer  struct {
		Name paypalName `json:"name"`
	} `json:"payer"`
	PurchaseUnits []struct {
		CustomID string `json:"custom_id"`
		Payments struct {
			Captures []paypalCapture `json:"captures"`
		} `json:"payments"`
	} `json:"purchase_units"`
	Links []paypalLink `json:"links"`
}

type paypalCapture struct {
	ID         string      `json:"id"`
	Status     string      `json:"status"`
	Amount     paypalMoney `json:"amount"`
	CreateTime time.Time   `json:"create_time"`
	// SupplementaryData names the order, in a capture's own events.
	SupplementaryData struct {
		RelatedIDs struct {
			OrderID string `json:"order_id"`
		} `json:"related_ids"`
	} `json:"supplementary_data"`
	Links []paypalLink `json:"links"`
}

type paypalSubscription struct {
	ID         string `json:"id"`
	Status     string `json:"status"`
	PlanID     string `json:"plan_id"`
	CustomID   string `json:"custom_id"`
	Subscriber struct {
		Name paypalName `json:"name"`
	} `json:"subscriber"`
	BillingInfo struct {
		NextBillingTime     *time.Time  `json:"next_billing_time"`
		FailedPaymentsCount int         `json:"failed_payments_count"`
		OutstandingBalance  paypalMoney `json:"outstanding_balance"`
		LastFailedPayment   *struct {
			Time time.Time `json:"time"`
		} `json:"last_failed_payment"`
		LastPayment *struct {
			Amount paypalMoney `json:"amount"`
			Time   time.Time   `json:"time"`
		} `json:"last_payment"`
		CycleExecutions []paypalCycleExecution `json:"cycle_executions"`
	} `json:"billing_info"`
	Links []paypalLink `json:"links"`
}

type paypalCycleExecution struct {
	TenureType      string `json:"tenure_type"` // TRIAL or REGULAR
	CyclesCompleted int    `json:"cycles_completed"`
}

func linkTo(links []paypalLink, rels ...string) string {
	for _, rel := range rels {
		for _, l := range links {
			if l.Rel == rel {
				return l.Href
			}
		}
	}
	return ""
}

// paypalAmount writes a price as PayPal wants it in currency.
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

// paypalEvent is the part of a webhook event the server reads: only what
// to ask PayPal about.
type paypalEvent struct {
	EventType string `json:"event_type"`
	Resource  struct {
		ID                 string `json:"id"`
		BillingAgreementID string `json:"billing_agreement_id"`
		SaleID             string `json:"sale_id"`
		SupplementaryData  struct {
			RelatedIDs struct {
				OrderID string `json:"order_id"`
			} `json:"related_ids"`
		} `json:"supplementary_data"`
		Links []paypalLink `json:"links"`
	} `json:"resource"`
}

// verified asks PayPal whether it sent the event. The event goes back as it
// came, since the signature covers its bytes.
func (p *paypalClient) verified(ctx context.Context, r *http.Request, event []byte) (bool, error) {
	if p.webhookID == "" {
		return false, nil
	}
	signed := map[string]string{
		"auth_algo":         r.Header.Get("PAYPAL-AUTH-ALGO"),
		"cert_url":          r.Header.Get("PAYPAL-CERT-URL"),
		"transmission_id":   r.Header.Get("PAYPAL-TRANSMISSION-ID"),
		"transmission_sig":  r.Header.Get("PAYPAL-TRANSMISSION-SIG"),
		"transmission_time": r.Header.Get("PAYPAL-TRANSMISSION-TIME"),
	}
	// What PayPal could never have sent isn't worth asking it about.
	for _, v := range signed {
		if v == "" {
			return false, nil
		}
	}
	if cert, err := url.Parse(signed["cert_url"]); err != nil || cert.Scheme != "https" ||
		cert.Hostname() != "paypal.com" && !strings.HasSuffix(cert.Hostname(), ".paypal.com") {
		return false, nil
	}
	signed["webhook_id"] = p.webhookID
	fields, err := json.Marshal(signed)
	if err != nil {
		return false, err
	}
	body := append(fields[:len(fields)-1], `,"webhook_event":`...)
	body = append(append(body, event...), '}')
	var out struct {
		Status string `json:"verification_status"`
	}
	err = p.call(ctx, http.MethodPost, "/v1/notifications/verify-webhook-signature", body, "", &out)
	var refused paypalRefusal
	if errors.As(err, &refused) && refused.status == http.StatusBadRequest {
		return false, nil
	}
	return out.Status == "SUCCESS", err
}

// orderOf finds the order a capture or refund event is about: the event may
// say, or else its link up leads to the capture, which does.
func (p *paypalClient) orderOf(ctx context.Context, ev *paypalEvent) (string, error) {
	if id := ev.Resource.SupplementaryData.RelatedIDs.OrderID; id != "" {
		return id, nil
	}
	up, err := url.Parse(linkTo(ev.Resource.Links, "up"))
	if err != nil {
		return "", nil
	}
	if id, ok := strings.CutPrefix(up.Path, "/v2/checkout/orders/"); ok {
		return id, nil
	}
	captureID, ok := strings.CutPrefix(up.Path, "/v2/payments/captures/")
	if !ok || !paypalID.MatchString(captureID) {
		return "", nil
	}
	// Asked of PayPal itself, whatever host the link names.
	var capture paypalCapture
	if err := p.call(ctx, http.MethodGet, "/v2/payments/captures/"+captureID, nil, "", &capture); err != nil {
		if paypalNotFound(err) {
			return "", nil
		}
		return "", err
	}
	return capture.SupplementaryData.RelatedIDs.OrderID, nil
}

// PayPalWebhook takes in an event from PayPal. Anything but a 2xx makes
// PayPal send it again, which only a failure here wants.
func (s *Server) PayPalWebhook(w http.ResponseWriter, r *http.Request) {
	pp := s.settings.Load().paypal
	if pp == nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}
	event, err := io.ReadAll(r.Body)
	var ev paypalEvent
	if err != nil || json.Unmarshal(event, &ev) != nil {
		writeError(w, http.StatusBadRequest, "bad_request")
		return
	}
	ok, err := pp.verified(r.Context(), r, event)
	if err != nil {
		s.log.Error("asking paypal about a webhook failed", "err", err)
		writeError(w, http.StatusInternalServerError, "internal")
		return
	}
	if !ok {
		noteMiss(r.Context())
		s.warnRejected("paypal")
		writeError(w, http.StatusForbidden, "invalid_token")
		return
	}
	var orderID, subID string
	switch t := ev.EventType; {
	case strings.HasPrefix(t, "CHECKOUT.ORDER."):
		orderID = ev.Resource.ID
	case strings.HasPrefix(t, "PAYMENT.CAPTURE."):
		orderID, err = pp.orderOf(r.Context(), &ev)
	case strings.HasPrefix(t, "BILLING.SUBSCRIPTION."):
		subID = ev.Resource.ID
	case t == "PAYMENT.SALE.REFUNDED" || t == "PAYMENT.SALE.REVERSED":
		err = s.refundPayPalSale(r.Context(), pp, &ev)
	case strings.HasPrefix(t, "PAYMENT.SALE."):
		subID = ev.Resource.BillingAgreementID
	}
	switch {
	case err != nil:
	case paypalID.MatchString(orderID):
		_, _, err = s.syncPayPalOrder(r.Context(), pp, orderID)
	case paypalID.MatchString(subID):
		_, err = s.syncPayPalSubscription(r.Context(), pp, subID)
	}
	if err != nil {
		s.log.Error("taking a paypal event failed", "event", ev.EventType, "err", err)
		writeError(w, http.StatusInternalServerError, "internal")
		return
	}
	w.WriteHeader(http.StatusOK)
}
