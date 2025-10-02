# Version Management for 5DayDocs

## Current Version
The current version is stored in `/VERSION` file at the root of the 5daydocs repository.

## When to Update Version

Update the version number whenever you make:
- **Major changes (X.0.0)**: Breaking changes to folder structure or workflow
- **Minor changes (0.X.0)**: New features, scripts, or substantial improvements
- **Patch changes (0.0.X)**: Bug fixes, typos, small improvements

### Files to Update When Changing Version

When you increment the version, you MUST update:
1. `/VERSION` - The master version file
2. `/scripts/update.sh` - Line 43: `CURRENT_VERSION="X.X.X"`

## Version Change Checklist

- [ ] Update `/VERSION` file with new version number
- [ ] Update `CURRENT_VERSION` in `/scripts/update.sh`
- [ ] Add migration logic in `update.sh` if needed for structural changes
- [ ] Test the update process on a sample project
- [ ] Commit with message: `chore: bump version to X.X.X`

## Examples of Version-Worthy Changes

### Requires Version Bump:
- Adding new folder structures
- Changing script behavior significantly
- Modifying setup.sh or update.sh logic
- Adding new features or scripts
- Fixing bugs in existing scripts

### Does NOT Require Version Bump:
- Updating documentation only (README, etc.)
- Fixing typos in comments
- Adding examples or templates that don't affect functionality

## Testing Version Updates

Before committing a version change:
1. Run setup.sh on a test directory
2. Make some changes to simulate an older installation
3. Run update.sh to verify migrations work correctly