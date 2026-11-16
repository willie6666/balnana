-- +goose Up

-- Accounts mode: a group can close its link, so no one joins by it alone.
-- Its members keep using it, and people invited by email can still join.
alter table groups add column link_closed boolean not null default false;

-- +goose Down
alter table groups drop column link_closed;
