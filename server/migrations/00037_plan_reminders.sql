-- +goose Up

-- Whether a plan's groups can send payment reminders as notifications.
-- Sharing a reminder as a message needs no server, so it is always free.
alter table plans add column reminders boolean not null default false;
update plans set reminders = true where id = 'plus';

-- +goose Down
alter table plans drop column reminders;
