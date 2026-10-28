-- +goose Up

-- An expense that repeats: the server adds a copy of it at every occurrence.
-- Occurrence n is starts_at plus n times the interval, counted on the
-- calendar of time_zone, so it keeps its local time and day of the month.
create table recurring_expenses (
  id                uuid primary key default gen_random_uuid(),
  group_id          uuid not null references groups(id) on delete cascade,
  title             text not null,
  category_id       text references categories(id) on delete set null,
  amount            bigint not null check (amount > 0),   -- minor units of the group's currency
  split_method      split_method not null,
  note              text,
  location_name     text,
  latitude          double precision,
  longitude         double precision,
  unit              text not null check (unit in ('day', 'week', 'month', 'year')),
  every             integer not null check (every between 1 and 999),
  starts_at         timestamptz not null,
  time_zone         text not null,
  ends_on           date,                                -- last day an occurrence may fall on, in time_zone
  next_at           timestamptz,                         -- null once it has ended
  last_at           timestamptz,                         -- the latest occurrence added
  paused            boolean not null default false,
  created_by_member uuid references members(id) deferrable initially deferred,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  version           integer not null default 1
);

create index recurring_expenses_group_idx on recurring_expenses (group_id);
create index recurring_expenses_due_idx on recurring_expenses (next_at) where not paused;

create table recurring_expense_payers (
  recurring_id uuid references recurring_expenses(id) on delete cascade,
  member_id    uuid references members(id) deferrable initially deferred,
  amount       bigint not null check (amount > 0),
  primary key (recurring_id, member_id)
);

create table recurring_expense_splits (
  recurring_id uuid references recurring_expenses(id) on delete cascade,
  member_id    uuid references members(id) deferrable initially deferred,
  amount       bigint not null check (amount >= 0),
  share        numeric(12,4),
  primary key (recurring_id, member_id)
);

-- Each occurrence is added once, however often the job runs or retries.
alter table expenses
  add column recurring_id uuid references recurring_expenses(id) on delete set null,
  add column recurring_due timestamptz,
  add constraint expenses_recurring_once unique (recurring_id, recurring_due);

-- +goose Down

alter table expenses
  drop constraint expenses_recurring_once,
  drop column recurring_due,
  drop column recurring_id;
drop table recurring_expense_splits;
drop table recurring_expense_payers;
drop table recurring_expenses;
