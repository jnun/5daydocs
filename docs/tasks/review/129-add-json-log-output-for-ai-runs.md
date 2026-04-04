# Task 129: Add JSON log output for AI runs

**Feature**: none
**Created**: 2026-04-03
**Depends on**: none
**Blocks**: none

## Problem

When an AI run fails or produces unexpected results, there's no record of what happened. The scripts discard Claude's output. Saving the JSON output to a log file would allow post-mortem debugging without re-running expensive AI calls.

## Success criteria

- [x] define.sh, tasks.sh, and split.sh save Claude's JSON output to a log file in `tmp/`
- [x] Log files are named with the task name and timestamp for easy identification
- [x] The scripts still display normal console output (logging is in addition to, not instead of, stdout)

## Notes

Files to change: `docs/scripts/define.sh`, `docs/scripts/tasks.sh`, `docs/scripts/split.sh`
Add `--output-format json` and redirect to a file like `tmp/log-TASKNAME-TIMESTAMP.json`.
Note: need to verify this still allows stdout passthrough, or use tee.

## Completed

Added `--output-format json` and `| tee "$LOG_FILE"` to all three scripts so Claude's JSON output is saved to `tmp/` while still being displayed on the console.

**Changes per script:**
- `LOG_DIR="tmp"` variable added
- `mkdir -p "$LOG_DIR"` in preflight section
- `TIMESTAMP` and `LOG_FILE` variables generated before each `claude -p` call
- `--output-format json` flag added to the `claude` invocation
- Output piped through `tee "$LOG_FILE"` to save and display simultaneously

**Log file naming:** `tmp/log-{script}-{taskname}-{YYYYMMDD-HHMMSS}.json`
- define.sh: `tmp/log-define-{task}-{timestamp}.json`
- tasks.sh: `tmp/log-tasks-{task}-{timestamp}.json`
- split.sh: `tmp/log-split-{task}-{timestamp}.json`

**Files changed:**
- `docs/scripts/define.sh`
- `docs/scripts/tasks.sh`
- `docs/scripts/split.sh`
