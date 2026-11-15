-- +goose Up

-- A group's password, as an argon2id hash, or null for none. Anyone who is
-- not a member of the group must give it before the group opens for them,
-- even with its link. The key a device keeps once it gave the password is
-- derived from this hash, so a new password shuts out every old key.
alter table groups add column password_hash text;

-- +goose Down
alter table groups drop column password_hash;
