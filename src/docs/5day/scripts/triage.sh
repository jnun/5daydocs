#!/usr/bin/env bash
# shellcheck disable=SC2207
set -euo pipefail

# Triage tasks interactively: AI assesses each task, human decides what to do.
# Usage: ./5day.sh triage [limit]
#   Walks blocked/, next/, backlog/ in priority order.

# ── Config ───────────────────────────────────────────────────────────
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

limit="${1:-0}"
[[ "$limit" =~ ^[0-9]+$ ]] || { echo "Usage: triage [limit]  (limit must be a number)"; exit 1; }

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

timeout_sec=120
command -v "$FIVEDAY_CLI" &>/dev/null || {
  echo -e "${RED}Error: AI CLI '$FIVEDAY_CLI' not found in PATH.${NC}" >&2
  echo "Edit docs/5day/config (CLI) or install the tool." >&2
  exit 1
}

_triage_model="$(fiveday_resolve_model TRIAGE)"
_model_args=()
[ -n "$_triage_model" ] && _model_args=(--model "$_triage_model")

# Portable timeout
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
    kill "$watcher" 2>/dev/null
    pkill -P "$watcher" 2>/dev/null
    wait "$watcher" 2>/dev/null
    return $ret
  }
fi

trap 'echo ""; echo "Triage interrupted."; exit 130' INT TERM

# ── Collect tasks in priority order ──────────────────────────────────
DIRS=("docs/tasks/blocked" "docs/tasks/next" "docs/tasks/backlog")
all_files=()
counts=()

for dir in "${DIRS[@]}"; do
  if [ ! -d "$dir" ]; then
    counts+=(0)
    continue
  fi
  IFS=$'\n' folder_files=($(
    find "$dir" -maxdepth 1 -type f -name '*.md' -exec basename {} \; \
      | awk -F- '/^[0-9]+-/ { print $0 }' \
      | sort -t- -k1,1n \
      | sed "s|^|$dir/|"
  )) || true
  unset IFS
  counts+=("${#folder_files[@]}")
  all_files+=("${folder_files[@]}")
done

# Apply limit
if [ "$limit" -gt 0 ] && [ "${#all_files[@]}" -gt "$limit" ]; then
  all_files=("${all_files[@]:0:$limit}")
fi

