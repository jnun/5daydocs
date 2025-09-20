#!/bin/bash

# Exit on error
set -e

# Read highest task ID and increment
HIGHEST_ID=$(awk '/Highest Task ID/{print $NF}' work/STATE.md)
NEW_ID=$((HIGHEST_ID + 1))

# Get the task description from the command line argument
DESCRIPTION="$1"
if [ -z "$DESCRIPTION" ]; then
  echo "Usage: $0 \"Brief description of the task\""
  exit 1
fi
KEBAB_CASE_DESC=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9 -]/ /g' | sed 's/  */-/g' | sed 's/^-//;s/-$//')
FILENAME=$(printf "%03d-%s.md" "$NEW_ID" "$KEBAB_CASE_DESC")

# Create the task file using a here-document for readability
cat << EOF > work/tasks/backlog/$FILENAME
# Task ID: $DESCRIPTION

**Feature**: none
**Created**: $(date +%F)

## Problem
Description of what needs to be fixed or built

## Success Criteria
- [ ] First criterion
- [ ] Second criterion
EOF

# Update work/STATE.md using a temporary file to prevent race conditions
LAST_UPDATED=$(date +%F)
cat << EOF > work/STATE.md
# work/STATE.md

**Last Updated**: $LAST_UPDATED
**Highest Task ID**: $NEW_ID
EOF

# Stage the changes and print the commit message
git add work/STATE.md "work/tasks/backlog/$FILENAME"
echo "Staged new task: $FILENAME"
echo "Suggested commit message: git commit -m 'feat: Add task #$NEW_ID - $DESCRIPTION'"