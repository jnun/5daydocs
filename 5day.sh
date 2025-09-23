#!/bin/bash

# 5d - Five Day Docs Command Line Tool
# Main entry point for managing tasks, features, and project analysis

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the absolute path to the project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to display help
show_help() {
    echo -e "${CYAN}5d - Five Day Docs Management Tool${NC}"
    echo ""
    echo "Usage: 5d <command> [options]"
    echo ""
    echo -e "${BLUE}Commands:${NC}"
    echo "  newtask <description>     Create a new task in backlog"
    echo "  newfeature <name>         Create a new feature document"
    echo "  checkfeatures             Analyze feature alignment across docs"
    echo "  status                    Show current task status"
    echo "  help                      Show this help message"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  5d newtask \"Fix login authentication bug\""
    echo "  5d newfeature user-profile"
    echo "  5d checkfeatures"
    echo "  5d status"
    echo ""
}

# Function to create a new task
create_task() {
    local description="$1"

    if [ -z "$description" ]; then
        echo -e "${RED}ERROR: Task description required${NC}"
        echo "Usage: 5d newtask \"Brief description of the task\""
        exit 1
    fi

    # Call the existing create-task.sh script
    if [ -x "$PROJECT_ROOT/work/scripts/create-task.sh" ]; then
        "$PROJECT_ROOT/work/scripts/create-task.sh" "$description"
    else
        echo -e "${RED}ERROR: create-task.sh not found or not executable${NC}"
        echo "Run: chmod +x work/scripts/create-task.sh"
        exit 1
    fi
}

# Function to create a new feature
create_feature() {
    local feature_name="$1"

    if [ -z "$feature_name" ]; then
        echo -e "${RED}ERROR: Feature name required${NC}"
        echo "Usage: 5d newfeature <feature-name>"
        exit 1
    fi

    # Call the create-feature.sh script
    if [ -x "$PROJECT_ROOT/work/scripts/create-feature.sh" ]; then
        "$PROJECT_ROOT/work/scripts/create-feature.sh" "$feature_name"
    else
        echo -e "${RED}ERROR: create-feature.sh not found or not executable${NC}"
        echo "Creating it now..."
        # Create the feature script if it doesn't exist
        cat > "$PROJECT_ROOT/work/scripts/create-feature.sh" << 'EOF'
#!/bin/bash

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

echo -e "${GREEN}✓ Created feature: $FEATURE_FILE${NC}"
echo ""
echo "Next steps:"
echo "1. Edit the feature document with detailed requirements"
echo "2. Create tasks for implementation: 5d newtask \"Implement $FEATURE_NAME\""
echo "3. Move feature to WORKING when development begins"
EOF
        chmod +x "$PROJECT_ROOT/work/scripts/create-feature.sh"
        "$PROJECT_ROOT/work/scripts/create-feature.sh" "$feature_name"
    fi
}

# Function to check features
check_features() {
    if [ -x "$PROJECT_ROOT/work/scripts/check-alignment.sh" ]; then
        "$PROJECT_ROOT/work/scripts/check-alignment.sh"
    else
        echo -e "${RED}ERROR: check-alignment.sh not found or not executable${NC}"
        echo "Run: chmod +x work/scripts/check-alignment.sh"
        exit 1
    fi
}

# Function to show task status
show_status() {
    echo -e "${CYAN}=== 5-Day Docs Task Status ===${NC}"
    echo ""

    # Count tasks in each stage
    local backlog_count=$(ls -1 work/tasks/backlog/*.md 2>/dev/null | wc -l | tr -d ' ')
    local next_count=$(ls -1 work/tasks/next/*.md 2>/dev/null | wc -l | tr -d ' ')
    local working_count=$(ls -1 work/tasks/working/*.md 2>/dev/null | wc -l | tr -d ' ')
    local review_count=$(ls -1 work/tasks/review/*.md 2>/dev/null | wc -l | tr -d ' ')
    local live_count=$(ls -1 work/tasks/live/*.md 2>/dev/null | wc -l | tr -d ' ')

    echo -e "${BLUE}Task Pipeline:${NC}"
    echo "  Backlog:  $backlog_count tasks"
    echo "  Next:     $next_count tasks"
    echo "  Working:  $working_count tasks"
    echo "  Review:   $review_count tasks"
    echo "  Live:     $live_count tasks"
    echo ""

    # Show current highest task ID
    if [ -f "work/STATE.md" ]; then
        local highest_id=$(awk '/Highest Task ID/{print $NF}' work/STATE.md)
        echo -e "${BLUE}Current highest task ID:${NC} $highest_id"
    fi

    # Show tasks in working
    if [ "$working_count" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Currently working on:${NC}"
        for task in work/tasks/working/*.md; do
            if [ -f "$task" ]; then
                basename "$task" .md
            fi
        done
    fi

    # Count features
    if [ -d "docs/features" ]; then
        echo ""
        echo -e "${BLUE}Features:${NC}"
        local feature_count=$(ls -1 docs/features/*.md 2>/dev/null | wc -l | tr -d ' ')
        echo "  Total features: $feature_count"

        # Count by status
        local backlog_features=$(grep -l "Status:.*BACKLOG" docs/features/*.md 2>/dev/null | wc -l | tr -d ' ')
        local working_features=$(grep -l "Status:.*WORKING" docs/features/*.md 2>/dev/null | wc -l | tr -d ' ')
        local testing_features=$(grep -l "Status:.*TESTING" docs/features/*.md 2>/dev/null | wc -l | tr -d ' ')
        local live_features=$(grep -l "Status:.*LIVE" docs/features/*.md 2>/dev/null | wc -l | tr -d ' ')

        echo "    BACKLOG: $backlog_features"
        echo "    WORKING: $working_features"
        echo "    TESTING: $testing_features"
        echo "    LIVE:    $live_features"
    fi
}

# Main command router
case "$1" in
    newtask)
        shift
        create_task "$@"
        ;;
    newfeature)
        shift
        create_feature "$@"
        ;;
    checkfeatures)
        check_features
        ;;
    status)
        show_status
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo -e "${RED}ERROR: Unknown command '$1'${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac