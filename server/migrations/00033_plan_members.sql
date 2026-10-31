-- +goose Up

-- A plan now limits the groups an account is in, whoever made them, and the
-- people in a group.
alter table plans rename column own_groups to joined_groups;
alter table plans rename constraint plans_own_groups_check to plans_joined_groups_check;
alter table plans add column members_per_group integer check (members_per_group >= 0);
update plans set joined_groups = 10, members_per_group = 15 where id = 'free';
update plans set joined_groups = 50, members_per_group = 100 where id = 'plus';

-- +goose Down
update plans set joined_groups = 5 where id = 'free';
alter table plans drop column members_per_group;
alter table plans rename constraint plans_joined_groups_check to plans_own_groups_check;
alter table plans rename column joined_groups to own_groups;
