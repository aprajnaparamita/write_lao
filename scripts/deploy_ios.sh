#!/usr/bin/env bash
# ── scripts/deploy_ios.sh ─────────────────────────────────────────────────────
# Builds a release IPA and installs it on every connected iOS device.
# Works with both USB-connected and wirelessly-paired devices.
#
# Usage:
#   bash scripts/deploy_ios.sh            # install on all found iOS devices
#   bash scripts/deploy_ios.sh --phone    # iPhone only
#   bash scripts/deploy_ios.sh --ipad     # iPad only
#   bash scripts/deploy_ios.sh --list     # just list detected devices, then exit
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

FLUTTER="${FLUTTER_ROOT:-/Users/dara/dev/flutter}/bin/flutter"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()  { echo -e "${CYAN}▶ $*${RESET}"; }
ok()   { echo -e "${GREEN}✓ $*${RESET}"; }
warn() { echo -e "${YELLOW}⚠ $*${RESET}"; }
err()  { echo -e "${RED}✗ $*${RESET}" >&2; }

# ── Parse flags ───────────────────────────────────────────────────────────────
FILTER=""      # empty = all iOS devices
for arg in "$@"; do
  case "$arg" in
    --phone) FILTER="phone" ;;
    --ipad)  FILTER="ipad"  ;;
    --list)  FILTER="list"  ;;
    --help|-h)
      grep "^# " "$0" | cut -c3-
      exit 0
      ;;
    *) err "Unknown flag: $arg"; exit 1 ;;
  esac
done

# ── Detect iOS devices ────────────────────────────────────────────────────────
log "Scanning for connected iOS devices…"
RAW_DEVICES=$("$FLUTTER" devices 2>/dev/null || true)

declare -a DEVICE_IDS=()
declare -a DEVICE_NAMES=()

while IFS= read -r line; do
  # flutter devices columns: Name  •  device-id  •  platform  •  os-version
  if [[ "$line" == *"• ios •"* || "$line" == *"• ios"* ]]; then
    # Extract device ID (second • field)
    DEV_ID=$(echo "$line" | awk -F '•' '{gsub(/ /,"",$2); print $2}')
    DEV_NAME=$(echo "$line" | awk -F '•' '{gsub(/^ +| +$/,"",$1); print $1}')

    # Apply filter
    case "$FILTER" in
      phone) [[ "$line" == *"iPad"* ]] && continue ;;
      ipad)  [[ "$line" != *"iPad"* ]] && continue ;;
    esac

    DEVICE_IDS+=("$DEV_ID")
    DEVICE_NAMES+=("$DEV_NAME")
  fi
done <<< "$RAW_DEVICES"

if [[ ${#DEVICE_IDS[@]} -eq 0 ]]; then
  err "No iOS devices found."
  echo ""
  echo "  • For USB: unlock your device, trust this Mac, then re-run."
  echo "  • For wireless: pair via Xcode → Window → Devices and Simulators."
  exit 1
fi

echo ""
echo -e "${BOLD}Found iOS devices:${RESET}"
for i in "${!DEVICE_IDS[@]}"; do
  echo -e "  ${GREEN}[${i}]${RESET} ${DEVICE_NAMES[$i]}  (${DEVICE_IDS[$i]})"
done
echo ""

[[ "$FILTER" == "list" ]] && exit 0

# ── Step 1: Regenerate secrets.dart ──────────────────────────────────────────
log "Regenerating secrets from .env…"
bash "$SCRIPT_DIR/setup_secrets.sh"
ok "secrets.dart is up to date"

# ── Step 2: Single release build ─────────────────────────────────────────────
echo ""
log "Building iOS release (this takes ~2–3 min first time)…"
echo ""
cd "$ROOT_DIR"
"$FLUTTER" build ios --release 2>&1 | grep -v "^$" | \
  while IFS= read -r line; do
    # Suppress verbose Xcode noise; surface warnings/errors
    case "$line" in
      *error:*|*Error:*)  err  "$line" ;;
      *warning:*)         warn "$line" ;;
      *"✓"*|*"Built"*)    ok   "$line" ;;
      *)                  echo "  $line" ;;
    esac
  done

ok "Build complete"

# ── Step 3: Install on each device (parallel) ────────────────────────────────
echo ""
log "Installing on ${#DEVICE_IDS[@]} device(s)…"

PIDS=()
for i in "${!DEVICE_IDS[@]}"; do
  DEV="${DEVICE_IDS[$i]}"
  NAME="${DEVICE_NAMES[$i]}"
  (
    echo -e "  ${CYAN}→ Installing on: ${NAME}${RESET}"
    if "$FLUTTER" install -d "$DEV" 2>&1 | grep -q "Installed"; then
      echo -e "  ${GREEN}✓ ${NAME}${RESET}"
    else
      "$FLUTTER" install -d "$DEV"   # fallback: run without grep (shows full output)
      echo -e "  ${GREEN}✓ ${NAME}${RESET}"
    fi
  ) &
  PIDS+=($!)
done

# Wait for all installs and collect exit codes
FAILED=0
for pid in "${PIDS[@]}"; do
  if ! wait "$pid"; then
    FAILED=$((FAILED + 1))
  fi
done

echo ""
if [[ $FAILED -eq 0 ]]; then
  echo -e "${BOLD}${GREEN}🎉  Write Lao installed on all devices!${RESET}"
else
  err "$FAILED install(s) failed — check output above."
  exit 1
fi
