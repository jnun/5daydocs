#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$SCRIPT_DIR/../lib.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# ── Parse arguments ──────────────────────────────────────────────────
MODE="prompt"
TASK_ID=""

for arg in "$@"; do
    case "$arg" in
        --work)  MODE="work" ;;
        [0-9]*)  TASK_ID="$arg" ;;
        *)
            echo -e "${RED}ERROR: Unknown argument: $arg${NC}"
            echo "Usage: ./5day.sh find <task-id> [--work]"
            exit 1
            ;;
    esac
done

if [ -z "$TASK_ID" ]; then
    echo -e "${RED}ERROR: Task ID required${NC}"
    echo "Usage: ./5day.sh find <task-id> [--work]"
    echo ""
    echo "  --work   Execute the task directly via AI (no copy/paste)"
    exit 1
fi

# ── Find the task ────────────────────────────────────────────────────
TASKS_DIR="$PROJECT_ROOT/docs/tasks"
TASK_FILE=""
TASK_STAGE=""

for stage in working next backlog review live blocked; do
    match=$(find "$TASKS_DIR/$stage" -maxdepth 1 -name "${TASK_ID}-*.md" 2>/dev/null | head -1)
    if [ -n "$match" ]; then
        TASK_FILE="$match"
        TASK_STAGE="$stage"
        break
    fi
done

if [ -z "$TASK_FILE" ]; then
    echo -e "${RED}Task $TASK_ID not found.${NC}"
    exit 1
fi

RELATIVE_PATH="${TASK_FILE#$PROJECT_ROOT/}"

case "$TASK_STAGE" in
    live)
        echo -e "${YELLOW}Task $TASK_ID is already live.${NC}"
        echo -e "${BLUE}File:${NC} $RELATIVE_PATH"
        exit 0
        ;;
    review)
        echo -e "${YELLOW}Task $TASK_ID is in review — not ready to work.${NC}"
        echo -e "${BLUE}File:${NC} $RELATIVE_PATH"
        exit 0
        ;;
esac

echo -e "${GREEN}Found task ${BOLD}$TASK_ID${NC}${GREEN} in ${CYAN}$TASK_STAGE${NC}"
echo -e "${BLUE}File:${NC} $RELATIVE_PATH"

# ── Read task content ────────────────────────────────────────────────
TASK_CONTENT="$(cat "$TASK_FILE")"

# ── Collect development rules that exist ─────────────────────────────
RULES_PATHS=""
for candidate in \
    CLAUDE.md \
    DOCUMENTATION.md \
    docs/5day/project.md \
    docs/guides/standards.md; do
    if [ -f "$PROJECT_ROOT/$candidate" ]; then
        RULES_PATHS="${RULES_PATHS}
- ${candidate}"
    fi
done

# ── Extract linked feature file from task metadata ───────────────────
FEATURE_LINE=$(echo "$TASK_CONTENT" | grep -m1 '^\*\*Feature\*\*:' || true)
FEATURE_REF=""
if [ -n "$FEATURE_LINE" ]; then
    ref=$(echo "$FEATURE_LINE" | sed 's/.*: *//' | sed 's/^[ ]*//')
    case "$ref" in
        none|multiple|"") ;;
        *)
            clean=$(echo "$ref" | sed 's|^/||')
            if [ -f "$PROJECT_ROOT/$clean" ]; then
                FEATURE_REF="$clean"
            fi
            ;;
    esac
fi

# ── Build the prompt ─────────────────────────────────────────────────
PROMPT="Complete the task at ${RELATIVE_PATH}.

TASK:
---
${TASK_CONTENT}
---

Read these before writing code:${RULES_PATHS}"

if [ -n "$FEATURE_REF" ]; then
    PROMPT="${PROMPT}
- ${FEATURE_REF} (linked feature spec)"
fi

PROMPT="${PROMPT}

Steps:
1. Read the task and every success criterion.
2. Read the development rules listed above.
3. Explore relevant code — grep and read before changing anything.
4. Implement. Change only what the task requires.
5. Test what you touched.
6. Check off each criterion in the task file.
7. Add a ## Completed section listing files changed.
8. Do not commit."

# ── Execute or display ───────────────────────────────────────────────
if [ ! -f "$PROJECT_ROOT/docs/5day/project.md" ]; then
    echo -e "${YELLOW}Tip: run ./5day.sh profile to teach AI about your project's stack${NC}"
fi

if [ "$MODE" = "work" ]; then
    echo ""
    echo -e "${CYAN}Executing task $TASK_ID...${NC}"

    MODEL="$(fiveday_resolve_model FIND)"

    local_args=()
    [ -n "$MODEL" ] && local_args+=(--model "$MODEL")

    LOG_DIR="$PROJECT_ROOT/docs/5day/tmp"
    mkdir -p "$LOG_DIR"
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    LOG_FILE="$LOG_DIR/log-find-${TASK_ID}-$TIMESTAMP.json"

    fiveday_run -p "$PROMPT" \
        ${local_args[@]+"${local_args[@]}"} \
        --tools "Read,Edit,Write,Bash,Agent,Explore" \
        --permissions "auto" \
        --output-format json > "$LOG_FILE"

    echo -e "${GREEN}Done. Log: $LOG_FILE${NC}"
else
    echo ""
    echo -e "${CYAN}─────────────────────────────────────────${NC}"
    echo -e "${BOLD}PROMPT${NC}"
    echo -e "${CYAN}─────────────────────────────────────────${NC}"
    echo ""
    echo "$PROMPT"
    echo ""
    echo -e "${CYAN}─────────────────────────────────────────${NC}"
fi
