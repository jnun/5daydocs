# Task 60: Create Version Migration Scripts

**Status**: BACKLOG
**Feature**: /docs/features/dual-repository-architecture.md
**Created**: 2025-09-24
**Priority**: LOW

## Problem Statement

The dual-repository architecture mentions migration scripts for version upgrades but these don't exist yet. Users need automated tools to safely upgrade between 5daydocs versions while preserving their work.

## Success Criteria

- [ ] Create `scripts/migrate-version.sh` script
- [ ] Support migration from standalone to submodule installation
- [ ] Preserve all user data (tasks, bugs, docs, custom scripts)
- [ ] Handle STATE.md format changes between versions
- [ ] Create rollback mechanism for failed migrations
- [ ] Add version compatibility checking
- [ ] Document migration process

## Technical Notes

Migration script should:
1. Detect current installation type (standalone vs submodule)
2. Backup existing work/ directory
3. Check version compatibility
4. Apply any STATE.md format updates
5. Update folder structure if needed
6. Validate migration success
7. Provide rollback option

Version checking:
- Add VERSION file to track 5daydocs version
- Check compatibility matrix
- Warn about breaking changes

## Testing

1. Test standalone to submodule migration
2. Test version upgrade with STATE.md changes
3. Test rollback after failed migration
4. Verify no data loss
5. Test with various edge cases (empty folders, missing STATE.md, etc.)