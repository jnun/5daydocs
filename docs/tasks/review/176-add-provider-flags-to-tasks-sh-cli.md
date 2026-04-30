# Task 176: Add provider flags to tasks.sh CLI

**Feature**: none
**Created**: 2026-04-24
**Depends on**: Task 175
**Blocks**: none

## Problem

Users need to override their default AI CLI on a per-run basis. A user with `FIVEDAY_CLI=claude` may want to run a specific sprint with Mistral or OpenAI without editing config.sh.

## Success criteria

- [x] `./5day.sh tasks --claude` runs tasks using the claude.sh profile
- [x] `./5day.sh tasks --openai` runs tasks using the openai.sh profile
- [x] `./5day.sh tasks --gemini` runs tasks using the gemini.sh profile
- [x] `./5day.sh tasks --mistral` runs tasks using the mistral.sh profile
- [x] Without a provider flag, uses whatever `FIVEDAY_CLI` is set to in config.sh
- [x] The flag overrides the profile for that run only — does not modify config.sh
- [x] Mirror changes to `src/docs/5day/scripts/tasks.sh`

## Notes

The flag should re-source the matching profile from `docs/5day/cli/` to swap the `fiveday_run` function for that invocation. Also needs to update `FIVEDAY_CLI` for the session so the preflight binary check validates the right binary.

## Completed

**Files changed:**
- `docs/5day/scripts/tasks.sh` — added `--claude`, `--openai`, `--gemini`, `--mistral` flags to argument parsing; added provider override block after config.sh sourcing that sets `FIVEDAY_CLI` and re-sources the matching CLI profile; added usage examples in header comment
- `src/docs/5day/scripts/tasks.sh` — mirrored from docs/
