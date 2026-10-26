// Package push sends notifications to the Android app through Firebase Cloud
// Messaging (the HTTP v1 API).
package push

import (
	"bytes"
	"context"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/jwt"

	"balnana/internal/config"
)

// Message is one notification for one phone.
//
// The text comes from the app's Android string resources, so it is in the
// phone's language: BodyKey names a string and BodyArgs fill it in.
type Message struct {
	Device   string
	Title    string
	BodyKey  string
	BodyArgs []string
	// Tag replaces an earlier notification with the same tag.
	Tag  string
	Data map[string]string
}

// ErrGone means the device token no longer works and should be forgotten.
var ErrGone = errors.New("push: device is no longer registered")

type Sender interface {
	Send(ctx context.Context, m Message) error
}

const scope = "https://www.googleapis.com/auth/firebase.messaging"

// FCM sends through the Firebase project the service account belongs to.
type FCM struct {
	client *http.Client
	url    string
}

func NewFCM(a *config.FCMAccount) (*FCM, error) {
	block, _ := pem.Decode([]byte(a.PrivateKey))
	if block == nil {
		return nil, errors.New("push: the service account's private key is not PEM")
	}
	if _, err := x509.ParsePKCS8PrivateKey(block.Bytes); err != nil {
		return nil, fmt.Errorf("push: the service account's private key: %w", err)
	}
	jc := &jwt.Config{Email: a.ClientEmail, PrivateKey: []byte(a.PrivateKey), TokenURL: a.TokenURI, Scopes: []string{scope}}
	ctx := context.WithValue(context.Background(), oauth2.HTTPClient, &http.Client{Timeout: 10 * time.Second})
	client := oauth2.NewClient(ctx, jc.TokenSource(ctx))
	client.Timeout = 10 * time.Second
	return &FCM{client: client, url: "https://fcm.googleapis.com/v1/projects/" + url.PathEscape(a.ProjectID) + "/messages:send"}, nil
}

func (f *FCM) Send(ctx context.Context, m Message) error {
	body, err := json.Marshal(map[string]any{"message": wire(m)})
	if err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, f.url, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	res, err := f.client.Do(req)
	if err != nil {
		return err
	}
	defer res.Body.Close()
	reply, _ := io.ReadAll(io.LimitReader(res.Body, 64<<10))
	switch {
	case res.StatusCode == http.StatusOK:
		return nil
	// UNREGISTERED, or SENDER_ID_MISMATCH for a token of another project.
	case res.StatusCode == http.StatusNotFound || res.StatusCode == http.StatusForbidden && bytes.Contains(reply, []byte("SENDER_ID_MISMATCH")):
		return ErrGone
	default:
		return fmt.Errorf("push: FCM answered %d: %s", res.StatusCode, reply)
	}
}

// wire is m in the shape FCM expects.
func wire(m Message) map[string]any {
	args := m.BodyArgs
	if args == nil {
		args = []string{}
	}
	notification := map[string]any{"body_loc_key": m.BodyKey, "body_loc_args": args}
	if m.Tag != "" {
		notification["tag"] = m.Tag
	}
	return map[string]any{
		"token":        m.Device,
		"notification": map[string]any{"title": m.Title},
		"android":      map[string]any{"notification": notification},
		"data":         m.Data,
	}
}
