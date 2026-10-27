-- +goose Up

-- What amounts are shown with, chosen by the group: "$" for a dollar of any
-- kind, say. Null shows the currency's own symbol.
alter table groups add column symbol text;

-- +goose Down

alter table groups drop column symbol;
