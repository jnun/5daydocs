# Task 84: Update 5day.sh Command Interface

**Feature**: /docs/features/core-workflow.md
**Created**: 2025-10-19

## Problem
The 5day.sh script references paths like `docs/work/tasks/` and `docs/work/scripts/` that need to be updated to the new flattened structure.

## Success Criteria
- [x] All path references updated
- [x] Script tested with all commands (newtask, newfeature, status, checkfeatures)
- [x] Help text updated if it mentions paths

## Related Tasks
- Depends on Task 78 (planning)

## Completion Notes
- Updated all path references using sed batch replacements
- Replaced docs/work/tasks/ → docs/tasks/
- Replaced docs/work/scripts/ → docs/scripts/
- All commands (newtask, newfeature, status, checkfeatures) now use correct paths
- Help text automatically reflects new paths through variable references
