#!/usr/bin/env bash
# shellcheck disable=SC2207
set -euo pipefail

# Audit tasks using an AI CLI (default: Claude Code)
# Usage: ./audit-backlog.sh [folder] [limit] [offset]
#   folder: backlog (default), next, working, blocked — or a full path
#   review and live are not auditable (completed work)

# ── Config ───────────────────────────────────────────────────────────
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

folder="${1:-backlog}"
limit="${2:-0}"       # 0 = no limit
offset="${3:-0}"      # skip first N tasks

# Resolve folder name to path
case "$folder" in
    backlog|next|working|blocked)
        dir="docs/tasks/$folder"
        ;;
    review|live)
        echo "Error: Cannot audit $folder/ — those are completed tasks." >&2
        echo "Audit is for finding stale, done, or undefined work in backlog or next." >&2
        exit 1
        ;;
    *)
        # Treat as a direct path for backwards compatibility
        dir="$folder"
        ;;
esac

# Support single-file audit: ./5day.sh audit path/to/task.md
single_file=""
if [ -f "$dir" ]; then
    single_file="$dir"
elif [ ! -d "$dir" ]; then
    echo "Error: Not found: $dir" >&2
    exit 1
fi
timeout_sec=120       # kill hung AI CLI calls after this
command -v "$FIVEDAY_CLI" &>/dev/null || { echo "Error: AI CLI '$FIVEDAY_CLI' not found in PATH. Edit docs/5day/config (CLI) or install the tool. Claude Code: https://docs.anthropic.com/en/docs/claude-code/overview" >&2; exit 1; }

# Build --model args (empty = let CLI pick its own default)
_audit_model="$(fiveday_resolve_model AUDIT)"
_model_args=()
[ -n "$_audit_model" ] && _model_args=(--model "$_audit_model")

# Portable timeout: macOS lacks coreutils timeout
if command -v timeout &>/dev/null; then
  run_with_timeout() { timeout "${timeout_sec}s" "$@"; }
elif command -v gtimeout &>/dev/null; then
  run_with_timeout() { gtimeout "${timeout_sec}s" "$@"; }
else
  run_with_timeout() {
    "$@" &
    local pid=$!
    ( sleep "$timeout_sec" && kill "$pid" 2>/dev/null ) &
    local watcher=$!
    wait "$pid" 2>/dev/null
    local ret=$?
    # Kill watcher and its child sleep to avoid orphaned processes
    kill "$watcher" 2>/dev/null
    pkill -P "$watcher" 2>/dev/null
    wait "$watcher" 2>/dev/null
    return $ret
  }
fi

review_dir="docs/tasks/review"
blocked_dir="docs/tasks/blocked"
log_file="docs/tasks/audit-log.txt"

mkdir -p "$review_dir" "$blocked_dir"
touch "$log_file"

# Portable in-place sed that works on both macOS (BSD) and Linux (GNU)
sed_inplace() {
    if sed --version 2>/dev/null | grep -q GNU; then
        sed -i "$@"
    else
        sed -i '' "$@"
    fi
}

# Get sorted list of numbered task files
if [ -n "$single_file" ]; then
  files=("$single_file")
else
  IFS=$'\n' files=($(
    find "$dir" -maxdepth 1 -type f -name '*.md' -exec basename {} \; \
      | awk -F- '/^[0-9]+-/ { print $0 }' \
      | sort -t- -k1,1n \
      | if [ "$offset" -gt 0 ]; then tail -n +"$((offset + 1))"; else cat; fi \
      | if [ "$limit" -gt 0 ]; then head -"$limit"; else cat; fi \
      | sed "s|^|$dir/|"
  ))
  unset IFS
fi

