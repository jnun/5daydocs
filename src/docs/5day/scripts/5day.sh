#!/bin/bash
set -e

# 5day - Five Day Docs CLI

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$SCRIPT_DIR/docs/5day/scripts" ]; then
    PROJECT_ROOT="$SCRIPT_DIR"
else
    PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
fi

# Utility: count files matching pattern
count_files() {
    local pattern="$1"
    local count=0
    for f in $pattern; do
        [ -f "$f" ] && ((count++)) || true
    done
    echo "$count"
}

# Utility: run helper script
run_script() {
    local script="$PROJECT_ROOT/docs/5day/scripts/$1"
    shift
    if [ -x "$script" ]; then
        "$script" "$@"
    else
        echo -e "${RED}ERROR: $script not found or not executable${NC}"
        exit 1
    fi
}

show_help() {
    echo -e "${CYAN}5day - Five Day Docs CLI${NC}"
    echo ""
    echo "Usage: ./5day.sh <command> [options]"
    echo ""
    echo -e "${BLUE}Commands:${NC}"
    echo "  newidea <name>            Create a new idea to refine"
    echo "  newfeature <name>         Create a new feature"
    echo "  newtask <description>     Create a new task"
    echo "  newbug <description>      Report a new bug"
    echo "  status                    Show project status"
    echo "  checkfeatures             Analyze feature alignment"
    echo "  ai-context                Generate AI context summary"
    echo "  help                      Show this message"
    echo ""
}

cmd_newidea() {
    [ -z "$1" ] && { echo -e "${RED}ERROR: Idea name required${NC}"; exit 1; }
    run_script "create-idea.sh" "$1"
}

cmd_newtask() {
    [ -z "$1" ] && { echo -e "${RED}ERROR: Task description required${NC}"; exit 1; }
    run_script "create-task.sh" "$1"
}

cmd_newfeature() {
    [ -z "$1" ] && { echo -e "${RED}ERROR: Feature name required${NC}"; exit 1; }
    run_script "create-feature.sh" "$1"
}

cmd_newbug() {
    [ -z "$1" ] && { echo -e "${RED}ERROR: Bug description required${NC}"; exit 1; }
    run_script "create-bug.sh" "$1"
}

cmd_status() {
    echo -e "${CYAN}=== Project Status ===${NC}"
    echo ""

    cd "$PROJECT_ROOT"

    echo -e "${BLUE}Tasks:${NC}"
    echo "  Backlog:  $(count_files "docs/tasks/backlog/*.md")"
    echo "  Next:     $(count_files "docs/tasks/next/*.md")"
    echo "  Working:  $(count_files "docs/tasks/working/*.md")"
    echo "  Review:   $(count_files "docs/tasks/review/*.md")"
    echo "  Live:     $(count_files "docs/tasks/live/*.md")"

    local working_count=$(count_files "docs/tasks/working/*.md")
    if [ "$working_count" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}In progress:${NC}"
        for task in docs/tasks/working/*.md; do
            [ -f "$task" ] && echo "  $(basename "$task" .md)"
        done
    fi

    if [ -d "docs/ideas" ] && ls docs/ideas/*.md >/dev/null 2>&1; then
        echo ""
        echo -e "${BLUE}Ideas:${NC}  $(count_files "docs/ideas/*.md")"
    fi

    if [ -d "docs/bugs" ]; then
        local bug_count=$(find docs/bugs -maxdepth 1 -name "BUG-*.md" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$bug_count" -gt 0 ]; then
            echo ""
            echo -e "${BLUE}Bugs:${NC}   $bug_count open"
        fi
    fi

    if [ -d "docs/features" ] && ls docs/features/*.md >/dev/null 2>&1; then
        echo ""
        echo -e "${BLUE}Features:${NC}"
        echo "  Backlog:  $(grep -l "Status:.*BACKLOG" docs/features/*.md 2>/dev/null | wc -l | tr -d ' ')"
        echo "  Working:  $(grep -l "Status:.*WORKING" docs/features/*.md 2>/dev/null | wc -l | tr -d ' ')"
        echo "  Live:     $(grep -l "Status:.*LIVE" docs/features/*.md 2>/dev/null | wc -l | tr -d ' ')"
    fi
}

cmd_checkfeatures() {
    run_script "check-alignment.sh"
}

cmd_ai_context() {
    run_script "ai-context.sh"
}

# Main
case "${1:-}" in
    newidea)       shift; cmd_newidea "$@" ;;
    newtask)       shift; cmd_newtask "$@" ;;
    newfeature)    shift; cmd_newfeature "$@" ;;
    newbug)        shift; cmd_newbug "$@" ;;
    status)        cmd_status ;;
    checkfeatures) cmd_checkfeatures ;;
    ai-context)    cmd_ai_context ;;
    help|--help|-h|"") show_help ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac
