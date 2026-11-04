// Package rates fetches exchange rates for the app to start a foreign
// expense's rate from: from Frankfurter, which needs no key, or from Open
// Exchange Rates with an app ID.
package rates

import (
	"cmp"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"math/big"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"sync"
	"time"
)

// Sources, as the app names them.
const (
	Frankfurter = "frankfurter"
	OXR         = "openexchangerates"
)

const (
	// MaxAge is how long a table is used before it is fetched again.
	// Frankfurter changes once a working day and Open Exchange Rates' free
	// plan once an hour, which is also within its 1,000 requests a month.
	MaxAge = time.Hour
	// retryAfter is how long a failed fetch waits before the next try, so
	// that a source that is down is not asked on every request.
	retryAfter = 5 * time.Minute
	timeout    = 10 * time.Second
	// maxBody bounds what a source may answer; a whole table is a few KB.
	maxBody = 1 << 20
	// decimals and digits round rates the way the app's rate field takes
	// them: six significant digits, at most eight decimals.
	decimals = 8
	digits   = 6
)

var (
	// ErrUnknown is for a currency the source has no rate for.
	ErrUnknown = errors.New("rates: unknown currency")
	code       = regexp.MustCompile(`^[A-Z]{3}$`)
)

// Table is one source's rates: units of each currency per unit of one base.
type Table struct {
	Source  string
	Rates   map[string]*big.Rat
	Updated time.Time
}

// Rate is how many units of to one unit of from is worth, as a decimal
// string, e.g. "0.00653" for JPY to USD.
func (t *Table) Rate(from, to string) (string, error) {
	f, g := t.Rates[from], t.Rates[to]
	if f == nil || g == nil || f.Sign() <= 0 || g.Sign() <= 0 {
		return "", ErrUnknown
	}
	r := new(big.Rat).Quo(g, f)
	s := round(r)
	if s == "" {
		return "", ErrUnknown
	}
	return s, nil
}

// round writes r with six significant digits and at most eight decimals,
// half up and without trailing zeros, as rateOf in the app does; "" when
// that leaves nothing.
func round(r *big.Rat) string {
	ten := big.NewInt(10)
	var n *big.Int
	d := 0
	for ; ; d++ {
		scale := new(big.Int).Exp(ten, big.NewInt(int64(d)), nil)
		v := new(big.Rat).Mul(r, new(big.Rat).SetInt(scale))
		// Half up: floor(v + 1/2).
		v.Add(v, big.NewRat(1, 2))
		n = new(big.Int).Quo(v.Num(), v.Denom())
		if d == decimals || len(n.String()) >= digits {
			break
		}
	}
	if n.Sign() == 0 {
		return ""
	}
	s := n.String()
	if d > 0 {
		s = strings.Repeat("0", max(0, d+1-len(s))) + s
		s = s[:len(s)-d] + "." + s[len(s)-d:]
		s = strings.TrimRight(strings.TrimRight(s, "0"), ".")
	}
	return s
}

// Source fetches a whole table.
type Source interface {
	Name() string
	Fetch(ctx context.Context, client *http.Client) (*Table, error)
}

// FrankfurterSource reads the European Central Bank's reference rates
// through Frankfurter (https://frankfurter.dev): about 30 currencies, euro
// based, changed once a working day.
type FrankfurterSource struct {
	// URL is the latest-rates endpoint; empty for the public one.
	URL string
}

func (FrankfurterSource) Name() string { return Frankfurter }

func (f FrankfurterSource) Fetch(ctx context.Context, client *http.Client) (*Table, error) {
	var body struct {
		Base  string                 `json:"base"`
		Date  string                 `json:"date"`
		Rates map[string]json.Number `json:"rates"`
	}
	if err := get(ctx, client, cmp.Or(f.URL, "https://api.frankfurter.dev/v1/latest"), &body); err != nil {
		return nil, err
	}
	// The day the central bank published them.
	day, err := time.Parse(time.DateOnly, body.Date)
	if err != nil {
		return nil, fmt.Errorf("frankfurter: date %q: %w", body.Date, err)
	}
	t, err := table(Frankfurter, body.Rates, day)
	if err != nil {
		return nil, err
	}
	// The base is left out of its own rates.
	if code.MatchString(body.Base) {
		t.Rates[body.Base] = big.NewRat(1, 1)
	}
	return t, nil
}

