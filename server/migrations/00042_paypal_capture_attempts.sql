-- +goose Up

-- A declined capture sends the payer back to PayPal to pay another way. The
-- next capture needs a request ID of its own, as PayPal answers a repeated one
-- with what it said the first time.
alter table paypal_orders add column capture_attempts integer not null default 0;

-- +goose Down
alter table paypal_orders drop column capture_attempts;
