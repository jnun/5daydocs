# Task 166: Remove Jira and Bitbucket scaffolding

**Feature**: none
**Created**: 2026-04-16
**Depends on**: none
**Blocks**: none

## Problem

The codebase has Jira and Bitbucket integration scaffolding that was never completed and nobody is asking for. It adds dead platform choices to the installer, dead code paths in setup.sh, dead feature specs and guides in docs/, dead backlog tasks, and a dead pipeline file in src/. This noise makes the codebase harder to navigate and the installer longer than it needs to be. Remove it all.

## Success criteria

- [x] `./setup.sh` platform menu shows only: `1) GitHub Issues (default)` and `2) No sync`. No Jira or Bitbucket options.
- [x] `docs/.platform-config` only stores `github-issues` or `none`
- [x] `src/bitbucket-pipelines.yml` deleted
- [x] All Jira/Bitbucket feature specs deleted: `docs/features/jira-integration.md`, `docs/features/jira-git-sync.md`
- [x] All Jira/Bitbucket guides deleted: `docs/guides/jira-integration-setup.md`, `docs/guides/jira-kanban-setup.md`, `docs/guides/jira-github-sync-comparison.md`
- [x] Dead backlog tasks deleted: 37, 40, 61, 62, 146 (all Jira/Bitbucket work)
- [x] No remaining references to `bitbucket-jira`, `github-jira`, or `bitbucket` as a platform in setup.sh
- [x] `DOCUMENTATION.md` line 3 ("Like Jira, but folders") reworded — no Jira name-drop
- [x] Fresh install test passes with the simplified platform menu
- [x] `grep -ri 'jira\|bitbucket' setup.sh` returns zero results

## Implementation

### 1. Delete files (git rm)

```
src/bitbucket-pipelines.yml
docs/features/jira-integration.md
docs/features/jira-git-sync.md
docs/guides/jira-integration-setup.md
docs/guides/jira-kanban-setup.md
docs/guides/jira-github-sync-comparison.md
docs/tasks/backlog/37-create-bitbucket-pipelines-config.md
docs/tasks/backlog/40-document-jira-webhook-setup.md
docs/tasks/backlog/61-configure-and-test-jira-integration.md
docs/tasks/backlog/62-implement-two-way-jira-git-sync.md
docs/tasks/backlog/146-wire-bitbucket-jira-platform-to-pipelines-jira-yml.md
```

### 2. Simplify setup.sh platform menu

Find the `PLATFORM CONFIGURATION` section (search for `Select your platform configuration`). Replace the 4-option menu with 2 options:

```bash
echo "1) GitHub Issues (default)"
echo "2) No sync — opt out of GitHub issue tracking"

case "$PLATFORM_CHOICE" in
    1|"")
        PLATFORM="github-issues"
        ;;
    2)
        PLATFORM="none"
        ;;
    *)
        PLATFORM="github-issues"
        ;;
esac
```

Keep the update-mode logic that reads `CURRENT_PLATFORM` from `docs/.platform-config` and defaults to it on Enter. But remove the `github-jira` and `bitbucket-jira` cases.

### 3. Remove Bitbucket code paths from setup.sh

- **Directory creation** (search `bitbucket-jira`): the `if [ "$PLATFORM" != "bitbucket-jira" ]` guard around `.github/` directory creation — simplify to `if [ "$PLATFORM" != "none" ]`
- **Walk section**: remove the `bitbucket-*` filter block (`if [[ "$rel_path" == bitbucket-* ]]`)
- **Copilot instructions**: the guard `if [ "$PLATFORM" != "bitbucket-jira" ] && [ "$PLATFORM" != "none" ]` — simplify to `if [ "$PLATFORM" != "none" ]`
- **Workflow section**: remove the entire `elif` Bitbucket Pipelines branch. The section should be: if `none` → skip + cleanup; else → GitHub Actions.

### 4. Update DOCUMENTATION.md (both copies)

Line 3: `Project management in markdown files. Like Jira, but folders and plain text.`
→ Reword to remove the Jira name-drop. Something like: `Project management in markdown files. Folders and plain text.`

### 5. Check for stragglers

Run `grep -ri 'jira\|bitbucket' setup.sh DOCUMENTATION.md src/ docs/5day/ CLAUDE.md README.md` and fix any remaining references. Ignore hits in `docs/tasks/` (historical task files in review/live are fine to leave).

## Notes

- `docs/guides/git-source-of-truth-sync.md` mentions Jira in passing (as a comparison). Check if it still makes sense after removal — may need a light edit or can be left as-is if the reference is generic.
- `docs/tasks/audit-log.txt` has historical verdicts for deleted tasks — leave it alone, it's an append-only log.
- `docs/tasks/next/159-simplify-distribution.md` references Bitbucket in the planning notes — that's historical context in a completed task, leave it.
- The `docs/.platform-config` file format stays the same, just with fewer valid values. Existing installs with `github-jira` or `bitbucket-jira` will fall through to the default (`github-issues`) on next update — that's fine since those platforms never worked anyway.

## Completed

All items completed on 2026-04-22.

### Files deleted (git rm)
- `src/bitbucket-pipelines.yml`
- `docs/features/jira-integration.md`
- `docs/features/jira-git-sync.md`
- `docs/guides/jira-integration-setup.md`
- `docs/guides/jira-kanban-setup.md`
- `docs/guides/jira-github-sync-comparison.md`
- `docs/guides/git-source-of-truth-sync.md` (entirely about Jira sync, not just a passing mention)
- `docs/tasks/backlog/37-create-bitbucket-pipelines-config.md`
- `docs/tasks/backlog/40-document-jira-webhook-setup.md`
- `docs/tasks/backlog/61-configure-and-test-jira-integration.md`
- `docs/tasks/backlog/62-implement-two-way-jira-git-sync.md`
- `docs/tasks/backlog/146-wire-bitbucket-jira-platform-to-pipelines-jira-yml.md`

### Files modified
- `setup.sh` — platform menu reduced to 2 options; removed `github-jira`/`bitbucket-jira` cases, `bitbucket-*` walk filter, and `bitbucket-jira` directory-creation guard
- `DOCUMENTATION.md` (root) — line 3 reworded to remove Jira name-drop
- `src/DOCUMENTATION.md` — same line 3 change
- `CLAUDE.md` — removed Bitbucket from "GitHub/Bitbucket templates" section heading and path reference
- `docs/features/folder-based-project-management.md` — removed "Jira" from "Universal across documentation, Jira, and GitHub"
- `docs/guides/templates-index.md` — removed Bitbucket directory tree entries and install line

### Verified
- `grep -ri 'jira\|bitbucket' setup.sh` returns zero results
- Fresh install test passes with simplified 2-option platform menu
- Only remaining Jira/Bitbucket references are in task files (159, 166) which are historical context

## Audit

- **Passes run**: 1
- **Final verdict**: PASS
- **Date**: 2026-04-22
- **Files audited**: 6
- **Context source**: task ## Completed section
