#!/bin/bash

# Sync task files to GitHub by committing and pushing to main
# This triggers the GitHub Actions workflow that creates/updates issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$PROJECT_ROOT"

# Check we're in a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}ERROR: Not a git repository${NC}"
    exit 1
fi

# Check we're on main
BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "main" ]; then
    echo -e "${RED}ERROR: Must be on main branch (currently on '$BRANCH')${NC}"
    exit 1
fi

# Check for a remote
if ! git remote get-url origin >/dev/null 2>&1; then
    echo -e "${RED}ERROR: No 'origin' remote configured${NC}"
    exit 1
fi

# Determine what to sync
FORCE_ALL=false
if [ "${1:-}" = "--all" ]; then
    FORCE_ALL=true
    shift
fi

echo -e "${CYAN}=== 5DayDocs GitHub Sync ===${NC}"
echo ""

# Stage task files from all pipeline folders
FOLDERS="backlog next working blocked review live"
STAGED=0

for folder in $FOLDERS; do
    DIR="docs/tasks/$folder"
    [ -d "$DIR" ] || continue
    CHANGES=$(git status --porcelain "$DIR" 2>/dev/null || true)
    if [ -n "$CHANGES" ]; then
        git add "$DIR"/*.md 2>/dev/null || true
        COUNT=$(echo "$CHANGES" | wc -l | tr -d ' ')
        echo -e "  ${GREEN}+${NC} $folder: $COUNT file(s)"
        STAGED=$((STAGED + COUNT))
    fi
done

# Also stage DOC_STATE.md if changed
if git status --porcelain docs/5day/DOC_STATE.md 2>/dev/null | grep -q .; then
    git add docs/5day/DOC_STATE.md 2>/dev/null || true
    echo -e "  ${GREEN}+${NC} DOC_STATE.md"
    STAGED=$((STAGED + 1))
fi

# If --all, set the bulk sync flag
if [ "$FORCE_ALL" = "true" ]; then
    if grep -q '^\*\*SYNC_ALL_TASKS\*\*: false' docs/5day/DOC_STATE.md; then
        if sed --version 2>/dev/null | grep -q GNU; then
            sed -i 's/^\*\*SYNC_ALL_TASKS\*\*: false$/\*\*SYNC_ALL_TASKS\*\*: true/' docs/5day/DOC_STATE.md
        else
            sed -i '' 's/^\*\*SYNC_ALL_TASKS\*\*: false$/\*\*SYNC_ALL_TASKS\*\*: true/' docs/5day/DOC_STATE.md
        fi
        git add docs/5day/DOC_STATE.md 2>/dev/null || true
        echo -e "  ${YELLOW}!${NC} SYNC_ALL_TASKS set to true (full resync)"
        STAGED=$((STAGED + 1))
    fi
fi

if [ "$STAGED" -eq 0 ]; then
    echo -e "${YELLOW}No task changes to sync.${NC}"
    if [ "$FORCE_ALL" != "true" ]; then
        echo "Use --all to force a full resync of all tasks."
    fi
    exit 0
fi

echo ""

# Commit
git commit -m "sync: update task files for GitHub issue sync"

# Push
echo -e "${CYAN}Pushing to origin/main...${NC}"
git push origin main

echo ""
echo -e "${GREEN}Synced $STAGED file(s). GitHub Actions will update issues shortly.${NC}"
echo "Check workflow status: gh run list --workflow=sync-tasks-to-issues.yml --limit 1"
