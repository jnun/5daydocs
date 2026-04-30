# Task 177: Add AI CLI picker to setup.sh install flow

**Feature**: none
**Created**: 2026-04-24
**Depends on**: Task 174
**Blocks**: none

## Problem

When a user runs `setup.sh` to install or upgrade 5DayDocs, they should be asked which AI CLI they use. Currently `config.sh` defaults to `claude` and users have to manually edit it to change providers.

## Success criteria

- [x] `setup.sh` prompts "Which AI CLI do you use?" with options: 1) Claude, 2) OpenAI/Codex, 3) Gemini, 4) Mistral, 5) Other
- [x] Selection writes `FIVEDAY_CLI=<value>` into the installed config.sh
- [x] "Other" prompts for the CLI binary name
- [x] Default (pressing Enter) selects Claude
- [x] On upgrade, if config.sh already has a `FIVEDAY_CLI` set, shows current value and keeps it on Enter
- [x] The picker runs after directory setup but before validation

## Notes

Keep it to a single question. The picker only sets `FIVEDAY_CLI`; profile loading in config.sh (Task 174) handles everything else.

## Completed

**Date**: 2026-04-25

### Files changed
- `setup.sh` — Added "AI CLI PICKER" section (lines ~1114-1175) between legacy cleanup and validation. Prompts user to pick their AI CLI, writes selection into the installed `docs/5day/config.sh` via sed replacement of the `FIVEDAY_CLI` default value. Handles fresh install (defaults to claude) and upgrade (detects/preserves current value).
