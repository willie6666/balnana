#!/usr/bin/env bash
# Install or update a native Debian-family deployment from this checkout.
set -Eeuo pipefail
umask 022

usage() {
  cat <<'EOF'
Usage: sudo ./scripts/deploy-debian.sh

Installs build dependencies and local PostgreSQL, builds the Flutter web app
and Go server, and enables/restarts balnana.service. Run again after git pull
to update. Existing /etc/balnana/balnana.env and database contents are preserved.
The checkout's .env is NOT loaded (it may contain Docker/development settings).

Optional environment variables (pass with sudo env NAME=value ...):
  GO_VERSION       Default: the go directive in server/go.mod
  FLUTTER_VERSION  Default: FLUTTER_VERSION in Dockerfile

Configuration: /etc/balnana/balnana.env
Logs:          journalctl -u balnana.service -f
EOF
}

die() { echo "Error: $*" >&2; exit 1; }
log() { printf '\n==> %s\n' "$*"; }

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  '') ;;
  *) usage >&2; exit 2 ;;
esac
[[ $# -eq 0 ]] || die "Unexpected arguments. Use --help."
[[ $EUID -eq 0 ]] || die "Run this script with sudo (or as root)."
[[ -r /etc/os-release ]] || die "Cannot identify this operating system."
# shellcheck source=/dev/null
. /etc/os-release
case " ${ID:-} ${ID_LIKE:-} " in
  *' debian '*|*' ubuntu '*) ;;
  *) die "This script requires a Debian-family system." ;;
esac
[[ -d /run/systemd/system ]] || die "systemd must be running as PID 1."
for command in apt-get systemctl runuser flock tar; do
  command -v "$command" >/dev/null || die "Required command not found: $command"
done

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
GO_VERSION="${GO_VERSION:-$(awk '$1 == "go" {print $2; exit}' "$PROJECT_ROOT/server/go.mod")}"
FLUTTER_VERSION="${FLUTTER_VERSION:-$(sed -n 's/^ARG FLUTTER_VERSION=//p' "$PROJECT_ROOT/Dockerfile" | head -n 1)}"
[[ $GO_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "Invalid GO_VERSION: $GO_VERSION"
[[ $FLUTTER_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "Invalid FLUTTER_VERSION: $FLUTTER_VERSION"
case "$(uname -m)" in
  x86_64) GO_ARCH=amd64 ;;
  aarch64|arm64) GO_ARCH=arm64 ;;
  *) die "Only amd64 and arm64 hosts are supported." ;;
esac

# Hold the lock through the build and restart, including runs from other checkouts.
exec 9>/run/lock/balnana-deploy.lock
flock -n 9 || die "Another Balnana deployment is running."
BUILD_DIR=''
cleanup() {
  if [[ -n $BUILD_DIR ]]; then rm -rf -- "$BUILD_DIR"; fi
}
trap cleanup EXIT
trap 'echo "Deployment failed at line $LINENO. See the output above; service logs: journalctl -u balnana.service -n 80 --no-pager" >&2' ERR

log "Installing Debian packages"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  ca-certificates curl git unzip xz-utils zip file libglu1-mesa libstdc++6 \
  python3 postgresql postgresql-client

log "Preparing service and build accounts"
if ! getent passwd balnana >/dev/null; then
  useradd --system --user-group --home-dir /var/lib/balnana \
    --no-create-home --shell /usr/sbin/nologin balnana
fi
if ! getent passwd balnana-build >/dev/null; then
  useradd --system --user-group --home-dir /var/cache/balnana-build \
    --no-create-home --shell /usr/sbin/nologin balnana-build
fi
BUILD_HOME=/var/cache/balnana-build
install -d -o balnana-build -g balnana-build -m 0750 "$BUILD_HOME"
install -d -o root -g root -m 0755 /opt/balnana
install -d -o root -g balnana -m 0750 /etc/balnana
BUILD_DIR="$(mktemp -d "$BUILD_HOME/deploy.XXXXXXXX")"
chmod 0755 "$BUILD_DIR"

# Build code never runs as root and cannot read the service's environment file.
# Keep toolchains/caches outside the checkout, and ignore the caller's DB settings.
GO_HOME="$BUILD_HOME/go-$GO_VERSION-$GO_ARCH"
FLUTTER_HOME="$BUILD_HOME/flutter-$FLUTTER_VERSION"
as_builder() {
  runuser -u balnana-build -- env -i \
    HOME="$BUILD_HOME" USER=balnana-build LOGNAME=balnana-build \
    PATH="$GO_HOME/bin:$FLUTTER_HOME/bin:/usr/bin:/bin" \
    LANG=C.UTF-8 CI=true GOTOOLCHAIN=local \
    "$@"
}

if [[ ! -x $GO_HOME/bin/go ]]; then
  log "Downloading Go $GO_VERSION ($GO_ARCH)"
  archive="go$GO_VERSION.linux-$GO_ARCH.tar.gz"
  curl --fail --show-error --silent --location --retry 3 \
    'https://go.dev/dl/?mode=json&include=all' -o "$BUILD_DIR/go-releases.json"
  # Verify against the official release manifest before extracting the SDK.
  checksum="$(python3 - "$BUILD_DIR/go-releases.json" "$archive" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as source:
    for release in json.load(source):
        for artifact in release["files"]:
            if artifact["filename"] == sys.argv[2]:
                print(artifact["sha256"])
                sys.exit(0)
sys.exit("Requested Go archive was not found in the official release manifest")
PY
  )"
  curl --fail --show-error --location --retry 3 \
    "https://go.dev/dl/$archive" -o "$BUILD_DIR/$archive"
  (cd "$BUILD_DIR"; printf '%s  %s\n' "$checksum" "$archive" | sha256sum --check -)
  tar -xzf "$BUILD_DIR/$archive" -C "$BUILD_DIR"
  mv "$BUILD_DIR/go" "$GO_HOME"
