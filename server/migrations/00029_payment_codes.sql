-- +goose Up
-- Payments reach an account by a code in the payment's message or by its
-- transaction ID.
alter table users add column payment_code text unique;

-- Not unique: Ko-fi's test messages can repeat an ID.
alter table payment_events add column reference text;
create index payment_events_reference_idx on payment_events (provider, reference) where reference is not null;

-- +goose Down
drop index payment_events_reference_idx;
alter table payment_events drop column reference;

alter table users drop column payment_code;
