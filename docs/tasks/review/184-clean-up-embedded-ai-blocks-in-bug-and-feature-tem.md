# Task 184: Clean up embedded AI blocks in bug and feature templates

**Feature**: none
**Created**: 2026-06-22
**Depends on**: none
**Blocks**: none

## Problem

The bug template (`.TEMPLATE-bug.md`) and feature template (`.TEMPLATE-feature.md`) still have large embedded HTML comment blocks with AI guidance that duplicates content in `docs/5day/ai/`. The task template was already cleaned up — replace the embedded blocks in bug and feature templates with short pointers to the appropriate AI guidance files, matching the pattern used in the task template. Also update the corresponding `create-bug.sh` and `create-feature.sh` heredocs to match.

## Success criteria

- [x] Bug template has a short AI pointer comment instead of the full embedded guide
- [x] Feature template has a short AI pointer comment instead of the full embedded guide
- [x] `create-bug.sh` and `create-feature.sh` heredocs match their respective templates
- [x] All changes mirrored from docs/ to src/

## Notes

Pattern to follow: see `docs/tasks/.TEMPLATE-task.md` (the cleaned-up version).
Bug-specific guidance (severity levels, workflow) may need its own AI file under `docs/5day/ai/` since none exists today.

## Completed

Files changed:
- `docs/5day/ai/bug-creation.md` — new AI guidance file for bugs
- `docs/5day/ai/feature-creation.md` — new AI guidance file for features
- `docs/bugs/.TEMPLATE-bug.md` — replaced embedded AI block with pointer
- `docs/features/.TEMPLATE-feature.md` — replaced embedded AI block with pointer
- `docs/5day/scripts/create-bug.sh` — heredoc updated to match template
- `docs/5day/scripts/create-feature.sh` — heredoc updated to match template
- `src/docs/5day/ai/bug-creation.md` — mirrored
- `src/docs/5day/ai/feature-creation.md` — mirrored
- `src/docs/bugs/.TEMPLATE-bug.md` — mirrored
- `src/docs/features/.TEMPLATE-feature.md` — mirrored
- `src/docs/5day/scripts/create-bug.sh` — mirrored
- `src/docs/5day/scripts/create-feature.sh` — mirrored

<!--
AI: Full task-writing guidance is in docs/5day/ai/task-creation.md
-->
