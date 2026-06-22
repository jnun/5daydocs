# Task 163: Task search command

**Feature**: none
**Created**: 2026-04-16
**Depends on**: none
**Blocks**: none

## Problem

The CLI has `find` to locate a task by its numeric ID, but no way to search tasks by keyword. When you remember a word from a task title or body but not its ID, you have to manually grep or scan files. A `search` command would let users quickly locate tasks by text across all pipeline stages.

## Success criteria

- [x] `./5day.sh search <keyword>` searches task filenames and content across all stages
- [x] Results show task ID, stage, and title for each match
- [x] Search is case-insensitive
- [x] `./5day.sh search` with no argument prints usage and exits non-zero
- [x] Script is mirrored to `src/docs/5day/scripts/search.sh`
- [x] `search` command is wired into `5day.sh` help text and case dispatch

## Notes

<!-- Include dependencies, related docs, or edge cases worth considering.
     Leave empty if none, but keep this section. -->

## Completed

- `docs/5day/scripts/search.sh` — new search script
- `src/docs/5day/scripts/search.sh` — mirrored to distribution
- `5day.sh` — added `search` command, help text, and dispatch

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

Get next ID: docs/5day/DOC_STATE.md (5DAY_TASK_ID field + 1)
Full protocol: docs/5day/ai/task-creation.md
-->
