-- +goose Up

-- Receipt photos live in the database next to their expense, so a backup of
-- the database is a backup of everything. They are small re-encoded JPEGs.
create table receipts (
  expense_id uuid primary key references expenses(id) on delete cascade,
  data       bytea not null,
  created_at timestamptz not null default now()
);
alter table expenses drop column receipt_url;

-- +goose Down

alter table expenses add column receipt_url text;
drop table receipts;
