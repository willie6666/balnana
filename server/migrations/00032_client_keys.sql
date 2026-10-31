-- +goose Up
-- What the app named a new row, so that sending it again after a lost answer
-- does not add it twice.
alter table expenses add column client_key uuid;
create unique index expenses_client_key_idx on expenses (group_id, client_key) where client_key is not null;
alter table recurring_expenses add column client_key uuid;
create unique index recurring_client_key_idx on recurring_expenses (group_id, client_key) where client_key is not null;

-- +goose Down
drop index recurring_client_key_idx;
alter table recurring_expenses drop column client_key;
drop index expenses_client_key_idx;
alter table expenses drop column client_key;
