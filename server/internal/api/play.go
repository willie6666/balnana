package api

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/coreos/go-oidc/v3/oidc"
	"github.com/jackc/pgx/v5"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/jwt"

	"balnana/internal/config"
)

// Subscriptions through Google Play. The app reports what it bought, Google
// tells the server about every later change (real-time developer
// notifications, pushed through Pub/Sub), and either way the server only
// believes what the Developer API says of the purchase.

const (
	playPath     = BasePath + "/webhooks/play"
	playAPI      = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/"
	playScope    = "https://www.googleapis.com/auth/androidpublisher"
	playTokenURL = "https://oauth2.googleapis.com/token"
	googleCerts  = "https://www.googleapis.com/oauth2/v3/certs"
	playTimeout  = 15 * time.Second
	// maxPurchaseToken is far longer than the tokens Google hands out.
	maxPurchaseToken = 4096
)

var (
	// errPlayPurchase is a token Google doesn't know, or no longer does.
	errPlayPurchase     = badRequest("invalid_purchase")
	errPlayOtherAccount = conflict("play_other_account")
	errPlayUnavailable  = &apiError{status: http.StatusServiceUnavailable, code: "play_unavailable"}
	// errPlayUnacknowledged is a purchase that counts here but that Google
	// wasn't told about, which is to be tried again.
	errPlayUnacknowledged = errors.New("acknowledging a google play purchase failed")
)

// playRefusal is an answer from the Developer API other than a success.
type playRefusal struct{ status int }

func (e playRefusal) Error() string {
	return fmt.Sprintf("google play: %d %s", e.status, http.StatusText(e.status))
}

// playClient talks to Google Play for one app.
type playClient struct {
	packageName string
	http        *http.Client
	base        string
	// pushAccount is who signs notifications, and push checks their tokens.
	// Without them notifications are turned away, and renewals arrive only
	// when someone opens their plan.
	pushAccount string
	push        *oidc.IDTokenVerifier
}

// newPlayClient is nil until the app's package and a service account are set.
func newPlayClient(cfg *config.Config, audience string) *playClient {
	if cfg.PlayPackage == "" || cfg.PlayServiceAccount == nil {
		return nil
	}
	key := jwt.Config{
		Email:      cfg.PlayServiceAccount.Email,
		PrivateKey: []byte(cfg.PlayServiceAccount.PrivateKey),
		Scopes:     []string{playScope},
		TokenURL:   playTokenURL,
	}
	// Fetching the access token ignores the context of the call it is for, and
	// every other call waits for it, so it needs a limit of its own.
	tokens := context.WithValue(context.Background(), oauth2.HTTPClient, &http.Client{Timeout: playTimeout})
	c := &playClient{packageName: cfg.PlayPackage, http: key.Client(tokens), base: playAPI}
	if cfg.PlayPushAccount != "" {
		keys := oidc.NewRemoteKeySet(context.Background(), googleCerts)
		c.pushAccount = cfg.PlayPushAccount
		c.push = oidc.NewVerifier(googleIssuer, keys, &oidc.Config{ClientID: audience})
	}
	return c
}

// playSubscription is the part of a SubscriptionPurchaseV2 the server reads.
type playSubscription struct {
	State           string         `json:"subscriptionState"`
	Acknowledgement string         `json:"acknowledgementState"`
	LinkedToken     string         `json:"linkedPurchaseToken"`
	Account         playAccount    `json:"externalAccountIdentifiers"`
	OutOfApp        playOutOfApp   `json:"outOfAppPurchaseContext"`
	LineItems       []playLineItem `json:"lineItems"`
}

type playAccount struct {
	Obfuscated string `json:"obfuscatedExternalAccountId"`
}

// playOutOfApp names the subscription someone came back to from the store,
// where the app can't say whose purchase it is.
type playOutOfApp struct {
	Account      playAccount `json:"expiredExternalAccountIdentifiers"`
	ExpiredToken string      `json:"expiredPurchaseToken"`
}

type playLineItem struct {
	ProductID string    `json:"productId"`
	Expiry    time.Time `json:"expiryTime"`
	OrderID   string    `json:"latestSuccessfulOrderId"`
}

