#!/bin/bash
# ── tasks.sh ────────────────────────────────────────────────────────
# STEP 3 of 3 — Task Execution
#
# Picks up tasks from docs/tasks/next/ in order (by leading number)
# and works each one in a fresh Claude context window.
#
# For each task it:
#   - Moves the task file to working/
#   - Reads the task, reads CLAUDE.md, makes all code changes
#   - Checks off completed items, adds a ## Completed summary
#   - Moves the task file to review/
#   - Stops on failure so you can inspect
#
# Does NOT commit. You review the changes and commit yourself.
#
# Usage:
#   bash docs/5day/scripts/tasks.sh           # run all tasks in next/
#   bash docs/5day/scripts/tasks.sh 3         # run at most 3 tasks
#   bash docs/5day/scripts/tasks.sh 1         # run just the next task
#
# Full workflow:
#   bash docs/5day/scripts/sprint.sh 5        # 1. plan sprint from backlog
#   bash docs/5day/scripts/define.sh          # 2. review & triage queued tasks
#   bash docs/5day/scripts/tasks.sh           # 3. execute the sprint
#

set -euo pipefail

NEXT_DIR="docs/tasks/next"
WORKING_DIR="docs/tasks/working"
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

MODEL="$(fiveday_resolve_model FIVEDAY_MODEL_TASKS)"
TOOLS="Read,Edit,Write,Bash,Grep,Glob,Agent"
PERMISSIONS="auto"
MAX_TURNS=100

# ── Helpers ──────────────────────────────────────────────────────────

move_file() {
  git mv "$1" "$2" 2>/dev/null || mv "$1" "$2"
}

# ── Preflight ───────────────────────────────────────────────────────

if ! command -v "$FIVEDAY_CLI" &>/dev/null; then
  echo "✗ AI CLI '$FIVEDAY_CLI' not found in PATH"
  echo "  Edit docs/5day/config.sh to change FIVEDAY_CLI, or install the tool."
  echo "  Claude Code: https://docs.anthropic.com/en/docs/claude-code/overview"
  echo "  Required by: tasks.sh (task execution)"
  exit 1
fi

mkdir -p "$LOG_DIR"

for dir in "$NEXT_DIR" "$WORKING_DIR" "$REVIEW_DIR"; do
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

echo "▸ $COUNT task(s) queued from $NEXT_DIR"
echo ""

# ── Runner ──────────────────────────────────────────────────────────

COMPLETED=0
FAILED=0
INCOMPLETE=0
TOTAL_START=$SECONDS

for i in $(seq 0 $((COUNT - 1))); do
  TASK_FILE="${TASK_FILES[$i]}"
  TASK_NAME=$(basename "$TASK_FILE")
  N=$((i + 1))
  TASK_START=$SECONDS

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▸ Task $N/$COUNT: $TASK_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Move to working
  move_file "$TASK_FILE" "$WORKING_DIR/$TASK_NAME"

  # Snapshot tree state before Claude runs (for audit manifest)
  PRE_SNAPSHOT="$LOG_DIR/.pre-snapshot-$$"
  git diff --name-only > "$PRE_SNAPSHOT" 2>/dev/null || true
  git diff --cached --name-only >> "$PRE_SNAPSHOT" 2>/dev/null || true
  git ls-files --others --exclude-standard >> "$PRE_SNAPSHOT" 2>/dev/null || true

  TASK_CONTENT=$(cat "$WORKING_DIR/$TASK_NAME")

  PROMPT="You are working on a task from the project task queue.

CLAUDE.md is auto-loaded with project context and conventions.
For task workflow details, see DOCUMENTATION.md.

The task file is at: $WORKING_DIR/$TASK_NAME

Here is the task:
---
$TASK_CONTENT
---

