#!/bin/bash
set -e

# Create a new bug report in docs/bugs

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

# Read highest bug ID and increment with error handling
HIGHEST_ID=$(awk '/^\*\*5DAY_BUG_ID\*\*:/{print $NF}' docs/5day/DOC_STATE.md)
if [ -z "$HIGHEST_ID" ] || ! [[ "$HIGHEST_ID" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}ERROR: Invalid or missing bug ID in DOC_STATE.md${NC}"
    echo "Please fix docs/5day/DOC_STATE.md manually. Expected format: '**5DAY_BUG_ID**: NUMBER'"
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

FILENAME=$(printf "%d-%s.md" "$NEW_ID" "$KEBAB_CASE_DESC")

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
cat << 'BUGEOF' > "docs/bugs/$FILENAME"
# Bug BUG_ID_PLACEHOLDER: DESCRIPTION_PLACEHOLDER

**Severity:** [CRITICAL | HIGH | MEDIUM | LOW]
**Created**: CREATED_DATE_PLACEHOLDER

## Problem

<!-- What is happening, and what should happen instead?
     Be specific about the unexpected behavior. -->



## Steps to reproduce

<!-- Numbered steps someone can follow to see the bug. -->

1.
2.
3.

## Success criteria

<!-- How do you know this is fixed?
     Write observable behaviors: "User can [do what]" or "System shows [result]" -->

- [ ]

## Notes

<!-- Environment details, screenshots, error messages, related files, or any other context.
     Leave empty if none, but keep this section. -->



<!--
AI BUG GUIDE

Severity levels:
  CRITICAL: System down, data loss, security issue
  HIGH: Major feature broken, blocks users
  MEDIUM: Feature impaired, workaround exists
  LOW: Minor issue, cosmetic

Bug file naming: ID-description.md (e.g., 3-login-timeout.md)

After documenting the bug:
1. Create a task to fix it (./5day.sh newtask "Fix: [bug description]")
2. Reference this bug file in the task
3. Move this file to docs/bugs/archived/ when fixed
-->
BUGEOF

# Replace placeholders with actual values (escape user input for sed safety)
sed_inplace "s/BUG_ID_PLACEHOLDER/$NEW_ID/g" "docs/bugs/$FILENAME"
sed_inplace "s/DESCRIPTION_PLACEHOLDER/$(sed_escape "$DESCRIPTION")/g" "docs/bugs/$FILENAME"
sed_inplace "s/CREATED_DATE_PLACEHOLDER/$CREATED_DATE/g" "docs/bugs/$FILENAME"

# Update DOC_STATE.md in place — only touch the fields that changed
LAST_UPDATED=$(date +%F)
TEMP_STATE="docs/5day/DOC_STATE.md.tmp.$$"
cp docs/5day/DOC_STATE.md "$TEMP_STATE"
sed_inplace "s/^\*\*5DAY_BUG_ID\*\*:.*/**5DAY_BUG_ID**: $NEW_ID/" "$TEMP_STATE"
sed_inplace "s/^\*\*Last Updated\*\*:.*/**Last Updated**: $LAST_UPDATED/" "$TEMP_STATE"
if mv -f "$TEMP_STATE" docs/5day/DOC_STATE.md; then
    echo -e "${GREEN}✓ DOC_STATE.md updated successfully${NC}"
else
    echo -e "${RED}ERROR: Failed to update DOC_STATE.md${NC}"
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
git add docs/5day/DOC_STATE.md "docs/bugs/$FILENAME"

echo -e "${GREEN}Created bug: docs/bugs/$FILENAME${NC}"
echo ""
echo "Next: Fill in the severity, problem description, and steps to reproduce."
