-- +goose Up

-- A web app on another origin (one listed in BALNANA_CORS_ORIGINS) gets its
-- sign-in back as a code, like the Android app, at its own /oauth-done.
alter table oauth_logins add column origin text;

-- +goose Down

alter table oauth_logins drop column origin;
