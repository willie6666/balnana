-- +goose Up

-- PayPal gives a plan's free trial to every subscription on it, so accounts
-- that have had one subscribe to without_trial: the same plan without it.
alter table plan_products add column without_trial text;

-- +goose Down
alter table plan_products drop column without_trial;
