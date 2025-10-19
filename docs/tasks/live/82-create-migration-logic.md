# Task 82: Create Migration Logic in update.sh

**Feature**: /docs/features/core-workflow.md
**Created**: 2025-10-19

## Problem
Existing installations need migration logic to safely move from `docs/work/*` structure to `docs/*` structure without losing any user data (tasks, bugs, custom scripts, etc.).

## Success Criteria
- [x] Migration from 1.x to 2.0.0 logic created
- [x] Safely moves docs/work/tasks/* to docs/tasks/*
- [x] Safely moves docs/work/bugs/* to docs/bugs/*
- [x] Safely moves docs/work/scripts/* to docs/scripts/*
- [x] Safely moves docs/work/designs/* to docs/designs/*
- [x] Safely moves docs/work/examples/* to docs/examples/*
- [x] Safely moves docs/work/data/* to docs/data/*
- [x] Preserves all user files and STATE.md data
- [x] Handles edge cases (missing folders, partial migrations)
- [x] Creates backups before migration

## Related Tasks
- Depends on Task 78 (planning)
- This is CRITICAL - must preserve all user data

## Completion Notes
- Added comprehensive migration block for version < 2.0.0 in update.sh
- Creates timestamped backup: docs/work-backup-YYYYMMDD-HHMMSS
- safe_migrate_dir() function handles both simple moves and content merging
- Migrates all 6 subdirectories (tasks, bugs, scripts, designs, examples, data)
- Moves platform config file
- Verifies all expected directories exist after migration
- Removes empty docs/work/ directory only if safe
- Provides clear user messaging throughout migration process
- Handles edge cases: missing directories, existing destinations, partial migrations
