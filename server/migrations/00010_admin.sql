-- +goose Up

-- The server's administrator: one password, no account. Until it is set,
-- the app sends people to /admin to set it. setup_code is asked for too when
-- the server already held data when it first needed setting up (an upgrade),
-- so whoever reaches /admin first cannot take over a running server; the
-- server prints it in its log.
create table admin (
  id            boolean primary key default true check (id),
  password_hash text,
  setup_code    text,
  created_at    timestamptz not null default now()
);
insert into admin default values;

create table admin_sessions (
  token_hash bytea primary key,
  expires_at timestamptz not null
);

-- Settings saved at /admin, by environment variable name. An environment
-- variable that is set wins over these.
create table settings (
  key        text primary key,
  value      text not null,
  updated_at timestamptz not null default now()
);

-- Tells every server sharing this database to reload the settings. Sent on
-- commit.
-- +goose StatementBegin
create function notify_settings_change() returns trigger language plpgsql as $$
begin
  perform pg_notify('balnana_settings', '');
  return null;
end
$$;
-- +goose StatementEnd

create trigger settings_notify after insert or update or delete on settings
  for each statement execute function notify_settings_change();

-- +goose Down

drop trigger settings_notify on settings;
drop function notify_settings_change();
drop table settings;
drop table admin_sessions;
drop table admin;
