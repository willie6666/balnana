-- +goose Up

-- A sign-in with Google or OpenID Connect between leaving for the provider
-- and coming back. The state travels to the provider and back; the browser
-- also keeps it in a cookie, so a callback only works where it started.
create table oauth_logins (
  state_hash bytea primary key,
  provider   text not null,
  verifier   text not null,            -- PKCE code verifier
  nonce      text not null,
  app        text not null check (app in ('web', 'android')),
  next       text not null,            -- app path to open afterwards
  challenge  text,                     -- the Android app's PKCE challenge
  expires_at timestamptz not null
);

-- Hands a finished sign-in to the Android app, which proves with its own
-- verifier that it started it.
create table oauth_codes (
  code_hash  bytea primary key,
  user_id    uuid not null references users(id) on delete cascade,
  challenge  text not null,
  expires_at timestamptz not null
);

create index oauth_identities_user_idx on oauth_identities (user_id);

-- +goose Down

drop index oauth_identities_user_idx;
drop table oauth_codes;
drop table oauth_logins;
