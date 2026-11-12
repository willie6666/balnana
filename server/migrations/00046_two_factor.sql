-- +goose Up

-- Two-step sign-in with a password. Kept apart from users, so that signing in
-- with a code writes here and never to the account's row.
create table two_factor (
  user_id        uuid primary key references users(id) on delete cascade,
  -- The authenticator app's key, in base32. It asks for nothing at sign-in
  -- until a code from the app has shown the app has it (totp_enabled).
  totp_secret    text,
  totp_enabled   boolean not null default false,
  -- The time step of the last code taken, so that none signs in twice.
  totp_used_step bigint,
  -- Codes by email, to the account's confirmed address.
  email          boolean not null default false
);

-- Each signs in once in place of the authenticator app's code.
create table recovery_codes (
  user_id   uuid not null references users(id) on delete cascade,
  code_hash bytea not null,
  primary key (user_id, code_hash)
);

-- The code last emailed to an account that is signing in.
create table login_codes (
  user_id    uuid primary key references users(id) on delete cascade,
  code_hash  bytea not null,
  attempts   integer not null default 0,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

-- A PayPal trial pays nothing, but the administrator's list of payments shows
-- it: one record per subscription that had one.
insert into payment_events (provider, event_id, kind, product, recurring, state, plan_id, user_id, entitlement_id,
                            paid_at, reference, paid_until)
select 'paypal', s.subscription_id || '@trial', 'Trial', s.product, true, 'applied', e.plan_id, s.user_id,
       s.entitlement_id, s.created_at, s.subscription_id, s.trial_until
from paypal_subscriptions s left join entitlements e on e.id = s.entitlement_id
where s.trial_until is not null
on conflict (provider, event_id) do nothing;

-- +goose Down
delete from payment_events where provider = 'paypal' and kind = 'Trial';
drop table login_codes;
drop table recovery_codes;
drop table two_factor;