Instructions:
1. Work through every action item in the task.
2. Make all necessary code changes. Use the Agent tool for research-heavy subtasks.
3. After making changes, run any existing tests, linters, or build/compile checks relevant to the files you modified. Fix issues before moving on.
4. If you cannot complete all action items, document what remains and why in the task file so the next person can pick it up.
5. After completing the work, update the task file: check off completed items and add a ## Completed section at the bottom summarizing what was done and any files changed.
6. Do NOT commit — just make the changes."

  # Run in fresh context
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  LOG_FILE="$LOG_DIR/log-tasks-${TASK_NAME%.md}-$TIMESTAMP.json"

  _model_args=()
  [ -n "$MODEL" ] && _model_args=(--model "$MODEL")

  if "$FIVEDAY_CLI" -p "$PROMPT" \
    "${_model_args[@]}" \
    --allowedTools "$TOOLS" \
    --permission-mode "$PERMISSIONS" \
    --max-turns "$MAX_TURNS" \
    --output-format json \
    --no-session-persistence > "$LOG_FILE"; then

    # Check for ## Completed section before promoting to review
    if grep -q '^## Completed' "$WORKING_DIR/$TASK_NAME"; then

      # ── Code Audit (fresh-context review of changes) ──────
      # Build manifest: files that changed AFTER Claude ran (subtract pre-snapshot)
      AUDIT_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/audit-code.sh"
      if [ -f "$AUDIT_SCRIPT" ]; then
        POST_SNAPSHOT="$LOG_DIR/.post-snapshot-$$"
        git diff --name-only > "$POST_SNAPSHOT" 2>/dev/null || true
        git diff --cached --name-only >> "$POST_SNAPSHOT" 2>/dev/null || true
        git ls-files --others --exclude-standard >> "$POST_SNAPSHOT" 2>/dev/null || true

        AUDIT_MANIFEST_FILE="$LOG_DIR/.audit-manifest-$$"
        # New/changed files = in post but not in pre (what THIS task changed)
        comm -23 <(sort -u "$POST_SNAPSHOT") <(sort -u "$PRE_SNAPSHOT") \
          > "$AUDIT_MANIFEST_FILE" 2>/dev/null || true

        # If manifest is empty, fall back to full post-snapshot (first task in a clean tree)
        if [ ! -s "$AUDIT_MANIFEST_FILE" ]; then
          sort -u "$POST_SNAPSHOT" | grep -v '^$' > "$AUDIT_MANIFEST_FILE" || true
        fi

        echo ""
        echo "▸ Running code audit for $TASK_NAME..."
        if AUDIT_MANIFEST="$AUDIT_MANIFEST_FILE" bash "$AUDIT_SCRIPT" "$WORKING_DIR/$TASK_NAME"; then
          echo "  ✓ Audit passed"
        else
          echo "  ⚠ Audit completed with warnings (see task file)"
        fi

        rm -f "$PRE_SNAPSHOT" "$POST_SNAPSHOT" "$AUDIT_MANIFEST_FILE"
      fi
      # ──────────────────────────────────────────────────────

      move_file "$WORKING_DIR/$TASK_NAME" "$REVIEW_DIR/$TASK_NAME"
      COMPLETED=$((COMPLETED + 1))
      echo ""
      echo "✓ Task $N complete → $REVIEW_DIR/$TASK_NAME"
    else
      INCOMPLETE=$((INCOMPLETE + 1))
      echo ""
      echo "⚠ Task $N incomplete (no ## Completed section) — left in $WORKING_DIR/$TASK_NAME"
    fi
  else
    echo ""
    echo "✗ Task $N failed — left in $WORKING_DIR/$TASK_NAME"
    FAILED=$((FAILED + 1))
    TASK_ELAPSED=$((SECONDS - TASK_START))
    echo "⏱ Elapsed: $((TASK_ELAPSED / 60))m $((TASK_ELAPSED % 60))s"
    break
  fi

  TASK_ELAPSED=$((SECONDS - TASK_START))
  echo "⏱ Elapsed: $((TASK_ELAPSED / 60))m $((TASK_ELAPSED % 60))s"
  echo ""
done

TOTAL_ELAPSED=$((SECONDS - TOTAL_START))
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▸ Done: $COMPLETED completed, $FAILED failed, $INCOMPLETE incomplete, $((COUNT - COMPLETED - FAILED - INCOMPLETE)) skipped — total $((TOTAL_ELAPSED / 60))m $((TOTAL_ELAPSED % 60))s"
