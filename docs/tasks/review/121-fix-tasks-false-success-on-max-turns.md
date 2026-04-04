# Task 121: Fix tasks.sh moves to review/ even when task is incomplete

**Feature**: none
**Created**: 2026-04-03
**Depends on**: none
**Blocks**: none

## Problem

In tasks.sh, a task is moved to review/ whenever `claude` exits with code 0, but Claude exits 0 even when it hits `--max-turns` without finishing. A half-completed task gets promoted to review/ as if it were done, hiding incomplete work from the developer.

## Success criteria

- [x] tasks.sh checks the task file for a `## Completed` section before moving to review/
- [x] If the section is missing, the task stays in working/ and is reported as incomplete (not failed, not complete)

## Notes

File to change: `docs/scripts/tasks.sh` (after line 113)
After `claude` exits 0, grep the task file for `## Completed`. If missing, leave in working/ and report as incomplete.
Add a third counter (INCOMPLETE) to the summary line.

## Completed

After `claude` exits 0, tasks.sh now greps the task file for `^## Completed`. If the section is present, the task moves to review/ as before. If missing, the task stays in working/ and is reported with a `⚠` incomplete message. Added an `INCOMPLETE` counter to the summary line.

**Files changed:**
- `docs/scripts/tasks.sh` — added `## Completed` check after exit 0, added INCOMPLETE counter to summary
