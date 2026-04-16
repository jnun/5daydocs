#!/usr/bin/env bash
# ── audit-code.sh ───────────────────────────────────────────────────
# Iterative code quality audit for completed tasks.
#
# Runs up to N passes of fresh-context review on code changes. Each
# pass can read, fix, and re-verify. Stops on first PASS verdict.
#
# Context modes (how the audit knows what changed):
#
#   1. MANIFEST FILE (from tasks.sh)
#      tasks.sh snapshots the tree before/after and writes a manifest
#      file listing exactly which files the task changed. Passed via
#      AUDIT_MANIFEST env var.
#
#   2. TASK FILE with ## Completed section (standalone)
#      The task's ## Completed section lists files changed. The auditor
#      parses this and traces impact through the codebase.
#
#   3. EXPLICIT FILE LIST (standalone, no task)
#      Pass file paths directly:  ./5day.sh review-code file1.py file2.ts
#
# In all modes the auditor also traces the IMPACT GRAPH — what other
# code imports, calls, or references the changed files — so it can
# check for regressions beyond the immediate changes.
#
# Usage:
#   bash docs/5day/scripts/audit-code.sh <task-file> [max-passes]
#   bash docs/5day/scripts/audit-code.sh <file1> <file2> ... [-- max-passes]
#   AUDIT_MANIFEST=/path/to/manifest bash audit-code.sh <task-file>
#
# The audit never blocks task promotion — it fixes what it can,
# documents what it cannot, and exits 0 (clean) or 1 (warnings).

set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────
_CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config.sh"
# shellcheck source=/dev/null
[ -f "$_CONFIG" ] && source "$_CONFIG"
: "${FIVEDAY_CLI:=claude}"
if ! declare -F fiveday_resolve_model >/dev/null 2>&1; then
  fiveday_resolve_model() {
    local var="$1"
    if [ "${!var+set}" = "set" ]; then printf '%s' "${!var}"
    else printf '%s' "${FIVEDAY_MODEL_DEFAULT-}"; fi
  }
fi

MODEL="$(fiveday_resolve_model FIVEDAY_MODEL_CODE_AUDIT)"
TOOLS="Read,Edit,Write,Bash,Grep,Glob,Agent"
PERMISSIONS="auto"
MAX_TURNS=75
LOG_DIR="docs/tmp"

# ── Parse arguments ─────────────────────────────────────────────────
# Accepts:
#   audit-code.sh <task.md> [max-passes]
#   audit-code.sh <file1> <file2> ... [-- max-passes]
TASK_FILE=""
EXPLICIT_FILES=()
MAX_PASSES="${FIVEDAY_AUDIT_MAX_PASSES:-3}"

