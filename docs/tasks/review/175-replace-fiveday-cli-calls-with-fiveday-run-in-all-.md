# Task 175: Replace FIVEDAY_CLI calls with fiveday_run in all scripts

**Feature**: none
**Created**: 2026-04-24
**Depends on**: Task 174
**Blocks**: Task 176

## Problem

All 7 scripts call `"$FIVEDAY_CLI"` directly with Claude-specific flags inline. Task 174 created the `fiveday_run` function in CLI profiles. Now every raw `$FIVEDAY_CLI` invocation needs to be replaced with `fiveday_run` so the profile controls the flags.

## Success criteria

- [x] `tasks.sh` uses `fiveday_run` for sequential runner, parallel runner, and drift check
- [x] `define.sh`, `plan.sh`, `sprint.sh`, `split.sh` use `fiveday_run`
- [x] `audit-backlog.sh`, `audit-code.sh` use `fiveday_run`
- [x] No script contains raw `"$FIVEDAY_CLI"` invocations except the preflight binary check
- [ ] Running `./5day.sh tasks` with default Claude config works identically to before
- [x] Mirror all changes to `src/docs/5day/scripts/`

## Notes

Each script currently builds its own `_model_args`, `_turns_args`, `_budget_args` arrays. These should be passed as arguments to `fiveday_run` which handles flag translation internally.

## Completed

All 9 `$FIVEDAY_CLI` invocations across 7 scripts replaced with `fiveday_run` using provider-neutral flags.

**Flag translations applied:**
- `--allowedTools` → `--tools`
- `--permission-mode` → `--permissions`
- `--dangerously-skip-permissions` → `--skip-permissions`
- `--max-budget-usd` → `--budget`
- `--no-session-persistence` removed (handled internally by `fiveday_run` for `-p` calls)

**Files changed:**
- `docs/5day/scripts/tasks.sh` — 3 invocations (parallel, sequential, drift check) + budget arg
- `docs/5day/scripts/define.sh` — 1 invocation
- `docs/5day/scripts/plan.sh` — 1 invocation (interactive/append-system-prompt mode)
- `docs/5day/scripts/sprint.sh` — 1 invocation
- `docs/5day/scripts/split.sh` — 1 invocation
- `docs/5day/scripts/audit-code.sh` — 1 invocation + budget arg
- `docs/5day/scripts/audit-backlog.sh` — 1 invocation (restructured inline prompt to use `-p` arg form, removed unused `cli_bin` variable)
- `src/docs/5day/scripts/` — all 7 files mirrored

**Remaining:** Manual verification that `./5day.sh tasks` works identically with default Claude config.
