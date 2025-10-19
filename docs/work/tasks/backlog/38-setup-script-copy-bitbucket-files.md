# Task 38: Setup Script Copy Bitbucket Configuration Files

**Feature**: none
**Created**: 2025-10-19


## Problem
The setup.sh script currently skips all automation setup when "Bitbucket with Jira" is selected, only showing a message about skipping GitHub Actions. It should copy Bitbucket-specific configuration files.

## Success Criteria
- setup.sh copies bitbucket-pipelines.yml when Bitbucket option is selected
- Any Bitbucket-specific scripts are copied to work/scripts/
- Clear feedback about what Bitbucket files were set up
- Platform-specific instructions for Bitbucket+Jira configuration

- [ ] Run setup.sh with Bitbucket option - verify bitbucket-pipelines.yml is copied
- [ ] Verify no GitHub Actions files are created for Bitbucket option
- [ ] Output messages correctly describe Bitbucket setup
