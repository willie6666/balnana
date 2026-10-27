# Balnana

Split group expenses: who paid what, who owes whom.

Balnana is a self-hosted group expense splitter for Android and the web. Share a
private group link with friends, add what everyone paid, and Balnana works out the
fewest payments that settle everyone up. Amounts are exact: money is stored and
computed as whole minor units (cents), never as floating point.

Coming from Settle Up? Export the group as CSV there, then choose **New group →
Import** in Balnana: expenses, payments and members come along, and balances stay
the same. New imports preserve refunds and income: spending subtracts refunds
and excludes income, while balances still include every transaction. Imports
made before transaction direction was stored need to be imported again from the
original CSV into a new group to recover correct spending statistics; an upgrade
cannot infer the missing direction from the old balance rows.

> Status: early development, preparing the first release (milestone M6). Groups,
> expenses, balances, both access modes, live updates, statistics, imports and
> exports, receipts and push notifications work. See [docs/PLAN.md](docs/PLAN.md).

## Self-hosting with Docker

You need Docker with the Compose plugin.

```bash
cp .env.example .env
# Edit .env: set POSTGRES_PASSWORD at least.
docker compose up -d --build
```

The web app and the API are then on `http://localhost:8080` (change the port with
`BALNANA_PORT`). Database migrations run automatically on startup.

### Administration

The first time anyone opens a new server, the app sends them to `/admin` to choose
the administrator password (there is no username). After that, `/admin` asks for
the password and shows the server's settings: its public address, link or accounts
mode, password sign-in and sign-up, email (SMTP), Google and OpenID Connect sign-in,
and Android app links. Changes apply at once, on every server sharing the database.
Nothing in the app links to `/admin`; open it by typing the address.

Set it up right after starting a new server: until the password is set, whoever
opens the server first can set it. A server that already held groups or accounts
before it had administration also asks for a setup code, printed in its log
(`docker compose logs balnana`), so an upgrade cannot be taken over by a visitor.

Lost the administrator password? Run `docker compose exec balnana /balnana reset-admin`.
It signs everyone out of `/admin` and prints a setup code; open `/admin` and choose a
new password with that code.

Every setting can also be an environment variable; one that is set wins, and
`/admin` shows it as fixed. [.env.example](.env.example) marks which ones `/admin`
can change.

For anything beyond your own machine, put a TLS reverse proxy (Caddy, Traefik, nginx)
in front and set `BALNANA_PUBLIC_URL` to the public `https://` address: group links
are built from it. Behind a proxy, also set `BALNANA_TRUST_PROXY=true` so the
per-client rate limit (`BALNANA_RATE_LIMIT`, requests a minute) sees real client
addresses. While that limit is on, each client address may also create 30 groups at
once (then one a minute), create 10 accounts at once (then six an hour) and hold 100
live connections, and each account may send 20
email invitations at once (then one a minute), so the server cannot be used to send
spam. The limits are kept in memory by each server process.

The server sets no overall read timeout, since live updates hold connections open;
let the reverse proxy limit slow clients. Back up the PostgreSQL database
(`docker compose exec db pg_dump -U balnana balnana > backup.sql`): it holds
everything.

Open groups update live over Server-Sent Events (`/api/v1/g/<token>/events`). The
proxy must not buffer those responses; nginx honours the `X-Accel-Buffering: no`
header the server sends, and Caddy and Traefik need no setup. Serve over HTTP/2 if
you can: browsers allow only six HTTP/1.1 connections per site, and each open group
tab holds one.

[.env.example](.env.example) lists every setting, including the access mode (`link`
or `accounts`), email and OAuth sign-in.

In **link mode** (the default) a group's private link is all anyone needs. In
**accounts mode** (`BALNANA_AUTH_MODE=accounts`) people sign in, and a link only lets
signed-in people join the group, claiming one of its members or adding themselves.
A group owner can still open a group to anyone with the link, unless
`BALNANA_LINK_GROUPS=false`. The first account registered on a server can always
register, even with `BALNANA_AUTH_SIGNUP=closed`.

