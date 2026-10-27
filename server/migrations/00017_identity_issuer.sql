-- +goose Up

-- The issuer that vouched for the subject, which is only unique at its issuer:
-- the OpenID Connect provider can be replaced, and the new one's subjects are
-- other people. Google's is known. The OpenID Connect ones are named by the
-- server when it starts with a provider configured, as the one they were made
-- with; until then they sign nobody in.
alter table oauth_identities add column issuer text;
update oauth_identities set issuer = 'https://accounts.google.com' where provider = 'google';
alter table oauth_identities drop constraint oauth_identities_pkey;
create unique index oauth_identities_key on oauth_identities (provider, issuer, subject);

-- +goose Down

delete from oauth_identities a using oauth_identities b
where a.provider = b.provider and a.subject = b.subject and a.ctid > b.ctid;
drop index oauth_identities_key;
alter table oauth_identities drop column issuer;
alter table oauth_identities add primary key (provider, subject);
