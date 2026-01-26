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
cat > "$FEATURE_FILE" << EOL
# Feature: ${FEATURE_NAME}

**Status:** BACKLOG
**Created:** $(date +%Y-%m-%d)
**Updated:** $(date +%Y-%m-%d)

## Overview
Brief description of the feature and its purpose.

## User Stories
- As a [user type], I want to [action], so that [benefit]

## Requirements
### Functional Requirements
- [ ] Requirement 1
- [ ] Requirement 2

### Non-Functional Requirements
- [ ] Performance criteria
- [ ] Security requirements

## Technical Design
### Architecture
Describe the technical approach and architecture

### Dependencies
- List any dependencies or prerequisites

### API/Interface
Define any APIs or interfaces

## Implementation Tasks
Reference task IDs that implement this feature:
- [ ] Task #ID - Description

## Testing Strategy
### Test Cases
- [ ] Test case 1
- [ ] Test case 2

### Acceptance Criteria
- [ ] Criteria 1
- [ ] Criteria 2

## Documentation
- [ ] User documentation
- [ ] API documentation
- [ ] Admin guide

## Notes
Additional notes or considerations
EOL

echo -e "${GREEN}Created feature: $FEATURE_FILE${NC}"
echo ""
echo "Next: Edit the file to define requirements and acceptance criteria."