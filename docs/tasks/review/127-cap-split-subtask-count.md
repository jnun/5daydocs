# Task 127: Add sub-task count guidance to split.sh prompt

**Feature**: none
**Created**: 2026-04-03
**Depends on**: none
**Blocks**: none

## Problem

split.sh has no guidance on how many sub-tasks to create. A massive task could produce 20+ micro-tasks that are too granular to be useful. The prompt should suggest a reasonable range so the AI knows when to split into medium tasks instead of atoms.

## Success criteria

- [x] split.sh prompt includes guidance to aim for 3-10 sub-tasks
- [x] Prompt instructs the AI that if more than 10 would be needed, split into 2-3 medium tasks instead

## Notes

File to change: `docs/scripts/split.sh` (prompt text, in the RULES FOR SPLITTING section)
Add as rule 8 or similar.

## Completed

Added rule 8 to the RULES FOR SPLITTING section in the split.sh prompt: "Aim for 3–10 sub-tasks. If you would need more than 10, split into 2–3 medium-sized tasks instead of many micro-tasks. Each medium task can be split again later if needed."

Files changed:
- `docs/scripts/split.sh` — added rule 8
- `src/docs/5day/scripts/split.sh` — same change in source copy
