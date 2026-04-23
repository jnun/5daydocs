# Task 170: Change task runner defaults and flags in tasks.sh

**Feature**: none
**Created**: 2026-04-23
**Depends on**: Task 169
**Blocks**: Task 172

## Problem

tasks.sh defaults are too permissive: 100 turns, 4 parallel jobs, drift runs by default, audit runs after every task, and there's no cost cap. These defaults waste tokens on atomic tasks. The flag interface also needs new options for opt-in drift/audit and an escape hatch for complex tasks.

**Files to change**:
- docs/5day/scripts/tasks.sh
- src/docs/5day/scripts/tasks.sh (mirror)

## Success criteria

- [x] MAX_TURNS reduced from 100 to 40
- [x] MAX_JOBS default reduced from 4 to 2
- [x] Drift default inverted: skip by default, `--drift` opt-in enables it (replaces `--no-drift`)
- [x] Audit default inverted: skip by default, `--audit` opt-in enables post-task code audit
- [x] When a task hits the turn limit: move to `blocked/`, print notice suggesting split or redefine
- [x] `--max` flag: removes turn limit AND budget cap — no guardrails, just finish the job
- [x] `--fast` redefined: `--parallel` + higher MAX_JOBS (4 instead of default 2)
- [x] Add `--max-budget-usd` flag to both CLI invocations, using `FIVEDAY_BUDGET_TASKS` from config (defined in Task 169)
- [x] src/docs/5day/scripts/tasks.sh is an exact copy of docs/5day/scripts/tasks.sh
- [x] Task prompts left as-is (trimmed separately in Task 172)
- [x] No other files changed

## How to wire up --max-budget-usd

Read FIVEDAY_BUDGET_TASKS from config.sh (already sourced). Build the flag conditionally:

```bash
_budget_args=()
[ -n "${FIVEDAY_BUDGET_TASKS:-}" ] && _budget_args=(--max-budget-usd "$FIVEDAY_BUDGET_TASKS")
```

Add `"${_budget_args[@]}"` to both CLI invocations (parallel and sequential).

## Turn limit behavior

When a task exits because it hit MAX_TURNS (exit code non-zero, no `## Completed`), move it to `blocked/` instead of leaving it in `working/`, and print:

```
✗ Task N exceeded 40 turns — too complex for atomic execution.
  → Moved to docs/tasks/blocked/TASK_NAME
  Consider: split with ./5day.sh split, or redefine with fewer goals.
```

For `--max` flag, add to argument parsing:

```bash
--max)      MAX_TURNS=""; FIVEDAY_BUDGET_TASKS="" ;;
```

Then build args conditionally:

```bash
_turns_args=()
[ -n "$MAX_TURNS" ] && _turns_args=(--max-turns "$MAX_TURNS")
```

Replace hardcoded `--max-turns "$MAX_TURNS"` in both CLI invocations with `"${_turns_args[@]}"`.

For `--fast`, redefine:

```bash
--fast)     PARALLEL=1; MAX_JOBS=4 ;;
```

Update the usage comments in the header to document `--max`, `--fast`, `--audit`, and `--drift`.

## Audit opt-in

Current behavior: audit runs unconditionally after every completed task (both parallel and sequential paths).

Add `RUN_AUDIT=0` default at top. Add `--audit` flag:

```bash
--audit)    RUN_AUDIT=1 ;;
```

Wrap both audit blocks (sequential ~line 486, parallel ~line 289) in `if [ "$RUN_AUDIT" -eq 1 ]`.

Standalone `./5day.sh review-code` is unaffected — that calls audit-code.sh directly.

## Drift flag inversion

Current behavior in argument parsing:

```bash
--no-drift) FIVEDAY_SKIP_DRIFT_CHECK=1 ;;
--fast)     PARALLEL=1; FIVEDAY_SKIP_DRIFT_CHECK=1 ;;
```

Change to: default `FIVEDAY_SKIP_DRIFT_CHECK=1` at the top, add `--drift` to unset it:

```bash
--drift)    FIVEDAY_SKIP_DRIFT_CHECK=0 ;;
--fast)     PARALLEL=1 ;;
```

Remove `--no-drift` from the case statement. Remove the "parallel mode implies no-drift" block (drift is already off). Update the usage comments in the header to show `--drift` instead of `--no-drift`.

## Notes

The drift prompt and its logic stay as-is — only the default and flag name change.

Summary of flag behavior after this task:

| Command | Behavior |
|---------|----------|
| `./5day.sh tasks` | Sequential, 40 turns, $5 cap, no drift, no audit |
| `./5day.sh tasks --parallel` | Parallel (2 jobs), same limits |
| `./5day.sh tasks --fast` | Parallel (4 jobs), same limits |
| `./5day.sh tasks --max` | Sequential, no turn/budget limit |
| `./5day.sh tasks --fast --max` | Parallel (4 jobs), no limits |
| `./5day.sh tasks --drift` | Adds drift check before each task |
| `./5day.sh tasks --audit` | Adds code audit after each task |

## Completed

All changes applied to `docs/5day/scripts/tasks.sh` and mirrored to `src/docs/5day/scripts/tasks.sh`:

- **MAX_TURNS**: 100 → 40
- **MAX_JOBS**: 4 → 2
- **Drift**: Default `FIVEDAY_SKIP_DRIFT_CHECK=1`, `--drift` opt-in (removed `--no-drift` and parallel-implies-no-drift block)
- **Audit**: Added `RUN_AUDIT=0` default, `--audit` flag, wrapped both audit blocks in conditional
- **Turn limit**: Both parallel and sequential paths move tasks to `blocked/` with guidance message when turn limit is hit
- **`--max` flag**: Uses `_NO_LIMITS` flag to clear `MAX_TURNS` and `FIVEDAY_BUDGET_TASKS` after config is sourced
- **`--fast`**: Redefined as `PARALLEL=1; MAX_JOBS=4` (no longer implies `--no-drift`)
- **Budget**: `_budget_args` built from `FIVEDAY_BUDGET_TASKS`, added to both CLI invocations
- **Turns**: `_turns_args` built conditionally, replaces hardcoded `--max-turns` in both invocations
- Updated usage comments in header

Files changed: `docs/5day/scripts/tasks.sh`, `src/docs/5day/scripts/tasks.sh`
