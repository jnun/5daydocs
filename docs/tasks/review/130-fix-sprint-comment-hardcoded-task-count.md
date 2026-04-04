# Task 130: Fix hardcoded "293+ tasks" in sprint.sh comment

**Feature**: none
**Created**: 2026-04-03
**Depends on**: none
**Blocks**: none

## Problem

sprint.sh line 5 says "Scans docs/tasks/backlog/ (293+ tasks)" which is a hardcoded number from a specific project. This file is distributed to all 5DayDocs users, so the comment should be generic.

## Success criteria

- [x] sprint.sh header comment does not contain a hardcoded task count

## Notes

File to change: `docs/scripts/sprint.sh` (line 5-6)
Replace "(293+ tasks)" with just "your backlog" or remove the parenthetical entirely.

## Completed

Removed the hardcoded "(293+ tasks)" parenthetical from the sprint.sh header comment in both copies:
- `docs/scripts/sprint.sh` (line 5)
- `src/docs/5day/scripts/sprint.sh` (line 5)

The comment now reads: `# Scans docs/tasks/backlog/, reads the codebase to check`
