#!/bin/bash
# validate-tasks.sh - Validates and fixes task files to match template format
#
# Usage:
#   ./validate-tasks.sh              # Check all tasks, report issues
#   ./validate-tasks.sh --fix        # Check and auto-fix tasks
#   ./validate-tasks.sh --fix --dry-run  # Show what would be fixed without changing files

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TASK_DIRS=(
    "$PROJECT_ROOT/docs/tasks/backlog"
    "$PROJECT_ROOT/docs/tasks/next"
    "$PROJECT_ROOT/docs/tasks/working"
    "$PROJECT_ROOT/docs/tasks/review"
    "$PROJECT_ROOT/docs/tasks/live"
)

# Options
FIX_MODE=false
DRY_RUN=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --fix)
            FIX_MODE=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --help|-h)
            echo "Usage: $0 [--fix] [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --fix       Automatically fix issues in task files"
            echo "  --dry-run   Show what would be fixed without making changes"
            echo "  --help      Show this help message"
            exit 0
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_FILES=0
VALID_FILES=0
INVALID_FILES=0
FIXED_FILES=0

echo "🔍 Validating task files..."
echo ""

validate_and_fix_task() {
    local file="$1"
    local task_id
    local filename
    local issues=()

    filename=$(basename "$file")

    # Skip template and index files
    if [[ "$filename" == "TEMPLATE"* ]] || [[ "$filename" == "INDEX.md" ]]; then
        return 0
    fi

    TOTAL_FILES=$((TOTAL_FILES + 1))

    # Extract task ID from filename
    task_id=$(echo "$filename" | cut -d'-' -f1)

    # Validate task ID is numeric
    if ! [[ "$task_id" =~ ^[0-9]+$ ]]; then
        issues+=("Invalid task ID in filename (must be numeric): $filename")
        INVALID_FILES=$((INVALID_FILES + 1))
        printf "${RED}✗${NC} %s\n" "$file"
        for issue in "${issues[@]}"; do
            printf "  ${YELLOW}⚠${NC}  %s\n" "$issue"
        done
        return 1
    fi

    # Read file content
    if [ ! -f "$file" ]; then
        issues+=("File does not exist")
        INVALID_FILES=$((INVALID_FILES + 1))
        printf "${RED}✗${NC} %s\n" "$file"
        for issue in "${issues[@]}"; do
            printf "  ${YELLOW}⚠${NC}  %s\n" "$issue"
        done
        return 1
    fi

    local content
    content=$(<"$file")

    # Check 1: Title format (# Task ID: Title)
    local title_line
    title_line=$(head -n1 "$file")

    if ! echo "$title_line" | grep -qE "^# Task [0-9]+:"; then
        issues+=("Title must start with '# Task $task_id: ' (found: $title_line)")
    fi

    # Check 2: Required fields
    if ! grep -q '^\*\*Feature\*\*:' "$file"; then
        issues+=("Missing required field: **Feature**:")
    fi

    if ! grep -qE '^## (Problem|Description|What|Overview)' "$file"; then
        issues+=("Missing required section: ## Problem (or equivalent)")
    fi

    if ! grep -qE '^## (Success criteria|Success Criteria|Testing Criteria|Desired Outcome|Acceptance Criteria)' "$file"; then
        issues+=("Missing required section: ## Success criteria (or equivalent)")
    fi

    # If no issues found, file is valid
    if [ ${#issues[@]} -eq 0 ]; then
        VALID_FILES=$((VALID_FILES + 1))
        printf "${GREEN}✓${NC} %s\n" "$file"
        return 0
    fi

    # File has issues
    INVALID_FILES=$((INVALID_FILES + 1))
    printf "${RED}✗${NC} %s\n" "$file"
    for issue in "${issues[@]}"; do
        printf "  ${YELLOW}⚠${NC}  %s\n" "$issue"
    done

    # Attempt to fix if requested
    if [ "$FIX_MODE" = true ]; then
        echo "  ${BLUE}🔧 Attempting to fix...${NC}"

        if fix_task_file "$file" "$task_id"; then
            FIXED_FILES=$((FIXED_FILES + 1))
            printf "  ${GREEN}✓${NC} Fixed\n"
        else
            printf "  ${RED}✗${NC} Could not auto-fix (manual intervention required)\n"
        fi
    fi

    return 1
}

fix_task_file() {
    local file="$1"
    local task_id="$2"
    local temp_file="${file}.tmp"
    local has_problem=false
    local has_success_criteria=false

    # Check what sections exist
    if grep -qE '^## (Problem|Description|What|Overview)' "$file"; then
        has_problem=true
    fi

    if grep -qE '^## (Success criteria|Success Criteria|Testing Criteria|Desired Outcome|Acceptance Criteria)' "$file"; then
        has_success_criteria=true
    fi

    # Get the first line (current title)
    local first_line
    first_line=$(head -n1 "$file")

    # Extract title text (remove any existing "# Task X:" prefix or just "# ")
    local title_text
    title_text=$(echo "$first_line" | sed -E 's/^# (Task [0-9]+: )?//')

    # Start building corrected file
    {
        # Fix title
        echo "# Task ${task_id}: ${title_text}"
        echo ""

        # Add Feature field if missing (insert after title, before first ## section)
        if ! grep -q '^\*\*Feature\*\*:' "$file"; then
            echo "**Feature**: none"
            echo "**Created**: $(date +%Y-%m-%d)"
            echo ""
        fi

        # Process rest of file (skip first line)
        local line_num=0
        local seen_success_criteria=false
        local in_desired_outcome=false

        while IFS= read -r line; do
            line_num=$((line_num + 1))

            # Skip the first line (title) - already handled
            if [ $line_num -eq 1 ]; then
                continue
            fi

            # Rename section variations to standard names
            if echo "$line" | grep -qE '^## (Success criteria|Success Criteria|Testing Criteria|Acceptance Criteria)$'; then
                # Only output Success criteria once
                if [ "$seen_success_criteria" = false ]; then
                    echo "## Success criteria"
                    seen_success_criteria=true
                fi
                in_desired_outcome=false
            elif echo "$line" | grep -qE '^## Desired Outcome$'; then
                # Rename Desired Outcome to Success criteria
                if [ "$seen_success_criteria" = false ]; then
                    echo "## Success criteria"
                    seen_success_criteria=true
                fi
                in_desired_outcome=true
            elif echo "$line" | grep -qE '^## (Description|What|Overview)$'; then
                echo "## Problem"
                in_desired_outcome=false
            elif echo "$line" | grep -qE '^## '; then
                # Other section - reset flags
                echo "$line"
                in_desired_outcome=false
            else
                # Regular content line
                echo "$line"
            fi
        done < "$file"

        # Add missing Problem section if needed
        if [ "$has_problem" = false ]; then
            echo ""
            echo "## Problem"
            echo "[Description of what needs to be done]"
        fi

        # Add missing Success criteria section if needed
        if [ "$has_success_criteria" = false ]; then
            echo ""
            echo "## Success criteria"
            echo "- [ ] [Add success criteria here]"
        fi

    } > "$temp_file"

    # Write fixed content
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY RUN] Would update file"
        rm "$temp_file"
        return 0
    else
        mv "$temp_file" "$file"
        return 0
    fi
}

# Process all task directories
for task_dir in "${TASK_DIRS[@]}"; do
    if [ ! -d "$task_dir" ]; then
        continue
    fi

    # Find all .md files in the directory
    for file in "$task_dir"/*.md; do
        # Skip if glob didn't match any files
        [ -e "$file" ] || continue
        validate_and_fix_task "$file" || true  # Don't exit on validation failure
    done
done

# Print summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "Total files:    %d\n" "$TOTAL_FILES"
printf "${GREEN}Valid files:    %d${NC}\n" "$VALID_FILES"
printf "${RED}Invalid files:  %d${NC}\n" "$INVALID_FILES"

if [ "$FIX_MODE" = true ]; then
    printf "${BLUE}Fixed files:    %d${NC}\n" "$FIXED_FILES"
fi

echo ""

# Exit with error code if there are invalid files
if [ "$INVALID_FILES" -gt 0 ]; then
    if [ "$FIX_MODE" = false ]; then
        echo "💡 Tip: Run with --fix to automatically correct issues"
    fi

    if [ "$FIX_MODE" = true ] && [ "$FIXED_FILES" -lt "$INVALID_FILES" ]; then
        echo "⚠️  Some files could not be auto-fixed and require manual intervention"
        exit 1
    fi

    if [ "$FIX_MODE" = false ]; then
        exit 1
    fi
fi

echo "✅ All task files are valid!"
exit 0
