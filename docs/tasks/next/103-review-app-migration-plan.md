# Task 103: Review src/ Creation Plan

**Feature**: none
**Created**: 2025-10-21
**Depends on**: Tasks 97-102 (review all tasks before execution)

## Description

Review the complete src/ creation plan (Tasks 97-102) to ensure it solves the original problem and accounts for all potential challenges.

## Original Problem

**Issue**: Confusion between distributable files and development files
- templates/ was unclear in purpose
- scripts/update.sh copied from .github/ instead of templates/
- No clear separation between "building 5daydocs" and "using 5daydocs"
- Dogfooding installation was confusing

## Proposed Solution

**New Structure**:
- `src/` = Single source of truth for distributable 5daydocs template files  
- `docs/` = Dogfooding 5daydocs to manage 5daydocs development (stays exactly as is)
- `scripts/` = Developer tools for maintaining 5daydocs
- Clear installation: `src/setup.sh` and `src/5day.sh` command interface

## Task Sequence Review

1. **Task 97**: Audit files - determines what template files to create in src/
2. **Task 98**: Create src/ structure - builds skeleton for template files
3. **Task 99**: Create template files in src/ - populates structure with clean templates
4. **Task 100**: Create installation scripts - makes it functional for users
5. **Task 101**: Test everything - validates installation works
6. **Task 102**: Document and cleanup - makes it maintainable

## Potential Challenges Identified

### Challenge 1: Dual Purpose of .github/
**Issue**: 5daydocs repo needs workflows, users need workflow templates
**Solution**: Copy to src/github/, keep in root for repo's own use
**Status**: ✅ Addressed in Task 99

### Challenge 2: docs/ Template vs Working Docs
**Issue**: Current docs/ has live tasks, users need clean template structure
**Solution**: src/docs/ is clean template structure, root docs/ is our live dogfooding docs (stays exactly as is)
**Status**: ✅ Addressed in Task 99

### Challenge 3: Three Different scripts/ Locations
**Issue**: User scripts, install scripts, dev scripts - confusing
**Solution**:
- `src/docs/scripts/` = Template user daily tools (create-task.sh, etc.)
- `src/setup.sh` = Main installation script
- `src/5day.sh` = Command interface for users
- `scripts/` = Developer tools for maintaining 5daydocs
**Status**: ✅ Addressed in Task 99 and 100

### Challenge 4: Backward Compatibility
**Issue**: Existing users have old installations
**Solution**: Keep migration logic in update.sh
**Status**: ✅ Addressed in Task 100

### Challenge 5: Dogfooding Installation Safety
**Issue**: Installing to current directory could overwrite src/
**Solution**: Check if target is same as source, skip src/ copy
**Status**: ✅ Addressed in Task 100

### Challenge 6: templates/ Obsolescence
**Issue**: What happens to templates/ after src/ creation?
**Solution**: Can safely remove since content will be in src/
**Status**: ✅ Addressed in Task 102

## Additional Challenges to Consider

### Challenge 7: Git History
**Question**: Do we lose git history when creating template files?
**Solution**: Use `cp` for templates since they'll be modified - git history less important
**Action**: Confirmed approach in Task 99

### Challenge 8: Existing Installations
**Question**: What happens when users update from old structure?
**Solution**: src/setup.sh should detect and migrate old installations
**Action**: Verify Task 100 includes migration logic

### Challenge 9: Submodule Workflow
**Question**: How does this work with git submodules?
**Solution**: Test scenario included - src/ should work as submodule
**Status**: ✅ Addressed in Task 101

### Challenge 10: VERSION Management
**Question**: Should this be version 3.0.0 (breaking change)?
**Solution**: Yes, major structural change warrants major version bump
**Status**: ✅ Addressed in Task 102

## Missing Tasks?

Considerations:
- [ ] Do we need a task for updating CI/CD if it exists?
- [ ] Do we need to update any GitHub Actions workflows?
- [ ] Do we need to notify existing users of breaking change?
- [ ] Do we need a migration guide for existing installations?

## Success Criteria for This Review

- [ ] All tasks 97-102 reviewed
- [ ] All challenges identified and addressed
- [ ] Task sequence makes sense
- [ ] No gaps in the plan
- [ ] Ready to execute tasks in order
- [ ] User (project maintainer) approves plan

## Decision Points

Before proceeding:
1. ✅ Confirm src/ is the right name (vs dist/, pkg/, tool/)
2. ✅ Confirm task sequence is correct
3. ✅ Confirm all edge cases covered
4. ✅ Get approval to proceed with execution

## Next Steps After Approval

1. Move Task 97 to docs/tasks/next/
2. Begin execution in order
3. Do not proceed to next task until previous is complete and tested
4. Update this task with any issues discovered during execution
