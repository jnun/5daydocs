# Task 83: Update Template Files

**Feature**: /docs/features/core-workflow.md
**Created**: 2025-10-19

## Problem
Template files in templates/project/ contain path references to old structure that need updating.

## Success Criteria
- [x] templates/project/STATE.md.template reviewed (likely no changes needed)
- [x] Any other templates updated with new paths
- [x] Template documentation updated

## Related Tasks
- Depends on Task 78 (planning)

## Completion Notes
- STATE.md.template requires no changes (contains no path references)
- Updated templates/workflows/github/sync-tasks-to-issues.yml
- Replaced docs/work/tasks/ → docs/tasks/ in workflow templates
- Verified all workflow templates in templates/workflows/github/ and templates/workflows/bitbucket/
- Templates now match the flattened structure
