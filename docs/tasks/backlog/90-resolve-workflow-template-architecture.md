# Task 90: Resolve Workflow Template Architecture

**Feature**: none
**Created**: 2025-10-19

## Problem

**CRITICAL DISCOVERY:** The current architecture is broken for distribution!

When workflow templates were deleted from `templates/workflows/github/` (commit 1947ee7), it created a critical gap in the distribution pipeline:

1. `build-distribution.sh` creates clean distribution repo but does NOT copy `.github/` directory
2. `setup.sh:401` tries to copy FROM `$FIVEDAY_SOURCE_DIR/.github/workflows/sync-tasks-to-issues.yml`
3. **Result:** Users installing from built distribution get NO workflow files (fails silently)

**Current state:**
- Development repo: ✅ Has `.github/workflows/`, setup.sh works
- Distribution repo (from build-distribution.sh): ❌ Missing `.github/workflows/`, setup.sh fails
- `setup.sh` and `update.sh` expect to copy from `.github/workflows/`
- Documentation (`docs/guides/templates-index.md`) is outdated

**Root cause:**
The deletion of templates solved the sync problem but broke the distribution build process. The architecture didn't account for how workflow files get from development → distribution → user installation.

**Three distinct needs:**
1. **Development**: Edit workflows in dev repo without sync overhead
2. **Distribution packaging**: Get workflows into built distribution repo
3. **User installation**: setup.sh copies workflows to user's project

The core conflict is WHERE workflows should live in the distribution repo and HOW they get there.

## Success criteria

- [ ] Distribution repo (from build-distribution.sh) includes workflow files
- [ ] setup.sh successfully copies workflows when installing from distribution
- [ ] Development workflow allows editing .github/workflows/ without manual sync
- [ ] No manual sync required between development and distribution workflows
- [ ] Clear documentation explains the distribution build process
- [ ] Update `docs/guides/templates-index.md` to reflect architecture
- [ ] Validation ensures build-distribution.sh includes all necessary files
- [ ] Implementation follows software engineering best practices (DRY, single source of truth)
- [ ] Test both installation paths: from dev repo and from distribution repo

## Notes

**Proposed Solution Options:**

### Option 1: Copy .github/ to Distribution (Simplest Fix) ⭐
**Modify build-distribution.sh to include .github/ in distribution:**
```bash
# Add after line 49 (cp -r templates):
echo "📋 Copying GitHub configuration..."
cp -r .github "$DIST_PATH/"
```

**Pros:**
- ✅ One-line fix to build-distribution.sh
- ✅ setup.sh works as-is (no changes needed)
- ✅ Distribution repo can run workflows (might be useful for testing)
- ✅ Simple, maintainable, no sync needed

**Cons:**
- ⚠️ Distribution has active .github/ directory (workflows could run on distribution repo)
- ⚠️ Exposes .github/ as part of public distribution structure

### Option 2: Build-time Template Generation (Clean Separation)
**build-distribution.sh generates templates from .github/workflows/:**
```bash
# Copy workflows to templates during build
mkdir -p "$DIST_PATH/templates/workflows/github"
cp .github/workflows/*.yml "$DIST_PATH/templates/workflows/github/"
```
**Modify setup.sh to copy from templates instead of .github:**
```bash
# Change line 401 to copy from templates
if [ -f "$FIVEDAY_SOURCE_DIR/templates/workflows/github/sync-tasks-to-issues.yml" ]; then
```

**Pros:**
- ✅ Clean separation: dev uses .github/, distribution uses templates/
- ✅ Distribution doesn't have active workflows directory
- ✅ Single source of truth (.github/ in dev) with automated transformation
- ✅ Can add build-time processing (variable substitution, validation)
- ✅ Aligns with DRY principle

**Cons:**
- ⚠️ Requires updating both build-distribution.sh AND setup.sh
- ⚠️ Slightly more complex build process
- ⚠️ Templates in dev repo vs distribution repo differ (dev has none, dist has templates/)

### Option 3: Hybrid - Copy to Both Locations
**build-distribution.sh copies workflows to BOTH .github/ and templates/:**
- Keeps .github/ for functional testing of distribution
- Keeps templates/ for clear distribution packaging
- setup.sh can copy from either location

**Pros:**
- ✅ Maximum flexibility
- ✅ Distribution can run workflows for testing
- ✅ Templates available for reference

**Cons:**
- ❌ Creates duplication in distribution repo (same files in two places)
- ❌ Violates DRY principle
- ❌ Confusing which is "source of truth" in distribution

### Option 4: No Build Distribution (Direct Clone/Submodule)
**Eliminate build-distribution.sh entirely:**
- Users clone/submodule the development repo directly
- Accept that they get dev artifacts (docs/tasks/live/, etc.)
- Add .gitattributes to exclude dev artifacts when cloning

**Pros:**
- ✅ Simplest possible architecture
- ✅ No build process needed
- ✅ Users always get latest .github/workflows/

**Cons:**
- ❌ Users get ALL development artifacts (cluttered)
- ❌ Can't create "clean" distribution
- ❌ May confuse users with 5daydocs' own task files

---

## Recommended Solution: **Option 2** (Build-time Template Generation)

**Why this is best:**
1. **Fixes the critical bug** - Distribution will have workflow files
2. **Clean architecture** - Development uses .github/, distribution uses templates/
3. **Single source of truth** - .github/workflows/ in dev, generated during build
4. **Extensible** - Can add platform-specific variants, variable substitution, validation
5. **Aligns with existing patterns** - Already using build-distribution.sh for STATE.md.template
6. **Best practices** - Separation of dev vs distribution concerns

**Implementation approach:**
1. Update build-distribution.sh to copy .github/workflows/ → templates/workflows/github/
2. Update setup.sh to copy from templates/workflows/github/ (revert to pre-1947ee7 behavior)
3. Keep .github/workflows/ as the ONLY editable source in dev repo
4. Templates in distribution are build artifacts (never manually edited)
5. Add validation to ensure workflow files are included in build

**Alternative: Quick Fix Option 1**
If you want the simplest immediate fix:
- Just add `cp -r .github "$DIST_PATH/"` to build-distribution.sh
- Solves the critical bug immediately
- Can always refactor to Option 2 later for cleaner architecture

**Files requiring changes (Option 2):**
- `scripts/build-distribution.sh` - Add workflow → template copy step
- `setup.sh` - Change line 401 to copy from templates/ instead of .github/
- `docs/guides/templates-index.md` - Update to reflect new architecture
- README.md - Document the build process clearly

**Files requiring changes (Option 1):**
- `scripts/build-distribution.sh` - Add .github/ copy step (one line)

**Current workflow files to distribute:**
- `.github/workflows/sync-tasks-to-issues.yml` - Primary GitHub Issues integration
- `.github/ISSUE_TEMPLATE/*.md` - Issue templates (bug, feature, task)
- `.github/pull_request_template.md` - PR template

**Testing checklist:**
1. Run build-distribution.sh to create distribution
2. Verify workflow files exist in distribution (either .github/ or templates/)
3. Run setup.sh from distribution to install to test project
4. Verify test project receives workflow files in .github/workflows/
5. Test workflow execution in test project
