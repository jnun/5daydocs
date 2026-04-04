# Task 123: Fix lexicographic sort on task files

**Feature**: none
**Created**: 2026-04-03
**Depends on**: none
**Blocks**: none

## Problem

In define.sh and tasks.sh, task files are sorted with plain `sort`, which is lexicographic. Task `9-foo.md` sorts after `10-bar.md` because "9" > "1" in string comparison. Tasks should be processed in numeric ID order.

## Success criteria

- [x] Task files in define.sh and tasks.sh are sorted by numeric ID prefix
- [x] Task 9 processes before task 10

## Notes

Files to change: `docs/scripts/define.sh` and `docs/scripts/tasks.sh`
Change `sort` to `sort -V` (version sort) or `sort -t- -k1,1n` on the `ls` pipeline.

## Completed

Changed `sort` to `sort -V` (version sort) on the `ls` pipeline in all four script files. This ensures task files like `9-foo.md` sort before `10-bar.md` by treating the numeric prefix naturally.

**Files changed:**
- `docs/scripts/define.sh` — line 55
- `docs/scripts/tasks.sh` — line 55
- `src/docs/5day/scripts/define.sh` — line 55
- `src/docs/5day/scripts/tasks.sh` — line 55
