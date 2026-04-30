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
#   bash docs/5day/scripts/tasks.sh                  # run all tasks in next/
#   bash docs/5day/scripts/tasks.sh 3                # run at most 3 tasks
#   bash docs/5day/scripts/tasks.sh 1                # run just the next task
#   bash docs/5day/scripts/tasks.sh --drift          # enable pre-task drift check
#   bash docs/5day/scripts/tasks.sh --audit          # enable post-task code audit
#   bash docs/5day/scripts/tasks.sh --parallel       # run all tasks concurrently (2 jobs)
#   bash docs/5day/scripts/tasks.sh --fast           # shorthand for --parallel with 4 jobs
#   bash docs/5day/scripts/tasks.sh --max            # no turn limit or budget cap
#   bash docs/5day/scripts/tasks.sh --fast --max     # parallel (4 jobs), no limits
#   bash docs/5day/scripts/tasks.sh --assist         # interactive mode picker
#   bash docs/5day/scripts/tasks.sh --claude         # use claude CLI profile
#   bash docs/5day/scripts/tasks.sh --openai         # use openai CLI profile
#   bash docs/5day/scripts/tasks.sh --gemini         # use gemini CLI profile
#   bash docs/5day/scripts/tasks.sh --mistral        # use mistral CLI profile
#
# Model selection is handled by docs/5day/config — scripts no longer
# hardcode model names.  Set FIVEDAY_MODEL_TASKS in your environment or
# config to override.
#
# Full workflow:
#   bash docs/5day/scripts/sprint.sh 5        # 1. plan sprint from backlog
#   bash docs/5day/scripts/define.sh          # 2. review & triage queued tasks
#   bash docs/5day/scripts/tasks.sh           # 3. execute the sprint
#

set -euo pipefail

# ── Argument parsing ────────────────────────────────────────────────
MAX_TASKS=999
PARALLEL=0
MAX_JOBS=2
FIVEDAY_SKIP_DRIFT_CHECK=1
RUN_AUDIT=0
_NO_LIMITS=0
_PROVIDER_OVERRIDE=""
_next_is_jobs=0
for arg in "$@"; do
  if [ "$_next_is_jobs" -eq 1 ]; then
    MAX_JOBS="$arg"
    _next_is_jobs=0
    continue
  fi
  case "$arg" in
    --drift)    FIVEDAY_SKIP_DRIFT_CHECK=0 ;;
    --audit)    RUN_AUDIT=1 ;;
    --parallel) PARALLEL=1 ;;
    --fast)     PARALLEL=1; MAX_JOBS=4 ;;
    --max)      _NO_LIMITS=1 ;;
    --assist)   _ASSIST=1 ;;
    --jobs)     _next_is_jobs=1 ;;
    --claude)   _PROVIDER_OVERRIDE="claude" ;;
    --openai)   _PROVIDER_OVERRIDE="openai" ;;
    --gemini)   _PROVIDER_OVERRIDE="gemini" ;;
    --mistral)  _PROVIDER_OVERRIDE="mistral" ;;
    [0-9]*)     MAX_TASKS="$arg" ;;
  esac
done
unset _next_is_jobs

# ── Interactive assist mode ─────────────────────────────────────────
if [ "${_ASSIST:-0}" -eq 1 ]; then
  echo ""
  echo "  ┌─────────────────────────────────────────┐"
  echo "  │         5DayDocs Task Runner             │"
  echo "  └─────────────────────────────────────────┘"
  echo ""
  echo "  Pick a run mode:"
  echo ""
  echo "  1) Standard              sequential"
  echo "  2) Fast parallel         --fast (4 concurrent jobs)"
  echo "  3) Full quality          --max --audit (no limits + audit)"
  echo "  4) Full quality + fast   --max --audit --fast"
  echo ""
  printf "  Choice [1-4]: "
  read -r _choice </dev/tty 2>/dev/null || _choice="1"
  echo ""
  case "$_choice" in
    1) set -- ;;
    2) set -- --fast ;;
    3) set -- --max --audit ;;
    4) set -- --max --audit --fast ;;
    *) echo "  Invalid choice, running standard."; set -- ;;
  esac

  # Re-parse the selected flags
  MAX_TASKS=999; PARALLEL=0; MAX_JOBS=2; RUN_AUDIT=0
  _NO_LIMITS=0; FIVEDAY_SKIP_DRIFT_CHECK=1
  for arg in "$@"; do
    case "$arg" in
      --drift)    FIVEDAY_SKIP_DRIFT_CHECK=0 ;;
      --audit)    RUN_AUDIT=1 ;;
      --parallel) PARALLEL=1 ;;
      --fast)     PARALLEL=1; MAX_JOBS=4 ;;
      --max)      _NO_LIMITS=1 ;;
    esac
  done
