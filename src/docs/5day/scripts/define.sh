#!/bin/bash
# ── define.sh ───────────────────────────────────────────────────────
# STEP 2 of 3 — Task Definition Review
#
# Reviews each task in docs/tasks/next/ against the current codebase.
# For each task it:
#   - Checks which action items are already done (and verifies quality)
#   - Identifies remaining work
#   - Asks clarifying questions with suggestions when decisions are needed
#   - Writes a ## Questions section into the task file
#
# Verdicts:
#   READY   — task stays in next/, ready for tasks.sh to execute
#   BLOCKED — task moves to blocked/, needs developer answers first
#   DONE    — task moves to review/, all work is already complete
#
# Usage:
#   bash docs/5day/scripts/define.sh          # review all tasks in next/
#   bash docs/5day/scripts/define.sh 3        # review at most 3 tasks
#   bash docs/5day/scripts/define.sh 1        # review just the next task
#
# After running:
#   - READY tasks: run docs/5day/scripts/tasks.sh to execute them
#   - BLOCKED tasks: answer questions in the file, move back to next/
#   - DONE tasks: verify in review/, then move to live/
#

set -euo pipefail

NEXT_DIR="docs/tasks/next"
BLOCKED_DIR="docs/tasks/blocked"
REVIEW_DIR="docs/tasks/review"
LOG_DIR="docs/tmp"
MAX_TASKS="${1:-999}"

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

MODEL="$(fiveday_resolve_model FIVEDAY_MODEL_DEFINE)"
TOOLS="Read,Bash,Grep,Glob,Edit,Write"
PERMISSIONS="auto"
MAX_TURNS=40

# ── Helpers ──────────────────────────────────────────────────────────

move_file() {
  git mv "$1" "$2" 2>/dev/null || mv "$1" "$2"
}

# ── Preflight ───────────────────────────────────────────────────────

if ! command -v "$FIVEDAY_CLI" &>/dev/null; then
  echo "✗ AI CLI '$FIVEDAY_CLI' not found in PATH"
  echo "  Edit docs/5day/config.sh to change FIVEDAY_CLI, or install the tool."
  echo "  Claude Code: https://docs.anthropic.com/en/docs/claude-code/overview"
  echo "  Required by: define.sh (task definition review)"
  exit 1
fi

mkdir -p "$LOG_DIR"

for dir in "$NEXT_DIR" "$BLOCKED_DIR" "$REVIEW_DIR"; do
  if [ ! -d "$dir" ]; then
    echo "✗ Missing directory: $dir"
    exit 1
  fi
done

