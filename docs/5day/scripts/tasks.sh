#!/usr/bin/env bash
# tasks.sh — Execute tasks from next/. See: ./5day.sh help tasks

set -euo pipefail

# ── Argument parsing ────────────────────────────────────────────────
MAX_TASKS=999
PARALLEL=0
MAX_JOBS=2
FIVEDAY_SKIP_DRIFT_CHECK=1
RUN_AUDIT=0
_NO_LIMITS=0
_next_is_jobs=0
VERBOSE=0
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
    --verbose)  VERBOSE=1 ;;
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
WORKING_DIR="docs/tasks/doing"
REVIEW_DIR="docs/tasks/review"
BLOCKED_DIR="docs/tasks/blocked"
LOG_DIR="docs/tmp"

# ── Config ───────────────────────────────────────────────────────────
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

# To run one invocation against a different CLI or mode, prefix the command:
#   FIVEDAY_CLI=codex ./5day.sh tasks      (exec that CLI in a plain terminal)
#   FIVEDAY_MODE=emit ./5day.sh tasks      (force prompt emit for any agent)

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

# ── Preflight ───────────────────────────────────────────────────────
# run_with_timeout comes from lib.sh. In emit mode no CLI binary is needed;
# in exec mode fiveday_ai_mode already verified the binary exists.
DRIFT_TIMEOUT=120
AI_MODE="$(fiveday_ai_mode)"

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

if [ "$VERBOSE" -eq 1 ]; then
  for ((i=0; i<COUNT; i++)); do
    _vf="${TASK_FILES[$i]}"
    _vn="${_vf##*/}"
    echo "──────────────────────────────────────────────────────────"
    echo "  $((i + 1))/$COUNT: $_vn"
    echo "──────────────────────────────────────────────────────────"
    sed 's/^/  /' "$_vf"
    echo ""
  done
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi

# ── Runner ──────────────────────────────────────────────────────────

COMPLETED=0
FAILED=0
INCOMPLETE=0
HARD_FAIL=0
TOTAL_START=$SECONDS
AUDIT_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/audit-code.sh"

_model_args=();  [ -n "$MODEL" ] && _model_args=(--model "$MODEL")
_turns_args=();  [ -n "$MAX_TURNS" ] && _turns_args=(--max-turns "$MAX_TURNS")
_budget_args=(); [ -n "${FIVEDAY_BUDGET_TASKS:-}" ] && _budget_args=(--budget "$FIVEDAY_BUDGET_TASKS")

# Shared execution rules — used by both the exec prompt and the emit
# subagent instruction so they can't drift.
_TASK_RULES="- Change ONLY files relevant to this task.
- Grep/Glob first, read minimal code.
- Use Edit/Write for changes.
- Run only relevant tests/linters on files you touched.
- If you cannot finish, document what remains in the task file.
- When done, check off items and add a ## Completed section listing files changed.
- Do NOT commit."

# Build the execution prompt for a task file at a given path (exec mode).
_task_prompt() {
  local path="$1" content profile_line
  content=$(<"$path")
  profile_line="$(fiveday_profile_line)"
  cat <<PROMPT
You are executing ONE task from the project queue.
CLAUDE.md is auto-loaded.${profile_line}
Task file: $path

TASK:
---
$content
---

Rules:
$_TASK_RULES
PROMPT
}

# ── Emit mode: orchestrate one fresh subagent per task ───────────────
# Claude Code (or any agent with a Task/subagent tool) is the driver. Give
# it an orchestration plan: dispatch each task to a FRESH subagent so tasks
# don't share context, run them in parallel, and move each file by result.
# This mirrors exec mode's per-task isolation, natively.
if [ "$AI_MODE" = "emit" ]; then
  _profile_line="$(fiveday_profile_line)"

  _task_list=""
  for ((i=0; i<COUNT; i++)); do
    _task_list="${_task_list}
- ${TASK_FILES[$i]}"
  done

  _jobs_hint="in parallel, a few at a time"
  [ "$PARALLEL" -eq 1 ] && _jobs_hint="in parallel, up to $MAX_JOBS at a time"

  _audit_step=""
  [ "$RUN_AUDIT" -eq 1 ] && _audit_step="
   c. If it landed in review/, run: ./5day.sh review-code docs/tasks/review/<name>"

  fiveday_run -p "You are running the 5DayDocs task queue: $COUNT task(s) to execute.
CLAUDE.md is auto-loaded.${_profile_line}

