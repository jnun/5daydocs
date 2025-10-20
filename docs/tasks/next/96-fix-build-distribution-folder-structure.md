# Task 96: Fix build-distribution.sh v2.0.0 folder structure

**Feature**: none
**Created**: 2025-10-19
**Priority**: CRITICAL

## Problem
The `scripts/build-distribution.sh` script creates the OLD v1.x folder structure instead of the NEW v2.0.0 flattened structure. Line 60 creates folders under `docs/work/` when they should be directly under `docs/`.

Old (incorrect) structure:
- `docs/work/scripts/`
- `docs/work/designs/`
- `docs/work/examples/`
- `docs/work/data/`

New (correct) v2.0.0 structure:
- `docs/scripts/`
- `docs/designs/`
- `docs/examples/`
- `docs/data/`

This means all distributions built with this script have the WRONG structure and don't match the v2.0.0 migration that update.sh performs!

## Success Criteria
- [ ] Remove `docs/work/` path from folder creation
- [ ] Create folders directly under `docs/` instead
- [ ] Follow v2.0.0 structure consistently
- [ ] Test build creates correct folder structure
- [ ] Verify .gitkeep files are created in new structure

## Dependencies
- **Depends on**: None - This is CRITICAL and blocks distribution
- **Blocks**: All distribution builds

## Implementation Guidance

Modify scripts/build-distribution.sh around line 60 where folder structure is created.

Change the mkdir command that creates `docs/work/{scripts,designs,examples,data}` to instead create these directories directly under `docs/`. This aligns with the v2.0.0 migration performed by update.sh (lines 279-390).

The bugs directory should remain at `docs/bugs/archived` (not under work).

## Testing
1. Build distribution in safe test location:
   ```bash
   mkdir -p /tmp/test-build-96
   cd /tmp/test-build-96
   bash /Users/jnun/Projects/5daydocs/scripts/build-distribution.sh
   ```

2. Verify correct v2.0.0 structure:
   ```bash
   cd /tmp/test-build-96/../5daydocs
   find docs -type d | sort
   ```
   **Expected output:**
   ```
   docs
   docs/bugs
   docs/bugs/archived
   docs/data
   docs/designs
   docs/examples
   docs/features
   docs/guides
   docs/scripts
   docs/tasks
   docs/tasks/backlog
   docs/tasks/live
   docs/tasks/next
   docs/tasks/review
   docs/tasks/working
   ```
   **Should NOT show**: docs/work

3. Verify .gitkeep files exist:
   ```bash
   find docs -name ".gitkeep"
   ```
   **Expected**: .gitkeep in all empty directories

4. Cleanup:
   ```bash
   rm -rf /tmp/test-build-96
   ```

## Notes
This is a CRITICAL bug. The v2.0.0 migration in update.sh moves folders OUT of docs/work/ into docs/, but build-distribution.sh still creates the old structure. New distributions will be incompatible with the expected v2.0.0 structure.

---

<!--
Workflow Reminder:
1. Start in docs/tasks/backlog/
2. Move to docs/tasks/next/ during sprint planning
3. Move to docs/tasks/working/ when starting work
4. Move to docs/tasks/review/ when complete
5. Move to docs/tasks/live/ after approval

If blocked, move back to docs/tasks/next/
-->
