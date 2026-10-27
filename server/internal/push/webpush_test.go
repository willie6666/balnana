package push

import (
	"bytes"
	"context"
	"crypto/aes"
	"crypto/cipher"
	"crypto/ecdh"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/hkdf"
	"crypto/sha256"
	"encoding/binary"
	"encoding/json"
	"errors"
	"io"
	"math/big"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

func mustDecode(t *testing.T, s string) []byte {
	t.Helper()
	b, err := decode(s)
	if err != nil {
		t.Fatal(err)
	}
	return b
}

// The example in RFC 8291, section 5.
func TestEncryptRFC8291(t *testing.T) {
	as, err := ecdh.P256().NewPrivateKey(mustDecode(t, "yfWPiYE-n46HLnH0KqZOF1fJJU3MYrct3AELtAQ-oRw"))
	if err != nil {
		t.Fatal(err)
	}
	sub := Subscription{
		P256dh: "BCVxsr7N_eNgVRqvHtD0zTZsEc6-VV-JvLexhqUzORcxaOzi6-AYWXvTBHm4bjyPjs7Vd8pZGH6SRpkNtoIAiw4",
		Auth:   "BTBZMqHH6r4Tts7J_aSIgg",
	}
	got, err := encrypt([]byte("When I grow up, I want to be a watermelon"), sub, mustDecode(t, "DGv6ra1nlYgDCS1FRnbzlw"), as)
	if err != nil {
		t.Fatal(err)
	}
	const want = "DGv6ra1nlYgDCS1FRnbzlwAAEABBBP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A_yl95bQpu6cVPTpK4Mqgkf1CXztLVBSt2Ks3oZwbuwXPXLWyouBWLVWGNWQexSgSxsj_Qulcy4a-fN"
	if b64.EncodeToString(got) != want {
		t.Fatalf("got %s", b64.EncodeToString(got))
	}
}

// phone is the receiving end of a subscription.
type phone struct {
	priv *ecdh.PrivateKey
	auth []byte
}

func newPhone(t *testing.T) *phone {
	priv, err := ecdh.P256().GenerateKey(nil)
	if err != nil {
		t.Fatal(err)
	}
	return &phone{priv, []byte("0123456789abcdef")}
}

func (p *phone) sub(endpoint string) Subscription {
	return Subscription{Endpoint: endpoint, P256dh: b64.EncodeToString(p.priv.PublicKey().Bytes()), Auth: b64.EncodeToString(p.auth)}
}

// decrypt opens a message as RFC 8291 says the phone does.
func (p *phone) decrypt(t *testing.T, body []byte) []byte {
	t.Helper()
	salt, rs, idlen := body[:16], binary.BigEndian.Uint32(body[16:20]), int(body[20])
	if rs != recordSize || idlen != 65 {
		t.Fatalf("rs %d idlen %d", rs, idlen)
	}
	asPub, err := ecdh.P256().NewPublicKey(body[21 : 21+idlen])
	if err != nil {
		t.Fatal(err)
	}
	secret, err := p.priv.ECDH(asPub)
	if err != nil {
		t.Fatal(err)
	}
	info := append(append([]byte("WebPush: info\x00"), p.priv.PublicKey().Bytes()...), asPub.Bytes()...)
	ikm, _ := hkdf.Key(sha256.New, secret, p.auth, string(info), 32)
	prk, _ := hkdf.Extract(sha256.New, ikm, salt)
	cek, _ := hkdf.Expand(sha256.New, prk, "Content-Encoding: aes128gcm\x00", 16)
	nonce, _ := hkdf.Expand(sha256.New, prk, "Content-Encoding: nonce\x00", 12)
	block, _ := aes.NewCipher(cek)
	gcm, _ := cipher.NewGCM(block)
	plain, err := gcm.Open(nil, nonce, body[21+idlen:], nil)
	if err != nil {
		t.Fatal(err)
	}
	if plain[len(plain)-1] != 2 {
		t.Fatalf("delimiter %d", plain[len(plain)-1])
	}
	return plain[:len(plain)-1]
}

func TestSend(t *testing.T) {
	key, err := NewKey()
	if err != nil {
		t.Fatal(err)
	}
	if again, err := ParseKey(key.Bytes()); err != nil || again.Public() != key.Public() {
		t.Fatalf("parsed key %v", err)
	}
	p := newPhone(t)
	var got *http.Request
	var body []byte
	status := http.StatusCreated
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		got = r
		body, _ = io.ReadAll(r.Body)
		w.WriteHeader(status)
	}))
	defer ts.Close()
	now := time.Unix(1_800_000_000, 0)
	w := NewWebPush(key, func() string { return "https://balnana.example" }, true)
	w.now = func() time.Time { return now }
	m := Message{Subscription: p.sub(ts.URL + "/push/abc"), Payload: []byte(`{"hi":1}`), Topic: "t1", Urgency: "normal", TTL: time.Hour}
	if err := w.Send(context.Background(), m); err != nil {
		t.Fatal(err)
	}
	if got.URL.Path != "/push/abc" || got.Header.Get("Content-Encoding") != "aes128gcm" || got.Header.Get("TTL") != "3600" ||
		got.Header.Get("Topic") != "t1" || got.Header.Get("Urgency") != "normal" {
		t.Errorf("request %s %v", got.URL, got.Header)
	}
	if plain := p.decrypt(t, body); string(plain) != `{"hi":1}` {
		t.Errorf("payload %q", plain)
	}

	// The VAPID claim is signed with key, for this push service.
	auth, ok := strings.CutPrefix(got.Header.Get("Authorization"), "vapid t=")
	token, k, ok2 := strings.Cut(auth, ", k=")
	if !ok || !ok2 || k != key.Public() {
		t.Fatalf("authorization %q", got.Header.Get("Authorization"))
	}
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		t.Fatalf("token %q", token)
	}
	pub, err := ecdsa.ParseUncompressedPublicKey(elliptic.P256(), mustDecode(t, k))
	if err != nil {
		t.Fatal(err)
	}
	sig := mustDecode(t, parts[2])
	digest := sha256.Sum256([]byte(parts[0] + "." + parts[1]))
	if len(sig) != 64 || !ecdsa.Verify(pub, digest[:], new(big.Int).SetBytes(sig[:32]), new(big.Int).SetBytes(sig[32:])) {
		t.Fatal("bad signature")
	}
	var claims struct {
		Aud string `json:"aud"`
		Exp int64  `json:"exp"`
		Sub string `json:"sub"`
	}
	if err := json.Unmarshal(mustDecode(t, parts[1]), &claims); err != nil {
		t.Fatal(err)
	}
	if claims.Aud != ts.URL || claims.Exp != now.Add(vapidLifetime).Unix() || claims.Sub != "https://balnana.example" {
		t.Errorf("claims %+v", claims)
	}

	status = http.StatusGone
	if err := w.Send(context.Background(), m); !errors.Is(err, ErrGone) {
		t.Errorf("gone: %v", err)
	}
	status = http.StatusTooManyRequests
	if err := w.Send(context.Background(), m); err == nil || errors.Is(err, ErrGone) || strings.Contains(err.Error(), "/push/abc") {
		t.Errorf("busy: %v", err)
	}
	m.Payload = bytes.Repeat([]byte("a"), MaxPayload+1)
	if err := w.Send(context.Background(), m); err == nil {
		t.Error("sent a payload too big")
	}
}

