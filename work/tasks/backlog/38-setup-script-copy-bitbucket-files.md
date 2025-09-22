# Setup Script Copy Bitbucket Configuration Files

## Problem
The setup.sh script currently skips all automation setup when "Bitbucket with Jira" is selected, only showing a message about skipping GitHub Actions. It should copy Bitbucket-specific configuration files.

## Desired Outcome
- setup.sh copies bitbucket-pipelines.yml when Bitbucket option is selected
- Any Bitbucket-specific scripts are copied to work/scripts/
- Clear feedback about what Bitbucket files were set up
- Platform-specific instructions for Bitbucket+Jira configuration

## Testing Criteria
- [ ] Run setup.sh with Bitbucket option - verify bitbucket-pipelines.yml is copied
- [ ] Verify no GitHub Actions files are created for Bitbucket option
- [ ] Output messages correctly describe Bitbucket setup
- [ ] Instructions for Jira webhook configuration are shown