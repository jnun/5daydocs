# Task 33: GitHub Workflow Files Not Being Copied

**Feature**: none
**Created**: 2025-10-19


## Problem
The setup.sh script creates the .github/workflows directory but does not copy any workflow files into it, leaving it empty.

## Success criteria
When setup.sh runs, the appropriate GitHub Actions workflow files should be copied based on platform selection:
- GitHub with Issues: sync-tasks-to-issues.yml
- GitHub with Jira: sync-tasks-to-jira.yml and sync-jira-to-git.yml
- Bitbucket: no GitHub Actions needed

- [ ] Run setup.sh with GitHub Issues option - verify sync-tasks-to-issues.yml is copied
- [ ] Run setup.sh with GitHub+Jira option - verify both Jira workflows are copied
- [ ] Run setup.sh with Bitbucket option - verify no .github directory is created
