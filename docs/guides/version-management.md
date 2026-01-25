# Version Management for 5DayDocs

## Overview

This document explains how VERSION tracking works in 5DayDocs, where VERSION files should exist, and how version information flows through the system.

## Current Version
The current version is stored in `/VERSION` file at the root of the 5daydocs repository.

## When to Update Version

Update the version number whenever you make:
- **Major changes (X.0.0)**: Breaking changes to folder structure or workflow
- **Minor changes (0.X.0)**: New features, scripts, or substantial improvements
- **Patch changes (0.0.X)**: Bug fixes, typos, small improvements

### Files to Update When Changing Version

When you increment the version, you only need to update:
1. `/VERSION` - The master version file (update.sh now reads from this file automatically)

## Version Change Checklist

- [ ] Update `/VERSION` file with new version number
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

## VERSION File Distribution Strategy

### Decision: VERSION File MUST Be Distributed

**Rationale:**
1. **update.sh requires it** - Will error without VERSION file in source directory
2. **setup.sh needs it** - Falls back to "1.0.0" without it (causing incorrect STATE.md)
3. **Distribution IS the source** - For users, the distributed repo is their 5daydocs source
4. **Version tracking** - No other way to know which distribution version is installed

### File Locations

#### Source Repository (Development)
- **Path**: `/VERSION`
- **Purpose**: Source of truth for current framework version
- **Content**: Single line with semantic version (e.g., "2.0.0")

#### Distribution Repository (For Users)
- **Path**: `/VERSION`
- **Purpose**: Enables setup.sh and update.sh to read framework version
- **Created by**: `build-distribution.sh` copies from source VERSION
- **Status**: **REQUIRED** - update.sh will error without it

#### Target Project (User's Project)
- **Path**: `docs/STATE.md` field: `5DAY_VERSION`
- **Purpose**: Tracks which version of 5DayDocs is installed
- **Created by**: setup.sh reads distribution VERSION and writes to STATE.md

### Version Flow Diagram

```
Source Repo          Distribution Repo      Target Project
-----------          -----------------      --------------
VERSION file    →    VERSION file      →   docs/STATE.md
(2.0.0)         copy (2.0.0)          read  5DAY_VERSION: 2.0.0
                by build-dist.sh       by setup.sh
```

### How Scripts Handle VERSION File

#### setup.sh (lines 16-19)
- **Reads**: `$FIVEDAY_SOURCE_DIR/VERSION` (distribution/submodule)
- **Behavior**: Falls back to "1.0.0" if VERSION missing
- **Issue**: Silent fallback causes incorrect version in STATE.md
- **Fix**: After Task 95, VERSION will always exist in distributions

#### update.sh (lines 19-23)
- **Reads**: `$FIVEDAY_SOURCE_DIR/VERSION` (distribution/submodule)
- **Behavior**: Exits with error if VERSION missing
- **Correct**: Fails fast instead of using wrong version

#### build-distribution.sh (lines 8-13, Task 95)
- **Reads**: `VERSION` in source repo
- **Before Task 95**: Does NOT copy VERSION to distribution (BUG)
- **After Task 95**: Copies VERSION to distribution (FIXED)

### Current Issue (Fixed in Task 95)

**Problem**: build-distribution.sh did not copy VERSION file to distributions

**Impact**:
- New installations show `5DAY_VERSION: 1.0.0` instead of `5DAY_VERSION: 2.0.0`
- update.sh fails when trying to update distributed installations
- Users cannot determine which version they have

**Solution**: Task 95 adds VERSION file copying to build-distribution.sh

## Version History

### 2.1.0 (2025-01-25) - Framework Namespace
**BREAKING CHANGE**: Framework files moved to `docs/5day/` namespace

**What Changed:**
- `docs/scripts/` → `docs/5day/scripts/` (framework scripts)
- Added `docs/5day/ai/` for future AI instructions
- `docs/scripts/` now reserved for user's own scripts (optional)

**Migration:**
- Automatic migration in update.sh for all users on version < 2.1.0
- Framework scripts (.sh files) moved to `docs/5day/scripts/`
- User's custom files in `docs/scripts/` are preserved

**Why This Change:**
- Clear separation between framework and user files
- AI agents can easily identify what to edit vs not edit
- `docs/5day/` = framework (read-only), everything else = user content

### 2.0.0 (2025-10-19) - Structure Simplification
**BREAKING CHANGE**: Flattened directory structure

**What Changed:**
- `docs/work/tasks/` → `docs/tasks/`
- `docs/work/bugs/` → `docs/bugs/`
- `docs/work/scripts/` → `docs/5day/scripts/`
- `docs/work/designs/` → `docs/designs/`
- `docs/work/examples/` → `docs/examples/`
- `docs/work/data/` → `docs/data/`
- Removed `docs/work/` directory entirely

**Migration:**
- Automatic migration in update.sh for all users on version < 2.0.0
- Creates timestamped backup before migration
- Safely merges content if conflicts exist
- All user data (tasks, bugs, STATE.md IDs) preserved

**Why This Change:**
- Simpler paths (less nesting)
- Easier to type and remember
- More intuitive structure
- Aligns with "keep it simple" philosophy

**Impact:**
- All existing installations will auto-migrate on first update
- All scripts, documentation, and templates updated
- GitHub workflows updated to use new paths

### 1.2.0 - Previous version (pre-flattening)