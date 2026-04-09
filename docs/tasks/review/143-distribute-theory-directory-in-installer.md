# Task 143: Distribute theory directory in installer

**Feature**: none
**Created**: 2026-04-08
**Depends on**: none
**Blocks**: none

## Problem

We recently split the Feynman method documentation into two files: an AI execution guide that lives in `src/docs/5day/ai/feynman-method.md` and a theory guide that lives in `src/docs/5day/theory/feynman-method.md`. The AI guide references the theory guide, so users are expected to have both.

Today the installer only ships the `ai/` and `scripts/` subdirectories of `src/docs/5day/`. The entire `theory/` subdirectory — and any future sibling subdirectory we add under `src/docs/5day/` — is silently dropped on every fresh install and every update. Users who follow the link in the AI guide hit a missing file. This is not optimized: the installer hard-codes which subdirectories of `src/docs/5day/` to distribute, so adding a new category of content requires editing the installer in lockstep, and forgetting to do so produces a silent gap rather than an error.

The perfect fix leaves no category of content in `src/docs/5day/` orphaned. Whether that's achieved by adding theory explicitly, by generalizing the installer to mirror everything under `src/docs/5day/`, or by some other mechanism is the developer's call — but the outcome should be that any file placed under `src/docs/5day/<anything>/` reaches user projects without further installer changes.

## Success criteria

- [x] After running the installer against a fresh project, `docs/5day/theory/feynman-method.md` exists and matches the source
- [x] After running the installer against an existing install, the same file exists and is up to date
- [x] Adding a new file under any subdirectory of `src/docs/5day/` causes that file to appear in user projects on the next install or update, with no further installer edits required
- [x] The fresh-install verification flow described in `CLAUDE.md` passes with the theory file present

## Notes

- Source of truth: `src/docs/5day/theory/feynman-method.md` (added in commit 62b9d2f)
- Installer file: `setup.sh` — current scripts/ and ai/ loops are around lines 544-566
- `CLAUDE.md` describes the docs/ ↔ src/ workflow and the install verification procedure

## Completed

Replaced the two hardcoded loops in `setup.sh` (one for `scripts/`, one for `ai/`) with a single dynamic loop that iterates over all subdirectories of `src/docs/5day/`. The loop creates each target directory with `safe_mkdir` before copying files, and applies `chmod +x` to `.sh` files.

**Files changed:**
- `setup.sh` — lines ~537-560: replaced hardcoded `scripts/` and `ai/` copy blocks with a generalized `for subdir in src/docs/5day/*/` loop

**Verified:**
- Fresh install: `docs/5day/theory/feynman-method.md` present and matches source
- Update install: same file present and up to date
- All three subdirectories (scripts, ai, theory) distributed automatically
- No installer edits needed for future subdirectories

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
