#!/usr/bin/env bash
# ship.sh — DEV-ONLY release tool. Mirrors the live development tree into the
# distributable src/ and bumps the version. Run from the repo root:
#
#     ./ship.sh            # bump patch  (X.Y.Z -> X.Y.Z+1) and mirror
#     ./ship.sh minor      # bump minor  (X.Y.Z -> X.Y+1.0) and mirror
#     ./ship.sh major      # bump major  (X.Y.Z -> X+1.0.0) and mirror
#     ./ship.sh --dry-run  # show exactly what would change, touch nothing
#     ./ship.sh --no-bump  # mirror only, leave the version alone
#
# THIS SCRIPT IS NOT DISTRIBUTED. It lives at the repo root (never under src/),
# so setup.sh — which only walks src/ — can never copy it into a user's project.
# Do not move it into src/ or docs/5day/.
#
# ── Why this exists ──────────────────────────────────────────────────
# This repo has two trees: docs/ (the live dev environment we edit and test)
# and src/ (the distributable setup.sh installs). Every framework change must
# be mirrored docs/ -> src/ or it never reaches users. Doing that by hand, file
# by file, is the single most error-prone step in this repo. ship.sh makes it
# one command, and — because it mirrors whole trees, not enumerated files — a
# NEW script/help/ai/cli/guide file under docs/5day/ is picked up automatically.
# You only edit ship.sh when a NEW distributable path appears OUTSIDE the trees
# already listed below (a new root file, or a brand-new docs/ subtree to ship).

set -euo pipefail

# Run from the repo root regardless of caller's CWD.
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colors (blanked under NO_COLOR, matching 5day.sh) ────────────────
if [ -n "${NO_COLOR:-}" ] || [ ! -t 1 ]; then
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
else
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
    BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
fi

# ── Distribution manifest ────────────────────────────────────────────
# Everything that must exist in src/ for a working install. Keep this in sync
# with reality: if you design a new distributable file that does NOT already
# sit under one of the TREE_MIRRORS below, add it here (or add its tree).

# Single files copied from the repo root into src/ (SRC = "src/<same name>").
ROOT_FILES=(
    "5day.sh"
    "DOCUMENTATION.md"
)

# Whole directory trees mirrored live -> distributable, "LIVE_DIR:SRC_DIR".
# rsync --delete keeps src/ an exact copy: a file deleted from the live tree is
# removed from src/ too. New files under a live tree ship with no edit here.
TREE_MIRRORS=(
    "docs/5day:src/docs/5day"
)

# Paths (relative to a mirrored tree's root) that are DEV-ONLY and must never
# ship: DOC_STATE.md is generated per-install by setup.sh; tmp/ is scratch/logs.
TREE_EXCLUDES=(
    "DOC_STATE.md"
    "tmp"
)

# ── Argument parsing ─────────────────────────────────────────────────
BUMP="patch"
DRY_RUN=0
NO_BUMP=0
for arg in "$@"; do
    case "$arg" in
        major|minor|patch) BUMP="$arg" ;;
        --dry-run)         DRY_RUN=1 ;;
        --no-bump)         NO_BUMP=1 ;;
        -h|--help)
            sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *)
            echo -e "${RED}✗ Unknown argument: $arg${NC}" >&2
            echo "Usage: ./ship.sh [major|minor|patch] [--dry-run] [--no-bump]" >&2
            exit 1 ;;
    esac
done

# ── Version helper ───────────────────────────────────────────────────
bump_version() {
    local cur="$1" level="$2" major minor patch
    IFS='.' read -r major minor patch <<< "$cur"
    if ! [[ "$major" =~ ^[0-9]+$ && "$minor" =~ ^[0-9]+$ && "$patch" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}✗ src/VERSION is not X.Y.Z: '$cur'${NC}" >&2
        return 1
    fi
    case "$level" in
        major) major=$((major + 1)); minor=0; patch=0 ;;
        minor) minor=$((minor + 1)); patch=0 ;;
        patch) patch=$((patch + 1)) ;;
    esac
    printf '%s.%s.%s' "$major" "$minor" "$patch"
}

# ── Preflight: must be the 5daydocs dev root ─────────────────────────
for required in "setup.sh" "src" "docs/5day" "src/VERSION"; do
    if [ ! -e "$required" ]; then
        echo -e "${RED}✗ Not in the 5daydocs dev root (missing: $required)${NC}" >&2
        echo "  Run ./ship.sh from the repository root." >&2
        exit 1
    fi
done

# Fail fast on a malformed version BEFORE any files are touched — a bump we
# can't compute must not leave a half-mirrored src/ behind. (Skipped when
# --no-bump, since the version is then irrelevant.)
if [ "$NO_BUMP" -eq 0 ] && ! bump_version "$(cat src/VERSION)" "$BUMP" >/dev/null 2>&1; then
    echo -e "${RED}✗ src/VERSION is not X.Y.Z: '$(cat src/VERSION)' — fix it or use --no-bump${NC}" >&2
    exit 1
fi

echo -e "${BOLD}5DayDocs — ship${NC}"
[ "$DRY_RUN" -eq 1 ] && echo -e "${YELLOW}(dry run — no files will change)${NC}"
echo ""

# Exclude flags, built once and reused by rsync (mirror) and diff (preview +
# verify). Keeping both in lockstep is what lets the preview, the copy, and the
# verification all agree on which paths are dev-only.
_rsync_excludes=()
_diff_excludes=()
for ex in "${TREE_EXCLUDES[@]}"; do
    _rsync_excludes+=(--exclude "$ex")
    _diff_excludes+=(--exclude="$ex")
