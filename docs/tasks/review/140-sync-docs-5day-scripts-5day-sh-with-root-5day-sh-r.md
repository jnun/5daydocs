# Task 140: Sync docs/5day/scripts/5day.sh with root 5day.sh — root version is more complete

**Feature**: none
**Created**: 2026-04-04
**Depends on**: none
**Blocks**: none

## Problem

There are two `5day.sh` files: root `./5day.sh` (used by this repo) and `docs/5day/scripts/5day.sh` (distributed to users via setup.sh). They've drifted apart — the root version has `newbug` and other improvements that the distributed version lacks. This means the tool works better here than it does for people who install it.

## Success criteria

- [ ] `docs/5day/scripts/5day.sh` has all commands present in root `5day.sh`
- [ ] `src/docs/5day/scripts/5day.sh` matches `docs/5day/scripts/5day.sh`
- [ ] `./5day.sh help` output is identical whether run from root or installed copy

## Notes

This is the foundation task — tasks 132 and 133 add new functionality on top of this sync. Do this first, then layer the new commands. The root 5day.sh is the source of truth for existing commands.

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