Execute each task in its OWN fresh subagent (Task tool) so tasks never share
context. Dispatch them $_jobs_hint. You are the orchestrator — the subagents
do the work, you move the files.

For EACH task file listed below:
1. Move it into doing/:   git mv <path> docs/tasks/doing/
2. Launch a subagent whose entire instruction is:
     \"Execute ONE task. Read the task file at docs/tasks/doing/<name> and do the work.
$_TASK_RULES\"
3. When the subagent returns, read docs/tasks/doing/<name> and route it:
   a. contains a '## Completed' section → git mv it to docs/tasks/review/
   b. otherwise → git mv it to docs/tasks/blocked/ and note what remains${_audit_step}

Tasks (in order):$_task_list

When every task has been routed, report a one-line summary:
how many landed in review/ vs blocked/."
  exit 0
fi

# ── exec helpers (shared by sequential and parallel) ─────────────────

# Run the AI on a task already in doing/. Writes a JSON log. Returns exit code.
_run_task() {
  local name="$1" log
  log="$(fiveday_log_path tasks "$name")"
  fiveday_run -p "$(_task_prompt "$WORKING_DIR/$name")" \
    ${_model_args[@]+"${_model_args[@]}"} \
    ${_turns_args[@]+"${_turns_args[@]}"} \
    ${_budget_args[@]+"${_budget_args[@]}"} \
    --tools "$TOOLS" \
    --permissions "$PERMISSIONS" \
    --output-format json > "$log" 2>&1
}

# Route a finished task (in doing/) to review/ or blocked/, update counters.
# Args: name  exit_code
_route_result() {
  local name="$1" rc="$2" num
  if [ "$rc" -eq 0 ] && grep -q '^## Completed' "$WORKING_DIR/$name"; then
    if [ "$RUN_AUDIT" -eq 1 ] && [ -f "$AUDIT_SCRIPT" ]; then
      echo "  ▸ Running code audit..."
      if bash "$AUDIT_SCRIPT" "$WORKING_DIR/$name"; then
        echo "  ✓ Audit passed"
      else
        echo "  ⚠ Audit completed with warnings (see task file)"
      fi
    fi
    move_file "$WORKING_DIR/$name" "$REVIEW_DIR/$name"
    COMPLETED=$((COMPLETED + 1))
    echo "  ✓ Complete → $REVIEW_DIR/$name"
  elif [ -n "$MAX_TURNS" ]; then
    # No ## Completed and a turn cap was in force → too big to finish atomically.
    num=$(echo "$name" | grep -oE '^[0-9]+' || echo "?")
    move_file "$WORKING_DIR/$name" "$BLOCKED_DIR/$name"
    FAILED=$((FAILED + 1))
    echo "  ✗ Task $num exceeded $MAX_TURNS turns — too complex for atomic execution."
    echo "    → Moved to $BLOCKED_DIR/$name"
    echo "    Consider: split with ./5day.sh split, or redefine with fewer goals."
  elif [ "$rc" -eq 0 ]; then
    INCOMPLETE=$((INCOMPLETE + 1))
    echo "  ⚠ Incomplete (no ## Completed section) — left in $WORKING_DIR/$name"
  else
    FAILED=$((FAILED + 1))
    HARD_FAIL=1
    echo "  ✗ Failed (exit $rc) — left in $WORKING_DIR/$name"
  fi
}

trap 'echo ""; [ -n "${TASK_NAME:-}" ] && echo "▸ Interrupted — current task left in $WORKING_DIR/$TASK_NAME" || echo "▸ Interrupted"; exit 130' INT TERM

