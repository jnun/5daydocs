# Task 186: Fix audit-backlog.sh naming confusion

**Feature**: none
**Created**: 2026-06-22
**Depends on**: none
**Blocks**: none

## Problem

`audit-backlog.sh` has conflicting names everywhere. The filename says "backlog", its header comment says "audit-next", it defaults to auditing `next/`, and its summary banner says "Backlog Audit". This makes it hard to understand what the script actually does or which folder it targets. The `./5day.sh audit` command should have consistent naming and clear behavior.

## Success criteria

- [x] Script filename, header comment, banner, and help text all use the same terminology
- [x] `./5day.sh help` accurately describes what `audit` does and which folder it defaults to
- [x] Running `./5day.sh audit` without arguments produces output that matches the documented default

## Notes

Decision: renamed to `audit-tasks.sh` (generic name since it audits any folder) and kept `next/` as the default (established behavior). This avoids the naming trap entirely — "audit-tasks" is accurate regardless of which folder is passed.

## Completed

Renamed `audit-backlog.sh` to `audit-tasks.sh` and made all naming consistent:

- `docs/5day/scripts/audit-tasks.sh` — renamed file; fixed header comment (`audit-next.sh` -> `audit-tasks.sh`), corrected default folder in usage (`backlog` -> `next`), replaced hardcoded "Backlog Audit" banner with dynamic `Task Audit ($folder)`, made KEEP/TIMEOUT messages use `$folder` instead of hardcoded "next", fixed error message to list all auditable folders, made summary line say "Kept in place" instead of "Kept in next"
- `src/docs/5day/scripts/audit-tasks.sh` — mirrored from docs/, old `audit-backlog.sh` removed
- `5day.sh` — `cmd_audit` now calls `audit-tasks.sh`; help text says "Audit tasks in next/ (or specified folder)"
- `src/5day.sh` — same changes mirrored
- `DOCUMENTATION.md` — updated audit command description
- `src/DOCUMENTATION.md` — same change mirrored
- `docs/tasks/next/187-move-shared-shell-utilities-into-lib-sh.md` — updated reference from `audit-backlog` to `audit-tasks`

<!--
AI: Full task-writing guidance is in docs/5day/ai/task-creation.md
-->
