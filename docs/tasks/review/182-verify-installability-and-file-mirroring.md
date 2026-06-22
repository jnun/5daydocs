# Task 182: Verify installability and file mirroring

**Feature**: none
**Created**: 2026-06-22
**Depends on**: Task 181
**Blocks**: none

## Problem

After rapid changes to scripts, documentation, and the kanban workflow (adding `blocked/`, removing `live/`, rewriting `find.sh`), the files under `src/` may have drifted from `docs/`. A fresh install via `setup.sh` needs to be verified end-to-end — correct folder creation, no stale references, and consistent pipeline descriptions across all user-facing files.

## Success criteria

- [x] All scripts mirrored correctly: `diff -r docs/5day/scripts/ src/docs/5day/scripts/` shows no differences
- [x] `5day.sh` mirrored: `diff 5day.sh src/5day.sh` shows no differences
- [x] `DOCUMENTATION.md` mirrored: `diff DOCUMENTATION.md src/DOCUMENTATION.md` shows no differences
- [x] Fresh install test passes: `mkdir /tmp/test-5day && ./setup.sh` (enter `/tmp/test-5day`), verify no errors, then `rm -rf /tmp/test-5day`
- [x] The six task folders (backlog, next, doing, blocked, review, done) are created during fresh install
- [x] No references to `live/` remain in any shipped file under `src/` (migration code in `setup.sh` is exempt)
- [x] `blocked/` appears in every script and doc that lists task stages — no script silently skips it
- [x] The help text in `5day.sh` accurately describes every command's current behavior
- [x] Pipeline descriptions in `DOCUMENTATION.md`, `quick-reference.md`, `.TEMPLATE-task.md`, and `.github/pull_request_template.md` all match: `backlog → next → doing → blocked → review → done`

## Notes

- Depends on Task 181 (style cleanup) so that mirroring happens after scripts are finalized.
- `setup.sh` migration code that references `live/` is correct and should not be changed — it handles upgrades from v2.
- The dual-tree rule applies: if any fix is needed, edit in `docs/`, test, then mirror to `src/`.

## Completed

All mirroring verified clean. One fix applied:

- `.github/pull_request_template.md` — added missing `blocked` stage to pipeline description
- `src/.github/pull_request_template.md` — same fix mirrored

Everything else passed: scripts, `5day.sh`, `DOCUMENTATION.md`, AI files, and templates were already in sync. Fresh install creates all six task folders correctly, no stale `live/` references in `src/`, `blocked/` present in all relevant scripts, and help text matches implemented commands.

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