fi
if [[ ! -x $FLUTTER_HOME/bin/flutter ]]; then
  log "Downloading Flutter $FLUTTER_VERSION"
  # Clone into a temporary directory so interrupted downloads are safe to retry.
  install -d -o balnana-build -g balnana-build "$BUILD_DIR/flutter-sdk"
  as_builder git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$BUILD_DIR/flutter-sdk"
  mv "$BUILD_DIR/flutter-sdk" "$FLUTTER_HOME"
fi

log "Building Flutter web and Go from the current checkout"
# Exclude development databases, secrets, old builds and platform-specific SDKs.
# Use a snapshot so deployment does not change ownership/files in the checkout.
tar -C "$PROJECT_ROOT" \
  --exclude=server/bin --exclude=server/internal/web/dist \
  --exclude=app/build --exclude=app/.dart_tool --exclude=app/.git \
  --exclude=app/android --exclude=app/ios --exclude=app/linux \
  --exclude=app/macos --exclude=app/windows \
  -cf - server app | tar -C "$BUILD_DIR" -xf -
chown -R balnana-build:balnana-build "$BUILD_DIR/server" "$BUILD_DIR/app"
# Variables in this script are expanded by the builder's shell.
# shellcheck disable=SC2016
as_builder bash -c '
  set -euo pipefail
  cd "$1/app"
  flutter config --no-analytics --no-cli-animations
  flutter pub get
  flutter build web --release --no-pub --no-web-resources-cdn
  test -s build/web/index.html
  test -s build/web/main.dart.js
  mkdir -p "$1/server/internal/web/dist"
  cp -a build/web/. "$1/server/internal/web/dist/"
  cd "$1/server"
  CGO_ENABLED=0 go build -mod=readonly -trimpath \
    -ldflags "-s -w -X main.version=$2" -o balnana ./cmd/balnana
' -- "$BUILD_DIR" "$(git -C "$PROJECT_ROOT" describe --always --dirty 2>/dev/null || echo local)"

