package api

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestBuckets(t *testing.T) {
	b := newBuckets(60, 3) // one a second, three at once
	now := time.Unix(1000, 0)
	for i := range 3 {
		if !b.take("a", 1, now) {
			t.Fatalf("take %d refused", i)
		}
	}
	if b.take("a", 1, now) {
		t.Fatal("fourth take allowed")
	}
	if got := b.retryAfter("a", now); got != time.Second {
		t.Fatalf("retryAfter = %v, want 1s", got)
	}
	if !b.take("b", 1, now) {
		t.Fatal("other key refused")
	}
	if !b.take("a", 1, now.Add(time.Second)) {
		t.Fatal("refill did not happen")
	}
	// Taking more than is left drains the bucket.
	if b.take("c", 5, now) {
		t.Fatal("take of 5 allowed with 3")
	}
	if b.retryAfter("c", now) == 0 {
		t.Fatal("bucket not drained")
	}
	// Full buckets are swept.
	b.take("a", 0, now.Add(time.Hour))
	if _, ok := b.m["b"]; ok {
		t.Fatal("idle bucket kept")
	}
}

func TestClientKey(t *testing.T) {
	tests := []struct {
		remote, xff, realIP string
		trust               bool
		want                string
	}{
		{"192.0.2.7:5000", "", "", false, "192.0.2.7"},
		{"192.0.2.7:5000", "198.51.100.1", "", false, "192.0.2.7"},
		{"192.0.2.7:5000", "203.0.113.9, 198.51.100.1", "", true, "198.51.100.1"},
		{"192.0.2.7:5000", "", "198.51.100.2", true, "198.51.100.2"},
		{"[2001:db8:1:2:3:4:5:6]:5000", "", "", false, "2001:db8:1:2::/64"},
		{"[::ffff:192.0.2.8]:5000", "", "", false, "192.0.2.8"},
	}
	for _, tt := range tests {
		r := httptest.NewRequest(http.MethodGet, "/api/v1/server-info", nil)
		r.RemoteAddr = tt.remote
		if tt.xff != "" {
			r.Header.Set("X-Forwarded-For", tt.xff)
		}
		if tt.realIP != "" {
			r.Header.Set("X-Real-IP", tt.realIP)
		}
		if got := clientKey(r, tt.trust); got != tt.want {
			t.Errorf("clientKey(%q, xff %q, trust %v) = %q, want %q", tt.remote, tt.xff, tt.trust, got, tt.want)
		}
	}
}

func TestRateLimitRequests(t *testing.T) {
	h := testHandler(t, baseConfig(t, map[string]string{"BALNANA_RATE_LIMIT": "60"}))
	// The burst for 60 a minute is 20.
	for i := range 20 {
		if rec := get(t, h, "/api/v1/nope", nil); rec.Code != http.StatusNotFound {
			t.Fatalf("request %d: status %d", i, rec.Code)
		}
	}
	rec := get(t, h, "/api/v1/nope", nil)
	if rec.Code != http.StatusTooManyRequests || rec.Header().Get("Retry-After") == "" {
		t.Fatalf("status %d, Retry-After %q", rec.Code, rec.Header().Get("Retry-After"))
	}
	// The web app and health checks are not limited.
	if rec := get(t, h, "/healthz", nil); rec.Code == http.StatusTooManyRequests {
		t.Fatal("healthz limited")
	}
}

func TestRateLimitTokenMisses(t *testing.T) {
	h := testHandler(t, baseConfig(t, map[string]string{"BALNANA_RATE_LIMIT": "0"}))
	// Malformed tokens are misses that never reach the database.
	for i := range missBurst {
		if rec := get(t, h, "/api/v1/g/nope", nil); rec.Code != http.StatusNotFound {
			t.Fatalf("miss %d: status %d", i, rec.Code)
		}
	}
	if rec := get(t, h, "/api/v1/g/nope", nil); rec.Code != http.StatusTooManyRequests {
		t.Fatalf("status %d after %d misses", rec.Code, missBurst)
	}
	if rec := get(t, h, "/api/v1/server-info", nil); rec.Code != http.StatusTooManyRequests {
		t.Fatal("blocked client can still call the API")
	}
}

