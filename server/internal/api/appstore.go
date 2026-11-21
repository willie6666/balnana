package api

import (
	"context"
	"crypto/sha256"
	"crypto/x509"
	_ "embed"
	"encoding/asn1"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/go-jose/go-jose/v4"
	"github.com/jackc/pgx/v5"

	"balnana/internal/config"
)

// Subscriptions through the App Store. StoreKit 2 hands the app every
// transaction as a JWS that Apple signed, and App Store Server Notifications
// V2 bring renewals, refunds and expiries signed the same way. The server
// checks each signature up to Apple's root certificate, so it needs no key
// of its own: it believes nothing Apple didn't sign.

const (
	appStorePath = BasePath + "/webhooks/appstore"
	// maxSignedTransaction is far longer than the JWS Apple hands out.
	maxSignedTransaction = 16 << 10
	appStoreProduction   = "Production"
)

var (
	errAppStorePurchase     = badRequest("invalid_purchase")
	errAppStoreOtherAccount = conflict("appstore_other_account")
)

// appleRootG3 is Apple Root CA - G3, which every App Store signature chains to.
//
//go:embed apple_root_ca_g3.pem
var appleRootG3 []byte

// Apple marks the certificates it signs App Store data with: the leaf with
// the first, the Apple Worldwide Developer Relations intermediate with the
// second.
var (
	oidAppStoreReceiptSigner = asn1.ObjectIdentifier{1, 2, 840, 113635, 100, 6, 11, 1}
	oidAppleWWDRIntermediate = asn1.ObjectIdentifier{1, 2, 840, 113635, 100, 6, 2, 1}
)

// appStoreClient checks what the App Store says of one app.
type appStoreClient struct {
	bundleID string
	sandbox  bool // take sandbox transactions too
	roots    *x509.CertPool
}

// newAppStoreClient is nil until the iOS app's bundle ID is set.
func newAppStoreClient(cfg *config.Config) *appStoreClient {
	if cfg.AppleBundleID == "" {
		return nil
	}
	roots := x509.NewCertPool()
	if !roots.AppendCertsFromPEM(appleRootG3) {
		panic("apple root certificate does not parse")
	}
	return &appStoreClient{bundleID: cfg.AppleBundleID, sandbox: cfg.AppStoreSandbox, roots: roots}
}

// appStoreSigned is the part of any signed App Store payload that says when
// it was signed.
type appStoreSigned struct {
	SignedDate int64 `json:"signedDate"`
}

// verify checks that Apple signed the JWS and decodes its payload into out.
// The chain is checked as of when Apple says it signed: a transaction the
// device kept since then stays good after the certificate it was signed with
// expires. A payload claiming to be signed in the future is not believed.
func (a *appStoreClient) verify(signed string, out any) error {
	if len(signed) > maxSignedTransaction {
		return errAppStorePurchase
	}
	jws, err := jose.ParseSigned(signed, []jose.SignatureAlgorithm{jose.ES256})
	if err != nil || len(jws.Signatures) != 1 {
		return errAppStorePurchase
	}
	var claimed appStoreSigned
	if json.Unmarshal(jws.UnsafePayloadWithoutVerification(), &claimed) != nil || claimed.SignedDate <= 0 {
		return errAppStorePurchase
	}
	at := time.UnixMilli(claimed.SignedDate)
	if at.After(time.Now().Add(5 * time.Minute)) {
		return errAppStorePurchase
	}
	chains, err := jws.Signatures[0].Protected.Certificates(x509.VerifyOptions{
		Roots:       a.roots,
		CurrentTime: at,
		KeyUsages:   []x509.ExtKeyUsage{x509.ExtKeyUsageAny},
	})
	if err != nil || !appleChain(chains) {
		return errAppStorePurchase
	}
	payload, err := jws.Verify(chains[0][0].PublicKey)
	if err != nil {
		return errAppStorePurchase
	}
	if json.Unmarshal(payload, out) != nil {
		return errAppStorePurchase
	}
	return nil
}

// appleChain reports whether a chain is the one Apple signs App Store data
// with: Apple's root alone would also vouch for certificates made for
// anything else Apple signs.
func appleChain(chains [][]*x509.Certificate) bool {
	for _, chain := range chains {
		if len(chain) == 3 && hasExtension(chain[0], oidAppStoreReceiptSigner) && hasExtension(chain[1], oidAppleWWDRIntermediate) {
			return true
		}
	}
	return false
}

