# Task 90: Fix build-distribution.sh VERSION placeholder bug

**Feature**: none
**Created**: 2025-10-19

## Problem
In `scripts/build-distribution.sh` line 68, the script only replaces the `{{DATE}}` placeholder in STATE.md.template but fails to replace the `{{VERSION}}` placeholder. This causes distributed versions of 5daydocs to have a literal "{{VERSION}}" string in their STATE.md instead of the actual version number.

The script needs to read the VERSION file and use that value when replacing placeholders in the template.

## Success Criteria
- [ ] scripts/build-distribution.sh reads VERSION file into a variable
- [ ] The sed command replaces both {{DATE}} and {{VERSION}} placeholders
- [ ] Follows the same pattern as setup.sh (lines 139-141)
- [ ] Test build creates STATE.md with actual version number instead of "{{VERSION}}"

## Dependencies
- **Depends on**: None
- **Blocks**: Distribution releases (should be fixed before next build)

## Implementation Guidance

Two changes needed in scripts/build-distribution.sh:

1. Add VERSION file reading early in the script (after `set -e`, before the Configuration section)
   - Read VERSION file if it exists
   - Default to "1.0.0" if missing
   - Store in CURRENT_VERSION variable

2. Update the sed command that creates STATE.md (around line 68)
   - Use multiple `-e` expressions to replace multiple placeholders
   - Replace both {{DATE}} and {{VERSION}}
   - Reference setup.sh lines 139-141 for the correct pattern

## Testing
1. Verify current directory before running any tests:
   ```bash
   pwd
   # Should show: /Users/jnun/Projects/5daydocs
   ```

2. Create a safe test location and build there:
   ```bash
   mkdir -p /tmp/test-build-90
   cd /tmp/test-build-90
   bash /Users/jnun/Projects/5daydocs/scripts/build-distribution.sh
   ```

3. Verify VERSION placeholder is replaced:
   ```bash
   cat /tmp/test-build-90/../5daydocs/docs/STATE.md | grep "5DAY_VERSION"
   ```
   **Expected**: Should show "**5DAY_VERSION**: 2.0.0" (or current version)
   **Not**: "**5DAY_VERSION**: {{VERSION}}"

4. Verify the VERSION variable is available:
   ```bash
   grep "CURRENT_VERSION" /Users/jnun/Projects/5daydocs/scripts/build-distribution.sh
   ```
   **Expected**: Should see CURRENT_VERSION being read before the sed command

5. Cleanup:
   ```bash
   rm -rf /tmp/test-build-90
   ```

## Notes
Reference implementation from setup.sh:139-141 shows the correct pattern.

This is a CRITICAL bug affecting all distributions.

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