if [ $# -eq 0 ]; then
  echo "Usage:" >&2
  echo "  audit-code.sh <task-file.md> [max-passes]" >&2
  echo "  audit-code.sh <file1> <file2> ... [-- max-passes]" >&2
  exit 1
fi

# Check if first arg is a task .md file or a code file
if [[ "$1" == *.md ]] && [ -f "$1" ]; then
  TASK_FILE="$1"
  shift
  # Optional max-passes as second arg
  [ $# -gt 0 ] && MAX_PASSES="$1"
else
  # Collect file args until -- or end
  while [ $# -gt 0 ]; do
    case "$1" in
      --)
        shift
        [ $# -gt 0 ] && MAX_PASSES="$1"
        break
        ;;
      *)
        if [ -f "$1" ]; then
          EXPLICIT_FILES+=("$1")
        else
          echo "✗ File not found: $1" >&2
          exit 1
        fi
        shift
        ;;
    esac
  done
fi

# ── Preflight ───────────────────────────────────────────────────────
if ! command -v "$FIVEDAY_CLI" &>/dev/null; then
  echo "✗ AI CLI '$FIVEDAY_CLI' not found in PATH" >&2
  echo "  Edit docs/5day/config.sh to change FIVEDAY_CLI, or install the tool." >&2
  exit 1
fi

mkdir -p "$LOG_DIR"

# ── Build the change manifest ───────────────────────────────────────
# Priority: AUDIT_MANIFEST env > explicit files > task ## Completed > git diff
CHANGED_FILES=""
CONTEXT_SOURCE=""

# 1. Manifest file from tasks.sh (most reliable — exact before/after snapshot)
if [ -n "${AUDIT_MANIFEST:-}" ] && [ -f "${AUDIT_MANIFEST}" ]; then
  CHANGED_FILES=$(cat "$AUDIT_MANIFEST" | grep -v '^$' || true)
  CONTEXT_SOURCE="manifest from tasks.sh"

# 2. Explicit file list from CLI args
elif [ ${#EXPLICIT_FILES[@]} -gt 0 ]; then
  CHANGED_FILES=$(printf '%s\n' "${EXPLICIT_FILES[@]}")
  CONTEXT_SOURCE="explicit file list"

# 3. Task file's ## Completed section
elif [ -n "$TASK_FILE" ] && grep -q '^## Completed' "$TASK_FILE"; then
  # Extract file paths from the Completed section (lines containing path-like strings)
  CHANGED_FILES=$(sed -n '/^## Completed/,/^## /{ /^## /d; p; }' "$TASK_FILE" \
    | grep -oE '[a-zA-Z0-9_/./-]+\.[a-zA-Z]{1,5}' \
    | sort -u \
    | while read -r f; do [ -f "$f" ] && echo "$f"; done || true)
  CONTEXT_SOURCE="task ## Completed section"

# 4. Fallback: git working tree diff
else
  CHANGED_FILES=$(git diff --name-only 2>/dev/null || true)
  STAGED=$(git diff --cached --name-only 2>/dev/null || true)
  CHANGED_FILES=$(printf '%s\n%s' "$CHANGED_FILES" "$STAGED" | sort -u | grep -v '^$' || true)
  CONTEXT_SOURCE="git working tree diff"
fi

if [ -z "$CHANGED_FILES" ]; then
  echo "▸ No changed files found — nothing to audit"
  echo "  Context source: $CONTEXT_SOURCE"
  echo ""
  echo "  Provide files explicitly:  ./5day.sh review-code file1.py file2.ts"
  echo "  Or ensure the task has a ## Completed section listing changed files."
  exit 0
fi

FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
TASK_NAME=""
TASK_CONTENT=""
if [ -n "$TASK_FILE" ]; then
  TASK_NAME=$(basename "$TASK_FILE")
  TASK_CONTENT=$(cat "$TASK_FILE")
fi

echo "▸ Auditing $FILE_COUNT changed file(s)${TASK_NAME:+ for: $TASK_NAME}"
echo "  Context source: $CONTEXT_SOURCE"
echo "  Max passes: $MAX_PASSES"
echo "  Files:"
echo "$CHANGED_FILES" | sed 's/^/    /'
echo ""

# ── Build task context block ────────────────────────────────────────
if [ -n "$TASK_CONTENT" ]; then
  TASK_BLOCK="TASK FILE: $TASK_FILE

ORIGINAL TASK:
---
$TASK_CONTENT
---"
else
  TASK_BLOCK="No task file provided. Auditing the listed files directly."
fi

# ── Audit loop ──────────────────────────────────────────────────────
PASS=1
VERDICT="FAIL"

while [ "$PASS" -le "$MAX_PASSES" ]; do
  echo "── Pass $PASS/$MAX_PASSES ──────────────────────────────────"

  if [ "$PASS" -eq 1 ]; then
    PASS_CONTEXT="This is the first audit pass. Be thorough."
  else
    PASS_CONTEXT="This is pass $PASS. A previous auditor already reviewed and fixed some issues. Focus on anything they may have introduced or missed. Verify their fixes are correct."
  fi

  PROMPT="You are a code auditor reviewing changes made by another developer.
You have FRESH EYES — you did not write this code.

CLAUDE.md is auto-loaded with project context and conventions.

$TASK_BLOCK
$PASS_CONTEXT

CHANGED FILES:
$CHANGED_FILES

## Your first step: Build the impact graph

Before auditing, trace what depends on the changed files:

1. Read each changed file to understand what was modified.
2. Search the codebase for files that IMPORT, CALL, or REFERENCE the changed
   files. Use Grep to find:
   - Python: \`from <module> import\` or \`import <module>\`
   - TypeScript: \`import .* from '<path>'\` or \`require('<path>')\`
   - Route references: API endpoint paths used by frontend hooks/client
   - Test files that test the changed code
3. Read the key impacted files to check for regressions.

List the impacted files you found before proceeding to the audit.

## Then audit these categories IN ORDER

Fix every issue you find before moving to the next category:

1. CORRECTNESS
   - Do the changes accomplish what the task asked for?
   - Any behavioral regressions in the changed files OR their dependents?
   - Any edge cases missed (case sensitivity, null values, boundary conditions)?
   - Any error responses that changed (e.g. 404→422) that callers depend on?

2. FRAMEWORK CONVENTIONS
   - Route/middleware ordering (FastAPI: static routes before parameterized)
   - Import ordering and unused imports
   - Parameter ordering in function signatures (no bare params after defaults)
   - Decorator placement

3. STYLE & FORMATTING
   - PEP 8 for Python (2 blank lines between top-level defs, no trailing whitespace
     ONLY on lines you changed — do not fix pre-existing style issues)
   - ESLint/Prettier for TypeScript
   - Consistent patterns with surrounding code

4. BUILD VERIFICATION
   - Python files: python3 -c \"import ast; ast.parse(open('<file>').read())\"
   - TypeScript files: cd app && pnpm tsc --noEmit (if app/ files changed)
   - Fix any errors before proceeding

5. SAFETY
   - No hardcoded secrets, credentials, or connection strings
   - No new security vulnerabilities (injection, XSS, etc.)
   - Environment variables used where required

After completing ALL checks and fixing any issues found, output a summary
and then your verdict as the VERY LAST LINE of your response, exactly:
VERDICT: PASS
or
VERDICT: FAIL"

  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  _log_name="${TASK_NAME:-adhoc}"
  LOG_FILE="$LOG_DIR/log-audit-code-${_log_name%.md}-pass${PASS}-$TIMESTAMP.json"

  _model_args=()
  [ -n "$MODEL" ] && _model_args=(--model "$MODEL")

  OUTPUT=$("$FIVEDAY_CLI" -p "$PROMPT" \
    "${_model_args[@]}" \
    --allowedTools "$TOOLS" \
    --permission-mode "$PERMISSIONS" \
    --max-turns "$MAX_TURNS" \
    --output-format json \
    --no-session-persistence 2>/dev/null | tee "$LOG_FILE") || true

  # Extract verdict from output
  PASS_VERDICT=$(echo "$OUTPUT" | grep -oE 'VERDICT: (PASS|FAIL)' | tail -1 | awk '{print $2}' || true)
  [ -z "$PASS_VERDICT" ] && PASS_VERDICT="UNCLEAR"

  echo "  Result: $PASS_VERDICT"

  case "$PASS_VERDICT" in
    PASS)
      VERDICT="PASS"
      echo "  ✓ Audit passed on pass $PASS"
      break
      ;;
    FAIL)
      VERDICT="FAIL"
      echo "  ⚠ Issues found and fixed — will re-audit"
      ;;
    *)
      echo "  ? Could not parse verdict — treating as FAIL"
      VERDICT="UNCLEAR"
      ;;
  esac

  PASS=$((PASS + 1))
done

echo ""

# ── Append audit notes to task file (if we have one) ────────────────
if [ -n "$TASK_FILE" ]; then
  {
    echo ""
    echo "## Audit"
    echo ""
    echo "- **Passes run**: $((PASS > MAX_PASSES ? MAX_PASSES : PASS))"
    echo "- **Final verdict**: $VERDICT"
    echo "- **Date**: $(date +%Y-%m-%d)"
    echo "- **Files audited**: $FILE_COUNT"
    echo "- **Context source**: $CONTEXT_SOURCE"
  } >> "$TASK_FILE"
fi

if [ "$VERDICT" = "PASS" ]; then
  echo "✓ Code audit passed ($((PASS)) pass(es))"
  exit 0
else
  echo "⚠ Code audit completed with warnings after $MAX_PASSES pass(es)"
  echo "  Review the changes and audit logs in $LOG_DIR/"
  exit 1
fi
