# Task 146: Wire bitbucket-jira platform to pipelines-jira.yml template

**Feature**: none
**Created**: 2026-04-08
**Depends on**: none
**Blocks**: none

## Problem

`setup.sh` detects three platforms — `github-issues`, `bitbucket`, and `bitbucket-jira` — but the bitbucket workflow branch (`setup.sh:615-621`) always copies the generic `src/templates/workflows/bitbucket/pipelines.yml`, regardless of which bitbucket variant the user picked. The Jira-aware sibling `src/templates/workflows/bitbucket/pipelines-jira.yml` exists in the templates tree but is never installed by anything. A user who picks the `bitbucket-jira` platform gets the non-Jira pipeline silently, with no warning that the wrong template was chosen.

## Success criteria

- [ ] When `PLATFORM=bitbucket-jira`, the installer copies `pipelines-jira.yml` (not `pipelines.yml`) to the target project
- [ ] When `PLATFORM=bitbucket`, the installer continues to copy `pipelines.yml`
- [ ] Fresh-install verification per `CLAUDE.md` still passes for both bitbucket variants
- [ ] `pipelines-jira.yml` is no longer orphaned in the templates tree

## Notes

- Installer site: `setup.sh:615-621` — the `else` branch under the `[ "$PLATFORM" != "bitbucket-jira" ]` guard. The branch should select the template by `$PLATFORM` instead of hardcoding `pipelines.yml`.
- Templates tree: `src/templates/workflows/bitbucket/pipelines.yml` and `src/templates/workflows/bitbucket/pipelines-jira.yml` both exist.
- Discovered while auditing tasks 143/144/145 — orphan predates those tasks but was unmasked by the templates unification.

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
