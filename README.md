# Balnana

Split group expenses: who paid what, who owes whom.

Balnana is a self-hosted group expense splitter for Android and the web. Share a
private group link with friends, add what everyone paid, and Balnana works out the
fewest payments that settle everyone up. Amounts are exact: money is stored and
computed as whole minor units (cents), never as floating point.

> Status: early development (milestone M0). The server, the app shell, settings and
> the money engine are in place; groups and expenses come next. See
> [docs/PLAN.md](docs/PLAN.md).

## Self-hosting with Docker

You need Docker with the Compose plugin.

```bash
cp .env.example .env
# Edit .env: set POSTGRES_PASSWORD and BALNANA_PUBLIC_URL at least.
docker compose up -d --build
```

The web app and the API are then on `http://localhost:8080` (change the port with
`BALNANA_PORT`). Database migrations run automatically on startup.

For anything beyond your own machine, put a TLS reverse proxy (Caddy, Traefik, nginx)
in front and set `BALNANA_PUBLIC_URL` to the public `https://` address: group links
are built from it.

Every setting is an environment variable; [.env.example](.env.example) lists them
all, including the access mode (`link` or `accounts`), email and OAuth sign-in.

### Connecting the apps

- **Web**: the web app talks to the server that serves it. Nothing to configure.
- **Android**: on first launch the app asks for the server address. It can be
  changed later in Settings → Server. A build can also bake in a default:
  `flutter build apk --dart-define=BALNANA_SERVER_URL=https://balnana.example.com`.
- A web app hosted on another origin needs that origin listed in
  `BALNANA_CORS_ORIGINS`.

## Development

The repository is a monorepo:

| Path       | What                                                                 |
|------------|----------------------------------------------------------------------|
| `server/`  | Go server (stdlib `net/http`, pgx, goose, oapi-codegen)               |
| `app/`     | Flutter app for Android and the web                                  |
| `api/`     | `openapi.yaml` (the API contract) and shared test vectors            |
| `docs/`    | Plan and design notes                                                |
| `scripts/` | Development helpers                                                  |

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
