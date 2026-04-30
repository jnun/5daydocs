# Task 178: Stub provider profiles for openai, gemini, mistral

**Feature**: none
**Created**: 2026-04-24
**Depends on**: Task 174
**Blocks**: none

## Problem

Task 174 creates `claude.sh` and `default.sh` profiles. Users who select OpenAI, Gemini, or Mistral need profile files with the correct CLI flags for their provider.

## Success criteria

- [x] `docs/5day/cli/openai.sh` defines `fiveday_run` with OpenAI/Codex CLI flags
- [x] `docs/5day/cli/gemini.sh` defines `fiveday_run` with Gemini CLI flags
- [x] `docs/5day/cli/mistral.sh` defines `fiveday_run` with Mistral CLI flags
- [x] Each profile sets reasonable defaults for prompt passing and output handling
- [x] Profiles include comments noting what's assumed vs verified
- [x] Mirror all to `src/docs/5day/cli/`

## Notes

These start as best-effort based on each CLI's documented flags. They'll be refined as we test with each provider. The `default.sh` fallback ensures nothing breaks if a profile has wrong flags.

## Completed

**Date**: 2026-04-25

### Files changed
- `docs/5day/cli/openai.sh` — new: Codex CLI profile (prompt as positional arg, `--model`, `--full-auto`)
- `docs/5day/cli/gemini.sh` — new: Gemini CLI profile (`-p` prompt, `--model`, `--sandbox`)
- `docs/5day/cli/mistral.sh` — new: Mistral CLI profile (`--model`, prompt as positional arg)
- `src/docs/5day/cli/openai.sh` — mirror
- `src/docs/5day/cli/gemini.sh` — mirror
- `src/docs/5day/cli/mistral.sh` — mirror
