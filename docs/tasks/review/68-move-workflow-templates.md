# Task 68: Move Workflow Templates to Unified Structure

**Feature**: none
**Created**: 2025-10-19


## Objective
Reorganize all CI/CD workflow templates into `/templates/workflows/` with platform-specific subdirectories

## Steps
1. Move GitHub workflow templates to `/templates/workflows/github/`
2. Move Bitbucket pipeline templates to `/templates/workflows/bitbucket/`
3. Move Jira integration documentation to `/templates/docs/`

## Commands
```bash
# Move GitHub workflows
git mv templates/github-workflows/*.yml templates/workflows/github/

# Move Bitbucket templates
git mv templates/bitbucket-pipelines*.yml* templates/workflows/bitbucket/

# Move documentation
git mv templates/JIRA_INTEGRATION_SETUP.md templates/docs/
git mv templates/INDEX.md templates/docs/TEMPLATES_INDEX.md
```

## Dependencies
- Task 66 must be completed first (directory structure exists)

## Success criteria
- All workflows organized by platform
- Documentation moved to `/templates/docs/`

## Problem
[Description of what needs to be done]
