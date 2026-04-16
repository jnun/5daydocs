#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Escape special characters for sed replacement strings (/, &, \)
sed_escape() {
    printf '%s' "$1" | sed 's;[&/\\];\\&;g'
}

# Portable in-place sed that works on both macOS (BSD) and Linux (GNU)
sed_inplace() {
    if sed --version 2>/dev/null | grep -q GNU; then
        sed -i "$@"
    else
        sed -i '' "$@"
    fi
}

# Verify DOC_STATE.md exists and is valid
if [ ! -f "docs/5day/DOC_STATE.md" ]; then
    echo -e "${RED}ERROR: docs/5day/DOC_STATE.md not found!${NC}"
    echo "Run ./setup.sh first to initialize the project."
    exit 1
fi

# Read highest task ID and increment with error handling
HIGHEST_ID=$(awk '/^\*\*5DAY_TASK_ID\*\*:/{print $NF}' docs/5day/DOC_STATE.md)
if [ -z "$HIGHEST_ID" ] || ! [[ "$HIGHEST_ID" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}ERROR: Invalid or missing task ID in DOC_STATE.md${NC}"
    echo "Please fix docs/5day/DOC_STATE.md manually. Expected format: '**5DAY_TASK_ID**: NUMBER'"
    exit 1
fi

NEW_ID=$((HIGHEST_ID + 1))

# Get the task description from the command line argument
DESCRIPTION="$1"
if [ -z "$DESCRIPTION" ]; then
  echo "Usage: $0 \"Brief description of the task\" [feature-name]"
  echo ""
  echo "Examples:"
  echo "  $0 \"Fix login bug\""
  echo "  $0 \"Add user authentication\" user-auth"
  exit 1
fi

# Optional feature name
FEATURE="${2:-}"
# Convert to kebab-case and validate
KEBAB_CASE_DESC=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9 -]/ /g' | sed 's/  */-/g' | sed 's/^-//;s/-$//')

# Limit filename length to prevent filesystem issues
if [ ${#KEBAB_CASE_DESC} -gt 50 ]; then
    KEBAB_CASE_DESC="${KEBAB_CASE_DESC:0:50}"
    echo -e "${YELLOW}Note: Filename truncated to 50 characters${NC}"
fi

FILENAME=$(printf "%d-%s.md" "$NEW_ID" "$KEBAB_CASE_DESC")

# Check if file already exists (race condition protection)
if [ -f "docs/tasks/backlog/$FILENAME" ]; then
    echo -e "${RED}ERROR: Task file already exists!${NC}"
    echo "Another process may have created this task. Please try again."
    exit 1
fi

# Create the task file matching src/docs/tasks/.TEMPLATE-task.md
if [ -n "$FEATURE" ]; then
    FEATURE_LINE="**Feature**: /docs/features/${FEATURE}.md"
else
    FEATURE_LINE="**Feature**: none"
fi

CREATED_DATE=$(date +%Y-%m-%d)

cat << 'TASKEOF' > "docs/tasks/backlog/$FILENAME"
# Task NEW_ID_PLACEHOLDER: DESCRIPTION_PLACEHOLDER

FEATURE_LINE_PLACEHOLDER
**Created**: CREATED_DATE_PLACEHOLDER
**Depends on**: none
**Blocks**: none

## Problem

<!-- Write 2-5 sentences explaining what needs solving and why.
     Describe it as you would to a colleague unfamiliar with this area. -->



## Success criteria

<!-- Write observable behaviors: "User can [do what]" or "App shows [result]"
     Each criterion should be verifiable by using the app. -->

- [ ]
- [ ]
- [ ]

## Notes

<!-- Include dependencies, related docs, or edge cases worth considering.
     Leave empty if none, but keep this section. -->

<!--
AI TASK CREATION GUIDE

Write as you'd explain to a colleague:
- Problem: describe what needs solving and why
- Success criteria: "User can [do what]" or "App shows [result]"
- Notes: dependencies, links, edge cases

Patterns that work well:
  Filename:    120-add-login-button.md (ID + kebab-case description)
  Title:       # Task 120: Add login button (matches filename ID)
  Feature:     **Feature**: /docs/features/auth.md (or "none" or "multiple")
  Created:     **Created**: 2026-01-28 (YYYY-MM-DD format)
  Depends on:  **Depends on**: Task 42 (or "none")
  Blocks:      **Blocks**: Task 101 (or "none")

Success criteria that verify easily:
  - [ ] User can reset password via email
  - [ ] Dashboard shows total for selected date range
  - [ ] Search returns results within 500ms

Get next ID: docs/5day/DOC_STATE.md (5DAY_TASK_ID field + 1)
Full protocol: docs/5day/ai/task-creation.md
-->
TASKEOF

# Replace placeholders with actual values (escape user input for sed safety)
sed_inplace "s/NEW_ID_PLACEHOLDER/$NEW_ID/g" "docs/tasks/backlog/$FILENAME"
sed_inplace "s/DESCRIPTION_PLACEHOLDER/$(sed_escape "$DESCRIPTION")/g" "docs/tasks/backlog/$FILENAME"
sed_inplace "s/FEATURE_LINE_PLACEHOLDER/$(sed_escape "$FEATURE_LINE")/g" "docs/tasks/backlog/$FILENAME"
sed_inplace "s/CREATED_DATE_PLACEHOLDER/$CREATED_DATE/g" "docs/tasks/backlog/$FILENAME"

# Update DOC_STATE.md in place — only touch the fields that changed
LAST_UPDATED=$(date +%F)
TEMP_STATE="docs/5day/DOC_STATE.md.tmp.$$"
cp docs/5day/DOC_STATE.md "$TEMP_STATE"
sed_inplace "s/^\*\*5DAY_TASK_ID\*\*:.*/**5DAY_TASK_ID**: $NEW_ID/" "$TEMP_STATE"
sed_inplace "s/^\*\*Last Updated\*\*:.*/**Last Updated**: $LAST_UPDATED/" "$TEMP_STATE"
if mv -f "$TEMP_STATE" docs/5day/DOC_STATE.md; then
    echo -e "${GREEN}✓ DOC_STATE.md updated successfully${NC}"
else
    echo -e "${RED}ERROR: Failed to update DOC_STATE.md${NC}"
    rm -f "docs/tasks/backlog/$FILENAME"
    rm -f "$TEMP_STATE"
    exit 1
fi

# Verify task file was created successfully
if [ ! -f "docs/tasks/backlog/$FILENAME" ]; then
    echo -e "${RED}ERROR: Task file was not created${NC}"
    exit 1
fi

# Stage the changes (skip gracefully if not in a git repo)
git add docs/5day/DOC_STATE.md "docs/tasks/backlog/$FILENAME" 2>/dev/null || true

echo -e "${GREEN}Created task: docs/tasks/backlog/$FILENAME${NC}"
echo ""
echo "Next: Edit the file to define the problem and success criteria."