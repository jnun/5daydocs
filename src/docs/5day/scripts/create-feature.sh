#!/usr/bin/env bash
set -euo pipefail

# Create a new feature document in docs/features

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get feature name
FEATURE_NAME="$1"
if [ -z "$FEATURE_NAME" ]; then
    echo -e "${RED}ERROR: Feature name required${NC}"
    echo "Usage: $0 <feature-name>"
    exit 1
fi

# Convert to kebab-case
KEBAB_CASE=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')

# Feature file path
FEATURE_FILE="docs/features/${KEBAB_CASE}.md"

# Check if feature already exists
if [ -f "$FEATURE_FILE" ]; then
    echo -e "${YELLOW}WARNING: Feature '$KEBAB_CASE' already exists at $FEATURE_FILE${NC}"
    exit 1
fi

# Create feature directory if it doesn't exist
mkdir -p docs/features

# Read template and substitute placeholders
TEMPLATE_FILE="docs/features/.TEMPLATE-feature.md"
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}ERROR: Template file not found: $TEMPLATE_FILE${NC}"
    exit 1
fi

CREATED_DATE=$(date +%Y-%m-%d)

cp "$TEMPLATE_FILE" "$FEATURE_FILE"

sed_inplace "s/\[FEATURE-NAME\]/$(sed_escape "$FEATURE_NAME")/g" "$FEATURE_FILE"
sed_inplace "s/YYYY-MM-DD/$CREATED_DATE/g" "$FEATURE_FILE"

# Stage the changes (skip gracefully if not in a git repo)
git add "$FEATURE_FILE" 2>/dev/null || true

echo -e "${GREEN}Created feature: $FEATURE_FILE${NC}"
echo ""
echo "Next: Edit the file to define requirements and acceptance criteria."