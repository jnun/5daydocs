#!/usr/bin/env bash
# talk.sh — Talk a task through, refining it one detail at a time. See: ./5day.sh help talk

set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

# ── Args ─────────────────────────────────────────────────────────────

TASK_ID="${1:-}"

if [ -z "$TASK_ID" ]; then
  echo "Usage: ./5day.sh talk <task-id>"
  echo "  Talk an existing task through, refining it one detail at a time."
  exit 1
fi

# ── Find the task file ───────────────────────────────────────────────

if ! _RESULT="$(fiveday_find_task "$TASK_ID")"; then
  echo "Error: No task found with ID $TASK_ID in blocked/, backlog/, next/, or doing/"
  exit 1
fi
TASK_FILE="${_RESULT%%$'\t'*}"
TASK_DIR="${_RESULT##*$'\t'}"

TASK_NAME=$(basename "$TASK_FILE")
PARENT_NUM="${TASK_NAME%%-*}"
STAGE="$(basename "$TASK_DIR")"
echo "▸ Talking through: $TASK_NAME"
echo "  Location: $TASK_DIR/"
echo ""

# Interactive, reasoning-heavy review — worth the strongest model unless pinned.
_MODEL="$(fiveday_tier_model TALK)"
_model_args=()
[ -n "$_MODEL" ] && _model_args=(--model "$_MODEL")

# ── Launch the conversational review ─────────────────────────────────

_PROFILE_LINE="$(fiveday_profile_line)"

# When the user chooses to split, the original file is retired once its
# children exist. In emit mode the surrounding agent performs the delete
# (the shell can't act after an emitted prompt); in exec mode the spawned
# CLI does it inline via Bash. Same wording pattern as split.sh.
if [ "$(fiveday_ai_mode)" = "emit" ]; then
  _RETIRE_INSTR="delete it yourself: git rm $TASK_FILE   (or: rm $TASK_FILE)"
else
  _RETIRE_INSTR="delete it: git rm $TASK_FILE   (or: rm $TASK_FILE)"
fi

# newtask always creates children in backlog/. If the original is further
# along the pipeline (next/doing/blocked), the children must follow it there
# or a split silently drops the work out of that stage. Empty when the
# original is already in backlog, so the common case reads clean.
if [ "$STAGE" = "backlog" ]; then
  _STAGE_MOVE=""
else
  _STAGE_MOVE="Each child is created in backlog/, but the original lives in ${STAGE}/ — move every finished child there with 'git mv docs/tasks/backlog/<child-file> $TASK_DIR/<child-file>' so this work stays in ${STAGE}/. "
fi

APPEND_PROMPT="You are a senior engineer reviewing a task with the colleague who wrote it. They already sense it is not fully thought out and want to talk it through, one detail at a time, until it reads like a crisp, executive-summary-level brief that any developer could pick up.

The task file is at: $TASK_FILE — read it now, before you say anything.${_PROFILE_LINE}

YOUR GOAL: Through a focused back-and-forth, turn a rough task into clear, actionable work. A task that turns out to be several jobs in a trench coat gets split into small atomic sub-tasks; a task that is genuinely one job gets refined in place. Either way the result states what \"done\" looks like, names sensible technology choices with the reasoning behind them, and points to helpful references. You raise the open questions and technical decisions; the developer who later works the task makes the final call and writes the code.

STEP 0 — SIZE IT UP FIRST:
After reading the file (and skimming any code or files it references), tell the user in one or two sentences what this task really is, then make a call: is this ONE atomic piece of work (one file / one endpoint / one component), or does it bundle several distinct pieces? State which, and why. Then take the matching path below. If it is a borderline case, say so and let the user decide. And if the task is already clear and well-scoped, say so plainly and confirm with the user rather than inventing gaps — improve only what genuinely needs it.

