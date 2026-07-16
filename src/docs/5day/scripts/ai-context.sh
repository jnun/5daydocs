#!/usr/bin/env bash
set -euo pipefail
# ai-context.sh — Generate AI context summary. See: ./5day.sh help ai-context

# Determine project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
DOCS_DIR="$PROJECT_ROOT/docs"

_list_md() {
    local dir="$1" fallback="$2" limit="${3:-0}"
    local files
    files=$(find "$dir" -maxdepth 1 -name '*.md' -exec basename {} \; 2>/dev/null | sort)
    if [ -n "$files" ]; then
        if [ "$limit" -gt 0 ]; then echo "$files" | head -n "$limit"; else echo "$files"; fi
    else
        echo "$fallback"
    fi
}

echo "# Project Context Summary"
echo ""
echo "## Global State (DOC_STATE.md)"
if [ -f "$DOCS_DIR/5day/DOC_STATE.md" ]; then
    cat "$DOCS_DIR/5day/DOC_STATE.md"
else
    echo "DOC_STATE.md not found."
fi
echo ""

echo "## Blocked (requires attention to unblock sprint)"
if [ -d "$DOCS_DIR/tasks/blocked" ]; then
    blocked_files=$(_list_md "$DOCS_DIR/tasks/blocked" "")
    if [ -n "$blocked_files" ]; then
        echo "$blocked_files"
        echo ""
        echo "These tasks cannot be worked given current conditions — docs changed,"
        echo "dependencies shifted, or the task is undefined. They need analysis and"
        echo "resolution before the sprint can move forward."
    else
        echo "No blocked tasks."
    fi
else
    echo "No blocked tasks."
fi
echo ""

echo "## Active Tasks (Doing)"
if [ -d "$DOCS_DIR/tasks/doing" ]; then
    _list_md "$DOCS_DIR/tasks/doing" "No active tasks."
else
    echo "Doing directory not found."
fi
echo ""

echo "## Up Next (Sprint Queue)"
if [ -d "$DOCS_DIR/tasks/next" ]; then
    _list_md "$DOCS_DIR/tasks/next" "No tasks in queue."
else
    echo "Next directory not found."
fi
echo ""

echo "## Ideas (In Refinement)"
if [ -d "$DOCS_DIR/ideas" ]; then
    _list_md "$DOCS_DIR/ideas" "No ideas." 5
else
    echo "Ideas directory not found."
fi
echo ""

echo "## Recent Bugs"
if [ -d "$DOCS_DIR/bugs" ]; then
    _list_md "$DOCS_DIR/bugs" "No active bugs." 5
else
    echo "Bugs directory not found."
fi
echo ""

echo "## Suggested Action"
# Priority: blocked > doing > next > backlog
blocked_count=$(find "$DOCS_DIR/tasks/blocked" -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
doing_count=$(find "$DOCS_DIR/tasks/doing" -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
next_count=$(find "$DOCS_DIR/tasks/next" -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')

if [ "$blocked_count" -gt 0 ]; then
    echo "Blocked tasks need attention first — they are holding up the sprint."
    echo "Run './5day.sh find <task-id>' on a blocked task to analyze why it's stuck."
elif [ "$doing_count" -gt 0 ]; then
    echo "Focus on completing the active task in 'doing/'."
elif [ "$next_count" -gt 0 ]; then
    echo "Pick a task from 'next/' and move it to 'doing/'."
else
    echo "Check 'backlog/' for new tasks or create one."
fi
