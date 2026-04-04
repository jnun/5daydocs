# Task 137: Update stale INDEX.md files — remove work/ references in docs/INDEX.md, fix docs/tasks/INDEX.md and docs/features/INDEX.md

**Feature**: none
**Created**: 2026-04-04
**Depends on**: none
**Blocks**: none

## Problem

Several INDEX.md files reference the old `work/` directory structure that was flattened in 2.0.0. `docs/INDEX.md` still says "work/ - Task pipeline, bugs, scripts...". `docs/features/INDEX.md` mentions a TESTING status not documented in DOCUMENTATION.md. These stale references confuse both humans and AI assistants reading the project.

## Success criteria

- [x] `docs/INDEX.md` reflects current directory structure (no `work/` references)
- [x] `docs/tasks/INDEX.md` accurately describes task pipeline states
- [x] `docs/features/INDEX.md` uses only documented status values
- [x] All INDEX.md files match what's actually in their directories

## Notes

Also check src/ copies of INDEX.md files for the same staleness.

## Completed

All three INDEX.md files updated to reflect current project structure:

- **docs/INDEX.md** — Replaced stale `work/` reference with complete listing of all current directories (5day, bugs, data, designs, examples, features, guides, ideas, tasks, tests). Fixed feature status list from `LIVE/TESTING/WORKING/BACKLOG` to `BACKLOG/WORKING/LIVE`.
- **docs/tasks/INDEX.md** — Added missing `blocked/` stage to pipeline listing and quick commands section, matching DOCUMENTATION.md and the actual directory structure.
- **docs/features/INDEX.md** — Removed undocumented `TESTING` status. Status list and flow now show `BACKLOG/WORKING/LIVE`, matching the feature template's AI guide.
- **src/ check** — Only one INDEX.md exists in src/ (`src/docs/5day/scripts/INDEX.md`), which has no stale references. No src/ copies of docs/INDEX.md, docs/tasks/INDEX.md, or docs/features/INDEX.md exist.

Files changed: `docs/INDEX.md`, `docs/tasks/INDEX.md`, `docs/features/INDEX.md`

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
