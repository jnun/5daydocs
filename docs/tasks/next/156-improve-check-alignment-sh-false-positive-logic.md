# Task 156: Improve check-alignment.sh false-positive logic

**Feature**: none
**Created**: 2026-04-08
**Depends on**: none
**Blocks**: none

## Problem

`./5day.sh checkfeatures` (which runs `docs/5day/scripts/check-alignment.sh`) is supposed to flag mismatches between feature status and the tasks that reference each feature, plus orphaned tasks and broken feature references. In practice the orphan-detection and folder-vs-status-mismatch logic produce so many false positives on the current repo that the useful signal — broken feature-file references — is buried in noise. Two specific problems: (1) the script warns on every task missing a `**Feature**:` field, but the task template does not actually require one, so dozens of legitimate tasks get flagged; and (2) the script warns when a task's folder implies a different status than the feature's status (e.g. backlog task under a LIVE feature), even though the script's own "Best Practices" output says this is fine. The goal is to keep the broken-link checking, which is genuinely useful, and either remove or soften the noisy checks so the output is actionable.

## Definition of done

`./5day.sh checkfeatures` produces output where every warning represents a real, actionable problem on the current repo, and the script's exit code is meaningful (non-zero only when something genuinely needs human attention). Running it on the current state of the repo should not surface dozens of warnings about tasks that have no `**Feature**:` field.

## Success criteria

- [ ] Running `./5day.sh checkfeatures` on the current repo produces zero "no feature reference" warnings for tasks where omitting the field is legitimate per `src/templates/project/TEMPLATE-task.md`
- [ ] Running `./5day.sh checkfeatures` still flags tasks that reference a non-existent feature file (e.g. `/docs/features/core-workflow.md` when no such file exists) — the broken-link check is preserved
- [ ] The folder-vs-status mismatch warning is either removed entirely, or rewritten so that it only fires when the mismatch represents a real inconsistency (not an enhancement task on a LIVE feature)
- [ ] The script's "Best Practices" output no longer contradicts its own warnings
- [ ] The script exits 0 on a clean repo and non-zero only when a real broken-link or invalid-status issue is present
- [ ] The fix is mirrored from `docs/5day/scripts/check-alignment.sh` to `src/docs/5day/scripts/check-alignment.sh` per the dual-tree workflow
- [ ] A test run against the current repo state shows the warning count dropped substantially (record before/after counts in the task notes when working it)
- [ ] No regression: features that genuinely have invalid status fields (`Status: FOOBAR`) or missing status are still flagged

## Notes

- The script lives at `docs/5day/scripts/check-alignment.sh` (and its `src/` mirror). The relevant blocks: feature loop starts ~line 46, orphan check starts ~line 138, summary at ~line 173.
- Two design decisions to make before implementing:
  1. **Should `**Feature**:` be required on tasks?** If yes, fix the template and the orphan check stays. If no, delete the orphan-by-missing-field check and keep only the broken-link check. Recommend the latter — features are an organizing concept, not a hard dependency.
  2. **Is the folder-vs-status mismatch ever useful?** Probably not given the script itself acknowledges that backlog tasks on LIVE features are normal. Recommend removing the warning entirely; if anyone wants a "feature has no LIVE capability yet" check that's a different (cleaner) tool.
- Per `CLAUDE.md`: edit `docs/` first, run the script to confirm, then mirror to `src/`.
- Related: this script previously also tripped over `docs/features/INDEX.md`. That bug is moot now (the file is gone) but the underlying pattern — globbing `docs/features/*.md` without filtering — could re-bite if anyone drops a non-feature `.md` in there. Consider adding a defensive filename filter (skip `INDEX.md`, `TEMPLATE*`, anything not matching the expected feature naming).
- Test against the current repo: run `./5day.sh checkfeatures > /tmp/before.txt` first, make changes, run again to `/tmp/after.txt`, diff to confirm only intended warnings disappeared.

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
