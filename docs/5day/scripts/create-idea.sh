#!/usr/bin/env bash
set -euo pipefail

# Create a new idea document in docs/ideas

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get idea name
IDEA_NAME="$1"
if [ -z "$IDEA_NAME" ]; then
    echo -e "${RED}ERROR: Idea name required${NC}"
    echo "Usage: $0 <idea-name>"
    exit 1
fi

# Convert to kebab-case
KEBAB_CASE=$(echo "$IDEA_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')

# Idea file path
IDEA_FILE="docs/ideas/${KEBAB_CASE}.md"

# Check if idea already exists
if [ -f "$IDEA_FILE" ]; then
    echo -e "${YELLOW}WARNING: Idea '$KEBAB_CASE' already exists at $IDEA_FILE${NC}"
    exit 1
fi

# Create ideas directory if it doesn't exist
mkdir -p docs/ideas

# Read template and substitute placeholders
TEMPLATE_FILE="docs/ideas/.TEMPLATE-idea.md"
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}ERROR: Template file not found: $TEMPLATE_FILE${NC}"
    exit 1
fi

CREATED_DATE=$(date +%Y-%m-%d)

cp "$TEMPLATE_FILE" "$IDEA_FILE"

sed_inplace "s/\[IDEA-NAME\]/$(sed_escape "$IDEA_NAME")/g" "$IDEA_FILE"
sed_inplace "s/YYYY-MM-DD/$CREATED_DATE/g" "$IDEA_FILE"

# Stage the changes (skip gracefully if not in a git repo)
git add "$IDEA_FILE" 2>/dev/null || true

echo -e "${GREEN}Created idea: $IDEA_FILE${NC}"
echo ""
echo "Next: Open the file and work through each section."
