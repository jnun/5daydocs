# Task 183: Clean up coding style for remaining shipped scripts

**Feature**: none
**Created**: 2026-06-22
**Depends on**: Task 181
**Blocks**: none

## Problem

Task 181 normalized coding style across the 20 scripts in `docs/5day/scripts/`. But additional shell scripts that ship to users — the main entrypoint, the shared library, CLI profiles, and the installer — were not included. These files have the same inconsistencies (mixed shebangs, missing `set -euo pipefail`, unquoted variables) and should match the standard established by Task 181.

## Success criteria

- [x] All scripts listed below use `#!/usr/bin/env bash` and `set -euo pipefail` (or document why omitted)
- [x] All variable expansions are double-quoted to prevent word-splitting bugs
- [x] Every script passes `bash -n` and `shellcheck -S warning`
- [x] Shipped scripts are mirrored: `diff` between `docs/` and `src/` copies shows no differences
- [x] `5day.sh` mirrored: `diff 5day.sh src/5day.sh` shows no differences
- [x] `setup.sh` passes `bash -n` and `shellcheck -S warning`

## Files to audit and update

**Ship to users (edit in `docs/`, mirror to `src/`):**

1. `docs/5day/lib.sh` → `src/docs/5day/lib.sh`
2. `docs/5day/cli/claude.sh` → `src/docs/5day/cli/claude.sh`
3. `docs/5day/cli/default.sh` → `src/docs/5day/cli/default.sh`
4. `docs/5day/cli/openai.sh` → `src/docs/5day/cli/openai.sh`
5. `docs/5day/cli/gemini.sh` → `src/docs/5day/cli/gemini.sh`
6. `docs/5day/cli/mistral.sh` → `src/docs/5day/cli/mistral.sh`
7. `5day.sh` → `src/5day.sh`

**Root-level (no mirror):**

8. `setup.sh`

**Dev-only (no mirror, do not ship):**

9. `scripts/migrate-to-submodule.sh`
10. `docs/tests/test-5day.sh`
11. `docs/tests/test-ai-context.sh`
12. `docs/tests/test-check-alignment.sh`
13. `docs/tests/test-cleanup-tmp.sh`
14. `docs/tests/test-create-bug.sh`
15. `docs/tests/test-create-feature.sh`
16. `docs/tests/test-create-idea.sh`
17. `docs/tests/test-create-task.sh`
18. `docs/tests/test-find.sh`
19. `docs/tests/test-validate-tasks.sh`

## Notes

- The dual-tree rule applies to items 1–7: edit in `docs/`, test, then mirror to `src/`.
- `setup.sh` has no mirror — it lives only at the repo root.
- Dev-only scripts (items 9–19) do not ship but should still follow the same conventions for consistency.
- `lib.sh` is sourced (not executed), so it should NOT have a shebang or `set -euo pipefail` — the sourcing script provides those. Verify this is already the case; if it has them, remove them.
- Same `set -euo pipefail` risk applies: grep returning 1, pipelines with empty output. Test each script after changes.

## Completed

### Changes made

**Shipped scripts (docs/ → src/ mirrored):**
- `docs/5day/lib.sh`: Removed shebang (sourced file), added `# shellcheck shell=bash` directive
- `docs/5day/cli/openai.sh`: Added `# shellcheck disable=SC2034` for intentionally consumed but unmapped flags
- `docs/5day/cli/gemini.sh`: Same shellcheck directive
- `docs/5day/cli/mistral.sh`: Same shellcheck directive
- `docs/5day/cli/claude.sh`: No changes needed (already clean)
- `docs/5day/cli/default.sh`: No changes needed (already clean)
- `5day.sh`: `#!/bin/bash` → `#!/usr/bin/env bash`, `set -eu` → `set -euo pipefail`, removed unused GREEN color, split `local x=$(...)` to avoid SC2155, fixed arg forwarding for `profile` and `review-sprint` commands (SC2120)

**Root-level (no mirror):**
- `setup.sh`: `#!/bin/bash` → `#!/usr/bin/env bash`, expanded comment documenting why `set -euo pipefail` is intentionally omitted, `cd` with `|| exit 1` (SC2164), `grep -q` → `grep -qF` for literal matching (SC2063), added `# shellcheck source=/dev/null` for dynamic source

**Dev-only:**
- `scripts/migrate-to-submodule.sh`: `#!/bin/bash` → `#!/usr/bin/env bash`, `set -e` → `set -euo pipefail`, quoted `$REMOVED_FILES` (SC2086), quoted `"done"` in for-loop (SC1010)
- All 10 test scripts (`docs/tests/test-*.sh`): `#!/bin/bash` → `#!/usr/bin/env bash`, `set -e` → `set -euo pipefail`

### Pre-existing test failures (not caused by this task)
- `test-ai-context.sh`: ai-context.sh exits 1 on empty projects, causing `set -e` to abort (pre-existing; unrelated to pipefail)
- `test-check-alignment.sh`: check-alignment.sh has stale WORKING/LIVE status values (documented in Task 181)
- `test-create-idea.sh`: Phase 3 heading mismatch in create-idea.sh template (pre-existing)

<!--
AI TASK CREATION GUIDE

Write as you'd explain to a colleague:
- Problem: describe what needs solving and why
- Success criteria: "User can [do what]" or "App shows [result]"
- Notes: dependencies, links, edge cases

Patterns that work well:
  Filename:    120-add-login-button.md (ID + kebab-case description)
  Title:       # Task 120: Add login button (matches filename ID)
  Feature:     **Feature**: /docs/features/auth.md (or "none" or "multiple")
  Created:     **Created**: 2026-01-28 (YYYY-MM-DD format)
  Depends on:  **Depends on**: Task 42 (or "none")
  Blocks:      **Blocks**: Task 101 (or "none")

Success criteria that verify easily:
  - [ ] User can reset password via email
  - [ ] Dashboard shows total for selected date range
  - [ ] Search returns results within 500ms

Get next ID: docs/5day/DOC_STATE.md (5DAY_TASK_ID field + 1)
Full protocol: docs/5day/ai/task-creation.md
-->
