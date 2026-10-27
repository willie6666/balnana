-- +goose Up

-- A changed address waits here until a link sent to it is opened. Until then
-- the account keeps its old address, so a mistyped one never takes its place
-- (an address no one has confirmed may be claimed by its owner).
alter table users add column pending_email citext;

-- The address a verification token confirms, when it is not the account's
-- current one.
alter table email_tokens add column email citext;

-- +goose Down

alter table email_tokens drop column email;
alter table users drop column pending_email;
