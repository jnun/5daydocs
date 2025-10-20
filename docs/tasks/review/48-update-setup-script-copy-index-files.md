# Task 48: Update Setup Script to Copy INDEX.md Files

**Feature**: none
**Created**: 2025-10-19


## Related Tasks
- Complete task 46 first (INDEX.md files for work/ folders must exist)
- Complete task 47 first (INDEX.md files for docs/ folders must exist)

## Problem
Once INDEX.md files are created for work/ and docs/ folders, the setup.sh script needs to copy them to target projects during installation.

## Success criteria
- setup.sh copies all INDEX.md files to their respective folders
- Handles both new installations and updates
- Preserves existing INDEX.md files if user has customized them
- Reports which INDEX.md files were copied

- [ ] All INDEX.md files present after fresh setup
- [ ] Existing customized INDEX.md files are not overwritten
- [ ] Setup output shows INDEX.md files were processed
