#!/usr/bin/env bash
# Build the iOS app for App Store Connect (an .ipa to upload with Transporter
# or `xcrun altool`), or an unsigned build to check that it compiles. Edit the
# settings below, then run this script on a Mac with Xcode.
set -euo pipefail

# Build settings.
FLUTTER_BIN="flutter"
SERVER_URL="https://app.balnana.com"   # Empty lets the user choose a server.
                                       # App Review needs a server to sign in to.
BUILD_NAME=""                        # Empty uses the version in pubspec.yaml.
BUILD_NUMBER=""                      # Empty uses the build number in pubspec.yaml.
                                       # App Store Connect needs a new one per upload.
SIGNED=true                          # false only compiles, without a team or profile.
EXPORT_OPTIONS=""                    # An ExportOptions.plist; empty lets Flutter make
                                       # one for App Store upload with automatic signing.
# The App Store build never links to paying elsewhere: lib/core/server.dart
# turns BALNANA_EXTERNAL_PAYMENTS off on iOS whatever it is set to.

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$PROJECT_ROOT/app"

case "$SIGNED" in
  true|false) ;;
  *) echo "SIGNED must be true or false" >&2; exit 1 ;;
esac

if [[ "$(uname)" != Darwin ]]; then
  echo "iOS builds need macOS with Xcode." >&2
  exit 1
fi
if ! xcodebuild -version >/dev/null 2>&1; then
  echo "xcodebuild needs Xcode, not just the Command Line Tools. Run:" >&2
  echo "  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer" >&2
  exit 1
fi
if ! command -v "$FLUTTER_BIN" >/dev/null 2>&1; then
  echo "Flutter not found. Set FLUTTER_BIN to its executable path." >&2
  exit 1
fi

cd -- "$APP_DIR"
"$FLUTTER_BIN" pub get

args=(--release --no-pub --flavor foss)
if [[ -n "$SERVER_URL" ]]; then
  args+=("--dart-define=BALNANA_SERVER_URL=$SERVER_URL")
fi
if [[ -n "$BUILD_NAME" ]]; then
  args+=("--build-name=$BUILD_NAME")
fi
if [[ -n "$BUILD_NUMBER" ]]; then
  args+=("--build-number=$BUILD_NUMBER")
fi

if [[ "$SIGNED" == false ]]; then
  "$FLUTTER_BIN" build ios "${args[@]}" --no-codesign
  echo "Unsigned app: $APP_DIR/build/ios/iphoneos/Runner.app"
  exit 0
fi

if [[ -n "$EXPORT_OPTIONS" ]]; then
  args+=("--export-options-plist=$EXPORT_OPTIONS")
fi
"$FLUTTER_BIN" build ipa "${args[@]}"
echo "IPA for App Store Connect is in: $APP_DIR/build/ios/ipa/"
