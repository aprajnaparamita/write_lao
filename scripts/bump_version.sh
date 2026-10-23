#!/usr/bin/env bash
# ── scripts/bump_version.sh ──────────────────────────────────────────────────
# Bumps the app version in pubspec.yaml and keeps the matching Sentry release
# tag in lib/main.dart in sync. The runtime UI strings (About / Settings)
# read from package_info_plus, so they update automatically on the next build.
#
# Usage:
#   bash scripts/bump_version.sh                # patch bump: 1.0.4+1 → 1.0.5+1
#   bash scripts/bump_version.sh patch          # same as above (default)
#   bash scripts/bump_version.sh minor          # 1.0.4+1 → 1.1.0+1
#   bash scripts/bump_version.sh major          # 1.0.4+1 → 2.0.0+1
#   bash scripts/bump_version.sh build          # 1.0.4+1 → 1.0.4+2  (build only)
#   bash scripts/bump_version.sh 2.3.4+5        # set exact version
#   bash scripts/bump_version.sh --dry-run ...  # show diff, write nothing
#   bash scripts/bump_version.sh --show         # print current version, exit
#   bash scripts/bump_version.sh --help         # show this header
#
# Notes:
#   - Always resets build number to 1 on patch/minor/major.
#   - Refuses to bump down for patch/minor/major; pass an explicit version
#     (e.g. `bash $0 0.5.0+1`) if you really need to.
#   - Prompts for confirmation when run from a terminal; safe to call from CI
#     with --dry-run or by piping `yes`.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PUBSPEC="$ROOT_DIR/pubspec.yaml"
MAIN_DART="$ROOT_DIR/lib/main.dart"

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()  { echo -e "${CYAN}▶ $*${RESET}"; }
ok()   { echo -e "${GREEN}✓ $*${RESET}"; }
warn() { echo -e "${YELLOW}⚠ $*${RESET}"; }
err()  { echo -e "${RED}✗ $*${RESET}" >&2; }

# ── Parse args ───────────────────────────────────────────────────────────────
DRY_RUN=false
ACTION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=true; shift ;;
    --show)       ACTION="show"; shift ;;
    --help|-h)
      grep "^# " "$0" | cut -c3-
      exit 0
      ;;
    -*) err "Unknown flag: $1"; exit 1 ;;
    patch|minor|major|build)
      ACTION="$1"; shift ;;
    *)
      if [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
        ACTION="set:$1"; shift
      else
        err "Unknown argument: $1"
        echo "    Expected: patch | minor | major | build | X.Y.Z+N | --show | --dry-run"
        exit 1
      fi
      ;;
  esac
done

ACTION="${ACTION:-patch}"

# ── Read current version from pubspec.yaml ──────────────────────────────────
if [[ ! -f "$PUBSPEC" ]]; then
  err "pubspec.yaml not found at $PUBSPEC"
  exit 1
fi

# Extract the value after `version:` cleanly, stripping optional surrounding
# single or double quotes (some pubspecs quote the string).
CURRENT=$(awk '/^[[:space:]]*version:[[:space:]]*/ {
    v = $2
    gsub(/^['\''"]|['\''"]$/, "", v)
    print v; exit
  }' "$PUBSPEC")

if [[ -z "$CURRENT" ]]; then
  err "Could not find a 'version:' line in $PUBSPEC"
  exit 1
fi

if ! [[ "$CURRENT" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)$ ]]; then
  err "Current version '$CURRENT' is not in X.Y.Z+N form"
  exit 1
fi
CUR_MAJOR="${BASH_REMATCH[1]}"
CUR_MINOR="${BASH_REMATCH[2]}"
CUR_PATCH="${BASH_REMATCH[3]}"
CUR_BUILD="${BASH_REMATCH[4]}"

if [[ "$ACTION" == "show" ]]; then
  echo "Current version: $CURRENT"
  echo "  pubspec.yaml   : version: $CURRENT"
  if grep -q "write_lao@$CURRENT" "$MAIN_DART" 2>/dev/null; then
    echo "  lib/main.dart  : Sentry release tag matches ✓"
  else
    warn "lib/main.dart Sentry release tag does NOT match pubspec — run this script to sync."
  fi
  exit 0
fi

