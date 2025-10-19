# Task 85: Update GitHub Actions Workflows

**Feature**: /docs/features/github-integration.md
**Created**: 2025-10-19

## Problem
GitHub Actions workflows reference task paths and need to be updated for the new structure.

## Success Criteria
- [x] .github/workflows/sync-tasks-to-issues.yml updated
- [x] templates/workflows/github/sync-tasks-to-issues.yml updated
- [x] Any other workflow files updated
- [x] Path patterns updated for task detection

## Related Tasks
- Depends on Task 78 (planning)

## Completion Notes
- Updated .github/workflows/sync-tasks-to-issues.yml with sed
- Replaced docs/work/tasks/ → docs/tasks/ throughout workflow
- Updated path patterns for task file detection
- Template version also updated in Task 83
- All workflow automation will now trigger on correct paths
