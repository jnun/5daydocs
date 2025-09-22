# Create Jira Synchronization Scripts

## Problem
Both GitHub+Jira and Bitbucket+Jira options need scripts to sync tasks between the file system and Jira issues, but these scripts don't exist yet.

## Desired Outcome
- Script to sync work/tasks/ files to Jira issues
- Script to sync Jira issue updates back to task files
- Support for both GitHub and Bitbucket environments
- Handles task state transitions (backlog → next → working → review → live)
- Maps to appropriate Jira workflow states

## Testing Criteria
- [ ] Script creates Jira issues from new task files
- [ ] Script updates Jira issues when tasks move between folders
- [ ] Script handles Jira authentication securely
- [ ] Works with both GitHub Actions and Bitbucket Pipelines
- [ ] Preserves task ID mapping between systems