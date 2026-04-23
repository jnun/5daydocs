# Task 169: Downgrade models and reduce limits in config.sh

**Feature**: none
**Created**: 2026-04-23
**Depends on**: none
**Blocks**: Task 170, Task 171

## Problem

Task execution and code audits use opus for everything. This is the single biggest token cost driver — sonnet is ~5x cheaper and sufficient for mechanical task execution and code review. Audit passes default to 3 (up to 6 total steps), which compounds the cost. There is also no per-invocation cost cap.

**Files to change**:
- docs/5day/config.sh
- src/docs/5day/config.sh (mirror)

## Success criteria

- [x] FIVEDAY_MODEL_TASKS changed from opus to sonnet
- [x] FIVEDAY_MODEL_CODE_AUDIT changed from opus to sonnet
- [x] FIVEDAY_MODEL_DRIFT left as sonnet (haiku too weak for judgment calls)
- [x] FIVEDAY_AUDIT_MAX_PASSES changed from 3 to 2
- [x] New variable FIVEDAY_BUDGET_TASKS added (default: 5.00) — per-task USD cap
- [x] New variable FIVEDAY_BUDGET_AUDIT added (default: 3.00) — per-audit-step USD cap
- [x] src/docs/5day/config.sh is an exact copy of docs/5day/config.sh
- [x] No other files changed

## Notes

Use short model aliases (sonnet, haiku) — Claude Code resolves these to the latest version. Do not use dated IDs like claude-3-haiku-20240307, they go stale.

Keep opus for planning/define/sprint/split scripts — those are single-shot, quality-critical calls where the cost is justified. Only downgrade the high-volume scripts (tasks, audit). Drift stays on sonnet — it makes judgment calls (DONE/OUTDATED/PROCEED) where a wrong answer wastes more than the tokens saved.

The new FIVEDAY_BUDGET_* variables will be consumed by tasks.sh and audit-code.sh via `--max-budget-usd` flag (handled in tasks 170 and 171). This task only defines the config variables.
