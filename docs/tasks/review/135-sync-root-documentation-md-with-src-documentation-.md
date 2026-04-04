# Task 135: Sync root DOCUMENTATION.md with src/DOCUMENTATION.md — src version is authoritative

**Feature**: none
**Created**: 2026-04-04
**Depends on**: none
**Blocks**: none

## Problem

Root `DOCUMENTATION.md` and `src/DOCUMENTATION.md` have diverged. The src version has more complete bug workflow documentation and correct naming schemes. Per the project's workflow, changes should go to root first then sync to src — but currently src is ahead, meaning the root (live) copy is stale.

## Success criteria

- [x] Root DOCUMENTATION.md matches src/DOCUMENTATION.md content
- [x] Bug naming scheme (`BUG-ID-description.md`) is documented correctly in both
- [x] Both files include the complete "Creating Work" section

## Notes

Decide which direction to sync. src/DOCUMENTATION.md appears more complete — copy it to root, verify, then both are in sync.

## Completed

Copied `src/DOCUMENTATION.md` to root `DOCUMENTATION.md`. The src version was authoritative — it had the complete "Creating Work" table (with `newbug` command), correct `BUG-ID-description.md` naming scheme, and separate bug ID tracking. Files are now identical.

**Files changed:**
- `DOCUMENTATION.md` — replaced with contents of `src/DOCUMENTATION.md`

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
