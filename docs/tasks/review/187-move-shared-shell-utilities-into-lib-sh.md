# Task 187: Move shared shell utilities into lib.sh

**Feature**: none
**Created**: 2026-06-22
**Depends on**: none
**Blocks**: none

## Problem

`sed_escape()`, `sed_inplace()`, and `move_file()` are each reimplemented in multiple scripts (create-bug, create-task, create-feature, create-idea, audit-tasks). When one copy gets a fix — like the portable sed handling — the others drift. These belong in `lib.sh` where every script can source them once.

## Success criteria

- [x] `sed_escape()`, `sed_inplace()`, and `move_file()` defined once in `lib.sh`
- [x] All scripts that used local copies now source them from `lib.sh`
- [x] Scripts that don't currently source `lib.sh` (the create-* scripts) still work after the change
- [x] All changes mirrored from docs/ to src/

## Notes

Chose option (a): create-* scripts now source lib.sh directly. The CLI profile auto-loading is harmless — it sets unused variables but doesn't interfere with script behavior. Verified with syntax checks, a live `newtask` invocation, and a fresh install test.

## Completed

Added `sed_escape()`, `sed_inplace()`, and `move_file()` to `docs/5day/lib.sh` and removed all 9 local copies across scripts.

Files changed:
- `docs/5day/lib.sh` — added three utility functions
- `docs/5day/scripts/create-task.sh` — source lib.sh, removed local sed_escape/sed_inplace
- `docs/5day/scripts/create-bug.sh` — source lib.sh, removed local sed_escape/sed_inplace
- `docs/5day/scripts/create-feature.sh` — source lib.sh, removed local sed_escape/sed_inplace
- `docs/5day/scripts/create-idea.sh` — source lib.sh, removed local sed_escape/sed_inplace
- `docs/5day/scripts/audit-tasks.sh` — removed local sed_inplace (already sourced lib.sh)
- `docs/5day/scripts/tasks.sh` — removed local move_file (already sourced lib.sh)
- `docs/5day/scripts/define.sh` — removed local move_file (already sourced lib.sh)
- `docs/5day/scripts/find.sh` — removed local move_file (already sourced lib.sh)
- `docs/5day/scripts/sprint.sh` — removed local move_file (already sourced lib.sh)
- All above mirrored to `src/`

<!--
AI: Full task-writing guidance is in docs/5day/ai/task-creation.md
-->