fi
unset _ASSIST

NEXT_DIR="docs/tasks/next"
WORKING_DIR="docs/tasks/working"
REVIEW_DIR="docs/tasks/review"
BLOCKED_DIR="docs/tasks/blocked"
LOG_DIR="docs/tmp"

# ── Config ───────────────────────────────────────────────────────────
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

# ── Provider flag override ─────────────────────────────────────────
# --claude/--openai/--gemini/--mistral override the CLI profile for this
# run only.  Re-source the matching profile to swap fiveday_run().
[ -n "${_PROVIDER_OVERRIDE:-}" ] && fiveday_load_profile "$_PROVIDER_OVERRIDE"
unset _PROVIDER_OVERRIDE

MODEL="$(fiveday_resolve_model TASKS)"

TOOLS="Read,Edit,Write,Bash,Grep,Glob,Agent"
PERMISSIONS="auto"
MAX_TURNS=40

# --max removes all guardrails (turn limit + budget cap)
if [ "$_NO_LIMITS" -eq 1 ]; then
  MAX_TURNS=""
  FIVEDAY_BUDGET_TASKS=""
fi
unset _NO_LIMITS

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
  echo "  Edit docs/5day/config to change CLI, or install the tool."
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

TASK_FILES=()
while IFS= read -r f; do
  TASK_FILES+=("$f")
done < <(
  ls -1 "$NEXT_DIR"/*.md 2>/dev/null \
    | sed 's|.*/||' \
    | sort -t- -k1,1n \
    | sed "s|^|$NEXT_DIR/|"
)

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
AUDIT_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/audit-code.sh"
_model_args=()
[ -n "$MODEL" ] && _model_args=(--model "$MODEL")
_turns_args=()
[ -n "$MAX_TURNS" ] && _turns_args=(--max-turns "$MAX_TURNS")
_budget_args=()
[ -n "${FIVEDAY_BUDGET_TASKS:-}" ] && _budget_args=(--budget "$FIVEDAY_BUDGET_TASKS")

trap 'echo ""; [ -n "${TASK_NAME:-}" ] && echo "▸ Interrupted — current task left in $WORKING_DIR/$TASK_NAME" || echo "▸ Interrupted"; exit 130' INT TERM

