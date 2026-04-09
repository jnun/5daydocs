# Task 144: Unify templates source tree under src

**Feature**: none
**Created**: 2026-04-08
**Depends on**: none
**Blocks**: none

## Problem

`CLAUDE.md` states the rule clearly: `src/` is the distribution package, and anything that ships to user projects should live there. The project-level templates (task, bug, feature, idea, gitignore) already follow this rule and live under `src/templates/project/`.

The GitHub workflow templates and GitHub issue/PR templates do not. Two parallel trees exist — `templates/` at the repo root and `src/templates/` — and the installer reads workflows and GitHub templates from the root `templates/` tree while reading project templates from `src/templates/`. Both trees contain `workflows/github/sync-tasks-to-issues.yml` and `github/ISSUE_TEMPLATE/*` and `github/pull_request_template.md`, and the two copies of `sync-tasks-to-issues.yml` have already drifted apart.

This is not optimized in two ways. First, contributors have no clear answer to "where do I edit a workflow template" — both locations look plausible, and editing `src/templates/workflows/...` currently ships to nobody. Second, the drift is invisible: the installer happily copies the stale root copy and never warns that a sibling exists. The perfect fix collapses this into one source of truth, consistent with the rule already documented in `CLAUDE.md`, so that any file shipped to a user project is editable in exactly one place and the installer reads from that place.

## Success criteria

- [x] Only one templates tree exists in the repo for files that ship to user projects
- [x] The location matches the convention documented in `CLAUDE.md` (under `src/`)
- [x] The installer reads workflow templates, GitHub issue templates, and the PR template from that single location
- [x] A fresh install produces the same `.github/workflows/`, `.github/ISSUE_TEMPLATE/`, and `.github/pull_request_template.md` files as before this change (content preserved — pick whichever copy is currently correct)
- [x] `CLAUDE.md` is updated if any new convention is introduced, or left alone if the existing rule already covers it
- [x] Fresh-install verification per `CLAUDE.md` passes

## Notes

- Drift today: `templates/workflows/github/sync-tasks-to-issues.yml` and `src/templates/workflows/github/sync-tasks-to-issues.yml` differ near the `uses:` line. The developer should determine which is correct before deleting the other.
- The reusable workflow `sync-tasks-reusable.yml` is referenced as `jnun/5daydocs/.github/workflows/sync-tasks-reusable.yml@main` and resolves remotely, so it does not need to ship in the templates tree.
- Installer references to update: `setup.sh` workflow and GitHub template copy block (around lines 610-624).
- `templates/project/` at the root (containing only `README.md` and a `STATE.md.template`) should also be evaluated for whether it still has any reason to exist.

## Completed

Unified all template sources under `src/templates/`, eliminating the duplicate `templates/` tree at the repo root.

### Changes made

- **`setup.sh`**: Updated 6 `safe_copy` calls (lines 608-617) to read from `src/templates/` instead of root `templates/`. Also fixed a broken bitbucket reference that pointed to a nonexistent `templates/bitbucket-pipelines.yml` — now correctly points to `src/templates/workflows/bitbucket/pipelines.yml`.
- **Deleted `templates/`** (root): Removed the entire directory. The `src/templates/` copies were kept as the canonical versions since they were more complete (workflow had an extra trigger path; STATE.md.template had documentation comments).
- **`CLAUDE.md`**: Broadened the templates section to mention workflow and GitHub issue/PR templates alongside the existing task/bug/feature/idea list.

### Drift resolution

The `sync-tasks-to-issues.yml` in `src/` had an additional trigger path (`docs/docs/tasks/**/*.md`) not present in the root copy. The `src/` version was kept as it is the more complete one. The GitHub issue templates and PR template were identical between copies.

### Root `templates/project/` evaluation

Contained `README.md` and `STATE.md.template`, neither referenced by `setup.sh`. The README was unused; STATE.md.template was a stale duplicate of the one in `src/templates/project/` (which has additional documentation comments). Both removed with the rest of root `templates/`.

### Verification

Fresh install to `/tmp/test-5day` completed successfully with all GitHub templates, workflows, issue templates, and PR template correctly installed.

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
