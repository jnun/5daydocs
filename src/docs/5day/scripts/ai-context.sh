#!/bin/bash
set -e
# ai-context.sh - Generate a context summary for AI agents
# Usage: ./docs/5day/scripts/ai-context.sh

# Determine project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
DOCS_DIR="$PROJECT_ROOT/docs"

echo "# Project Context Summary"
echo ""
echo "## Global State (STATE.md)"
if [ -f "$DOCS_DIR/STATE.md" ]; then
    cat "$DOCS_DIR/STATE.md"
else
    echo "STATE.md not found."
fi
echo ""

echo "## Active Tasks (Working)"
if [ -d "$DOCS_DIR/tasks/working" ]; then
    ls -1 "$DOCS_DIR/tasks/working" | grep ".md" || echo "No active tasks."
else
    echo "Working directory not found."
fi
echo ""

echo "## Up Next (Sprint Queue)"
if [ -d "$DOCS_DIR/tasks/next" ]; then
    ls -1 "$DOCS_DIR/tasks/next" | grep ".md" || echo "No tasks in queue."
else
    echo "Next directory not found."
fi
echo ""

echo "## Ideas (In Refinement)"
if [ -d "$DOCS_DIR/ideas" ]; then
    ls -1 "$DOCS_DIR/ideas" | grep ".md" | head -n 5 || echo "No ideas."
else
    echo "Ideas directory not found."
fi
echo ""

echo "## Recent Bugs"
if [ -d "$DOCS_DIR/bugs" ]; then
    ls -1 "$DOCS_DIR/bugs" | grep ".md" | head -n 5 || echo "No active bugs."
else
    echo "Bugs directory not found."
fi
echo ""

echo "## Suggested Action"
# Simple heuristic for suggestion
WORKING_COUNT=$(ls "$DOCS_DIR/tasks/working" 2>/dev/null | grep ".md" | wc -l)
NEXT_COUNT=$(ls "$DOCS_DIR/tasks/next" 2>/dev/null | grep ".md" | wc -l)

if [ "$WORKING_COUNT" -gt 0 ]; then
    echo "Focus on completing the active task in 'working/'."
elif [ "$NEXT_COUNT" -gt 0 ]; then
    echo "Pick a task from 'next/' and move it to 'working/'."
else
    echo "Check 'backlog/' for new tasks or create one."
fi
