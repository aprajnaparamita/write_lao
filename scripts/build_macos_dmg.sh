#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Build the open-source macOS app (full vocabulary unlocked) and package it
# as a .dmg in outputs/.
#
#   bash scripts/build_macos_dmg.sh
#
# Result: outputs/write_lao-macos-<version>.dmg (version from pubspec.yaml)
#
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

FLUTTER="${FLUTTER:-/Users/dara/dev/flutter/bin/flutter}"
APP_NAME="write_lao"
VERSION="$(sed -n 's/^version: *//p' pubspec.yaml | tr -d ' ' | cut -d+ -f1)"
APP_BUNDLE="Write Lao"
VOL_NAME="Write Lao"
APP_PATH="build/macos/Build/Products/Release/${APP_BUNDLE}.app"
DMG_PATH="outputs/${APP_NAME}-macos-${VERSION}.dmg"
STAGING="$(mktemp -d)/dmg"

echo "▶ Building macOS app (APP_VARIANT=open)…"
"$FLUTTER" build macos --release --dart-define=APP_VARIANT=open

if [[ ! -d "$APP_PATH" ]]; then
  echo "error: app bundle not found at $APP_PATH" >&2
  exit 1
fi

echo "▶ Staging .dmg contents…"
rm -rf "$STAGING"
mkdir -p "$STAGING" outputs
cp -R "$APP_PATH" "$STAGING/"
ln -sf /Applications "$STAGING/Applications"

echo "▶ Creating ${DMG_PATH}…"
rm -f outputs/${APP_NAME}-macos*.dmg
hdiutil create \
  -volname "$VOL_NAME" \
  -srcfolder "$STAGING" \
  -ov -format UDZO \
  "$DMG_PATH" >/dev/null

echo ""
echo "✅  DMG ready: ${DMG_PATH} ($(ls -lh "$DMG_PATH" | awk '{print $5}'))"
