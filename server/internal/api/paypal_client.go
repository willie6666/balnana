package api

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/clientcredentials"

	"balnana/internal/config"
)

const (
	paypalLive    = "https://api-m.paypal.com"
	paypalSandbox = "https://api-m.sandbox.paypal.com"
	paypalTimeout = 15 * time.Second
)

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
