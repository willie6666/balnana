-- +goose Up
-- Deleting a group or category checks these columns for every row it removes.
create index expense_payers_member_idx on expense_payers (member_id);
create index expense_splits_member_idx on expense_splits (member_id);
create index expenses_created_by_idx on expenses (created_by_member);
create index expenses_category_idx on expenses (category_id);
create index activity_log_actor_idx on activity_log (actor_member);

-- +goose Down
drop index activity_log_actor_idx;
drop index expenses_category_idx;
drop index expenses_created_by_idx;
drop index expense_splits_member_idx;
drop index expense_payers_member_idx;
