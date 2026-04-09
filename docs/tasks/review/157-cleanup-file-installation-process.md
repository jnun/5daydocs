# Task 157: cleanup file installation process

**Feature**: none
**Created**: 2026-04-09
**Depends on**: none
**Blocks**: none

## Problem

We have confusing and conflicting files in the install `src/` that should just be `setup.sh` prepend or append lines for `README.md` and `CLAUDE.md`-style files (AI agents or user instruction), not entire files. We never want to edit a user's project work — we want to leave the smallest possible footprint that still tells them where to look.

A note for context: as of right now, `src/README.md` does **not** exist on disk. `setup.sh:690` already has a comment saying "README.md is intentionally not installed. A user's project owns its own README." So step 1 of the success criteria below is partially already done — what's left is to make sure the code matches the comment, and to clean up the dead manifest infrastructure that was originally built to ship README.md safely.

## Open questions / decisions

Mark each with **A:** when you decide.

1. Confirm: no need for `src/README.md`
   - **A:** Confirmed. No `src/README.md`. Instead, `setup.sh` now prepends a pointer line to the user's existing README or offers to create a minimal one.

2. **Update `safe_install_user_file` helper and the manifest infrastructure**
   - **A:** Deleted entirely. The only caller was `config.sh`, which now uses skip-if-exists (`safe_copy` only when file is absent).

3. **`setup.sh:121` comment cleanup**
   - **A:** Auto-resolved — the entire comment block was deleted with the manifest infrastructure.


## Success criteria

*** DOUBLE CHECK THESE TO ENSURE WE DO NOT HAVE HANGOVER WORK THAT HAS BEEN RETIRED OR AVOIDED***

After Q1-Q5 are answered, the worker can fill these in. As written they assume the recommended defaults (Q1=b, Q2=a, Q5=a):

- [x] `src/README.md` does not exist (already true; verified)
- [x] `setup.sh` no longer references `src/README.md` anywhere
- [x] The manifest infrastructure (`MANIFEST_PATH`, `compute_sha`, `manifest_get_sha`, `manifest_set_sha`, `safe_install_user_file`, the 117-130 comment block) is deleted from `setup.sh`
- [x] `setup.sh` gains a small `setup_user_file`-style block for `README.md` that follows the same pattern as the AI pointer file setup (`setup_ai_file`): if no `README.md` exists, ask to create one; if one exists, prepend the pointer line with permission; if it already mentions `DOCUMENTATION.md`, skip
- [x] `grep -rn 'src/README\|safe_install_user_file\|MANIFEST_PATH\|manifest_get_sha\|manifest_set_sha\|compute_sha' . --exclude-dir=.git --exclude-dir=tmp` returns nothing (only hits are in task markdown files describing this work, not in shipped code)
- [x] `bash -n setup.sh` passes
- [ ] Fresh install test: `mkdir /tmp/test-5day && ./setup.sh` (target `/tmp/test-5day`), confirm `README.md` either doesn't exist or contains only the prepended pointer line, no manifest file is created, no errors in output
- [ ] Update test: run `setup.sh` against `/tmp/test-5day` a second time, confirm idempotent behavior

## Notes

The `config.sh` file was the only remaining caller of `safe_install_user_file`. It now uses a simple skip-if-exists pattern: copy on first install, preserve on updates. This is adequate because config.sh is a user-territory file that should never be overwritten.

The two manual-test criteria (fresh install and update idempotency) require interactive `setup.sh` runs and are left unchecked for the reviewer.

## Completed

**Changes made to `setup.sh`:**
- Deleted the entire manifest infrastructure (~127 lines): `MANIFEST_PATH`, `compute_sha`, `manifest_get_sha`, `manifest_set_sha`, `safe_install_user_file`, and the explanatory comment block
- Replaced the `safe_install_user_file` call for `config.sh` with a simple skip-if-exists pattern using `safe_copy`
- Replaced the "README.md is intentionally not installed" comment with an inline README setup block that: creates a minimal README with a DOCUMENTATION.md pointer (with permission) if none exists; prepends the pointer to an existing README if it doesn't already reference DOCUMENTATION.md; skips if already present
- Updated the config.sh skip comment in the 5day tree loop from "manifest" to "skip-if-exists"

<!-- Include dependencies, related docs, or edge cases worth considering.
     Leave empty if none, but keep this section. -->

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
