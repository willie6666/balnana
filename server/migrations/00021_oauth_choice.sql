-- +goose Up

-- A provider sign-in whose address belongs to an account nobody has
-- confirmed yet, waiting for its person to say whether that account is
-- theirs. The token goes to the app as the code of a sign-in would.
create table oauth_pending (
  token_hash bytea primary key,
  provider   text not null,
  issuer     text not null,
  subject    text not null,
  email      citext not null,
  user_id    uuid not null references users(id) on delete cascade, -- the account with the address
  name       text not null,
  avatar_url text,
  challenge  text,
  expires_at timestamptz not null
);

-- A sign-in started from the account page adds its identity to that
-- account. The app opens the browser with a ticket, as the browser has no
-- session of its own.
alter table oauth_logins add column user_id uuid references users(id) on delete cascade;
create table oauth_link_tickets (
  ticket_hash bytea primary key,
  user_id     uuid not null references users(id) on delete cascade,
  expires_at  timestamptz not null
);

-- +goose Down

drop table oauth_link_tickets;
alter table oauth_logins drop column user_id;
drop table oauth_pending;
