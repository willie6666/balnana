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

// kofiSupport are the kinds of payment that buy a plan by their amount. Ko-fi
// documents a one-off tip as Tip, while its examples send Donation.
var kofiSupport = []string{"Tip", "Donation", "Subscription"}

// A price as Ko-fi and the admin page write it. Anything else is not read as
// an amount, and a payment with no amount only reaches a plan by its tier.
var decimalAmount = regexp.MustCompile(`^[0-9]{1,10}(\.[0-9]{1,2})?$`)

// payment is a provider's report of one payment.
type payment struct {
	provider  string
	eventID   string
	kind      string
	email     *string
	name      *string
	amount    *string
	currency  *string
	product   *string
	recurring bool
	paidAt    time.Time
}

// kofiEvent is the JSON Ko-fi sends in the form's data field.
type kofiEvent struct {
	VerificationToken string  `json:"verification_token"`
	MessageID         string  `json:"message_id"`
	Timestamp         string  `json:"timestamp"`
	Type              string  `json:"type"`
	FromName          string  `json:"from_name"`
	Email             string  `json:"email"`
	Amount            string  `json:"amount"`
	Currency          string  `json:"currency"`
	Subscription      bool    `json:"is_subscription_payment"`
	TierName          *string `json:"tier_name"`
}

func optional(s string) *string {
	if s = strings.TrimSpace(s); s != "" {
		return &s
	}
	return nil
}

// KofiWebhook records a payment Ko-fi reports. It works with billing off, so
// that the connection can be tried before charging anyone. Anything but a
// 200 makes Ko-fi send the same message again, which is what a failure wants
// and a repeat doesn't need.
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
		email:     optional(ev.Email),
		name:      optional(ev.FromName),
		currency:  optional(strings.ToUpper(ev.Currency)),
		recurring: ev.Subscription,
		paidAt:    paidAt,
	}
	if ev.TierName != nil {
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

// recordPayment keeps p, once, and gives it to its account if it can tell
// whose it is. A payment nobody can place yet stays for later: see
// claimPayments and AssignAdminPayment.
func recordPayment(ctx context.Context, tx pgx.Tx, p payment) error {
	planID, days, err := matchProduct(ctx, tx, p)
	if err != nil {
		return err
	}
	state := "unmatched"
	if planID != nil {
		state = "unclaimed"
	}
	var id string
	err = tx.QueryRow(ctx, `
		insert into payment_events (provider, event_id, kind, email, payer_name, amount, currency, product,
		                            recurring, state, plan_id, days, paid_at)
		values ($1, $2, $3, $4, $5, $6::numeric, $7, $8, $9, $10, $11, $12, $13)
		on conflict (provider, event_id) do nothing
		returning id::text`,
		p.provider, p.eventID, p.kind, p.email, p.name, p.amount, p.currency, p.product,
		p.recurring, state, planID, days, p.paidAt).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil // heard already
	}
	if err != nil || p.email == nil {
		return err
	}
	// An address someone proved first, then the account's own if confirmed:
	// anyone could sign up with a payer's address and wait for the payment.
	var userID *string
	err = tx.QueryRow(ctx, `
		select coalesce((select user_id from payment_emails where email = $1),
		                (select id from users where email = $1 and email_verified))::text`, *p.email).Scan(&userID)
	if err != nil || userID == nil {
		return err
	}
	if planID == nil {
		_, err = tx.Exec(ctx, `update payment_events set user_id = $1 where id = $2`, *userID, id)
		return err
	}
	if err := holdAccount(ctx, tx, *userID); err != nil {
		return err
	}
	return applyPayment(ctx, tx, id, *userID)
}

// matchProduct finds what p bought: by its membership tier, or else by how
// much a donation or membership paid. Shop orders and commissions buy goods
// and only an administrator can turn them into a plan.
func matchProduct(ctx context.Context, q querier, p payment) (planID *string, days *int, err error) {
	if p.product != nil {
		err = q.QueryRow(ctx, `
			select plan_id, days from plan_products
			where provider = $1 and product <> '' and lower(product) = lower($2) limit 1`,
			p.provider, *p.product).Scan(&planID, &days)
		if err == nil || !errors.Is(err, pgx.ErrNoRows) {
			return planID, days, err
		}
	}
	if p.provider != "kofi" || !slices.Contains(kofiSupport, p.kind) || p.amount == nil || p.currency == nil {
		return nil, nil, nil
	}
	err = q.QueryRow(ctx, `
		select plan_id, days from plan_products
		where provider = $1 and product = '' and currency = $2 and min_amount <= $3::numeric
		order by min_amount desc limit 1`, p.provider, *p.currency, *p.amount).Scan(&planID, &days)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil, nil
	}
	return planID, days, err
}

// applyPayment turns the payment into time on its plan. A membership's
// payment runs from when it was paid, so that renewing a little early adds
// nothing; a one-off adds to what is left. It needs the account held, so that
// two payments can't both start an entitlement, and gives a payment only once.
func applyPayment(ctx context.Context, tx pgx.Tx, paymentID, userID string) error {
	var provider, planID string
	var days int
	var recurring bool
	var paidAt time.Time
	err := tx.QueryRow(ctx, `
		select provider, plan_id, days, recurring, paid_at from payment_events
		where id = $1 and state <> 'applied' for update`, paymentID).
		Scan(&provider, &planID, &days, &recurring, &paidAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil
	}
	if err != nil {
		return err
	}
	var entitlement string
	err = tx.QueryRow(ctx, `
		select e.id::text from entitlements e
		where e.user_id = $1 and e.plan_id = $2 and e.source = $3 and `+entitlementActive+`
		order by e.expires_at desc nulls first limit 1 for update`, userID, planID, provider).Scan(&entitlement)
	switch {
	case errors.Is(err, pgx.ErrNoRows):
		start := time.Now()
		if recurring {
			start = paidAt
		}
		err = tx.QueryRow(ctx, `
			insert into entitlements (user_id, plan_id, source, starts_at, expires_at)
			values ($1, $2, $3, least($4::timestamptz, now()), $4::timestamptz + make_interval(days => $5))
			returning id::text`, userID, planID, provider, start, days).Scan(&entitlement)
		if err != nil {
			return err
		}
	case err != nil:
		return err
	default:
		_, err = tx.Exec(ctx, `
			update entitlements set expires_at = case
				when $2 then greatest(expires_at, $3::timestamptz + make_interval(days => $4))
				else expires_at + make_interval(days => $4) end
			where id = $1 and expires_at is not null`, entitlement, recurring, paidAt, days)
		if err != nil {
			return err
		}
	}
	_, err = tx.Exec(ctx, `update payment_events set state = 'applied', user_id = $1, entitlement_id = $2 where id = $3`,
		userID, entitlement, paymentID)
	return err
}

// claimPayments gives userID the payments waiting for an address it has
// shown is its own.
func claimPayments(ctx context.Context, tx pgx.Tx, userID string) error {
	rows, err := tx.Query(ctx, `
		select id::text from payment_events
		where state = 'unclaimed' and email in (
			select email from payment_emails where user_id = $1
			union
			select u.email from users u
			where u.id = $1 and u.email_verified
			  and not exists (select 1 from payment_emails e where e.email = u.email and e.user_id <> $1))
		order by paid_at`, userID)
	if err != nil {
		return err
	}
	ids, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil || len(ids) == 0 {
		return err
	}
	if err := holdAccount(ctx, tx, userID); err != nil {
		return err
	}
	for _, id := range ids {
		if err := applyPayment(ctx, tx, id, userID); err != nil {
			return err
		}
	}
	return nil
}
