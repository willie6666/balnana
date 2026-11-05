package api

import (
	"context"
	"crypto/subtle"
	"encoding/json"
	"errors"
	"net/http"
	"regexp"
	"slices"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
)

const kofiPath = BasePath + "/webhooks/kofi"

var errPaymentNotFound = &apiError{status: http.StatusNotFound, code: "payment_not_found"}

// kofiSupport are the kinds of payment that buy a plan by their amount. Ko-fi
// documents a one-off tip as Tip, while its examples send Donation.
// Memberships aren't sold here: an administrator decides what one buys.
var kofiSupport = []string{"Tip", "Donation"}

// kofiShopOrder is the kind of a purchase from a Ko-fi shop, which buys a
// plan by the items in it.
const kofiShopOrder = "Shop Order"

// kofiSampleTransaction is the ID in Ko-fi's published sample, which its test
// messages can carry. Anyone can look it up, so it proves nothing.
const kofiSampleTransaction = "00000000-1111-2222-3333-444444444444"

// A price as Ko-fi and the admin page write it. Anything else is not read as
// an amount, and a payment with no amount only reaches a plan by its product.
var decimalAmount = regexp.MustCompile(`^[0-9]{1,10}(\.[0-9]{1,2})?$`)

// A transaction ID, which is also part of the link to a Ko-fi payment.
var uuidInText = regexp.MustCompile(`[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}`)

// paymentReference reduces what a provider or a payer gave to a transaction
// ID: payers may paste the whole link.
func paymentReference(s string) string {
	s = strings.ToLower(strings.TrimSpace(s))
	if id := uuidInText.FindString(s); id != "" {
		return id
	}
	return s
}

// kofiReference is the ID to keep for claiming a Ko-fi payment, if it has one
// only its payer knows.
func kofiReference(transactionID string) *string {
	if id := paymentReference(transactionID); id != kofiSampleTransaction {
		return optional(id)
	}
	return nil
}

// kofiItemCode is a shop item as the admin page names it: the code at the end
// of its link, ko-fi.com/s/<code>, which may be pasted whole.
func kofiItemCode(s string) string {
	s = strings.TrimSpace(s)
	if i := strings.Index(strings.ToLower(s), "ko-fi.com/s/"); i >= 0 {
		s = s[i+len("ko-fi.com/s/"):]
		s, _, _ = strings.Cut(s, "?")
		s = strings.Trim(s, "/")
	}
	return s
}

// payment is a provider's report of one payment.
type payment struct {
	provider  string
	eventID   string
	kind      string
	name      *string
	amount    *string
	currency  *string
	product   *string
	items     []kofiShopItem // what a shop order bought
	paidAt    time.Time
	reference *string // the provider's ID for the transaction
}

// kofiEvent is the JSON Ko-fi sends in the form's data field. The payer's
// message and email aren't read: only the transaction ID ties a payment to
// an account.
type kofiEvent struct {
	VerificationToken string         `json:"verification_token"`
	MessageID         string         `json:"message_id"`
	Timestamp         string         `json:"timestamp"`
	Type              string         `json:"type"`
	FromName          string         `json:"from_name"`
	Amount            string         `json:"amount"`
	Currency          string         `json:"currency"`
	TierName          *string        `json:"tier_name"`
	TransactionID     string         `json:"kofi_transaction_id"`
	ShopItems         []kofiShopItem `json:"shop_items"`
}

type kofiShopItem struct {
	Code     string `json:"direct_link_code"`
	Quantity int    `json:"quantity"`
}

func optional(s string) *string {
	if s = strings.TrimSpace(s); s != "" {
		return &s
	}
	return nil
}

