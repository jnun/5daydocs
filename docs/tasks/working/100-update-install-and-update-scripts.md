# Task 100: Update install.sh and update.sh Scripts

**Feature**: none
**Created**: 2025-10-21
**Depends on**: Task 99 (src/ must be populated)

## Description

Update (or create) `src/scripts/install.sh` and `src/scripts/update.sh` to use `src/` as the source of truth instead of templates/ or .github/.

## Current State Problems

1. **setup.sh** - First-time installation script
   - Currently copies from `templates/` (which will become obsolete)
   - Should become `src/scripts/install.sh`
   - Should copy from `src/docs/`, `src/github/`, etc.

2. **scripts/update.sh** - Update existing installation
   - Currently copies from `.github/workflows/` (line 422)
   - Currently copies from `docs/scripts/` (line 445)
   - Should copy from `src/github/` and `src/docs/scripts/` instead

3. **No scripts/install.sh** - Doesn't exist yet
   - Should be created in `src/scripts/install.sh`
   - Or setup.sh should be moved/copied to src/scripts/install.sh

## New Script Behavior

### src/scripts/install.sh (first-time setup)

```bash
# User runs: ~/5daydocs/src/scripts/install.sh
# Prompts: "Where to install 5daydocs?"
# User enters: ../ (or any path)
# Script copies:
#   src/docs/        → ../docs/
#   src/github/      → ../.github/
#   src/DOCUMENTATION.md → ../DOCUMENTATION.md
#   src/README.md    → ../README.md (if doesn't exist)
```

### src/scripts/update.sh (updates)

```bash
# User runs: ~/5daydocs/src/scripts/update.sh
# Prompts: "Where is your project?"
# User enters: ../my-project (or any path)
# Script updates:
#   src/docs/scripts/*.sh → ../my-project/docs/scripts/
#   src/github/workflows/ → ../my-project/.github/workflows/
#   src/github/ISSUE_TEMPLATE/ → ../my-project/.github/ISSUE_TEMPLATE/
#   INDEX.md files, TEMPLATE files, etc.
```

## Key Changes Required

### For install.sh

- [ ] Change source from `templates/` to `src/`
- [ ] Update all copy paths: `src/docs/` → target
- [ ] Update GitHub template paths: `src/github/` → target
- [ ] Handle DOCUMENTATION.md and README.md root files
- [ ] Preserve existing user content (don't overwrite STATE.md, etc.)

### For update.sh

- [ ] Change source from `.github/workflows/` to `src/github/workflows/`
- [ ] Change source from `docs/scripts/` to `src/docs/scripts/`
- [ ] Update all copy operations to use src/ as source
- [ ] Preserve migration logic for older versions
- [ ] Keep VERSION reconciliation logic

## Challenges

1. **Backward compatibility**
   - Users with old installations might have old paths
   - Solution: Keep migration logic in update.sh

2. **Dogfooding installation**
   - When installing to "." (current directory for dogfooding)
   - Must not overwrite src/ with itself
   - Solution: Check if target is same as source, skip src/ copy

3. **FIVEDAY_SOURCE_DIR calculation**
   - Scripts currently calculate source from script location
   - With src/scripts/ this changes
   - Solution: `FIVEDAY_SOURCE_DIR` should point to `src/` not root

## Success Criteria

- [ ] src/scripts/install.sh works for first-time installation
- [ ] src/scripts/update.sh works for updating existing installations
- [ ] Both scripts use src/ as single source of truth
- [ ] No references to templates/ or .github/ as source
- [ ] Scripts work for external projects AND dogfooding
- [ ] Backward compatibility maintained
- [ ] All paths correctly calculated from src/ location

## Testing Plan

Test install.sh:
- [ ] Fresh install to new directory
- [ ] Install with existing README.md (should not overwrite)
- [ ] Install to current directory for dogfooding

Test update.sh:
- [ ] Update project with old structure (test migrations)
- [ ] Update project with current structure
- [ ] Update 5daydocs itself (dogfooding)
