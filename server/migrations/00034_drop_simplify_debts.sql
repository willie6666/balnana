-- +goose Up

-- Never read or written: every group's suggestions settle debts the same way.
alter table groups drop column simplify_debts;

-- +goose Down
alter table groups add column simplify_debts boolean not null default true;
