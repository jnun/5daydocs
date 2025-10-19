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
if [ -f "docs/work/tasks/backlog/$FILENAME" ]; then
    echo -e "${RED}ERROR: Task file already exists!${NC}"
    echo "Another process may have created this task. Please try again."
    exit 1
fi

# Create the task file with simple format matching actual usage
if [ -n "$FEATURE" ]; then
    FEATURE_LINE="**Feature**: /docs/features/${FEATURE}.md"
else
    FEATURE_LINE=""
fi

cat << EOF > docs/work/tasks/backlog/$FILENAME
# Task $NEW_ID: $DESCRIPTION

## Problem
[Describe what needs to be done or fixed]

$( [ -n "$FEATURE_LINE" ] && echo -e "$FEATURE_LINE\n" || echo "" )
## Desired Outcome
[Describe what success looks like]

## Testing Criteria
- [ ] [First success criterion]
- [ ] [Second success criterion]
- [ ] [Additional criteria as needed]
EOF

# Atomic update of STATE.md using temporary file
LAST_UPDATED=$(date +%F)
TEMP_STATE="docs/STATE.md.tmp.$$"

# Get current bug ID and sync flag to preserve them
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
**5DAY_TASK_ID**: $NEW_ID
**5DAY_BUG_ID**: $HIGHEST_BUG_ID
**SYNC_ALL_TASKS**: $SYNC_ALL_TASKS
EOF

# Atomically replace STATE.md
if mv -f "$TEMP_STATE" docs/STATE.md; then
    echo -e "${GREEN}✓ STATE.md updated successfully${NC}"
else
    echo -e "${RED}ERROR: Failed to update STATE.md${NC}"
    rm -f "docs/work/tasks/backlog/$FILENAME"
    rm -f "$TEMP_STATE"
    exit 1
fi

# Verify task file was created successfully
if [ ! -f "docs/work/tasks/backlog/$FILENAME" ]; then
    echo -e "${RED}ERROR: Task file was not created${NC}"
    exit 1
fi

# Stage the changes and print summary
git add docs/STATE.md "docs/work/tasks/backlog/$FILENAME"

echo ""
echo -e "${GREEN}✓ Task created successfully!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Task ID:     ${GREEN}#$NEW_ID${NC}"
echo -e "Title:       $DESCRIPTION"
if [ -n "$FEATURE" ]; then
    echo -e "Feature:     $FEATURE"
fi
echo -e "Location:    docs/work/tasks/backlog/$FILENAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Edit the task file to add problem details and criteria"
echo "2. Commit: git commit -m 'Add task $NEW_ID: $DESCRIPTION'"
echo "3. Move to sprint: git mv docs/work/tasks/backlog/$FILENAME docs/work/tasks/next/"