func hasExtension(c *x509.Certificate, id asn1.ObjectIdentifier) bool {
	for _, e := range c.Extensions {
		if e.Id.Equal(id) {
			return true
		}
	}
	return false
}

// appStoreTransaction is the part of a JWSTransactionDecodedPayload the
// server reads. Times are milliseconds since the epoch, 0 when left out.
type appStoreTransaction struct {
	TransactionID         string `json:"transactionId"`
	OriginalTransactionID string `json:"originalTransactionId"`
	BundleID              string `json:"bundleId"`
	ProductID             string `json:"productId"`
	Type                  string `json:"type"`
	PurchaseDate          int64  `json:"purchaseDate"`
	ExpiresDate           int64  `json:"expiresDate"`
	RevocationDate        int64  `json:"revocationDate"`
	IsUpgraded            bool   `json:"isUpgraded"`
	AppAccountToken       string `json:"appAccountToken"`
	Environment           string `json:"environment"`
	Price                 int64  `json:"price"` // in thousandths of the currency
	Currency              string `json:"currency"`
}

// appStoreRenewal is the part of a JWSRenewalInfoDecodedPayload the server
// reads.
type appStoreRenewal struct {
	OriginalTransactionID  string `json:"originalTransactionId"`
	GracePeriodExpiresDate int64  `json:"gracePeriodExpiresDate"`
}

// transaction checks a signed transaction and that it is a subscription of
// this app, from an environment this server takes.
func (a *appStoreClient) transaction(signed string) (*appStoreTransaction, error) {
	var t appStoreTransaction
	if err := a.verify(signed, &t); err != nil {
		return nil, err
	}
	switch {
	case t.BundleID != a.bundleID,
		t.Type != "Auto-Renewable Subscription",
		t.TransactionID == "", t.OriginalTransactionID == "", t.ProductID == "", t.PurchaseDate <= 0,
		t.Environment != appStoreProduction && !a.sandbox:
		return nil, errAppStorePurchase
	}
	return &t, nil
}

// paidUntil is when the access this transaction gives ends: zero if it gives
// none, because it was refunded or replaced by an upgrade. grace is the end
// of a billing grace period Apple reported for it, if any.
func (t *appStoreTransaction) paidUntil(grace int64) time.Time {
	if t.RevocationDate > 0 || t.IsUpgraded || t.ExpiresDate <= 0 {
		return time.Time{}
	}
	return time.UnixMilli(max(t.ExpiresDate, grace))
}

// appStoreAccountToken is what the app gives StoreKit as appAccountToken to
// mark a purchase as the account's. The migration computes the same for
// users.appstore_account_token.
func appStoreAccountToken(userID string) string {
	sum := sha256.Sum256([]byte("appstore:" + userID))
	h := hex.EncodeToString(sum[:16])
	return h[0:8] + "-" + h[8:12] + "-" + h[12:16] + "-" + h[16:20] + "-" + h[20:32]
}

// appStoreOwner finds whose subscription this is: the account already on
// record for it, or else the one the app named when buying it.
func appStoreOwner(ctx context.Context, q querier, t *appStoreTransaction) (*string, error) {
	var owner *string
	err := q.QueryRow(ctx, `select user_id::text from appstore_subscriptions where original_transaction_id = $1`,
		t.OriginalTransactionID).Scan(&owner)
	if err == nil || !errors.Is(err, pgx.ErrNoRows) {
		return owner, err
	}
	if t.AppAccountToken == "" {
		return nil, nil
	}
	err = q.QueryRow(ctx, `select id::text from users where appstore_account_token::text = lower($1)`,
		t.AppAccountToken).Scan(&owner)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return owner, err
}

// syncAppStore applies a transaction Apple signed. reporter is the account
// that says it bought it, if any. grace is the end of a billing grace period
// from the renewal info that came with it. Everything for one subscription
// happens under one lock, or an older transaction could overwrite a newer one.
func (s *Server) syncAppStore(ctx context.Context, t *appStoreTransaction, grace int64, reporter *string) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `select pg_advisory_xact_lock(hashtextextended($1, 0))`,
			"appstore:"+t.OriginalTransactionID); err != nil {
			return err
		}
		return applyAppStore(ctx, tx, t, grace, reporter)
	})
}

