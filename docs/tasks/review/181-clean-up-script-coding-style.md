# Task 181: Clean up script coding style

**Feature**: none
**Created**: 2026-06-22
**Depends on**: none
**Blocks**: none

## Problem

After a series of rapid improvements to the kanban workflow — removing ghost `live/` references, adding `blocked/` support everywhere, rewriting `find.sh`, updating `ai-context.sh`, and fixing `5day.sh status` — the scripts were written iteratively with inconsistent coding style. Inconsistent quoting, variable naming, and error handling across scripts makes them harder to audit, upgrade, and read correctly by future coding agents.

## Success criteria

- [x] All bash scripts use `set -euo pipefail` (or document why a script intentionally omits it)
- [x] All variable expansions are double-quoted to prevent word-splitting bugs
- [x] Functions use `local` for all local variables
- [x] Variables use `snake_case`, constants and environment variables use `UPPER_CASE`
- [x] No dead code, unused variables, or commented-out blocks remain in any script
- [x] Every script in `docs/5day/scripts/` passes `bash -n` (syntax check) and `shellcheck` (if available)
- [x] All cleaned scripts are mirrored to `src/docs/5day/scripts/` — `diff -r docs/5day/scripts/ src/docs/5day/scripts/` shows no differences

## Notes

- The dual-tree rule applies: edit in `docs/`, test, then mirror to `src/`. See CLAUDE.md for the full protocol.
- Apply current bash best practices consistently. When a convention conflicts with existing script behavior (e.g., `set -e` breaking intentional non-zero exits), document the exception rather than forcing the convention.
- Run `diff -r docs/5day/scripts/ src/docs/5day/scripts/` as a final check to catch any mirror drift.

## Per-file audit

20 scripts in `docs/5day/scripts/`. Each entry notes what needs fixing.

### Audited (10/20)

**1. ai-context.sh** (86 lines) — needs work
- `set -e` only → add `-uo pipefail`
- `#!/bin/bash` → `#!/usr/bin/env bash`
- Lines 72-74: `ls | grep | wc -l` pattern will break under `pipefail` when `ls` dir is empty (grep returns 1). Wrap with `|| true` or use `find -name '*.md' | wc -l`.
- Line 38: echo says "Active Tasks (Working)" — stale label, should say "Active Tasks (Doing)"
- No functions, so no `local` issues
- Variable naming: `BLOCKED_FILES` etc. are script-local but use UPPER_CASE — rename to lowercase

**2. audit-backlog.sh** (207 lines) — mostly clean
- `set -euo pipefail` ✓, `#!/usr/bin/env bash` ✓
- Line 24: error message says "stale, done, or undefined work in next or next" — copy-paste bug, should be "backlog or next"
- `sed_inplace` function: no local vars needed (args only) ✓
- `run_with_timeout` fallback: uses `local` ✓
- Lines 90-98: `IFS=$'\n' files=($(…))` — fragile with spaces in paths but functional since task filenames are kebab-case
- SC2207 already disabled at top for the above pattern
- Quoting is good throughout

**3. audit-code.sh** (569 lines) — clean
- `set -euo pipefail` ✓, `#!/usr/bin/env bash` ✓
- Uses `local` extensively in functions ✓
- Quoting is thorough throughout
- `extract_summary` function uses embedded Python — acceptable, `local` used for param
- No dead code
- Variable naming: `UPPER_CASE` for script-level state (`VERDICT`, `NEXT_MODE`) — borderline, but these function as quasi-globals across the loop. Leave as-is.
- No changes needed unless enforcing snake_case for all non-env vars

**4. check-alignment.sh** (171 lines) — needs work
- `set -e` only → add `-uo pipefail`
- `#!/bin/bash` → `#!/usr/bin/env bash`
- Line 25-29: `is_valid_status` has stale values — lists `WORKING` and `LIVE` instead of `DOING` and `DONE`. Missing `BLOCKED` and `DOING`.
- Line 73: `[ ! -z "$prev_heading" ]` → `[ -n "$prev_heading" ]`
- Line 82: `[ $capability_count -eq 0 ]` — unquoted, will break under `-u` if unset
- Lines 63-80: `prev_heading` and `cap_status` not declared `local` in the while-loop scope (top-level, so no function to localize to)
- No functions use `local` (only `is_valid_status`, which needs none)
- Unquoted vars in multiple `[ ]` tests throughout

