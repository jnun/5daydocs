# Task 136: Add claude CLI preflight check to sprint.sh, define.sh, and tasks.sh — fail early with clear message

**Feature**: none
**Created**: 2026-04-04
**Depends on**: none
**Blocks**: none

## Problem

`sprint.sh`, `define.sh`, `tasks.sh`, and `split.sh` all invoke `claude -p` directly without checking that the Claude CLI is installed and available. If a user runs these scripts without Claude CLI, they get a cryptic shell error instead of a helpful message explaining what's needed.

## Success criteria

- [x] Each AI script checks for `claude` in PATH before doing anything else
- [x] Missing claude produces a clear error: name of the tool, install URL, and which command failed
- [x] Scripts still work normally when claude is available

## Notes

A shared preflight function could be sourced by all scripts, or each can inline the check. Related to task 134 (hardcoded path removal).

## Completed

Added `command -v claude` preflight check to the Preflight section of all four AI scripts. Each check runs before any other logic and exits with a clear error message including the tool name, install URL, and which script requires it.

**Files changed:**
- `docs/5day/scripts/sprint.sh` — added claude CLI check
- `docs/5day/scripts/define.sh` — added claude CLI check
- `docs/5day/scripts/tasks.sh` — added claude CLI check
- `docs/5day/scripts/split.sh` — added claude CLI check
- `src/docs/5day/scripts/sprint.sh` — synced from docs/
- `src/docs/5day/scripts/define.sh` — synced from docs/
- `src/docs/5day/scripts/tasks.sh` — synced from docs/
- `src/docs/5day/scripts/split.sh` — synced from docs/

<!--
AI TASK CREATION GUIDE

Write as you'd explain to a colleague:
- Problem: describe what needs solving and why
- Success criteria: "User can [do what]" or "App shows [result]"
- Notes: dependencies, links, edge cases

Patterns that work well:
  Filename:    120-add-login-button.md (ID + kebab-case description)
  Title:       # Task 120: Add login button (matches filename ID)
  Feature:     **Feature**: /docs/features/auth.md (or "none" or "multiple")
  Created:     **Created**: 2026-01-28 (YYYY-MM-DD format)
  Depends on:  **Depends on**: Task 42 (or "none")
  Blocks:      **Blocks**: Task 101 (or "none")

Success criteria that verify easily:
  - [ ] User can reset password via email
  - [ ] Dashboard shows total for selected date range
  - [ ] Search returns results within 500ms

Get next ID: docs/STATE.md (5DAY_TASK_ID field + 1)
Full protocol: docs/5day/ai/task-creation.md
-->
