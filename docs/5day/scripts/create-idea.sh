#!/bin/bash
set -e

# Create a new idea document in docs/ideas

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

# Create idea document
cat > "$IDEA_FILE" << 'EOL'
# Idea: IDEA_NAME_PLACEHOLDER

**Status:** DRAFT
**Created:** CREATED_DATE_PLACEHOLDER

---

## Instructions

This document helps refine a rough idea into a clear definition.

**For humans:** Work through each section below. Answer the questions honestly. If something is unclear, leave it and come back.

**For AI agents:** Read `docs/5day/ai/feynman-method.md` for the full protocol. Guide the user through each phase with questions. Collaborate with the user to fill sections together.

---

## Phase 1: The Problem

<!-- What problem does this solve? Who has this problem?
     What happens if we don't solve it? Be specific about the pain point. -->



---

## Phase 2: Plain English

<!-- Describe this idea so anyone on the team can understand it.
     Use everyday language. If you catch yourself using jargon, rephrase it. -->



---

## Phase 3: What It Does

<!-- List concrete capabilities this idea enables.
     Each should be something you can demonstrate or test. -->

- [ ]
- [ ]
- [ ]

---

## Phase 4: Open Questions

<!-- What's still unclear? What needs research? What assumptions are we making?
     It's good to capture uncertainty here. -->

-

---

## Notes

<!-- Any additional context, links, or references. -->

EOL

# Replace placeholders
sed -i '' "s/IDEA_NAME_PLACEHOLDER/${IDEA_NAME}/g" "$IDEA_FILE"
sed -i '' "s/CREATED_DATE_PLACEHOLDER/$(date +%Y-%m-%d)/g" "$IDEA_FILE"

echo -e "${GREEN}Created idea: $IDEA_FILE${NC}"
echo ""
echo "Next: Open the file and work through each section."
