-- +goose Up

-- Push notifications move from Firebase to Web Push through UnifiedPush.
-- A phone now registers under an ID of its own choosing, with the endpoint
-- its push distributor gave it and the keys messages are encrypted with.
-- Firebase registrations cannot carry over; phones register again on their
-- next start.
delete from push_devices;
alter table push_devices
  add column endpoint text not null,
  add column p256dh   text not null,
  add column auth     text not null;
-- A phone registering takes its endpoint from whatever registration held it.
create index push_devices_endpoint_idx on push_devices (endpoint);

-- The server's VAPID key, which signs every message. Phones subscribe with
-- its public half, so every server sharing this database uses the one key.
create table vapid (
  id          boolean primary key default true check (id),
  private_key bytea not null,
  created_at  timestamptz not null default now()
);

-- +goose Down

drop table vapid;
delete from push_devices;
drop index push_devices_endpoint_idx;
alter table push_devices
  drop column endpoint,
  drop column p256dh,
  drop column auth;