# ── Parallel runner ────────────────────────────────────────────────
if [ "$PARALLEL" -eq 1 ]; then

  # Move all tasks to working/ upfront
  TASK_NAMES=()
  for ((i=0; i<COUNT; i++)); do
    TASK_FILE="${TASK_FILES[$i]}"
    TASK_NAME="${TASK_FILE##*/}"
    TASK_NAMES+=("$TASK_NAME")
    move_file "$TASK_FILE" "$WORKING_DIR/$TASK_NAME"
  done

  # Override trap to kill background processes on interrupt
  PIDS=()
  trap 'echo ""; echo "▸ Interrupted — killing background tasks..."; for p in "${PIDS[@]}"; do kill "$p" 2>/dev/null; done; wait 2>/dev/null; echo "▸ In-progress tasks left in $WORKING_DIR/"; exit 130' INT TERM

  # Helper: launch a single task by index
  _launch_task() {
    local idx=$1
    local name="${TASK_NAMES[$idx]}"
    local content
    content=$(<"$WORKING_DIR/$name")

    local prompt="You are executing ONE task from the project queue.
CLAUDE.md is auto-loaded. Task file: $WORKING_DIR/$name

TASK:
---
$content
---

Rules:
- Change ONLY files relevant to this task.
- Grep/Glob first, read minimal code.
- Use Edit/Write for changes. Use Agent for research subtasks.
- Run only relevant tests/linters on files you touched.
- If blocked, document what remains in the task file.
- When done, check off items and add ## Completed section with files changed.
- Do NOT commit."

    local ts
    ts=$(date +%Y%m%d-%H%M%S)
    local log_file="$LOG_DIR/log-tasks-${name%.md}-$ts.json"
    local stderr_file="$LOG_DIR/stderr-tasks-${name%.md}-$ts.txt"

    echo "  ▸ Launching task $((idx + 1))/$COUNT: $name"

    fiveday_run -p "$prompt" \
      ${_model_args[@]+"${_model_args[@]}"} \
      ${_turns_args[@]+"${_turns_args[@]}"} \
      ${_budget_args[@]+"${_budget_args[@]}"} \
      --tools "$TOOLS" \
      --permissions "$PERMISSIONS" \
      --output-format json > "$log_file" 2>"$stderr_file" &
    PIDS[$idx]=$!
  }

  # Tracking arrays
  TASK_DONE=()
  EXIT_CODES=()
  for ((i=0; i<COUNT; i++)); do TASK_DONE+=(0); EXIT_CODES+=(0); PIDS+=(0); done

  # Launch initial batch
  NEXT_LAUNCH=0
  RUNNING=0
  echo "▸ Running $COUNT task(s) with --jobs $MAX_JOBS..."
  echo ""
  while [ "$NEXT_LAUNCH" -lt "$COUNT" ] && [ "$RUNNING" -lt "$MAX_JOBS" ]; do
    _launch_task "$NEXT_LAUNCH"
    NEXT_LAUNCH=$((NEXT_LAUNCH + 1))
    RUNNING=$((RUNNING + 1))
  done
  echo ""

  # Poll for completions, launch new tasks as slots open
  FINISHED=0
  while [ "$FINISHED" -lt "$COUNT" ]; do
    for ((i=0; i<COUNT; i++)); do
      if [ "${TASK_DONE[$i]}" -eq 0 ] && [ "${PIDS[$i]}" -ne 0 ] && ! kill -0 "${PIDS[$i]}" 2>/dev/null; then
        wait "${PIDS[$i]}" 2>/dev/null && EXIT_CODES[$i]=0 || EXIT_CODES[$i]=$?
        TASK_DONE[$i]=1
        FINISHED=$((FINISHED + 1))
        RUNNING=$((RUNNING - 1))
        _elapsed=$((SECONDS - TOTAL_START))
        if [ "${EXIT_CODES[$i]}" -eq 0 ]; then
          echo "  ✓ $FINISHED/$COUNT done: ${TASK_NAMES[$i]} (${_elapsed}s)"
        else
          echo "  ✗ $FINISHED/$COUNT failed: ${TASK_NAMES[$i]} (${_elapsed}s)"
        fi

        # Launch next task if any remain
        if [ "$NEXT_LAUNCH" -lt "$COUNT" ]; then
          _launch_task "$NEXT_LAUNCH"
          NEXT_LAUNCH=$((NEXT_LAUNCH + 1))
          RUNNING=$((RUNNING + 1))
        fi
      fi
    done
    [ "$FINISHED" -lt "$COUNT" ] && sleep 5
  done

  echo ""

  # Process results sequentially
  for ((i=0; i<COUNT; i++)); do
    TASK_NAME="${TASK_NAMES[$i]}"
    N=$((i + 1))
    EXIT_CODE="${EXIT_CODES[$i]}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "▸ Result $N/$COUNT: $TASK_NAME"

    if [ "$EXIT_CODE" -eq 0 ]; then
      if grep -q '^## Completed' "$WORKING_DIR/$TASK_NAME"; then

        # Run code audit (opt-in via --audit)
        if [ "$RUN_AUDIT" -eq 1 ] && [ -f "$AUDIT_SCRIPT" ]; then
          echo "  ▸ Running code audit..."
          if bash "$AUDIT_SCRIPT" "$WORKING_DIR/$TASK_NAME"; then
            echo "  ✓ Audit passed"
          else
            echo "  ⚠ Audit completed with warnings (see task file)"
          fi
        fi

        move_file "$WORKING_DIR/$TASK_NAME" "$REVIEW_DIR/$TASK_NAME"
        COMPLETED=$((COMPLETED + 1))
        echo "  ✓ Complete → $REVIEW_DIR/$TASK_NAME"
      else
        # No ## Completed — likely hit turn limit
        if [ -n "$MAX_TURNS" ]; then
          _task_num=$(echo "$TASK_NAME" | grep -oE '^[0-9]+' || echo "?")
          move_file "$WORKING_DIR/$TASK_NAME" "$BLOCKED_DIR/$TASK_NAME"
          FAILED=$((FAILED + 1))
          echo "  ✗ Task $_task_num exceeded $MAX_TURNS turns — too complex for atomic execution."
          echo "    → Moved to $BLOCKED_DIR/$TASK_NAME"
          echo "    Consider: split with ./5day.sh split, or redefine with fewer goals."
        else
          INCOMPLETE=$((INCOMPLETE + 1))
          echo "  ⚠ Incomplete (no ## Completed section) — left in $WORKING_DIR/$TASK_NAME"
        fi
      fi
    else
      # Non-zero exit — check if turn limit was hit
      if [ -n "$MAX_TURNS" ] && ! grep -q '^## Completed' "$WORKING_DIR/$TASK_NAME"; then
        _task_num=$(echo "$TASK_NAME" | grep -oE '^[0-9]+' || echo "?")
        move_file "$WORKING_DIR/$TASK_NAME" "$BLOCKED_DIR/$TASK_NAME"
        FAILED=$((FAILED + 1))
        echo "  ✗ Task $_task_num exceeded $MAX_TURNS turns — too complex for atomic execution."
        echo "    → Moved to $BLOCKED_DIR/$TASK_NAME"
        echo "    Consider: split with ./5day.sh split, or redefine with fewer goals."
      else
        FAILED=$((FAILED + 1))
        echo "  ✗ Failed (exit $EXIT_CODE) — left in $WORKING_DIR/$TASK_NAME"
      fi
    fi
    echo ""
  done

