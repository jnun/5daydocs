# Task 128: Add elapsed time display per task in define.sh and tasks.sh

**Feature**: none
**Created**: 2026-04-03
**Depends on**: none
**Blocks**: none

## Problem

When running multi-task batches through define.sh or tasks.sh, there's no indication of how long each task took. This makes it hard for users to estimate costs and calibrate sprint sizes. Even a simple per-task timer would help.

## Success criteria

- [x] define.sh shows elapsed time after each task review completes
- [x] tasks.sh shows elapsed time after each task execution completes
- [x] Total elapsed time shown in the final summary line

## Notes

Files to change: `docs/scripts/define.sh` and `docs/scripts/tasks.sh`
Use bash `SECONDS` variable: save it before each task, compute elapsed after. Display as "Xm Ys" format.

## Completed

Added per-task and total elapsed time display using bash `SECONDS` variable.

- Each task prints `⏱ Elapsed: Xm Ys` after completion
- Final summary line includes `— total Xm Ys` at the end
- Applied to both `docs/` and `src/` copies of the scripts

Files changed:
- `docs/scripts/define.sh` — per-task timer + total in summary
- `docs/scripts/tasks.sh` — per-task timer (including on failure) + total in summary
- `src/docs/5day/scripts/define.sh` — same changes (src copy)
- `src/docs/5day/scripts/tasks.sh` — same changes (src copy)
