# Task 99: Migrate Files to src/ Structure

**Feature**: none
**Created**: 2025-10-21
**Depends on**: Task 98 (src/ structure must exist)

## Description

Copy distributable files from their current locations into the new `src/` directory structure. This establishes `src/` as the single source of truth for 5daydocs software distribution.

## Migration Strategy

### Copy (not move) - Files needed in both places

These files stay in current location AND get copied to src/:
- `.github/workflows/` → `src/github/workflows/` (5daydocs repo needs workflows too)
- `.github/ISSUE_TEMPLATE/` → `src/github/ISSUE_TEMPLATE/`
- `.github/pull_request_template.md` → `src/github/pull_request_template.md`

### Move - Files only needed in src/

These files move entirely to src/:
- `templates/` content → `src/` (templates becomes obsolete)
- Create new `src/DOCUMENTATION.md` (explain 5daydocs usage)
- Create new `src/README.md` (template for user projects)

### Copy from docs/ - Template/structure files

These get copied to src/docs/ as templates:
- `docs/tasks/INDEX.md` → `src/docs/tasks/INDEX.md`
- `docs/tasks/TEMPLATE-task.md` → `src/docs/tasks/TEMPLATE-task.md`
- `docs/bugs/INDEX.md` → `src/docs/bugs/INDEX.md`
- `docs/bugs/TEMPLATE-bug.md` → `src/docs/bugs/TEMPLATE-bug.md`
- `docs/features/INDEX.md` → `src/docs/features/INDEX.md`
- `docs/features/TEMPLATE-feature.md` → `src/docs/features/TEMPLATE-feature.md`
- `docs/scripts/*.sh` → `src/docs/scripts/*.sh`
- `docs/scripts/INDEX.md` → `src/docs/scripts/INDEX.md`
- All other INDEX.md files from docs/

### Files that stay in root only

- `docs/` (live tasks for 5daydocs development - dogfooding)
- `.git/`, `.gitignore`, `.gitmodules`
- `VERSION`, `LICENSE`, `CLAUDE.md`
- Root `README.md` (about 5daydocs project itself)
- `scripts/` (developer tools, not user tools)

## Challenges to Address

1. **Dual purpose of .github/**
   - 5daydocs repo needs workflows for its own automation
   - Users need workflows as templates
   - Solution: Copy to src/github/, keep in root

2. **docs/ confusion**
   - Current docs/ has live 5daydocs tasks
   - Users need clean docs/ structure
   - Solution: src/docs/ is clean template, root docs/ is live dogfooding

3. **scripts/ confusion**
   - `docs/scripts/` are user-facing daily tools
   - `src/scripts/` are install/update tools
   - `scripts/` (root) are developer tools
   - Solution: Three separate locations, different purposes

## Success Criteria

- [ ] All distributable files copied/moved to src/
- [ ] src/ contains complete, functional 5daydocs distribution
- [ ] Root still contains development files
- [ ] No broken references or missing files
- [ ] templates/ directory handled appropriately
- [ ] Documentation updated to reflect new structure

## Testing

After migration:
- [ ] Verify src/ can be installed standalone
- [ ] Verify dogfooding still works in root docs/
- [ ] Verify no circular dependencies