# ── Parallel runner ────────────────────────────────────────────────
if [ "$PARALLEL" -eq 1 ]; then

  # Move all tasks to doing/ upfront.
  TASK_NAMES=()
  for ((i=0; i<COUNT; i++)); do
    TASK_NAME="${TASK_FILES[$i]##*/}"
    TASK_NAMES+=("$TASK_NAME")
    move_file "${TASK_FILES[$i]}" "$WORKING_DIR/$TASK_NAME"
  done

  PIDS=(); EXIT_CODES=(); TASK_DONE=()
  for ((i=0; i<COUNT; i++)); do PIDS+=(0); EXIT_CODES+=(0); TASK_DONE+=(0); done

  # Kill background jobs on interrupt.
  # shellcheck disable=SC2154
  trap 'echo ""; echo "▸ Interrupted — killing background tasks..."; for p in "${PIDS[@]}"; do kill "$p" 2>/dev/null; done; wait 2>/dev/null; echo "▸ In-progress tasks left in $WORKING_DIR/"; exit 130' INT TERM

  _launch() {
    local idx="$1"
    _run_task "${TASK_NAMES[$idx]}" &
    PIDS[$idx]=$!
    echo "  ▸ Launching task $((idx + 1))/$COUNT: ${TASK_NAMES[$idx]}"
  }

  NEXT_LAUNCH=0
  RUNNING=0
  echo "▸ Running $COUNT task(s) with --jobs $MAX_JOBS..."
  echo ""
  while [ "$NEXT_LAUNCH" -lt "$COUNT" ] && [ "$RUNNING" -lt "$MAX_JOBS" ]; do
    _launch "$NEXT_LAUNCH"
    NEXT_LAUNCH=$((NEXT_LAUNCH + 1)); RUNNING=$((RUNNING + 1))
  done
  echo ""

  FINISHED=0
  while [ "$FINISHED" -lt "$COUNT" ]; do
    for ((i=0; i<COUNT; i++)); do
      if [ "${TASK_DONE[$i]}" -eq 0 ] && [ "${PIDS[$i]}" -ne 0 ] && ! kill -0 "${PIDS[$i]}" 2>/dev/null; then
        wait "${PIDS[$i]}" 2>/dev/null && EXIT_CODES[$i]=0 || EXIT_CODES[$i]=$?
        TASK_DONE[$i]=1
        FINISHED=$((FINISHED + 1)); RUNNING=$((RUNNING - 1))
        _elapsed=$((SECONDS - TOTAL_START))
        echo "  • $FINISHED/$COUNT finished: ${TASK_NAMES[$i]} (${_elapsed}s)"
        if [ "$NEXT_LAUNCH" -lt "$COUNT" ]; then
          _launch "$NEXT_LAUNCH"
          NEXT_LAUNCH=$((NEXT_LAUNCH + 1)); RUNNING=$((RUNNING + 1))
        fi
      fi
    done
    [ "$FINISHED" -lt "$COUNT" ] && sleep 5
  done
  echo ""

  # Route all results in order.
  for ((i=0; i<COUNT; i++)); do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "▸ Result $((i + 1))/$COUNT: ${TASK_NAMES[$i]}"
    _route_result "${TASK_NAMES[$i]}" "${EXIT_CODES[$i]}"
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

  move_file "$TASK_FILE" "$WORKING_DIR/$TASK_NAME"
  TASK_CONTENT=$(<"$WORKING_DIR/$TASK_NAME")

  # ── Pre-work drift check (opt-in via --drift) ──────────────────────
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

    DRIFT_VERDICT=$(run_with_timeout "$DRIFT_TIMEOUT" fiveday_run -p "$DRIFT_PROMPT" \
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
        _updated_content=$(<"$WORKING_DIR/$TASK_NAME")
        _diff_output=$(diff --unified=2 <(echo "$TASK_CONTENT") <(echo "$_updated_content") || true)
        if [ -n "$_diff_output" ]; then
          echo "  Changes made to task file:"
          echo "$_diff_output" | head -40 | sed 's/^/    /'
          echo ""
        fi
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
        if read -r -t 15 _drift_choice </dev/tty 2>/dev/null; then :; else _drift_choice="1"; echo "1"; fi
        case "$_drift_choice" in
          2)
            echo "    → Moving to $BLOCKED_DIR/$TASK_NAME"
            move_file "$WORKING_DIR/$TASK_NAME" "$BLOCKED_DIR/$TASK_NAME"
            echo ""
            continue
            ;;
          *)
            echo "    → Proceeding with updated task"
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

  _run_task "$TASK_NAME"; _rc=$?
  _route_result "$TASK_NAME" "$_rc"

  TASK_ELAPSED=$((SECONDS - TASK_START))
  echo "⏱ Elapsed: $((TASK_ELAPSED / 60))m $((TASK_ELAPSED % 60))s"
  echo ""

  # Stop the queue on a genuine crash (non-zero exit with no turn cap).
  [ "$HARD_FAIL" -eq 1 ] && break
done

fi # end parallel/sequential branch

TOTAL_ELAPSED=$((SECONDS - TOTAL_START))
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▸ Done: $COMPLETED completed, $FAILED failed, $INCOMPLETE incomplete, $((COUNT - COMPLETED - FAILED - INCOMPLETE)) skipped — total $((TOTAL_ELAPSED / 60))m $((TOTAL_ELAPSED % 60))s"
