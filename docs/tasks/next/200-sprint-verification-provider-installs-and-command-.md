# Task 200: Sprint verification provider installs and command smoke

**Feature**: none
**Created**: 2026-07-18
**Depends on**: 194, 195, 196, 197, 198, 199
**Blocks**: none

## Problem

Tasks 194–199 each verify their own area; nothing verifies the whole
surface after the sprint lands. Per CLAUDE.md, a broken first-run
experience is a release blocker — and the sprint touches the installer,
the foundation library, and every command group at once. Verification is
currently ad-hoc (manual scripted `setup.sh` runs); it should become a
repeatable harness this sprint and every future one can rerun.

## Success criteria

- [ ] A dev-side smoke harness exists (location decided in-task; dev-only
      by default — it ships to users only if deliberately placed in `src/`)
      that: runs a scripted fresh install for each provider choice from
      task 194 (Claude Code, Cursor, generic), then in each install runs
      `--help` for every command plus an end-to-end pass of the AI-free
      commands (create/status/search/validate/cleanup)
- [ ] The harness mechanically checks `docs/5day/` ↔ `src/docs/5day/`
      mirror parity (diff, with an explicit allowlist for intentional
      divergences) so an unmirrored fix can never ship silently
- [ ] Emit-mode prompts for every AI command are generated and sanity-
      checked (non-empty, contain their file lists and completion signal)
      without spending AI calls
- [ ] Harness passes clean on the sprint's final state; failures during
      the sprint are routed back to the owning task
- [ ] Harness usage documented for future sprints (CLAUDE.md or a dev
      guide — root-level, never shipped)

## Notes

Audit bar, in priority order: efficient, functionally excellent, elegantly
coded, antifragile. Runs last — it is the sprint's exit gate. Keep the
harness itself boring and fast: plain bash, no AI spend, minutes not hours.

## Questions

**Status: READY**

### Already complete
None of the five success criteria are implemented — no smoke harness, no
mechanical parity check, no emit sanity-check, and no harness docs exist
anywhere (root `scripts/` holds only `migrate-to-submodule.sh`). But every
piece of groundwork the harness needs is in place and solid:

- **Emit mode is forceable for free** — `lib.sh:fiveday_ai_mode` honors
  `FIVEDAY_MODE=emit` (env beats config beats auto-detect), and
  `fiveday_emit_prompt` prints the full prompt to stdout with zero AI
  spend. Criterion 3 is a matter of `FIVEDAY_MODE=emit ./5day.sh <cmd>`
  plus greps.
- **Mirror baseline is clean** — `diff -r docs/5day/ src/docs/5day/`
  currently shows content-identical trees; the only divergences are
  dev-local (`DOC_STATE.md`, `tmp/`, `config.sh.bak`). Root pairs
  (`5day.sh`↔`src/5day.sh`, `DOCUMENTATION.md`↔`src/DOCUMENTATION.md`)
  are also byte-identical. That is exactly the allowlist criterion 2
  needs, and it starts from green.
- **Help surface is complete** — `docs/5day/help/` has one file per
  dispatcher command (24 of 24 in `5day.sh`'s case statement), and
  `./5day.sh help <cmd>` works today, so the `--help`-for-every-command
  sweep has a well-defined target list to enumerate from.
- **Prior art** — task 182 (in review/) is the manual version of this
  harness: its checklist (script diffs, fresh `/tmp` install, six folders
  created, no stale stage references) is a ready-made spec for what the
  scripted version must assert.

### Remaining work
All five criteria, i.e. the whole task. Concrete notes from the code:

1. Build the harness (criterion 1): scripted `setup.sh` install per
   provider choice, `help` for every dispatcher command, end-to-end pass
   of the AI-free commands (`newtask`/`newbug`/`newfeature`/`newidea`,
   `status`, `search`, `validate`, `cleanup`) inside the fresh install.
   Note `setup.sh` is interactive-only today (~31 `read` prompts, no
   headless flag) — see Q1 for the scripting mechanism. The provider
   list (Claude Code / Cursor / generic) matches what 194 is building;
   enumerate whatever picker options 194 actually ships, not this task's
   examples.
2. Mechanical parity check (criterion 2): `diff -r docs/5day/
   src/docs/5day/` with an allowlist seeded from today's known dev-local
   divergences (`DOC_STATE.md`, `tmp/`, `*.bak`). See Q2 on scope.
3. Emit sanity-check (criterion 3): for each AI command, run with
   `FIVEDAY_MODE=emit` in the throwaway install and assert non-empty
   output containing the file lists and completion signal. Two known
   hazards, both owned by task 197 and routed back there if still
   present: `audit-tasks.sh` has no emit guard and is destructive in
   emit mode, and `review-sprint.sh`'s prompt currently has no
   completion signal — the harness failing on these is it working as
   designed.
4. Run the harness on the sprint's final state and route failures to
   owning tasks (criterion 4). This is inherently last; note 197
   currently sits in blocked/ (on 194) — if it slips out of the sprint,
   its two emit hazards above become this harness's findings.
5. Document usage at the root level, never shipped (criterion 5) —
   CLAUDE.md's "Verifying an install" section is the natural home.

Dependencies 194–199 are all unfinished, but they are queued ahead of
this task in the same sprint and this task is the declared exit gate, so
that ordering is by design, not a blocker. The harness scaffolding
(parity check, emit checks, help sweep, docs) can even be built before
they land; only the provider-choice matrix and the final clean pass need
194+ in place.

### Questions for the developer
1. How should the harness script the interactive `setup.sh` — pipe a
   canned answer sequence, or add a non-interactive flag to the
   installer? (Suggestion: pipe canned answers (here-doc per provider
   choice). It keeps the shipped installer untouched and the harness
   purely dev-side; the answer files double as documentation of each
   provider path. Only add a headless flag if 194's picker rework makes
   the prompt sequence too unstable to script — and if so, that flag
   belongs to 194's setup.sh changes, not this task.)
2. Criterion 2 names only `docs/5day/` ↔ `src/docs/5day/` — should the
   parity check also cover the root mirror pairs `5day.sh`↔`src/5day.sh`
   and `DOCUMENTATION.md`↔`src/DOCUMENTATION.md`? (Suggestion: yes —
   they are part of the same edit-then-mirror contract per CLAUDE.md,
   task 182's manual checklist already treated them as mirror surface,
   and it costs two `diff` lines. Skip src-only files such as templates,
   which have no live counterpart by design.)
