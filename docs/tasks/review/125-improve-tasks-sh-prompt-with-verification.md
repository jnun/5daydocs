# Task 125: Improve tasks.sh prompt with test and verification guidance

**Feature**: none
**Created**: 2026-04-03
**Depends on**: none
**Blocks**: none

## Problem

The tasks.sh prompt is minimal compared to the other scripts. It tells the AI to make code changes but gives no guidance on running tests, verifying changes compile or lint, or handling partial completion. The AI might make changes that break the build without realizing it.

## Success criteria

- [x] tasks.sh prompt instructs the AI to run existing tests after making changes
- [x] Prompt instructs the AI to verify changes compile/lint if the project has those tools
- [x] Prompt instructs the AI on what to do if it cannot complete all action items (document what's left in the task file)

## Notes

File to change: `docs/scripts/tasks.sh` (prompt text, around line 89-105)
Add 2-3 additional instructions to the prompt. Keep it concise — don't over-specify.

## Completed

Added two new instructions (steps 3 and 4) to the tasks.sh prompt, renumbering the existing steps to 5 and 6:

- **Step 3**: "After making changes, run any existing tests, linters, or build/compile checks relevant to the files you modified. Fix issues before moving on." — covers both test running and compile/lint verification in one instruction.
- **Step 4**: "If you cannot complete all action items, document what remains and why in the task file so the next person can pick it up." — handles partial completion.

Files changed:
- `docs/scripts/tasks.sh` (prompt text, lines 102-107)
- `src/docs/5day/scripts/tasks.sh` (same change in source copy)
