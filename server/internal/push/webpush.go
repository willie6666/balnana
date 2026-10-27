// Package push sends notifications to the app as Web Push messages (RFC
// 8030): encrypted for the phone (RFC 8291) and signed with the server's
// VAPID key (RFC 8292). On Android they arrive through UnifiedPush, by
// whichever distributor the phone uses: the app's own embedded FCM
// distributor, or one such as ntfy. No Firebase project or SDK is involved.
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
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/netip"
	"net/url"
	"strconv"
	"strings"
	"syscall"
	"time"
)

// Subscription is where one phone receives its messages, and the keys they
// are encrypted with, as the phone's push distributor gave them.
type Subscription struct {
	Endpoint string
	// P256dh is the phone's P-256 public key, uncompressed, in base64url.
	P256dh string
	// Auth is the phone's 16-byte authentication secret, in base64url.
	Auth string
}

// Message is one notification for one phone.
type Message struct {
	Subscription
	Payload []byte
	// Topic replaces an undelivered message with the same topic: at most 32
	// base64url characters.
	Topic string
	// Urgency is "very-low", "low", "normal" or "high".
	Urgency string
	// TTL is how long the push service keeps the message for a phone that
	// is offline.
	TTL time.Duration
}

// ErrGone means the subscription has ended and should be forgotten.
var ErrGone = errors.New("push: the subscription has ended")

type Sender interface {
	Send(ctx context.Context, m Message) error
}

const (
	// recordSize is the one encrypted record a message is sent in.
	recordSize = 4096
	headerSize = 16 + 4 + 1 + 65
	// MaxPayload is the most a message can carry: what fits in one record
	// next to its header, padding delimiter and tag (4096 bytes in all, the
	// most push services must accept).
	MaxPayload    = recordSize - headerSize - 1 - 16
	maxEndpoint   = 2048
	vapidLifetime = 12 * time.Hour
)

var b64 = base64.RawURLEncoding

// Key is the server's VAPID key, which signs every message. Phones
// subscribe with its public half, so it must stay the same.
type Key struct{ priv *ecdsa.PrivateKey }

func NewKey() (*Key, error) {
	priv, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		return nil, err
	}
	return &Key{priv}, nil
}

// ParseKey reads a key saved with Bytes.
func ParseKey(b []byte) (*Key, error) {
	priv, err := ecdsa.ParseRawPrivateKey(elliptic.P256(), b)
	if err != nil {
		return nil, fmt.Errorf("push: VAPID key: %w", err)
	}
	return &Key{priv}, nil
}

// Bytes is the private key, to save.
func (k *Key) Bytes() []byte {
	b, _ := k.priv.Bytes()
	return b
}

// Public is the public key in base64url, as the app subscribes with it.
func (k *Key) Public() string {
	b, _ := k.priv.PublicKey.Bytes()
	return b64.EncodeToString(b)
}

// WebPush sends messages over HTTP.
type WebPush struct {
	key *Key
	// subject is how a push service can reach whoever runs the server: an
	// https or mailto URL.
	subject func() string
	client  *http.Client
	now     func() time.Time
}

// NewWebPush sends messages signed with key. Unless allowPrivate, it only
// sends to https endpoints on public addresses, so a subscription cannot
// make the server reach into its own network.
func NewWebPush(key *Key, subject func() string, allowPrivate bool) *WebPush {
	dialer := &net.Dialer{Timeout: 10 * time.Second}
	transport := &http.Transport{
		Proxy:               http.ProxyFromEnvironment,
		DialContext:         dialer.DialContext,
		ForceAttemptHTTP2:   true,
		MaxIdleConnsPerHost: 4,
		IdleConnTimeout:     90 * time.Second,
		TLSHandshakeTimeout: 10 * time.Second,
	}
	if !allowPrivate {
		// A proxy would dial for us, past the check.
		transport.Proxy = nil
		dialer.Control = func(_, address string, _ syscall.RawConn) error {
			ap, err := netip.ParseAddrPort(address)
			if err != nil {
				return err
			}
			if !publicAddr(ap.Addr()) {
				return fmt.Errorf("push: %s is not a public address", ap.Addr())
			}
			return nil
		}
	}
	return &WebPush{
		key:     key,
		subject: subject,
		client: &http.Client{
			Transport: transport,
			Timeout:   15 * time.Second,
			CheckRedirect: func(*http.Request, []*http.Request) error {
				return http.ErrUseLastResponse
			},
		},
		now: time.Now,
	}
}

