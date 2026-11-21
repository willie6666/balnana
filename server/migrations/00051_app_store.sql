-- +goose Up

-- Subscriptions bought through the App Store, by the first transaction of
-- each: renewals keep it. Apple signs each transaction, so the latest one the
-- server checked says how long the subscription lasts.
create table appstore_subscriptions (
  original_transaction_id text primary key,
  user_id                 uuid not null references users(id) on delete cascade,
  product_id              text not null,
  entitlement_id          uuid references entitlements(id) on delete set null,
  environment             text not null,
  -- The latest transaction applied: an older one arriving late changes nothing.
  purchased_at            timestamptz not null,
  expires_at              timestamptz,
  created_at              timestamptz not null default now()
);
create index appstore_subscriptions_user_idx on appstore_subscriptions (user_id);

-- What the app gives StoreKit as appAccountToken, to find the account from
-- what Apple hands back. One-way, as for Google Play.
alter table users add column appstore_account_token uuid
  generated always as (substr(encode(sha256(('appstore:' || id::text)::bytea), 'hex'), 1, 32)::uuid) stored;
create unique index users_appstore_account_idx on users (appstore_account_token);

alter table plan_products drop constraint plan_products_provider_check,
  add constraint plan_products_provider_check check (provider in ('kofi', 'play', 'paypal', 'appstore'));
alter table entitlements drop constraint entitlements_source_check,
  add constraint entitlements_source_check check (source in ('admin', 'kofi', 'play', 'paypal', 'appstore'));
alter table payment_events drop constraint payment_events_provider_check,
  add constraint payment_events_provider_check check (provider in ('kofi', 'play', 'paypal', 'appstore'));

-- +goose Down

delete from payment_events where provider = 'appstore';
alter table payment_events drop constraint payment_events_provider_check,
  add constraint payment_events_provider_check check (provider in ('kofi', 'play', 'paypal'));
delete from entitlements where source = 'appstore';
alter table entitlements drop constraint entitlements_source_check,
  add constraint entitlements_source_check check (source in ('admin', 'kofi', 'play', 'paypal'));
delete from plan_products where provider = 'appstore';
alter table plan_products drop constraint plan_products_provider_check,
  add constraint plan_products_provider_check check (provider in ('kofi', 'play', 'paypal'));
drop index users_appstore_account_idx;
alter table users drop column appstore_account_token;
drop table appstore_subscriptions;