func applyAppStore(ctx context.Context, tx pgx.Tx, t *appStoreTransaction, grace int64, reporter *string) error {
	owner, err := appStoreOwner(ctx, tx, t)
	if err != nil {
		return err
	}
	switch {
	case owner == nil && reporter == nil:
		return nil // the app will report it
	case owner == nil:
		owner = reporter
	case reporter != nil && *owner != *reporter:
		return errAppStoreOtherAccount
	}
	if err := holdAccount(ctx, tx, *owner); err != nil {
		return err
	}
	var entitlement *string
	var latest time.Time
	var known bool
	err = tx.QueryRow(ctx, `
		select entitlement_id::text, purchased_at from appstore_subscriptions
		where original_transaction_id = $1 for update`, t.OriginalTransactionID).Scan(&entitlement, &latest)
	switch {
	case errors.Is(err, pgx.ErrNoRows):
	case err != nil:
		return err
	default:
		known = true
	}
	planID, _, err := matchProduct(ctx, tx, payment{provider: "appstore", product: &t.ProductID})
	if err != nil {
		return err
	}
	purchased := time.UnixMilli(t.PurchaseDate)
	// An older transaction arriving late, or one an upgrade replaced, leaves
	// the access to the latest: only its payment is kept, refunded or not.
	if known && purchased.Before(latest) {
		return recordAppStorePayment(ctx, tx, t, *owner, planID, entitlement)
	}
	until := t.paidUntil(grace)
	active := !until.IsZero() && until.After(time.Now())
	switch {
	case until.IsZero() && entitlement != nil:
		_, err = tx.Exec(ctx, `update entitlements set expires_at = least(expires_at, now()) where id = $1`, *entitlement)
	case until.IsZero(), planID == nil:
		// Nothing to give: an administrator sees an unknown product among the payments.
	case entitlement != nil:
		_, err = tx.Exec(ctx, `update entitlements set plan_id = $2, expires_at = $3 where id = $1`, *entitlement, *planID, until)
	case active:
		var note *string
		if t.Environment != appStoreProduction {
			sandbox := "App Store sandbox"
			note = &sandbox
		}
		err = tx.QueryRow(ctx, `
			insert into entitlements (user_id, plan_id, source, note, expires_at) values ($1, $2, 'appstore', $3, $4)
			returning id::text`, *owner, *planID, note, until).Scan(&entitlement)
	}
	if err != nil {
		return err
	}
	var expires *time.Time
	if !until.IsZero() {
		expires = &until
	}
	_, err = tx.Exec(ctx, `
		insert into appstore_subscriptions (original_transaction_id, user_id, product_id, entitlement_id, environment, purchased_at, expires_at)
		values ($1, $2, $3, $4, $5, $6, $7)
		on conflict (original_transaction_id) do update
		set product_id = excluded.product_id, entitlement_id = excluded.entitlement_id,
		    purchased_at = excluded.purchased_at, expires_at = excluded.expires_at`,
		t.OriginalTransactionID, *owner, t.ProductID, entitlement, t.Environment, purchased, expires)
	if err != nil {
		return err
	}
	return recordAppStorePayment(ctx, tx, t, *owner, planID, entitlement)
}

// recordAppStorePayment keeps each payment of the subscription, by its
// transaction, among the payments an administrator sees. A refund marks it.
func recordAppStorePayment(ctx context.Context, tx pgx.Tx, t *appStoreTransaction, owner string, planID, entitlement *string) error {
	state := "unmatched"
	switch {
	case t.RevocationDate > 0:
		state = "refunded"
	case planID != nil:
		state = "applied"
	}
	var amount, currency *string
	if t.Price > 0 && len(t.Currency) == 3 {
		a := fmt.Sprintf("%d.%03d", t.Price/1000, t.Price%1000)
		amount, currency = &a, &t.Currency
	}
	_, err := tx.Exec(ctx, `
		insert into payment_events (provider, event_id, kind, product, amount, currency, recurring, state, plan_id, user_id, entitlement_id, paid_at)
		values ('appstore', $1, 'Subscription', $2, $3, $4, true, $5, $6, $7, $8, $9)
		on conflict (provider, event_id) do update
		set state = excluded.state, plan_id = excluded.plan_id, entitlement_id = excluded.entitlement_id
		where payment_events.state <> excluded.state and payment_events.state <> 'refunded'`,
		t.TransactionID, t.ProductID, amount, currency, state, planID, owner, entitlement, time.UnixMilli(t.PurchaseDate))
	return err
}

