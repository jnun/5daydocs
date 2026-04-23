# Task 172: Trim task execution prompts in tasks.sh

**Feature**: none
**Created**: 2026-04-23
**Depends on**: Task 170
**Blocks**: none

## Problem

The task prompts in tasks.sh are ~250 words of boilerplate instructions sent as input tokens on every task invocation. A shorter prompt (~80 words) conveys the same intent with less waste.

**Files to change**:
- docs/5day/scripts/tasks.sh
- src/docs/5day/scripts/tasks.sh (mirror)

## Success criteria

- [x] Parallel prompt (in `_launch_task` function) replaced with shorter version below
- [x] Sequential prompt (in the `else` branch) replaced with same shorter version
- [x] Both prompts still reference `$WORKING_DIR/$TASK_NAME` and inline `$content`/`$TASK_CONTENT`
- [x] src/docs/5day/scripts/tasks.sh is an exact copy of docs/5day/scripts/tasks.sh
- [x] No other changes to the file (flags, defaults, logic all untouched)

## Replacement prompt

Use this for both the parallel `_launch_task` prompt and the sequential `PROMPT=`:

```
You are executing ONE task from the project queue.
CLAUDE.md is auto-loaded. Task file: $WORKING_DIR/$TASK_NAME

TASK:
---
$content
---

Rules:
- Change ONLY files relevant to this task.
- Grep/Glob first, read minimal code.
- Use Edit/Write for changes. Use Agent for research subtasks.
- Run only relevant tests/linters on files you touched.
- If blocked, document what remains in the task file.
- When done, check off items and add ## Completed section with files changed.
- Do NOT commit.
```

Note: the sequential branch uses `$TASK_CONTENT` instead of `$content`. Match the existing variable name in each location.

## Notes

This is a pure text swap — no logic changes. Task 170 handles all flag/behavior changes in the same file; this task only touches the two prompt string assignments.

## Completed

Replaced both task execution prompts (~250 words each) with the shorter ~80-word version specified in the task. No logic, flags, or defaults were changed.

Files changed:
- docs/5day/scripts/tasks.sh — parallel prompt (line ~203) and sequential prompt (line ~481) replaced
- src/docs/5day/scripts/tasks.sh — exact copy of docs/ version
