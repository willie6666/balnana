-- +goose Up

-- Keep the existing default for verified accounts and groups without a sponsor.
insert into plans (id, name, rank, receipts_per_group, recurring_per_group, joined_groups, members_per_group, sponsored_groups, reminders)
select 'email-unverified', 'Email unverified', rank, 0, recurring_per_group, 5, members_per_group, sponsored_groups, reminders
from plans where is_default
on conflict (id) do nothing;

create table automatic_plans (
  singleton boolean primary key default true check (singleton),
  unverified_plan_id text not null references plans(id),
  verified_plan_id text not null references plans(id)
);
insert into automatic_plans (unverified_plan_id, verified_plan_id)
select 'email-unverified', id from plans where is_default;

-- +goose Down

drop table automatic_plans;
-- Leave the plan in place: entitlements may now refer to it.
