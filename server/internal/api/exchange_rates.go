package api

import (
	"context"
	"encoding/json"
	"errors"
	"math/big"
	"net/http"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"balnana/internal/config"
	"balnana/internal/rates"
)

var (
	errRatesOff         = &apiError{status: http.StatusNotFound, code: "rates_off"}
	errUnknownCurrency  = &apiError{status: http.StatusNotFound, code: "unknown_currency"}
	errRatesUnavailable = &apiError{status: http.StatusServiceUnavailable, code: "rates_unavailable"}
)

// rateSource is where cfg says rates come from.
func rateSource(cfg *config.Config) rates.Source {
	if cfg.OXRAppID != "" {
		return rates.OXRSource{AppID: cfg.OXRAppID}
	}
	return rates.FrankfurterSource{}
}

func (s *Server) GetExchangeRate(ctx context.Context, req GetExchangeRateRequestObject) (GetExchangeRateResponseObject, error) {
	cfg := s.conf()
	if !cfg.ExchangeRates {
		return nil, errRatesOff
	}
	from, to := req.Params.From, req.Params.To
	if !currencyCode.MatchString(from) || !currencyCode.MatchString(to) {
		return nil, badRequest("invalid_currency")
	}
	t, err := s.rates.Table(ctx, s.rateSource(cfg))
	if errors.Is(err, rates.ErrUnavailable) {
		return nil, errRatesUnavailable
	} else if err != nil {
		return nil, err
	}
	rate, err := t.Rate(from, to)
	if errors.Is(err, rates.ErrUnknown) {
		return nil, errUnknownCurrency
	} else if err != nil {
		return nil, err
	}
	return GetExchangeRate200JSONResponse{Rate: rate, Source: ExchangeRateSource(t.Source), UpdatedAt: t.Updated}, nil
}

// rateStore keeps each source's last table in exchange_rates.
type rateStore struct{ db *pgxpool.Pool }

func (r rateStore) Load(ctx context.Context, source string) (*rates.Table, time.Time, error) {
	var raw map[string]string
	t := &rates.Table{Source: source}
	var fetched time.Time
	err := r.db.QueryRow(ctx, `select rates, updated_at, fetched_at from exchange_rates where source = $1`, source).
		Scan(&raw, &t.Updated, &fetched)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, time.Time{}, nil
	} else if err != nil {
		return nil, time.Time{}, err
	}
	t.Rates = make(map[string]*big.Rat, len(raw))
	for c, v := range raw {
		if n, ok := new(big.Rat).SetString(v); ok {
			t.Rates[c] = n
		}
	}
	return t, fetched, nil
}

func (r rateStore) Save(ctx context.Context, t *rates.Table, fetched time.Time) error {
	raw := make(map[string]string, len(t.Rates))
	for c, v := range t.Rates {
		// Exact: a rate from JSON has a finite decimal expansion.
		raw[c] = v.FloatString(decimalPlaces(v))
	}
	b, err := json.Marshal(raw)
	if err != nil {
		return err
	}
	_, err = r.db.Exec(ctx, `
		insert into exchange_rates (source, rates, updated_at, fetched_at) values ($1, $2, $3, $4)
		on conflict (source) do update set rates = excluded.rates, updated_at = excluded.updated_at,
			fetched_at = excluded.fetched_at`, t.Source, b, t.Updated, fetched)
	return err
}

// decimalPlaces is how many decimals write r exactly, when its denominator
// has no factors but 2 and 5; at most 20 otherwise.
func decimalPlaces(r *big.Rat) int {
	d := new(big.Int).Set(r.Denom())
	ten := big.NewInt(10)
	n := 0
	for d.Cmp(big.NewInt(1)) != 0 && n < 20 {
		g := new(big.Int).GCD(nil, nil, d, ten)
		if g.Cmp(big.NewInt(1)) == 0 {
			return 20
		}
		d.Quo(d, g)
		n++
	}
	return n
}
