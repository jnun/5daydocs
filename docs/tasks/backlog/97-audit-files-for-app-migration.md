# Task 97: Audit Files for src/ Creation

**Feature**: none
**Created**: 2025-10-21

## Description

Audit all current files in the 5daydocs repository to determine what templates need to be created in `src/` (distributable install code) vs. what stays in root (development workspace and project documentation).

## Goals

1. Create comprehensive inventory of all files in repository
2. Categorize each file/directory:
   - **src/** - Template files that get copied when users install 5daydocs
   - **Root** - Development/dogfooding files for building 5daydocs itself
   - **Create** - Files that need to be created as clean templates in src/
3. Identify any conflicts or edge cases
4. Document the categorization decisions

## Key Questions to Answer

- What files in `.github/` should be templated in `src/github/` vs staying for 5daydocs repo itself?
- What template files need to be created in `src/docs/` (empty folders, INDEX.md, TEMPLATE files)?
- How does current `docs/` content relate to clean `src/docs/` templates?
- Which scripts are for end users vs developers?
- What install scripts need to be created in `src/`?

## Expected Output

A categorized list in this task file showing:
```
src/ (install templates to create):
  - docs/ (clean template structure with INDEX.md files)
  - setup.sh (installation script)
  - 5day.sh (command interface)
  - DOCUMENTATION.md (copy from current)
  - etc.

Root (keep for development):
  - docs/ (our live dogfooding documentation)
  - .git/, scripts/, VERSION (development files)
  - etc.

Template files to create:
  - src/docs/INDEX.md (clean template)
  - src/docs/TEMPLATE-task.md (copy from current)
  - src/setup.sh (new installation script)
```

## AUDIT RESULTS

### ROOT (Keep for Development - 5daydocs project itself)

**Development Files:**
- `README.md` - Development/contributor documentation for 5daydocs project
- `DISTRIBUTION.md` - Development documentation about distributing 5daydocs
- `INDEX.md` - Development workspace index for 5daydocs project  
- `VERSION` - Development version tracking for 5daydocs
- `VERSION_MANAGEMENT.md` - Development documentation about versioning
- `LICENSE` - License file (stays in repo)

**Development Scripts:**
- `setup.sh` - Current installation script (will be replaced by install.sh)
- `scripts/` - All development/build scripts for maintaining 5daydocs
  - `scripts/build-distribution.sh`
  - `scripts/migrate-to-submodule.sh` 
  - `scripts/update.sh` - Our dogfooding update script

**Dogfooding Documentation (Live Project Management):**
- `docs/` - Our actual working documentation (stays exactly as is)
  - `docs/tasks/` - All our real tasks (backlog/, next/, working/, review/, live/)
  - `docs/bugs/` - Our actual bugs and BUG_STATE.md
  - `docs/features/` - Our actual features and specs
  - `docs/guides/` - Our actual guides and documentation  
  - `docs/data/` - Our actual project data
  - `docs/designs/` - Our actual design documents
  - `docs/examples/` - Our actual examples
  - `docs/ideas/` - Our actual ideas
  - `docs/scripts/` - Our actual working scripts
  - `docs/STATE.md` - Our actual project state
  - `docs/INDEX.md` - Our actual documentation index
  - `docs/GITHUB-PROJECTS-SETUP.md` - Our specific setup guide

**Development Workspace:**
- `tmp/` - Temporary development files
- `src/` - Will contain distributable templates (currently exists but empty)

### SRC/ (Install Templates to Create)

**Core Template Structure:**
- `src/docs/` - Clean template documentation structure
  - `src/docs/INDEX.md` (template) 
  - `src/docs/STATE.md.template` (copy from templates/)
  - `src/docs/tasks/` - Template task folders (empty with INDEX.md)
    - `src/docs/tasks/INDEX.md` (template)
    - `src/docs/tasks/TEMPLATE-task.md` (copy from current)
    - `src/docs/tasks/backlog/` (empty folder)
    - `src/docs/tasks/next/` (empty folder) 
    - `src/docs/tasks/working/` (empty folder)
    - `src/docs/tasks/review/` (empty folder)
    - `src/docs/tasks/live/` (empty folder)
  - `src/docs/bugs/` - Template bug structure
    - `src/docs/bugs/INDEX.md` (template)
    - `src/docs/bugs/TEMPLATE-bug.md` (copy from current)
    - `src/docs/bugs/archived/` (empty folder)
  - `src/docs/features/` - Template feature structure
    - `src/docs/features/INDEX.md` (template)
    - `src/docs/features/TEMPLATE-feature.md` (copy from current)
  - `src/docs/scripts/` - Template user scripts  
    - `src/docs/scripts/INDEX.md` (template)
    - `src/docs/scripts/create-task.sh` (copy from current)
    - `src/docs/scripts/create-feature.sh` (copy from current)
    - `src/docs/scripts/validate-tasks.sh` (copy from current)
    - `src/docs/scripts/check-alignment.sh` (copy from current)
  - `src/docs/guides/` - Template guides structure
    - `src/docs/guides/INDEX.md` (template)
    - `src/docs/guides/quick-reference.md` (copy from current)
    - `src/docs/guides/templates-index.md` (copy from current)
  - `src/docs/data/` (empty folder with INDEX.md template)
  - `src/docs/designs/` (empty folder with INDEX.md template)
  - `src/docs/examples/` (empty folder with INDEX.md template)
  - `src/docs/ideas/` (empty folder with INDEX.md template)

**User Interface Files:**
- `src/5day.sh` - Command interface (copy/adapt from current)
- `src/DOCUMENTATION.md` - Usage reference guide (copy from current)

**Optional Integration Templates:**
- `src/github/` - Optional GitHub integration templates
  - `src/github/workflows/` - Template workflows
  - `src/github/ISSUE_TEMPLATE/` - Template issue templates
  - `src/github/pull_request_template.md` - Template PR template

### CREATE (New Files to Create)

**Installation System:**
- `install.sh` (root) - New main installation script
- `src/update.sh` - User update script (different from scripts/update.sh)

**Template Files:**
- All `src/docs/INDEX.md` files - Clean template index files
- Template README.md for user projects
- Clean template STATE.md files

### OBSOLETE (Will be removed after src/ creation)

**Current Template System:**
- `templates/` - Will be obsoleted by src/ structure
  - `templates/project/README.md` 
  - `templates/project/STATE.md.template`
  - `templates/workflows/bitbucket/` - Move relevant parts to src/

## Edge Cases and Conflicts Identified

1. **Dual 5day.sh Purpose**: Current `5day.sh` is for development, need src/ version for users
2. **Dual update.sh Purpose**: `scripts/update.sh` for dogfooding vs `src/update.sh` for users  
3. **DOCUMENTATION.md**: Already perfect - just copy to src/
4. **GitHub Workflows**: Need templates in src/github/ but keep .github/ for 5daydocs repo
5. **Templates Folder**: Content moves to src/, folder becomes obsolete

## Success Criteria

- [x] Complete file inventory created
- [x] Every file/directory categorized with rationale
- [x] Edge cases and conflicts identified  
- [ ] Categorization reviewed and approved
- [ ] Ready to proceed with creating src/ structure

## Categorization Rationale

**Key Principle**: Our `docs/` folder is live dogfooding documentation and stays exactly as is. The `src/docs/` will be clean templates for users.

**Strategy**: Create installation templates in `src/`, keep all development files in root, maintain our dogfooding setup untouched.

**Next Steps**: 
1. Review this categorization
2. Move Task 97 from backlog to next
3. Execute Task 98 (Create src/ structure)
4. Execute subsequent tasks to populate src/ with templates
