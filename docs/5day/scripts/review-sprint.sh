#!/bin/bash
# ── review-sprint.sh ───────────────────────────────────────────────
# Review queued sprint tasks through dual-persona collaboration.
#
# Reads all tasks in docs/tasks/next/, annotates each with perspective
# checks from two personas (Platform Architect + Experience Officer),
# then reshapes the sprint as a whole.
#
# Outputs:
#   - Each task file gets a ## Sprint Review section appended
#   - docs/tmp/sprint-review.md gets the sprint-level analysis
#
# Usage:
#   bash docs/5day/scripts/review-sprint.sh
#
# After running:
#   1. Review annotations in each task file
#   2. Review sprint-review.md for reordering/restructuring
#   3. Execute any recommended file operations
#

set -euo pipefail

NEXT_DIR="docs/tasks/next"
REVIEW_FILE="docs/tmp/sprint-review.md"

# ── Config ───────────────────────────────────────────────────────────
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

MODEL="$(fiveday_resolve_model REVIEW_SPRINT)"
TOOLS="Read,Edit,Write,Bash,Grep,Glob"
PERMISSIONS="auto"
MAX_TURNS=50

# ── Preflight ───────────────────────────────────────────────────────

if ! command -v "$FIVEDAY_CLI" &>/dev/null; then
  echo "✗ AI CLI '$FIVEDAY_CLI' not found in PATH"
  echo "  Edit docs/5day/config to change CLI, or install the tool."
  echo "  Claude Code: https://docs.anthropic.com/en/docs/claude-code/overview"
  echo "  Required by: review-sprint.sh (sprint review)"
  exit 1
fi

if [ ! -d "$NEXT_DIR" ]; then
  echo "✗ Missing directory: $NEXT_DIR"
  exit 1
fi

TASK_COUNT=$(find "$NEXT_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

if [ "$TASK_COUNT" -eq 0 ]; then
  echo "No tasks in $NEXT_DIR — queue a sprint first (./5day.sh sprint)"
  exit 0
fi

mkdir -p "$(dirname "$REVIEW_FILE")"

echo "▸ Tasks in next/: $TASK_COUNT"
echo ""

# ── Build prompt ────────────────────────────────────────────────────

PROMPT="You are acting as two collaborating leaders reviewing a queued sprint:

- **Chief Platform Architect** — optimizing for backend stability, data integrity, observability, and long-term platform health.
- **Chief Experience Officer** — optimizing for end-user clarity, friction reduction, perceived performance, and trust.

**Shared goal:** review and improve the task list into a better-planned sprint where backend reliability and user experience reinforce each other rather than compete.

Read docs/5day/ai/sprint-review.md for the full review protocol, then follow it.

PROJECT CONTEXT:
CLAUDE.md is auto-loaded with project overview, tech stack, and conventions.
For task workflow details, see DOCUMENTATION.md.

SPRINT QUEUE: $TASK_COUNT tasks in $NEXT_DIR/
Read every task file. The tasks are atomic and ordered sequentially.

YOUR JOB:

**Pass 1 — Task Annotation:**
Review tasks in order, finishing each fully before moving to the next.
For each task, append a ## Sprint Review section to the task file containing:
1. Perspective check — how each persona views this task, what each would push for or push back on.
2. Tension and resolution — where the two perspectives disagree, state the tradeoff and which way it resolves, and why.

The existing task structure (Problem, Success criteria, Notes) stays untouched. Only append the new section.

If a task is too vague to annotate meaningfully, propose a sharper rewrite of the problem and success criteria in your annotation rather than inventing detail.

**Pass 2 — Sprint Reshaping:**
After every task is annotated, review the full sprint as a unit. Write your analysis to $REVIEW_FILE with:

1. **Sprint assessment** — overall coherence, risk areas, dependency gaps.
2. **Recommended changes** — merge, split, reorder, rewrite, cut, or defer. For each change, state what changed and why in language a human or another LLM can act on without guessing.
3. **Final task order** — the recommended sequence, with a one-line rationale per position.
4. **Commands** — shell commands to execute any file moves (git mv preferred).

If the sprint is already well-ordered and no changes are needed, say so and why.

**Style:** Write in clear, conversational prose — full sentences that commit to a point, not bullet fragments that gesture at one. Read like a thoughtful colleague explaining their reasoning.

**Operating principle:** We practice LEAN, but the goal is perfection. Tools, rules, and process serve the outcome. If following the structure above would produce a worse plan, break it and explain why."

# ── Run ─────────────────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▸ Reviewing sprint (dual-persona analysis)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

_model_args=()
[ -n "$MODEL" ] && _model_args=(--model "$MODEL")

if fiveday_run -p "$PROMPT" \
  ${_model_args[@]+"${_model_args[@]}"} \
  --tools "$TOOLS" \
  --permissions "$PERMISSIONS" \
  --max-turns "$MAX_TURNS"; then

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▸ Sprint review complete"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  Task annotations: appended ## Sprint Review to each task in $NEXT_DIR/"
  echo "  Sprint analysis:  $REVIEW_FILE"
  echo ""
  echo "Next steps:"
  echo "  1. Review the annotations in each task file"
  echo "  2. Review $REVIEW_FILE for sprint-level changes"
  echo "  3. Execute any recommended commands from the review"
else
  echo ""
  echo "✗ Sprint review failed"
  exit 1
fi
