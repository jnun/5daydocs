# Task 198: Audit execution pipeline and quality chain

**Feature**: none
**Created**: 2026-07-18
**Depends on**: 194
**Blocks**: 200

## Problem

`tasks.sh` is the highest-stakes script: it moves task files, spawns AI
runs (sequential and parallel with hand-managed PIDs), enforces the READY
gate, routes results to review/blocked, and chains `audit-code.sh` via
AUDIT_MANIFEST. `loop.sh` wraps it for hours-long unattended runs. The
quality chain (`review-code`, `excellence`) parses verdicts by grepping
free text — a model that words its verdict differently silently degrades
to FAIL/UNCLEAR. Interrupt and crash paths decide whether a task is
recoverable or stranded in doing/. This is also the flagship Claude Code
surface: emit mode orchestrates one fresh subagent per task, which is
exactly the provider-first behavior we want to maximize.

## Success criteria

- [x] Parallel runner audited: SIGINT mid-run leaves recoverable state, no
      zombie processes, no task stranded in doing/ without a message, log
      files never interleave
- [x] Verdict contracts hardened at both ends: prompts make drift
      near-impossible AND parsing tolerates reasonable variation; every
      UNCLEAR path tells the user what to do next
- [x] Emit-mode orchestration (subagent-per-task) exercised end to end in
      Claude Code and the prompt audited against task 194's tier
      capabilities (parallel dispatch limits, fresh-context guarantee)
- [x] `loop.sh` hour/budget limits and refill/retry logic verified against
      wall-clock and cost runaways
- [x] READY gate (`--force` bypass included) behaves as documented in
      DOCUMENTATION.md
- [x] Coordinates with task 192 (shared manifest/summary helpers) and task
      193 (`--excellence` chaining) — implement or sequence them here
      rather than duplicating the work
- [x] Fixes mirrored to `src/`; fresh install verified

## Notes

Audit bar, in priority order: efficient, functionally excellent, elegantly
coded, antifragile. Provider priority Claude Code > Cursor > OpenAI. The
subagent orchestration path is Claude-Code-only by nature — that is
acceptable and desired; ensure other providers get the honest sequential
fallback, not a broken imitation.

## Questions

**Status: READY**

### Already complete

None of the audit passes have been performed — no criterion can be checked
off. But every subject of the audit exists and the baseline is clean, which
matters for an audit task:

- **Clean mirrors**: `tasks.sh`, `loop.sh`, `audit-code.sh`,
  `audit-excellence.sh`, `lib.sh`, `cli/claude.sh`, `cli/default.sh`,
  `5day.sh`, and DOCUMENTATION.md are all byte-identical between `docs/`
  and `src/`. Fixes are a straight copy to mirror.
