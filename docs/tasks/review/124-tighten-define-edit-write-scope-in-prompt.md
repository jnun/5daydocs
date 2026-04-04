# Task 124: Tighten define.sh prompt to restrict Edit/Write to task file only

**Feature**: none
**Created**: 2026-04-03
**Depends on**: none
**Blocks**: none

## Problem

In define.sh, the AI is given Edit and Write tools with full filesystem access but the prompt only says "Do NOT make any code changes. Only update the task file." This is a soft constraint that could be violated. The prompt should explicitly name the one file it's allowed to modify.

## Success criteria

- [x] define.sh prompt explicitly states the AI may only use Edit/Write on the specific task file path
- [x] Prompt includes "Do not create or modify any other files"

## Notes

File to change: `docs/scripts/define.sh` (prompt text, around line 137)
Replace the generic "Do NOT make any code changes" with explicit scoping: "You may only use Edit/Write on the task file at $NEXT_DIR/$TASK_NAME. Do not create or modify any other files."

## Completed

Replaced the soft constraint `"Do NOT make any code changes. Only update the task file."` with explicit scoping: `"You may only use Edit/Write on the task file at $NEXT_DIR/$TASK_NAME. Do not create or modify any other files."` in both copies of define.sh.

**Files changed:**
- `docs/scripts/define.sh` (line 138)
- `src/docs/5day/scripts/define.sh` (line 138)
