-- +goose Up

-- Invitations carry a secret, sent only in the invitation email: following
-- the link proves the address belongs to whoever registers with it.
delete from invites;
alter table invites
  add column token_hash bytea not null unique,
  add column expires_at timestamptz not null;
create index invites_group_idx on invites (group_id);

-- When a token was made, so the same email is not sent again within a minute.
alter table email_tokens add column created_at timestamptz not null default now();
create index email_tokens_user_idx on email_tokens (user_id, purpose);

-- +goose Down

drop index email_tokens_user_idx;
alter table email_tokens drop column created_at;
drop index invites_group_idx;
alter table invites drop column token_hash, drop column expires_at;