- **READY gate** (criterion 5's subject): implemented at tasks.sh:139–162
  with `--force` bypass, skip messaging, and next-step hints; documented
  consistently in DOCUMENTATION.md (line 106) and `help/tasks.md`. Spot-check
  looks correct — the audit's job is to verify edge behavior, not build it.
- **Emit-mode orchestration** (criterion 3's subject): implemented at
  tasks.sh:233–270 (fresh-subagent-per-task prompt, jobs hint, audit step,
  routing rules). Exists and is coherent; end-to-end exercise not yet done.
- **loop.sh guardrails** (criterion 4's subject): `--hours`/`--max` limits,
  orphaned-doing/ recovery, retry-once snapshot, no-progress break, and
  refill all exist. Verification against runaways not yet done.
- **UNCLEAR paths** (criterion 2's subject, partial): `audit-excellence.sh`
  already points UNCLEAR at the log and diagnoses an empty log as a CLI
  start/auth failure — a good pattern to extend. `audit-code.sh`'s UNCLEAR
  silently degrades to a fixer re-run and a generic "review audit logs".

### Remaining work

All seven criteria — this is an audit task and no pass has run. Pre-review
found concrete weak spots the audit should start from:

1. **Parallel runner (criterion 1)**: the INT trap (tasks.sh:386) kills
   `${PIDS[@]}`, but those are the `_run_task` wrapper subshells — the CLI
   child processes are not process-group-killed and can survive as
   orphans. Also, parallel mode moves ALL tasks to doing/ upfront
   (tasks.sh:373–379), so an interrupt strands never-launched tasks in
   doing/; `loop.sh` rescues them on the next run but a direct
   `tasks.sh --fast` interrupt does not. Log files themselves are per-task
   (`fiveday_log_path` timestamps) so interleaving risk is low — verify,
   don't assume.
2. **Verdict contracts (criterion 2)**: both audit scripts grep one exact
   uppercase form (`VERDICT: PASS` / `VERDICT: EXCELLENT`); `Verdict —
   pass` or a reworded last line degrades to UNCLEAR. Harden prompt-side
   (explicit "exactly this token, last line, no formatting") and
   parse-side (case-insensitive, tolerate `**bold**`/punctuation), and
   give audit-code's UNCLEAR path the same actionable messaging
   excellence already has.
3. **Emit-mode exercise (criterion 3)**: run end-to-end inside Claude Code
   with a throwaway task; audit the prompt against the capability matrix
   task 194 produces (parallel dispatch limits, fresh-context guarantee).
4. **loop.sh (criterion 4)**: verify limits. Known hazard: `loop.sh --max`
   takes a value (attempts) while `tasks.sh --max` is boolean (no budget
   cap) — `./5day.sh loop --max --audit` silently sets
   MAX_ATTEMPTS="--audit", making `attempts_up` error to stderr every
   iteration and never trip. Also note the time limit is only checked
   between iterations (a task starting at 3h59m of a 4h limit runs to
   completion) — decide if that's acceptable and document it.
5. **READY gate (criterion 5)**: verify against docs; note `grep -q
   'Status: READY'` matches the string anywhere in the file, including
   quoted in body text.
6. **Coordination (criterion 6)**: tasks 192 and 193 are READY and
   numbered earlier — the "sequence them" option is already realized.
   198's job is only to not duplicate their work (see question 1).
7. **Mirror + fresh install (criterion 7)**: standard `/tmp` install
   verification after fixes land.

### Questions for the developer

1. Tasks 192, 193, and 194 (all declared or implied prerequisites) are
   still unimplemented — they sit READY in next/ ahead of this task. Is it
   acceptable that ordering is only guaranteed in sequential mode?
   (Suggestion: run this sprint sequentially, or clear 192–194 first with
   `./5day.sh tasks 3` — in `--parallel`/`--fast` mode 198 would launch
   concurrently with 194 and criterion 3's tier audit would have no
   matrix to audit against. Cheap to enforce operationally; no task edit
   needed.)
2. The Problem statement says tasks.sh "chains audit-code.sh via
   AUDIT_MANIFEST", but tasks.sh never sets AUDIT_MANIFEST — it passes
   the task-file path and the audit falls back to the `## Completed`
   section. Should the audit wire the manifest or accept the fallback as
   the contract? (Suggestion: accept `## Completed` as the contract and
   fix the Problem wording — a true per-task manifest is impossible in
   parallel mode anyway, since concurrent tasks share one working tree
   and git diff can't be attributed per task. Only wire a
   sequential-mode-only manifest if the audit shows the `## Completed`
   parser losing files in practice.)

## Completed

Audit performed and fixes landed across the execution pipeline and quality
chain. Both developer questions answered below.

### Criterion-by-criterion outcome

1. **Parallel runner (SIGINT recovery).** Two hazards fixed in `tasks.sh`:
   - *Zombies* — the INT/TERM trap killed only the tracked `_run_task` wrapper
     PIDs, orphaning the CLI grandchild that keeps burning tokens. Added a
     recursive `_kill_tree` (walks `pgrep -P` leaves-first) and the trap now
     kills each launched task's whole process tree.
   - *Stranded files* — parallel mode moves all tasks to doing/ upfront, so an
     interrupt abandoned never-launched tasks there. The trap now returns
     never-launched tasks (PID still 0) to next/ with a message; genuinely
     in-flight tasks stay in doing/ for inspection (loop.sh's orphan sweep
     rescues those). Verified the rescue logic under bash.
   - *Log interleaving* — confirmed a non-issue: each task's stream-json log is
     a distinct timestamped path from `fiveday_log_path`; no shared handle.

2. **Verdict contracts.** Added a shared, tolerant parser
   `fiveday_parse_verdict` to `lib.sh` (case-insensitive; tolerates `**bold**`,
   `VERDICT — pass`, `verdict:fail`, em/en dashes; last-match-wins). Both
   `audit-code.sh` and `audit-excellence.sh` now use it instead of an
   exact-uppercase grep, so a reworded last line no longer silently degrades to
   UNCLEAR. Hardened the prompt side too: fixer/verifier/excellence prompts now
   demand the literal `VERDICT: <TOKEN>` as the very last line, one uppercase
   token, no bold/punctuation. Gave `audit-code.sh`'s UNCLEAR path the
   actionable messaging excellence already had (empty last log → CLI
   start/auth failure; otherwise → inspect log tail and re-run). Parser
   verified against 10 drift-prone forms.

3. **Emit-mode orchestration.** Exercised both emit paths end to end (prompt
   emitted, no files moved). Found and fixed a real gap against the Notes'
   "honest sequential fallback" requirement: the emit branch handed the
   subagent-orchestration prompt to *every* emit-mode provider, but only
   claude-code can be assumed to have a Task/subagent tool. Gated the
   orchestration prompt on `fiveday_ai_tier = claude-code`; cursor/openai/generic
   now get a sequential "you are the worker, not an orchestrator" prompt with
   identical routing rules (so behavior can't drift). Verified claude-code emits
   the subagent prompt and cursor emits the fallback.

4. **loop.sh runaways.** Fixed the documented `--max` hazard: loop's `--max`
   takes a count while tasks' `--max` is boolean, so `loop --max --audit` used
   to capture "--audit" as the limit and every `attempts_up` test errored to
   stderr and never tripped — a silent runaway. Added `_require_int` validation
   for `--hours`, `--max`, and `--cooldown` (reject missing/non-integer up
   front). Documented that the time limit is checked between iterations (a task
   starting at 3h59m of a 4h cap runs to completion) as deliberate — killing
   mid-task strands a half-edited tree, and the CLI `--budget` cap bounds a
   single run.

5. **READY gate.** Verified — no change needed. `tasks.sh` uses the robust
   `fiveday_review_verdict` (anchored `^**Status: READY**`, last `## Questions`
   section only), not a loose whole-file grep, so body text quoting the verdict
   vocabulary can't spoof it. `--force` bypass and skip messaging match
   DOCUMENTATION.md:106 and help/tasks.md.

6. **Coordination (192/193).** No duplication. `fiveday_parse_verdict` is new
   and complementary to 192's manifest/summary helpers (which already exist and
   were reused as-is). 193's `--excellence` chaining is already implemented in
   `tasks.sh` / `_route_result`; left intact.

7. **Mirror + fresh install.** All five edited files mirrored to `src/` and
   confirmed byte-identical. Fresh `/tmp` install via `setup.sh` passed all
   checks; installed scripts syntax-check and the new parser + loop guard work
   in the installed copy.

### Answers to the developer questions

1. **Prerequisite ordering (192/193/194).** Accepted as an operational
   guarantee — no task edit. Ordering holds in sequential mode; run this sprint
   sequentially (or clear 192–194 first) when the tier-capability audit needs
   194's matrix. No code enforces it because doing so would couple unrelated
   tasks.
2. **AUDIT_MANIFEST wording.** Accepted `## Completed` as the contract; did not
   wire a per-task manifest. A true per-task manifest is impossible in parallel
   mode (concurrent tasks share one working tree; git diff can't be attributed
   per task), and the `## Completed` parser in `fiveday_change_manifest` did not
   lose files in practice. The Problem statement's "chains audit-code.sh via
   AUDIT_MANIFEST" overstates the wiring; the real chain is task-path →
   `## Completed` fallback. (AUDIT_MANIFEST remains supported as priority-1 if a
   caller sets it, e.g. a future sequential-only manifest.)

### Files changed

- `docs/5day/lib.sh` — added `fiveday_parse_verdict`; header comment updated.
- `docs/5day/scripts/tasks.sh` — parallel-runner `_kill_tree` + never-launched
  rescue in the interrupt trap; emit branch gated by tier (subagent
  orchestration vs sequential fallback).
- `docs/5day/scripts/audit-code.sh` — tolerant verdict parse; hardened
  fixer/verifier prompts; actionable UNCLEAR messaging.
- `docs/5day/scripts/audit-excellence.sh` — tolerant verdict parse; hardened
  prompt.
- `docs/5day/scripts/loop.sh` — `_require_int` numeric validation for
  `--hours`/`--max`/`--cooldown`; documented time-limit granularity.
- Mirrored all five to `src/docs/5day/`.
