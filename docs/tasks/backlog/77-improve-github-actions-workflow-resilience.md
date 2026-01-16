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
All improvements implemented in .github/workflows/sync-tasks-to-issues.yml:
- HTML metadata comment enables reliable lookup: <!-- 5daydocs-task-id: ID -->
- Workflow now idempotent and safe to retry
- Clear error messages with expected formats
- Better debugging with structured logging
- Backwards compatible with existing installations
