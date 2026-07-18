# Task 192: Extract shared change-manifest and summary helpers into lib.sh

**Feature**: none
**Created**: 2026-07-18
**Depends on**: none
**Blocks**: none

## Problem

`audit-code.sh` and `audit-excellence.sh` each carry a private copy of the
same two pieces of logic: the change-manifest builder (priority chain:
`AUDIT_MANIFEST` env > explicit file list > task `## Completed` section >
git working-tree diff, ~40 lines) and the Python JSON summary extractor
(~25 lines). Duplicated logic drifts — a fix to the `## Completed` parser
in one audit silently misses the other, and any future audit script would
copy the block a third time.

## Success criteria

- [x] `lib.sh` provides `fiveday_change_manifest` (emits the changed-file
      list and sets/prints the context source) and `fiveday_extract_summary`
      (JSON log path in, summary text out)
- [x] `audit-code.sh` and `audit-excellence.sh` both consume the helpers;
      their observable behavior (context sources, output, verdicts, exit
      codes) is unchanged
- [x] Both scripts pass a stub-CLI exec test and an emit-mode test after
      the refactor
- [x] Mirrored to `src/docs/5day/` (lib.sh and both scripts)

## Notes

Filed by the excellence audit of the excellence-audit feature itself
(2026-07-18). Keep helper argument surfaces boring — positional args, no
globals beyond what lib.sh already documents in its header comment, and add
the two helpers to that header list.

## Questions

**Status: READY**

### Already complete

Nothing. `docs/5day/lib.sh` has neither helper, and both
`docs/5day/scripts/audit-code.sh` (lines 68–98, 225–252) and
`docs/5day/scripts/audit-excellence.sh` (lines 54–76, 179–193) still carry
their private copies. The `docs/` and `src/` mirrors of all three files are
currently in sync, so this is a clean starting point.

### Remaining work

All four success criteria are open:

1. Add `fiveday_change_manifest` and `fiveday_extract_summary` to
   `docs/5day/lib.sh` and list them in the header's "Provides" block. The
   two manifest builders are verbatim-identical (modulo comments), so
   extraction is mechanical. Note the helper must return two things (file
   list + context source); since `$(...)` substitution runs in a subshell,
   either print the source as a distinguishable first line or set
   documented output variables and call the helper directly — both fit the
   task's "sets/prints" wording.
2. Point both audit scripts at the helpers. Callers must keep the
   bash-3.2-safe empty-array guard (`${EXPLICIT_FILES[@]+...}`) when
   passing the explicit file list.
3. Verify both scripts in stub-CLI exec mode and emit mode
   (`FIVEDAY_MODE=emit`). No test for either audit script exists in
   `docs/tests/` today (see question 2).
4. Mirror `lib.sh` and both scripts to `src/docs/5day/`.

One wrinkle: the two summary extractors are **not** identical, so "extract
the shared copy" requires picking a canonical behavior (see question 1).

### Questions for the developer

1. The two Python summary extractors diverge in their fallback paths:
   `audit-code.sh` tries a 30-line window before the `VERDICT:` line before
   falling back to the last 2000 chars, and its regex lookahead uses `$`
   where `audit-excellence.sh` uses `\Z`. Which behavior becomes canonical
   in `fiveday_extract_summary`? (Suggestion: adopt audit-code's version —
   the VERDICT-window fallback is a strict superset that only fires when
   `## Summary` is absent, so the normal path is byte-identical for both
   scripts and the "observable behavior unchanged" criterion still holds;
   keep `\Z` since it's the stricter anchor and the two are equivalent on
   real CLI JSON output.)
2. Should the stub-CLI exec test and emit-mode test be committed as
   `docs/tests/test-audit-code.sh` / `test-audit-excellence.sh` following
   the existing `docs/tests/` conventions, or is one-off manual
   verification enough? (Suggestion: commit them — the criterion says the
   scripts must "pass" the tests, `docs/tests/` already has a
   setup/assert harness pattern to copy, and a committed test is the only
   thing that keeps the two consumers from drifting again, which is the
   whole point of this task.)

## Completed

Extracted the two duplicated blocks into `lib.sh` and pointed both audit
scripts at them.

**Decisions (answering the task's questions):**
- Q1 — Adopted audit-code's summary extractor as canonical (VERDICT-window
  fallback is a strict superset; the `## Summary` path is byte-identical for
  both scripts). Kept `\Z` as the stricter anchor. The only observable
  divergence is the final python-missing fallback message, now the generic
  `(Could not extract summary)`.
- Q2 — Committed the tests as `docs/tests/test-audit-code.sh` and
  `docs/tests/test-audit-excellence.sh`, following the existing
  setup/assert-contains/assert-exit-code harness. Tests are dev-internal
  (`src/docs/tests/` is empty and setup.sh only creates an empty folder), so
  they are not mirrored.

**Verification:**
- Both new suites: 10/10 assertions each (stub-CLI exec, emit mode,
  AUDIT_MANIFEST priority, usage/preflight errors).
- `shellcheck -x` clean on `lib.sh` (added `# shellcheck disable=SC2034` for
  the two output vars, matching the existing `FIVEDAY_STAGES` pattern).
- The other pre-existing `docs/tests` failures were confirmed to fail
  identically against committed `HEAD:lib.sh` — unrelated to this change.
- `docs/` and `src/` copies of all three files verified byte-identical.

**Files changed:**
- `docs/5day/lib.sh` — added `fiveday_change_manifest` and
  `fiveday_extract_summary`; listed both in the header "Provides" block.
- `docs/5day/scripts/audit-code.sh` — manifest block and `extract_summary`
  now call the lib helpers.
- `docs/5day/scripts/audit-excellence.sh` — same two consumers.
- `docs/tests/test-audit-code.sh` — new (dev-internal).
- `docs/tests/test-audit-excellence.sh` — new (dev-internal).
- `src/docs/5day/lib.sh`, `src/docs/5day/scripts/audit-code.sh`,
  `src/docs/5day/scripts/audit-excellence.sh` — mirrored.
