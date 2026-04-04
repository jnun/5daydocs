# Task 77: Improve GitHub Actions Workflow Resilience

**Feature**: github-issue-sync
**Created**: 2025-10-19

## Problem
The GitHub Actions workflow for syncing 5DayDocs tasks to GitHub Issues had several reliability and resilience issues:
- INDEX.md files were being processed as tasks, causing workflow failures
- No support for submodule installations (docs/tasks/ path pattern)
- Unreliable issue lookup using title search that could match wrong issues
- Issue bodies never updated after creation, causing stale content
- No concurrency control leading to potential race conditions
- Silent failures with undefined variables
- Shallow git history (fetch-depth: 2) missing changes on merge commits
- No validation of task IDs or folder patterns

## Success Criteria
- [x] Skip INDEX.md and TEMPLATE files to prevent processing errors
- [x] Support both installation patterns: docs/tasks/ and docs/docs/tasks/
- [x] Implement idempotent issue lookup using HTML comment metadata
- [x] Update issue bodies when task content changes
- [x] Add concurrency control to prevent conflicting workflow runs
- [x] Add strict error handling with set -euo pipefail
- [x] Validate task IDs are numeric
- [x] Validate files match known folder patterns (backlog/next/working/review/live)
- [x] Use full git history (fetch-depth: 0) for reliable change detection
- [x] Add structured logging with success indicators
- [x] Test workflow with real task creation and movement

## Notes
All improvements implemented in .github/workflows/sync-tasks-reusable.yml:
- HTML metadata comment enables reliable lookup: <!-- 5daydocs-task-id: ID -->
- Workflow now idempotent and safe to retry
- Clear error messages with expected formats
- Better debugging with structured logging
- Backwards compatible with existing installations

## Completed
Implemented all missing resilience improvements in the reusable workflow and caller templates:

**Concurrency control** — Added `concurrency` block (`5daydocs-sync-${{ github.repository }}`, `cancel-in-progress: false`) to prevent race conditions from overlapping workflow runs.

**Strict error handling** — Added `set -euo pipefail` to all `run:` steps (Validate structure, Setup labels, Determine files, Build cache, Sync tasks, Projects integration, Reset bulk sync flag) so undefined variables and failed commands are caught immediately.

**HTML comment metadata for idempotent issue lookup** — Issue bodies now include `<!-- 5daydocs-task-id: {ID} -->`. Cache fetches body field. Lookup first searches by metadata comment, then falls back to title pattern for backwards compatibility with pre-metadata issues.

**Numeric task ID validation** — Added explicit `^[0-9]+$` regex check after extracting task ID.

**Submodule path support** — Added `docs/docs/tasks/**/*.md` to path triggers in both the caller workflow and the distribution template.

### Files changed
- `.github/workflows/sync-tasks-reusable.yml` — concurrency, set -euo pipefail, HTML metadata in body, metadata-first lookup, numeric ID validation
- `.github/workflows/sync-tasks-to-issues.yml` — added `docs/docs/tasks/` path trigger
- `src/templates/workflows/github/sync-tasks-to-issues.yml` — added `docs/docs/tasks/` path trigger
