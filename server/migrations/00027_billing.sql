-- +goose Up

-- What people may use on a server that charges for it. Nothing here is read
-- while BALNANA_BILLING_ENABLED is off. A null limit means no limit.
create table plans (
  id                  text primary key check (id ~ '^[a-z0-9][a-z0-9-]{0,31}$'),
  name                text not null,
  rank                integer not null default 0,   -- the highest active plan wins
  is_default          boolean not null default false,
  receipts_per_group  integer check (receipts_per_group >= 0),
  recurring_per_group integer check (recurring_per_group >= 0),
  own_groups          integer check (own_groups >= 0),
  sponsored_groups    integer check (sponsored_groups >= 0)
);
-- Exactly one: what anyone without an entitlement has.
create unique index plans_default_idx on plans (is_default) where is_default;

insert into plans (id, name, rank, is_default, receipts_per_group, recurring_per_group, own_groups, sponsored_groups) values
  ('free', 'Free', 0, true, 20, 2, 5, 0),
  ('plus', 'Plus', 10, false, 2000, 50, 50, 10);

-- What a payment buys. A Ko-fi product is a membership tier's name; one with
-- no name is any payment of at least min_amount in currency.
create table plan_products (
  id         uuid primary key default gen_random_uuid(),
  provider   text not null check (provider in ('kofi', 'play')),
  product    text not null default '',
  plan_id    text not null references plans(id),
  days       integer not null check (days > 0),
  min_amount numeric(12,2) check (min_amount >= 0),
  currency   text check (currency ~ '^[A-Z]{3}$')
);
create unique index plan_products_product_idx on plan_products (provider, lower(product), coalesce(min_amount, 0), coalesce(currency, ''));

-- A period of a plan. Someone's plan is worked out from these, never stored
-- on the account, so it ends by itself. A null expires_at never ends.
create table entitlements (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(id) on delete cascade,
  plan_id    text not null references plans(id),
  source     text not null check (source in ('admin', 'kofi', 'play')),
  note       text,
  starts_at  timestamptz not null default now(),
  expires_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);
create index entitlements_user_idx on entitlements (user_id);

-- Every payment a provider reported, whether it found its account or not.
-- A provider that repeats itself is told apart by (provider, event_id).
-- Records outlive the account they belonged to.
create table payment_events (
  id             uuid primary key default gen_random_uuid(),
  provider       text not null check (provider in ('kofi', 'play')),
  event_id       text not null,
  kind           text not null,
  email          citext,
  payer_name     text,
  amount         numeric(12,2),
  currency       text,
  product        text,
  recurring      boolean not null default false,
  -- applied: an entitlement came of it. unclaimed: it bought a plan, for an
  -- address no account has shown is theirs yet. unmatched: nothing it bought
  -- is configured, so an administrator decides.
  state          text not null check (state in ('applied', 'unclaimed', 'unmatched')),
  plan_id        text references plans(id) on delete set null,
  days           integer,
  user_id        uuid references users(id) on delete set null,
  entitlement_id uuid references entitlements(id) on delete set null,
  paid_at        timestamptz not null,
  created_at     timestamptz not null default now(),
  unique (provider, event_id)
);
create index payment_events_created_idx on payment_events (created_at desc);
create index payment_events_email_idx on payment_events (email) where state = 'unclaimed';

-- Addresses an account proved it reads, so that payments made with one reach
-- it. The latest account to prove an address has it.
create table payment_emails (
  email      citext primary key,
  user_id    uuid not null references users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create index payment_emails_user_idx on payment_emails (user_id);

-- Who pays for this group's limits, for as long as they are a member of it.
-- Not the owner: ownership passes on by itself, and paying must not.
alter table groups add column sponsor_user_id uuid references users(id) on delete set null;
create index groups_sponsor_idx on groups (sponsor_user_id) where sponsor_user_id is not null;

alter table email_tokens drop constraint email_tokens_purpose_check;
alter table email_tokens add constraint email_tokens_purpose_check check (purpose in ('verify', 'reset', 'payment'));

-- +goose Down

delete from email_tokens where purpose = 'payment';
alter table email_tokens drop constraint email_tokens_purpose_check;
alter table email_tokens add constraint email_tokens_purpose_check check (purpose in ('verify', 'reset'));

alter table groups drop column sponsor_user_id;
drop table payment_emails;
drop table payment_events;
drop table entitlements;
drop table plan_products;
drop table plans;
