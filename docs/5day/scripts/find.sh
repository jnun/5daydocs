#!/usr/bin/env bash
# find.sh — Find a task by ID and optionally work it. See: ./5day.sh help find
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$SCRIPT_DIR/../lib.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# ── Parse arguments ──────────────────────────────────────────────────
MODE="prompt"
TASK_ID=""

for arg in "$@"; do
    case "$arg" in
        --work)   MODE="work" ;;
        --think)  MODE="think" ;;
        [0-9]*)   TASK_ID="$arg" ;;
        *)
            echo -e "${RED}ERROR: Unknown argument: $arg${NC}"
            echo "Usage: ./5day.sh find <task-id> [--think|--work]"
            exit 1
            ;;
    esac
done

# --think/--work still drive the CLI directly (capture + post-processing).
# Pin exec so lib.sh's emit/exec router doesn't emit for them yet; converting
# find.sh to the mode-aware model is tracked as its own task (191).
if [ "$MODE" = "work" ] || [ "$MODE" = "think" ]; then
    export FIVEDAY_MODE="${FIVEDAY_MODE:-exec}"
fi

if [ -z "$TASK_ID" ]; then
    echo -e "${RED}ERROR: Task ID required${NC}"
    echo ""
    echo "Usage: ./5day.sh find <task-id> [--think|--work]"
    echo ""
    echo "  ./5day.sh find 172          Show task location and a prompt to copy/paste"
    echo "  ./5day.sh find 172 --think  Stress-test task quality: fit, scope, criteria, risks"
    echo "  ./5day.sh find 172 --work   Full lifecycle: analyze → move → work"
    echo ""
    echo "What --work does by stage:"
    echo "  doing/next/backlog  Verify task is current, implement, move to review/"
    echo "  blocked/              Analyze why it's stuck, write action items to task file"
    echo "  review/               Verify success criteria against codebase"
    echo "  done/                 Nothing — task is already complete"
    exit 1
fi

# ── 1. Find the task ────────────────────────────────────────────────

TASKS_DIR="$PROJECT_ROOT/docs/tasks"
TASK_FILE=""
TASK_STAGE=""

for stage in doing next backlog blocked review "done"; do
    match=$(find "$TASKS_DIR/$stage" -maxdepth 1 -name "${TASK_ID}-*.md" 2>/dev/null | head -1)
    if [ -n "$match" ]; then
        TASK_FILE="$match"
        TASK_STAGE="$stage"
        break
    fi
done

if [ -z "$TASK_FILE" ]; then
    echo -e "${RED}Task $TASK_ID not found.${NC}"
    exit 1
fi

TASK_NAME="$(basename "$TASK_FILE")"
RELATIVE_PATH="${TASK_FILE#$PROJECT_ROOT/}"

echo -e "${GREEN}Found task ${BOLD}$TASK_ID${NC}${GREEN} in ${CYAN}$TASK_STAGE/${NC}"
echo -e "${BLUE}File:${NC} $RELATIVE_PATH"

if [ "$TASK_STAGE" = "done" ]; then
    echo ""
    echo -e "${YELLOW}Task $TASK_ID is already done.${NC}"
    exit 0
fi

# ── Collect context paths ────────────────────────────────────────────

RULES_PATHS=""
for candidate in \
    CLAUDE.md \
    DOCUMENTATION.md \
    docs/5day/project.md \
    docs/guides/standards.md; do
    if [ -f "$PROJECT_ROOT/$candidate" ]; then
        RULES_PATHS="${RULES_PATHS}
- ${candidate}"
    fi
done

TASK_CONTENT="$(cat "$TASK_FILE")"
FEATURE_LINE=$(echo "$TASK_CONTENT" | grep -m1 '^\*\*Feature\*\*:' || true)
FEATURE_REF=""
if [ -n "$FEATURE_LINE" ]; then
    ref=$(echo "$FEATURE_LINE" | sed 's/.*: *//' | sed 's/^[ ]*//')
    case "$ref" in
        none|multiple|"") ;;
        *)
            clean=$(echo "$ref" | sed 's|^/||')
            [ -f "$PROJECT_ROOT/$clean" ] && FEATURE_REF="$clean"
            ;;
    esac
fi

