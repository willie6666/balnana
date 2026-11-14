package rates

import (
	"context"
	"errors"
	"math/big"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

func TestRound(t *testing.T) {
	for _, c := range []struct {
		r    *big.Rat
		want string
	}{
		{big.NewRat(1, 1), "1"},
		{big.NewRat(31256789, 1000000), "31.2568"},
		{big.NewRat(653, 100000), "0.00653"},
		{big.NewRat(2, 3), "0.666667"},
		{big.NewRat(123456789, 1), "123456789"},
		// Eight decimals at most, as the app's field takes.
		{big.NewRat(1, 30000000), "0.00000003"},
		{big.NewRat(1, 300000000), ""},
		{big.NewRat(15, 1000000000), "0.00000002"},
	} {
		if got := round(c.r); got != c.want {
			t.Errorf("round(%v) = %q, want %q", c.r, got, c.want)
		}
	}
}

func TestRate(t *testing.T) {
	tb := &Table{Rates: map[string]*big.Rat{
		"USD": big.NewRat(1, 1),
		"JPY": big.NewRat(15312, 100),
		"EUR": big.NewRat(9213, 10000),
	}}
	for _, c := range []struct{ from, to, want string }{
		{"JPY", "USD", "0.00653083"},
		{"USD", "JPY", "153.12"},
		{"EUR", "JPY", "166.2"},
		{"USD", "USD", "1"},
	} {
		got, err := tb.Rate(c.from, c.to)
		if err != nil || got != c.want {
			t.Errorf("%s to %s = %q, %v; want %q", c.from, c.to, got, err, c.want)
		}
	}
	if _, err := tb.Rate("USD", "XYZ"); !errors.Is(err, ErrUnknown) {
		t.Errorf("unknown currency: %v", err)
	}
}

func TestFrankfurter(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(`{"amount":1.0,"base":"EUR","date":"2026-11-03","rates":{"JPY":166.2,"USD":1.0854,"bad":2,"TWD":-1}}`))
	}))
	defer srv.Close()
	tb, err := FrankfurterSource{URL: srv.URL}.Fetch(context.Background(), srv.Client())
	if err != nil {
		t.Fatal(err)
	}
	if tb.Source != Frankfurter || !tb.Updated.Equal(time.Date(2026, 11, 3, 0, 0, 0, 0, time.UTC)) {
		t.Errorf("table %s %v", tb.Source, tb.Updated)
	}
	// The base is in, what is no rate is not.
	if len(tb.Rates) != 3 || tb.Rates["EUR"].Cmp(big.NewRat(1, 1)) != 0 {
		t.Errorf("rates %v", tb.Rates)
	}
	if got, _ := tb.Rate("USD", "EUR"); got != "0.921319" {
		t.Errorf("USD to EUR %q", got)
	}
}

func TestOXR(t *testing.T) {
	var asked string
	status := http.StatusOK
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		asked = r.URL.Query().Get("app_id")
		w.WriteHeader(status)
		w.Write([]byte(`{"timestamp":1793750400,"base":"USD","rates":{"USD":1,"JPY":153.12}}`))
	}))
	defer srv.Close()
	src := OXRSource{AppID: "secret-id", URL: srv.URL}
	tb, err := src.Fetch(context.Background(), srv.Client())
	if err != nil {
		t.Fatal(err)
	}
	if asked != "secret-id" || tb.Source != OXR || tb.Updated.Unix() != 1793750400 {
		t.Errorf("asked %q, table %s %v", asked, tb.Source, tb.Updated)
	}
	status = http.StatusUnauthorized
	if _, err := src.Fetch(context.Background(), srv.Client()); err == nil || strings.Contains(err.Error(), "secret-id") {
		t.Errorf("refused: %v", err)
	}
	srv.Close()
	if _, err := src.Fetch(context.Background(), srv.Client()); err == nil || strings.Contains(err.Error(), "secret-id") {
		t.Errorf("unreachable: %v", err)
	}
}

type fakeSource struct {
	name    string
	fetches int
	fail    bool
}

func (f *fakeSource) Name() string { return f.name }

func (f *fakeSource) Fetch(context.Context, *http.Client) (*Table, error) {
	f.fetches++
	if f.fail {
		return nil, errors.New("down")
	}
	return &Table{Source: f.name, Rates: map[string]*big.Rat{"USD": big.NewRat(1, 1), "JPY": big.NewRat(150, 1)}}, nil
}

