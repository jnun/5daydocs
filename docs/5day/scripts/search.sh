#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

if [ -z "${1:-}" ]; then
    echo -e "${RED}ERROR: Search term required${NC}"
    echo "Usage: ./5day.sh search <keyword>"
    exit 1
fi

QUERY="$1"
TASKS_DIR="$PROJECT_ROOT/docs/tasks"
STAGES=(backlog next doing blocked review "done")
FOUND=0

for stage in "${STAGES[@]}"; do
    stage_dir="$TASKS_DIR/$stage"
    [ -d "$stage_dir" ] || continue

    for task_file in "$stage_dir"/*.md; do
        [ -f "$task_file" ] || continue

        basename_file="$(basename "$task_file")"

        if echo "$basename_file" | grep -qi "$QUERY" || grep -qi "$QUERY" "$task_file"; then
            task_id="${basename_file%%-*}"
            title=$(head -1 "$task_file" | sed 's/^# *//')
            echo -e "  ${BOLD}${task_id}${NC}  ${CYAN}${stage}${NC}  ${title}"
            FOUND=$((FOUND + 1))
        fi
    done
done

if [ "$FOUND" -eq 0 ]; then
    echo -e "${YELLOW}No tasks matching \"$QUERY\"${NC}"
else
    echo ""
    echo -e "${GREEN}${FOUND} task(s) found${NC}"
fi
