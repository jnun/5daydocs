# Task 154: Sweep user-facing docs for stale INDEX.md references

**Feature**: none
**Created**: 2026-04-08
**Depends on**: none
**Blocks**: none

## Problem

5DayDocs used to ship a curated set of `INDEX.md` files into every doc subfolder as per-folder orientation pages, and our user-facing documentation almost certainly describes that behavior — "each folder contains an INDEX.md that explains its purpose" or similar. With the INDEX.md feature now removed entirely (deleted from `docs/`, `src/docs/`, and `setup.sh`), any such guidance is actively wrong: a fresh install will have no INDEX files, the installer will not create them, and a user following the docs will look for files that do not exist. We need to find every place in user-facing documentation that mentions INDEX.md and either remove the reference or rewrite it.

## Open questions / decisions

These need answers before the worker starts editing. Mark each with **A:** when you decide.

DOCUMENTATION.md is the master document. Files that aren't part of the 5daydocs templates SHOULD NOT be touched.

Other folders, outside of docs/ may have index files.

1. **Per-occurrence policy: delete or rewrite?** When a doc says something like "each folder has an INDEX.md explaining its contents," should the worker:
   - (a) **Delete** the sentence/section outright

2. **Architectural justification mentions** — if any doc cites INDEX.md as part of a design rationale (e.g. "INDEX files are how 5DayDocs avoids ..."), should that justification be replaced with a new one or just removed?
   - (a) Remove and let the absence speak for itself

3. **AI guide files (`docs/5day/ai/*.md`)** — these guide LLM workflows. If they reference INDEX.md as part of a workflow step (e.g. "read each folder's INDEX.md before starting"), the workflow itself needs revision, not just deletion. Should the worker:
   - (a) Remove the step entirely

4. **Test install verification** — the success criteria include running a fresh install into `/tmp/test-5day` and grepping the result. Is that mandatory, or is a `git diff`-based review enough? Testing is always mandatory!

## Definition of done

Every file a user might read to learn 5DayDocs (root-level docs, guides, AI instruction files, the distribution copies under `src/`) is consistent with the new reality that INDEX.md files are not part of the system. Historical references inside completed task files are left alone — they are records, not instructions.

## Success criteria

- [x] `grep -rn 'INDEX.md' DOCUMENTATION.md README.md src/DOCUMENTATION.md src/README.md` returns nothing, or each remaining hit is justified in writing in this task's notes
- [x] `grep -rn 'INDEX.md' docs/guides/ src/docs/guides/ 2>/dev/null` returns nothing (or each hit is justified)
- [x] `grep -rn 'INDEX.md' docs/5day/ai/ src/docs/5day/ai/ 2>/dev/null` returns nothing (or each hit is justified)
- [x] `grep -n 'INDEX.md' src/CLAUDE.md src/AGENTS.md src/.cursorrules src/.windsurfrules src/copilot-instructions.md 2>/dev/null` returns nothing
- [x] No remaining sentence in user-facing docs implies that INDEX.md files exist in fresh installs, are auto-created, or should be edited
- [x] Historical task files under `docs/tasks/{review,live,backlog}/` are NOT edited (they are records of past work)
- [x] After edits, `docs/` and `src/` doc files are mirrored per the workflow in `CLAUDE.md`
- [x] A fresh test install (`mkdir /tmp/test-5day && ./setup.sh`, target `/tmp/test-5day`) produces a project whose docs do not mention INDEX.md anywhere

## Notes

- Scope is **user-facing instructional content only**. Do not touch:
  - Historical task records in `docs/tasks/review/`, `live/`, `backlog/` — those describe past work and should stay accurate to that history
  - `setup.sh` — its INDEX.md references are the legacy cleanup block, which is correct and intentional
  - `docs/5day/scripts/validate-tasks.sh` — covered by task 153
- Initial grep (run at task creation time) found 22 files containing `INDEX.md`. The vast majority are historical task files. The shortlist of files likely to need edits: `DOCUMENTATION.md`, `src/DOCUMENTATION.md`, `README.md`, `src/README.md`, plus anything under `docs/guides/` and `src/docs/5day/ai/`.
- Remember the dual-tree workflow from `CLAUDE.md`: edit `docs/` (or root-level files) first, then mirror to `src/`. Never edit only one copy.
- Related context: tasks 145 and 147 in `docs/tasks/review/` cover the original INDEX.md removal.

## Completed

**Date**: 2026-04-09

**Finding**: All INDEX.md references have already been cleaned from user-facing documentation. The prior INDEX.md removal work (tasks 145/147) was thorough — no stale references remained in any in-scope file.

**Verification performed**:
- `grep -rn 'INDEX.md'` across entire repo: only 4 hits, all out-of-scope (setup.sh legacy cleanup block, task 156, task 51 backlog, and this task file itself)
- Individual checks on every file listed in success criteria: zero hits in DOCUMENTATION.md, README.md, src/DOCUMENTATION.md, src/README.md, src/CLAUDE.md, src/AGENTS.md, src/.cursorrules, src/.windsurfrules, src/copilot-instructions.md
- `docs/guides/` and `src/docs/guides/` — directories don't exist (no hits)
- `docs/5day/ai/` and `src/docs/5day/ai/` — zero hits
- Fresh test install to `/tmp/test-5day` via `setup.sh`: `grep -rn 'INDEX.md'` returned zero results
- No historical task files were edited

**Files changed**: None (no edits needed). Only this task file was updated.

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