Accounts mode can also offer **Continue with Google** or any OpenID Connect provider
(Authentik, Keycloak, Dex, ...). Register
`<BALNANA_PUBLIC_URL>/api/v1/auth/oauth/google/callback` (or `.../oidc/callback`) as
the redirect URI and set the `BALNANA_OAUTH_*` variables. A provider sign-in joins an
existing account only when both sides have confirmed the same email. When the provider
has confirmed an address that an account claims but never confirmed, the provider's
person takes that account over, its password removed: whoever typed someone else's
address at sign-up cannot keep its owner out.

People can change or add their email address and delete their account in the app,
under Settings → Account; the web page `/delete-account` does the same after signing
in, for app stores that ask for a deletion link. A deleted account's members stay in
their groups, unclaimed, so balances still add up; ownership passes to the member who
joined first, and groups nobody else can reach are deleted with it. Group owners (or,
in link mode, anyone with the link) can delete a whole group under its settings. The
administrator can find and delete accounts under `/admin` → Accounts.

The app links a privacy notice from its sign-in page and Settings → About. Set
`BALNANA_PRIVACY_URL` (or the field under `/admin`) to your own policy; without it the
app shows a short built-in description of what the server stores.

### Connecting the apps

- **Web**: the web app talks to the server that serves it. Nothing to configure.
- **Android**: on first launch the app asks for the server address. It can be
  changed later in Settings → Server. A build can also bake in a default:
  `flutter build apk --dart-define=BALNANA_SERVER_URL=https://balnana.example.com`.
  Such a build also opens that server's group, invitation and email links in the
  app. For Android to do so without asking, enter the SHA-256 fingerprint of the
  build's signing certificate under `/admin` → Android app links (or set
  `BALNANA_ANDROID_CERT_SHA256`); `keytool -list -v -keystore <your keystore>`
  prints it. The server then serves `/.well-known/assetlinks.json`.
- A web app hosted on another origin needs that origin listed in
  `BALNANA_CORS_ORIGINS`.

### Push notifications

The server notifies phones when someone adds, changes or deletes an expense they are
in. Nothing to set up: the server makes its own VAPID key the first time it starts
and keeps it in the database. `BALNANA_PUSH=false` turns notifications off.