// Without allowPrivate, the server reaches nothing on its own network, even
// through a name that leads there.
func TestSendPublicOnly(t *testing.T) {
	key, _ := NewKey()
	hit := false
	ts := httptest.NewTLSServer(http.HandlerFunc(func(http.ResponseWriter, *http.Request) { hit = true }))
	defer ts.Close()
	w := NewWebPush(key, func() string { return "mailto:a@example.com" }, false)
	w.client.Transport.(*http.Transport).TLSClientConfig = ts.Client().Transport.(*http.Transport).TLSClientConfig
	p := newPhone(t)
	for _, endpoint := range []string{ts.URL, strings.Replace(ts.URL, "127.0.0.1", "localhost", 1)} {
		err := w.Send(context.Background(), Message{Subscription: p.sub(endpoint + "/x"), Payload: []byte("x")})
		if err == nil || !strings.Contains(err.Error(), "not a public address") || strings.Contains(err.Error(), "/x") {
			t.Errorf("%s: %v", endpoint, err)
		}
	}
	if hit {
		t.Error("reached a private address")
	}
}

func TestCheck(t *testing.T) {
	p := newPhone(t)
	good := p.sub("https://fcm.googleapis.com/fcm/send/abc")
	if err := Check(good, false); err != nil {
		t.Fatal(err)
	}
	padded := good
	padded.Auth += "=="
	if err := Check(padded, false); err != nil {
		t.Errorf("padded: %v", err)
	}
	for name, c := range map[string]struct {
		sub          Subscription
		allowPrivate bool
	}{
		"http":       {p.sub("http://ntfy.example.com/up"), false},
		"no host":    {p.sub("https:///x"), false},
		"user":       {p.sub("https://a:b@ntfy.example.com/up"), false},
		"loopback":   {p.sub("https://127.0.0.1/up"), false},
		"private":    {p.sub("https://[fd00::1]/up"), false},
		"cgnat":      {p.sub("https://100.64.1.1/up"), false},
		"localhost":  {p.sub("https://localhost/up"), false},
		"ftp":        {p.sub("ftp://ntfy.example.com/up"), true},
		"long":       {p.sub("https://ntfy.example.com/" + strings.Repeat("a", maxEndpoint)), false},
		"bad key":    {Subscription{Endpoint: good.Endpoint, P256dh: b64.EncodeToString(make([]byte, 65)), Auth: good.Auth}, false},
		"short auth": {Subscription{Endpoint: good.Endpoint, P256dh: good.P256dh, Auth: "AAAA"}, false},
	} {
		if err := Check(c.sub, c.allowPrivate); err == nil {
			t.Errorf("%s: allowed", name)
		}
	}
	for _, endpoint := range []string{"http://192.168.1.2:8080/up", "https://localhost/up"} {
		if err := Check(p.sub(endpoint), true); err != nil {
			t.Errorf("%s with private allowed: %v", endpoint, err)
		}
	}
}
