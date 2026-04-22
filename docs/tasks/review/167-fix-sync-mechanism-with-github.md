# Task 167: Fix sync mechanism with Github

**Feature**: none
**Created**: 2026-04-16
**Depends on**: none
**Blocks**: none

## Problem

The GitHub Actions task-sync workflow pushes commits directly to `main` (e.g. resetting `SYNC_ALL_TASKS` in `DOC_STATE.md`), which causes push rejections for local developers who are the sole committers. The bot commit (`8bb6ddb`) flipped `SYNC_ALL_TASKS` from `true` to `false` after a sync run, creating a divergence that required a rebase to resolve. This friction will recur on every sync cycle and is surprising because no human is pushing to the remote.

## Success criteria

- [x] Local `git push` after a sync cycle does not require a rebase or pull to succeed
- [x] The sync workflow does not push commits directly to `main`
- [x] `SYNC_ALL_TASKS` flag reset is handled without creating remote-only commits
- [x] Sync workflow changes are audited and documented in the task notes before implementation

## Notes

- The sync workflow runs as `github-actions[bot]` and commits to `docs/5day/DOC_STATE.md`
- Commit in question: `8bb6ddb` ("chore: reset SYNC_ALL_TASKS [skip ci]")
- Relevant files: `.github/workflows/` (sync workflow), `docs/5day/DOC_STATE.md` (state file)
- Possible approaches: use workflow artifacts or GitHub API state instead of committing flag resets; use a separate branch for bot commits; use the GitHub API to set repository variables instead of file-based flags

## Completed

**Approach**: Replaced the file-based `SYNC_ALL_TASKS` flag mechanism with `workflow_dispatch` input (`force_sync_all`). The root cause was that the sync workflow committed a flag reset directly to `main`, creating remote-only commits that forced local developers to rebase. The fix eliminates all bot commits — full resyncs are now triggered via `gh workflow run` with the `force_sync_all` parameter instead of mutating a file on the remote.

**Changes**:

1. `.github/workflows/sync-tasks-reusable.yml`
   - Removed `SYNC_ALL_TASKS` file-based flag check from "Determine files to process" step
   - Removed the entire "Reset bulk sync flag" step (the bot commit)
   - Downgraded `contents` permission from `write` to `read` (no longer needs to push)

2. `.github/workflows/sync-tasks-to-issues.yml`
   - Removed `docs/5day/DOC_STATE.md` from push trigger paths (no longer a sync signal)
   - Downgraded `contents` permission from `write` to `read`

3. `docs/5day/scripts/sync.sh` (and `src/` mirror)
   - Removed code that set `SYNC_ALL_TASKS` flag in `DOC_STATE.md`
   - `--all` now triggers `gh workflow run sync-tasks-to-issues.yml -f force_sync_all=true`
   - Allows `--all` with no pending file changes (just dispatches the workflow)

4. `docs/5day/DOC_STATE.md` — Removed `SYNC_ALL_TASKS` field entirely

5. `setup.sh` — Removed `SYNC_ALL_TASKS` from both fresh-install and upgrade DOC_STATE.md templates

6. `docs/tests/test-*.sh` — Removed `SYNC_ALL_TASKS` lines from test DOC_STATE.md fixtures

7. `src/.github/workflows/sync-tasks-to-issues.yml` — Mirrored caller workflow changes

**All existing tests pass (test-5day.sh, test-create-task.sh, test-create-bug.sh).**

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

## Audit

- **Passes run**: 1
- **Final verdict**: PASS
- **Date**: 2026-04-22
- **Files audited**: 7
- **Context source**: task ## Completed section
