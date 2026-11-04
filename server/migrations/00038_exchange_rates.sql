-- +goose Up

-- The last table of exchange rates fetched from each source, so a restart
-- does not spend a request of the source's quota.
create table exchange_rates (
    source text primary key,
    -- Units of each currency per unit of the source's base, as decimal strings.
    rates jsonb not null,
    -- When the source last changed them.
    updated_at timestamptz not null,
    fetched_at timestamptz not null
);

-- +goose Down
drop table exchange_rates;
