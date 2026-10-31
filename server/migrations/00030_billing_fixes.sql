-- +goose Up
-- Where the time memberships paid for ends. What expires_at holds past it is
-- one-off time, which renewals must not swallow.
alter table entitlements add column paid_through timestamptz;
update entitlements e set paid_through = e.expires_at
where exists (select 1 from payment_events p where p.entitlement_id = e.id and p.recurring)
  and e.source <> 'play';

-- What Google last said of the purchase, so that one on hold is not taken for
-- one that has ended.
alter table play_subscriptions add column state text;

-- playAccountID, to find an account from what Google hands back.
alter table users add column play_account_id text
  generated always as (encode(sha256(id::text::bytea), 'hex')) stored;
create unique index users_play_account_idx on users (play_account_id);

-- +goose Down
drop index users_play_account_idx;
alter table users drop column play_account_id;
alter table play_subscriptions drop column state;
alter table entitlements drop column paid_through;
