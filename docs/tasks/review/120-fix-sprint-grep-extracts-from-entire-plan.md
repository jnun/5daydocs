# Task 120: Fix sprint.sh grep extracts backlog paths from entire plan

**Feature**: none
**Created**: 2026-04-03
**Depends on**: none
**Blocks**: none

## Problem

In sprint.sh, the grep that extracts backlog file paths for the move confirmation scans the entire plan file, not just the `## Commands` section. This means paths mentioned in the "Already Done", "Deferred", and "Sprint Tasks" tables are also matched. A deferred task could be accidentally moved to next/.

## Success criteria

- [x] Only backlog paths from the `## Commands` section of the sprint plan are extracted for moving
- [x] Paths mentioned in other sections (Already Done, Deferred, Sprint Tasks table) are not moved

## Notes

File to change: `docs/scripts/sprint.sh` (line 188 area)
Current code: `grep -oE "docs/tasks/backlog/[^ ]+" "$PLAN_FILE"`
Approach: extract only the content after the `## Commands` heading before grepping, e.g. `sed -n '/^## Commands/,$p' "$PLAN_FILE" | grep -oE ...`

## Completed

Fixed the grep on line 188 to first extract only content after the `## Commands` heading using `sed -n '/^## Commands/,$p'` before piping to grep. This ensures only backlog paths from move commands are extracted, not paths mentioned in other plan sections.

**Files changed:**
- `docs/scripts/sprint.sh` (line 188)
- `src/docs/5day/scripts/sprint.sh` (line 188)