func (w *WebPush) Send(ctx context.Context, m Message) error {
	u, err := url.Parse(m.Endpoint)
	if err != nil || u.Host == "" {
		return errors.New("push: bad endpoint")
	}
	salt := make([]byte, 16)
	rand.Read(salt)
	as, err := ecdh.P256().GenerateKey(rand.Reader)
	if err != nil {
		return err
	}
	body, err := encrypt(m.Payload, m.Subscription, salt, as)
	if err != nil {
		return err
	}
	token, err := w.vapid(u.Scheme + "://" + u.Host)
	if err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, m.Endpoint, bytes.NewReader(body))
	if err != nil {
		return errors.New("push: bad endpoint")
	}
	req.Header.Set("Authorization", "vapid t="+token+", k="+w.key.Public())
	req.Header.Set("Content-Encoding", "aes128gcm")
	req.Header.Set("Content-Type", "application/octet-stream")
	req.Header.Set("TTL", strconv.Itoa(int(m.TTL/time.Second)))
	if m.Urgency != "" {
		req.Header.Set("Urgency", m.Urgency)
	}
	if m.Topic != "" {
		req.Header.Set("Topic", m.Topic)
	}
	res, err := w.client.Do(req)
	if err != nil {
		// The endpoint is the phone's secret: name only its host.
		var ue *url.Error
		if errors.As(err, &ue) {
			err = ue.Err
		}
		return fmt.Errorf("push: %s: %w", u.Host, err)
	}
	defer res.Body.Close()
	reply, _ := io.ReadAll(io.LimitReader(res.Body, 512))
	switch {
	case res.StatusCode >= 200 && res.StatusCode < 300:
		return nil
	case res.StatusCode == http.StatusNotFound || res.StatusCode == http.StatusGone:
		return ErrGone
	default:
		return fmt.Errorf("push: %s answered %d: %s", u.Host, res.StatusCode, bytes.TrimSpace(reply))
	}
}

// vapid is the signed claim that the server sends to audience (RFC 8292).
func (w *WebPush) vapid(audience string) (string, error) {
	header := b64.EncodeToString([]byte(`{"typ":"JWT","alg":"ES256"}`))
	claims, err := json.Marshal(map[string]any{
		"aud": audience,
		"exp": w.now().Add(vapidLifetime).Unix(),
		"sub": w.subject(),
	})
	if err != nil {
		return "", err
	}
	signed := header + "." + b64.EncodeToString(claims)
	digest := sha256.Sum256([]byte(signed))
	r, s, err := ecdsa.Sign(rand.Reader, w.key.priv, digest[:])
	if err != nil {
		return "", err
	}
	sig := make([]byte, 64)
	r.FillBytes(sig[:32])
	s.FillBytes(sig[32:])
	return signed + "." + b64.EncodeToString(sig), nil
}

