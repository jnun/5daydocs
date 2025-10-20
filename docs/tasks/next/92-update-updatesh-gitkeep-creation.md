# Task 92: Update update.sh to create .gitkeep files when creating folders

**Feature**: none
**Created**: 2025-10-19

## Problem
The `scripts/update.sh` script creates necessary folders but doesn't add .gitkeep files to preserve empty directories in git. This can cause issues when users commit their updated structure.

Affected functions:
- `ensure_task_folders()` (lines 81-88) - creates task pipeline folders
- Lines 203-212 - creates bug and support folders

## Success Criteria
- [ ] Add .gitkeep creation after folder creation in ensure_task_folders()
- [ ] Add .gitkeep creation for bugs, scripts, designs, examples, data folders
- [ ] Follow the pattern from build-distribution.sh:64 for finding and creating .gitkeep files
- [ ] Test update.sh on a sample project to verify .gitkeep files are created

## Dependencies
- **Depends on**: Task 91 (for reference implementation)
- **Blocks**: None

## Implementation Guidance

Add .gitkeep creation logic to scripts/update.sh after all folder creation is complete. Consider two approaches:

1. **Simple approach**: Add logic after line 218 (after all folder creation) to find empty directories and add .gitkeep files
2. **Function approach**: Create a function that handles .gitkeep creation and call it after folder creation

Use the find command to locate empty directories and create .gitkeep files only where needed. Reference build-distribution.sh line 64 for the pattern.

## Testing
1. Create a test project directory:
   ```bash
   mkdir -p /tmp/test-5daydocs-update
   cd /tmp/test-5daydocs-update
   git init
   mkdir -p docs/tasks/backlog
   echo "**5DAY_TASK_ID**: 0" > docs/STATE.md
   ```

2. Run update.sh and point it to the test directory:
   ```bash
   cd /Users/jnun/Projects/5daydocs
   ./scripts/update.sh
   # When prompted, enter: /tmp/test-5daydocs-update
   ```

3. Verify .gitkeep files were created:
   ```bash
   find /tmp/test-5daydocs-update/docs -name ".gitkeep" | sort
   ```
   **Expected**: Should show .gitkeep files in empty directories

4. Check specific folders:
   ```bash
   ls -la /tmp/test-5daydocs-update/docs/bugs/archived/.gitkeep
   ls -la /tmp/test-5daydocs-update/docs/data/.gitkeep
   ls -la /tmp/test-5daydocs-update/docs/tasks/backlog/.gitkeep
   ```
   **Expected**: All should exist

5. Cleanup:
   ```bash
   rm -rf /tmp/test-5daydocs-update
   ```

## Notes
The find command will only add .gitkeep to directories that are currently empty, which is exactly what we want.

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