log "Preparing local PostgreSQL (existing roles and databases are kept)"
systemctl enable --now postgresql.service
pg_admin() {
  runuser -u postgres -- psql -X -h /var/run/postgresql -p 5432 \
    -U postgres -d postgres --set=ON_ERROR_STOP=1
}
pg_admin <<'SQL'
SELECT 'CREATE ROLE balnana LOGIN'
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'balnana')
\gexec
SELECT 'CREATE DATABASE balnana OWNER balnana'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'balnana')
\gexec
SQL

if [[ ! -e /etc/balnana/balnana.env ]]; then
  log "Creating /etc/balnana/balnana.env"
  cat > "$BUILD_DIR/balnana.env" <<'EOF'
# systemd EnvironmentFile syntax: KEY=value, no export or shell expansion.
# Local PostgreSQL uses peer authentication as the balnana OS user; no password.
BALNANA_DATABASE_URL=postgres:///balnana?host=/var/run/postgresql&port=5432
BALNANA_LISTEN=:8080
# All optional BALNANA_* settings are described in the checkout's .env.example.
# BALNANA_PUBLIC_URL=https://balnana.example.com
# For a reverse proxy on this host, bind only to loopback and trust its headers:
# BALNANA_LISTEN=127.0.0.1:8080
# BALNANA_TRUST_PROXY=true
EOF
  install -o root -g balnana -m 0640 "$BUILD_DIR/balnana.env" /etc/balnana/balnana.env
fi

cat > "$BUILD_DIR/wait-ready" <<'EOF'
#!/bin/sh
# systemd supplies the same EnvironmentFile and MAINPID as the main process.
attempt=0
while [ "$attempt" -lt 90 ]; do
  kill -0 "$MAINPID" 2>/dev/null || exit 1
  if /opt/balnana/balnana healthcheck >/dev/null 2>&1; then
    exit 0
  fi
  attempt=$((attempt + 1))
  sleep 2
done
echo "Balnana did not become healthy before the startup deadline." >&2
exit 1
EOF
cat > "$BUILD_DIR/balnana.service" <<'EOF'
[Unit]
Description=Balnana expense splitting server
Wants=network-online.target postgresql.service
After=network-online.target postgresql.service

[Service]
Type=exec
User=balnana
Group=balnana
WorkingDirectory=/var/lib/balnana
StateDirectory=balnana
StateDirectoryMode=0750
EnvironmentFile=/etc/balnana/balnana.env
ExecStart=/opt/balnana/balnana
ExecStartPost=/opt/balnana/wait-ready
Restart=on-failure
RestartSec=5s
TimeoutStartSec=300s
TimeoutStopSec=30s
UMask=0077
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
RestrictSUIDSGID=true

[Install]
WantedBy=multi-user.target
EOF

log "Installing the completed build and restarting balnana.service"
# Rename on the same filesystem: never truncate the running executable.
install -o root -g root -m 0755 "$BUILD_DIR/server/balnana" /opt/balnana/balnana.new
mv -f /opt/balnana/balnana.new /opt/balnana/balnana
install -o root -g root -m 0755 "$BUILD_DIR/wait-ready" /opt/balnana/wait-ready
install -o root -g root -m 0644 "$BUILD_DIR/balnana.service" /etc/systemd/system/balnana.service
systemctl daemon-reload
systemctl enable balnana.service
systemctl reset-failed balnana.service
# restart waits for ExecStartPost: exit nonzero if startup/health checking fails.
if ! systemctl restart balnana.service; then
  journalctl -u balnana.service -n 80 --no-pager >&2 || true
  die "The new service failed to start. Check /etc/balnana/balnana.env and the logs."
fi
systemctl --no-pager --full status balnana.service
log "Deployment complete. Default address: http://<server-ip>:8080"
echo "Configure: /etc/balnana/balnana.env (then systemctl restart balnana.service)"
echo "First setup code and logs: journalctl -u balnana.service -n 80 --no-pager"