done

# ── Step 1: show pending changes (what this run will mirror) ─────────
# Content-based (diff), NOT timestamp-based: rsync -a resyncs mtimes on every
# run, so an rsync itemize would flag identical files as "changed". git ignores
# mtimes, so the only changes worth reporting are real content adds/edits/prunes.
echo -e "${BLUE}▸ Changes to mirror into src/:${NC}"
CHANGES=0

for f in "${ROOT_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo -e "  ${RED}missing live file: $f${NC}"; continue
    fi
    if ! diff -q "$f" "src/$f" >/dev/null 2>&1; then
        echo "  ~ $f -> src/$f"; CHANGES=$((CHANGES + 1))
    fi
done

for pair in "${TREE_MIRRORS[@]}"; do
    live="${pair%%:*}"; dist="${pair#*:}"
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        echo "  $line"; CHANGES=$((CHANGES + 1))
    done < <(diff -rq "${_diff_excludes[@]}" "$live" "$dist" 2>/dev/null \
        | sed -E \
            -e "s|^Files (.*) and .* differ|~ \1 (edited)|" \
            -e "s|^Only in ($live[^:]*): (.*)|+ \1/\2 (new — will ship)|" \
            -e "s|^Only in ($dist[^:]*): (.*)|- \1/\2 (stale — will be pruned)|")
done

if [ "$CHANGES" -eq 0 ]; then
    echo "  (none — src/ already matches the live tree)"
else
    echo -e "  ${YELLOW}$CHANGES path(s) will change${NC}"
fi
echo ""

if [ "$DRY_RUN" -eq 1 ]; then
    # Also preview the version bump so a dry run is a full preview.
    CUR="$(cat src/VERSION)"
    if [ "$NO_BUMP" -eq 0 ]; then
        echo -e "${BLUE}▸ Version:${NC} $CUR -> $(bump_version "$CUR" "$BUMP" 2>/dev/null || echo '?')"
    fi
    echo -e "${YELLOW}Dry run complete. Re-run without --dry-run to apply.${NC}"
    exit 0
fi

# ── Step 2: mirror live -> src/ ──────────────────────────────────────
echo -e "${BLUE}▸ Mirroring live tree into src/…${NC}"

for f in "${ROOT_FILES[@]}"; do
    cp -p "$f" "src/$f"
    echo "  copied $f -> src/$f"
done

for pair in "${TREE_MIRRORS[@]}"; do
    live="${pair%%:*}"; dist="${pair#*:}"
    mkdir -p "$dist"
    rsync -a --delete "${_rsync_excludes[@]}" "$live/" "$dist/"
    echo "  synced $live/ -> $dist/ (excluding: ${TREE_EXCLUDES[*]})"
done

# NB: we deliberately do NOT chmod the shipped files. rsync -a and cp -p mirror
# the live file's exact mode, so an executable script (755) stays executable and
# a *sourced* profile like cli/*.sh (644) stays non-executable. Forcing +x here
# would flip those 644 files to 755 and show up as spurious git mode changes.
# setup.sh runs its own chmod +x on install, so runnability is covered there.
echo ""

# ── Step 3: bump the version ─────────────────────────────────────────
CUR_VERSION="$(cat src/VERSION)"
if [ "$NO_BUMP" -eq 1 ]; then
    echo -e "${BLUE}▸ Version:${NC} $CUR_VERSION (unchanged — --no-bump)"
else
    NEW_VERSION="$(bump_version "$CUR_VERSION" "$BUMP")"
    printf '%s' "$NEW_VERSION" > src/VERSION
    echo -e "${BLUE}▸ Version:${NC} $CUR_VERSION -> ${GREEN}$NEW_VERSION${NC} ($BUMP)"
fi
echo ""

# ── Step 4: verify src/ is now an exact mirror (antifragile gate) ────
# The mirror above is only trustworthy if the trees are provably identical
# afterward. Any residual difference (other than the dev-only excludes) means
# something is wrong — fail loudly rather than ship a broken package.
echo -e "${BLUE}▸ Verifying src/ matches the live tree…${NC}"
VERIFY_FAIL=0

for f in "${ROOT_FILES[@]}"; do
    if ! diff -q "$f" "src/$f" >/dev/null 2>&1; then
        echo -e "  ${RED}MISMATCH: $f != src/$f${NC}"; VERIFY_FAIL=1
    fi
done

for pair in "${TREE_MIRRORS[@]}"; do
    live="${pair%%:*}"; dist="${pair#*:}"
    if ! out="$(diff -rq "${_diff_excludes[@]}" "$live" "$dist" 2>&1)"; then
        echo -e "  ${RED}Tree differs: $live vs $dist${NC}"
        echo "$out" | sed 's/^/    /'
        VERIFY_FAIL=1
    fi
done

if [ "$VERIFY_FAIL" -ne 0 ]; then
    echo -e "${RED}✗ Verification failed — src/ is NOT a clean mirror. Investigate above.${NC}" >&2
    exit 1
fi
echo -e "  ${GREEN}✓ src/ is a clean mirror of the live tree${NC}"
echo ""

# ── Done ─────────────────────────────────────────────────────────────
echo -e "${GREEN}${BOLD}✓ Shipped.${NC}"
echo "  Review and commit:"
echo "    git add -A && git status"
echo "    git commit -m \"ship: v$(cat src/VERSION)\""
