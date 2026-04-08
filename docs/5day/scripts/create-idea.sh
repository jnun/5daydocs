#!/bin/bash
set -e

# Create a new idea document in docs/ideas

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

<!-- What problem does this solve? Who specifically has this problem?
     What happens if we don't solve it? Be specific about the pain point.
     Name a real person or role who would benefit. -->

**The problem:**

**Who has it:**

**What happens without it:**

---

## Phase 2: Plain English

<!-- Describe this idea so anyone on the team can understand it.
     Use everyday language. If you catch yourself using jargon, rephrase it.
     Could a new hire with no project context understand this? -->



---

## Phase 3: Decomposition

<!-- Break this idea into its smallest parts. For each part, tag it:
     [READY]    - Clear enough to become a task right now
     [RESEARCH] - Needs investigation before it can move forward
     [BLOCKED]  - Depends on something else being resolved first

     If a part feels too big, break it down further. -->

- [ ] `[READY]` (example — replace with your items)

---

## Phase 4: Open Questions

<!-- What's still unclear? What assumptions are we making?
     List anything tagged [RESEARCH] or [BLOCKED] above and what
     needs to happen to resolve it. -->

-

---

## Notes

<!-- Any additional context, links, or references. -->

---

## Ready to Graduate?

Before promoting this idea to a feature, verify:

- [ ] Phase 1 names a specific person or role who benefits
- [ ] Phase 2 is understandable by someone with no project context
- [ ] Phase 3 has no unresolved `[BLOCKED]` items
- [ ] Phase 3 has no unresolved `[RESEARCH]` items
- [ ] Every `[READY]` item is small enough to be a single task

```bash
./5day.sh promote KEBAB_CASE_PLACEHOLDER
```

EOL

# Replace placeholders (escape user input for sed safety)
sed_inplace "s/IDEA_NAME_PLACEHOLDER/$(sed_escape "$IDEA_NAME")/g" "$IDEA_FILE"
sed_inplace "s/CREATED_DATE_PLACEHOLDER/$(date +%Y-%m-%d)/g" "$IDEA_FILE"
sed_inplace "s/KEBAB_CASE_PLACEHOLDER/$(sed_escape "$KEBAB_CASE")/g" "$IDEA_FILE"

# Stage the changes
git add "$IDEA_FILE"

echo -e "${GREEN}Created idea: $IDEA_FILE${NC}"
echo ""
echo "Next: Open the file and work through each section."
