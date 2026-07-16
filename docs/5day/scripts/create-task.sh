#!/usr/bin/env bash
# create-task.sh — Create a task. See: ./5day.sh help newtask
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Read template and substitute placeholders
TEMPLATE_FILE="docs/tasks/.TEMPLATE-task.md"
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}ERROR: Template file not found: $TEMPLATE_FILE${NC}"
    exit 1
fi

if [ -n "$FEATURE" ]; then
    FEATURE_LINE="**Feature**: /docs/features/${FEATURE}.md"
else
    FEATURE_LINE="**Feature**: none"
fi

CREATED_DATE=$(date +%Y-%m-%d)

cp "$TEMPLATE_FILE" "docs/tasks/backlog/$FILENAME"

sed_inplace "s/\[ID\]/$NEW_ID/g" "docs/tasks/backlog/$FILENAME"
sed_inplace "s/\[Brief Description\]/$(sed_escape "$DESCRIPTION")/g" "docs/tasks/backlog/$FILENAME"
sed_inplace "s/YYYY-MM-DD/$CREATED_DATE/g" "docs/tasks/backlog/$FILENAME"
if [ -n "$FEATURE" ]; then
    sed_inplace "s/\*\*Feature\*\*: none/$(sed_escape "$FEATURE_LINE")/g" "docs/tasks/backlog/$FILENAME"
fi

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