package api

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"net/url"
	"strings"
)

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
