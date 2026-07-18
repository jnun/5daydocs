# Task 196: Audit creation commands for robustness

**Feature**: none
**Created**: 2026-07-18
**Depends on**: 194
**Blocks**: 200

## Problem

The creation commands (`newtask`, `newbug`, `newfeature`, `newidea`,
`newtest` → `create-*.sh`) allocate IDs from `DOC_STATE.md` via a
read-increment-write that is not atomic — and the excellence audit and
parallel `tasks` runs can now create tasks concurrently, making the race
real rather than theoretical. Other risks: 50-char filename truncation can
collide two long similar descriptions; template drift between
`docs/tasks/.TEMPLATE-task.md` (src-only mirror) and what scripts assume;
DOC_STATE corruption has an error message but no recovery path. The
AI-assisted flows (`newfeature` Q&A, `newidea` Feynman protocol) predate
the model-resolution conventions and should exploit the provider tiers.

## Success criteria

- [ ] ID allocation race examined and either made safe (lock via `mkdir`
      or `noclobber`) or measured and documented as acceptable, with the
      existing file-exists guard proven sufficient
- [ ] All five commands behave sanely with: missing DOC_STATE, missing
      template, descriptions containing quotes/unicode/200 chars,
      read-only docs tree — clear errors, no partial state left behind
- [ ] Filename collision on truncation detected and handled (suffix or
      error), not silently refused as "another process created this"
- [ ] AI flows use `fiveday_resolve_model` keys and, on Claude Code (per
      task 194 tiers), the strongest appropriate model
- [ ] Fixes mirrored to `src/`; fresh install verified

## Notes

Audit bar, in priority order: efficient, functionally excellent, elegantly
coded, antifragile. Provider priority Claude Code > Cursor > OpenAI.
Templates live only under `src/` (e.g. `src/docs/tasks/.TEMPLATE-task.md`)
— remember the dual-tree rule when fixing them.

## Questions

**Status: READY**

### Already complete
The scaffolding this audit inspects is in place and partly sound:

- **Missing-DOC_STATE and missing-template checks** — `create-task.sh` and
  `create-bug.sh` verify DOC_STATE exists and route ID parsing through
  `lib.sh:alloc_id` with a clear error; all five scripts route template
  copying through `lib.sh:copy_template` with an error on failure. Correct
  as far as they go (but see the misleading-error caveat under Remaining).
- **Ordering avoids the worst partial state** — the task/bug scripts create
  the file first and bump DOC_STATE after, so a failed copy never burns an
  ID.
- **Quote/sed safety** — descriptions pass through `sed_escape` before
  substitution; `&`, `/`, `\` are handled.
- **50-char truncation with a visible note** — present in all scripts that
  build filenames from descriptions.
- **`fiveday_resolve_model` wiring (half of criterion 4)** —
  `create-feature.sh` resolves key `FEATURE` and `create-idea.sh` resolves
  `IDEA`, both passing `--model` through `fiveday_run`. However,
  `docs/5day/config` documents thirteen other `MODEL_*` keys and omits
  `MODEL_FEATURE`/`MODEL_IDEA`, so the keys are undiscoverable — add them.
- **Mirrors in sync** — the five `create-*.sh` scripts, `lib.sh`, and
  `config` are currently byte-identical between `docs/5day/` and
  `src/docs/5day/`, so the audit starts from a clean base.

### Remaining work
Everything substantive; the audit has not been performed.

1. **ID race (criterion 1)**: the existing file-exists guard is provably
   insufficient — two concurrent creates with *different* descriptions get
   the same ID from `alloc_id` but different filenames, so both pass the
   guard and both succeed, yielding duplicate IDs (DOC_STATE is bumped
   twice to the same value). Either add a lock (`mkdir` is the obvious
   portable choice) or measure and document the window as acceptable.
2. **Edge-case robustness (criterion 2)**, concrete defects found:
   - `create-task.sh:22` and `create-bug.sh:23` use `DESCRIPTION="$1"`
     under `set -u`, so running with no argument crashes with an "unbound
     variable" bash error instead of printing usage. (`create-feature`,
     `create-idea`, `create-test` use `${1:-}` correctly.)
   - Read-only docs tree: `copy_template`'s only failure message is
     "Template file not found", which is wrong when the template exists
     but `cp`/`mkdir` failed on permissions.
   - An all-unicode/symbol description kebab-cases to an empty slug,
     producing `NNN-.md` (task/bug) or a hidden `docs/features/.md`
     (feature/idea/test) — guard against empty slugs.
   - `create-idea.sh:50` hard-fails when the CLI binary is missing even
     though `fiveday_run` supports emit mode (which needs no binary);
     `create-feature.sh` correctly has no such check — remove it.
   - `create-test.sh` duplicates `kebab_case` inline and redefines the
     color variables lib.sh already provides — fold into the shared
     helpers per the elegance bar.
3. **Truncation collision (criterion 3)**: for feature/idea/test (no ID
   prefix) two long distinct names truncating to the same 50 chars collide
   into an "already exists" refusal; for task/bug the collision message
   blames "another process". Detect truncation-induced collision and
   suffix or error honestly. Also trim the trailing hyphen after
   truncation in task/bug (create-test already does).
4. **Tier-aware models (criterion 4, second half)**: branch on task 194's
   tier helper to pick the strongest model on Claude Code. 194 is
   sequenced first (it blocks this task) but is not yet implemented — do
   not start this item until 194's helper (e.g. `fiveday_ai_tier`) exists
   in `lib.sh`; the `MODEL_FEATURE`/`MODEL_IDEA` config-key addition can
   land independently.
5. **Mirror + fresh install (criterion 5)**: after fixes, copy to
   `src/docs/5day/` and verify a `/tmp` install.

### Questions for the developer
None — task is fully defined. The two either/or choices (lock vs.
documented-acceptable race; suffix vs. error on collision) are latitude
the task explicitly grants, and the recommendation in each case is noted
above (mkdir lock; honest error).
