-- +goose Up

create extension if not exists citext;

-- Accounts mode only ---------------------------------------------------------

create table users (
  id               uuid primary key default gen_random_uuid(),
  email            citext unique,
  email_verified   boolean not null default false,
  password_hash    text,                 -- null when only OAuth is used
  display_name     text not null,
  avatar_url       text,
  locale           text,                 -- preferred UI language; null = follow device
  created_at       timestamptz not null default now()
);

create table oauth_identities (
  provider    text not null,             -- 'google', 'oidc'
  subject     text not null,             -- provider's stable user id
  user_id     uuid not null references users(id) on delete cascade,
  primary key (provider, subject)
);

create table refresh_tokens (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(id) on delete cascade,
  token_hash bytea not null unique,
  expires_at timestamptz not null,
  revoked_at timestamptz
);

create table email_tokens (              -- verification + password reset
  token_hash bytea primary key,
  user_id    uuid not null references users(id) on delete cascade,
  purpose    text not null check (purpose in ('verify', 'reset')),
  expires_at timestamptz not null
);

-- Both modes -------------------------------------------------------------------

create table groups (
  id             uuid primary key default gen_random_uuid(),
  token          text not null unique,           -- secret, appears in the URL
  name           text not null,
  emoji          text,
  color          integer check (color between 0 and 16777215), -- 0xRRGGBB
  currency       char(3) not null,
  minor_digits   smallint not null default 2 check (minor_digits between 0 and 4),
  simplify_debts boolean not null default true,
  link_access    boolean not null default true,  -- always true in link mode
  created_at     timestamptz not null default now(),
  archived_at    timestamptz
);

create table members (
  id           uuid primary key default gen_random_uuid(),
  group_id     uuid not null references groups(id) on delete cascade,
  user_id      uuid references users(id),        -- null = unclaimed / link-mode member
  display_name text not null,                     -- per-group nickname
  color        integer check (color between 0 and 16777215),
  is_owner     boolean not null default false,
  created_at   timestamptz not null default now(),
  left_at      timestamptz,                       -- members with history are marked, never deleted
  unique (group_id, user_id)
);

create table categories (            -- fixed built-in list first; group-custom categories later
  id    text primary key,            -- display names come from l10n, keyed by id
  emoji text not null,
  color integer not null check (color between 0 and 16777215)
);

insert into categories (id, emoji, color) values
  ('food',          '🍔', x'F07C2E'::int),
  ('groceries',     '🛒', x'3C9D6B'::int),
  ('transport',     '🚌', x'3E8EDE'::int),
  ('travel',        '✈️', x'1F9E9A'::int),
  ('lodging',       '🏨', x'8E5BC8'::int),
  ('rent',          '🏠', x'8A5A3C'::int),
  ('utilities',     '💡', x'E8A800'::int),
  ('entertainment', '🎟️', x'D2486A'::int),
  ('shopping',      '🛍️', x'B57EDC'::int),
  ('health',        '💊', x'2E7D5B'::int),
  ('gifts',         '🎁', x'C2415B'::int),
  ('other',         '📦', x'5D6B82'::int);

create type expense_kind as enum ('expense', 'payment');
create type split_method as enum ('equal', 'exact', 'percent', 'shares');

create table expenses (
  id                uuid primary key default gen_random_uuid(),
  group_id          uuid not null references groups(id) on delete cascade,
  kind              expense_kind not null default 'expense',
  title             text not null,
  category_id       text references categories(id),
  amount            bigint not null check (amount > 0),   -- minor units of `currency`
  currency          char(3) not null,
  exchange_rate     numeric(20,10) not null default 1,
  split_method      split_method not null,
  occurred_at       timestamptz not null,
  note              text,
  receipt_url       text,
  created_by_member uuid references members(id),     -- null if the device had not picked an identity
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,                      -- soft delete, restorable
  version           integer not null default 1        -- optimistic locking for concurrent edits
);

create table expense_payers (
  expense_id uuid references expenses(id) on delete cascade,
  member_id  uuid references members(id),
  amount     bigint not null check (amount > 0),
  primary key (expense_id, member_id)
);

create table expense_splits (
  expense_id uuid references expenses(id) on delete cascade,
  member_id  uuid references members(id),
  amount     bigint not null check (amount >= 0),   -- final computed amount
  share      numeric(12,4),                          -- raw input: percent or shares (for display)
  primary key (expense_id, member_id)
);

create table activity_log (
  id           bigserial primary key,
  group_id     uuid not null references groups(id) on delete cascade,
  actor_member uuid references members(id),
  action       text not null,          -- expense.created / expense.updated / member.joined / group.link_reset ...
  subject_id   uuid,
  payload      jsonb not null,         -- structured before/after; rendered client-side in the viewer's language
  created_at   timestamptz not null default now()
);

create index activity_log_group_idx on activity_log (group_id, id desc);
create index expenses_group_idx on expenses (group_id, occurred_at desc) where deleted_at is null;
create index members_user_idx on members (user_id) where user_id is not null;

-- +goose Down

drop table activity_log;
drop table expense_splits;
drop table expense_payers;
drop table expenses;
drop type split_method;
drop type expense_kind;
drop table categories;
drop table members;
drop table groups;
drop table email_tokens;
drop table refresh_tokens;
drop table oauth_identities;
drop table users;
