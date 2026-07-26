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

# ── Close-the-loop: a blocked task that talk fully defines goes straight back
# into the sprint. Only meaningful when the task is in blocked/ (that's where
# define parked it); for any other stage there is no loop to close, so this is
# empty and the closing section reads clean. A human-supervised talk is a
# stronger readiness signal than define's automated pass, so talk stamps the
# READY verdict itself instead of bouncing the task through another define run.
if [ "$STAGE" = "blocked" ]; then
  _CLOSE_LOOP_INSTR="
1b. CLOSE THE LOOP (this task is in blocked/):
define parked this task in blocked/ because it wasn't defined enough to work.
If — and ONLY if — the conversation has genuinely resolved it (no open decision
remains and it now reads as fully defined), close the loop so it can be worked:
1. Make the file END with a '## Questions' section whose first line is EXACTLY:
     **Status: READY**
   Keep the brief '### Already complete / ### Remaining work / ### Questions for
   the developer' structure under it; if nothing is open write 'None — task is
   fully defined.' Replace any earlier '## Questions' section, don't add a second.
2. DELETE any '## BLOCKED' section — it no longer applies.
3. Move it into the sprint queue:  git mv $TASK_FILE docs/tasks/next/$TASK_NAME
Then tell the user it's back in next/ and runnable with ./5day.sh tasks.
If ANY open question remains, do NONE of this: leave the file in blocked/ and say
plainly what still needs deciding."
else
  _CLOSE_LOOP_INSTR=""
fi

# ── Chain to the next dependency in a FRESH context. Defining one task often
# surfaces that it depends on another undefined task; walking that chain in THIS
# conversation piles context up and burns tokens. So we hand the next task off
# through its FILE (a durable note the fresh session reads) and start clean:
# emit mode spawns a brand-new subagent (the driving agent has a Task tool);
# exec mode can't open a window, so it prints the command for the user to run.
if [ "$(fiveday_ai_mode)" = "emit" ] && [ "$(fiveday_ai_tier)" = "claude-code" ]; then
  _CONTINUE_INSTR="Then CONTINUE THE CHAIN in a fresh context so this session's tokens don't pile up: launch a NEW subagent (Task tool) for <next-id>. Its entire instruction: 'Run ./5day.sh talk <next-id> and carry that task as far toward READY as you can on your own — read the *Context from talk* note already in its file, refine it, and if a question genuinely needs the human, leave it in the file's ## Questions section and report it back.' Tell the user you have spun up a fresh agent for <next-id> and say in one line what it is picking up."
else
  _CONTINUE_INSTR="Then, to keep each session's context small, do NOT keep going here. Tell the user the next task to define and the exact command to run in a FRESH window:  ./5day.sh talk <next-id>  — the *Context from talk* note you just wrote means that fresh session already has what it needs."
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
- Stay within the task pipeline: you may edit $TASK_FILE, any sub-task files you create via ./5day.sh newtask, and — for the handoff note described below — the file of the one next dependency you chain to. Do not touch anything else.

═══ WHEN THE TASK READS CLEARLY — FINISH, CLOSE, CHAIN ═══
Once the task in front of you (the Path B parent, or — for a split — its children) reads as fully defined, do these in order:

1. FINISH: tell the user, and show the final state (the refined task, or the list of children with the original retired).
${_CLOSE_LOOP_INSTR}

2. FIND THE NEXT TASK TO DEFINE: read this task's '**Depends on**:' line. For each dependency number N, look for docs/tasks/blocked/N-*.md or docs/tasks/backlog/N-*.md. A dependency is UNDEFINED if that file exists and does NOT contain a line '**Status: READY**'. Among the undefined dependencies, pick the most upstream one — the dependency whose OWN '**Depends on**' has no undefined dependencies left (nothing must be defined before it); break ties by lowest number. Call it <next-id>. If there are NO undefined dependencies, the chain is complete: say so and STOP — do not spawn or recommend anything.

3. HAND OFF THROUGH THE FILE: into <next-id>'s file, under its ## Notes (create the section if absent), write a short blockquote note capturing ONLY what this conversation decided that <next-id>'s author needs to know — the constraints, choices, and interface details that flow downstream. Start it exactly '> **Context from talk (task $PARENT_NUM):**' so a later run can find and replace it instead of stacking a second copy. Keep it to a few sentences; it is a seed, not a transcript.

4. CHAIN: ${_CONTINUE_INSTR}"

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
