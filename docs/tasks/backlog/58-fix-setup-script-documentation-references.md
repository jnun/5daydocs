# Task 58: Fix Setup Script Documentation References

**Status**: BACKLOG
**Feature**: /docs/features/task-automation.md
**Created**: 2025-09-24
**Priority**: HIGH

## Problem Statement

Feature documentation incorrectly references `work/scripts/setup.sh` but the actual setup.sh script is located in the project root. This creates confusion for users following the documentation.

## Success Criteria

- [ ] Update all feature documentation files to correctly reference `/setup.sh` or `./setup.sh`
- [ ] Verify no broken references to `work/scripts/setup.sh` remain
- [ ] Update CLAUDE.md if it contains incorrect references
- [ ] Test that all documented commands work correctly

## Technical Notes

Files to check and update:
- `/docs/features/task-automation.md`
- `/docs/features/state-management.md`
- Any other docs referencing setup.sh

## Testing

1. Run grep to find all references to setup.sh
2. Verify each reference points to correct location
3. Test setup.sh execution from root directory
4. Confirm documentation matches actual file structure