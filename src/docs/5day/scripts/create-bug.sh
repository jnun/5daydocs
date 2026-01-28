#!/bin/bash
set -e

# Create a new bug report in docs/bugs

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

# Read highest bug ID and increment with error handling
HIGHEST_ID=$(awk '/5DAY_BUG_ID/{print $NF}' docs/STATE.md)
if [ -z "$HIGHEST_ID" ] || ! [[ "$HIGHEST_ID" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}ERROR: Invalid or missing bug ID in STATE.md${NC}"
    echo "Please fix docs/STATE.md manually. Expected format: '5DAY_BUG_ID: NUMBER'"
    exit 1
fi

NEW_ID=$((HIGHEST_ID + 1))

# Get the bug description from the command line argument
DESCRIPTION="$1"
if [ -z "$DESCRIPTION" ]; then
    echo "Usage: $0 \"Brief description of the bug\""
    echo ""
    echo "Examples:"
    echo "  $0 \"Login button unresponsive on mobile\""
    echo "  $0 \"Dashboard shows wrong date format\""
    exit 1
fi

# Convert to kebab-case
KEBAB_CASE_DESC=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9 -]/ /g' | sed 's/  */-/g' | sed 's/^-//;s/-$//')

# Limit filename length to prevent filesystem issues
if [ ${#KEBAB_CASE_DESC} -gt 50 ]; then
    KEBAB_CASE_DESC="${KEBAB_CASE_DESC:0:50}"
    echo -e "${YELLOW}Note: Filename truncated to 50 characters${NC}"
fi

FILENAME=$(printf "BUG-%d-%s.md" "$NEW_ID" "$KEBAB_CASE_DESC")

# Create bugs directory if it doesn't exist
mkdir -p docs/bugs

# Check if file already exists (race condition protection)
if [ -f "docs/bugs/$FILENAME" ]; then
    echo -e "${RED}ERROR: Bug file already exists!${NC}"
    echo "Another process may have created this bug. Please try again."
    exit 1
fi

CREATED_DATE=$(date +%Y-%m-%d)

# Create the bug file
cat << 'BUGEOF' > docs/bugs/$FILENAME
# Bug BUG_ID_PLACEHOLDER: DESCRIPTION_PLACEHOLDER

**Reported By:** [Your name]
**Date:** CREATED_DATE_PLACEHOLDER
**Severity:** [CRITICAL | HIGH | MEDIUM | LOW]

## Description

<!-- What is happening? Be specific about the unexpected behavior. -->



## Expected Behavior

<!-- What should happen instead? Describe the correct behavior. -->



## Steps to Reproduce

<!-- Numbered steps someone can follow to see the bug. -->

1.
2.
3.

## Environment

<!-- Where did this happen? Fill in what's relevant. -->

- Browser:
- OS:
- Device:
- Version:

## Additional Context

<!-- Screenshots, error messages, console logs, or any other helpful details. -->



<!--
AI BUG GUIDE

Severity levels:
  CRITICAL: System down, data loss, security issue
  HIGH: Major feature broken, blocks users
  MEDIUM: Feature impaired, workaround exists
  LOW: Minor issue, cosmetic

After documenting the bug:
1. Create a task to fix it (./5day.sh newtask "Fix: [bug description]")
2. Reference this bug file in the task
3. Move this file to docs/bugs/archived/ when fixed
-->
BUGEOF

# Replace placeholders with actual values
sed -i '' "s/BUG_ID_PLACEHOLDER/$NEW_ID/g" "docs/bugs/$FILENAME"
sed -i '' "s/DESCRIPTION_PLACEHOLDER/$DESCRIPTION/g" "docs/bugs/$FILENAME"
sed -i '' "s/CREATED_DATE_PLACEHOLDER/$CREATED_DATE/g" "docs/bugs/$FILENAME"

# Atomic update of STATE.md using temporary file
LAST_UPDATED=$(date +%F)
TEMP_STATE="docs/STATE.md.tmp.$$"

# Get current values to preserve them
CURRENT_VERSION=$(awk '/5DAY_VERSION/{print $NF}' docs/STATE.md)
if [ -z "$CURRENT_VERSION" ]; then
    CURRENT_VERSION="1.0.0"
fi

HIGHEST_TASK_ID=$(awk '/5DAY_TASK_ID/{print $NF}' docs/STATE.md)
if [ -z "$HIGHEST_TASK_ID" ]; then
    HIGHEST_TASK_ID="0"
fi

SYNC_ALL_TASKS=$(awk '/SYNC_ALL_TASKS/{print $NF}' docs/STATE.md)
if [ -z "$SYNC_ALL_TASKS" ]; then
    SYNC_ALL_TASKS="false"
fi

# Create temporary file with new state
cat << EOF > "$TEMP_STATE"
# docs/STATE.md

**Last Updated**: $LAST_UPDATED
**5DAY_VERSION**: $CURRENT_VERSION
**5DAY_TASK_ID**: $HIGHEST_TASK_ID
**5DAY_BUG_ID**: $NEW_ID
**SYNC_ALL_TASKS**: $SYNC_ALL_TASKS
EOF

# Atomically replace STATE.md
if mv -f "$TEMP_STATE" docs/STATE.md; then
    echo -e "${GREEN}✓ STATE.md updated successfully${NC}"
else
    echo -e "${RED}ERROR: Failed to update STATE.md${NC}"
    rm -f "docs/bugs/$FILENAME"
    rm -f "$TEMP_STATE"
    exit 1
fi

# Verify bug file was created successfully
if [ ! -f "docs/bugs/$FILENAME" ]; then
    echo -e "${RED}ERROR: Bug file was not created${NC}"
    exit 1
fi

# Stage the changes
git add docs/STATE.md "docs/bugs/$FILENAME"

echo -e "${GREEN}Created bug: docs/bugs/$FILENAME${NC}"
echo ""
echo "Next: Fill in the severity, steps to reproduce, and environment details."
