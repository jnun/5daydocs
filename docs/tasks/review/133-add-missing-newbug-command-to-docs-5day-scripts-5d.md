# Task 133: Add missing newbug command to docs/5day/scripts/5day.sh — copy from root 5day.sh

**Feature**: none
**Created**: 2026-04-04
**Depends on**: none
**Blocks**: none

## Problem

The distributed `docs/5day/scripts/5day.sh` is missing the `newbug` command — no function, no case handler, no help text. The root `5day.sh` has it. Users who install 5DayDocs cannot run `./5day.sh newbug` even though DOCUMENTATION.md and README.md both document it.

## Success criteria

- [x] `./5day.sh newbug "description"` works in an installed project
- [x] `./5day.sh help` lists the newbug command
- [x] Both docs/5day/scripts/5day.sh and src/docs/5day/scripts/5day.sh include the command

## Notes

May be absorbed into task 140 (sync 5day.sh files). The `cmd_newbug()` implementation in root `5day.sh` can be copied directly.

## Completed

All three copies of `5day.sh` already contain the `newbug` command (function, case handler, and help text) from prior uncommitted work. Verified:

- `docs/5day/scripts/5day.sh` — `cmd_newbug()` at line 120, case handler at line 159, help at line 53
- `src/docs/5day/scripts/5day.sh` — `cmd_newbug()` at line 84, case handler at line 167, help at line 53
- Root `5day.sh` — `cmd_newbug()` at line 84, case handler at line 167, help at line 53
- `docs/5day/scripts/create-bug.sh` and `src/docs/5day/scripts/create-bug.sh` both exist
- `./5day.sh help` confirms `newbug` is listed

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
