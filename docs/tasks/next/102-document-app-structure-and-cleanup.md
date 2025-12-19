# Task 102: Document src/ Structure and Cleanup

**Feature**: none
**Created**: 2025-10-21
**Depends on**: Task 101 (testing must pass)

## Description

Document the new `src/` structure, update all relevant documentation, and clean up obsolete files/references.

## Documentation Updates

### 1. Update Root README.md

Current root README.md should explain:
- What 5daydocs project is (tool for building file-based project management)
- How to use 5daydocs on another project
- How to contribute to 5daydocs development
- Explain src/ vs docs/ distinction

Add sections:
```markdown
## Repository Structure

- `src/` - The 5daydocs distribution (install this in your project)
- `docs/` - Dogfooding 5daydocs to manage 5daydocs development
- `scripts/` - Developer tools for maintaining 5daydocs
- `README.md` - About the 5daydocs project

## Quick Start for Users

Install 5daydocs in your project:
\`\`\`bash
git clone https://github.com/yourusername/5daydocs.git ~/5daydocs
cd ~/5daydocs
src/scripts/install.sh
\`\`\`

## Quick Start for Contributors

...
```

### 2. Create src/README.md

Template README for user projects (what gets copied to their root):
```markdown
# Project Name

This project uses [5daydocs](https://github.com/...) for file-based project management.

See DOCUMENTATION.md for how to use the 5daydocs workflow.
```

### 3. Create src/DOCUMENTATION.md

Complete guide for using 5daydocs:
- Overview of file-based project management
- Directory structure explanation
- Task workflow (backlog → next → working → review → live)
- Using scripts (create-task.sh, etc.)
- Integration with GitHub/Jira
- STATE.md management

### 4. Update docs/guides/templates-index.md

Currently explains templates/ architecture. Should be updated or removed since templates/ becomes obsolete. Replace with:
- `docs/guides/app-structure.md` - Explains src/ directory
- How developers maintain src/
- How src/ is distributed to users

### 5. Update CLAUDE.md

If exists, update to reflect new structure:
- How AI should navigate src/ vs docs/
- Where to find source of truth
- Development workflow

## Cleanup Tasks

### Files to Delete

- [ ] `templates/` directory (content moved to src/)
- [ ] Old `docs/guides/templates-index.md` (replace with app-structure.md)
- [ ] Any obsolete scripts referencing templates/

### Files to Update References

Search and update references to templates/:
- [ ] All .md files mentioning templates/
- [ ] Any scripts with hardcoded paths
- [ ] GitHub workflow files if they reference structure

### scripts/ Directory Clarification

Add README to scripts/ explaining:
```markdown
# Developer Scripts

These scripts are for 5daydocs developers, NOT for end users.

- `build-distribution.sh` - [explain or remove if obsolete]
- `migrate-to-submodule.sh` - [explain purpose]
- `update.sh` - [explain vs src/scripts/update.sh]

For user-facing installation scripts, see `src/scripts/`.
```

## Version Update

- [ ] Update VERSION file (if this is a major change)
- [ ] Update STATE.md.template to include version reference
- [ ] Consider this a 3.0.0 release (major structural change)

## Git Cleanup

- [ ] Remove templates/ from git (git rm -r templates/)
- [ ] Commit all src/ structure
- [ ] Update .gitignore if needed
- [ ] Ensure .gitkeep files in empty src/docs/ subdirectories

## Success Criteria

- [ ] All documentation accurate and up-to-date
- [ ] src/ structure fully documented
- [ ] Obsolete files removed
- [ ] No broken references to templates/
- [ ] Clear separation between developer docs and user docs
- [ ] README files clear for both developers and users
- [ ] Version properly incremented

## Final Verification

- [ ] Read through all documentation as a new user
- [ ] Read through all documentation as a new contributor
- [ ] Verify no confusion about src/ vs docs/ vs templates/
- [ ] All links work
- [ ] No TODOs or outdated information
