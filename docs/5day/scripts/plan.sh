#!/usr/bin/env bash
# ── plan.sh ──────────────────────────────────────────────────────────
# Interactive Q&A session to define an incomplete or complex task.
#
# Finds a task by ID, reads it, then launches a conversational session
# that asks the user probing questions to fill in the Problem,
# Success criteria, and Notes sections — producing an actionable task.
#
# Usage:
#   bash docs/5day/scripts/plan.sh <task-id>
#   ./5day.sh plan 141
#
# After running:
#   - The task file is updated in place with a complete definition
#   - If the task was in blocked/, it moves to backlog/
#

set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

# ── Args ─────────────────────────────────────────────────────────────

TASK_ID="${1:-}"

if [ -z "$TASK_ID" ]; then
  echo "Usage: ./5day.sh plan <task-id>"
  echo "  Starts an interactive Q&A to define an incomplete task."
  exit 1
fi

# ── Find the task file ───────────────────────────────────────────────

TASK_FILE=""
TASK_DIR=""

for dir in docs/tasks/blocked docs/tasks/backlog docs/tasks/next docs/tasks/working; do
  match=$(find "$dir" -maxdepth 1 -name "${TASK_ID}-*.md" 2>/dev/null | head -1) || true
  if [ -n "$match" ]; then
    TASK_FILE="$match"
    TASK_DIR="$dir"
    break
  fi
done

if [ -z "$TASK_FILE" ]; then
  echo "Error: No task found with ID $TASK_ID in backlog/, blocked/, next/, or working/"
  exit 1
fi

TASK_NAME=$(basename "$TASK_FILE")
echo "▸ Planning: $TASK_NAME"
echo "  Location: $TASK_DIR/"
echo ""

# ── Preflight ────────────────────────────────────────────────────────

if ! command -v "$FIVEDAY_CLI" &>/dev/null; then
  echo "Error: AI CLI '$FIVEDAY_CLI' not found in PATH"
  echo "  Edit docs/5day/config to change CLI, or install the tool."
  echo "  Claude Code: https://docs.anthropic.com/en/docs/claude-code/overview"
  exit 1
fi

# Resolve model: empty string = let the CLI pick its own default.
_MODEL="$(fiveday_resolve_model PLAN)"
_model_args=()
[ -n "$_MODEL" ] && _model_args=(--model "$_MODEL")

# ── Launch interactive Q&A ───────────────────────────────────────────

APPEND_PROMPT="You are a senior developer helping a colleague define a task through conversation.

The task file is at: $TASK_FILE — read it now before saying anything.

YOUR GOAL: Through a focused Q&A conversation, gather enough information from the user to write a complete, actionable task definition. You are filling in the Problem, Success criteria, and Notes sections.

HOW TO CONDUCT THE SESSION:

1. START by reading the task file silently. Then greet the user briefly, show them the current task title, and ask:
   \"In 1-2 sentences, what does this task need to accomplish and why?\"

2. AFTER their answer, ask follow-up questions ONE AT A TIME. Each question should:
   - Target a specific gap (scope, approach, edge cases, dependencies, success criteria)
   - Include a best-practice suggestion when one exists, formatted as: \"(Best practice: [recommendation])\"
   - Be concise — no long preambles

   Good probing questions include:
   - What scripts/files/features are in scope?
   - What should happen on success? On failure?
   - Are there dependencies or ordering constraints?
   - What's the simplest version that would be useful?
   - Should this be split into smaller tasks?

3. WHEN YOU HAVE ENOUGH to write the task (typically 3-7 questions), tell the user:
   \"I have enough to write this up. Here's what I'll put in the task:\"
   Then show them the proposed Problem and Success criteria sections in a preview.

4. AFTER the user confirms (or adjusts), update the task file:
   - Fill in the ## Problem section (2-5 sentences, clear and specific)
   - Fill in the ## Success criteria with observable, verifiable checkboxes
   - Fill in ## Notes with any dependencies, edge cases, or decisions made
   - Remove the \"This task is not defined yet\" marker if present
   - Remove or update the ## Questions section to reflect the new status
   - Set the status to READY if fully defined

5. TELL the user the task has been updated and show the final state.

RULES:
- Ask ONE question at a time. Wait for the answer before asking the next.
- Keep the conversation moving — don't repeat what the user said back to them.
- When a question has a widely accepted best practice, lead with it.
- You may only edit the task file at $TASK_FILE. Do not create or modify any other files.
- Do not write code or implement the task — only define it."

fiveday_run \
  --append-system-prompt "$APPEND_PROMPT" \
  ${_model_args[@]+"${_model_args[@]}"} \
  --tools "Read,Edit,Write,Grep,Glob" \
  --name "plan-${TASK_ID}" \
  "Read the task file at $TASK_FILE and start the planning Q&A session."

# ── Post-session: move from blocked to backlog if defined ────────────

echo ""

if [ "$TASK_DIR" = "docs/tasks/blocked" ]; then
  if grep -q "This task is not defined yet" "$TASK_FILE" 2>/dev/null; then
    echo "⊘ Task still undefined — staying in blocked/"
  else
    DEST="docs/tasks/backlog/$TASK_NAME"
    git mv "$TASK_FILE" "$DEST" 2>/dev/null || mv "$TASK_FILE" "$DEST"
    echo "✓ Task defined — moved to backlog/$TASK_NAME"
  fi
fi
