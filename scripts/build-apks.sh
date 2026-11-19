#!/usr/bin/env bash
# Build both Android APK flavors and a release Play App Bundle. Edit the
# settings below, then run this script
# from a development shell (nix-shell on the configured development machine).
set -euo pipefail

# Build settings.
FLUTTER_BIN="flutter"
BUILD_MODE="release"                 # release, debug or profile
SERVER_URL="https://app.balnana.com"   # Empty lets the user choose a server.
BUILD_NAME=""                        # Empty uses the version in pubspec.yaml.
BUILD_NUMBER=""                      # Empty uses the build number in pubspec.yaml.
SPLIT_PER_ABI=false                   # false produces one APK per flavor.
BUILD_PLAY_BUNDLE=true                # Also build a signed Play AAB in release mode.
FOSS_EXTERNAL_PAYMENTS=true          # Only the foss flavor may enable this.
ALLOW_DEBUG_SIGNING=false             # Allow release APKs without a release key.
# AABs always need android/key.properties, even with ALLOW_DEBUG_SIGNING=true.
# Set BUILD_PLAY_BUNDLE=false for APKs only. Debug/profile builds skip the AAB.
# Package names come from android/app/build.gradle.kts.

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$PROJECT_ROOT/app"

case "$BUILD_MODE" in
  release|debug|profile) ;;
  *) echo "Invalid BUILD_MODE: $BUILD_MODE" >&2; exit 1 ;;
esac

for setting in SPLIT_PER_ABI BUILD_PLAY_BUNDLE FOSS_EXTERNAL_PAYMENTS ALLOW_DEBUG_SIGNING; do
  case "${!setting}" in
    true|false) ;;
    *) echo "$setting must be true or false" >&2; exit 1 ;;
  esac
done

build_play_bundle=false
if [[ "$BUILD_MODE" == release && "$BUILD_PLAY_BUNDLE" == true ]]; then
  build_play_bundle=true
  if [[ ! -f "$APP_DIR/android/key.properties" ]]; then
    echo "A Google Play AAB requires $APP_DIR/android/key.properties. Set BUILD_PLAY_BUNDLE=false for APKs only." >&2
    exit 1
  fi
elif [[ "$BUILD_PLAY_BUNDLE" == true ]]; then
  echo "Skipping Play AAB: BUILD_MODE=$BUILD_MODE (requires release)."
fi

if ! command -v "$FLUTTER_BIN" >/dev/null 2>&1; then
  echo "Flutter not found. Enter nix-shell or set FLUTTER_BIN to its executable path." >&2
  exit 1
fi

cd -- "$APP_DIR"
"$FLUTTER_BIN" pub get

common_args=("--$BUILD_MODE" --no-pub)
if [[ -n "$SERVER_URL" ]]; then
  common_args+=("--dart-define=BALNANA_SERVER_URL=$SERVER_URL")
fi
if [[ -n "$BUILD_NAME" ]]; then
  common_args+=("--build-name=$BUILD_NAME")
fi
if [[ -n "$BUILD_NUMBER" ]]; then
  common_args+=("--build-number=$BUILD_NUMBER")
fi
apk_args=("${common_args[@]}")
if [[ "$SPLIT_PER_ABI" == true ]]; then
  apk_args+=(--split-per-abi)
fi
if [[ "$ALLOW_DEBUG_SIGNING" == true && "$BUILD_MODE" == release ]]; then
  apk_args+=(--android-project-arg=allowDebugSigning=true)
fi

for flavor in foss play; do
  external_payments=false
  if [[ "$flavor" == foss ]]; then
    external_payments="$FOSS_EXTERNAL_PAYMENTS"
  fi
  echo "Building $flavor ($BUILD_MODE)..."
  "$FLUTTER_BIN" build apk "${apk_args[@]}" --flavor "$flavor" \
    "--dart-define=BALNANA_EXTERNAL_PAYMENTS=$external_payments"
done

if [[ "$build_play_bundle" == true ]]; then
  echo "Building Google Play AAB (release)..."
  "$FLUTTER_BIN" build appbundle "${common_args[@]}" --flavor play \
    --dart-define=BALNANA_EXTERNAL_PAYMENTS=false
fi

echo "APKs are in: $APP_DIR/build/app/outputs/flutter-apk/"
if [[ "$build_play_bundle" == true ]]; then
  echo "Google Play AAB: $APP_DIR/build/app/outputs/bundle/playRelease/app-play-release.aab"
fi
