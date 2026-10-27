# Balnana

Split group expenses: who paid what, who owes whom.

Balnana is a self-hosted group expense splitter for Android and the web. Share a
private group link with friends, add what everyone paid, and Balnana works out the
fewest payments that settle everyone up.

> Status: early development, preparing the first release.

## Features

- **Exact money.** Amounts are stored and computed as whole minor units (cents),
  never as floating point.
- **Private group links.** In link mode a group's link is all anyone needs. In
  accounts mode people sign in with a password, Google or any OpenID Connect
  provider.
- **Flexible splits.** Split equally, by exact amounts, by percentages or by shares,
  with several payers per expense.
- **Simplified debts.** Balances turn into the fewest payments that settle the
  group.
- **Live updates.** Open groups update as others add expenses, and phones get push
  notifications over UnifiedPush, with no Firebase SDK in the app.
- **Statistics, receipts and exports.** Spending by category, member and month, receipt
  photos, and CSV export.
- **Import from Settle Up.** Bring a group over from its CSV export, balances
  intact.
- **Yours to run.** One Docker Compose file, a PostgreSQL database and a web page to
  administer the server.

## Quick start

You need Docker with the Compose plugin.

```bash
cp .env.example .env
# Edit .env: set POSTGRES_PASSWORD at least.
docker compose up -d --build
```

Open `http://localhost:8080`. The first visit asks you to choose the administrator
password, so do that right away. [.env.example](.env.example) lists every setting.

## Built with

A Go server (`server/`) with PostgreSQL, and a Flutter app (`app/`) for Android and
the web. `api/openapi.yaml` is the contract between them.

## License

Balnana is free software, licensed under the
[GNU Affero General Public License v3.0](LICENSE) (`AGPL-3.0-only`).

You may run, study, change and share it. If you run a modified version as a service
that other people use over a network, you must offer those users the source code of
your version under the same license.