// KofiWebhook records a payment Ko-fi reports, for its payer to claim by its
// transaction ID. It works with billing off, so that the connection can be
// tried before charging anyone. Anything but a 200 makes Ko-fi send the same
// message again, which is what a failure wants and a repeat doesn't need.
func (s *Server) KofiWebhook(w http.ResponseWriter, r *http.Request) {
	token := s.conf().KofiToken
	if token == "" {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}
	var ev kofiEvent
	if err := r.ParseForm(); err != nil || json.Unmarshal([]byte(r.PostForm.Get("data")), &ev) != nil {
		writeError(w, http.StatusBadRequest, "bad_request")
		return
	}
	if subtle.ConstantTimeCompare([]byte(ev.VerificationToken), []byte(token)) != 1 {
		noteMiss(r.Context())
		s.warnRejected("kofi")
		writeError(w, http.StatusForbidden, "invalid_token")
		return
	}
	if ev.MessageID == "" {
		writeError(w, http.StatusBadRequest, "bad_request")
		return
	}
	paidAt, err := time.Parse(time.RFC3339, ev.Timestamp)
	if err != nil {
		paidAt = time.Now()
	}
	p := payment{
		provider:  "kofi",
		eventID:   ev.MessageID,
		kind:      ev.Type,
		name:      optional(ev.FromName),
		currency:  optional(strings.ToUpper(ev.Currency)),
		paidAt:    paidAt,
		reference: kofiReference(ev.TransactionID),
	}
	switch {
	case ev.Type == kofiShopOrder:
		p.items = ev.ShopItems
		if len(p.items) > 0 {
			p.product = optional(p.items[0].Code)
		}
	case ev.TierName != nil:
		p.product = optional(*ev.TierName)
	}
	if decimalAmount.MatchString(ev.Amount) {
		p.amount = &ev.Amount
	}
	if err := pgx.BeginFunc(r.Context(), s.db, func(tx pgx.Tx) error { return recordPayment(r.Context(), tx, p) }); err != nil {
		s.log.Error("recording a payment failed", "provider", p.provider, "err", err)
		writeError(w, http.StatusInternalServerError, "internal")
		return
	}
	w.WriteHeader(http.StatusOK)
}

// warnRejected tells the operator a provider's notification was turned away:
// with a wrong token every payment is, and nobody would know until someone
// complains. Anyone can send these, so the log hears of it now and then.
func (s *Server) warnRejected(provider string) {
	if s.rejected.take(provider, 1, time.Now()) {
		s.log.Warn("turned away a payment notification: check its token or account", "provider", provider)
	}
}

// recordPayment keeps p, once, until its payer claims it (see ClaimPayment)
// or an administrator gives it to someone (AssignAdminPayment).
func recordPayment(ctx context.Context, tx pgx.Tx, p payment) error {
	planID, days, err := matchKofi(ctx, tx, p)
	if err != nil {
		return err
	}
	state := "unmatched"
	if planID != nil {
		state = "unclaimed"
	}
	items := []byte("[]")
	if len(p.items) > 0 {
		items, err = json.Marshal(p.items)
	}
	if err != nil {
		return err
	}
	_, err = tx.Exec(ctx, `
		insert into payment_events (provider, event_id, kind, payer_name, amount, currency, product,
		                            state, plan_id, days, paid_at, reference, shop_items)
		values ($1, $2, $3, $4, $5::numeric, $6, $7, $8, $9, $10, $11, $12, $13)
		on conflict (provider, event_id) do nothing`,
		p.provider, p.eventID, p.kind, p.name, p.amount, p.currency, p.product,
		state, planID, days, p.paidAt, p.reference, items)
	return err
}