# ── Sequential runner (default) ───────────────────────────────────
else

for ((i=0; i<COUNT; i++)); do
  TASK_FILE="${TASK_FILES[$i]}"
  TASK_NAME="${TASK_FILE##*/}"
  N=$((i + 1))
  TASK_START=$SECONDS

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▸ Task $N/$COUNT: $TASK_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Move to working
  move_file "$TASK_FILE" "$WORKING_DIR/$TASK_NAME"

  TASK_CONTENT=$(<"$WORKING_DIR/$TASK_NAME")

  # ── Pre-work drift check ───────────────────────────────────────────
  # Quick check: has the codebase changed enough that this task is
  # already done or no longer relevant?  Skippable via env var.
  if [ "${FIVEDAY_SKIP_DRIFT_CHECK:-}" != "1" ]; then
    echo "  ▸ Drift check..."

    _drift_model="$(fiveday_resolve_model DRIFT)"
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

    DRIFT_VERDICT=$(run_with_timeout fiveday_run -p "$DRIFT_PROMPT" \
      "${_drift_model_args[@]}" \
      --tools "Read,Edit,Write,Grep,Glob,Bash" \
      --skip-permissions \
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
        echo "  ⚠ Drift check: task was outdated — fixes applied."
        echo ""

        # Show what the AI changed using a diff of old vs new task content
        _updated_content=$(<"$WORKING_DIR/$TASK_NAME")
        _diff_output=$(diff --unified=2 <(echo "$TASK_CONTENT") <(echo "$_updated_content") || true)
        if [ -n "$_diff_output" ]; then
          echo "  Changes made to task file:"
          echo "$_diff_output" | head -40 | sed 's/^/    /'
          echo ""
        fi

        # Show the AI's reasoning (everything before the verdict line)
        _drift_explanation=$(echo "$DRIFT_VERDICT" | sed '/^[[:space:]]*FIXED[[:space:]]*$/d' | tail -20)
        if [ -n "$_drift_explanation" ]; then
          echo "  AI reasoning:"
          echo "$_drift_explanation" | sed 's/^/    /'
          echo ""
        fi

        echo "  Updated task: $WORKING_DIR/$TASK_NAME"
        echo ""
        echo "  1) Looks good, work the task"
        echo "  2) Move to blocked for manual review"
        echo ""
        printf "  Choice [1/2] (auto-proceeds in 15s): "
        if read -r -t 15 _drift_choice </dev/tty 2>/dev/null; then
          :
        else
          _drift_choice="1"
          echo "1"
        fi
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
            TASK_CONTENT=$(<"$WORKING_DIR/$TASK_NAME")
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

  PROMPT="You are executing ONE task from the project queue.
CLAUDE.md is auto-loaded. Task file: $WORKING_DIR/$TASK_NAME

TASK:
---
$TASK_CONTENT
---

Rules:
- Change ONLY files relevant to this task.
- Grep/Glob first, read minimal code.
- Use Edit/Write for changes. Use Agent for research subtasks.
- Run only relevant tests/linters on files you touched.
- If blocked, document what remains in the task file.
- When done, check off items and add ## Completed section with files changed.
- Do NOT commit."

  # Run in fresh context
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  LOG_FILE="$LOG_DIR/log-tasks-${TASK_NAME%.md}-$TIMESTAMP.json"

  if fiveday_run -p "$PROMPT" \
    ${_model_args[@]+"${_model_args[@]}"} \
    ${_turns_args[@]+"${_turns_args[@]}"} \
    ${_budget_args[@]+"${_budget_args[@]}"} \
    --tools "$TOOLS" \
    --permissions "$PERMISSIONS" \
    --output-format json > "$LOG_FILE"; then

    # Check for ## Completed section before promoting to review
    if grep -q '^## Completed' "$WORKING_DIR/$TASK_NAME"; then

      # ── Code Audit (opt-in via --audit) ──
      if [ "$RUN_AUDIT" -eq 1 ]; then
        if [ -f "$AUDIT_SCRIPT" ]; then
          echo ""
          echo "▸ Running code audit for $TASK_NAME..."
          if bash "$AUDIT_SCRIPT" "$WORKING_DIR/$TASK_NAME"; then
            echo "  ✓ Audit passed"
          else
            echo "  ⚠ Audit completed with warnings (see task file)"
          fi
        else
          echo ""
          echo "⚠ Audit script not found: $AUDIT_SCRIPT"
          echo "  Skipping code audit — task will still be promoted"
        fi
      fi
      # ──────────────────────────────────────────────────────

      move_file "$WORKING_DIR/$TASK_NAME" "$REVIEW_DIR/$TASK_NAME"

      COMPLETED=$((COMPLETED + 1))
      echo ""
      echo "✓ Task $N complete → $REVIEW_DIR/$TASK_NAME"
    else

      # No ## Completed — likely hit turn limit
      if [ -n "$MAX_TURNS" ]; then
        _task_num=$(echo "$TASK_NAME" | grep -oE '^[0-9]+' || echo "?")
        move_file "$WORKING_DIR/$TASK_NAME" "$BLOCKED_DIR/$TASK_NAME"
        FAILED=$((FAILED + 1))
        echo ""
        echo "✗ Task $_task_num exceeded $MAX_TURNS turns — too complex for atomic execution."
        echo "  → Moved to $BLOCKED_DIR/$TASK_NAME"
        echo "  Consider: split with ./5day.sh split, or redefine with fewer goals."
      else
        INCOMPLETE=$((INCOMPLETE + 1))
        echo ""
        echo "⚠ Task $N incomplete (no ## Completed section) — left in $WORKING_DIR/$TASK_NAME"
      fi
    fi
  else
    # Non-zero exit — check if turn limit was hit
    if [ -n "$MAX_TURNS" ] && ! grep -q '^## Completed' "$WORKING_DIR/$TASK_NAME"; then
      _task_num=$(echo "$TASK_NAME" | grep -oE '^[0-9]+' || echo "?")
      move_file "$WORKING_DIR/$TASK_NAME" "$BLOCKED_DIR/$TASK_NAME"
      FAILED=$((FAILED + 1))
      echo ""
      echo "✗ Task $_task_num exceeded $MAX_TURNS turns — too complex for atomic execution."
      echo "  → Moved to $BLOCKED_DIR/$TASK_NAME"
      echo "  Consider: split with ./5day.sh split, or redefine with fewer goals."
    else
      echo ""
      echo "✗ Task $N failed — left in $WORKING_DIR/$TASK_NAME"
      FAILED=$((FAILED + 1))
    fi
    TASK_ELAPSED=$((SECONDS - TASK_START))
    echo "⏱ Elapsed: $((TASK_ELAPSED / 60))m $((TASK_ELAPSED % 60))s"
    break
  fi

  TASK_ELAPSED=$((SECONDS - TASK_START))
  echo "⏱ Elapsed: $((TASK_ELAPSED / 60))m $((TASK_ELAPSED % 60))s"
  echo ""
done

fi # end parallel/sequential branch

TOTAL_ELAPSED=$((SECONDS - TOTAL_START))
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▸ Done: $COMPLETED completed, $FAILED failed, $INCOMPLETE incomplete, $((COUNT - COMPLETED - FAILED - INCOMPLETE)) skipped — total $((TOTAL_ELAPSED / 60))m $((TOTAL_ELAPSED % 60))s"
