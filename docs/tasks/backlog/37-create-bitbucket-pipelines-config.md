# Task 37: Create Bitbucket Pipelines Configuration

**Feature**: none
**Created**: 2025-10-19


## Problem
When users select "Bitbucket with Jira" in setup.sh, no Bitbucket-specific files are created. Need to create bitbucket-pipelines.yml and related configuration.

## Success criteria
- bitbucket-pipelines.yml file created with task syncing pipeline
- Pipeline triggers on task file changes in work/tasks/
- Configuration matches the functionality of GitHub Actions workflows
- Proper Jira integration using Bitbucket's native features

- [ ] bitbucket-pipelines.yml is created when Bitbucket option selected
- [ ] File is placed in correct location (repository root)
- [ ] Pipeline syntax is valid for Bitbucket
