package push

import (
	"context"
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"balnana/internal/config"
)

func testAccount(t *testing.T, tokenURL string) *config.FCMAccount {
	t.Helper()
	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	der, err := x509.MarshalPKCS8PrivateKey(key)
	if err != nil {
		t.Fatal(err)
	}
	pemKey := pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: der})
	return &config.FCMAccount{ProjectID: "demo", ClientEmail: "push@demo.iam.gserviceaccount.com", PrivateKey: string(pemKey), TokenURI: tokenURL}
}

func TestSend(t *testing.T) {
	var got map[string]map[string]any
	var auth string
	status := http.StatusOK
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/token" {
			w.Header().Set("Content-Type", "application/json")
			io.WriteString(w, `{"access_token":"at","token_type":"Bearer","expires_in":3600}`)
			return
		}
		if r.URL.Path != "/v1/projects/demo/messages:send" {
			t.Errorf("path %s", r.URL.Path)
		}
		auth = r.Header.Get("Authorization")
		json.NewDecoder(r.Body).Decode(&got)
		w.WriteHeader(status)
		io.WriteString(w, `{"error":{"status":"NOT_FOUND","details":[{"errorCode":"UNREGISTERED"}]}}`)
	}))
	defer srv.Close()

	f, err := NewFCM(testAccount(t, srv.URL+"/token"))
	if err != nil {
		t.Fatal(err)
	}
	f.url = srv.URL + "/v1/projects/demo/messages:send"
	m := Message{Device: "dev", Title: "Flat", BodyKey: "push_expense_added", BodyArgs: []string{"Ana", "Pizza", "10.00 USD"}, Tag: "e1", Data: map[string]string{"group": "tok"}}
	if err := f.Send(context.Background(), m); err != nil {
		t.Fatal(err)
	}
	if auth != "Bearer at" {
		t.Errorf("auth %q", auth)
	}
	msg := got["message"]
	android := msg["android"].(map[string]any)["notification"].(map[string]any)
	if msg["fid"] != "dev" || msg["token"] != nil || msg["notification"].(map[string]any)["title"] != "Flat" || android["body_loc_key"] != "push_expense_added" || android["tag"] != "e1" {
		t.Errorf("message %v", msg)
	}

	status = http.StatusNotFound
	if err := f.Send(context.Background(), m); !errors.Is(err, ErrGone) {
		t.Errorf("unregistered: %v", err)
	}
	status = http.StatusInternalServerError
	if err := f.Send(context.Background(), m); err == nil || errors.Is(err, ErrGone) {
		t.Errorf("server error: %v", err)
	}
}

func TestBadKey(t *testing.T) {
	a := testAccount(t, "http://unused")
	a.PrivateKey = strings.Replace(a.PrivateKey, "PRIVATE KEY", "NOT A KEY", 2)[:40]
	if _, err := NewFCM(a); err == nil {
		t.Fatal("accepted a broken key")
	}
}
