# Task 199: Audit maintenance commands and doc accuracy

**Feature**: none
**Created**: 2026-07-18
**Depends on**: 194
**Blocks**: 200

## Problem

The deterministic commands (`status`, `search`, `validate`, `cleanup`,
`sync`, `checkfeatures`, `ai-context`, `profile`) fail quietly rather than
loudly: their risk is drift and unguarded assumptions. `help/*.md` and
DOCUMENTATION.md describe flags that evolve (the `tasks` line has already
churned through `--parallel`/`--force` variants); `validate --fix` edits
user task files against a template that lives only in `src/`; `sync.sh`
assumes a GitHub remote and `gh`; `status` greps feature Status lines that
the feature template must actually contain.

## Success criteria

- [ ] Every `help/*.md` and the DOCUMENTATION.md command list diffed
      against the flags each script actually parses — zero drift, and a
      repeatable check for it (script or documented procedure) so drift is
      caught next time
- [ ] Each command run against three environments: empty fresh install,
      populated project, degenerate cases (no git remote, no `gh`, empty
      folders, missing DOC_STATE) — no unguarded failures, every error
      names the fix
- [ ] `validate --fix` round-trips current template output without
      mangling user content
- [ ] `sync` degrades gracefully without GitHub: clear message, documented
      exit code
- [ ] Fixes mirrored to `src/`; fresh install verified

## Notes

Audit bar, in priority order: efficient, functionally excellent, elegantly
coded, antifragile. Provider priority Claude Code > Cursor > OpenAI —
these commands are mostly AI-free, so the bar here is mechanical
excellence: fast, correct, self-explanatory when something is missing.

## Questions

**Status: READY**

### Already complete

The audit itself has not been run, but several guards the success criteria
demand already exist piecemeal — verify them during the audit rather than
rebuilding them:

- **`sync` degradation guards exist** — `sync.sh` checks git repo, main
  branch, `origin` remote, and `gh` (for `--all`) before acting, each with
  a red error and exit 1. Partial credit only: the no-remote error doesn't
  name the fix, exit codes aren't documented in `help/sync.md`, and the
  `gh` check runs *after* commit/push, so a `--all` run can half-succeed.
- **Missing-folder guards in `ai-context`, `cleanup`, `search`** — all
  three handle absent directories with friendly messages instead of
  crashing (e.g. `cleanup` exits 0 cleanly when `docs/tmp/` is missing;
  `ai-context` prints "DOC_STATE.md not found." rather than failing).
- **`status` feature grep works against the current template** —
  `cmd_status` greps `Status:.*BACKLOG` which matches the template's
  `**Status:** BACKLOG` line, so the specific fear in the Problem section
  is currently satisfied for `status` (but NOT for `checkfeatures` — see
  Remaining work).
- **Mirror is currently clean** — `docs/5day/` and `src/docs/5day/` are
  byte-identical except the expected dev-only files (`DOC_STATE.md`,
  `tmp/`) and one stray `docs/5day/config.sh.bak` that should be deleted
  during this task.

One correction to the Problem section: `validate --fix` does not read the
template file at all — its rules are hardcoded in `validate-tasks.sh`.
The round-trip criterion is still the right test (generate a task from
`src/docs/tasks/.TEMPLATE-task.md`, run `validate --fix`, diff), it just
tests hardcoded rules against the template rather than a file dependency.

### Remaining work

All five success criteria. Confirmed findings that make the scope concrete:

1. **Doc drift is real and specific.** DOCUMENTATION.md line ~106 lists
   `tasks [limit] [--fast]` but `tasks.sh` parses `--drift --audit
   --parallel --fast --max --force --assist --jobs --verbose`; the
   dispatcher usage line has the same gap. DOCUMENTATION.md's `validate
   [--fix]` omits `--dry-run`. `help/cleanup.md` omits `--force`
   (a real distinct behavior: deletes stale files *without* confirmation).
   `help/tasks.md` omits `--jobs` and `--verbose`. Fix these, then build
   the repeatable drift check.
2. **`checkfeatures` cannot parse template-generated features.**
   `check-alignment.sh` expects `## Feature Status:` headings and
   `**Status**:` (colon outside bold) capability lines, but the shipped
   template uses `**Status:** BACKLOG` (colon inside bold). A fresh user's
   first feature gets "⚠ No status found". It only works in this repo
   because our live features use the old heading format. (See Q3.)
3. **`validate --fix` round-trip risks to test explicitly:** a second
   success-criteria-style heading is silently dropped (its content merges
   into the previous section); a failed `task_title` extraction yields an
   empty title (`# Task N: `); section detection greps by prefix but
   renaming requires an exact `$`-anchored match, so `## Success Criteria
   and tests` passes detection yet never normalizes.
4. **Degenerate-environment matrix** per the criterion (fresh install,
   populated, no remote / no `gh` / empty folders / missing DOC_STATE).
   One known class of bug to hunt: empty-array expansion under `set -u`
   (e.g. `cleanup-tmp.sh` line 103 `targets=("${stale[@]}" "${recent[@]}")`)
   breaks on macOS's stock bash 3.2 when an array is empty.
5. **Document `sync` exit codes** in `help/sync.md` and move the `gh`
   precheck before the commit/push so `--all` fails whole, not half.
6. **Mirror to `src/`, delete the stray `config.sh.bak`, fresh-install
   verify.**

Dependency note: task 194 is not done yet, but these commands are almost
entirely AI-free (only `profile` invokes the CLI), so 194's tier system
barely touches this task. Sprint execution order (194 runs first) covers
the formal dependency; nothing here needs to wait on a decision from it.

### Questions for the developer

1. Should the doc-drift check ship to users or stay dev-only? (Suggestion:
   ship it as a small script wired in as `validate --docs` — users' help
   files drift the same way ours do when they touch scripts, the `validate`
   command is the natural home for "check files against expectations," and
   a shipped script mirrors cleanly to `src/` with no new command surface.)
2. For undocumented flags found during the drift diff, is the default
   direction "document reality" rather than "remove the flag"? (Suggestion:
   yes — document `cleanup --force`, `tasks --jobs/--verbose`, etc.;
   removing behavior is out of scope for an audit task and `tasks.sh`
   belongs to task 198's territory anyway. Only remove a flag if it is
   demonstrably broken.)
3. Which feature Status format is canonical — the template's
   `**Status:** BACKLOG` or the `## Feature Status:` heading that
   `check-alignment.sh` and this repo's live features use? (Suggestion:
   treat the template as canonical since it's what every new user
   generates, and make `check-alignment.sh` accept both patterns —
   antifragile per the audit bar, and it avoids rewriting existing user
   feature files.)
