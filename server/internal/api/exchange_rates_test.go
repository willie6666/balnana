package api

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"

	"balnana/internal/config"
	"balnana/internal/rates"
)

// rateServer answers like Frankfurter, or like Open Exchange Rates for a
// request with an app ID, and counts what it was asked.
func rateServer(t *testing.T) (*httptest.Server, *atomic.Int32) {
	var asked atomic.Int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		asked.Add(1)
		if r.URL.Query().Get("app_id") != "" {
			w.Write([]byte(`{"timestamp":1793750400,"base":"USD","rates":{"USD":1,"JPY":153.12,"TWD":32.05}}`))
			return
		}
		w.Write([]byte(`{"amount":1.0,"base":"EUR","date":"2026-11-03","rates":{"JPY":166.2,"USD":1.0854}}`))
	}))
	t.Cleanup(srv.Close)
	return srv, &asked
}

func rateClient(t *testing.T, s *Server, url string) *client {
	s.rateSource = func(cfg *config.Config) rates.Source {
		if cfg.OXRAppID != "" {
			return rates.OXRSource{AppID: cfg.OXRAppID, URL: url}
		}
		return rates.FrankfurterSource{URL: url}
	}
	return &client{t: t, h: NewHandler(s, http.NotFoundHandler())}
}

func TestExchangeRate(t *testing.T) {
	srv, asked := rateServer(t)
	pool := testDB(t)
	s := NewServer(baseConfig(t, map[string]string{}), pool, slog.New(slog.DiscardHandler), "test")
	c := rateClient(t, s, srv.URL)

	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if !info.ExchangeRates {
		t.Error("exchange rates are on by default")
	}
	var r ExchangeRate
	c.must(200, "GET", "/exchange-rate?from=JPY&to=EUR", nil, &r)
	if r.Rate != "0.00601685" || r.Source != Frankfurter || r.UpdatedAt.Format("2006-01-02") != "2026-11-03" {
		t.Errorf("%+v", r)
	}
	c.must(200, "GET", "/exchange-rate?from=EUR&to=USD", nil, &r)
	if r.Rate != "1.0854" {
		t.Errorf("%+v", r)
	}
	if code := c.errorCode(404, "GET", "/exchange-rate?from=TWD&to=USD", nil); code != "unknown_currency" {
		t.Error(code)
	}
	if code := c.errorCode(400, "GET", "/exchange-rate?from=usd&to=JPY", nil); code != "invalid_currency" {
		t.Error(code)
	}
	if asked.Load() != 1 {
		t.Errorf("asked the source %d times", asked.Load())
	}

	// A restart starts from what was fetched.
	again := rateClient(t, NewServer(baseConfig(t, map[string]string{}), pool, slog.New(slog.DiscardHandler), "test"), srv.URL)
	again.must(200, "GET", "/exchange-rate?from=JPY&to=USD", nil, &r)
	if r.Rate != "0.00653069" || asked.Load() != 1 {
		t.Errorf("%+v, asked %d times", r, asked.Load())
	}
}

func TestExchangeRateOXR(t *testing.T) {
	srv, _ := rateServer(t)
	s := NewServer(baseConfig(t, map[string]string{"BALNANA_OXR_APP_ID": "app"}), testDB(t), slog.New(slog.DiscardHandler), "test")
	c := rateClient(t, s, srv.URL)
	var r ExchangeRate
	c.must(200, "GET", "/exchange-rate?from=TWD&to=JPY", nil, &r)
	if r.Rate != "4.77754" || r.Source != Openexchangerates || r.UpdatedAt.Unix() != 1793750400 {
		t.Errorf("%+v", r)
	}
}

func TestExchangeRateOff(t *testing.T) {
	srv, asked := rateServer(t)
	s := NewServer(baseConfig(t, map[string]string{"BALNANA_EXCHANGE_RATES": "false"}), testDB(t), slog.New(slog.DiscardHandler), "test")
	c := rateClient(t, s, srv.URL)
	var info ServerInfo
	c.must(200, "GET", "/server-info", nil, &info)
	if info.ExchangeRates {
		t.Error("server-info says on")
	}
	if code := c.errorCode(404, "GET", "/exchange-rate?from=JPY&to=USD", nil); code != "rates_off" {
		t.Error(code)
	}
	// Out of reach with nothing from before.
	on := NewServer(baseConfig(t, map[string]string{"BALNANA_EXCHANGE_RATES": "true"}), testDB(t), slog.New(slog.DiscardHandler), "test")
	srv.Close()
	if code := rateClient(t, on, srv.URL).errorCode(503, "GET", "/exchange-rate?from=JPY&to=USD", nil); code != "rates_unavailable" {
		t.Error(code)
	}
	if asked.Load() != 0 {
		t.Errorf("asked %d times", asked.Load())
	}
}
