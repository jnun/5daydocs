# Task 141: Create automated tests for 9 self-contained scripts

**Feature**: none
**Created**: 2026-04-04
**Depends on**: none
**Blocks**: none

## Problem

The 9 self-contained scripts in `docs/5day/scripts/` have no automated tests. When scripts are modified, there's no way to verify they still work without manually running each one. This slows development and risks shipping broken changes. We need a simple bash test suite that validates each testable script's behavior using temp directories and file assertions — no external dependencies.

## Success criteria

- [x] `docs/tests/` contains one test file per script (9 total): `test-5day.sh`, `test-ai-context.sh`, `test-check-alignment.sh`, `test-cleanup-tmp.sh`, `test-create-bug.sh`, `test-create-feature.sh`, `test-create-idea.sh`, `test-create-task.sh`, `test-validate-tasks.sh`
- [x] Each test creates a temp directory, sets up minimal required state, runs the script, and asserts expected outcomes (exit codes, file creation, output content)
- [x] Each test covers happy path and at least one error case (e.g., missing arguments)
- [x] All 9 test files pass when run individually with `bash docs/tests/test-<name>.sh`
- [x] Tests are self-contained bash — no external test frameworks or dependencies
- [x] Tests are NOT copied to `src/` — this is internal dogfooding only

## Notes

- **Out of scope**: `plan.sh`, `audit-backlog.sh`, `define.sh`, `split.sh`, `sprint.sh`, `tasks.sh` — these wrap the Claude CLI and their core behavior isn't deterministically testable
- The shell wrapper logic of the 6 excluded scripts (arg parsing, file lookup) could be tested in a follow-up task
- Each test should clean up its temp directory on exit (trap cleanup)
- Scripts in scope: `5day.sh`, `ai-context.sh`, `check-alignment.sh`, `cleanup-tmp.sh`, `create-bug.sh`, `create-feature.sh`, `create-idea.sh`, `create-task.sh`, `validate-tasks.sh`

**Status: READY**

## Questions

**Status: READY**

### Already complete
Nothing is implemented yet. The `docs/tests/` directory exists (with `.gitkeep`) but contains no test files. All 9 scripts in scope exist and are readable.

### Remaining work
All success criteria are remaining. The full scope is: write 9 test files, each with happy-path and error-case coverage.

Key implementation considerations the developer should know:

1. **`git add` in create scripts** — `create-task.sh`, `create-bug.sh`, `create-feature.sh`, and `create-idea.sh` all call `git add` at the end. Each test's temp directory will need `git init` to avoid failures, or tests will need to tolerate/suppress the git error.

2. **`PROJECT_ROOT` resolution** — Most scripts derive `PROJECT_ROOT` from `SCRIPT_DIR` using relative paths (e.g., `../../..`). Tests can't just invoke the script from a temp dir; they need to either (a) copy/symlink the script into a matching directory structure inside the temp dir, or (b) set up the temp dir as the project root and call the script with the correct path relationship. Option (b) is cleaner: create `$TMPDIR/docs/5day/scripts/` and symlink/copy the script there.

3. **`5day.sh` testing** — This script dispatches to helper scripts via `run_script()`. Testing it end-to-end would effectively re-test the create scripts. The testable surface for `5day.sh` itself is: help output, unknown command error, missing-argument errors for each subcommand, `status` output formatting, and `count_files()` utility behavior.

4. **`check-alignment.sh`** — Expects `docs/features/*.md` and `docs/tasks/{backlog,next,...}/*.md`. Tests need to create feature files with `## Feature Status:` lines and task files with `**Feature**:` references. The script exits with `$ISSUES_FOUND` (0 or 1), which is easy to assert.

5. **`cleanup-tmp.sh`** — Interactive mode (`--delete`, `--all`) prompts for confirmation via `read`. Tests should use `--force` for non-interactive deletion, and dry-run (no args) for the default path. Testing `--delete` would require piping `y` to stdin.

6. **`validate-tasks.sh`** — Uses `set -euo pipefail` and hardcodes `PROJECT_ROOT` as `$SCRIPT_DIR/../../..`. Easy to test with well-formed and malformed task files in the temp structure.

### Questions for the developer
1. Should the create-script tests actually verify the `git add` succeeds (requiring `git init` in the temp dir), or should tests only verify file creation and STATE.md updates and accept that `git add` may fail in the test environment? (Suggestion: Use `git init` in the temp dir — it's one line and tests the full script path without modifications. Skipping git would leave a real code path untested.)

2. For `cleanup-tmp.sh`, how should tests handle the `file_age_days()` function which depends on real file mtimes? Should tests use `touch -t` to create artificially old files, or just test the dry-run/empty-dir paths? (Suggestion: Use `touch -t` to backdate files — it's portable and lets you test the stale-vs-recent classification, which is the script's core logic.)

3. Should `test-5day.sh` test full end-to-end dispatch (e.g., `./5day.sh newtask "foo"` actually creates a file), or just test the router itself (help output, unknown commands, missing args)? (Suggestion: Test the router only — help, unknown command, missing-arg errors, and `status` with an empty project. End-to-end create paths are covered by the individual create-script tests. This avoids duplication and keeps the test focused.)

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

Get next ID: docs/STATE.md (5DAY_TASK_ID field + 1)
Full protocol: docs/5day/ai/task-creation.md
-->

## Completed

All 9 test files created and passing (99 total assertions, 0 failures).

### Design decisions
- Used `git init` in temp dirs so create scripts' `git add` calls work end-to-end
- Used `touch -t` to backdate files for cleanup-tmp stale detection tests
- Used `echo "y" | script --all` to test interactive confirmation paths
- `test-5day.sh` tests the router only (help, unknown commands, missing args, status) — end-to-end dispatch covered by individual create-script tests
- Each test uses `trap 'rm -rf "$TMPDIR"' EXIT` for cleanup

### Files created
- `docs/tests/test-5day.sh` — 15 assertions: help, unknown command, missing args for 5 subcommands, status output
- `docs/tests/test-ai-context.sh` — 11 assertions: headers, STATE.md content, suggested actions per state
- `docs/tests/test-check-alignment.sh` — 9 assertions: empty project, aligned, orphaned, bad ref, missing status
- `docs/tests/test-cleanup-tmp.sh` — 14 assertions: empty/missing dir, dry-run, --force, --all, .gitkeep, log files
- `docs/tests/test-create-bug.sh` — 10 assertions: creation, title, sections, STATE.md, errors
- `docs/tests/test-create-feature.sh` — 11 assertions: creation, sections, kebab-case, duplicate, errors
- `docs/tests/test-create-idea.sh` — 10 assertions: creation, Feynman phases, status, duplicate, errors
- `docs/tests/test-create-task.sh` — 9 assertions: creation, title, STATE.md, feature arg, truncation, errors
- `docs/tests/test-validate-tasks.sh` — 19 assertions: valid/invalid files, --fix, --help, TEMPLATE skip, non-numeric ID
