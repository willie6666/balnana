-- +goose Up

-- Subscriptions bought through Google Play, by purchase token. Google says how
-- long each lasts, so its entitlement follows the subscription rather than
-- the days on its product.
create table play_subscriptions (
  purchase_token text primary key,
  user_id        uuid not null references users(id) on delete cascade,
  product_id     text not null,
  entitlement_id uuid references entitlements(id) on delete set null,
  created_at     timestamptz not null default now()
);
create index play_subscriptions_user_idx on play_subscriptions (user_id);

-- +goose Down

drop table play_subscriptions;
