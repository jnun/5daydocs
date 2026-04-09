#!/bin/bash
# ── sprint.sh ───────────────────────────────────────────────────────
# STEP 1 of 3 — Sprint Planning
#
# Scans docs/tasks/backlog/, reads the codebase to check
# what's still relevant, and writes a sprint plan to docs/tmp/sprint-plan.md.
#
# The plan includes:
#   - Grouped tasks that form a coherent sprint
#   - Tasks flagged as already done (move straight to review/)
#   - Deferred tasks with reasons
#   - Copy-paste shell commands to queue the sprint
#
# Does NOT move any files. You review the plan first.
#
# Usage:
#   bash docs/5day/scripts/sprint.sh                # plan ~5 tasks (default)
#   bash docs/5day/scripts/sprint.sh 10             # plan ~10 tasks
#   bash docs/5day/scripts/sprint.sh 5 "security"   # plan ~5 tasks focused on security
#   bash docs/5day/scripts/sprint.sh 19 "parent:425" # plan all children of task 425
#
# The focus arg can be:
#   - A keyword:    "security", "UI", "reports"
#   - A parent ref: "parent:425" — finds all sub-tasks split from task 425
#
# After running:
#   1. Review docs/tmp/sprint-plan.md
#   2. Approve the move when prompted (or run commands from the plan manually)
#   3. Run docs/5day/scripts/define.sh to review the queued tasks
#

set -euo pipefail

BACKLOG_DIR="docs/tasks/backlog"
NEXT_DIR="docs/tasks/next"
PLAN_FILE="docs/tmp/sprint-plan.md"
SPRINT_SIZE="${1:-5}"
FOCUS="${2:-}"

# ── Config ───────────────────────────────────────────────────────────
_CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config.sh"
# shellcheck source=/dev/null
[ -f "$_CONFIG" ] && source "$_CONFIG"
: "${FIVEDAY_CLI:=claude}"
# Fallback resolver if config.sh is missing (pre-config-era installs).
# Honors the per-script var if set, else FIVEDAY_MODEL_DEFAULT, else empty.
if ! declare -F fiveday_resolve_model >/dev/null 2>&1; then
  fiveday_resolve_model() {
    local var="$1"
    if [ "${!var+set}" = "set" ]; then printf '%s' "${!var}"
    else printf '%s' "${FIVEDAY_MODEL_DEFAULT-}"; fi
  }
fi

MODEL="$(fiveday_resolve_model FIVEDAY_MODEL_SPRINT)"
TOOLS="Read,Bash,Grep,Glob,Write"
PERMISSIONS="auto"
MAX_TURNS=50

# ── Helpers ──────────────────────────────────────────────────────────

move_file() {
  git mv "$1" "$2" 2>/dev/null || mv "$1" "$2"
}

# ── Preflight ───────────────────────────────────────────────────────

if ! command -v "$FIVEDAY_CLI" &>/dev/null; then
  echo "✗ AI CLI '$FIVEDAY_CLI' not found in PATH"
  echo "  Edit docs/5day/config.sh to change FIVEDAY_CLI, or install the tool."
  echo "  Claude Code: https://docs.anthropic.com/en/docs/claude-code/overview"
  echo "  Required by: sprint.sh (sprint planning)"
  exit 1
fi

if [ ! -d "$BACKLOG_DIR" ]; then
  echo "✗ Missing directory: $BACKLOG_DIR"
  exit 1
fi

