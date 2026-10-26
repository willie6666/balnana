package api

import (
	"context"
	"net"
	"net/http"
	"net/netip"
	"strconv"
	"strings"
	"sync"
	"time"
)

// Group-token misses allowed per client before it is blocked, and how fast
// that allowance comes back. Tokens are 128 random bits, so this is not what
// keeps groups safe; it keeps a misbehaving client from hammering the database.
const (
	missBurst     = 200
	missPerMinute = 20
)

// buckets is a token bucket per client key. Buckets refill continuously and
// are dropped once full, so idle clients cost nothing.
type buckets struct {
	mu        sync.Mutex
	perSecond float64
	burst     float64
	m         map[string]*bucket
	lastSweep time.Time
}

type bucket struct {
	tokens float64
	last   time.Time
}

func newBuckets(perMinute, burst int) *buckets {
	return &buckets{perSecond: float64(perMinute) / 60, burst: float64(burst), m: map[string]*bucket{}}
}

// take removes n tokens and reports whether there were at least n. A request
// that takes more than is left still drains the bucket (to zero), so a burst
// of misses blocks the requests after it.
func (b *buckets) take(key string, n float64, now time.Time) bool {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.sweep(now)
	k := b.m[key]
	if k == nil {
		k = &bucket{tokens: b.burst, last: now}
		b.m[key] = k
	}
	k.tokens = min(b.burst, k.tokens+now.Sub(k.last).Seconds()*b.perSecond)
	k.last = now
	if k.tokens < n {
		k.tokens = 0
		return false
	}
	k.tokens -= n
	return true
}

// retryAfter is how long until key has one token again.
func (b *buckets) retryAfter(key string, now time.Time) time.Duration {
	b.mu.Lock()
	defer b.mu.Unlock()
	k := b.m[key]
	if k == nil || b.perSecond == 0 {
		return 0
	}
	tokens := k.tokens + now.Sub(k.last).Seconds()*b.perSecond
	if tokens >= 1 {
		return 0
	}
	return time.Duration((1 - tokens) / b.perSecond * float64(time.Second))
}

func (b *buckets) sweep(now time.Time) {
	if now.Sub(b.lastSweep) < time.Minute {
		return
	}
	b.lastSweep = now
	for key, k := range b.m {
		if k.tokens+now.Sub(k.last).Seconds()*b.perSecond >= b.burst {
			delete(b.m, key)
		}
	}
}

type missesKey struct{}

type clientCtxKey struct{}

// requestClient is the key rateLimit gave this request's client ("" when
// the request did not come through it).
func requestClient(ctx context.Context) string {
	key, _ := ctx.Value(clientCtxKey{}).(string)
	return key
}

// noteMiss records that this request asked for a group token that does not
// exist, for the rate limiter.
func noteMiss(ctx context.Context) {
	if n, ok := ctx.Value(missesKey{}).(*int); ok {
		*n++
	}
}

// Groups a client may create in a row, and how fast that allowance comes
// back; invitation emails an account may send likewise. They keep one client
// from filling the database, or the server's mailbox from becoming a way to
// send spam.
const (
	createBurst     = 30
	createPerMinute = 1
	inviteBurst     = 20
	invitePerMinute = 1
)

var errRateLimited = &apiError{status: http.StatusTooManyRequests, code: "rate_limited"}

// limitCreates counts a new group against the client's allowance. Like the
// request rate limit, it is off when BALNANA_RATE_LIMIT is 0.
func (s *Server) limitCreates(ctx context.Context) error {
	if s.conf().RateLimit == 0 {
		return nil
	}
	if !s.creates.take(requestClient(ctx), 1, time.Now()) {
		return errRateLimited
	}
	return nil
}

// rateLimit caps API requests per client (perMinute, 0 for no cap) and blocks
// clients that keep asking for group tokens that do not exist.
func rateLimit(perMinute int, trustProxy bool, next http.Handler) http.Handler {
	var requests *buckets
	if perMinute > 0 {
		// Allow a short burst: opening the app fetches a few things at once.
		requests = newBuckets(perMinute, max(perMinute/4, 20))
	}
	misses := newBuckets(missPerMinute, missBurst)
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !strings.HasPrefix(r.URL.Path, BasePath+"/") || r.Method == http.MethodOptions {
			next.ServeHTTP(w, r)
			return
		}
		key := clientKey(r, trustProxy)
		now := time.Now()
		if requests != nil && !requests.take(key, 1, now) {
			tooMany(w, requests.retryAfter(key, now))
			return
		}
		if wait := misses.retryAfter(key, now); wait > 0 {
			tooMany(w, wait)
			return
		}
		var n int
		ctx := context.WithValue(r.Context(), missesKey{}, &n)
		next.ServeHTTP(w, r.WithContext(context.WithValue(ctx, clientCtxKey{}, key)))
		if n > 0 {
			misses.take(key, float64(n), time.Now())
		}
	})
}

func tooMany(w http.ResponseWriter, wait time.Duration) {
	w.Header().Set("Retry-After", strconv.Itoa(max(1, int(wait.Seconds()+0.999))))
	writeError(w, http.StatusTooManyRequests, "rate_limited")
}

// clientKey identifies the client: its IP address, or its /64 network for
// IPv6, where one client often has a whole /64. Behind a reverse proxy
// (trustProxy) the address comes from the last X-Forwarded-For entry, the one
// the proxy itself added, or X-Real-IP.
func clientKey(r *http.Request, trustProxy bool) string {
	raw := ""
	if trustProxy {
		if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
			raw = strings.TrimSpace(xff[strings.LastIndexByte(xff, ',')+1:])
		} else {
			raw = strings.TrimSpace(r.Header.Get("X-Real-IP"))
		}
	}
	if raw == "" {
		raw = r.RemoteAddr
		if host, _, err := net.SplitHostPort(raw); err == nil {
			raw = host
		}
	}
	addr, err := netip.ParseAddr(raw)
	if err != nil {
		return raw
	}
	addr = addr.Unmap()
	if addr.Is6() {
		p, _ := addr.Prefix(64)
		return p.String()
	}
	return addr.String()
}