// paidUntil is when the access this subscription gives ends: zero if it gives
// none now. A subscription in its grace period or cancelled still has the
// time it was paid for, and Google moves expiryTime to the end of the grace.
func (p *playSubscription) paidUntil() time.Time {
	switch p.State {
	case "SUBSCRIPTION_STATE_ACTIVE", "SUBSCRIPTION_STATE_IN_GRACE_PERIOD", "SUBSCRIPTION_STATE_CANCELED":
		return p.LineItems[0].Expiry
	}
	return time.Time{}
}

// call asks the Developer API about a purchase and decodes the answer into out.
func (p *playClient) call(ctx context.Context, method, path string, body io.Reader, out any) error {
	ctx, cancel := context.WithTimeout(ctx, playTimeout)
	defer cancel()
	req, err := http.NewRequestWithContext(ctx, method, p.base+url.PathEscape(p.packageName)+path, body)
	if err != nil {
		return err
	}
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	resp, err := p.http.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	switch {
	case resp.StatusCode >= 300:
		return playRefusal{resp.StatusCode}
	case out == nil:
		return nil
	}
	return json.NewDecoder(io.LimitReader(resp.Body, maxBody)).Decode(out)
}

func (p *playClient) subscription(ctx context.Context, token string) (*playSubscription, error) {
	var sub playSubscription
	if err := p.call(ctx, http.MethodGet, "/purchases/subscriptionsv2/tokens/"+url.PathEscape(token), nil, &sub); err != nil {
		var refused playRefusal
		if errors.As(err, &refused) &&
			(refused.status == http.StatusBadRequest || refused.status == http.StatusNotFound || refused.status == http.StatusGone) {
			return nil, errPlayPurchase
		}
		return nil, err
	}
	if len(sub.LineItems) == 0 {
		return nil, errPlayPurchase
	}
	return &sub, nil
}

// acknowledge keeps the purchase: Google refunds one left unacknowledged for
// three days.
func (p *playClient) acknowledge(ctx context.Context, productID, token string) error {
	path := "/purchases/subscriptions/" + url.PathEscape(productID) + "/tokens/" + url.PathEscape(token) + ":acknowledge"
	return p.call(ctx, http.MethodPost, path, strings.NewReader("{}"), nil)
}

// playAccountID is what the app gives Google to mark a purchase as the
// account's. Google asks for it to be one-way.
func playAccountID(userID string) string {
	sum := sha256.Sum256([]byte(userID))
	return hex.EncodeToString(sum[:])
}

// playOwner finds whose purchase this is: the account of the token or of the
// one it follows, or else the account the app named when buying it.
func playOwner(ctx context.Context, q querier, token string, sub *playSubscription) (*string, error) {
	var owner *string
	err := q.QueryRow(ctx, `select user_id::text from play_subscriptions where purchase_token = any($1) limit 1`,
		[]string{token, sub.LinkedToken, sub.OutOfApp.ExpiredToken}).Scan(&owner)
	if err == nil || !errors.Is(err, pgx.ErrNoRows) {
		return owner, err
	}
	err = q.QueryRow(ctx, `
		select id::text from users where encode(sha256(convert_to(id::text, 'UTF8')), 'hex') = any($1) limit 1`,
		[]string{sub.Account.Obfuscated, sub.OutOfApp.Account.Obfuscated}).Scan(&owner)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return owner, err
}

// syncPlay brings the account in line with what Google says of the purchase.
// reporter is the account that says it bought it, if any: with no sign of
// whose it is, the token shows it holds the purchase.
func (s *Server) syncPlay(ctx context.Context, play *playClient, token string, reporter *string) error {
	sub, err := play.subscription(ctx, token)
	if err != nil {
		return err
	}
	var keep bool
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		keep, err = applyPlay(ctx, tx, token, sub, reporter)
		return err
	})
	if err != nil || !keep {
		return err
	}
	if err := play.acknowledge(ctx, sub.LineItems[0].ProductID, token); err != nil {
		return fmt.Errorf("%w: %w", errPlayUnacknowledged, err)
	}
	return nil
}

