# Task 197: Audit planning and definition commands

**Feature**: none
**Created**: 2026-07-18
**Depends on**: 194
**Blocks**: 200

## Problem

The planning commands (`find`, `plan`, `define`, `sprint`, `split`,
`review-sprint`, `triage`, `audit` → their scripts) are the AI-heaviest
surface: prompt quality and provider exploitation determine output quality.
They were built incrementally and vary in emit/exec handling, model keys,
MAX_TURNS, log handling, and completion signals. Specific concerns:
`sprint.sh` pre-finds child tasks by grepping `"Task $PARENT_ID"` — fragile
text matching; `define` now stamps `Status: READY` as the gate `tasks`
enforces — the contract between them must be audited as a pair; `audit`
(audit-tasks.sh) overlaps `define` in purpose (both examine next/) and the
distinction should be justified or collapsed.

## Success criteria

- [ ] Consistent emit/exec behavior across all eight commands: emit prompts
      are complete enough for the surrounding agent to act alone; exec
      parses results robustly with actionable failure messages
- [ ] Every AI prompt audited: states role, inputs, output contract, and a
      parseable completion signal; no prompt relies on the model guessing
      file layouts it wasn't given
- [ ] The define→READY→tasks gate contract verified end to end, including
      what happens to tasks that fail the gate
- [ ] On Claude Code (task 194 tiers), parallel/subagent dispatch is used
      where it materially helps (e.g. `define` reviewing N tasks in
      parallel subagents); generic providers degrade to sequential
- [ ] define vs audit overlap resolved: merge, differentiate clearly in
      help text, or document why both exist
- [ ] Fixes mirrored to `src/`; fresh install verified

## Notes

Audit bar, in priority order: efficient, functionally excellent, elegantly
coded, antifragile. Provider priority Claude Code > Cursor > OpenAI; a
Claude-Code-only enhancement is acceptable when it beats the generic path
and degrades cleanly elsewhere.

## Questions

**Status: READY**

### Already complete
The audit itself hasn't been done, but a real base exists and part of
criterion 3's machinery is already in place:

- **define→READY→tasks gate exists and is coherent** — `define.sh` stamps
  `**Status: READY**` (or BLOCKED/DONE) via the ## Questions section and
  moves files accordingly (exec mode: shell greps the verdict and moves;
  emit mode: the move instructions are folded into the prompt).
  `tasks.sh` (~line 139) skips any next/ task without a `Status: READY`
  verdict, prints which were skipped, points at `./5day.sh define`, and
  offers `--force`. No-verdict tasks stay in next/ with a clear message.
  What remains is the *audit* of this contract, and it will find work: all
  the greps match `Status: READY` / `Status: BLOCKED` anywhere in the
  file, so a task whose body merely quotes the verdict vocabulary (as the
  195–199 audit tasks do) can false-positive.
- **Five of eight commands are already mode-aware** — define, plan,
  sprint, split, and triage all branch on `fiveday_ai_mode`/
  `fiveday_emitted` and fold file-move instructions into emit prompts.
  `find.sh` pins exec for --think/--work deliberately (its header comment
  defers mode conversion to task 191, now in backlog).
- **Mirrors clean** — all eight scripts are currently byte-identical
  between `docs/5day/scripts/` and `src/docs/5day/scripts/`, so the audit
  starts from a synced base.

### Remaining work
Everything except the gate mechanism itself. Concrete defects already
visible that the audit must fix:

1. **`audit-tasks.sh` is destructive in emit mode.** It has no emit
   guard: inside an agent session `fiveday_run` emits the prompt to
   stdout, which is captured as the `verdict`, and since the prompt's own
   rubric lines start with `DONE - …`, the parser reads verdict DONE and
   `git mv`s every audited task to review/. Running `./5day.sh audit`
   from Claude Code would mass-move the backlog. Highest-priority fix.
2. **`review-sprint.sh` is not mode-aware** — no emit handling, prints a
   misleading "Sprint review complete" success block after merely
   emitting a prompt, and its preflight hard-fails when the CLI binary is
   missing even though lib.sh deliberately falls back to emit.
3. **Prompt contract audit** (criterion 2): review-sprint's prompt has no
   parseable completion signal; find.sh's review-stage prompt defines
   VERIFIED / NOT COMPLETE phrases the script never parses (routing keys
   only on `## Completed` / `## Blocked Analysis`); sprint.sh's plan
   parsing greps backlog paths out of the ## Commands section and fails
   soft. Each needs the role/inputs/contract/signal check.
4. **Gate fragility** (criterion 3): make the verdict greps anchor on the
   ## Questions section (or line-anchored `**Status: X**`) so body text
   can't false-positive; verify the full end-to-end path including the
   no-verdict and --force branches.
5. **sprint.sh parent matching**: replace the fragile
   `grep "Task $PARENT_ID\|parent.*$PARENT_ID"` pre-find (matches "Task
   19" inside "Task 192", and any prose mentioning the number) with a
   stricter pattern or a structured Parent field; it also runs the same
   grep twice (once for names, once for count).
6. **Tier-based dispatch** (criterion 4): blocked on task 194's
   `fiveday_ai_tier` helper, which is not yet implemented (no PROVIDER
   key in config, no tier helper in lib.sh). 194 is queued ahead of this
   task in the same sprint and the runner executes in ID order, so by the
   time this task runs the helper should exist — build on whatever 194
   ships rather than the exact names its spec suggests.
7. **define vs audit** (criterion 5): help texts exist and differ (define
   = pre-sprint deep review writing ## Questions; audit = bulk verdict
   triage that moves/deletes) but neither cross-references the other or
   justifies coexistence. Note `triage.sh` overlaps audit even more
   closely (same AI verdict + move loop, interactive).
8. **Consistency sweep**: audit-tasks.sh redefines `run_with_timeout`
   locally, shadowing the lib.sh version triage.sh uses; MAX_TURNS is set
   in define/sprint/split/review-sprint but absent in find/triage/
   audit-tasks; log handling varies (fiveday_log_path vs hand-rolled
   timestamps in find.sh). Normalize per the audit bar.
9. Mirror all fixes to `src/docs/5day/scripts/` and run a fresh
   `/tmp` install (criterion 6).

### Questions for the developer
1. Does criterion 1's "consistent emit/exec across all eight" include
   converting find.sh's --think/--work modes, given task 191 (backlog)
   already owns splitting/streamlining find.sh and its exec pin is
   deliberate? (Suggestion: no — audit find.sh's prompts and failure
   messages here, keep the exec pin, and leave mode conversion to 191;
   two tasks rewriting the same 470-line script invites conflicts.)
2. Should the criterion-5 overlap resolution also cover triage.sh, which
   duplicates audit's verdict-and-move loop interactively? (Suggestion:
   yes, but only at the help-text level — differentiate all three
   (define = pre-sprint gate on next/, audit = batch cleanup of stale
   backlog/blocked work, triage = interactive version of the same) with
   cross-references, and defer any code merge of audit/triage to a
   follow-up task; this satisfies the criterion's "differentiate clearly
   in help text" option without growing this task's diff.)
