#!/bin/bash
# check-alignment.sh - Check alignment between features and their tasks
# Usage: ./docs/5day/scripts/check-alignment.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${BOLD}================================================"
echo "  Feature-Task Alignment Analysis"
echo -e "================================================${NC}\n"

# Track if we found any issues
ISSUES_FOUND=0

# Function to check feature status validity
is_valid_status() {
    case "$1" in
        BACKLOG|NEXT|WORKING|REVIEW|LIVE) return 0 ;;
        *) return 1 ;;
    esac
}

# Analyze each feature
echo -e "${CYAN}${BOLD}Analyzing Features:${NC}\n"

for feature_file in docs/features/*.md; do
    # Skip if glob didn't match, is template, or is INDEX
    [ -f "$feature_file" ] || continue
    case "$(basename "$feature_file")" in
        TEMPLATE*|INDEX.md) continue ;;
    esac

    feature_name=$(basename "$feature_file" .md)
    echo -e "${BLUE}${BOLD}Feature: ${NC}$feature_name"

    # Get feature status (look for overall status first)
    feature_status=$(grep -E "^## (Feature |Overall )?Status:" "$feature_file" 2>/dev/null | head -1 | sed 's/.*Status: *//' | tr -d '[:space:]')

    if [ -z "$feature_status" ]; then
        echo -e "  ${RED}⚠ No status found in feature file${NC}"
        ISSUES_FOUND=1
    elif ! is_valid_status "$feature_status"; then
        echo -e "  ${RED}⚠ Invalid status: $feature_status${NC}"
        ISSUES_FOUND=1
    else
        echo -e "  Status: ${BOLD}$feature_status${NC}"
    fi

    # Find all capability statuses in the feature
    echo -e "  ${CYAN}Capabilities:${NC}"
    capability_count=0

    # Read file and track capabilities properly
    prev_heading=""
    while IFS= read -r line; do
        # Track section headings
        if echo "$line" | grep -q "^## "; then
            # Skip "Feature Status" heading
            if ! echo "$line" | grep -qE "^## (Feature |Overall )?Status:"; then
                prev_heading=$(echo "$line" | sed 's/^## *//')
            fi
        # Check for capability status
        elif echo "$line" | grep -qF '**Status**:'; then
            cap_status=$(echo "$line" | sed 's/.*\*\*Status\*\*: *//' | cut -d' ' -f1)
            if [ ! -z "$prev_heading" ] && [ ! -z "$cap_status" ]; then
                capability_count=$((capability_count + 1))
                echo -e "    - $prev_heading: $cap_status"
                # Clear heading to avoid duplicate output
                prev_heading=""
            fi
        fi
    done < "$feature_file"

    if [ $capability_count -eq 0 ]; then
        echo -e "    ${YELLOW}(No individual capabilities tracked)${NC}"
    fi

    # Find related tasks
    echo -e "  ${CYAN}Related Tasks:${NC}"
    task_found=0

    # Search for tasks that reference this feature
    for task_dir in docs/tasks/{backlog,next,working,review,live}; do
        if [ -d "$task_dir" ]; then
            for task_file in "$task_dir"/*.md; do
                if [ -f "$task_file" ] && [[ ! "$task_file" == *"TEMPLATE"* ]]; then
                    # Check if task references this feature
                    if grep -q "/docs/features/$feature_name.md" "$task_file" 2>/dev/null; then
                        task_found=1
                        task_id=$(basename "$task_file" .md | cut -d'-' -f1)
                        task_title=$(grep "^# Task" "$task_file" 2>/dev/null | sed 's/# Task [0-9]*: //')
                        folder=$(basename "$task_dir")

                        echo -e "    ${GREEN}✓ Task $task_id in $folder/${NC}"
                        echo -e "      $task_title"
                    fi
                fi
            done
        fi
    done

    if [ $task_found -eq 0 ]; then
        echo -e "    ${YELLOW}(No tasks currently reference this feature)${NC}"
    fi

    echo ""
done

# Check for broken feature references (tasks pointing to non-existent feature files)
echo -e "${CYAN}${BOLD}Checking for Broken Feature References:${NC}\n"

broken_found=0
for task_dir in docs/tasks/{backlog,next,working,review,live}; do
    if [ -d "$task_dir" ]; then
        for task_file in "$task_dir"/*.md; do
            if [ -f "$task_file" ] && [[ ! "$task_file" == *"TEMPLATE"* ]]; then
                task_id=$(basename "$task_file" .md | cut -d'-' -f1)
                # Extract only the first **Feature**: line, ignoring template comments
                feature_ref=$(grep -m1 -F "**Feature**:" "$task_file" 2>/dev/null | sed 's/.*\*\*Feature\*\*: *//')

                # Skip tasks with no feature field, "none", or "multiple" — feature is optional
                if [ -z "$feature_ref" ] || [ "$feature_ref" = "none" ] || [ "$feature_ref" = "multiple" ]; then
                    continue
                fi

                # Check if the feature reference points to a file that exists
                if [[ "$feature_ref" == *"/docs/features/"* ]]; then
                    feature_basename=$(echo "$feature_ref" | sed 's/.*\/docs\/features\///' | sed 's/\.md$//')
                    if [ ! -f "docs/features/${feature_basename}.md" ]; then
                        broken_found=1
                        folder=$(basename "$task_dir")
                        echo -e "  ${RED}⚠ Task $task_id in $folder/ references non-existent feature: $feature_ref${NC}"
                        ISSUES_FOUND=1
                    fi
                fi
            fi
        done
    fi
done

if [ $broken_found -eq 0 ]; then
    echo -e "  ${GREEN}✓ All feature references point to existing files${NC}\n"
fi

# Summary and recommendations
echo -e "${BOLD}================================================"
echo "  Summary & Recommendations"
echo -e "================================================${NC}\n"

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✓ No alignment issues found!${NC}\n"
else
    echo -e "${RED}⚠ Issues found that need attention — see warnings above.${NC}\n"
fi

echo -e "${CYAN}Best Practices:${NC}"
echo "• Feature Status = highest completed capability state"
echo "• Tasks are temporary work items, features are permanent"
echo "• A LIVE feature can still have backlog tasks for enhancements"
echo "• The Feature field on tasks is optional — not every task belongs to a feature"

# Exit with error only when real issues exist (broken links, invalid statuses)
exit $ISSUES_FOUND