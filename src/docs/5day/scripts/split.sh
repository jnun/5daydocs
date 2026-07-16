#!/usr/bin/env bash
# split.sh — Break a large task into sub-tasks. See: ./5day.sh help split

set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

MODEL="$(fiveday_resolve_model SPLIT)"
TOOLS="Read,Bash,Grep,Glob,Edit,Write"
PERMISSIONS="auto"
MAX_TURNS=60
LOG_DIR="docs/tmp"

# ── Preflight ───────────────────────────────────────────────────────

if ! command -v "$FIVEDAY_CLI" &>/dev/null; then
  echo "✗ AI CLI '$FIVEDAY_CLI' not found in PATH"
  echo "  Edit docs/5day/config to change CLI, or install the tool."
  echo "  Claude Code: https://docs.anthropic.com/en/docs/claude-code/overview"
  echo "  Required by: split.sh (task splitting)"
  exit 1
fi

TASK_FILE="${1:-}"

if [ -z "$TASK_FILE" ]; then
  echo "Usage: bash docs/5day/scripts/split.sh <path-to-task-file>"
  echo "Example: bash docs/5day/scripts/split.sh docs/tasks/backlog/455-show-companies-and-users-to-superadmin.md"
  exit 1
fi

mkdir -p "$LOG_DIR"

if [ ! -f "$TASK_FILE" ]; then
  echo "✗ File not found: $TASK_FILE"
  exit 1
fi

TASK_NAME=$(basename "$TASK_FILE")

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▸ Splitting: $TASK_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Run ─────────────────────────────────────────────────────────────

PROMPT="You are breaking a large task into small, atomic sub-tasks.

The task file is at: $TASK_FILE
Read this file to understand the full task content.

CLAUDE.md is auto-loaded with project context and conventions.
For task workflow details, see DOCUMENTATION.md.

RULES FOR SPLITTING:
1. Understand the project context from CLAUDE.md (already loaded).
2. Read the source files referenced by the task to understand current state.
3. Each sub-task MUST be atomic — one discrete change that can be completed independently.
   Good: 'Add permission check to create_service_log endpoint'
   Bad: 'Add permission checks to service log endpoints' (that's 5+ endpoints)
4. Each sub-task should touch as few files as possible. Ideally one.
5. Sub-tasks should be ordered by dependency — if B needs A done first, A comes first.
6. Skip anything that's already done in the current code. Verify before including.
7. Keep descriptions short and action-oriented. They become task titles.
8. Aim for 3–10 sub-tasks. If you would need more than 10, split into 2–3 medium-sized
   tasks instead of many micro-tasks. Each medium task can be split again later if needed.

HOW TO CREATE SUB-TASKS:
Run this command for each sub-task:
  ./5day.sh newtask 'short description of the atomic task'

This creates a new task file in docs/tasks/backlog/ with the next available ID.

After creating all sub-tasks, read each newly created file and fill in:
- The ## Problem section (2-3 sentences, reference the parent task)
- The ## Success criteria (1-3 checkboxes, specific and verifiable)
- The ## Notes section (mention the parent task number, list which file(s) to change)
- Set **Depends on**: to the previous sub-task number if ordering matters, or 'none' if independent

The original task file will be deleted after you finish. Do NOT edit it.

After creating all sub-tasks, print a summary of what was created:
  'Created N sub-tasks from [original task title]'
  Then list each: 'Task NNN: description'"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$LOG_DIR/log-split-${TASK_NAME%.md}-$TIMESTAMP.json"

# Timestamp marker created before the run so -newer has no same-second race
SPLIT_MARKER=$(mktemp)
trap 'rm -f "$SPLIT_MARKER"' EXIT

_model_args=()
[ -n "$MODEL" ] && _model_args=(--model "$MODEL")

if fiveday_run -p "$PROMPT" \
  ${_model_args[@]+"${_model_args[@]}"} \
  --tools "$TOOLS" \
  --permissions "$PERMISSIONS" \
  --max-turns "$MAX_TURNS" \
  --output-format json > "$LOG_FILE"; then

  # Verify sub-tasks were actually created before deleting the original
  NEW_TASKS=$(find docs/tasks/backlog -maxdepth 1 -name "*.md" -newer "$SPLIT_MARKER" 2>/dev/null | wc -l | tr -d ' ')

  if [ "$NEW_TASKS" -gt 0 ]; then
    # Delete the original — it's been replaced by atomic sub-tasks
    git rm "$TASK_FILE" 2>/dev/null || rm "$TASK_FILE"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "▸ Original deleted: $TASK_FILE"
    echo "▸ $NEW_TASKS sub-tasks created in docs/tasks/backlog/"
    echo "▸ Run ./5day.sh status to see the new tasks"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠ No sub-tasks detected — original preserved at $TASK_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
  fi
else
  echo ""
  echo "✗ Split failed — original untouched at $TASK_FILE"
  exit 1
fi
