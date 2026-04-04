# Task 132: Add sprint, define, tasks, split, and audit commands to docs/5day/scripts/5day.sh dispatcher

**Feature**: none
**Created**: 2026-04-04
**Depends on**: none
**Blocks**: none

## Problem

The `5day.sh` CLI dispatcher only exposes `newidea`, `newfeature`, `newtask`, `newbug`, `status`, `checkfeatures`, and `ai-context`. Five workflow scripts exist in `docs/5day/scripts/` but have no CLI commands: `sprint.sh`, `define.sh`, `tasks.sh`, `split.sh`, `audit-backlog.sh`. Users must know to call them directly via `bash docs/5day/scripts/sprint.sh`, which defeats the unified CLI.

## Success criteria

- [x] `./5day.sh sprint` runs sprint.sh with optional args (count, focus)
- [x] `./5day.sh define` runs define.sh with optional limit arg
- [x] `./5day.sh tasks` runs tasks.sh with optional limit arg
- [x] `./5day.sh split <path>` runs split.sh with task file path
- [x] `./5day.sh audit` runs audit-backlog.sh with optional args
- [x] `./5day.sh help` lists all new commands with descriptions

## Notes

This must be done in `docs/5day/scripts/5day.sh` (the distributed version), then synced to `src/docs/5day/scripts/5day.sh`. The root `5day.sh` is a separate file for this repo's own use and also needs updating. Depends on task 140 (5day.sh sync) or can be done together.

## Completed

Added `sprint`, `define`, `tasks`, `split`, and `audit` commands to the 5day.sh CLI dispatcher. Each command delegates to its corresponding script in `docs/5day/scripts/` and passes through all arguments. The `split` command validates that a path argument is provided. Help output groups the new commands under a "Workflow" section.

Also added the missing `cmd_newbug` function to `docs/5day/scripts/5day.sh` (it had a case entry but no function).

### Files changed
- `5day.sh` — added 5 workflow commands + case entries
- `docs/5day/scripts/5day.sh` — added 5 workflow commands, `cmd_newbug`, case entries, updated help
- `src/docs/5day/scripts/5day.sh` — synced same changes (5 workflow commands + case entries + help)

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
