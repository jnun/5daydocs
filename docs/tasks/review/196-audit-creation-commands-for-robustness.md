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

- [x] ID allocation race examined and either made safe (lock via `mkdir`
      or `noclobber`) or measured and documented as acceptable, with the
      existing file-exists guard proven sufficient
- [x] All five commands behave sanely with: missing DOC_STATE, missing
      template, descriptions containing quotes/unicode/200 chars,
      read-only docs tree — clear errors, no partial state left behind
- [x] Filename collision on truncation detected and handled (suffix or
      error), not silently refused as "another process created this"
- [x] AI flows use `fiveday_resolve_model` keys and, on Claude Code (per
      task 194 tiers), the strongest appropriate model
- [x] Fixes mirrored to `src/`; fresh install verified

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

## Completed

All five success criteria met. Chose the recommended options: a `mkdir`
lock for the race, honest errors for collisions.

**Criterion 1 — ID race:** Added `fiveday_lock`/`fiveday_unlock` to
`lib.sh` (portable `mkdir` mutex over `docs/5day/.5day-alloc.lock`).
`create-task.sh` and `create-bug.sh` now bracket
`alloc_id → create-file → bump_doc_state` in the lock. The lock is
best-effort by design — unwritable tree ⇒ proceed unlocked; a lock held
>5s (crashed run) is stolen once then abandoned; auto-released via an EXIT
trap. **Verified:** 10 parallel `newtask` runs produced 10 unique IDs
(11–20) with DOC_STATE landing exactly at 20; previously two concurrent
creates with different descriptions could share an ID.

**Criterion 2 — edge cases:**
- `DESCRIPTION="${1:-}"` in task/bug (was `"$1"` → `set -u` "unbound
  variable" crash on no-arg; now prints usage).
- `copy_template` now emits its own precise error to stderr,
  distinguishing a missing template from an unwritable destination
  (read-only tree / permission denied); callers reduced to `|| exit 1`.
- New `fiveday_slug` helper rejects descriptions that kebab-case to an
  empty slug (all-symbol/unicode) instead of writing `NNN-.md` / a hidden
  `.md`; all five commands guard on it.
- Removed `create-idea.sh`'s CLI-missing hard-fail — emit mode needs no
  binary (matches `create-feature.sh`). **Verified:** `newidea` with a
  nonexistent CLI now emits the prompt instead of aborting.
- `create-idea.sh`/`create-feature.sh` diagnostics moved to stderr so they
  aren't swallowed by the `$()` return-channel (fixed the empty-slug and
  collision messages, which were silently eaten before).

**Criterion 3 — truncation collision:** `fiveday_slug` trims the trailing
hyphen left by a 50-char cut (task/bug did not before) and the truncation
note goes to stderr. Collision messages are now honest: task/bug name the
exact path and attribute it to DOC_STATE drift (the lock rules out a
racing process); feature/idea/test name the resulting slug so a
truncation-induced collapse of two long names is visible alongside the
truncation note.

**Criterion 4 — tier-aware models:** Added `fiveday_tier_model` to
`lib.sh` — resolves via `fiveday_resolve_model` but, when nothing is
configured and the tier is `claude-code`, defaults to `opus` (strongest
appropriate for the interactive Q&A / Feynman flows). `create-feature.sh`
and `create-idea.sh` use it. Added the previously-undocumented
`MODEL_FEATURE`/`MODEL_IDEA` keys to `config`. **Verified:** empty config
on claude-code ⇒ `opus`; env/config pin wins; cursor/openai/generic ⇒
empty (they can't select a model).

**Criterion 5 — mirror + install:** All seven files
(`lib.sh`, `config`, five `create-*.sh`) mirrored byte-identical to
`src/docs/5day/`. Fresh `/tmp` install verified: `newtask`, `newbug`,
`newfeature`, `newtest` all create files and bump DOC_STATE correctly.

**Elegance:** `create-test.sh` no longer duplicates `kebab_case` inline or
redefines the color variables `lib.sh` already provides — it routes
through `fiveday_slug` and `copy_template` like the others.

### Files changed
- `docs/5day/lib.sh` — added `fiveday_slug`, `fiveday_tier_model`,
  `fiveday_lock`/`fiveday_unlock`; `copy_template` now emits precise
  stderr errors; header updated.
- `docs/5day/config` — added `MODEL_FEATURE`/`MODEL_IDEA` keys with a note
  on the claude-code strongest-model default.
- `docs/5day/scripts/create-task.sh` — `${1:-}`, slug guard, `mkdir` lock
  around allocation, honest collision message, `copy_template || exit 1`.
- `docs/5day/scripts/create-bug.sh` — same set as create-task.
- `docs/5day/scripts/create-feature.sh` — slug guard (stderr),
  `fiveday_tier_model`, `copy_template || exit 1`.
- `docs/5day/scripts/create-idea.sh` — slug guard (stderr),
  `fiveday_tier_model`, removed CLI-missing hard-fail,
  `copy_template || exit 1`.
- `docs/5day/scripts/create-test.sh` — folded into `fiveday_slug` +
  `copy_template`; dropped duplicated `kebab_case` and color redefs.
- Mirrored all of the above to `src/docs/5day/`.
- `src/.gitignore.template` and repo `.gitignore` — ignore the transient
  `docs/5day/.5day-alloc.lock/` mutex dir.
