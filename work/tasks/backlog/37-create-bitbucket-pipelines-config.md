# Task 37: Create Bitbucket Pipelines Configuration

## Problem
When users select "Bitbucket with Jira" in setup.sh, no Bitbucket-specific files are created. Need to create bitbucket-pipelines.yml and related configuration.

## Desired Outcome
- bitbucket-pipelines.yml file created with task syncing pipeline
- Pipeline triggers on task file changes in work/tasks/
- Configuration matches the functionality of GitHub Actions workflows
- Proper Jira integration using Bitbucket's native features

## Testing Criteria
- [ ] bitbucket-pipelines.yml is created when Bitbucket option selected
- [ ] File is placed in correct location (repository root)
- [ ] Pipeline syntax is valid for Bitbucket
- [ ] Jira integration points are configured