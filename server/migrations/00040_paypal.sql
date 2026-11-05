-- +goose Up

-- PayPal sells plans next to Ko-fi and Google Play. Ko-fi no longer sells
-- memberships here: its payments are one-offs, claimed by transaction ID.
alter table plan_products drop constraint plan_products_provider_check,
  add constraint plan_products_provider_check check (provider in ('kofi', 'play', 'paypal'));
alter table entitlements drop constraint entitlements_source_check,
  add constraint entitlements_source_check check (source in ('admin', 'kofi', 'play', 'paypal'));
-- refunded: the provider gave the money back, and the time it bought with it.
alter table payment_events drop constraint payment_events_provider_check,
  add constraint payment_events_provider_check check (provider in ('kofi', 'play', 'paypal')),
  drop constraint payment_events_state_check,
  add constraint payment_events_state_check check (state in ('applied', 'unclaimed', 'unmatched', 'refunded'));

-- Checkouts started from the app. What was asked for is kept here, since an
-- order says only what it cost.
create table paypal_orders (
  order_id   text primary key,
  user_id    uuid not null references users(id) on delete cascade,
  product    text not null,
  plan_id    text references plans(id) on delete set null,
  days       integer not null check (days > 0),
  amount     numeric(12,2) not null,
  currency   text not null,
  created_at timestamptz not null default now()
);
create index paypal_orders_user_idx on paypal_orders (user_id);

-- Subscriptions started from the app; product is PayPal's plan ID. Each has
-- an entitlement of its own that runs to the next billing time.
create table paypal_subscriptions (
  subscription_id text primary key,
  user_id         uuid not null references users(id) on delete cascade,
  product         text not null,
  entitlement_id  uuid references entitlements(id) on delete set null,
  state           text,
  created_at      timestamptz not null default now()
);
create index paypal_subscriptions_user_idx on paypal_subscriptions (user_id);

-- Payment codes and the addresses Ko-fi memberships went by.
drop index payment_events_email_idx;
drop table payment_emails;
alter table users drop column payment_code;
alter table entitlements drop column paid_through;

-- +goose Down

alter table entitlements add column paid_through timestamptz;
alter table users add column payment_code text unique;
create table payment_emails (
  email      citext primary key,
  user_id    uuid not null references users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create index payment_emails_user_idx on payment_emails (user_id);
create index payment_events_email_idx on payment_events (email) where state = 'unclaimed';

drop table paypal_subscriptions;
drop table paypal_orders;

delete from payment_events where provider = 'paypal';
update payment_events set state = 'unmatched' where state = 'refunded';
delete from plan_products where provider = 'paypal';
update entitlements set source = 'admin' where source = 'paypal';
alter table payment_events drop constraint payment_events_state_check,
  add constraint payment_events_state_check check (state in ('applied', 'unclaimed', 'unmatched')),
  drop constraint payment_events_provider_check,
  add constraint payment_events_provider_check check (provider in ('kofi', 'play'));
alter table entitlements drop constraint entitlements_source_check,
  add constraint entitlements_source_check check (source in ('admin', 'kofi', 'play'));
alter table plan_products drop constraint plan_products_provider_check,
  add constraint plan_products_provider_check check (provider in ('kofi', 'play'));
