#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verify STATE.md exists and is valid
if [ ! -f "work/STATE.md" ]; then
    echo -e "${RED}ERROR: work/STATE.md not found!${NC}"
    echo "Run ./work/scripts/setup.sh first to initialize the project."
    exit 1
fi

# Read highest task ID and increment with error handling
HIGHEST_ID=$(awk '/Highest Task ID/{print $NF}' work/STATE.md)
if [ -z "$HIGHEST_ID" ] || ! [[ "$HIGHEST_ID" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}ERROR: Invalid or missing task ID in STATE.md${NC}"
    echo "Please fix work/STATE.md manually. Expected format: 'Highest Task ID: NUMBER'"
    exit 1
fi

NEW_ID=$((HIGHEST_ID + 1))

# Get the task description from the command line argument
DESCRIPTION="$1"
if [ -z "$DESCRIPTION" ]; then
  echo "Usage: $0 \"Brief description of the task\" [options]"
  echo ""
  echo "Options:"
  echo "  --priority=<P0|P1|P2|P3>  Set task priority (default: P2)"
  echo "  --assignee=<name>         Assign task to someone"
  echo "  --feature=<feature-name>  Link to a feature"
  echo "  --estimate=<hours>        Add time estimate"
  echo ""
  echo "Example:"
  echo "  $0 \"Fix login bug\" --priority=P1 --assignee=john --estimate=4"
  exit 1
fi

# Parse optional arguments
PRIORITY="P2"
ASSIGNEE="unassigned"
FEATURE="none"
ESTIMATE=""

for arg in "${@:2}"; do
    case $arg in
        --priority=*)
            PRIORITY="${arg#*=}"
            if ! [[ "$PRIORITY" =~ ^P[0-3]$ ]]; then
                echo -e "${YELLOW}Warning: Invalid priority '$PRIORITY'. Using P2.${NC}"
                PRIORITY="P2"
            fi
            ;;
        --assignee=*)
            ASSIGNEE="${arg#*=}"
            ;;
        --feature=*)
            FEATURE="${arg#*=}"
            ;;
        --estimate=*)
            ESTIMATE="${arg#*=}"
            ;;
        *)
            echo -e "${YELLOW}Warning: Unknown option '$arg' ignored${NC}"
            ;;
    esac
done
# Convert to kebab-case and validate
KEBAB_CASE_DESC=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9 -]/ /g' | sed 's/  */-/g' | sed 's/^-//;s/-$//')

# Limit filename length to prevent filesystem issues
if [ ${#KEBAB_CASE_DESC} -gt 50 ]; then
    KEBAB_CASE_DESC="${KEBAB_CASE_DESC:0:50}"
    echo -e "${YELLOW}Note: Filename truncated to 50 characters${NC}"
fi

FILENAME=$(printf "%03d-%s.md" "$NEW_ID" "$KEBAB_CASE_DESC")

# Check if file already exists (race condition protection)
if [ -f "work/tasks/backlog/$FILENAME" ]; then
    echo -e "${RED}ERROR: Task file already exists!${NC}"
    echo "Another process may have created this task. Please try again."
    exit 1
fi

# Create the task file with enhanced agile template
cat << EOF > work/tasks/backlog/$FILENAME
# Task $NEW_ID: $DESCRIPTION

## Metadata
- **Priority**: $PRIORITY
- **Assignee**: $ASSIGNEE
- **Feature**: $FEATURE
- **Created**: $(date +%F)
- **Status**: BACKLOG
$( [ -n "$ESTIMATE" ] && echo "- **Estimate**: ${ESTIMATE} hours" || echo "" )

## Problem Statement
_Describe the issue or requirement that this task addresses_

[Add problem description here]

## User Story
_As a [user type], I want [goal] so that [benefit]_

As a user, I want...

## Success Criteria
_Define what "done" looks like for this task_

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Tests pass
- [ ] Documentation updated

## Technical Notes
_Implementation details, dependencies, or technical considerations_

-

## References
_Links to related tasks, features, or documentation_

- Related to: #
EOF

# Atomic update of STATE.md using temporary file
LAST_UPDATED=$(date +%F)
TEMP_STATE="work/STATE.md.tmp.$$"

# Create temporary file with new state
cat << EOF > "$TEMP_STATE"
# work/STATE.md

**Last Updated**: $LAST_UPDATED
**Highest Task ID**: $NEW_ID
EOF

# Atomically replace STATE.md
if mv -f "$TEMP_STATE" work/STATE.md; then
    echo -e "${GREEN}✓ STATE.md updated successfully${NC}"
else
    echo -e "${RED}ERROR: Failed to update STATE.md${NC}"
    rm -f "work/tasks/backlog/$FILENAME"
    rm -f "$TEMP_STATE"
    exit 1
fi

# Verify task file was created successfully
if [ ! -f "work/tasks/backlog/$FILENAME" ]; then
    echo -e "${RED}ERROR: Task file was not created${NC}"
    exit 1
fi

# Stage the changes and print summary
git add work/STATE.md "work/tasks/backlog/$FILENAME"

echo ""
echo -e "${GREEN}✓ Task created successfully!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Task ID:     ${GREEN}#$NEW_ID${NC}"
echo -e "Priority:    $PRIORITY"
echo -e "Assignee:    $ASSIGNEE"
echo -e "Location:    work/tasks/backlog/$FILENAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Edit the task file to add more details"
echo "2. Commit: git commit -m 'feat: Add task #$NEW_ID - $DESCRIPTION'"
echo "3. Move to sprint: git mv work/tasks/backlog/$FILENAME work/tasks/next/"