**5. cleanup-tmp.sh** (163 lines) — minor fixes
- `set -e` only → add `-uo pipefail`
- `#!/bin/bash` → `#!/usr/bin/env bash`
- `file_age_days` and `format_age` use `local` ✓
- Lines 13-17: `PROJECT_ROOT` detection heuristic is fragile — checks `$SCRIPT_DIR/docs/5day/scripts` which is wrong (SCRIPT_DIR is already inside scripts/). Works by accident since that path doesn't exist, so it falls through to the correct `dirname` chain.
- `MODE` and `TMP_DIR` are script-level but UPPER_CASE — rename to lowercase
- `stale`, `recent`, `total_count` are correctly lowercase ✓
- No dead code

**6. create-bug.sh** (163 lines) — minor fixes
- `set -e` only → add `-uo pipefail`
- `#!/bin/bash` → `#!/usr/bin/env bash`
- `sed_escape` and `sed_inplace` functions: pure arg handling, no `local` needed ✓
- Quoting is good throughout
- Atomic write via `TEMP_STATE` is a nice pattern ✓
- Variable naming: all UPPER_CASE for script-level — rename non-constants to lowercase (`highest_id`, `new_id`, `description`, `filename`, etc.)
- No dead code

**7. create-feature.sh** (163 lines) — minor fixes
- `set -e` only → add `-uo pipefail`
- `#!/bin/bash` → `#!/usr/bin/env bash`
- Same patterns as create-bug.sh
- `sed_escape` and `sed_inplace` duplicated from create-bug.sh (and several others) — not a style issue per se, but noted
- Variable naming: same UPPER_CASE → lowercase rename needed
- No dead code

**8. create-idea.sh** (148 lines) — minor fixes
- `set -e` only → add `-uo pipefail`
- `#!/bin/bash` → `#!/usr/bin/env bash`
- Same patterns as other create-* scripts
- Variable naming: UPPER_CASE → lowercase for non-constants
- No dead code

**9. create-task.sh** (170 lines) — minor fixes
- `set -e` only → add `-uo pipefail`
- `#!/bin/bash` → `#!/usr/bin/env bash`
- `FEATURE="${2:-}"` — properly defaults to empty string ✓
- Same patterns as other create-* scripts
- Variable naming: UPPER_CASE → lowercase for non-constants
- No dead code

**10. define.sh** (205 lines) — minor fixes
- `set -euo pipefail` ✓ (already added)
- `#!/bin/bash` → `#!/usr/bin/env bash`
- Line 69: `TASK_FILES=($(ls -1 ...))` — word-splitting via command substitution. Should use `while read` pattern or `mapfile`.
- `move_file` function: pure args, no local needed ✓
- Variable naming: UPPER_CASE for script-level state — rename non-constants
- No dead code

### Not yet audited (10/20)

- find.sh (485 lines)
- plan.sh (141 lines)
- profile.sh (107 lines)
- review-sprint.sh (138 lines)
- search.sh (50 lines)
- split.sh (148 lines)
- sprint.sh (247 lines)
- sync.sh (101 lines)
- tasks.sh (639 lines)
- validate-tasks.sh (309 lines)

## Think Notes

- **Reviewed**: 2026-06-22
- Split from original scope: install verification and file-mirroring checks moved to Task 182 (now in next/).
- Key risk: `set -euo pipefail` may break scripts that intentionally handle non-zero exits (e.g., grep returning 1 on no match). Implementer should test each script after adding it and document exceptions.
- 8 of the first 10 scripts need `set -euo pipefail` added; only audit-backlog.sh and audit-code.sh already have it.
- check-alignment.sh has a **correctness bug**: `is_valid_status` still lists `WORKING` and `LIVE` instead of `DOING` and `DONE`, and is missing `BLOCKED`. This is a functional fix, not just style.
- The four create-* scripts share duplicated `sed_escape`/`sed_inplace` helpers. Extracting to a shared file is out of scope for this task but worth noting.
- The `#!/bin/bash` → `#!/usr/bin/env bash` change is a portability improvement. Almost all newer scripts already use `env bash`.
