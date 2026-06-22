# Task 188: Make create scripts read template files at runtime

**Feature**: none
**Created**: 2026-06-22
**Depends on**: none
**Blocks**: none

## Problem

Each create script (`create-task.sh`, `create-bug.sh`, `create-feature.sh`, `create-idea.sh`) embeds a full heredoc copy of its corresponding `.TEMPLATE-*` file. This means every format change must be made in two places — the template and the heredoc — and they've already drifted in the past (WORKING vs DOING in create-feature.sh). The scripts should read the template file and perform placeholder substitution, eliminating the duplicate.

## Success criteria

- [x] Each create script reads its `.TEMPLATE-*` file instead of embedding a heredoc copy
- [x] Placeholder substitution (ID, description, date, feature) still works correctly
- [x] `./5day.sh newtask`, `newbug`, `newfeature`, `newidea` all produce correct output
- [x] SYNC NOTEs in templates updated or removed (no longer needed if scripts read the template)
- [x] All changes mirrored from docs/ to src/

## Notes

Depends on Task 187 (shared utilities in lib.sh) — the sed helpers used for placeholder substitution should come from lib.sh rather than being reimplemented.
Template files contain HTML comments meant for humans/AI reference. The create scripts should preserve these in the generated output (they currently do since the heredoc includes them — `cat` from the template file would do the same).

## Completed

Files changed:
- `docs/5day/scripts/create-task.sh` — replaced heredoc with template read + sed substitution
- `docs/5day/scripts/create-bug.sh` — replaced heredoc with template read + sed substitution
- `docs/5day/scripts/create-feature.sh` — replaced heredoc with template read + sed substitution
- `docs/5day/scripts/create-idea.sh` — replaced heredoc with template read + sed substitution
- `docs/bugs/.TEMPLATE-bug.md` — removed SYNC NOTE
- `docs/features/.TEMPLATE-feature.md` — removed SYNC NOTE
- `docs/ideas/.TEMPLATE-idea.md` — removed SYNC NOTE
- `src/docs/5day/scripts/create-task.sh` — mirrored
- `src/docs/5day/scripts/create-bug.sh` — mirrored
- `src/docs/5day/scripts/create-feature.sh` — mirrored
- `src/docs/5day/scripts/create-idea.sh` — mirrored
- `src/docs/bugs/.TEMPLATE-bug.md` — mirrored
- `src/docs/features/.TEMPLATE-feature.md` — mirrored
- `src/docs/ideas/.TEMPLATE-idea.md` — mirrored

<!--
AI: Full task-writing guidance is in docs/5day/ai/task-creation.md
-->