Notifications are standard Web Push messages, encrypted end to end, delivered over
[UnifiedPush](https://unifiedpush.org/). A phone with a UnifiedPush distributor such
as [ntfy](https://ntfy.sh/) gets them through it. Otherwise the app uses the
distributor built in, which goes through Google's Firebase Cloud Messaging on phones
with Google Play services; the app contains no Firebase SDK and needs no Firebase
project. Settings → Notifications turns them off and on per device.

The server only sends to public https addresses. A distributor on your own network
(for example a self-hosted ntfy at `http://192.168.1.2`) needs
`BALNANA_PUSH_PRIVATE_ENDPOINTS=true`.

### Android release builds

Release APKs are signed with your own upload key. Create one once and keep it, and
its passwords, safe: every later update must be signed with the same key.

```bash
keytool -genkeypair -v -keystore ~/balnana-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then create `app/android/key.properties` (git ignores it):

```properties
storeFile=/home/you/balnana-upload.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

`storeFile` may also be relative to `app/android/`. `flutter build apk --release`
(or `appbundle`) now signs with that key. Without `key.properties`,
`flutter build appbundle` stops with an error, and release APKs are signed with the
debug key, with a warning: fine for trying them out, but they cannot update an
installed properly signed app, and the reverse.

### Publishing the Android app

App stores such as Google Play ask for a few things the code cannot supply:

- **A default server.** Build with `--dart-define=BALNANA_SERVER_URL=https://...`
  so people do not have to type an address on first launch.
- **A privacy policy URL**, public and reachable without signing in: set
  `BALNANA_PRIVACY_URL` to your policy, or give the store `<server>/privacy`, the
  built-in notice.
- **An account deletion URL** (accounts mode): `<server>/delete-account`.
- **The release key** (above) for the app bundle: `flutter build appbundle` refuses
  to build without it. With Play App Signing, add Play's app signing certificate
  fingerprint to `BALNANA_ANDROID_CERT_SHA256` as well, so app links keep working.
- The store's data safety form: the server stores names, email addresses, the groups'
  expenses and receipt photos, and (with push notifications) the push service address
  each phone gives it.

The app contains no proprietary libraries, so it can be built for F-Droid. Its built-in
push distributor still uses Google's Firebase Cloud Messaging as a network service
when no other distributor is installed, which F-Droid may label as an anti-feature.

## Development

The repository is a monorepo:

| Path       | What                                                                 |
|------------|----------------------------------------------------------------------|
| `server/`  | Go server (stdlib `net/http`, pgx, goose, oapi-codegen)               |
| `app/`     | Flutter app for Android and the web                                  |
| `api/`     | `openapi.yaml` (the API contract) and shared test vectors            |
| `docs/`    | Plan and design notes                                                |
| `scripts/` | Development helpers                                                  |

See [docs/CODE_REVIEW.md](docs/CODE_REVIEW.md) for the review findings, follow-up
status, and verification results for the reviewed revision.

### Setup

On NixOS or with Nix installed, `nix-shell` provides Go, PostgreSQL, goose,
oapi-codegen and the JDK, and points Flutter and the Android SDK at local installs
(edit the paths in [shell.nix](shell.nix) for your machine). Otherwise install
Go 1.26, PostgreSQL 18 and Flutter 3.47 yourself.

```bash
nix-shell
scripts/db.sh start            # local Postgres in .pgdata/, unix socket only
```

### Server

```bash
cd server
go generate ./...              # after editing api/openapi.yaml
go test ./...
go run ./cmd/balnana           # uses DATABASE_URL from nix-shell; serves on :8080
```

To serve a local web build too, set `BALNANA_WEB_DIR=../app/build/web`.

### App

```bash
cd app
flutter test
flutter run -d chrome --dart-define=BALNANA_SERVER_URL=http://localhost:8080
flutter run -d emulator-5554   # then enter http://10.0.2.2:8080 as the server
```

`10.0.2.2` is how the Android emulator reaches your computer.

The launcher icons, splash logos and web icons are all drawn by
`scripts/make-icons.py` (needs Pillow). Change the shape or colors there and run it
again rather than editing the generated files.

Flutter 3.47 moved Material out of the SDK into the `material_ui` package: import
`package:material_ui/material_ui.dart`, not `package:flutter/material.dart`.

### IntelliJ IDEA

Open the repository root. With the Go and Flutter/Dart plugins installed, IDEA picks
up `server/` as a Go module and `app/` as a Flutter project (set the Flutter SDK path
in Settings → Languages & Frameworks → Flutter). Run configurations are not checked
in; create one for `server/cmd/balnana` with the environment variables you need.

### Rules of the codebase

- English only in code, comments and docs. Translations live in
  `app/lib/l10n/app_*.arb`; `scripts/check-english.sh` enforces this.
- No user-facing string literals in widgets: add them to `app_en.arb`.
- No color literals in widgets: use the theme (`ColorScheme`, `context.bColors`).
- Money is never `double`. Go uses `int64` minor units, Dart uses `BigInt`, and the
  API sends amounts as decimal strings. Both implementations must pass
  `api/testdata/money.json`.

## License

Balnana is free software, licensed under the
[GNU Affero General Public License v3.0](LICENSE) (`AGPL-3.0-only`).

You may run, study, change and share it. If you run a modified version as a service
that other people use over a network, you must offer those users the source code of
your version under the same license. Running an unmodified copy needs nothing extra.
The app links to the source under Settings → About → Source code; it points to
[this repository](https://github.com/willie6666/balnana) unless you set `BALNANA_SOURCE_URL` to your own.

Bundled third-party parts keep their own licenses, for example the Plus Jakarta Sans
font (SIL Open Font License, `app/assets/fonts/OFL.txt`). The app lists them all
under Settings → About → Open source licenses.
