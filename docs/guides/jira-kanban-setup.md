# Jira Kanban Board Setup Guide

> **Key Principle**: The `docs/tasks/` folders are the source of truth. Jira is just a visual mirror for stakeholders.

## Overview

This guide shows how to set up automatic synchronization between your 5DayDocs folder system and Jira, creating a kanban board that stakeholders can view. The folders control everything - Jira just displays it.

## What This Integration Does

✅ **Automatic sync from folders to Jira:**
- Creates Jira tickets when tasks appear in any folder
- Updates ticket status when tasks move between folders
- Closes tickets when tasks reach live/
- Works with both GitHub and Bitbucket

✅ **Maintains folder authority:**
- Folders are the single source of truth
- Changes in folders override Jira
- Task IDs from your system preserved in Jira

❌ **What it doesn't do:**
- Does NOT sync Jira changes back to folders
- Does NOT use Jira workflows or rules
- Does NOT require specific Jira configurations

## Prerequisites

1. **Jira Cloud account** (won't work with Jira Server/Data Center)
2. **Repository on GitHub or Bitbucket**
3. **Admin access** to create API tokens and custom fields

## Step-by-Step Setup

### Step 1: Create Jira API Token

1. Go to [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Click **Create API token**
3. Name it "5DayDocs Sync"
4. Copy the token immediately (you won't see it again)

### Step 2: Create Custom Field in Jira

This field will store your task IDs to prevent duplicates:

1. Go to **Jira Settings** → **Issues** → **Custom fields**
2. Click **Create custom field**
3. Choose **Short text (plain text only)**
4. Name it: "5-Day Task ID"
5. Add to all relevant screens
6. Note the field ID (you'll see it in the URL when editing, like `customfield_10100`)

### Step 3: Set Up Repository Variables

#### For GitHub:

1. Go to your repository → **Settings** → **System (from the gear dropdown menu)** → **Secrets and variables** → **Actions**
2. Add these secrets:
   - `JIRA_BASE_URL` - Your Atlassian URL (e.g., `https://yourcompany.atlassian.net`)
   - `JIRA_USER_EMAIL` - Your email address
   - `JIRA_API_TOKEN` - Token from Step 1
   - `JIRA_PROJECT_KEY` - Your Jira project key (e.g., `PROJ`)

#### For Bitbucket:

1. Go to your repository → **Settings** → **Pipelines** → **Repository variables**
2. Add the same variables (mark `JIRA_API_TOKEN` as secured)
3. Enable Pipelines if not already active

### Step 4: Configure the Workflow

#### For GitHub:

Edit `.github/workflows/sync-tasks-to-jira.yml` and update line 47:
```yaml
TASK_ID_FIELD="customfield_10100"  # Replace with your field ID from Step 2
```

#### For Bitbucket:

Edit `bitbucket-pipelines.yml` and update line 38:
```yaml
- TASK_ID_FIELD="customfield_10100"  # Replace with your field ID from Step 2
```

### Step 5: Configure Jira Board

Create a kanban board that matches your folder structure:

1. **Create a new board:**
   - Go to **Boards** → **Create board** → **Create a Kanban board**
   - Choose "Board from an existing project"
   - Select your project

2. **Configure columns to match folders:**
   - Go to **Board settings** → **Columns**
   - Set up these columns:
     - **Backlog** (maps to: To Do status)
     - **Sprint Queue** (maps to: To Do status with label)
     - **In Progress** (maps to: In Progress status)
     - **Review** (maps to: In Review status)
     - **Done** (maps to: Done status)

3. **Set up swimlanes (optional):**
   - Use **Queries** swimlane type
   - Create swimlanes by feature or priority

4. **Configure card layout:**
   - Show: Task ID, Title, Labels
   - Hide: Jira's story points, estimates (not used)

### Step 6: Test the Integration

1. Create a test task:
   ```bash
   echo "# Task 999: Test Jira Sync" > docs/tasks/backlog/999-test-jira.md
   git add docs/tasks/backlog/999-test-jira.md
   git commit -m "Add test task"
   git push
   ```

2. Check Jira - you should see a new ticket in the Backlog column

3. Move the task:
   ```bash
   git mv docs/tasks/backlog/999-test-jira.md docs/tasks/working/
   git commit -m "Start test task"
   git push
   ```

4. The ticket should move to "In Progress" column automatically

## How the Folder → Jira Mapping Works

| Folder | Jira Status | Kanban Column | Description |
|--------|-------------|---------------|-------------|
| `backlog/` | To Do | Backlog | Not prioritized |
| `next/` | To Do + label | Sprint Queue | Ready for sprint |
| `working/` | In Progress | In Progress | Being worked on |
| `review/` | In Review | Review | Awaiting approval |
| `live/` | Done | Done | Completed (ticket closed) |

## Understanding the Sync

### What Gets Synced

From each task file:
- Task ID → Custom field + ticket title
- Task title → Ticket summary
- Problem section → Ticket description
- Success criteria → Ticket description
- Folder location → Ticket status

### One-Way Sync Rules

1. **Folders always win** - Moving a file overrides any Jira status
2. **No back-sync** - Changes in Jira don't affect folders
3. **Automatic labels** - System adds `5day-docs` label to identify synced tickets
4. **Preserve IDs** - Your task IDs are maintained, not Jira's

## Working with the Integration

### Daily Workflow

Just work normally with your folders:
```bash
# Your normal workflow - Jira updates automatically
git mv docs/tasks/next/30-feature.md docs/tasks/working/
git commit -m "Start work on feature"
git push
```

### If Stakeholders Create Tickets in Jira

They can create tickets in Jira, but you need to:
1. Create a corresponding task file in the right folder
2. Include the same ID to link them
3. The folder placement will control the actual status

### Handling Conflicts

If a ticket exists in Jira but not in folders:
- It will show in Jira but won't be managed by the sync
- Create a matching task file to take control

If a task exists in folders but sync failed:
- Check GitHub/Bitbucket Actions logs for errors
- Usually an auth or permission issue

## Troubleshooting

### Sync Not Working?

1. **Check workflow runs:**
   - GitHub: Actions tab → "Sync Tasks to Jira"
   - Bitbucket: Pipelines → Recent runs

2. **Common issues:**
   - Wrong API token or email
   - Custom field not added to screens
   - Project key incorrect
   - Jira status names don't match

### Tickets Not Moving?

- Check if Jira workflow allows the transition
- Verify status names in the workflow file
- Look at action logs for transition errors

### Duplicate Tickets?

- Ensure custom field is configured correctly
- Check that field ID matches in workflow file
- Verify field is on all screens

## Best Practices

1. **Commit messages**: Be clear about what you're doing
   ```bash
   git commit -m "Move task 30 to review"  # Good
   git commit -m "stuff"                   # Bad
   ```

2. **Batch moves**: Move multiple tasks in one commit
   ```bash
   git mv docs/tasks/working/30-*.md docs/tasks/review/
   git mv docs/tasks/working/31-*.md docs/tasks/review/
   git commit -m "Submit tasks 30 and 31 for review"
   ```

3. **Keep folders clean**: Archive completed tasks regularly

4. **For stakeholders**: Share the Jira board link, not individual tickets

## FAQ

**Q: Can I use Jira's workflow features?**
A: No, the folder structure IS the workflow. Jira just displays it.

**Q: What if I accidentally change status in Jira?**
A: Next sync from folders will override it. Folders always win.

**Q: Can I use Jira's sprint features?**
A: No, use the `next/` folder as your sprint queue instead.

**Q: Will comments in Jira sync?**
A: No, this is display-only. Use task files for documentation.

**Q: Can I customize the columns?**
A: Yes, but they should match your folder structure conceptually.

## Summary

This integration gives you:
- ✅ Stakeholder-friendly kanban view
- ✅ Automatic status updates
- ✅ Your folder system as source of truth
- ✅ No manual Jira management
- ❌ Not using Jira's complex features
- ❌ Not replacing your workflow

The folders drive everything. Jira just shows what's happening.