total=${#files[@]}
echo "=== Backlog Audit: $total tasks (${timeout_sec}s timeout) ==="
echo "=== Backlog Audit started $(date) ===" >> "$log_file"
log_start_line=$(wc -l < "$log_file")

for i in "${!files[@]}"; do
  file="${files[$i]}"
  idx=$((i + 1))
  taskname=$(basename "$file")
  echo ""
  echo "[$idx/$total] Auditing: $taskname"

  # Run claude with timeout
  _audit_prompt="You are auditing a backlog task file.

CLAUDE.md is auto-loaded with project context and conventions.
Read it first to understand the project's tech stack and structure.

Read the task file at: $file

Then check the current codebase to determine if this task has ALREADY been completed,
if the task references files/features that no longer exist or are unrecognizable,
or if the task is too vaguely defined to be actionable.

Your job is to output EXACTLY ONE of these verdicts on the first line, followed by
a brief one-line reason on the second line:

DONE - The task has already been completed (the features/fixes described exist in the codebase)
OUTDATED - The task references files, patterns, or features that no longer exist or are unrecognizable
UNDEFINED - The task is not defined well enough to work (missing problem statement, success criteria, or actionable details)
KEEP - The task is still relevant, well-defined, and not yet completed

Rules:
- Be conservative: if in doubt, say KEEP
- DONE means the specific work described is clearly present in the codebase
- OUTDATED means the task cannot be worked because its context is gone
- UNDEFINED means someone would need to rewrite the task before working it
- Only output the verdict line and reason line, nothing else"

  verdict=$(run_with_timeout fiveday_run -p "$_audit_prompt" \
    ${_model_args[@]+"${_model_args[@]}"} --skip-permissions 2>/dev/null) || true

  # Parse verdict — scan for keyword (Sonnet sometimes buries it)
  action=$(echo "$verdict" | grep -oE '^(DONE|OUTDATED|UNDEFINED|KEEP)' | head -1 || true)
  if [ -z "$action" ]; then
    action=$(echo "$verdict" | grep -oE '\b(DONE|OUTDATED|UNDEFINED|KEEP)\b' | head -1 || true)
  fi
  [ -z "$action" ] && action="TIMEOUT"

  reason=$(echo "$verdict" | tail -1)
  [ -z "$reason" ] && reason="No response (timed out after ${timeout_sec}s)"

  echo "  Verdict: $action"
  echo "  Reason:  $reason"

  case "$action" in
    DONE)
      echo "  -> Moving to review/"
      git mv "$file" "$review_dir/" 2>/dev/null || mv "$file" "$review_dir/"
      echo "DONE | $taskname | $reason" >> "$log_file"
      ;;
    OUTDATED)
      echo "  -> Removing (outdated)"
      git rm "$file" 2>/dev/null || rm "$file"
      echo "OUTDATED | $taskname | $reason" >> "$log_file"
      ;;
    UNDEFINED)
      echo "  -> Marking as undefined, moving to blocked/"
      if grep -q '^## Problem' "$file"; then
        sed_inplace '/^## Problem$/a\
\
**This task is not defined yet. Define it first.**\
' "$file"
      else
        sed_inplace '1,/^#/{/^#/a\
\
## Problem\
\
**This task is not defined yet. Define it first.**\
}' "$file"
      fi
      git mv "$file" "$blocked_dir/" 2>/dev/null || mv "$file" "$blocked_dir/"
      echo "UNDEFINED | $taskname | $reason" >> "$log_file"
      ;;
    KEEP)
      echo "  -> Keeping in backlog"
      echo "KEEP | $taskname | $reason" >> "$log_file"
      ;;
    *)
      echo "  -> Timed out, keeping in backlog (retry later)"
      echo "TIMEOUT | $taskname | $reason" >> "$log_file"
      ;;
  esac
done

echo ""
echo "=== Audit complete ==="
echo "Log: $log_file"
echo ""
echo "--- Summary (this run) ---"
run_log=$(tail -n +"$((log_start_line + 1))" "$log_file")
echo "  Moved to review:  $(echo "$run_log" | grep -c '^DONE' || true)"
echo "  Removed (outdated): $(echo "$run_log" | grep -c '^OUTDATED' || true)"
echo "  Marked undefined: $(echo "$run_log" | grep -c '^UNDEFINED' || true)"
echo "  Kept in backlog:  $(echo "$run_log" | grep -c '^KEEP' || true)"
echo "  Timed out:        $(echo "$run_log" | grep -c '^TIMEOUT' || true)"
