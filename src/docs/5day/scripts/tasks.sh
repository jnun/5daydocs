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
BLOCKED_DIR="docs/tasks/blocked"
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

# Portable timeout: macOS lacks coreutils timeout
DRIFT_TIMEOUT=120
if command -v timeout &>/dev/null; then
  run_with_timeout() { timeout "${DRIFT_TIMEOUT}s" "$@"; }
elif command -v gtimeout &>/dev/null; then
  run_with_timeout() { gtimeout "${DRIFT_TIMEOUT}s" "$@"; }
else
  run_with_timeout() {
    "$@" &
    local pid=$!
    ( sleep "$DRIFT_TIMEOUT" && kill "$pid" 2>/dev/null ) &
    local watcher=$!
    wait "$pid" 2>/dev/null
    local ret=$?
    kill "$watcher" 2>/dev/null
    pkill -P "$watcher" 2>/dev/null
    wait "$watcher" 2>/dev/null
    return $ret
  }
fi

# ── Preflight ───────────────────────────────────────────────────────

if ! command -v "$FIVEDAY_CLI" &>/dev/null; then
  echo "✗ AI CLI '$FIVEDAY_CLI' not found in PATH"
  echo "  Edit docs/5day/config.sh to change FIVEDAY_CLI, or install the tool."
  echo "  Claude Code: https://docs.anthropic.com/en/docs/claude-code/overview"
  echo "  Required by: tasks.sh (task execution)"
  exit 1
fi

mkdir -p "$LOG_DIR"

for dir in "$NEXT_DIR" "$WORKING_DIR" "$REVIEW_DIR" "$BLOCKED_DIR"; do
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

  # ── Pre-work drift check ───────────────────────────────────────────
  # Quick check: has the codebase changed enough that this task is
  # already done or no longer relevant?  Skippable via env var.
  if [ "${FIVEDAY_SKIP_DRIFT_CHECK:-}" != "1" ]; then
    echo "  ▸ Drift check..."

    _drift_model="$(fiveday_resolve_model FIVEDAY_MODEL_DRIFT)"
    _drift_model_args=()
    [ -n "$_drift_model" ] && _drift_model_args=(--model "$_drift_model")

    DRIFT_PROMPT="You are checking whether a task is still relevant before it gets worked.

CLAUDE.md is auto-loaded with project context and conventions.

Read the task file at: $WORKING_DIR/$TASK_NAME

Then check the current codebase to determine:
- Has this work ALREADY been completed? (the features/fixes described exist)
- Does the task reference files, patterns, or APIs that no longer exist?

If the task is OUTDATED, try to fix it:
- Identify what changed (renamed files, moved APIs, refactored code)
- Update the task file with corrected references and adjusted action items
- After editing the file, list the fixes you made as bullet points

Output EXACTLY ONE of these verdicts on the LAST line of your response:

DONE - The task has already been completed (nothing to do)
FIXED - The task was outdated but you updated the file with corrections
OUTDATED - The task is outdated and you cannot resolve the drift
PROCEED - The task is still relevant and ready to work

Rules:
- Be conservative: if in doubt, say PROCEED
- DONE means the specific work is clearly already present in the codebase
- FIXED means you edited the task file to account for codebase drift
- OUTDATED means the drift is too severe for you to fix — needs human rewrite
- Before your verdict, list any fixes you made as bullet points (for FIXED)"

    DRIFT_VERDICT=$(run_with_timeout "$FIVEDAY_CLI" -p "$DRIFT_PROMPT" \
      "${_drift_model_args[@]}" \
      --allowedTools "Read,Edit,Write,Grep,Glob,Bash" \
      --dangerously-skip-permissions \
      --max-turns 20 2>/dev/null) || true

    _drift_action=$(echo "$DRIFT_VERDICT" | grep -oE '\b(DONE|FIXED|OUTDATED|PROCEED)\b' | tail -1 || true)
    [ -z "$_drift_action" ] && _drift_action="PROCEED"

    case "$_drift_action" in
      DONE)
        _drift_reason=$(echo "$DRIFT_VERDICT" | grep -i 'done' | head -1)
        echo "  ✓ Drift check: already done — $_drift_reason"
        echo "    → Moving to review/"
        move_file "$WORKING_DIR/$TASK_NAME" "$REVIEW_DIR/$TASK_NAME"
        COMPLETED=$((COMPLETED + 1))
        echo ""
        continue
        ;;
      FIXED)
        echo "  ⚠ Drift check: task was outdated — fixes applied:"
        echo ""
        # Show the bullet-pointed fixes from the AI output
        echo "$DRIFT_VERDICT" | grep '^ *[-•*]' | head -20
        echo ""
        echo "  The task file has been updated: $WORKING_DIR/$TASK_NAME"
        echo ""
        echo "  1) Looks good, work the task"
        echo "  2) Move to blocked for manual review"
        echo ""
        printf "  Choice [1/2]: "
        read -r _drift_choice </dev/tty
        case "$_drift_choice" in
          2)
            echo "    → Moving to $BLOCKED_DIR/$TASK_NAME"
            move_file "$WORKING_DIR/$TASK_NAME" "$BLOCKED_DIR/$TASK_NAME"
            echo ""
            continue
            ;;
          *)
            echo "    → Proceeding with updated task"
            # Re-read the updated task content
            TASK_CONTENT=$(cat "$WORKING_DIR/$TASK_NAME")
            ;;
        esac
        ;;
      OUTDATED)
        _drift_reason=$(echo "$DRIFT_VERDICT" | grep -i 'outdated' | head -1)
        echo "  ✗ Drift check: outdated — $_drift_reason"
        echo "    → Moving to $BLOCKED_DIR/$TASK_NAME (needs human intervention)"
        move_file "$WORKING_DIR/$TASK_NAME" "$BLOCKED_DIR/$TASK_NAME"
        echo ""
        continue
        ;;
      *)
        echo "  ✓ Drift check: proceed"
        ;;
    esac
  fi
  # ────────────────────────────────────────────────────────────────────

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
