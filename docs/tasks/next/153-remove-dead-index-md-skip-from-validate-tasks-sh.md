# Task 153: Remove dead INDEX.md skip from validate-tasks.sh

**Feature**: none
**Created**: 2026-04-08
**Depends on**: none
**Blocks**: none

## Problem

`validate-tasks.sh` contains a defensive skip for `INDEX.md` filenames so that the per-folder INDEX files we used to ship would not be linted as task files. As of the recent INDEX.md removal, those files no longer exist anywhere under `docs/tasks/`, so the skip is dead code. Leaving dead branches in validation scripts is low-cost individually but accumulates as confusing noise — future readers will assume `INDEX.md` is a meaningful concept in the task pipeline when it is not. The fix is a one-line removal in two files (live copy in `docs/` and distribution copy in `src/`).

## Definition of done

The `INDEX.md` filename special-case is gone from both copies of `validate-tasks.sh`, the validator still runs cleanly against the current task tree, and no other script in the repo silently relies on the removed branch.

## Success criteria

- [ ] `grep -n 'INDEX.md' docs/5day/scripts/validate-tasks.sh` returns nothing
- [ ] `grep -n 'INDEX.md' src/docs/5day/scripts/validate-tasks.sh` returns nothing
- [ ] `./5day.sh validate` runs to completion with no new errors compared to a pre-change baseline
- [ ] No other reference to `INDEX.md`-as-task-skip exists under `docs/5day/scripts/` or `src/docs/5day/scripts/` (verify with grep)
- [ ] Both files remain executable (`-x` bit preserved)
- [ ] Live and src copies remain byte-identical except for any pre-existing intentional drift (diff them after the change)

## Notes

- The skip currently lives at `docs/5day/scripts/validate-tasks.sh:72` and the equivalent line in `src/docs/5day/scripts/validate-tasks.sh`. Search for the exact line `if [[ "$filename" == "TEMPLATE"* ]] || [[ "$filename" == "INDEX.md" ]]; then` and remove the `|| [[ "$filename" == "INDEX.md" ]]` clause.
- Per `CLAUDE.md`: edit `docs/` first, run it, then mirror to `src/`. Do not edit `src/` standalone.
- This task is downstream of the INDEX.md removal — see `docs/tasks/review/145-stop-shipping-live-index-files-to-user-installs.md` for context on why the skip became dead.

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
