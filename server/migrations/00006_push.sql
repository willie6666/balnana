-- +goose Up

-- Phones to notify, by their Firebase Cloud Messaging token. A signed-in
-- phone hears about its account's groups until the session ends; any phone
-- also hears about the link groups it follows, as the member it is there.
-- The app registers again on every start, so phones gone quiet are dropped.
create table push_devices (
  token      text primary key,
  session_id uuid references sessions(id) on delete cascade,
  updated_at timestamptz not null default now()
);
create index push_devices_session_idx on push_devices (session_id);
create index push_devices_updated_idx on push_devices (updated_at);

create table push_follows (
  device    text not null references push_devices(token) on delete cascade,
  group_id  uuid not null references groups(id) on delete cascade,
  member_id uuid not null references members(id) on delete cascade,
  primary key (device, group_id)
);
create index push_follows_group_idx on push_follows (group_id, member_id);

-- +goose Down

drop table push_follows;
drop table push_devices;
