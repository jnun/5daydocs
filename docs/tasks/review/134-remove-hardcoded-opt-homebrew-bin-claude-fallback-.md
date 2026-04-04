# Task 134: Remove hardcoded /opt/homebrew/bin/claude fallback in audit-backlog.sh line 12 — error if claude not in PATH

**Feature**: none
**Created**: 2026-04-04
**Depends on**: none
**Blocks**: none

## Problem

`audit-backlog.sh` line 12 has a hardcoded macOS Homebrew fallback: `claude_bin=$(command -v claude 2>/dev/null || echo "/opt/homebrew/bin/claude")`. On Linux or non-Homebrew installs, the script will try to execute a nonexistent binary instead of failing with a clear error.

## Success criteria

- [x] Script exits with clear error if `claude` is not in PATH
- [x] No hardcoded platform-specific paths in any script
- [x] Script works normally when claude is in PATH

## Notes

Related to task 136 (preflight check). Check all AI scripts for similar hardcoded paths.

## Completed

Replaced the hardcoded `/opt/homebrew/bin/claude` fallback on line 12 of `audit-backlog.sh` with a clear error message that exits with code 1 if `claude` is not found in PATH. Grep-verified no other scripts contain hardcoded platform-specific paths.

**Files changed:**
- `docs/5day/scripts/audit-backlog.sh` — replaced fallback with error exit
- `src/docs/5day/scripts/audit-backlog.sh` — same change synced to distribution copy

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
