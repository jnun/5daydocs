# Task 93: Update setup.sh to create .gitkeep files when creating folders

**Feature**: none
**Created**: 2025-10-19

## Problem
The `setup.sh` script creates necessary folders using `safe_mkdir()` but doesn't add .gitkeep files to preserve empty directories in git. New installations won't have proper folder preservation.

The `safe_mkdir()` function (lines 100-109) creates directories but should also ensure .gitkeep files exist for empty directories.

## Success Criteria
- [ ] Add .gitkeep creation logic after all folders are created
- [ ] Ensure all structural folders have .gitkeep files in new installations
- [ ] Follow the pattern from build-distribution.sh:64 for finding and creating .gitkeep files
- [ ] Test setup.sh on a fresh project to verify .gitkeep files are created
- [ ] Verify .gitkeep appears in validation output or summary

## Dependencies
- **Depends on**: Task 91 (for reference implementation)
- **Blocks**: None

## Implementation Guidance

Add .gitkeep creation after line 125 in setup.sh (after all safe_mkdir calls, before the .github/workflows creation section).

Use the find command to locate empty directories in the docs folder and create .gitkeep files. Add an informative echo message to let users know this step is happening. Reference build-distribution.sh line 64 for the correct pattern.

## Testing
1. Create a test project directory:
   ```bash
   mkdir -p /tmp/test-5daydocs-setup
   cd /tmp/test-5daydocs-setup
   git init
   ```

2. Run setup.sh and point it to the test directory:
   ```bash
   cd /Users/jnun/Projects/5daydocs
   ./setup.sh
   # When prompted for path, enter: /tmp/test-5daydocs-setup
   # When prompted for platform, press Enter for default (GitHub)
   # When prompted for .gitignore, enter: n
   ```

3. Verify .gitkeep files were created:
   ```bash
   find /tmp/test-5daydocs-setup/docs -name ".gitkeep" | sort
   ```
   **Expected**: Should show .gitkeep files in empty directories

4. Check specific empty folders:
   ```bash
   ls -la /tmp/test-5daydocs-setup/docs/data/.gitkeep
   ls -la /tmp/test-5daydocs-setup/docs/designs/.gitkeep
   ls -la /tmp/test-5daydocs-setup/docs/examples/.gitkeep
   ls -la /tmp/test-5daydocs-setup/docs/bugs/archived/.gitkeep
   ```
   **Expected**: All should exist

5. Verify setup summary mentions .gitkeep:
   ```bash
   # Review the output from setup.sh
   ```
   **Expected**: Should see message about .gitkeep files

6. Cleanup:
   ```bash
   rm -rf /tmp/test-5daydocs-setup
   ```

## Notes
The find command automatically handles only empty directories, so it won't add unnecessary .gitkeep files to folders that already have content.

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