TASK_COUNT=$(find "$BACKLOG_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

if [ "$TASK_COUNT" -eq 0 ]; then
  echo "No tasks in $BACKLOG_DIR"
  exit 0
fi

# Count what's already in next/
mkdir -p "$(dirname "$PLAN_FILE")"

NEXT_COUNT=$(find "$NEXT_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo "▸ Backlog: $TASK_COUNT tasks"
echo "▸ Already in next/: $NEXT_COUNT tasks"
echo "▸ Planning sprint of ~$SPRINT_SIZE tasks${FOCUS:+ (focus: $FOCUS)}"
echo ""

# ── Build prompt ────────────────────────────────────────────────────

FOCUS_INSTRUCTION=""
CHILD_FILES=""
if [[ "$FOCUS" == parent:* ]]; then
  PARENT_ID="${FOCUS#parent:}"
  # Pre-find children so the AI doesn't have to search 300+ files
  CHILD_FILES=$(grep -rl "Task $PARENT_ID\|parent.*$PARENT_ID" "$BACKLOG_DIR"/ 2>/dev/null | sort | while read -r f; do basename "$f"; done | tr '\n' ', ') || CHILD_FILES=""
  CHILD_COUNT=$(grep -rl "Task $PARENT_ID\|parent.*$PARENT_ID" "$BACKLOG_DIR"/ 2>/dev/null | wc -l | tr -d ' ') || CHILD_COUNT=0
  FOCUS_INSTRUCTION="
PARENT TASK FILTER: This sprint is composed of sub-tasks split from parent Task $PARENT_ID.
There are $CHILD_COUNT child tasks. Here are their filenames — include ALL of them:
$CHILD_FILES

Read each of these files from $BACKLOG_DIR/. Do NOT browse other backlog tasks.
The sprint size target does not apply — include every child task listed above.
Order them in a logical sequence (dependencies first, then by area)."
elif [ -n "$FOCUS" ]; then
  FOCUS_INSTRUCTION="
FOCUS AREA: The developer wants this sprint focused on: $FOCUS
Prioritize tasks related to this area. Other tasks can be included if they're
tightly coupled or are quick wins, but the sprint should primarily advance
the focus area."
fi

PROMPT="You are a technical project manager planning the next sprint.

PROJECT CONTEXT:
CLAUDE.md is auto-loaded with project overview, tech stack, and conventions.
For task workflow details, see DOCUMENTATION.md.

BACKLOG: $TASK_COUNT tasks in $BACKLOG_DIR/
List the directory to see all task filenames, then read the ones that look promising.

ALREADY IN NEXT/ ($NEXT_COUNT tasks queued):
List $NEXT_DIR/ to see what's already queued so you don't duplicate.

TARGET SPRINT SIZE: ~$SPRINT_SIZE tasks
$FOCUS_INSTRUCTION

YOUR JOB:
1. Read CLAUDE.md to understand the project.
2. List $BACKLOG_DIR/ to see all task filenames. The filenames contain task IDs and short descriptions — use these to identify candidates.
3. Read the full content of promising tasks. Focus on higher-numbered tasks first (they're newer and more likely to be relevant). Skip the 100-series review tasks unless they're specifically relevant to the focus area.
4. Check the current codebase to verify candidates aren't already done.
5. Select ~$SPRINT_SIZE tasks that form a coherent sprint. A good sprint:
   - Groups related work (same feature area, shared files, dependent changes)
   - Respects dependency order (if task B depends on task A, A comes first)
   - Balances effort — don't pack all large tasks together
   - Includes quick wins alongside larger items when possible
   - Avoids tasks that are blocked by unresolved decisions
6. For tasks that are clearly already done, note them separately so the developer can move them straight to review/.

Write your plan to: $PLAN_FILE

FORMAT the plan file exactly like this:

# Sprint Plan — $(date +%Y-%m-%d)

## Theme
One sentence describing what this sprint accomplishes.

## Sprint Tasks (move to next/)
Ordered list of tasks to include, in the order they should be worked.

| # | Task File | Summary | Why included |
|---|-----------|---------|--------------|
| 1 | filename.md | what it does | why it fits this sprint |

## Already Done (move to review/)
Tasks from the backlog that appear to be fully implemented already.

| Task File | Evidence |
|-----------|----------|
| filename.md | brief explanation of why it's done |

## Deferred
Tasks you considered but excluded, with a one-line reason.

| Task File | Reason |
|-----------|--------|
| filename.md | why it was excluded |

## Dependencies & Risks
Any ordering constraints, shared files that multiple tasks touch, or risks.

## Commands
Shell commands to move the approved tasks:

\`\`\`bash
# Move sprint tasks to next/
git mv $BACKLOG_DIR/task-file.md $NEXT_DIR/
\`\`\`

Do NOT move any files yourself. Only write the plan to $PLAN_FILE."

# ── Run ─────────────────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▸ Planning sprint..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

_model_args=()
[ -n "$MODEL" ] && _model_args=(--model "$MODEL")

if "$FIVEDAY_CLI" -p "$PROMPT" \
  "${_model_args[@]}" \
  --allowedTools "$TOOLS" \
  --permission-mode "$PERMISSIONS" \
  --max-turns "$MAX_TURNS" \
  --no-session-persistence; then

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▸ Sprint plan written to $PLAN_FILE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Extract backlog file paths from the plan's move commands
  MOVE_SOURCES=$(sed -n '/^## Commands/,$p' "$PLAN_FILE" | grep -oE "docs/tasks/backlog/[^ ]+" 2>/dev/null | sort -u || true)

  if [ -z "$MOVE_SOURCES" ]; then
    echo "No move commands found in plan."
    exit 0
  fi

  echo ""
  echo "These tasks will be moved to $NEXT_DIR/:"
  echo ""
  echo "$MOVE_SOURCES" | while read -r src; do
    echo "  $(basename "$src")"
  done
  echo ""

  if [ -t 0 ]; then
    read -p "Move tasks to next/? (y/n) " -n 1 -r
    echo ""
  else
    REPLY="y"
  fi

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    MOVED=0
    while read -r src; do
      [ -z "$src" ] && continue
      BASENAME=$(basename "$src")
      move_file "$src" "$NEXT_DIR/$BASENAME"
      MOVED=$((MOVED + 1))
    done <<< "$MOVE_SOURCES"
    echo "▸ Moved $MOVED tasks to $NEXT_DIR/"
  else
    echo "▸ No files moved. Run the commands from $PLAN_FILE manually when ready."
  fi

else
  echo ""
  echo "✗ Sprint planning failed"
  exit 1
fi
