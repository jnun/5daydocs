#!/usr/bin/env bash
set -euo pipefail

# create-bug.sh — Report a bug. See: ./5day.sh help newbug

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

# Verify DOC_STATE.md exists and is valid
if [ ! -f "docs/5day/DOC_STATE.md" ]; then
    echo -e "${RED}ERROR: docs/5day/DOC_STATE.md not found!${NC}"
    echo "Run ./setup.sh first to initialize the project."
    exit 1
fi

# Read highest bug ID and increment with error handling
NEW_ID=$(alloc_id 5DAY_BUG_ID) || {
    echo -e "${RED}ERROR: Invalid or missing bug ID in DOC_STATE.md${NC}"
    echo "Please fix docs/5day/DOC_STATE.md manually. Expected format: '**5DAY_BUG_ID**: NUMBER'"
    exit 1
}

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
KEBAB_CASE_DESC=$(kebab_case "$DESCRIPTION")

# Limit filename length to prevent filesystem issues
if [ ${#KEBAB_CASE_DESC} -gt 50 ]; then
    KEBAB_CASE_DESC="${KEBAB_CASE_DESC:0:50}"
    echo -e "${YELLOW}Note: Filename truncated to 50 characters${NC}"
fi

FILENAME=$(printf "%d-%s.md" "$NEW_ID" "$KEBAB_CASE_DESC")

# Check if file already exists (race condition protection)
if [ -f "docs/bugs/$FILENAME" ]; then
    echo -e "${RED}ERROR: Bug file already exists!${NC}"
    echo "Another process may have created this bug. Please try again."
    exit 1
fi

# Read template and substitute placeholders
TEMPLATE_FILE="docs/bugs/.TEMPLATE-bug.md"
copy_template "$TEMPLATE_FILE" "docs/bugs/$FILENAME" || {
    echo -e "${RED}ERROR: Template file not found: $TEMPLATE_FILE${NC}"
    exit 1
}

CREATED_DATE=$(date +%Y-%m-%d)

sed_inplace "s/\[ID\]/$NEW_ID/g" "docs/bugs/$FILENAME"
sed_inplace "s/\[Brief Description\]/$(sed_escape "$DESCRIPTION")/g" "docs/bugs/$FILENAME"
sed_inplace "s/YYYY-MM-DD/$CREATED_DATE/g" "docs/bugs/$FILENAME"

# Update DOC_STATE.md in place — only touch the fields that changed
LAST_UPDATED=$(date +%F)
bump_doc_state 5DAY_BUG_ID "$NEW_ID"
bump_doc_state "Last Updated" "$LAST_UPDATED"
echo -e "${GREEN}✓ DOC_STATE.md updated successfully${NC}"

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
