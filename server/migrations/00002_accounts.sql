-- +goose Up

-- Sign-in sessions. The token itself is only ever with the client (a cookie on
-- the web, a bearer token on Android); the server keeps its SHA-256.
drop table refresh_tokens;

create table sessions (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references users(id) on delete cascade,
  token_hash   bytea not null unique,
  created_at   timestamptz not null default now(),
  last_used_at timestamptz not null default now(),
  expires_at   timestamptz not null
);
create index sessions_user_idx on sessions (user_id);

-- Email invitations to a group, optionally for one placeholder member. With
-- BALNANA_AUTH_SIGNUP=invite_only, only invited addresses may register.
create table invites (
  id         uuid primary key default gen_random_uuid(),
  group_id   uuid not null references groups(id) on delete cascade,
  email      citext not null,
  member_id  uuid references members(id) on delete cascade,
  invited_by uuid references members(id) on delete set null,
  created_at timestamptz not null default now()
);
create index invites_email_idx on invites (email);

-- +goose Down

drop table invites;
drop table sessions;

create table refresh_tokens (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(id) on delete cascade,
  token_hash bytea not null unique,
  expires_at timestamptz not null,
  revoked_at timestamptz
);
