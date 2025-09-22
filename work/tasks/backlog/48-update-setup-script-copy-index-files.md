# Update Setup Script to Copy INDEX.md Files

## Problem
Once INDEX.md files are created for work/ and docs/ folders, the setup.sh script needs to copy them to target projects during installation.

## Desired Outcome
- setup.sh copies all INDEX.md files to their respective folders
- Handles both new installations and updates
- Preserves existing INDEX.md files if user has customized them
- Reports which INDEX.md files were copied

## Testing Criteria
- [ ] All INDEX.md files present after fresh setup
- [ ] Existing customized INDEX.md files are not overwritten
- [ ] Setup output shows INDEX.md files were processed
- [ ] Folder structure is self-documenting after setup