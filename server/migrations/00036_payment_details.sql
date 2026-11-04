-- +goose Up

-- How to pay a member: a list of {label, value}, set in each group.
alter table members add column payment_details jsonb not null default '[]';

-- +goose Down
alter table members drop column payment_details;
