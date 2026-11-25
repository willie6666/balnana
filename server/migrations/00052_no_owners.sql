-- +goose Up

-- Every member of a group may do everything in it, so no one owns a group.
alter table members drop column is_owner;

-- +goose Down

-- Who owned what is gone: the first account still in each group gets it.
alter table members add column is_owner boolean not null default false;
update members set is_owner = true where id in (
  select distinct on (group_id) id from members
  where user_id is not null and left_at is null
  order by group_id, created_at);
