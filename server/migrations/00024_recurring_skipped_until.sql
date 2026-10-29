-- +goose Up

-- Where the occurrences skipped while a recurring expense was paused end, so
-- an edit after it has ended does not bring them back.
alter table recurring_expenses add column skipped_until timestamptz;

-- +goose Down

alter table recurring_expenses drop column skipped_until;
