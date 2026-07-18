# Task 194: Define AI provider capability tiers and setup selection

**Feature**: none
**Created**: 2026-07-18
**Depends on**: none
**Blocks**: 195, 196, 197, 198, 199, 200

## Problem

5DayDocs currently treats AI providers as a lowest common denominator.
`docs/5day/cli/` holds only `claude.sh` (full flag mapping: model, tools,
budget, turns, permissions, JSON output) and `default.sh` (a passthrough
that **silently drops** model, tools, budget, and turn flags). Nothing
declares what each provider can do, so scripts cannot exploit Claude Code
strengths (subagents, parallel tools, JSON output, budget caps) or degrade
honestly on Cursor/OpenAI. `setup.sh` asks which AI instruction files to
install and which CLI binary to use, but the choice does not shape what is
installed or how scripts behave.

We prioritize what people actually use: Claude Code first, Cursor second,
OpenAI third. A Claude-Code-only path (flagged at setup) is acceptable when
it outperforms the generic path — provider-agnostic is a virtue only when
it costs nothing.

## Success criteria

- [x] A provider capability matrix exists (in `docs/5day/ai/` or
      DOCUMENTATION.md) covering Claude Code, Cursor, OpenAI CLI, and
      generic: exec JSON output, subagent/parallel dispatch, tool
      restriction, budget caps, model selection, emit-mode detection
- [x] `setup.sh` records the chosen provider in `docs/5day/config`
      (e.g. `PROVIDER=claude-code`) and installs provider-specific files
      when Claude Code or Cursor is selected
- [x] `cli/` profiles exist for cursor and openai, OR the fallback to
      `default.sh` prints a one-line warning naming the dropped
      capabilities instead of silently ignoring flags
- [x] Scripts can query the tier (helper in `lib.sh`) so later audit tasks
      can branch: full orchestration on Claude Code, graceful degradation
      elsewhere
- [x] Mirrored to `src/docs/5day/` and `setup.sh`; fresh install verified
      for each provider choice

## Notes

Audit bar for this sprint, in priority order: efficient, functionally
excellent, elegantly coded, antifragile. This task gates the "maximize
smart AI models and tools" dimension of tasks 195–199 — do it first.
Emit-mode detection today keys on env vars (`CLAUDECODE`,
`CURSOR_TRACE_ID`, …) in `lib.sh:fiveday_ai_mode`; the tier system should
build on that, not duplicate it.

## Questions

**Status: READY**

### Already complete
None of the five success criteria are implemented yet, but the groundwork
they build on exists and is solid:

- **Profile loader** — `lib.sh:fiveday_load_profile` sources
  `docs/5day/cli/<provider>.sh`, falling back to `default.sh`. Clean; the
  tier system can hang off the same `FIVEDAY_CLI` value.
- **Emit-mode detection** — `lib.sh:fiveday_ai_mode` exists as described in
  Notes (env precedence, agent-session env vars, CLI-exists fallback).
- **Setup CLI picker** — `setup.sh` (~line 1408) already asks which AI CLI
  the user runs and writes `CLI=<binary>` via `fiveday_cfg_set`, with
  update-mode "keep current" handling. However: the menu offers
  Claude / OpenAI-Codex / Gemini / Mistral / Other — **there is no Cursor
  option**, and the choice writes only `CLI=`; it does not shape which
  files are installed.
- **default.sh consumes flags cleanly** — it eats `--model`, `--tools`,
  `--budget`, etc. so they don't leak to the binary, but drops them
  silently (its header comment says so). That silence is exactly what
  this task fixes.
- **Mirrors in sync** — `docs/5day/{lib.sh,config,cli/}` currently match
  `src/docs/5day/` byte-for-byte, so this task starts from a clean base.

History worth knowing: `openai.sh`, `gemini.sh`, and `mistral.sh` profiles
were created by task 178 and deliberately deleted in commit db90170
("Streamlining") because they were best-effort/unverified. Don't blindly
resurrect them.

### Remaining work
All five success criteria, in full:

1. Write the capability matrix (Claude Code / Cursor / OpenAI CLI /
   generic × JSON output, subagent dispatch, tool restriction, budget
   caps, model selection, emit detection).