// appStoreOffer is what the account can do through the App Store, if anything.
func (s *Server) appStoreOffer(ctx context.Context, q querier, userID string) (*AppStoreBilling, error) {
	if s.settings.Load().appStore == nil {
		return nil, nil
	}
	rows, err := q.Query(ctx, `select distinct product from plan_products where provider = 'appstore' order by product`)
	if err != nil {
		return nil, err
	}
	products, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil || len(products) == 0 {
		return nil, err
	}
	rows, err = q.Query(ctx, `
		select distinct a.product_id from appstore_subscriptions a
		join entitlements e on e.id = a.entitlement_id and `+entitlementActive+`
		where a.user_id = $1 order by a.product_id`, userID)
	if err != nil {
		return nil, err
	}
	subscribed, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil {
		return nil, err
	}
	if subscribed == nil {
		subscribed = []string{}
	}
	return &AppStoreBilling{
		AccountToken: appStoreAccountToken(userID),
		Products:     products,
		Subscribed:   subscribed,
	}, nil
}

func (s *Server) ReportAppStorePurchase(ctx context.Context, req ReportAppStorePurchaseRequestObject) (ReportAppStorePurchaseResponseObject, error) {
	if err := s.requireBilling(); err != nil {
		return nil, err
	}
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	store := s.settings.Load().appStore
	if store == nil {
		return nil, errNotFound
	}
	t, err := store.transaction(req.Body.SignedTransaction)
	if err != nil {
		noteMiss(ctx)
		return nil, err
	}
	if err := s.syncAppStore(ctx, t, 0, &u.id); err != nil {
		return nil, err
	}
	out, err := s.myPlan(ctx, s.db, u.id)
	if err != nil {
		return nil, err
	}
	return ReportAppStorePurchase200JSONResponse(out), nil
}

// appStoreNotification is the part of a responseBodyV2DecodedPayload the
// server reads.
type appStoreNotification struct {
	NotificationType string `json:"notificationType"`
	Data             *struct {
		BundleID              string `json:"bundleId"`
		SignedTransactionInfo string `json:"signedTransactionInfo"`
		SignedRenewalInfo     string `json:"signedRenewalInfo"`
	} `json:"data"`
}

// AppStoreWebhook takes in an App Store Server Notification V2. Apple sends
// one again unless it gets a 2xx, which only a failure here wants.
func (s *Server) AppStoreWebhook(w http.ResponseWriter, r *http.Request) {
	store := s.settings.Load().appStore
	if store == nil || !s.conf().Billing {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}
	var body struct {
		SignedPayload string `json:"signedPayload"`
	}
	if json.NewDecoder(io.LimitReader(r.Body, maxBody)).Decode(&body) != nil {
		writeError(w, http.StatusBadRequest, "bad_request")
		return
	}
	var n appStoreNotification
	if err := store.verify(body.SignedPayload, &n); err != nil {
		noteMiss(r.Context())
		s.warnRejected("appstore")
		writeError(w, http.StatusForbidden, "invalid_token")
		return
	}
	// A test notification, one for another app, or one with no transaction
	// (such as a consumption request) has nothing to apply.
	if n.Data == nil || n.Data.BundleID != store.bundleID || n.Data.SignedTransactionInfo == "" {
		w.WriteHeader(http.StatusOK)
		return
	}
	t, err := store.transaction(n.Data.SignedTransactionInfo)
	if err != nil {
		w.WriteHeader(http.StatusOK) // not one this server takes; it won't get better
		return
	}
	var grace int64
	if n.Data.SignedRenewalInfo != "" {
		var renewal appStoreRenewal
		if store.verify(n.Data.SignedRenewalInfo, &renewal) == nil && renewal.OriginalTransactionID == t.OriginalTransactionID {
			grace = renewal.GracePeriodExpiresDate
		}
	}
	if err := s.syncAppStore(r.Context(), t, grace, nil); err != nil {
		s.log.Error("taking an app store notification failed", "type", n.NotificationType, "err", err)
		writeError(w, http.StatusInternalServerError, "internal")
		return
	}
	w.WriteHeader(http.StatusOK)
}
