# Jira Integration

Automatic synchronization between 5DayDocs tasks and Jira tickets.

## Feature Status: BACKLOG

Task 30 is in backlog - integration exists but needs configuration.

## Overview

This feature automatically creates and updates Jira tickets based on task movements through the 5DayDocs folder system. When tasks move between folders (backlog → next → active → review → archive), corresponding Jira tickets are created or updated with appropriate status transitions.

## Setup Instructions

### Choose Your Platform

#### Option A: GitHub Actions

Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- **JIRA_BASE_URL**: Your Jira instance URL (e.g., `https://yourcompany.atlassian.net`)
- **JIRA_USER_EMAIL**: Email address of the Jira user for API access
- **JIRA_API_TOKEN**: API token for authentication ([Create one here](https://id.atlassian.com/manage-profile/security/api-tokens))
- **JIRA_PROJECT_KEY**: The project key where tickets should be created (e.g., `PROJ`)

#### Option B: Bitbucket Pipelines

Add the following repository variables in Bitbucket (Settings → Pipelines → Repository variables):

- **JIRA_BASE_URL**: Your Jira instance URL (e.g., `https://yourcompany.atlassian.net`)
- **JIRA_USER_EMAIL**: Email address of the Jira user for API access
- **JIRA_API_TOKEN**: API token for authentication (mark as secured)
- **JIRA_PROJECT_KEY**: The project key where tickets should be created (e.g., `PROJ`)

Enable Pipelines in your repository settings if not already active.

### 2. Create Custom Field in Jira

To track 5DayDocs task IDs in Jira:

1. Go to Jira Settings → Issues → Custom fields
2. Create a new custom field:
   - Name: "5-Day Task ID"
   - Type: Short text (plain text only)
3. Note the custom field ID (e.g., `customfield_10100`)
4. Update the workflow file with your custom field ID:
   - **GitHub**: Line 47 in `.github/workflows/sync-tasks-to-jira.yml`
   - **Bitbucket**: Line 38 in `bitbucket-pipelines.yml`

### 3. Configure Jira Workflow

Ensure your Jira project has these statuses (or update the workflow file to match your statuses):

- **To Do** - For backlog and sprint queue tasks
- **In Progress** - For active tasks
- **In Review** - For tasks under review
- **Done** - For completed/archived tasks

### 4. Adjust Issue Type (Optional)

The workflow creates "Task" type issues by default. If you use a different issue type, update line 146 in the workflow file.

## How It Works

### Automatic Sync

When you push changes to task files in `work/tasks/*/`:

1. **New Tasks**: Creates Jira tickets with task details
2. **Moved Tasks**: Updates ticket status based on folder location
3. **Deleted Tasks**: Marks tickets as Done with a comment

### Folder to Jira Status Mapping

| 5-Day Folder | Jira Status | Description |
|--------------|-------------|-------------|
| `backlog/` | To Do | Not prioritized |
| `next/` | To Do | Sprint queue (labeled) |
| `working/` | In Progress | Currently working |
| `review/` | In Review | Awaiting approval |
| `live/` | Done | Completed |

### Task Information Synced

Each Jira ticket includes:

- Task ID and title in summary
- Problem description
- Success criteria
- Feature reference
- Current status
- Link to task file location
- Automatic labels: `5day-docs`, `automated`

## Testing the Integration

1. Create a test task in `work/tasks/backlog/`:
   ```bash
   echo "# Task 999: Test Jira Integration" > work/tasks/backlog/999-test-jira.md
   ```

2. Commit and push:
   ```bash
   git add work/tasks/backlog/999-test-jira.md
   git commit -m "Test Jira integration"
   git push
   ```

3. Check your Jira project for the new ticket

4. Move the task through folders to test status updates:
   ```bash
   git mv work/tasks/backlog/999-test-jira.md work/tasks/working/
   git commit -m "Start work on test task"
   git push
   ```

## Limitations

- Requires Jira Cloud (API v3)
- Custom field for Task ID must be created manually
- Status names must match your Jira workflow
- One-way sync only (5DayDocs → Jira)
- Changes made in Jira are not reflected back

## Troubleshooting

### Check Workflow Runs

View GitHub Actions logs:
1. Go to your repository on GitHub
2. Click "Actions" tab
3. Select "Sync Tasks to Jira" workflow
4. Check run logs for errors

### Common Issues

- **Authentication Failed**: Verify API token and email are correct
- **Project Not Found**: Check JIRA_PROJECT_KEY secret
- **Status Transition Failed**: Ensure Jira workflow allows the transition
- **Custom Field Error**: Verify custom field ID in workflow file

## Related

- [GitHub Integration](./github-integration.md) - Similar integration for GitHub Issues
- [Task Management Guide](../guides/task-management.md) - Core task workflow