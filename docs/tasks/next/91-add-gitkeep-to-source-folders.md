# Task 91: Add .gitkeep files to source repository folders

**Feature**: none
**Created**: 2025-10-19

## Problem
Many structural folders in the source repository lack .gitkeep files, which means they won't be tracked by git if they're empty. Currently only `docs/tasks/working/` and `docs/tasks/next/` have .gitkeep files.

Missing .gitkeep in:
- docs/bugs/archived/
- docs/data/
- docs/designs/
- docs/examples/
- docs/tasks/backlog/
- docs/tasks/live/
- docs/tasks/review/
- docs/ideas/

## Success Criteria
- [ ] All structural folders have .gitkeep files
- [ ] Files are committed to git
- [ ] Empty folders are now tracked in the repository
- [ ] Verify with `git ls-tree -r HEAD --name-only | grep .gitkeep`

## Dependencies
- **Depends on**: None
- **Blocks**: Task 92, Task 93 (provides reference for implementation)

## Implementation Guidance

Create .gitkeep files in all structural folders that may be empty. Use the touch command to create empty .gitkeep files in each of the missing directories listed above. Then stage and commit them to git.

## Testing
1. Verify all .gitkeep files were created:
   ```bash
   find docs -name ".gitkeep" | sort
   ```
   **Expected**: Should list at least 10 .gitkeep files (2 existing + 8 new)

2. Add to git:
   ```bash
   git add docs/**/.gitkeep
   git status
   ```
   **Expected**: Should show new .gitkeep files staged

3. Commit:
   ```bash
   git commit -m "Add .gitkeep files to preserve empty folder structure"
   ```

4. Verify in repository:
   ```bash
   git ls-tree -r HEAD --name-only | grep .gitkeep
   ```
   **Expected**: All .gitkeep files should be listed

## Notes
This ensures the folder structure is preserved in git even when folders are empty. The build-distribution.sh script already handles this correctly (line 64), but the source repo itself needs these files.

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
