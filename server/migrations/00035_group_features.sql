-- +goose Up

-- What a group offers when adding expenses. Off hides the way to add more
-- and the server refuses new ones; what is there already stays. Switching
-- recurring off holds every schedule.
alter table groups
  add column foreign_currency boolean not null default true,
  add column recurring boolean not null default true,
  add column places boolean not null default true,
  add column receipts boolean not null default true;

-- +goose Down
alter table groups
  drop column foreign_currency,
  drop column recurring,
  drop column places,
  drop column receipts;
