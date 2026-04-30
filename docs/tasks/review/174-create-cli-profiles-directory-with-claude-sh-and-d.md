# Task 174: Create CLI profiles directory with claude.sh and default.sh

**Feature**: none
**Created**: 2026-04-24
**Depends on**: Task 173
**Blocks**: Task 175

## Problem

The 7 scripts in `docs/5day/scripts/` hardcode Claude-specific CLI flags (`--allowedTools`, `--permission-mode`, `--output-format json`, `--no-session-persistence`, `--dangerously-skip-permissions`) inline. To support multiple AI CLIs, these flags need to live in per-provider profile files that define a `fiveday_run` function.

## Success criteria

- [x] `docs/5day/cli/claude.sh` exists and defines `fiveday_run` that passes all current Claude flags (allowedTools, permission-mode, output-format, no-session-persistence, dangerously-skip-permissions, model, max-turns, budget)
- [x] `docs/5day/cli/default.sh` exists and defines `fiveday_run` with bare minimum flags (`-p` for prompt only)
- [x] `config.sh` sources the profile matching `FIVEDAY_CLI` and falls back to `default.sh`
- [x] Mirror `docs/5day/cli/` to `src/docs/5day/cli/`

## Notes

`fiveday_run` should accept a consistent interface: prompt, model (optional), max-turns (optional), tools (optional), permissions (optional), output log path (optional), and any extra args. The claude.sh implementation maps these to Claude Code flags. The default.sh implementation passes only the prompt.

## Completed

Files created:
- `docs/5day/cli/claude.sh` — defines `fiveday_run` mapping all provider-neutral flags to Claude Code CLI flags
- `docs/5day/cli/default.sh` — defines `fiveday_run` passing only `-p` prompt, silently consuming all other flags
- `src/docs/5day/cli/claude.sh` — mirror of docs copy
- `src/docs/5day/cli/default.sh` — mirror of docs copy

Files changed:
- `docs/5day/config.sh` — added CLI profile sourcing block at end (sources `cli/<FIVEDAY_CLI>.sh`, falls back to `cli/default.sh`)
- `src/docs/5day/config.sh` — mirror of docs copy