// OXRSource reads Open Exchange Rates (https://openexchangerates.org): about
// 170 currencies, dollar based on the free plan, changed hourly.
type OXRSource struct {
	AppID string
	// URL is the latest-rates endpoint; empty for the public one.
	URL string
}

func (OXRSource) Name() string { return OXR }

func (o OXRSource) Fetch(ctx context.Context, client *http.Client) (*Table, error) {
	u, err := url.Parse(cmp.Or(o.URL, "https://openexchangerates.org/api/latest.json"))
	if err != nil {
		return nil, err
	}
	u.RawQuery = url.Values{"app_id": {o.AppID}}.Encode()
	var body struct {
		Timestamp int64                  `json:"timestamp"`
		Rates     map[string]json.Number `json:"rates"`
	}
	if err := get(ctx, client, u.String(), &body); err != nil {
		// The URL holds the app ID, which logs should not.
		var ue *url.Error
		if errors.As(err, &ue) {
			err = ue.Err
		}
		return nil, fmt.Errorf("openexchangerates: %w", err)
	}
	return table(OXR, body.Rates, time.Unix(body.Timestamp, 0))
}

func get(ctx context.Context, client *http.Client, u string, into any) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		return err
	}
	req.Header.Set("Accept", "application/json")
	res, err := client.Do(req)
	if err != nil {
		return err
	}
	defer res.Body.Close()
	if res.StatusCode != http.StatusOK {
		return fmt.Errorf("status %d", res.StatusCode)
	}
	return json.NewDecoder(io.LimitReader(res.Body, maxBody)).Decode(into)
}

func table(source string, raw map[string]json.Number, updated time.Time) (*Table, error) {
	t := &Table{Source: source, Rates: make(map[string]*big.Rat, len(raw)), Updated: updated.UTC()}
	for c, n := range raw {
		r, ok := new(big.Rat).SetString(n.String())
		if code.MatchString(c) && ok && r.Sign() > 0 {
			t.Rates[c] = r
		}
	}
	if len(t.Rates) == 0 {
		return nil, fmt.Errorf("%s: no rates", source)
	}
	return t, nil
}

// Store keeps the last table of each source across restarts.
type Store interface {
	Load(ctx context.Context, source string) (t *Table, fetched time.Time, err error)
	Save(ctx context.Context, t *Table, fetched time.Time) error
}

// Cache fetches a table when the one it has is older than MaxAge, at most
// once at a time, and keeps using it while the source is out of reach.
type Cache struct {
	Store  Store
	Client *http.Client
	Log    *slog.Logger // nil logs nothing
	Now    func() time.Time

	mu      sync.Mutex
	source  string
	table   *Table
	fetched time.Time
	failed  time.Time
}

// Table is source's rates, fetched when needed.
func (c *Cache) Table(ctx context.Context, source Source) (*Table, error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	now := c.now()
	if c.source != source.Name() {
		// A new source, or the first ask since starting.
		c.source, c.table, c.failed = source.Name(), nil, time.Time{}
		if c.Store != nil {
			t, fetched, err := c.Store.Load(ctx, source.Name())
			if err != nil {
				return nil, err
			}
			c.table, c.fetched = t, fetched
		}
	}
	if c.table != nil && now.Sub(c.fetched) < MaxAge || now.Sub(c.failed) < retryAfter {
		return c.last()
	}
	fetchCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), timeout)
	defer cancel()
	client := c.Client
	if client == nil {
		client = http.DefaultClient
	}
	t, err := source.Fetch(fetchCtx, client)
	if err != nil {
		c.failed = now
		if c.Log != nil {
			c.Log.Warn("exchange rates not fetched", "source", source.Name(), "err", err)
		}
		if c.table == nil {
			return nil, fmt.Errorf("%w: %w", ErrUnavailable, err)
		}
		return c.table, nil
	}
	c.table, c.fetched, c.failed = t, now, time.Time{}
	if c.Store != nil {
		if err := c.Store.Save(ctx, t, now); err != nil {
			return nil, err
		}
	}
	return t, nil
}

// ErrUnavailable is for a source that could not be reached, with no table
// from before to fall back on.
var ErrUnavailable = errors.New("rates: source unavailable")

func (c *Cache) last() (*Table, error) {
	if c.table == nil {
		return nil, ErrUnavailable
	}
	return c.table, nil
}

func (c *Cache) now() time.Time {
	if c.Now != nil {
		return c.Now()
	}
	return time.Now()
}
