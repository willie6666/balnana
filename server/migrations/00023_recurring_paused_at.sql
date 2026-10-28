-- +goose Up

-- When a recurring expense was paused, rather than only whether: resuming
-- adds what came due before then and skips what came due while it waited.
alter table recurring_expenses add column paused_at timestamptz;
update recurring_expenses set paused_at = updated_at where paused;
drop index recurring_expenses_due_idx;
alter table recurring_expenses drop column paused;
create index recurring_expenses_due_idx on recurring_expenses (next_at) where paused_at is null;

-- +goose Down

alter table recurring_expenses add column paused boolean not null default false;
update recurring_expenses set paused = paused_at is not null;
drop index recurring_expenses_due_idx;
alter table recurring_expenses drop column paused_at;
create index recurring_expenses_due_idx on recurring_expenses (next_at) where not paused;
