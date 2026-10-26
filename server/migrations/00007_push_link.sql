-- +goose Up

-- A link follow lasts only as long as the link it was made with: resetting
-- the group's link must cut off phones that only had the old one. Follows
-- made before this are dropped; phones register again on their next start.
delete from push_follows;
alter table push_follows add column link_token text not null;

-- +goose Down

alter table push_follows drop column link_token;
