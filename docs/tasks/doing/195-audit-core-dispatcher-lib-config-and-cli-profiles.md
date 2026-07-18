# Task 195: Audit core dispatcher lib config and cli profiles

**Feature**: none
**Created**: 2026-07-18
**Depends on**: 194
**Blocks**: 200

## Problem

Every command flows through `5day.sh` (dispatch, `run_script`, `count_files`)
and `docs/5day/lib.sh` (config, model resolution, emit/exec routing,
provider profiles, ID allocation). A defect here multiplies across all ~26
commands. Known smells to chase: `default.sh` silently swallows provider
flags; `fiveday_ai_mode` re-reads config on every call (hot in loops);
`fiveday_emitted`/`FIVEDAY_LAST_MODE` cannot propagate out of a command
substitution — this already caused one real bug in `audit-excellence.sh`
(fixed there; other scripts may still misuse it); `run_with_timeout`'s
shell-watchdog fallback path; portability of every `sed`/`find`/`grep`
usage across macOS and Linux.

## Success criteria

- [ ] Every function in `lib.sh` and `5day.sh` audited and exercised:
      missing config, missing dirs, non-git directory, spaces in paths,
      NO_COLOR, filesystems without exec bits
- [ ] All scripts grepped for `fiveday_emitted` / `fiveday_run` inside
      command substitutions; any mode-detection misuse fixed
- [ ] shellcheck clean (or annotated with reasons) for `5day.sh`, `lib.sh`,
      and all `cli/*.sh`
- [ ] No hot-path inefficiency: config parsed once per invocation where
      possible; no repeated subprocess spawns in loops that a variable
      would cover
- [ ] Provider profile flag parity per task 194's matrix: nothing consumed
      by `claude.sh` may silently vanish in other profiles
- [ ] Fixes mirrored to `src/`; fresh install verified

## Notes

Audit bar, in priority order: efficient, functionally excellent, elegantly
coded, antifragile. Provider priority Claude Code > Cursor > OpenAI (task
194 defines the tiers). Foundation task — schedule before the command-area
audits 196–199 where practical.

## Questions

**Status: READY**

### Already complete
The audit itself is the work, so no criterion is done — but the pre-audit
verification confirms the task's premises and found a clean starting base:

- **Mirrors in sync** — `docs/5day/` matches `src/docs/5day/` byte-for-byte
  (except `tmp/`), and root `5day.sh` matches `src/5day.sh`. Fixes made here
  mirror cleanly with no drift to untangle first.
- **The `audit-excellence.sh` fix is real and correct** — it checks a
  pre-captured `AI_MODE` before the command substitution, with a comment
  explaining why `fiveday_emitted` can't be used there
  (`audit-excellence.sh:158`). Good pattern to replicate.
- **`sprint.sh:158` and `plan.sh:113` use `fiveday_emitted` correctly** —
  both call `fiveday_run` directly (not in a substitution), so the mode
  flag propagates. No fix needed there.
- **Robustness groundwork exists** — `count_files` handles empty dirs,
  spaces, and restores nullglob; `run_script` has the no-exec-bit fallback;
  `lib.sh` honours NO_COLOR; `claude.sh`'s PIPESTATUS handling is careful.
  The audit should verify these, not rebuild them.

### Remaining work
Everything, but pre-verification already located the defects the audit
should start from:

1. **Mode-detection misuse (criterion 2) — two confirmed bugs.**
   `audit-tasks.sh:125` and `audit-code.sh:402` capture `fiveday_run` in a
   command substitution with **no emit-mode guard at all**. In emit mode
   (any Claude Code/Cursor session) the emitted prompt text is parsed as
   the verdict: audit-tasks' prompt contains `DONE - ...` at line start, so
   every audited task matches DONE and is **moved to review/**; audit-code's
   prompt contains `VERDICT: PASS`, so it silently reports PASS having
   audited nothing.
2. **`run_with_timeout` cannot time out shell functions** (lib.sh:61).
   External `timeout`/`gtimeout` can't exec a shell function, and every
   timed call site passes the function `fiveday_run`
   (`audit-tasks.sh:125`, `triage.sh:134`, `tasks.sh:485`). On any system
   with coreutils timeout — i.e. all Linux — these fail instantly with
   exit 125/127, stderr suppressed by `2>/dev/null` and masked by
   `|| true`, surfacing as fake TIMEOUT/UNCLEAR verdicts. Only the
   macOS-without-coreutils watchdog path works. Also: `audit-tasks.sh:46-65`
   shadows lib.sh's `run_with_timeout` with a duplicate that has a
   different signature (no seconds argument) — consolidate on lib.sh's.
3. **shellcheck (criterion 3)** — nearly clean already; exactly two
   warnings: `5day.sh:31` SC2206 (intentional glob in `count_files` —
   annotate) and `lib.sh:180` SC1010 (quote `"done"` in FIVEDAY_STAGES).
   `cli/claude.sh` and `cli/default.sh` are clean.
4. **Hot-path (criterion 4)** — confirmed: `fiveday_ai_mode` calls
   `fiveday_cfg` (awk + tail subprocesses) on every `fiveday_run`, which
   loops in audit-tasks/triage/tasks; lib.sh's auto-load block spawns
   `fiveday_cfg` four more times per source; `sed_inplace` runs
   `sed --version` per call. Cache config once per invocation.
5. **Function-by-function audit (criterion 1)** — remaining smells found in
   passing, to fold in: `5day.sh` defines its own colours and ignores
   NO_COLOR (lib.sh honours it — inconsistent); `fiveday_cfg_set` breaks on
   values containing `|` or `&` (unescaped in the sed replacement);
   `audit-tasks.sh:39` hard-requires the CLI binary even when emit mode
   would apply.
6. **Provider parity (criterion 5)** — waits on task 194's matrix, which
   does not exist yet. Sequencing is already declared (`Depends on: 194`);
   do criteria 1–4 and 6 regardless, parity strictly after 194 lands.
7. **Mirror + fresh install (criterion 6)** — after fixes.

### Questions for the developer
1. How should `run_with_timeout` handle shell functions — restore the
   timeout guarantee or accept a two-path helper? (Suggestion: branch on
   `type -t "$1"` — external commands keep coreutils `timeout`; functions
   take the existing watchdog path, which already works for them. This
   keeps the guarantee everywhere without `export -f`/`bash -c` gymnastics,
   and lets `audit-tasks.sh` drop its divergent local copy.)
2. In emit mode, should `audit-tasks.sh` and `audit-code.sh` emit a
   combined prompt or refuse and require exec mode? (Suggestion: follow
   the proven in-repo pattern — `triage.sh:59` emits one combined prompt
   handing the whole loop to the surrounding agent, and
   `audit-excellence.sh:160` guards via pre-captured `AI_MODE` before any
   command substitution. Emitting keeps the commands usable inside agent
   sessions, which is where the confirmed bugs bite today; refusing would
   be safe but strictly less capable.)
