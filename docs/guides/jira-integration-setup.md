# Jira Integration Setup for 5DayDocs

This guide helps you set up automatic synchronization between your 5DayDocs task management system and Jira.

## Available Templates

### 1. GitHub + Jira Integration
**File:** `sync-tasks-to-jira-github.yml`
**Use when:** Your code is hosted on GitHub and you use Jira for issue tracking

### 2. Bitbucket + Jira Integration
**File:** `bitbucket-pipelines-jira.yml`
**Use when:** Your code is hosted on Bitbucket and you use Jira for issue tracking

## Setup Instructions

### For GitHub + Jira

1. **Copy the workflow file:**
   ```bash
   cp .github/workflow-templates/sync-tasks-to-jira-github.yml .github/workflows/
   ```

2. **Configure GitHub Secrets:**
   Go to your GitHub repository → Settings → Secrets and variables → Actions

   Add the following secrets:
   - `JIRA_BASE_URL`: Your Jira instance URL (e.g., `https://company.atlassian.net`)
   - `JIRA_EMAIL`: Email address associated with your Jira account
   - `JIRA_API_TOKEN`: Generate at [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
   - `JIRA_PROJECT_KEY`: Your Jira project key (e.g., `PROJ`)

3. **Customize Status Mapping (Optional):**
   Edit the workflow file to match your Jira workflow states. The default mapping is:
   - `backlog/` → "To Do"
   - `next/` → "Ready for Dev"
   - `working/` → "In Progress"
   - `review/` → "In Review"
   - `live/` → "Done"

4. **Test the Integration:**
   ```bash
   # Create a test task
   echo "# Task 99: Test Jira Sync" > work/tasks/backlog/99-test-jira-sync.md
   git add work/tasks/backlog/99-test-jira-sync.md
   git commit -m "Test Jira integration"
   git push
   ```

### For Bitbucket + Jira

1. **Copy the pipeline file:**
   ```bash
   cp .github/workflow-templates/bitbucket-pipelines-jira.yml bitbucket-pipelines.yml
   ```

2. **Configure Repository Variables:**
   Go to Bitbucket → Repository settings → Repository variables

   Add the following variables:
   - `JIRA_BASE_URL`: Your Jira instance URL (e.g., `https://company.atlassian.net`)
   - `JIRA_EMAIL`: Email address associated with your Jira account
   - `JIRA_API_TOKEN`: Generate at [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
   - `JIRA_PROJECT_KEY`: Your Jira project key (e.g., `PROJ`)

3. **Enable Pipelines:**
   Go to Repository settings → Pipelines → Settings → Enable Pipelines

4. **Customize Status Mapping (Optional):**
   Same as GitHub instructions above

5. **Test the Integration:**
   Same as GitHub instructions above

## How It Works

### Automatic Sync
- When you push changes to task files in `work/tasks/`, the workflow automatically:
  1. Creates new Jira issues for new tasks
  2. Updates existing issues when tasks move between folders
  3. Transitions issues to match folder status
  4. Adds labels to track 5DayDocs tasks

### Task Identification
- Tasks are matched to Jira issues by the task ID in the title
- Format: "Task {ID}: {Title}"
- Example: "Task 42: Implement user authentication"

### Folder to Status Mapping
| 5DayDocs Folder | Jira Status | Labels |
|-----------------|-------------|--------|
| `backlog/` | To Do | 5day-task, backlog |
| `next/` | Ready for Dev | 5day-task, sprint |
| `working/` | In Progress | 5day-task, working |
| `review/` | In Review | 5day-task, review |
| `live/` | Done | 5day-task, completed |

## Manual Sync

### GitHub
Trigger manually via GitHub Actions:
1. Go to Actions tab
2. Select "Sync 5DayDocs Tasks to Jira"
3. Click "Run workflow"

### Bitbucket
Trigger manually via Pipelines:
1. Go to Pipelines
2. Click "Run pipeline"
3. Select branch and pipeline

## Troubleshooting

### Common Issues

1. **"Issue not created" errors:**
   - Check your Jira project permissions
   - Verify the API token is valid
   - Ensure the project key is correct

2. **"Cannot transition issue" errors:**
   - Your Jira workflow may have different status names
   - Check transition rules in Jira (some transitions may require fields)
   - Update the status mapping in the workflow file

3. **"Authentication failed" errors:**
   - Regenerate your API token
   - Verify the email address is correct
   - Check that secrets/variables are properly set

### Debug Mode

To see detailed API responses, modify the workflow:

```bash
# Add -v flag to curl commands for verbose output
curl -v -X POST ...
```

## Customization Options

### Change Issue Type
Default is "Task". To use "Story" or other types:
```json
"issuetype": {
  "name": "Story"  // Change from "Task"
}
```

### Add Custom Fields
Add to the `fields` object in CREATE_PAYLOAD:
```json
"customfield_10001": "value",
"priority": {"name": "High"}
```

### Different Label Strategy
Modify the `JIRA_LABELS` variable assignment in the case statement.

## Security Notes

- Never commit API tokens or credentials directly in files
- Use GitHub Secrets or Bitbucket Variables for sensitive data
- Regularly rotate API tokens
- Limit Jira API token permissions to minimum required

## Support

For issues with:
- **5DayDocs system:** Check work/bugs/ folder
- **GitHub Actions:** Check Actions tab for logs
- **Bitbucket Pipelines:** Check Pipelines tab for logs
- **Jira API:** Consult [Jira REST API docs](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)