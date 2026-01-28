#!/bin/bash
set -e

# Create a new feature document in docs/features

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

# Create feature document
cat > "$FEATURE_FILE" << 'EOL'
# Feature: FEATURE_NAME_PLACEHOLDER

**Status:** BACKLOG
**Created:** CREATED_DATE_PLACEHOLDER
**Updated:** CREATED_DATE_PLACEHOLDER

## Overview

<!-- 2-3 sentences: What is this feature and why does it matter?
     Write for someone unfamiliar with the project. -->



## User Stories

<!-- Capture real user needs. Pattern: "As a [who], I want [what], so that [why]" -->

- As a _, I want to _, so that _

## Requirements

### Functional Requirements

<!-- What the feature does. Each should be testable. -->

- [ ]
- [ ]

### Non-Functional Requirements

<!-- Performance, security, accessibility, etc. -->

- [ ]

## Technical Design

### Architecture

<!-- High-level approach. Keep it brief until implementation begins. -->



### Dependencies

<!-- Other features, services, or libraries this requires. -->

-

### API/Interface

<!-- Public interfaces this feature exposes, if any. -->



## Implementation Tasks

<!-- Link tasks as they're created. Pattern: Task #ID - Brief description -->

- [ ]

## Testing Strategy

### Test Cases

<!-- Key scenarios to verify. -->

- [ ]

### Acceptance Criteria

<!-- Observable behaviors that confirm the feature works.
     Pattern: "User can [do what]" or "System shows [result]" -->

- [ ]
- [ ]

## Documentation

<!-- Track documentation needs. -->

- [ ] User-facing docs
- [ ] Technical docs

## Notes

<!-- Additional context, constraints, or considerations. -->


<!--
AI FEATURE GUIDE

Status values: BACKLOG → WORKING → LIVE

Write in plain English throughout. Focus on what users experience.
Technical details can wait until implementation begins.

Acceptance criteria work best as observable behaviors:
  - User can export data as CSV
  - Dashboard loads within 2 seconds
  - Error message appears when form is invalid
-->
EOL

# Replace placeholders
sed -i '' "s/FEATURE_NAME_PLACEHOLDER/${FEATURE_NAME}/g" "$FEATURE_FILE"
sed -i '' "s/CREATED_DATE_PLACEHOLDER/$(date +%Y-%m-%d)/g" "$FEATURE_FILE"

echo -e "${GREEN}Created feature: $FEATURE_FILE${NC}"
echo ""
echo "Next: Edit the file to define requirements and acceptance criteria."