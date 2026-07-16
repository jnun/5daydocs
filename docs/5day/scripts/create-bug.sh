#!/usr/bin/env bash
set -euo pipefail

# create-bug.sh — Report a bug. See: ./5day.sh help newbug

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

# Read template and substitute placeholders
TEMPLATE_FILE="docs/bugs/.TEMPLATE-bug.md"
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}ERROR: Template file not found: $TEMPLATE_FILE${NC}"
    exit 1
fi

CREATED_DATE=$(date +%Y-%m-%d)

cp "$TEMPLATE_FILE" "docs/bugs/$FILENAME"

sed_inplace "s/\[ID\]/$NEW_ID/g" "docs/bugs/$FILENAME"
sed_inplace "s/\[Brief Description\]/$(sed_escape "$DESCRIPTION")/g" "docs/bugs/$FILENAME"
sed_inplace "s/YYYY-MM-DD/$CREATED_DATE/g" "docs/bugs/$FILENAME"

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

# Stage the changes (skip gracefully if not in a git repo)
git add docs/5day/DOC_STATE.md "docs/bugs/$FILENAME" 2>/dev/null || true

echo -e "${GREEN}Created bug: docs/bugs/$FILENAME${NC}"
echo ""
echo "Next: Fill in the severity, problem description, and steps to reproduce."