// matchKofi finds what a Ko-fi payment bought: the shop items of a plan, as
// many times over as were bought, or else a plan by how much a donation paid.
// Memberships and commissions buy nothing by themselves: only an
// administrator can turn them into a plan.
func matchKofi(ctx context.Context, q querier, p payment) (planID *string, days *int, err error) {
	if p.kind == kofiShopOrder {
		total := 0
		mixed := false
		for _, item := range p.items {
			var itemPlan string
			var itemDays int
			err := q.QueryRow(ctx, `
				select plan_id, days from plan_products
				where provider = 'kofi' and product <> '' and lower(product) = lower($1) limit 1`, item.Code).
				Scan(&itemPlan, &itemDays)
			if errors.Is(err, pgx.ErrNoRows) {
				continue
			}
			if err != nil {
				return nil, nil, err
			}
			// One payment gives one plan: items of another are for an administrator.
			if planID != nil && *planID != itemPlan {
				mixed = true
				continue
			}
			planID = &itemPlan
			total += itemDays * max(item.Quantity, 1)
		}
		if planID == nil || mixed {
			return nil, nil, nil
		}
		total = min(total, maxPlanDays)
		return planID, &total, nil
	}
	if !slices.Contains(kofiSupport, p.kind) || p.amount == nil || p.currency == nil {
		return nil, nil, nil
	}
	err = q.QueryRow(ctx, `
		select plan_id, days from plan_products
		where provider = 'kofi' and product = '' and currency = $1 and min_amount <= $2::numeric
		order by min_amount desc limit 1`, *p.currency, *p.amount).Scan(&planID, &days)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil, nil
	}
	return planID, days, err
}

// matchProduct finds the plan a provider's product buys, by its name.
func matchProduct(ctx context.Context, q querier, p payment) (planID *string, days *int, err error) {
	if p.product == nil {
		return nil, nil, nil
	}
	err = q.QueryRow(ctx, `
		select plan_id, days from plan_products
		where provider = $1 and product <> '' and (lower(product) = lower($2) or lower(without_trial) = lower($2)) limit 1`,
		p.provider, *p.product).Scan(&planID, &days)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil, nil
	}
	return planID, days, err
}

// oneOffEntitlement picks the entitlements (as e) that bought time adds to:
// the ones no subscription runs, whose end only payments move.
const oneOffEntitlement = `e.source in ('kofi', 'paypal') and e.expires_at is not null
	and not exists (select 1 from play_subscriptions ps where ps.entitlement_id = e.id)
	and not exists (select 1 from paypal_subscriptions pp where pp.entitlement_id = e.id)`

// applyPayment turns the payment into time on its plan, added to what is left
// of time bought earlier. It needs the account held, so that two payments
// can't both start an entitlement, and gives a payment only once. One whose
// plan was deleted gives nothing until an administrator picks another.
func applyPayment(ctx context.Context, tx pgx.Tx, paymentID, userID string) error {
	var provider, planID string
	var days int
	err := tx.QueryRow(ctx, `
		select provider, plan_id, days from payment_events
		where id = $1 and state not in ('applied', 'refunded') and plan_id is not null for update`, paymentID).
		Scan(&provider, &planID, &days)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil
	}
	if err != nil {
		return err
	}
	source := provider
	if source == "play" {
		source = "admin" // a Play payment an administrator placed by hand
	}
	var entitlement string
	err = tx.QueryRow(ctx, `
		select e.id::text from entitlements e
		where e.user_id = $1 and e.plan_id = $2 and `+entitlementActive+` and `+oneOffEntitlement+`
		order by e.expires_at desc limit 1 for update`, userID, planID).Scan(&entitlement)
	switch {
	case errors.Is(err, pgx.ErrNoRows):
		err = tx.QueryRow(ctx, `
			insert into entitlements (user_id, plan_id, source, expires_at)
			values ($1, $2, $3, now() + make_interval(days => $4))
			returning id::text`, userID, planID, source, days).Scan(&entitlement)
	case err == nil:
		_, err = tx.Exec(ctx, `update entitlements set expires_at = expires_at + make_interval(days => $2) where id = $1`,
			entitlement, days)
	}
	if err != nil {
		return err
	}
	_, err = tx.Exec(ctx, `update payment_events set state = 'applied', user_id = $1, entitlement_id = $2 where id = $3`,
		userID, entitlement, paymentID)
	return err
}