// applyPlay records the subscription and sets its entitlement. It says
// whether to acknowledge the purchase: not one that buys nothing here, which
// Google then refunds.
func applyPlay(ctx context.Context, tx pgx.Tx, token string, sub *playSubscription, reporter *string) (bool, error) {
	owner, err := playOwner(ctx, tx, token, sub)
	if err != nil {
		return false, err
	}
	switch {
	case owner == nil && reporter == nil:
		return false, nil // the app will report it
	case owner == nil:
		owner = reporter
	case reporter != nil && *owner != *reporter:
		return false, errPlayOtherAccount
	}
	if err := holdAccount(ctx, tx, *owner); err != nil {
		return false, err
	}
	line := sub.LineItems[0]
	planID, _, err := matchProduct(ctx, tx, payment{provider: "play", product: &line.ProductID})
	if err != nil {
		return false, err
	}
	var entitlement *string
	err = tx.QueryRow(ctx, `select entitlement_id::text from play_subscriptions where purchase_token = $1 for update`,
		token).Scan(&entitlement)
	if errors.Is(err, pgx.ErrNoRows) {
		err = nil // first heard of now
	}
	if err != nil {
		return false, err
	}
	until := sub.paidUntil()
	switch {
	case until.IsZero() && entitlement != nil:
		_, err = tx.Exec(ctx, `update entitlements set expires_at = least(expires_at, now()) where id = $1`, *entitlement)
	case until.IsZero():
	case planID == nil:
		// Nothing to give: an administrator sees it among the payments.
	case entitlement != nil:
		_, err = tx.Exec(ctx, `update entitlements set plan_id = $2, expires_at = $3 where id = $1`, *entitlement, *planID, until)
	default:
		err = tx.QueryRow(ctx, `
			insert into entitlements (user_id, plan_id, source, expires_at) values ($1, $2, 'play', $3)
			returning id::text`, *owner, *planID, until).Scan(&entitlement)
	}
	if err != nil {
		return false, err
	}
	// The purchase it replaced stops counting once this one gives something,
	// whatever comes of its own news. Until then it is what was paid for.
	if planID != nil && !until.IsZero() {
		_, err = tx.Exec(ctx, `
			update entitlements set expires_at = least(expires_at, now())
			where id = (select entitlement_id from play_subscriptions where purchase_token = $1)`, sub.LinkedToken)
		if err != nil {
			return false, err
		}
	}
	_, err = tx.Exec(ctx, `
		insert into play_subscriptions (purchase_token, user_id, product_id, entitlement_id) values ($1, $2, $3, $4)
		on conflict (purchase_token) do update set product_id = excluded.product_id, entitlement_id = excluded.entitlement_id`,
		token, *owner, line.ProductID, entitlement)
	if err != nil {
		return false, err
	}
	keep := planID != nil && !until.IsZero() && sub.Acknowledgement == "ACKNOWLEDGEMENT_STATE_PENDING"
	if line.OrderID == "" || until.IsZero() {
		return keep, nil
	}
	state := "unmatched"
	if planID != nil {
		state = "applied"
	}
	_, err = tx.Exec(ctx, `
		insert into payment_events (provider, event_id, kind, product, recurring, state, plan_id, user_id, entitlement_id, paid_at)
		values ('play', $1, 'Subscription', $2, true, $3, $4, $5, $6, now())
		on conflict (provider, event_id) do update
		set state = excluded.state, plan_id = excluded.plan_id, entitlement_id = excluded.entitlement_id
		where payment_events.state <> 'applied'`,
		line.OrderID, line.ProductID, state, planID, *owner, entitlement)
	return keep, err
}

// playOffer is what the account can do through Google Play, if anything.
func (s *Server) playOffer(ctx context.Context, q querier, userID string) (*PlayBilling, error) {
	play := s.settings.Load().play
	if play == nil {
		return nil, nil
	}
	rows, err := q.Query(ctx, `select distinct product from plan_products where provider = 'play' order by product`)
	if err != nil {
		return nil, err
	}
	products, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil || len(products) == 0 {
		return nil, err
	}
	rows, err = q.Query(ctx, `
		select distinct ps.product_id from play_subscriptions ps
		join entitlements e on e.id = ps.entitlement_id and `+entitlementActive+`
		where ps.user_id = $1 order by ps.product_id`, userID)
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
	return &PlayBilling{
		AccountId:   playAccountID(userID),
		PackageName: play.packageName,
		Products:    products,
		Subscribed:  subscribed,
	}, nil
}

