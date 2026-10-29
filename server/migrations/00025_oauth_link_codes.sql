-- +goose Up

-- A provider added from the account page in the app waits for the app's
-- verifier as a sign-in does: whoever finished it elsewhere cannot add it.
alter table oauth_codes
  add column link_provider text,
  add column link_issuer   text,
  add column link_subject  text,
  add column link_email    citext;

-- +goose Down

delete from oauth_codes where link_provider is not null;
alter table oauth_codes
  drop column link_provider,
  drop column link_issuer,
  drop column link_subject,
  drop column link_email;
