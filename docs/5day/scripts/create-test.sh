#!/usr/bin/env bash
set -euo pipefail

# create-test.sh — Create a test loop. See: ./5day.sh help newtest

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

NAME="${1:-}"
if [ -z "$NAME" ]; then
    echo "Usage: $0 \"What you're testing\""
    echo ""
    echo "Examples:"
    echo "  $0 \"Signup converts cold visitors\""
    echo "  $0 \"Users finish onboarding unaided\""
    exit 1
fi

# Convert to kebab-case for the filename
KEBAB=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')

# Limit filename length to keep paths portable
if [ ${#KEBAB} -gt 50 ]; then
    KEBAB="${KEBAB:0:50}"
    KEBAB=$(echo "$KEBAB" | sed 's/-$//')
    echo -e "${YELLOW}Note: Filename truncated to 50 characters${NC}"
fi

TEST_FILE="docs/tests/${KEBAB}.md"

if [ -f "$TEST_FILE" ]; then
    echo -e "${YELLOW}WARNING: Test '$KEBAB' already exists at $TEST_FILE${NC}"
    exit 1
fi

mkdir -p docs/tests

TEMPLATE_FILE="docs/tests/.TEMPLATE-test.md"
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}ERROR: Template file not found: $TEMPLATE_FILE${NC}"
    exit 1
fi

CREATED_DATE=$(date +%Y-%m-%d)

cp "$TEMPLATE_FILE" "$TEST_FILE"

sed_inplace "s/\[TEST-NAME\]/$(sed_escape "$NAME")/g" "$TEST_FILE"
sed_inplace "s/YYYY-MM-DD/$CREATED_DATE/g" "$TEST_FILE"

# Stage the change (skip gracefully if not in a git repo)
git add "$TEST_FILE" 2>/dev/null || true

echo -e "${GREEN}Created test: $TEST_FILE${NC}"
echo ""
echo "Next: Sharpen what you're testing, run it your way, then file follow-ups with newfeature or newtask."
