#!/usr/bin/env bash
# define.sh — Review and refine tasks in next/. See: ./5day.sh help define

set -euo pipefail

NEXT_DIR="docs/tasks/next"
BLOCKED_DIR="docs/tasks/blocked"
REVIEW_DIR="docs/tasks/review"
LOG_DIR="docs/tmp"
MAX_TASKS=999
FORCE=0
for _arg in "$@"; do
  case "$_arg" in
    --force)     FORCE=1 ;;
    ''|*[!0-9]*) echo "Usage: ./5day.sh define [limit] [--force]" >&2; exit 1 ;;
    *)           MAX_TASKS="$_arg" ;;
  esac
done
unset _arg

# ── Config ───────────────────────────────────────────────────────────
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

MODEL="$(fiveday_resolve_model DEFINE)"
TOOLS="Read,Bash,Grep,Glob,Edit,Write"
PERMISSIONS="auto"
MAX_TURNS=40

# ── Preflight ───────────────────────────────────────────────────────

AI_MODE="$(fiveday_ai_mode)"

# In emit mode the agent moves files itself per its verdict; fold the moves
# into the prompt. In exec mode the shell moves them by reading the verdict.
_MOVE_INSTR=""
if [ "$AI_MODE" = "emit" ]; then
  _MOVE_INSTR="

After writing the verdict, act on it:
- BLOCKED → git mv the task file to docs/tasks/blocked/
- DONE    → git mv the task file to docs/tasks/review/
- READY   → leave the file in $NEXT_DIR/"
fi

mkdir -p "$LOG_DIR"

for dir in "$NEXT_DIR" "$BLOCKED_DIR" "$REVIEW_DIR"; do
  if [ ! -d "$dir" ]; then
    echo "✗ Missing directory: $dir"
    exit 1
  fi
done

# Skip tasks that already carry a review verdict so a re-run after a partial
# failure (API error mid-batch) retries only what's missing instead of
# re-reviewing — and re-paying for — the whole queue. --force re-reviews all.
TASK_FILES=()
SKIPPED_REVIEWED=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  # Only READY skips: a BLOCKED/DONE-stamped task sitting in next/ means the
  # user re-queued it after addressing the questions — re-review it.
  if [ "$FORCE" -ne 1 ] && [ "$(fiveday_review_verdict "$f")" = "READY" ]; then
    SKIPPED_REVIEWED=$((SKIPPED_REVIEWED + 1))
    continue
  fi
  TASK_FILES+=("$f")
