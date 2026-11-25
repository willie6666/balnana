-- +goose Up

-- A link that shows a group to anyone, without letting them change anything:
-- live, or a snapshot of the group when it was made. One per group.
create table view_links (
  id             uuid primary key default gen_random_uuid(),
  group_id       uuid not null unique references groups(id) on delete cascade,
  token          text not null unique,
  show_balances  boolean not null default true,
  show_expenses  boolean not null default true,
  show_spending  boolean not null default true,
  show_notes     boolean not null default false,
  show_places    boolean not null default false,
  show_receipts  boolean not null default false,
  -- The group as it was, for a snapshot; null for a live link.
  snapshot       jsonb,
  snapshot_at    timestamptz,
  created_at     timestamptz not null default now(),
  expires_at     timestamptz,
  -- Updated at most hourly.
  last_viewed_at timestamptz,
  check ((snapshot is null) = (snapshot_at is null)),
  check (snapshot is null or not show_receipts),
  check (show_balances or show_expenses or show_spending)
);

-- Whether a plan's groups may have a view-only link.
alter table plans add column view_link boolean not null default false;
update plans set view_link = true where id = 'plus';

-- +goose Down

alter table plans drop column view_link;
drop table view_links;
