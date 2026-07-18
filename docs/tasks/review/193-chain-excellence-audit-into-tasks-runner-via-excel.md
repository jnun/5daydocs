# Task 193: Chain excellence audit into tasks runner via --excellence flag

**Feature**: none
**Created**: 2026-07-18
**Depends on**: none
**Blocks**: none

## Problem

The quality pipeline is currently two commands with a manual seam:
`./5day.sh tasks --audit` chains the correctness audit (review-code) after
each completed task, but the excellence pass must be remembered and run by
hand per task. The pass that catches "works but isn't well-engineered" is
the one most likely to be skipped under time pressure — exactly when it
matters most.

## Success criteria

- [x] `./5day.sh tasks --excellence` runs the excellence audit on each task
      that lands in review/, after the code audit when `--audit` is also set
      (excellence presumes correctness, so order matters)
- [x] Works in both exec mode (script chain in `_route_result`) and emit
      mode (extra step in the orchestration prompt, like the existing
      `--audit` step)
- [x] The `tasks.sh` interactive quality menu offers a tier that includes
      excellence (e.g. "Full quality" becomes `--max --audit --excellence`)
- [x] A BLOCKER verdict does not halt the queue — the task still routes to
      review/ with the `## Excellence` section recording the blocker, and the
      end-of-run summary counts blockers
- [x] `docs/5day/help/tasks.md` and DOCUMENTATION.md document the flag
- [x] Mirrored to `src/docs/5day/`

## Notes

Filed by the excellence audit of the excellence-audit feature itself
(2026-07-18). See `docs/5day/help/excellence.md` for verdict semantics.
The excellence pass files tasks into docs/tasks/backlog/ — when run inside
the queue, those new tasks must NOT join the current run (tasks.sh already
snapshots its task list up front, so this should hold; add a test).

## Questions

**Status: READY**

### Already complete

None of this task's action items are implemented yet — no `--excellence`
flag exists in `tasks.sh`. But every prerequisite this task chains onto is
in place and verified:

- The standalone command works end to end: `audit-excellence.sh` exists,
  `5day.sh` dispatches `excellence` to it, and the help file, protocol
  file, and DOCUMENTATION.md entry all exist and are mirrored to `src/`.
- `audit-excellence.sh` needs no changes to be chained. It already accepts
  a task-file path, honors the `AUDIT_MANIFEST` env (comment even says
  "manifest from tasks.sh"), falls back to the task's `## Completed`
  section (which `_route_result` guarantees exists before routing to
  review/), appends the `## Excellence` section itself in exec mode, and
  exits 0/0/1 for EXCELLENT/FILED/BLOCKER.
- The `--audit` chain in `_route_result` (tasks.sh ~line 342) is a clean,
  direct template for the exec-mode chain, and `_audit_step` (~line 246)
  is the template for the emit-mode step.
- `docs/` and `src/` copies of tasks.sh, audit-excellence.sh, and the help
  files are currently byte-identical, so mirroring is a straight copy.

### Remaining work

All six success criteria. Concretely:

1. Add `--excellence` to both parse loops in tasks.sh — the main loop
   (~line 22) AND the `--assist` re-parse loop (~line 65), which resets
   flags and only re-parses the ones it knows about.
2. Exec mode: in `_route_result`, after the existing `RUN_AUDIT` block and
   before `move_file` to review/, run `audit-excellence.sh` on
   `$WORKING_DIR/$name` (add an `EXCELLENCE_SCRIPT` var next to
   `AUDIT_SCRIPT`). Ordering (audit first) falls out naturally.
3. Emit mode: add an `_excellence_step` alongside `_audit_step` — an extra
   lettered step running `./5day.sh excellence docs/tasks/review/<name>`
   after the review-code step.
4. Non-halting BLOCKER: capture the script's exit code without letting
   `set -e` kill the queue (same `if bash ...` pattern as the audit),
   still move to review/, increment a BLOCKERS counter, and add it to the
   end-of-run summary line. Detect BLOCKER by grepping the appended
   `**Verdict**: BLOCKER` line in the task file rather than by exit code
   alone — exit 1 also covers the UNCLEAR/parse-failure case, which should
   not be counted as a blocker.
5. Docs: add `--excellence` to the usage list in `docs/5day/help/tasks.md`
   and to the `./5day.sh tasks` line in DOCUMENTATION.md's Commands block
   (DOCUMENTATION.md documents flags inline on that line, e.g. `--fast`,
   `--force`).
6. Update assist-menu options 3 and 4 to include `--excellence`.
7. Mirror tasks.sh, help/tasks.md, and DOCUMENTATION.md changes to `src/`.
8. From Notes: add `docs/tests/test-tasks-*.sh` following the existing
   `docs/tests/` pattern, using a stub `FIVEDAY_CLI` that files a new task
   mid-run, asserting the snapshot holds (new tasks land in backlog/ and
   never join the current run). Tests are dev-internal and not mirrored.

### Questions for the developer

None — task is fully defined. The one judgment call (distinguishing a
BLOCKER verdict from an unparseable one, since both exit 1) has an obvious
answer recorded in item 4 above.

## Completed

Chained the excellence audit into the tasks runner behind a new
`--excellence` flag, in both exec and emit modes, with a non-halting
BLOCKER path and a snapshot-safety test.

**Files changed:**

- `docs/5day/scripts/tasks.sh` (mirrored to `src/`):
  - Added `RUN_EXCELLENCE` flag to both parse loops (main + `--assist`
    re-parse), plus `--excellence` to the case arms.
  - Updated assist-menu tiers 3 & 4 to `--max --audit --excellence[ --fast]`.
  - Added `EXCELLENCE_SCRIPT` var and a `BLOCKERS` counter.
  - Exec mode: `_route_result` runs `audit-excellence.sh` after the code
    audit and before routing to review/; a BLOCKER (detected via the
    appended `- **Verdict**: BLOCKER` line, not exit code) increments
    `BLOCKERS` but never halts the queue.
  - Emit mode: added an `_excellence_step` (step d) after the review-code
    step in the orchestration prompt.
  - End-of-run summary reports blocker count via an `if` (not `&&`, which
    would have poisoned the script's exit code on blocker-free runs).
- `docs/5day/help/tasks.md` (mirrored to `src/`): documented `--excellence`
  in the usage list and added a "Quality chain" paragraph.
- `DOCUMENTATION.md` (mirrored to `src/`): noted `--audit --excellence` on
  the `./5day.sh tasks` command line.
- `docs/tests/test-tasks-excellence.sh` (dev-internal, not mirrored): new
  test with a stub CLI covering the exec-mode chain, the non-halting
  BLOCKER + blocker count, the backlog-snapshot guarantee (a task filed
  mid-run never joins the current run), and opt-in behavior. 19 assertions,
  all passing.

**Verification:** `bash docs/tests/test-tasks-excellence.sh` → 19 passed;
`bash docs/tests/test-audit-excellence.sh` → 10 passed (no regression);
`bash -n docs/5day/scripts/tasks.sh` clean. `docs/` and `src/` copies of
tasks.sh, help/tasks.md, and DOCUMENTATION.md are byte-identical.
