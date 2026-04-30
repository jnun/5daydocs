# Task 173: Remove hardcoded model selection from scripts

**Feature**: none
**Created**: 2026-04-24
**Depends on**: none
**Blocks**: none

## Problem

`config.sh` hardcodes Claude-specific model names (`opus`, `sonnet`) as defaults for every `FIVEDAY_MODEL_*` variable. All 7 scripts resolve these and pass `--model` flags accordingly. The CLI already picks the right model when no `--model` flag is given. The hardcoded defaults override that for no benefit and break non-Claude CLIs.

## Success criteria

- [x] All `FIVEDAY_MODEL_*` defaults in `config.sh` changed from `opus`/`sonnet` to `""` (empty string)
- [x] `fiveday_resolve_model` still works for users who explicitly set a model in their config
- [x] `--cheap` and `--default-model` flags removed from `tasks.sh` (no longer meaningful)
- [x] `--assist` menu in `tasks.sh` simplified to remove model-tier options
- [x] Mirror changes to `src/docs/5day/config.sh`

## Notes

The scripts already handle empty model correctly — they skip `--model` entirely and the CLI uses its own default. This is purely removing unnecessary overrides.

## Completed

Files changed:
- `docs/5day/config.sh` — all 9 `FIVEDAY_MODEL_*` defaults changed from `opus`/`sonnet` to `""`, updated comments to reflect AI-agnostic intent
- `docs/5day/scripts/tasks.sh` — removed `--default-model` and `--cheap` flags from argument parsing, usage comments, and model override logic; simplified `--assist` menu from 7 options to 4 (removed model-tier choices)
- `src/docs/5day/config.sh` — mirrored from docs/
- `src/docs/5day/scripts/tasks.sh` — mirrored from docs/

Verified:
- `fiveday_resolve_model` passes all 4 test cases (empty default, explicit model, global fallback, explicit empty override)
- Both scripts pass `bash -n` syntax check
- No hardcoded `opus`/`sonnet` remains in any script file
- `src/` mirrors are byte-identical to `docs/` versions