2. Extend the `setup.sh` picker: add a Cursor option, record the provider
   tier in `docs/5day/config` alongside `CLI=`, and let the choice drive
   provider-specific installation (see Q3). Keep Gemini/Mistral choices
   mapped to the generic tier.
3. Add the one-line dropped-capabilities warning to `default.sh` (and a
   cursor/openai profile only per Q2's resolution).
4. Add a tier-query helper to `lib.sh` (e.g. `fiveday_ai_tier`) that
   tasks 195–199 can branch on.
5. Mirror everything to `src/docs/5day/` + `setup.sh`, then run a fresh
   `/tmp` install once per provider choice.

### Questions for the developer
1. How should the new provider key relate to the existing `CLI=` key —
   two keys or one? (Suggestion: keep `CLI=` as the binary name driving
   `fiveday_load_profile`, and add `PROVIDER=` as the capability-tier
   identity, exactly as the success criterion's example implies. Have the
   tier helper read `PROVIDER` first and fall back to inferring from
   `CLI` (claude→claude-code, cursor-agent→cursor, codex→openai,
   else→generic) so existing installs that upgrade without re-running the
   picker still resolve a sane tier.)
2. Criterion 3 is an OR — new cursor/openai profiles, or the default.sh
   warning? (Suggestion: ship the warning unconditionally — it's cheap,
   antifragile, and covers every unknown CLI, satisfying the criterion on
   its own. Add a `cursor.sh` profile only if its flags can be verified
   against a real `cursor-agent` install, since Cursor is priority #2;
   skip openai/gemini/mistral — unverified stubs were already tried and
   removed in db90170.)
3. What concretely are the "provider-specific files" setup.sh installs
   when Claude Code or Cursor is selected? (Suggestion: no new file
   kinds — wire the provider choice into the existing AI-instruction-file
   menu so choosing Claude Code pre-selects/creates `CLAUDE.md` and
   choosing Cursor pre-selects `.cursorrules`, plus any `cursor.sh`
   profile from Q2. This reuses the prepend-never-clobber machinery
   already in setup.sh and avoids inventing new distributed content.)

## Completed

Resolved all three developer questions along the suggested lines:
- **Q1** — two keys. `CLI=` keeps driving `fiveday_load_profile`; new
  `PROVIDER=` carries the capability tier. `fiveday_ai_tier` reads
  `PROVIDER` first, else infers from `CLI` (claude→claude-code,
  cursor-agent→cursor, codex→openai, else→generic). setup.sh derives the
  tier with the *identical* case block so config and library never drift.
- **Q2** — shipped the unconditional `default.sh` warning; skipped
  cursor/openai profiles (flags unverified; unverified stubs were removed
  in db90170). Cursor therefore runs on `default.sh` today and gets the
  warning like any other unprofiled CLI.
- **Q3** — reused `setup_ai_file` (prepend-never-clobber). After the CLI
  picker, choosing Claude Code offers to create `CLAUDE.md`, Cursor offers
  `.cursorrules`; generic tiers get no offer. No new distributed content.

The `default.sh` warning fires once per shell session and only when a
dropped flag actually carried a value, naming exactly what was dropped.

Fresh `/tmp` installs verified for all three menu paths: Claude
(`PROVIDER=claude-code`, `CLAUDE.md` created), Cursor
(`CLI=cursor-agent`, `PROVIDER=cursor`, `.cursorrules` created), and
Gemini (`CLI=gemini`, `PROVIDER=generic`, no provider-file offer).

### Files changed
- `docs/5day/ai/provider-capabilities.md` — new capability matrix (Claude
  Code / Cursor / OpenAI / generic × JSON output, subagent dispatch, tool
  restriction, budget caps, model selection, emit detection).
- `docs/5day/lib.sh` — added `fiveday_ai_tier`, auto-loads `FIVEDAY_PROVIDER`
  from config, documented in the header.
- `docs/5day/cli/default.sh` — warns once, to stderr, naming dropped
  capabilities instead of silently ignoring flags.
- `docs/5day/config` — added documented `PROVIDER=` key.
- `setup.sh` — added Cursor to the CLI picker, records `PROVIDER=`,
  offers the provider-matched instruction file.
- Mirrored to `src/docs/5day/{ai/provider-capabilities.md,lib.sh,
  cli/default.sh,config}` (setup.sh is a single root copy).