# ── Compute new version ──────────────────────────────────────────────────────
compute_new() {
  case "$ACTION" in
    set:*)  echo "${ACTION#set:}" ;;
    patch)  echo "$CUR_MAJOR.$CUR_MINOR.$((CUR_PATCH + 1))+1" ;;
    minor)  echo "$CUR_MAJOR.$((CUR_MINOR + 1)).0+1" ;;
    major)  echo "$((CUR_MAJOR + 1)).0.0+1" ;;
    build)  echo "$CUR_MAJOR.$CUR_MINOR.$CUR_PATCH+$((CUR_BUILD + 1))" ;;
    *) err "Unknown action: $ACTION"; exit 1 ;;
  esac
}

NEW=$(compute_new "$ACTION")

if ! [[ "$NEW" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)$ ]]; then
  err "Computed version '$NEW' is not in X.Y.Z+N form"
  exit 1
fi
NEW_MAJOR="${BASH_REMATCH[1]}"
NEW_MINOR="${BASH_REMATCH[2]}"
NEW_PATCH="${BASH_REMATCH[3]}"
NEW_BUILD="${BASH_REMATCH[4]}"

# Refuse to bump down on patch/minor/major (build can always go up).
if [[ "$ACTION" != "set:"* && "$ACTION" != "build" ]]; then
  CUR_TOTAL=$((CUR_MAJOR * 1000000 + CUR_MINOR * 1000 + CUR_PATCH))
  NEW_TOTAL=$((NEW_MAJOR  * 1000000 + NEW_MINOR  * 1000 + NEW_PATCH))
  if (( NEW_TOTAL < CUR_TOTAL )); then
    err "Refusing to bump down ($CURRENT → $NEW)."
    echo "    Pass an explicit version (e.g. 'bash $0 0.5.0+1') to override."
    exit 1
  fi
fi

# ── Report what would change ─────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Version bump${RESET}"
echo -e "  ${CYAN}pubspec.yaml${RESET}    : $CURRENT → $NEW"
echo -e "  ${CYAN}lib/main.dart${RESET}    : 'write_lao@$CURRENT' → 'write_lao@$NEW'"
echo ""

# Warn if working tree is dirty
if command -v git >/dev/null && git -C "$ROOT_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  if ! git -C "$ROOT_DIR" diff --quiet HEAD 2>/dev/null || \
     ! git -C "$ROOT_DIR" diff --quiet --cached 2>/dev/null; then
    warn "Working tree has uncommitted changes — bump will be mixed in."
  fi
fi

if $DRY_RUN; then
  echo -e "${YELLOW}--dry-run: no files modified.${RESET}"
  exit 0
fi

# Interactive confirm (TTY only)
if [[ -t 0 ]]; then
  read -rp "  Apply? [y/N] " ans
  case "$ans" in
    y|Y|yes|YES) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

# ── Apply edits ──────────────────────────────────────────────────────────────

# pubspec.yaml: rewrite the version line in place (preserve indent + quotes).
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
sed -E "s|^([[:space:]]*version:[[:space:]]*).*$|\1$NEW|" "$PUBSPEC" > "$TMP"
mv "$TMP" "$PUBSPEC"

# lib/main.dart: rewrite the Sentry release literal with a literal-substring
# replacement (no regex — `+` in the version would otherwise be a regex
# metachar and break the match).
if [[ ! -f "$MAIN_DART" ]]; then
  err "lib/main.dart not found at $MAIN_DART"
  exit 1
fi
if ! command -v python3 >/dev/null; then
  err "python3 is required for the lib/main.dart edit but was not found in PATH"
  exit 1
fi
python3 - "$MAIN_DART" "$CURRENT" "$NEW" <<'PY'
import sys, pathlib
path, old_ver, new_ver = sys.argv[1], sys.argv[2], sys.argv[3]
p = pathlib.Path(path)
old = f"write_lao@{old_ver}"
new = f"write_lao@{new_ver}"
content = p.read_text()
if old not in content:
    sys.exit(f"✗ Could not find literal '{old}' in {path} — update manually.")
p.write_text(content.replace(old, new))
PY

# ── Done ─────────────────────────────────────────────────────────────────────
ok "Bumped $CURRENT → $NEW"
echo ""
log "Next steps:"
echo "  • flutter build ios --release     # regenerates Info.plist values"
echo "  • or: make deploy-phone           # build + install on connected iPhone"
echo ""