FEATURE_LINE_PROMPT=""
[ -n "$FEATURE_REF" ] && FEATURE_LINE_PROMPT="
- ${FEATURE_REF} (linked feature spec)"

# ── Prompt-only mode (no --work) ─────────────────────────────────────
# Embeds task content for copy/paste to external tools.

if [ "$MODE" = "prompt" ]; then
    PROMPT="Complete the task at ${RELATIVE_PATH}.

TASK:
---
${TASK_CONTENT}
---

Read these before writing code:${RULES_PATHS}${FEATURE_LINE_PROMPT}

Steps:
1. Read the task and every success criterion.
2. Read the development rules listed above.
3. Explore relevant code — grep and read before changing anything.
4. Implement. Change only what the task requires.
5. Test what you touched.
6. Check off each criterion in the task file.
7. Add a ## Completed section listing files changed.
8. Do not commit."

    echo ""
    echo -e "${CYAN}─────────────────────────────────────────${NC}"
    echo -e "${BOLD}PROMPT${NC}"
    echo -e "${CYAN}─────────────────────────────────────────${NC}"
    echo ""
    echo "$PROMPT"
    echo ""
    echo -e "${CYAN}─────────────────────────────────────────${NC}"
    echo ""
    echo -e "${YELLOW}Analyze first:${NC}  ./5day.sh find $TASK_ID --think"
    echo -e "${YELLOW}Execute it:${NC}    ./5day.sh find $TASK_ID --work"
    exit 0
fi

# ═════════════════════════════════════════════════════════════════════
# --think mode
#
# Interactive Q&A session to stress-test task quality before work begins.
# The AI reads the task, its linked feature, the sprint plan, sibling
# tasks, and the codebase — then conducts a focused Q&A to surface
# gaps in goal alignment, scope, criteria, assumptions, and risks.
#
# After the Q&A, the AI can tighten the task file with user approval.
# The task stays in its current folder (no movement).
# ═════════════════════════════════════════════════════════════════════

if [ "$MODE" = "think" ]; then

    MODEL="$(fiveday_resolve_model THINK)"
    _model_args=()
    [ -n "$MODEL" ] && _model_args=(--model "$MODEL")

    # ── Gather extended context paths ───────────────────────────────

    _PROFILE_LINE=""
    [ -f "$PROJECT_ROOT/docs/5day/project.md" ] && _PROFILE_LINE="
Also read docs/5day/project.md for project-specific stack and conventions."

    _SPRINT_LINE=""
    [ -f "$PROJECT_ROOT/docs/tmp/sprint-plan.md" ] && _SPRINT_LINE="
- docs/tmp/sprint-plan.md (current sprint plan — check theme and inclusion rationale)"

    _TASK_RULES_LINE=""
    [ -f "$PROJECT_ROOT/docs/5day/ai/task-creation.md" ] && _TASK_RULES_LINE="