═══ PATH A — SPLIT (the task bundles several pieces) ═══
1. PROPOSE the breakdown before creating anything: list the candidate sub-tasks (3-10, each atomic and independently completable), ordered so that dependencies come first. Ask the user to confirm or adjust the list.
2. On agreement, CREATE each sub-task with the CLI so it gets a real ID and the standard template:
     ./5day.sh newtask 'short action-oriented description'
   Then open each newly created file in docs/tasks/backlog/ and fill it in:
     - **Parent**: $PARENT_NUM   (exactly this number — it is what './5day.sh sprint N \"parent:$PARENT_NUM\"' matches to gather the children, so do not omit it)
     - **Depends on**: the previous sub-task's number when order matters, else 'none'
     - ## Problem, ## Success criteria, ## Notes — see \"WHAT A FINISHED TASK LOOKS LIKE\" below
3. TALK THROUGH each sub-task to add detail — same one-detail-at-a-time loop as Path B (ask, polish, edit, move on). Add the depth that makes each child genuinely workable; do not leave them as one-line stubs.
4. FINISH UP once its children exist and are filled in — the original's content now lives in the sub-tasks. ${_STAGE_MOVE}Then confirm with the user and retire the original: ${_RETIRE_INSTR}

═══ PATH B — REFINE IN PLACE (the task is genuinely one job) ═══
Work one detail at a time. For EACH detail:
1. ASK one question — the single most important gap right now (scope, the definition of done, an unstated technical decision, a dependency, an edge case, a security or performance concern). One question, no preamble. When a decision is open, lay out the realistic choices in a sentence or two each and say which you would lean toward and why — cite the relevant best practice and flag any performance or security implication.
2. POLISH the answer together — tighten it and read it back in a sentence: \"So the crux is …\" Let them correct you before it lands in the file.
3. UPDATE the document immediately, while the detail is fresh — one small atomic edit to the relevant section. Do not batch edits for the end.
4. MOVE to the next detail — note briefly what is settled and what still feels thin, then return to step 1.

WHAT A FINISHED TASK LOOKS LIKE (applies to the parent in Path B and to every child in Path A):
- ## Problem — 2-5 sentences: what needs to happen and why it matters.
- ## Success criteria — observable, verifiable checkboxes that together define \"done.\"
- ## Notes — technology suggestions with their rationale, decisions made, open questions left for the implementer, and references. For references, link to concrete files already in this repository (paths) and to external documentation (URLs) that would help whoever builds it. Suggest, don't mandate.

RULES:
- Keep it at an executive-summary altitude: what and why, not how. Name technologies and approaches; do NOT write code snippets or pseudo-code — that is the implementer's call.
- Ask ONE question at a time and wait for the answer.
- Edit as each detail is settled — small atomic edits, not one big rewrite at the end.
- Lead with the best practice when a question has a widely accepted one; call out security and performance trade-offs.
- Keep the conversation moving — do not parrot the user's words back at length.
- Stay within the task pipeline: you may edit $TASK_FILE and any sub-task files you create via ./5day.sh newtask. Do not touch unrelated files.
- When everything reads clearly end to end, tell the user, show the final state (the refined task, or the list of children with the original retired), and stop."

# talk is a dialogue, not a one-shot job — fiveday_run_interactive keeps the
# CLI attached to the terminal so the user answers each question in turn. In
# emit mode the surrounding agent supplies that back-and-forth. In exec mode it
# needs an interactive-capable provider on a real terminal; when that is not
# available the run degrades to a single refinement pass — say so plainly and
# point to the guide, rather than pretending the conversation happened. The
# same fiveday_interactive_ok that routes the run decides the warning, so the
# two can never disagree.
if [ "$(fiveday_ai_mode)" = "exec" ] && ! fiveday_interactive_ok; then
  echo -e "${YELLOW}Note: a live back-and-forth needs an interactive-capable AI CLI (claude) in a real terminal.${NC}"
  echo -e "${YELLOW}Doing a single refinement pass instead. To wire up the full talk experience,${NC}"
  echo -e "${YELLOW}see docs/5day/guides/use_talk.md${NC}"
  echo ""
fi

fiveday_run_interactive \
  --append-system-prompt "$APPEND_PROMPT" \
  ${_model_args[@]+"${_model_args[@]}"} \
  --tools "Read,Edit,Write,Bash,Grep,Glob" \
  --permissions "auto" \
  --name "talk-${TASK_ID}" \
  "Read the task file at $TASK_FILE, size it up, and start talking it through — one detail at a time."
