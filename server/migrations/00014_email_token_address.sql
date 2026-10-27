-- +goose Up

-- A verification or reset token is good only for the address it was sent to:
-- once the account's address changes, links sent earlier stop working, even
-- one made while the change was under way. Older tokens never recorded their
-- address, so they go; people can ask for another link.
delete from email_tokens;
alter table email_tokens add column email citext not null;

-- +goose Down

alter table email_tokens drop column email;