- docs/5day/ai/task-creation.md (task creation protocol and quality standards)"

    # Collect sibling task filenames (same folder) for overlap detection
    _SIBLING_LIST=""
    _sibling_count=0
    _sibling_collected=0
    for sibling in "$TASKS_DIR/$TASK_STAGE"/*.md; do
        [ -f "$sibling" ] || continue
        _sib_name="$(basename "$sibling")"
        [ "$_sib_name" = "$TASK_NAME" ] && continue
        _sibling_count=$((_sibling_count + 1))
        if [ "$_sibling_collected" -lt 20 ]; then
            _SIBLING_LIST="${_SIBLING_LIST}
  - ${_sib_name}"
            _sibling_collected=$((_sibling_collected + 1))
        fi
    done

    _SIBLING_SECTION=""
    if [ "$_sibling_count" -gt 0 ]; then
        _sibling_label="$_sibling_count other tasks"
        [ "$_sibling_count" -gt 20 ] && _sibling_label="first 20 of $_sibling_count tasks"
        _SIBLING_SECTION="

SIBLING TASKS in $TASK_STAGE/ ($_sibling_label — scan titles for overlap):${_SIBLING_LIST}"
    fi

    # ── Build the think prompt ──────────────────────────────────────

    APPEND_PROMPT="You are a senior developer conducting a task quality review. Your role is to stress-test this task definition before work begins — find the gaps, challenge the assumptions, and sharpen the spec.

The task file is at: $RELATIVE_PATH — read it now before saying anything.${_PROFILE_LINE}

CONTEXT TO READ (read all that exist before your analysis):${RULES_PATHS}${FEATURE_LINE_PROMPT}${_SPRINT_LINE}${_TASK_RULES_LINE}
${_SIBLING_SECTION}

ANALYSIS DIMENSIONS — evaluate the task against all of these:

1. GOAL ALIGNMENT: Does this task advance its linked feature's goals? Does it fit the current sprint theme (if a sprint plan exists)? Is there a mismatch between what the task does and what the feature/sprint needs?

2. SCOPE VALIDATION: Is this the right size for a single task? Should it be split? Is it too narrow to justify its overhead? Does it overlap with sibling tasks in the same folder?

3. SUCCESS CRITERIA STRESS TEST: Are criteria verifiable by someone who didn't write the task? Are they complete — do they cover the Problem description fully? Do they miss edge cases? Are any criteria vague or subjective?

4. ASSUMPTION CHECK: What is the task taking for granted? Do referenced files, APIs, patterns, or conventions still exist in the current codebase? Are there unstated prerequisites?

5. RISK IDENTIFICATION: What could go wrong during implementation? What are the failure modes? Are there performance, security, or compatibility concerns?

6. DEPENDENCY VALIDATION: Are declared dependencies (Depends on / Blocks) real and current? Are there undeclared dependencies — other tasks or features that would need to land first?

7. ALTERNATIVE APPROACHES: Is there a simpler way to achieve the same outcome? Has the task locked in an approach prematurely?

HOW TO CONDUCT THE SESSION:

1. START by reading the task file and all available context documents silently. Then greet the user with a brief summary (2-3 sentences) of what the task is trying to accomplish, followed by your overall assessment: is it well-defined, roughly-defined, or has issues?

2. PRESENT your most important finding and ask the user about it. Frame it as a specific question, not a generic observation. Include your recommendation when you have one.

3. ASK FOLLOW-UP QUESTIONS ONE AT A TIME. Each question should:
   - Target a specific gap from the analysis dimensions above
   - Be concrete: reference specific criteria, files, or sections
   - Include a suggestion when you have one: \"(Suggestion: [recommendation and why])\"
   - Progress from most impactful to least impactful

4. TYPICAL SESSION LENGTH: 3-7 questions. Stop when:
   - The remaining findings are minor style/wording issues
   - The user signals they have enough
   - You have covered all material findings

5. AFTER THE Q&A, offer to update the task file. Tell the user:
   \"Based on our discussion, I can tighten the task. Here's what I'd change:\"
   Then show a preview of the proposed changes to Problem, Success criteria, and Notes.

6. IF THE USER APPROVES, update the task file:
   - Sharpen the Problem section based on what was discussed
   - Tighten or add Success criteria to cover gaps found
   - Update Notes with any new dependencies, edge cases, or decisions
   - Add or update a ## Think Notes section at the end (before any HTML comments) with:
     - **Reviewed**: date of this session
     - Key findings that do not fit in existing sections (risks, alternatives considered, assumptions validated)
   - Do NOT change the task's metadata (Feature, Created, Depends on, Blocks) unless the user explicitly asks
   - Do NOT add or remove the \"not defined yet\" marker — that's plan's job

7. IF THE USER DECLINES the rewrite, summarize the key findings and end.

RULES:
- Ask ONE question at a time. Wait for the answer before asking the next.
- Do not write to the task file until the user approves the rewrite.
- You may read any file in the project (for assumption checking), but only write to $RELATIVE_PATH.
- Keep your analysis grounded — cite specific criteria numbers, file paths, or section text when pointing out issues.
- Do not implement the task or write code. This is analysis only.
- The task stays in $TASK_STAGE/ regardless of outcome. Do not suggest moving it."

    echo ""
    echo -e "${CYAN}▸ Starting think session for task $TASK_ID...${NC}"
    echo -e "${BLUE}  Interactive Q&A to stress-test the task definition.${NC}"
    echo ""

    fiveday_run \
        --append-system-prompt "$APPEND_PROMPT" \
        ${_model_args[@]+"${_model_args[@]}"} \
        --tools "Read,Edit,Write,Bash,Grep,Glob" \
        --name "think-${TASK_ID}" \
        "Read the task file at $RELATIVE_PATH and all available context, then start the analysis session."

    # ── Post-session ────────────────────────────────────────────────
    echo ""
    if grep -q '^## Think Notes' "$TASK_FILE" 2>/dev/null; then
        echo -e "${GREEN}✓ Task $TASK_ID analyzed — think notes added to task file.${NC}"
    else
        echo -e "${YELLOW}Think session complete. No changes written to task file.${NC}"
    fi
    echo -e "${CYAN}  Next steps:${NC}"
    echo -e "    Review:   ./5day.sh find $TASK_ID"
    echo -e "    Redefine: ./5day.sh plan $TASK_ID"
    echo -e "    Execute:  ./5day.sh find $TASK_ID --work"
    exit 0
fi

# ═════════════════════════════════════════════════════════════════════
# --work mode
#
# One AI call per task. The prompt varies by stage. The AI reads the
# file at its current path, checks the codebase, and acts. After the
# call, the script reads signals from the task file and moves it:
#   ## Completed        → review/
#   ## Blocked Analysis → blocked/
#   neither             → stays put
# ═════════════════════════════════════════════════════════════════════

MODEL="$(fiveday_resolve_model FIND)"
_model_args=()
[ -n "$MODEL" ] && _model_args=(--model "$MODEL")

LOG_DIR="$PROJECT_ROOT/docs/tmp"
mkdir -p "$LOG_DIR"

_PROFILE_LINE=""
[ -f "$PROJECT_ROOT/docs/5day/project.md" ] && _PROFILE_LINE="
Also read docs/5day/project.md for project-specific stack and conventions."

if [ ! -f "$PROJECT_ROOT/docs/5day/project.md" ]; then
    echo -e "${YELLOW}Tip: run ./5day.sh profile to teach AI about your project's stack${NC}"
fi

# ── Build stage-specific prompt ──────────────────────────────────────
# No embedded content — the AI reads the file itself.

case "$TASK_STAGE" in

    review)
        PROMPT="You are verifying whether a task is complete.
CLAUDE.md is auto-loaded.${_PROFILE_LINE}

Read the task file at: $RELATIVE_PATH
Read these for project context:${RULES_PATHS}${FEATURE_LINE_PROMPT}

Steps:
1. Read every success criterion in the task file.
2. For each criterion, check the current codebase to verify it was implemented.
3. Report your findings: which criteria are met, which are not.
4. If ALL criteria are met: check off every criterion in the task file and add a
   '## Completed' section listing the files that satisfy them. This is the signal
   the tooling reads to confirm the task is verified — without it the task is
   treated as still open.
5. If any criteria are NOT met: do NOT add a '## Completed' section. List what
   remains directly in your report so the developer can send the task back to
   doing/."
        ;;

    blocked)
        PROMPT="This task is blocked — it can't be worked given current conditions.
CLAUDE.md is auto-loaded.${_PROFILE_LINE}

Read the task file at: $RELATIVE_PATH
Read these for project context:${RULES_PATHS}${FEATURE_LINE_PROMPT}

Your job:
1. Read the task file and understand what it's trying to accomplish.
2. Read the current codebase — check whether files, APIs, or patterns the task references still exist.
3. Determine WHY this task is blocked. Common reasons:
   - Documentation or code it depends on has changed or been removed
   - A dependency task was blocked, stopped, or changed
   - The task itself is too vague or undefined to work
   - The success criteria reference things that no longer exist
4. Write a ## Blocked Analysis section at the end of the task file (before any HTML comments) with:
   - **Why blocked**: Clear explanation of what's preventing work
   - **What changed**: Specific files, APIs, or conditions that shifted
   - **To unblock**: Concrete steps the developer needs to take
5. Summarize your findings."
        ;;

    *)
        PROMPT="You are executing a task from the project queue.
CLAUDE.md is auto-loaded.${_PROFILE_LINE}

Read the task file at: $RELATIVE_PATH
Read these before writing code:${RULES_PATHS}${FEATURE_LINE_PROMPT}

BEFORE YOU TOUCH ANY CODE, verify the task is still valid:
- Read the task and every success criterion.
- Check the current codebase: do the files, APIs, and patterns it references still exist?
- Has the work already been completed?

Based on what you find:

IF ALREADY DONE: Check off all completed criteria. Add a ## Completed section
noting the work was already in place. Stop — do not make code changes.

IF BLOCKED: The task references things that no longer exist or is too broken to work.
Write a ## Blocked Analysis section with why it's blocked, what changed, and what's
needed to unblock. Stop — do not attempt implementation.

IF WORKABLE: Implement it.
1. Read the development rules listed above.
2. Explore relevant code — grep and read before changing anything.
3. Implement. Change only what the task requires.
4. Test what you touched.
5. Check off each criterion in the task file.
6. Add a ## Completed section listing files changed.
7. Do not commit."
        ;;
esac

# ── 2. Execute ───────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}▸ Running task $TASK_ID...${NC}"

# Log path via the shared helper so naming stays consistent with define/split/
# tasks. It returns a repo-relative path; anchor it to PROJECT_ROOT to match
# find.sh's absolute-path convention.
LOG_FILE="$PROJECT_ROOT/$(fiveday_log_path find "$TASK_NAME")"

if fiveday_run -p "$PROMPT" \
    ${_model_args[@]+"${_model_args[@]}"} \
    --tools "Read,Edit,Write,Bash,Grep,Glob,Agent" \
    --permissions "auto" \
    --output-format json > "$LOG_FILE"; then
    _exit_code=0
else
    _exit_code=$?
fi

echo ""
echo -e "${BLUE}Log: $LOG_FILE${NC}"

# ── 3. Route based on signals in the task file ───────────────────────

if grep -q '^## Completed' "$TASK_FILE" 2>/dev/null; then
    # Work is done — move to review
    if [ "$TASK_STAGE" != "review" ]; then
        move_file "$TASK_FILE" "$TASKS_DIR/review/$TASK_NAME"
        echo -e "${GREEN}✓ Task $TASK_ID complete → review/$TASK_NAME${NC}"
    else
        echo -e "${GREEN}✓ Task $TASK_ID verified complete.${NC}"
    fi
    echo -e "${YELLOW}  Move to done:${NC} git mv docs/tasks/review/$TASK_NAME docs/tasks/done/"

elif grep -q '^## Blocked Analysis' "$TASK_FILE" 2>/dev/null; then
    # Task is blocked — move to blocked
    if [ "$TASK_STAGE" != "blocked" ]; then
        move_file "$TASK_FILE" "$TASKS_DIR/blocked/$TASK_NAME"
        echo -e "${YELLOW}⚠ Task $TASK_ID → blocked/$TASK_NAME${NC}"
    else
        echo -e "${YELLOW}⚠ Blocked analysis updated.${NC}"
    fi
    echo -e "${CYAN}  To redefine:${NC} ./5day.sh plan $TASK_ID"
    echo -e "${CYAN}  To unblock:${NC}  git mv docs/tasks/blocked/$TASK_NAME docs/tasks/next/"

elif [ "$TASK_STAGE" = "review" ]; then
    # Review didn't produce a clear signal
    echo -e "${YELLOW}⚠ Review complete — check findings above.${NC}"
    echo -e "${CYAN}  If done:${NC}  git mv $RELATIVE_PATH docs/tasks/done/"
    echo -e "${CYAN}  If not:${NC}  git mv $RELATIVE_PATH docs/tasks/doing/"

elif [ "$_exit_code" -ne 0 ]; then
    # AI crashed — move to blocked
    move_file "$TASK_FILE" "$TASKS_DIR/blocked/$TASK_NAME"
    echo -e "${RED}✗ Task $TASK_ID failed (exit $_exit_code) → blocked/$TASK_NAME${NC}"
    echo -e "${CYAN}  Run ./5day.sh plan $TASK_ID to redefine it.${NC}"

else
    # Finished but no clear signal
    echo -e "${YELLOW}⚠ Task $TASK_ID finished but left no outcome signal.${NC}"
    echo -e "${CYAN}  Move to review:${NC}  git mv $RELATIVE_PATH docs/tasks/review/"
    echo -e "${CYAN}  Move to blocked:${NC} git mv $RELATIVE_PATH docs/tasks/blocked/"
fi
