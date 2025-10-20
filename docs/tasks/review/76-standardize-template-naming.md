# Task 76: Standardize Template File Naming Convention

**Feature**: none
**Created**: 2025-10-19


## Objective
Apply consistent naming convention to all template files for clarity and maintainability.

## Current State
- Some files use `.template` suffix (e.g., `STATE.md.template`)
- Some files don't (e.g., workflow `.yml` files)
- Inconsistent use of prefixes

## Proposed Convention
- Use `.template` suffix ONLY for files that require variable substitution (e.g., {{DATE}})
- Keep standard extensions for files that are used as-is (e.g., `.yml` for workflows)
- Use kebab-case for all file names

## Files to Review
1. `templates/project/STATE.md.template` - KEEP .template (has {{DATE}} variable)
2. `templates/project/README.md` - No .template needed (used as-is)
3. `templates/workflows/bitbucket/pipelines.yml.template` - Check if has variables
4. All GitHub workflow files - Check if need .template suffix

## Steps
1. Review each template file for variable placeholders
2. Add/remove .template suffix based on presence of variables
3. Ensure all names use kebab-case
4. Update any scripts that reference renamed files

## Dependencies
- Tasks 72-75 should be completed first

## Success criteria
- Consistent naming convention applied
- Scripts updated to reference new names

## Problem
[Description of what needs to be done]
