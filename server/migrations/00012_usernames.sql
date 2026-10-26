-- +goose Up
-- Servers that do not require an email address let accounts sign in with a
-- username instead. The server stores it in lower case.
alter table users add column username citext unique;

-- +goose Down
alter table users drop column username;
