-- +goose Up

-- A subscription's free trial gives the plan's access until the first regular
-- billing. trial_until marks the one subscription per account that had it.
alter table paypal_subscriptions add column trial_until timestamptz;

-- +goose Down
alter table paypal_subscriptions drop column trial_until;
