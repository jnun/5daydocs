# Task 111: Copy VERSION file to distribution

**Feature**: none
**Created**: 2025-10-19
**Priority**: HIGH

## Problem
Task 94 determined that build-distribution.sh MUST copy the VERSION file to distributions. Currently it doesn't copy VERSION, causing setup.sh to fall back to "1.0.0" instead of using the correct version (2.0.0).

This results in:
- Distributed 5daydocs installations showing wrong version
- STATE.md files created with incorrect 5DAY_VERSION
- Users can't tell which version they have installed

## Success Criteria
- [ ] build-distribution.sh copies VERSION file to distribution directory
- [ ] Test distribution build includes VERSION file
- [ ] Verify setup.sh reads correct version from distribution
- [ ] Verify STATE.md gets correct version (2.0.0, not 1.0.0)

## Dependencies
- **Depends on**: Task 94 (requires documented decision)
- **Blocks**: None

## Implementation Guidance

Based on Task 94 analysis: Add VERSION file copy to build-distribution.sh

1. Find the section where documentation files are copied (around line 47, after CLAUDE.md)
2. Add a step to copy the VERSION file from source to $DIST_PATH/
3. Should be a simple copy operation with informative echo message
4. Ensures distributions have correct version information

## Testing

1. Create safe test location for distribution build:
   ```bash
   mkdir -p /tmp/test-version-95
   cd /tmp/test-version-95
   bash /Users/jnun/Projects/5daydocs/scripts/build-distribution.sh
   ```

2. Verify VERSION file was copied:
   ```bash
   ls -la /tmp/test-version-95/../5daydocs/VERSION
   cat /tmp/test-version-95/../5daydocs/VERSION
   ```
   **Expected**: File exists showing "2.0.0"

3. Test setup.sh reads correct version:
   ```bash
   mkdir -p /tmp/test-setup-version
   cd /tmp/test-version-95/../5daydocs
   ./setup.sh
   # When prompted for path, enter: /tmp/test-setup-version
   # Press Enter for defaults (GitHub)
   # Enter: n (for .gitignore)
   ```

4. Verify correct version in STATE.md:
   ```bash
   cat /tmp/test-setup-version/docs/STATE.md | grep "5DAY_VERSION"
   ```
   **Expected**: `**5DAY_VERSION**: 2.0.0` (NOT 1.0.0!)

5. Cleanup:
   ```bash
   rm -rf /tmp/test-version-95 /tmp/test-setup-version
   ```

## Notes
Task 94 completed the analysis and determined VERSION file is required in distributions to avoid the "1.0.0" fallback bug.

This is a simple but important fix that ensures version consistency across all installations.

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
