-- +goose Up

-- PayPal is asked about a subscription before its lock is taken, so two syncs
-- can finish out of order. synced_at is when the stored state was asked for:
-- an older answer doesn't overwrite a newer one.
alter table paypal_subscriptions add column synced_at timestamptz;

-- +goose Down
alter table paypal_subscriptions drop column synced_at;
