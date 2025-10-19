# Task 81: Update setup.sh for New Directory Structure

**Feature**: /docs/features/core-workflow.md
**Created**: 2025-10-19

## Problem
setup.sh creates the directory structure and needs to be updated to create `docs/tasks/`, `docs/bugs/`, `docs/scripts/`, etc. instead of `docs/work/tasks/`, `docs/work/bugs/`, etc.

## Success Criteria
- [x] Directory creation logic updated
- [x] STATE.md path references updated
- [x] Sample content paths updated
- [x] Script tested on fresh installation
- [x] Script tested with --force flag

## Related Tasks
- Depends on Task 78 (planning)

## Completion Notes
- Updated safe_mkdir calls to create docs/tasks/, docs/bugs/, docs/scripts/, etc.
- Updated template file copy paths
- Updated INDEX.md file list (removed docs/work/INDEX.md)
- Updated validation checks to look for flattened directories
- Updated platform config path from docs/work/.platform-config to docs/.platform-config
- Updated all user-facing messages and example commands