TASK_FILES=($(ls -1 "$NEXT_DIR"/*.md 2>/dev/null | sed 's|.*/||' | sort -t- -k1,1n | sed "s|^|$NEXT_DIR/|")) || true

if [ ${#TASK_FILES[@]} -eq 0 ]; then
  echo "No tasks in $NEXT_DIR"
  exit 0
fi

COUNT=${#TASK_FILES[@]}
if [ "$COUNT" -gt "$MAX_TASKS" ]; then
  COUNT=$MAX_TASKS
fi

echo "▸ Reviewing $COUNT task(s) from $NEXT_DIR"
echo ""

# ── Runner ──────────────────────────────────────────────────────────

READY=0
BLOCKED=0
DONE=0
TOTAL_START=$SECONDS

for i in $(seq 0 $((COUNT - 1))); do
  TASK_FILE="${TASK_FILES[$i]}"
  TASK_NAME=$(basename "$TASK_FILE")
  N=$((i + 1))
  TASK_START=$SECONDS

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▸ Review $N/$COUNT: $TASK_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  PROMPT="You are a senior developer reviewing a task before it enters a sprint.

CLAUDE.md is auto-loaded with project context and conventions.
For task workflow details, see DOCUMENTATION.md.

The task file is at: $NEXT_DIR/$TASK_NAME — read it first.

Your job:
1. Read the task file at $NEXT_DIR/$TASK_NAME.
2. Read the actual source files referenced by this task. Thoroughly check the current state of the code for every action item.
3. Classify each action item into one of three categories:
   - DONE: Already implemented in the current code.
   - REMAINING: Not yet done, and the action item is clear enough to execute.
   - UNCLEAR: Not yet done, but requires a decision or clarification before work can start.
4. Produce an overall verdict: READY or BLOCKED.

How to handle DONE items:
- Do NOT suggest removing them. They are context for the developer.
- Briefly note that they're done and whether the implementation looks correct and clean.
- If the implementation has issues (bugs, missing edge cases, inelegant code), flag that as remaining work.

A task is READY if:
- There is remaining work to do
- All remaining action items are clear enough to execute without asking questions
- No major design decisions are unresolved

A task is BLOCKED only if:
- Remaining action items require decisions the developer hasn't made yet
- Action items contradict each other or the current code
- Dependencies are unmet
- The task is entirely done and there is nothing left to do (mark as DONE instead of BLOCKED)

Then update the task file by adding a ## Questions section at the end (before any HTML comments).

Structure the ## Questions section exactly like this:

## Questions

**Status: READY** (or **BLOCKED** or **DONE**)

### Already complete
Items that are implemented and verified in the current code. Note any quality concerns.

### Remaining work
Summarize what's left to do. This is the actual scope for the sprint.

### Questions for the developer
Numbered list. Only include genuine questions where a decision is needed.
Each question must include a concrete suggestion with reasoning.
Format: '1. [Question]? (Suggestion: [recommendation and why])'

If there are no questions, write 'None — task is fully defined.' under this heading.

You may only use Edit/Write on the task file at $NEXT_DIR/$TASK_NAME. Do not create or modify any other files."

  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  LOG_FILE="$LOG_DIR/log-define-${TASK_NAME%.md}-$TIMESTAMP.json"

  _model_args=()
  [ -n "$MODEL" ] && _model_args=(--model "$MODEL")

  if "$FIVEDAY_CLI" -p "$PROMPT" \
    "${_model_args[@]}" \
    --allowedTools "$TOOLS" \
    --permission-mode "$PERMISSIONS" \
    --max-turns "$MAX_TURNS" \
    --output-format json \
    --no-session-persistence > "$LOG_FILE"; then

    # Check the task file for the verdict
    if ! grep -q "Status:" "$NEXT_DIR/$TASK_NAME" 2>/dev/null; then
      echo ""
      echo "✗ No verdict found in $TASK_NAME — leaving in $NEXT_DIR"
    elif grep -q "Status: BLOCKED" "$NEXT_DIR/$TASK_NAME" 2>/dev/null; then
      move_file "$NEXT_DIR/$TASK_NAME" "$BLOCKED_DIR/$TASK_NAME"
      BLOCKED=$((BLOCKED + 1))
      echo ""
      echo "⊘ Blocked → $BLOCKED_DIR/$TASK_NAME"
    elif grep -q "Status: DONE" "$NEXT_DIR/$TASK_NAME" 2>/dev/null; then
      move_file "$NEXT_DIR/$TASK_NAME" "$REVIEW_DIR/$TASK_NAME"
      DONE=$((DONE + 1))
      echo ""
      echo "✓ Already done → $REVIEW_DIR/$TASK_NAME"
    else
      READY=$((READY + 1))
      echo ""
      echo "✓ Ready — reviewed in $NEXT_DIR/$TASK_NAME"
    fi
  else
    echo ""
    echo "✗ Review failed for $TASK_NAME — skipping"
  fi

  TASK_ELAPSED=$((SECONDS - TASK_START))
  echo "⏱ Elapsed: $((TASK_ELAPSED / 60))m $((TASK_ELAPSED % 60))s"
  echo ""
done

TOTAL_ELAPSED=$((SECONDS - TOTAL_START))
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▸ Done: $READY ready, $DONE done, $BLOCKED blocked, $((COUNT - READY - DONE - BLOCKED)) errors — total $((TOTAL_ELAPSED / 60))m $((TOTAL_ELAPSED % 60))s"
