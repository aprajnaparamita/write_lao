#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Build Android artifacts into outputs/.
#
#   bash scripts/build_android.sh apk   # open-source APK, full vocab unlocked
#                                       # (sideload / adb install)
#   bash scripts/build_android.sh aab   # Play Store bundle, vocab behind IAP
#
# The open build is a different artifact from the Play Store build:
# same code, compile-time variant flag decides whether the vocabulary is
# unlocked by default or sold via in-app purchase.
#
# Asset names are stable (no version) so the README download link
# https://github.com/aprajnaparamita/write_lao/releases/latest/download/write_lao-android.apk
# keeps working across releases.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

FLUTTER="${FLUTTER:-/Users/dara/dev/flutter/bin/flutter}"
APP_NAME="write_lao"
VERSION="$(sed -n 's/^version: *//p' pubspec.yaml | tr -d ' ' | cut -d+ -f1)"
BUILD_NUM="$(sed -n 's/^version: *//p' pubspec.yaml | tr -d ' ' | cut -d+ -f2)"
TARGET="${1:-apk}"

mkdir -p outputs

case "$TARGET" in
  apk)
    OUT="outputs/${APP_NAME}-android.apk"
    echo "▶ Building open-source APK (APP_VARIANT=open)…"
    "$FLUTTER" build apk --release \
      --dart-define=APP_VARIANT=open \
      --build-name="$VERSION" --build-number="$BUILD_NUM"
    cp -f build/app/outputs/flutter-apk/app-release.apk "$OUT"
    ;;
  aab)
    OUT="outputs/${APP_NAME}-android-play.aab"
    echo "▶ Building Play Store bundle (APP_VARIANT=store)…"
    "$FLUTTER" build appbundle --release \
      --dart-define=APP_VARIANT=store \
      --build-name="$VERSION" --build-number="$BUILD_NUM"
    cp -f build/app/outputs/bundle/release/app-release.aab "$OUT"
    ;;
  *)
    echo "usage: build_android.sh [apk|aab]" >&2
    exit 1
    ;;
esac

echo ""
echo "✅  Ready: $OUT ($(ls -lh "$OUT" | awk '{print $5}'))"
