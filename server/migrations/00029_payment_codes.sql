-- +goose Up
-- Payments now reach an account by a code in the payment's message or by its
-- transaction ID. payment_emails holds what payers were seen paying from once
-- a payment was claimed, and only places their later subscription payments.
alter table users add column payment_code text unique;

-- Not unique: Ko-fi's test messages can repeat an ID.
alter table payment_events add column reference text;
create index payment_events_reference_idx on payment_events (provider, reference) where reference is not null;

delete from email_tokens where purpose = 'payment';
alter table email_tokens drop constraint email_tokens_purpose_check;
alter table email_tokens add constraint email_tokens_purpose_check check (purpose in ('verify', 'reset'));

-- +goose Down
alter table email_tokens drop constraint email_tokens_purpose_check;
alter table email_tokens add constraint email_tokens_purpose_check check (purpose in ('verify', 'reset', 'payment'));

drop index payment_events_reference_idx;
alter table payment_events drop column reference;

alter table users drop column payment_code;
