# Task 168: Optimize config for token efficiency

**Feature**: none
**Created**: 2026-04-23
**Depends on**: none
**Blocks**: Task 169, Task 170

## Problem

AI task execution burns too many tokens. The config uses opus for everything and allows too many parallel jobs and audit passes.

**Files to change**:
- docs/5day/config.sh

**Definition of Done**:
- [ ] FIVEDAY_MODEL_TASKS changed from opus to sonnet
- [ ] FIVEDAY_MODEL_CODE_AUDIT changed from opus to sonnet
- [ ] FIVEDAY_MODEL_DRIFT changed from sonnet to haiku
- [ ] FIVEDAY_AUDIT_MAX_PASSES changed from 3 to 2
- [ ] No other files changed

## Notes

The model names used should be the short aliases (sonnet, haiku) that Claude Code resolves to the latest version. Do not use dated model IDs like claude-3-haiku-20240307 — those go stale.

After this change, mirror to src/docs/5day/config.sh.
