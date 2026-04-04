#!/bin/bash
set -e

# cleanup-tmp.sh — Clear scratch files from docs/tmp/
#
# Usage:
#   cleanup-tmp.sh              # dry run — show what would be cleaned
#   cleanup-tmp.sh --delete     # delete stale files (with confirmation)
#   cleanup-tmp.sh --force      # delete stale files (no confirmation)
#   cleanup-tmp.sh --all        # delete everything (with confirmation)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$SCRIPT_DIR/docs/5day/scripts" ]; then
    PROJECT_ROOT="$SCRIPT_DIR"
else
    PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
fi

TMP_DIR="$PROJECT_ROOT/docs/tmp"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m'

MODE="${1:-dry-run}"
STALE_DAYS=7

if [ ! -d "$TMP_DIR" ]; then
    echo -e "${GREEN}docs/tmp/ not found. Nothing to clean.${NC}"
    exit 0
fi

# Get file age in days from mtime
file_age_days() {
    local file="$1"
    local mtime_epoch now_epoch
    if stat -f "%m" "$file" >/dev/null 2>&1; then
        mtime_epoch=$(stat -f "%m" "$file")
    elif stat -c "%Y" "$file" >/dev/null 2>&1; then
        mtime_epoch=$(stat -c "%Y" "$file")
    else
        echo 0; return
    fi
    now_epoch=$(date "+%s")
    echo $(( (now_epoch - mtime_epoch) / 86400 ))
}

format_age() {
    local days="$1"
    if [ "$days" -eq 0 ]; then echo "today"
    elif [ "$days" -eq 1 ]; then echo "1 day ago"
    else echo "${days} days ago"
    fi
}

# Classify files into stale (auto-clean) vs recent (keep unless --all)
stale=()
recent=()

while IFS= read -r file; do
    rel="${file#$TMP_DIR/}"
    age=$(file_age_days "$file")

    # Always stale: AI session logs (log-*.json)
    if [[ "$rel" == log-*.json ]]; then
        stale+=("$file")
        continue
    fi

    # Stale if older than threshold
    if [ "$age" -ge "$STALE_DAYS" ]; then
        stale+=("$file")
    else
        recent+=("$file")
    fi
done < <(find "$TMP_DIR" -type f -not -name '.gitkeep' -not -name '.DS_Store' | sort)

total_count=$(( ${#stale[@]} + ${#recent[@]} ))

if [ "$total_count" -eq 0 ]; then
    echo -e "${GREEN}docs/tmp/ is clean. Nothing to remove.${NC}"
    exit 0
fi

# Report
echo -e "${CYAN}=== docs/tmp/ cleanup ===${NC}"
echo ""

if [ ${#stale[@]} -gt 0 ]; then
    echo -e "${RED}Stale (${#stale[@]} files):${NC}"
    for file in "${stale[@]}"; do
        rel="${file#$TMP_DIR/}"
        age=$(file_age_days "$file")
        echo -e "  ${RED}✗${NC} $rel ${DIM}($(format_age "$age"))${NC}"
    done
    echo ""
fi

if [ ${#recent[@]} -gt 0 ]; then
    echo -e "${GREEN}Recent (${#recent[@]} files — keeping):${NC}"
    for file in "${recent[@]}"; do
        rel="${file#$TMP_DIR/}"
        age=$(file_age_days "$file")
        echo -e "  ${GREEN}✓${NC} $rel ${DIM}($(format_age "$age"))${NC}"
    done
    echo ""
fi

# Determine what to delete based on mode
if [ "$MODE" = "--all" ]; then
    targets=("${stale[@]}" "${recent[@]}")
    label="all $total_count"
elif [ "$MODE" = "--delete" ] || [ "$MODE" = "--force" ]; then
    targets=("${stale[@]}")
    label="${#stale[@]} stale"
else
    targets=()
    label=""
fi

if [ ${#targets[@]} -eq 0 ] && [ "$MODE" = "dry-run" ]; then
    if [ ${#stale[@]} -eq 0 ]; then
        echo -e "${GREEN}Nothing stale to clean. ${#recent[@]} recent files kept.${NC}"
    else
        echo -e "${DIM}Dry run — nothing was deleted.${NC}"
        echo -e "Run with ${CYAN}--delete${NC} to remove stale files, or ${CYAN}--all${NC} to clear everything."
    fi
    exit 0
fi

if [ ${#targets[@]} -eq 0 ]; then
    echo -e "${GREEN}Nothing to delete.${NC}"
    exit 0
fi

# Confirm unless --force
if [ "$MODE" = "--delete" ] || [ "$MODE" = "--all" ]; then
    echo -en "Delete $label files? [y/N] "
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy] ]]; then
        echo "Aborted."
        exit 0
    fi
fi

deleted=0
for file in "${targets[@]}"; do
    rel="${file#$TMP_DIR/}"
    if rm -- "$file" 2>/dev/null; then
        echo -e "  ${RED}Deleted${NC} $rel"
        deleted=$((deleted + 1))
    else
        echo -e "  ${YELLOW}Could not delete${NC} $rel"
    fi
done

# Remove empty subdirectories (but not the tmp dir itself)
find "$TMP_DIR" -mindepth 1 -type d -empty -delete 2>/dev/null || true
echo -e "\n${GREEN}Cleared ${deleted} files from docs/tmp/${NC}"