total=${#all_files[@]}
if [ "$total" -eq 0 ]; then
  echo "No tasks to triage."
  exit 0
fi

echo -e "${CYAN}=== Triage: $total tasks (${counts[0]} blocked, ${counts[1]} next, ${counts[2]} backlog) ===${NC}"

# ── Counters ─────────────────────────────────────────────────────────
worked=0
defined=0
killed=0
skipped=0

mkdir -p docs/tasks/next docs/tasks/doing

# ── Main loop ────────────────────────────────────────────────────────
for i in "${!all_files[@]}"; do
  file="${all_files[$i]}"
  idx=$((i + 1))

  # Task may have been moved by a prior define action
  if [ ! -f "$file" ]; then
    echo -e "\n${DIM}[$idx/$total] (moved or deleted, skipping)${NC}"
    continue
  fi

  taskname=$(basename "$file")
  stage_name=$(basename "$(dirname "$file")")

  # ── AI assessment ──────────────────────────────────────────────────
  _triage_prompt="You are triaging a task file from $stage_name/.

CLAUDE.md is auto-loaded with project context and conventions.
Read the task file at: $file

Then do a quick check of the current codebase to assess the task's status.

Output EXACTLY three lines in this format:

STATUS: <one of: DONE, BLOCKED, UNDEFINED, READY, STALE>
SUMMARY: <one sentence describing what this task is about>
RECOMMENDATION: <one sentence telling the user what to do with it>

Status definitions:
- DONE: The work described in this task is already present in the codebase
- BLOCKED: The task references files/APIs/patterns that no longer exist or has unmet dependencies
- UNDEFINED: The task lacks a clear problem statement or actionable success criteria
- READY: The task is well-defined, relevant, and ready to be worked
- STALE: The task is not wrong but feels low-priority or superseded by other work

Rules:
- Be conservative: if in doubt, say READY
- Keep SUMMARY and RECOMMENDATION each to ONE sentence
- Do not output anything else"

  verdict=$(run_with_timeout fiveday_run -p "$_triage_prompt" \
    ${_model_args[@]+"${_model_args[@]}"} --skip-permissions 2>/dev/null) || true

  # Parse structured output
  status=$(echo "$verdict" | grep -oE '^STATUS: (DONE|BLOCKED|UNDEFINED|READY|STALE)' | head -1 | sed 's/^STATUS: //' || true)
  if [ -z "$status" ]; then
    status=$(echo "$verdict" | grep -oE '\b(DONE|BLOCKED|UNDEFINED|READY|STALE)\b' | head -1 || true)
  fi
  [ -z "$status" ] && status="UNKNOWN"

  summary=$(echo "$verdict" | grep '^SUMMARY:' | head -1 | sed 's/^SUMMARY: //' || true)
  [ -z "$summary" ] && summary="(no summary returned)"

  recommendation=$(echo "$verdict" | grep '^RECOMMENDATION:' | head -1 | sed 's/^RECOMMENDATION: //' || true)
  [ -z "$recommendation" ] && recommendation="(no recommendation returned)"

  # ── Display ────────────────────────────────────────────────────────
  echo ""
  echo -e "${BOLD}[$idx/$total] $taskname${NC}"
  echo -e "  Stage:  ${BLUE}$stage_name/${NC}"
  if [ "$status" = "UNKNOWN" ]; then
    echo -e "  Status: ${DIM}(timed out)${NC}"
  elif [ "$status" = "DONE" ]; then
    echo -e "  Status: ${CYAN}$status${NC}"
  elif [ "$status" = "BLOCKED" ] || [ "$status" = "UNDEFINED" ]; then
    echo -e "  Status: ${RED}$status${NC}"
  elif [ "$status" = "STALE" ]; then
    echo -e "  Status: ${YELLOW}$status${NC}"
  else
    echo -e "  Status: $status"
  fi
  echo "  $summary"
  echo -e "  ${DIM}$recommendation${NC}"
  echo ""
  case "$stage_name" in
    next)     _w_label="Start it" ;;
    *)        _w_label="Promote" ;;
  esac
  echo -e "  ${BOLD}[w]${NC} $_w_label  ${BOLD}[d]${NC} Define it  ${BOLD}[k]${NC} Kill it  ${BOLD}[s]${NC} Skip  ${BOLD}[q]${NC} Quit"
  printf "  > "
  read -r choice </dev/tty 2>/dev/null || choice="s"

  # ── Act ────────────────────────────────────────────────────────────
  case "$choice" in
    w|W)
      case "$stage_name" in
        blocked|backlog)
          move_file "$file" "docs/tasks/next/$taskname"
          echo -e "  ${CYAN}-> Moved to next/${NC}"
          ;;
        next)
          move_file "$file" "docs/tasks/doing/$taskname"
          echo -e "  ${CYAN}-> Moved to doing/${NC}"
          ;;
      esac
      worked=$((worked + 1))
      ;;
    d|D)
      task_id=$(echo "$taskname" | grep -oE '^[0-9]+' || true)
      if [ -n "$task_id" ]; then
        echo -e "  ${BLUE}-> Launching plan session...${NC}"
        bash "$(dirname "${BASH_SOURCE[0]}")/plan.sh" "$task_id" </dev/tty || true
        echo ""
        echo -e "  ${DIM}Plan session complete. Continuing triage...${NC}"
        defined=$((defined + 1))
      else
        echo -e "  ${YELLOW}Could not extract task ID. Skipping define.${NC}"
        skipped=$((skipped + 1))
      fi
      ;;
    k|K)
      printf "  Delete %s? [y/N]: " "$taskname"
      read -r confirm </dev/tty 2>/dev/null || confirm="n"
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        git rm "$file" 2>/dev/null || rm "$file"
        echo -e "  ${RED}-> Deleted${NC}"
        killed=$((killed + 1))
      else
        echo -e "  ${DIM}-> Kept${NC}"
        skipped=$((skipped + 1))
      fi
      ;;
    q|Q)
      echo -e "  ${DIM}-> Quitting triage${NC}"
      break
      ;;
    *)
      skipped=$((skipped + 1))
      ;;
  esac
done

# ── Summary ──────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}=== Triage complete ===${NC}"
echo "  Worked:   $worked"
echo "  Defined:  $defined"
echo "  Killed:   $killed"
echo "  Skipped:  $skipped"
