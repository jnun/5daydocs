# Task 122: Fix define.sh treats missing verdict as READY

**Feature**: none
**Created**: 2026-04-03
**Depends on**: none
**Blocks**: none

## Problem

In define.sh, after the AI finishes, the script greps the task file for "Status: BLOCKED" or "Status: DONE". If neither is found, the else branch marks the task as READY. But if the AI hit max turns or wrote a malformed Questions section, the verdict is missing entirely. A task with no verdict should be treated as an error, not silently marked ready for execution.

## Success criteria

- [x] After claude exits 0, define.sh checks that "Status:" appears in the task file
- [x] If no verdict is found, the task is reported as an error and left in next/ (not counted as READY)

## Notes

File to change: `docs/scripts/define.sh` (lines 147-162 area)
Add a check for `grep -q "Status:" "$NEXT_DIR/$TASK_NAME"` before checking specific verdicts. If missing, fall through to an error case.

## Completed

Added a `grep -q "Status:"` guard as the first branch in the verdict-checking block. When no `Status:` line is found in the task file after a successful claude run, the script now prints an error message and leaves the task in `next/` — it is not counted as READY and falls into the error count in the summary line.

**Files changed:**
- `docs/scripts/define.sh` — added missing-verdict check (lines 148-150)
- `src/docs/5day/scripts/define.sh` — same fix applied to the src copy
