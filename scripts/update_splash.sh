#!/usr/bin/env bash
#
# update_splash.sh
#
# Extracts the rect5 element from the splash SVG and places it in every
# platform launch-image location. Nothing else.
#
# The SVG (assets_originals/write_lao_splash.svg) already has its version
# text updated by you in Inkscape; this script just renders the inner
# content area (id="rect5", 815x1207) and copies the PNG to the iOS and
# Android launch-image slots.
#
# Usage:
#   scripts/update_splash.sh
#
# Requires: inkscape, sips (macOS), magick (ImageMagick).

set -euo pipefail

# Resolve paths relative to this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$ROOT_DIR"

SVG="assets_originals/write_lao_splash.svg"
PNG="assets_originals/splash_screen.png"
IOS_DIR="ios/Runner/Assets.xcassets/LaunchImage.imageset"
ANDROID_RES="android/app/src/main/res"

# Pre-flight checks
for tool in inkscape sips magick; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "ERROR: Missing required tool: $tool" >&2
    case "$tool" in
      inkscape) echo "  Install with: brew install inkscape" >&2 ;;
      magick)   echo "  Install with: brew install imagemagick" >&2 ;;
    esac
    exit 1
  fi
done

if [ ! -f "$SVG" ]; then
  echo "ERROR: Required file not found: $SVG" >&2
  exit 1
fi

# Extract rect5 from the SVG
echo "Extracting rect5 from ${SVG}..."
inkscape "$SVG" \
  --export-id=rect5 \
  --export-type=png \
  --export-filename="$PNG" 2>&1 \
  | grep -Ev 'WARNING|CRITICAL|import_style_cb|tknzr_new_from_uri|cr_parser_parse_file|Could not open file' \
  || true

PNG_W=$(sips -g pixelWidth "$PNG" 2>/dev/null | tail -1 | awk '{print $2}')
PNG_H=$(sips -g pixelHeight "$PNG" 2>/dev/null | tail -1 | awk '{print $2}')
echo "Extracted ${PNG} (${PNG_W}x${PNG_H})"

# iOS — LaunchImage.imageset (1x/2x/3x)
cp "$PNG" "$IOS_DIR/LaunchImage.png"
magick "$PNG" -resize 1630x "$IOS_DIR/LaunchImage@2x.png"
magick "$PNG" -resize 2445x "$IOS_DIR/LaunchImage@3x.png"

# Android — one image per density bucket, each scaled to 360dp wide
# so it fills a standard-width screen at that density without cropping.
mkdir -p \
  "$ANDROID_RES/drawable-mdpi" \
  "$ANDROID_RES/drawable-hdpi" \
  "$ANDROID_RES/drawable-xhdpi" \
  "$ANDROID_RES/drawable-xxhdpi" \
  "$ANDROID_RES/drawable-xxxhdpi"

magick "$PNG" -resize 360x   "$ANDROID_RES/drawable-mdpi/splash.png"
magick "$PNG" -resize 540x   "$ANDROID_RES/drawable-hdpi/splash.png"
magick "$PNG" -resize 720x   "$ANDROID_RES/drawable-xhdpi/splash.png"
magick "$PNG" -resize 1080x  "$ANDROID_RES/drawable-xxhdpi/splash.png"
magick "$PNG" -resize 1440x  "$ANDROID_RES/drawable-xxxhdpi/splash.png"

echo ""
echo "Placed launch images:"
echo "  iOS  1x: $IOS_DIR/LaunchImage.png           (815x1207)"
echo "  iOS  2x: $IOS_DIR/LaunchImage@2x.png        (1630x2414)"
echo "  iOS  3x: $IOS_DIR/LaunchImage@3x.png        (2445x3621)"
echo "  And. mdpi:    $ANDROID_RES/drawable-mdpi/splash.png    (360×533)"
echo "  And. hdpi:    $ANDROID_RES/drawable-hdpi/splash.png    (540×800)"
echo "  And. xhdpi:   $ANDROID_RES/drawable-xhdpi/splash.png   (720×1067)"
echo "  And. xxhdpi:  $ANDROID_RES/drawable-xxhdpi/splash.png  (1080×1600)"
echo "  And. xxxhdpi: $ANDROID_RES/drawable-xxxhdpi/splash.png (1440×2133)"
