-- +goose Up

-- Remember which password authorized a link follow. A registration may
-- finish after a password change deletes the old follows, so delivery also
-- checks this against the group's current hash. Null passwords allow all
-- follows, including those retained when the password was removed.
alter table push_follows add column password_hash text;

-- Older follows cannot prove which password authorized them. Drop those
-- for protected groups; phones register again on their next start. Follows
-- for groups without a password stay in place.
delete from push_follows f using groups g
where g.id = f.group_id and g.password_hash is not null;

-- +goose Down
alter table push_follows drop column password_hash;
