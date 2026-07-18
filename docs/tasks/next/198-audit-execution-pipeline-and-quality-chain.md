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

- [ ] Parallel runner audited: SIGINT mid-run leaves recoverable state, no
      zombie processes, no task stranded in doing/ without a message, log
      files never interleave
- [ ] Verdict contracts hardened at both ends: prompts make drift
      near-impossible AND parsing tolerates reasonable variation; every
      UNCLEAR path tells the user what to do next
- [ ] Emit-mode orchestration (subagent-per-task) exercised end to end in
      Claude Code and the prompt audited against task 194's tier
      capabilities (parallel dispatch limits, fresh-context guarantee)
- [ ] `loop.sh` hour/budget limits and refill/retry logic verified against
      wall-clock and cost runaways
- [ ] READY gate (`--force` bypass included) behaves as documented in
      DOCUMENTATION.md
- [ ] Coordinates with task 192 (shared manifest/summary helpers) and task
      193 (`--excellence` chaining) — implement or sequence them here
      rather than duplicating the work
- [ ] Fixes mirrored to `src/`; fresh install verified

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