type memStore map[string]*Table

func (m memStore) Load(_ context.Context, source string) (*Table, time.Time, error) {
	t := m[source]
	if t == nil {
		return nil, time.Time{}, nil
	}
	return t, t.Updated, nil
}

func (m memStore) Save(_ context.Context, t *Table, _ time.Time) error {
	m[t.Source] = t
	return nil
}

func TestCache(t *testing.T) {
	ctx := context.Background()
	now := time.Date(2026, 11, 4, 12, 0, 0, 0, time.UTC)
	store := memStore{}
	c := &Cache{Store: store, Now: func() time.Time { return now }}
	src := &fakeSource{name: Frankfurter}

	if _, err := c.Table(ctx, src); err != nil || src.fetches != 1 || store[Frankfurter] == nil {
		t.Fatalf("first: %v, %d fetches", err, src.fetches)
	}
	now = now.Add(MaxAge - time.Minute)
	if _, err := c.Table(ctx, src); err != nil || src.fetches != 1 {
		t.Errorf("within the hour: %v, %d fetches", err, src.fetches)
	}
	// Out of reach: the old table, and no new try for a while.
	now = now.Add(2 * time.Minute)
	src.fail = true
	if tb, err := c.Table(ctx, src); err != nil || tb == nil || src.fetches != 2 {
		t.Errorf("down: %v, %d fetches", err, src.fetches)
	}
	if _, err := c.Table(ctx, src); err != nil || src.fetches != 2 {
		t.Errorf("soon after: %v, %d fetches", err, src.fetches)
	}
	now = now.Add(retryAfter)
	src.fail = false
	if _, err := c.Table(ctx, src); err != nil || src.fetches != 3 {
		t.Errorf("back: %v, %d fetches", err, src.fetches)
	}

	// Another source starts from what the store kept, with nothing to fall
	// back on when it is down.
	other := &fakeSource{name: OXR, fail: true}
	if _, err := c.Table(ctx, other); !errors.Is(err, ErrUnavailable) {
		t.Errorf("new source down: %v", err)
	}
	if _, err := c.Table(ctx, other); !errors.Is(err, ErrUnavailable) || other.fetches != 1 {
		t.Errorf("new source soon after: %v, %d fetches", err, other.fetches)
	}

	// A restart reads the stored table instead of fetching.
	restarted := &Cache{Store: store, Now: func() time.Time { return now }}
	store[Frankfurter].Updated = now
	if _, err := restarted.Table(ctx, src); err != nil || src.fetches != 3 {
		t.Errorf("restart: %v, %d fetches", err, src.fetches)
	}
}

type interruptedStore struct {
	memStore
	loadErr, saveErr error
}

func (s interruptedStore) Load(ctx context.Context, name string) (*Table, time.Time, error) {
	if s.loadErr != nil {
		return nil, time.Time{}, s.loadErr
	}
	return s.memStore.Load(ctx, name)
}

func (s interruptedStore) Save(ctx context.Context, table *Table, fetched time.Time) error {
	if s.saveErr != nil {
		return s.saveErr
	}
	return s.memStore.Save(ctx, table, fetched)
}

func TestCacheRetriesStoreLoadAfterFailure(t *testing.T) {
	now := time.Now()
	src := &fakeSource{name: Frankfurter}
	store := &interruptedStore{
		memStore: memStore{Frankfurter: {Source: Frankfurter, Updated: now}},
		loadErr:  context.DeadlineExceeded,
	}
	c := &Cache{Store: store, Now: func() time.Time { return now }}
	if _, err := c.Table(t.Context(), src); !errors.Is(err, context.DeadlineExceeded) {
		t.Fatalf("first load: %v", err)
	}
	store.loadErr = nil
	if got, err := c.Table(t.Context(), src); got != store.memStore[Frankfurter] || err != nil || src.fetches != 0 {
		t.Fatalf("second load: %v, %v, %d fetches", got, err, src.fetches)
	}
}

func TestCacheReturnsFreshRatesWhenPersistenceFails(t *testing.T) {
	src := &fakeSource{name: Frankfurter}
	c := &Cache{Store: interruptedStore{memStore: memStore{}, saveErr: errors.New("disk full")}}
	for range 2 {
		if got, err := c.Table(t.Context(), src); got == nil || err != nil || src.fetches != 1 {
			t.Fatalf("fresh rates: %v, %v, %d fetches", got, err, src.fetches)
		}
	}
}