// encrypt seals plain for sub in one aes128gcm record (RFC 8291), with a
// fresh salt and key pair for each message.
func encrypt(plain []byte, sub Subscription, salt []byte, as *ecdh.PrivateKey) ([]byte, error) {
	if len(plain) > MaxPayload {
		return nil, fmt.Errorf("push: the payload is %d bytes, more than %d", len(plain), MaxPayload)
	}
	uaBytes, ua, auth, err := keys(sub)
	if err != nil {
		return nil, err
	}
	secret, err := as.ECDH(ua)
	if err != nil {
		return nil, err
	}
	asBytes := as.PublicKey().Bytes()
	info := append(append([]byte("WebPush: info\x00"), uaBytes...), asBytes...)
	ikm, err := hkdf.Key(sha256.New, secret, auth, string(info), 32)
	if err != nil {
		return nil, err
	}
	prk, err := hkdf.Extract(sha256.New, ikm, salt)
	if err != nil {
		return nil, err
	}
	cek, err := hkdf.Expand(sha256.New, prk, "Content-Encoding: aes128gcm\x00", 16)
	if err != nil {
		return nil, err
	}
	nonce, err := hkdf.Expand(sha256.New, prk, "Content-Encoding: nonce\x00", 12)
	if err != nil {
		return nil, err
	}
	block, err := aes.NewCipher(cek)
	if err != nil {
		return nil, err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}
	out := make([]byte, 0, headerSize+len(plain)+1+gcm.Overhead())
	out = append(out, salt...)
	out = binary.BigEndian.AppendUint32(out, recordSize)
	out = append(out, byte(len(asBytes)))
	out = append(out, asBytes...)
	// The last (and only) record ends with the delimiter 2 and no padding.
	record := append(append(make([]byte, 0, len(plain)+1), plain...), 2)
	return gcm.Seal(out, nonce, record, nil), nil
}

// keys decodes the phone's keys.
func keys(sub Subscription) (uaBytes []byte, ua *ecdh.PublicKey, auth []byte, err error) {
	uaBytes, err = decode(sub.P256dh)
	if err == nil {
		ua, err = ecdh.P256().NewPublicKey(uaBytes)
	}
	if err != nil {
		return nil, nil, nil, errors.New("push: p256dh is not a P-256 public key")
	}
	auth, err = decode(sub.Auth)
	if err != nil || len(auth) != 16 {
		return nil, nil, nil, errors.New("push: auth is not 16 bytes")
	}
	return uaBytes, ua, auth, nil
}

// decode reads base64url with or without padding.
func decode(s string) ([]byte, error) {
	return b64.DecodeString(strings.TrimRight(s, "="))
}

// Check reports whether the server can send to sub: its keys are sound and
// its endpoint is an https URL (or, with allowPrivate, http), not one on a
// private address unless allowPrivate. A host name that leads to a private
// address is caught when sending.
func Check(sub Subscription, allowPrivate bool) error {
	if _, _, _, err := keys(sub); err != nil {
		return err
	}
	if len(sub.Endpoint) > maxEndpoint {
		return errors.New("push: the endpoint is too long")
	}
	u, err := url.Parse(sub.Endpoint)
	if err != nil || u.Host == "" || u.User != nil || u.Fragment != "" {
		return errors.New("push: the endpoint is not a URL")
	}
	switch {
	case u.Scheme == "https":
	case u.Scheme == "http" && allowPrivate:
	default:
		return errors.New("push: the endpoint is not an https URL")
	}
	if !allowPrivate {
		host := u.Hostname()
		if a, err := netip.ParseAddr(host); err == nil && !publicAddr(a) || host == "localhost" ||
			strings.HasSuffix(host, ".localhost") {
			return errors.New("push: the endpoint is not on a public address")
		}
	}
	return nil
}

// Addresses that are not on the internet, beyond what netip names.
var reserved = []netip.Prefix{
	netip.MustParsePrefix("0.0.0.0/8"),
	netip.MustParsePrefix("100.64.0.0/10"), // carrier-grade NAT
	netip.MustParsePrefix("192.0.0.0/24"),
	netip.MustParsePrefix("198.18.0.0/15"),
	netip.MustParsePrefix("240.0.0.0/4"),
	netip.MustParsePrefix("64:ff9b::/96"), // NAT64, which can reach any IPv4 address
	netip.MustParsePrefix("64:ff9b:1::/48"),
}

func publicAddr(a netip.Addr) bool {
	a = a.Unmap()
	if !a.IsGlobalUnicast() || a.IsPrivate() {
		return false
	}
	for _, p := range reserved {
		if p.Contains(a) {
			return false
		}
	}
	return true
}
