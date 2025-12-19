# Task 101: Test src/ Structure and Installation

**Feature**: none
**Created**: 2025-10-21
**Depends on**: Task 100 (scripts must be updated)

## Description

Thoroughly test the new `src/` structure and installation scripts to ensure:
1. Fresh installations work correctly
2. Updates work correctly
3. Dogfooding still works
4. All files are properly distributed

## Test Scenarios

### Scenario 1: Fresh Install to New Project

```bash
# Setup
mkdir ~/test-project
cd ~/test-project

# Run
~/5daydocs/src/scripts/install.sh

# Verify
- docs/ structure created
- .github/workflows/ installed
- .github/ISSUE_TEMPLATE/ installed
- DOCUMENTATION.md exists in root
- README.md created (new project)
- STATE.md created from template
- All scripts executable
- No src/ directory in test project
```

### Scenario 2: Fresh Install to Project with Existing README

```bash
# Setup
mkdir ~/test-project-2
cd ~/test-project-2
echo "# My Existing Project" > README.md

# Run
~/5daydocs/src/scripts/install.sh

# Verify
- Original README.md preserved
- DOCUMENTATION.md added
- All other files installed correctly
```

### Scenario 3: Update Existing Installation

```bash
# Setup: Use test-project from Scenario 1
# Modify some src/ files first to see updates

# Run
cd ~/5daydocs
src/scripts/update.sh
# Enter: ~/test-project

# Verify
- Updated files copied over
- STATE.md preserved (not overwritten)
- User's task files preserved
- Scripts updated
- Workflows updated
```

### Scenario 4: Dogfooding (Install to 5daydocs itself)

```bash
# Run from 5daydocs repo
cd ~/5daydocs
src/scripts/install.sh
# Enter: . (current directory)

# Verify
- docs/ updated from src/docs/ templates
- .github/ updated from src/github/
- DOCUMENTATION.md in root
- src/ NOT overwritten by itself
- Existing docs/tasks/ preserved (live work)
- No infinite loops or circular copies
```

### Scenario 5: Install as Submodule

```bash
# Setup
mkdir ~/another-project
cd ~/another-project
git init
git submodule add ~/5daydocs 5daydocs

# Run
./5daydocs/src/scripts/install.sh
# Enter: ..

# Verify
- Files installed to ../
- Submodule stays intact
- Can update from submodule
```

## Edge Cases to Test

1. **Non-existent target directory**
   - Script should error gracefully or create it

2. **Permission issues**
   - Script should handle read-only files appropriately

3. **Partial installation**
   - Some folders exist, some don't
   - Should merge correctly

4. **Old template/ structure**
   - If user has old installation, update.sh should migrate

## Validation Checklist

After each test:
- [ ] No error messages during installation
- [ ] All expected files present
- [ ] All scripts are executable (chmod +x)
- [ ] No unexpected files copied
- [ ] File permissions correct
- [ ] Symlinks work (if any)
- [ ] Git status clean (no tracked files changed unintentionally)

## Success Criteria

- [ ] All 5 test scenarios pass
- [ ] All edge cases handled appropriately
- [ ] No regressions in existing functionality
- [ ] Documentation accurate
- [ ] Ready for production use

## Rollback Plan

If tests fail:
1. Document the failure
2. Do not proceed to next task
3. Fix issues in src/ structure or scripts
4. Re-test until all scenarios pass