func TestCreateLimit(t *testing.T) {
	c := newClient(t)
	for range createBurst {
		createGroup(c, "Ana")
	}
	rec := c.do("POST", "/groups", GroupCreate{Name: "One more", Currency: "EUR", Members: []string{"Ana"}})
	if rec.Code != http.StatusTooManyRequests || rec.Header().Get("Retry-After") == "" {
		t.Fatalf("status %d, Retry-After %q", rec.Code, rec.Header().Get("Retry-After"))
	}
	// An import's preview does the same work, so it waits too.
	if code := c.errorCode(429, "POST", "/groups/import", importInputFor(settleUpFile(settleUpRows...), true)); code != "rate_limited" {
		t.Fatal(code)
	}
	// With rate limits off, so is this one.
	c = newClientWith(t, map[string]string{"BALNANA_RATE_LIMIT": "0"})
	for range createBurst + 1 {
		createGroup(c, "Ana")
	}
}

func TestInviteLimit(t *testing.T) {
	ana, f := mailClient(t, map[string]string{})
	register(ana, "ana@example.com", "Ana")
	confirmEmail(ana, f, "ana@example.com")
	path := "/g/" + createGroup(ana, "Ana").Token
	for range inviteBurst {
		ana.must(204, "POST", path+"/invites", InviteInput{Email: "ben@example.com"}, nil)
		f.next(t, "ben@example.com")
	}
	if code := ana.errorCode(429, "POST", path+"/invites", InviteInput{Email: "ben@example.com"}); code != "rate_limited" {
		t.Fatal(code)
	}
	f.none(t)
	// The cap is per account.
	ben := ana.another()
	register(ben, "ben@example.com", "Ben")
	confirmEmail(ben, f, "ben@example.com")
	ben.must(204, "POST", "/g/"+createGroup(ben, "Ben").Token+"/invites", InviteInput{Email: "ana@example.com"}, nil)
}

func TestStreamsPerClient(t *testing.T) {
	h := newHub()
	var chans []chan struct{}
	for range maxClientStreams {
		ch, err := h.subscribe("g", "a")
		if err != nil {
			t.Fatal(err)
		}
		chans = append(chans, ch)
	}
	if _, err := h.subscribe("g", "a"); err != errRateLimited {
		t.Fatalf("stream %d: %v", maxClientStreams+1, err)
	}
	if _, err := h.subscribe("g", "b"); err != nil {
		t.Fatal("another client refused:", err)
	}
	h.unsubscribe("g", "a", chans[0])
	h.unsubscribe("g", "a", chans[0]) // twice counts once
	if _, err := h.subscribe("g", "a"); err != nil {
		t.Fatal("closing a stream frees its place:", err)
	}
	if _, err := h.subscribe("g", "a"); err != errRateLimited {
		t.Fatal(err)
	}
	for _, ch := range chans[1:] {
		h.unsubscribe("g", "a", ch)
	}
	if h.clients["a"] != 1 {
		t.Fatalf("client a holds %d streams, want 1", h.clients["a"])
	}
}

func TestGuessLimit(t *testing.T) {
	ana := accountsClient(t, map[string]string{})
	register(ana, "ana@example.com", "Ana")
	right := LoginInput{Login: "ana@example.com", Password: "correct horse"}
	wrong := LoginInput{Login: "ana@example.com", Password: "wrong horse"}
	// Right passwords give back what they held, from the client and the
	// account alike.
	for range missBurst/loginMissWeight + 5 {
		ana.another().must(200, "POST", "/auth/login", right, nil)
	}
	for range guessBurst {
		ana.another().errorCode(401, "POST", "/auth/login", wrong)
	}
	// The account is held now, even for the right password; others are not.
	if code := ana.another().errorCode(429, "POST", "/auth/login", right); code != "rate_limited" {
		t.Fatal(code)
	}
	if code := ana.another().errorCode(401, "POST", "/auth/login", LoginInput{Login: "ben@example.com", Password: "x"}); code != "invalid_credentials" {
		t.Fatal(code)
	}
}
