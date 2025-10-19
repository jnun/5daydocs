# Task 80: Update All Work Scripts Paths

**Feature**: /docs/features/core-workflow.md
**Created**: 2025-10-19

## Problem
Scripts in docs/work/scripts/ reference paths like `docs/work/tasks/`, `docs/work/bugs/`, etc. These need to be updated to `docs/tasks/`, `docs/bugs/`, etc.

## Success Criteria
- [x] create-task.sh updated
- [x] create-feature.sh updated
- [x] check-alignment.sh updated
- [x] validate-tasks.sh updated
- [x] All scripts tested and working with new paths

## Related Tasks
- Depends on Task 78 (planning)

## Completion Notes
- Updated all 4 scripts using batch sed replacements
- Replaced docs/work/tasks/ → docs/tasks/
- Replaced docs/work/bugs/ → docs/bugs/
- Replaced docs/work/scripts/ → docs/scripts/
- All scripts now reference correct flattened paths