done < <(ls -1 "$NEXT_DIR"/*.md 2>/dev/null | sed 's|.*/||' | sort -t- -k1,1n | sed "s|^|$NEXT_DIR/|")

if [ "$SKIPPED_REVIEWED" -gt 0 ]; then
  echo "▸ Skipping $SKIPPED_REVIEWED already-reviewed task(s) — use --force to re-review"
fi

if [ ${#TASK_FILES[@]} -eq 0 ]; then
  if [ "$SKIPPED_REVIEWED" -gt 0 ]; then
    echo "All tasks in $NEXT_DIR are already reviewed"
  else
    echo "No tasks in $NEXT_DIR"
  fi
  exit 0
fi

COUNT=${#TASK_FILES[@]}
if [ "$COUNT" -gt "$MAX_TASKS" ]; then
  COUNT=$MAX_TASKS
fi

echo "▸ Reviewing $COUNT task(s) from $NEXT_DIR"
echo ""

# Profile line is task-independent — resolve it once, not per task.
_PROFILE_LINE="$(fiveday_profile_line)"

# The invariant review contract. Both the sequential per-task path and the
# claude-code parallel-subagent path build their prompt from this one source so
# the two can never drift. $1 is the task file the reviewer must read and edit.
_review_contract() {
  cat <<EOF
You are a senior developer reviewing a task before it enters a sprint.

CLAUDE.md is auto-loaded with project context and conventions.
For task workflow details, see DOCUMENTATION.md.${_PROFILE_LINE}

The task file is at: $1 — read it first.

Your job:
1. Read the task file at $1.
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
- It depends on other tasks being finished first. A dependency on other work is a
  sequencing constraint, not a definition blocker — record it and stay READY
  (see "Dependencies on other tasks" below).

A task is BLOCKED only if:
- Remaining action items require decisions the developer hasn't made yet
- Action items contradict each other or the current code
- The task is entirely done and there is nothing left to do (mark as DONE instead of BLOCKED)

Dependencies on other tasks:
Do NOT block a task merely because another task must be completed first — that is
exactly what the dependency field is for. If executing this task requires other
tasks to be finished first, ensure the task file records them in a bold
'**Depends on**:' field near the top (after the title), listing the task numbers,
e.g. '**Depends on**: 900-920, 922'. Add the field if it is missing, or update it
if it is incomplete. An unmet dependency keeps the task READY (or DONE if already
implemented): the task runner holds it in next/ until those dependencies reach
review/ or done/, then runs it automatically — no one has to babysit the order.
Reserve BLOCKED strictly for work that cannot be *defined* yet: genuine unresolved
decisions, contradictions, or missing clarifications a developer must supply. The
test is "could a developer start this if the prerequisite tasks were already
done?" — if yes, it is READY with a dependency, not BLOCKED.

Then update the task file by adding a ## Questions section at the end (before any HTML comments).
If a ## Questions section from a previous review already exists, replace it instead of adding a second one.

Structure the ## Questions section exactly like this:

## Questions

**Status: READY**

(or **Status: BLOCKED** / **Status: DONE** — write the stamp exactly in
that bold form, on its own line, directly under the ## Questions heading)

### Already complete
Items that are implemented and verified in the current code. Note any quality concerns.

### Remaining work
Summarize what's left to do. This is the actual scope for the sprint.

### Questions for the developer
Numbered list. Only include genuine questions where a decision is needed.
Each question must include a concrete suggestion with reasoning.
Format: '1. [Question]? (Suggestion: [recommendation and why])'

If there are no questions, write 'None — task is fully defined.' under this heading.

If the verdict is BLOCKED, ALSO add a '## BLOCKED' section directly above ## Questions:

## BLOCKED

One short plain-English paragraph: exactly why this task cannot proceed and what
decision or input would unblock it. Another agent (or the developer) must be able
to understand the blocker from this section alone, without reading anything else.
End the paragraph by pointing the developer to talk it through interactively:
"Run ./5day.sh talk <task-number> to resolve these questions." A BLOCKED verdict
means the work needs human definition — this is precisely what talk is for.

If the verdict is not BLOCKED, delete any ## BLOCKED section left from a previous review.

You may only use Edit/Write on the task file at $1.
EOF
}

# ── claude-code fast path: review all tasks in parallel subagents ─────
# On the claude-code tier in emit mode, dispatching one subagent per task is
# strictly faster than emitting N prompts the host agent runs one after another,
# and the reviews are independent (each touches only its own file). Other tiers
# can't fan out, and exec mode drives the CLI directly — both fall through to
# the sequential loop below. Only worth the orchestration when COUNT > 1.
if [ "$AI_MODE" = "emit" ] && [ "$(fiveday_ai_tier)" = "claude-code" ] && [ "$COUNT" -gt 1 ]; then
  _parallel_files=""
  for i in $(seq 0 $((COUNT - 1))); do
    _parallel_files="${_parallel_files}
- ${TASK_FILES[$i]}"
  done

  fiveday_run -p "You are orchestrating a parallel task-definition review of $COUNT tasks.

Dispatch ONE subagent per task file below, ALL IN PARALLEL (issue every Task
tool call in a single message). Each subagent reviews exactly one file and
follows this contract verbatim, substituting its assigned file path:

────────────────────────────────────────────────────────────
$(_review_contract "<the task file assigned to this subagent>")${_MOVE_INSTR}
────────────────────────────────────────────────────────────

Task files to review (one subagent each):${_parallel_files}

When every subagent has finished, print a summary table: one row per task with
its file name and final verdict (READY / BLOCKED / DONE)."
  echo ""
  exit 0
fi

# ── Runner ──────────────────────────────────────────────────────────

# Echo the file's ## BLOCKED section (guaranteed to exist by the routing
# below) so the reason is also visible on screen. The FILE is the record;
# this is a convenience copy for whoever is watching.
_show_blocked() {
  awk '/^## BLOCKED[[:space:]]*$/{f=1; next} f && /^## /{exit} f' "$1" \
    | head -20 | sed 's/^/    /'
}

READY=0
BLOCKED=0
DONE=0
BLOCKED_TASKS=()
ERROR_TASKS=()
TOTAL_START=$SECONDS

for i in $(seq 0 $((COUNT - 1))); do
  TASK_FILE="${TASK_FILES[$i]}"
  TASK_NAME=$(basename "$TASK_FILE")
  N=$((i + 1))
  TASK_START=$SECONDS

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▸ Review $N/$COUNT: $TASK_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  PROMPT="$(_review_contract "$NEXT_DIR/$TASK_NAME")${_MOVE_INSTR}"

  _model_args=()
  [ -n "$MODEL" ] && _model_args=(--model "$MODEL")

  # Emit mode: print the review prompt for the current agent to run.
  if [ "$AI_MODE" = "emit" ]; then
    fiveday_run -p "$PROMPT" \
      ${_model_args[@]+"${_model_args[@]}"} \
      --tools "$TOOLS" --permissions "$PERMISSIONS"
    echo ""
    continue
  fi

  LOG_FILE="$(fiveday_log_path define "$TASK_NAME")"

  if fiveday_run -p "$PROMPT" \
    ${_model_args[@]+"${_model_args[@]}"} \
    --tools "$TOOLS" \
    --permissions "$PERMISSIONS" \
    --max-turns "$MAX_TURNS" \
    --output-format json > "$LOG_FILE"; then

    # Route by the review's verdict stamp (anchored — body text that merely
    # mentions the verdict vocabulary cannot mis-route, see lib.sh).
    VERDICT="$(fiveday_review_verdict "$NEXT_DIR/$TASK_NAME")"
    case "$VERDICT" in
      BLOCKED)
        move_file "$NEXT_DIR/$TASK_NAME" "$BLOCKED_DIR/$TASK_NAME"
        BLOCKED=$((BLOCKED + 1))
        BLOCKED_TASKS+=("$TASK_NAME")
        # The reason must live IN the file — screen output is evanescent and
        # other agents can only work what is written down. If the reviewer
        # didn't write the ## BLOCKED section, synthesize one from the open
        # questions so the file stands alone.
        if ! grep -q '^## BLOCKED' "$BLOCKED_DIR/$TASK_NAME"; then
          # Extract the questions BEFORE opening the append redirection —
          # reading the file while appending to it would copy the
          # half-written section back into itself.
          _qs=$(awk '/^## Questions[[:space:]]*$/{s=""; f=1} f{s=s $0 "\n"} END{printf "%s", s}' "$BLOCKED_DIR/$TASK_NAME" \
                  | sed -n '/^### Questions for the developer/,$p' | sed '1d')
          {
            echo ""
            echo "## BLOCKED"
            echo ""
            echo "Blocked by define review on $(date +%Y-%m-%d). The open questions"
            echo "below must be answered before work can start. Talk them through"
            echo "interactively with: ./5day.sh talk ${TASK_NAME%%-*}"
            echo "$_qs"
          } >> "$BLOCKED_DIR/$TASK_NAME" \
            || echo "  ⚠ Could not write ## BLOCKED section to $BLOCKED_DIR/$TASK_NAME"
        fi
        echo ""
        echo "⊘ Blocked → $BLOCKED_DIR/$TASK_NAME"
        echo "  Why (the file's ## BLOCKED section):"
        _show_blocked "$BLOCKED_DIR/$TASK_NAME"
        echo "  Next: talk it through, or answer the questions inline, then re-queue:"
        echo "    ./5day.sh talk ${TASK_NAME%%-*}"
        echo "    git mv $BLOCKED_DIR/$TASK_NAME $NEXT_DIR/"
        ;;
      DONE)
        move_file "$NEXT_DIR/$TASK_NAME" "$REVIEW_DIR/$TASK_NAME"
        DONE=$((DONE + 1))
        echo ""
        echo "✓ Already done → $REVIEW_DIR/$TASK_NAME"
        ;;
      READY)
        READY=$((READY + 1))
        echo ""
        echo "✓ Ready — reviewed in $NEXT_DIR/$TASK_NAME"
        ;;
      *)
        ERROR_TASKS+=("$TASK_NAME → no verdict stamp, log: $LOG_FILE")
        echo ""
        echo "✗ No verdict found in $TASK_NAME — leaving in $NEXT_DIR"
        echo "  Log: $LOG_FILE"
        ;;
    esac
  else
    _cause=$(grep -oE 'API Error[^"]*' "$LOG_FILE" 2>/dev/null | tail -1 || true)
    ERROR_TASKS+=("$TASK_NAME → ${_cause:-review failed}, log: $LOG_FILE")
    echo ""
    echo "✗ Review failed for $TASK_NAME — left in $NEXT_DIR"
    [ -n "$_cause" ] && echo "  Cause: $_cause"
    echo "  Log: $LOG_FILE"
  fi

  TASK_ELAPSED=$((SECONDS - TASK_START))
  echo "⏱ Elapsed: $((TASK_ELAPSED / 60))m $((TASK_ELAPSED % 60))s"
  echo ""
done

TOTAL_ELAPSED=$((SECONDS - TOTAL_START))
ERRS=${#ERROR_TASKS[@]}
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▸ Done: $READY ready, $DONE done, $BLOCKED blocked, $ERRS errors — total $((TOTAL_ELAPSED / 60))m $((TOTAL_ELAPSED % 60))s"

if [ "$BLOCKED" -gt 0 ]; then
  echo ""
  echo "⊘ Blocked — each file's ## BLOCKED section says why:"
  for _t in ${BLOCKED_TASKS[@]+"${BLOCKED_TASKS[@]}"}; do
    echo "    $BLOCKED_DIR/$_t  (talk it through: ./5day.sh talk ${_t%%-*})"
  done
  echo "  Talk one through with ./5day.sh talk <id>, or answer inline, then: git mv <file> $NEXT_DIR/"
fi

if [ "$ERRS" -gt 0 ]; then
  echo ""
  echo "✗ Errors — these tasks were NOT reviewed and remain in $NEXT_DIR:"
  for _t in ${ERROR_TASKS[@]+"${ERROR_TASKS[@]}"}; do
    echo "    $_t"
  done
  echo "  Retry with: ./5day.sh define   (already-reviewed tasks are skipped)"
fi