func (s *Server) ReportPlayPurchase(ctx context.Context, req ReportPlayPurchaseRequestObject) (ReportPlayPurchaseResponseObject, error) {
	if err := s.requireBilling(); err != nil {
		return nil, err
	}
	u, err := s.requireUser(ctx)
	if err != nil {
		return nil, err
	}
	play := s.settings.Load().play
	if play == nil {
		return nil, errNotFound
	}
	token := req.Body.PurchaseToken
	if token == "" || len(token) > maxPurchaseToken {
		return nil, errPlayPurchase
	}
	err = s.syncPlay(ctx, play, token, &u.id)
	var known *apiError
	switch {
	case errors.Is(err, errPlayUnacknowledged):
		// The plan is theirs already. The next report or notification retries.
		s.log.Error("taking a google play purchase failed", "err", err)
	case errors.As(err, &known):
		return nil, err
	case err != nil:
		s.log.Error("asking google play failed", "err", err)
		return nil, errPlayUnavailable
	}
	out, err := s.myPlan(ctx, s.db, u.id)
	if err != nil {
		return nil, err
	}
	return ReportPlayPurchase200JSONResponse(out), nil
}

// playPush is a Pub/Sub push message. Go decodes data from its base64.
type playPush struct {
	Message struct {
		Data []byte `json:"data"`
	} `json:"message"`
}

// playNotification is a real-time developer notification, which says only
// that something happened to a purchase.
type playNotification struct {
	PackageName  string `json:"packageName"`
	Subscription *struct {
		PurchaseToken string `json:"purchaseToken"`
	} `json:"subscriptionNotification"`
	Voided *struct {
		PurchaseToken string `json:"purchaseToken"`
		ProductType   int    `json:"productType"`
	} `json:"voidedPurchaseNotification"`
}

// playPushed checks that Google's Pub/Sub sent the request, signing as the
// account the subscription was set up with. Anyone can have Google sign a
// token for this audience: the account is what tells this one apart.
func (p *playClient) playPushed(r *http.Request) bool {
	bearer, ok := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer ")
	if !ok || p.push == nil {
		return false
	}
	token, err := p.push.Verify(r.Context(), strings.TrimSpace(bearer))
	if err != nil {
		return false
	}
	var claims struct {
		Email    string `json:"email"`
		Verified bool   `json:"email_verified"`
	}
	return token.Claims(&claims) == nil && claims.Verified && strings.EqualFold(claims.Email, p.pushAccount)
}

// PlayWebhook takes in a notification from Google Play. Anything but a 2xx
// makes Pub/Sub send it again, which only a failure here wants.
func (s *Server) PlayWebhook(w http.ResponseWriter, r *http.Request) {
	play := s.settings.Load().play
	if play == nil || play.push == nil {
		writeError(w, http.StatusNotFound, "not_found")
		return
	}
	if !play.playPushed(r) {
		noteMiss(r.Context())
		writeError(w, http.StatusForbidden, "invalid_token")
		return
	}
	var push playPush
	var n playNotification
	if json.NewDecoder(r.Body).Decode(&push) != nil || json.Unmarshal(push.Message.Data, &n) != nil {
		writeError(w, http.StatusBadRequest, "bad_request")
		return
	}
	var token string
	switch {
	case n.PackageName != play.packageName: // sent by mistake; it won't get better
	case n.Subscription != nil:
		token = n.Subscription.PurchaseToken
	case n.Voided != nil && n.Voided.ProductType == 1:
		token = n.Voided.PurchaseToken
	}
	if token != "" {
		if err := s.syncPlay(r.Context(), play, token, nil); err != nil && !errors.Is(err, errPlayPurchase) {
			s.log.Error("taking a google play notification failed", "err", err)
			writeError(w, http.StatusInternalServerError, "internal")
			return
		}
	}
	w.WriteHeader(http.StatusOK)
}
