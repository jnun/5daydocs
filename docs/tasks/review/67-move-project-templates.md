# Task 67: Move Project Templates to Unified Structure

**Feature**: none
**Created**: 2025-10-19


## Objective
Move README.md and STATE.md templates from scattered locations to `/templates/project/`

## Steps
1. Move `/distribution-templates/README.md` to `/templates/project/README.md`
2. Move `/distribution-templates/STATE.md` to `/templates/project/STATE.md`
3. Move `/docs/work/templates/STATE.md.template` to `/templates/project/STATE.md.template`

## Commands
```bash
git mv distribution-templates/README.md templates/project/
git mv distribution-templates/STATE.md templates/project/
git mv docs/work/templates/STATE.md.template templates/project/
```

## Dependencies
- Task 66 must be completed first (directory structure exists)

## Success criteria
- All project template files in `/templates/project/`

## Problem
[Description of what needs to be done]
