#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verify STATE.md exists and is valid
if [ ! -f "docs/STATE.md" ]; then
    echo -e "${RED}ERROR: docs/STATE.md not found!${NC}"
    echo "Run ./setup.sh first to initialize the project."
    exit 1
fi

# Read highest task ID and increment with error handling
HIGHEST_ID=$(awk '/5DAY_TASK_ID/{print $NF}' docs/STATE.md)
if [ -z "$HIGHEST_ID" ] || ! [[ "$HIGHEST_ID" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}ERROR: Invalid or missing task ID in STATE.md${NC}"
    echo "Please fix docs/STATE.md manually. Expected format: '5DAY_TASK_ID: NUMBER'"
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
FEATURE="$2"
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

# Create the task file matching src/templates/project/TEMPLATE-task.md
if [ -n "$FEATURE" ]; then
    FEATURE_LINE="**Feature**: /docs/features/${FEATURE}.md"
else
    FEATURE_LINE="**Feature**: none"
fi

CREATED_DATE=$(date +%Y-%m-%d)

cat << 'TASKEOF' > docs/tasks/backlog/$FILENAME
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

Get next ID: docs/STATE.md (5DAY_TASK_ID field + 1)
Full protocol: docs/5day/ai/task-creation.md
-->
TASKEOF

# Replace placeholders with actual values
sed -i '' "s/NEW_ID_PLACEHOLDER/$NEW_ID/g" "docs/tasks/backlog/$FILENAME"
sed -i '' "s/DESCRIPTION_PLACEHOLDER/$DESCRIPTION/g" "docs/tasks/backlog/$FILENAME"
sed -i '' "s|FEATURE_LINE_PLACEHOLDER|$FEATURE_LINE|g" "docs/tasks/backlog/$FILENAME"
sed -i '' "s/CREATED_DATE_PLACEHOLDER/$CREATED_DATE/g" "docs/tasks/backlog/$FILENAME"

# Atomic update of STATE.md using temporary file
LAST_UPDATED=$(date +%F)
TEMP_STATE="docs/STATE.md.tmp.$$"

# Get current values to preserve them
CURRENT_VERSION=$(awk '/5DAY_VERSION/{print $NF}' docs/STATE.md)
if [ -z "$CURRENT_VERSION" ]; then
    CURRENT_VERSION="1.0.0"  # Default if not found
fi

HIGHEST_BUG_ID=$(awk '/5DAY_BUG_ID/{print $NF}' docs/STATE.md)
if [ -z "$HIGHEST_BUG_ID" ]; then
    HIGHEST_BUG_ID="0"  # Default if not found
fi

SYNC_ALL_TASKS=$(awk '/SYNC_ALL_TASKS/{print $NF}' docs/STATE.md)
if [ -z "$SYNC_ALL_TASKS" ]; then
    SYNC_ALL_TASKS="false"  # Default if not found
fi

# Create temporary file with new state
cat << EOF > "$TEMP_STATE"
# docs/STATE.md

**Last Updated**: $LAST_UPDATED
**5DAY_VERSION**: $CURRENT_VERSION
**5DAY_TASK_ID**: $NEW_ID
**5DAY_BUG_ID**: $HIGHEST_BUG_ID
**SYNC_ALL_TASKS**: $SYNC_ALL_TASKS
EOF

# Atomically replace STATE.md
if mv -f "$TEMP_STATE" docs/STATE.md; then
    echo -e "${GREEN}✓ STATE.md updated successfully${NC}"
else
    echo -e "${RED}ERROR: Failed to update STATE.md${NC}"
    rm -f "docs/tasks/backlog/$FILENAME"
    rm -f "$TEMP_STATE"
    exit 1
fi

# Verify task file was created successfully
if [ ! -f "docs/tasks/backlog/$FILENAME" ]; then
    echo -e "${RED}ERROR: Task file was not created${NC}"
    exit 1
fi

# Stage the changes
git add docs/STATE.md "docs/tasks/backlog/$FILENAME"

echo -e "${GREEN}Created task: docs/tasks/backlog/$FILENAME${NC}"
echo ""
echo "Next: Edit the file to define the problem and success criteria."