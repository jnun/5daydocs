# Task 126: Ensure tmp/ directory exists before sprint.sh runs

**Feature**: none
**Created**: 2026-04-03
**Depends on**: none
**Blocks**: none

## Problem

sprint.sh writes its plan to `tmp/sprint-plan.md` but nothing in the script ensures the `tmp/` directory exists. If it doesn't exist, the AI's Write tool might create it silently, but the script's post-processing grep could fail if the directory or file wasn't created.

## Success criteria

- [x] sprint.sh creates `tmp/` in its preflight section if it doesn't already exist

## Notes

File to change: `docs/scripts/sprint.sh` (preflight section, around line 51)
Add: `mkdir -p "$(dirname "$PLAN_FILE")"` before the AI runs.

## Completed

Added `mkdir -p "$(dirname "$PLAN_FILE")"` to the preflight section of sprint.sh, ensuring the `tmp/` directory is created before the AI writes the sprint plan.

**Files changed:**
- `docs/scripts/sprint.sh` — added mkdir -p at line 65 (preflight section)
- `src/docs/5day/scripts/sprint.sh` — same change in the source copy
