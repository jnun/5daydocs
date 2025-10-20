# Task 92: Copy Template Ideas to Project on Install/Update

**Feature**: none
**Created**: 2025-10-20

## Problem
When users run `setup.sh` or `scripts/update.sh` to install or update 5daydocs in their project, the scripts create an empty `docs/ideas/` folder but don't populate it with helpful starter content or template files.

Currently:
- The 5daydocs repository has useful example content in `docs/ideas/` (e.g., `naming-schema.md`)
- These files would be helpful for new projects as examples or starting points
- `setup.sh` and `scripts/update.sh` only create the `docs/ideas/` directory structure
- No template content is copied from `templates/` into the user's project

This means new projects miss out on helpful starter content that could guide them in using the ideas folder effectively.

## Success Criteria
- [ ] Create `templates/project/ideas/` directory structure
- [ ] Move or copy example idea files (like `naming-schema.md`) to `templates/project/ideas/`
- [ ] Update `setup.sh` to copy template idea files to user's `docs/ideas/` during initial installation
- [ ] Update `scripts/update.sh` to optionally copy new template files (without overwriting existing user content)
- [ ] Add logic to check if idea template files already exist before copying (preserve user modifications)
- [ ] Test: Fresh install should include template idea files in `docs/ideas/`
- [ ] Test: Update on existing project should not overwrite existing idea files
- [ ] Test: Update on project with empty ideas folder should add template files
- [ ] Document the template structure in README.md or DOCUMENTATION.md

## Implementation Notes
Consider the following approach:
1. Create template structure at `templates/project/ideas/` with example files
2. In `setup.sh`, add copy logic similar to how STATE.md.template is handled
3. In `scripts/update.sh`, add conditional copy (only if file doesn't exist)
4. Preserve the distinction between template content and user-generated content
