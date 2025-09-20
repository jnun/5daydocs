# Git as Source of Truth: Complete Sync Guide

> **Core Principle**: Git is ALWAYS the source of truth. Any conflicts are resolved by Git overriding external systems.

## Overview

This system provides true bidirectional sync between Git and Jira while maintaining Git's authority:

1. **Git → Jira**: Push changes immediately when tasks move
2. **Jira → Git**: Pull new tickets every 15 minutes and create task files
3. **Conflict Resolution**: Git always wins, Jira adjusts to match

## How It Works

### Two-Way Sync Architecture

```
Git Repository (SOURCE OF TRUTH)
    ↓ (on push - immediate)
GitHub/Bitbucket Actions
    ↓
Jira (MIRROR)
    ↓ (every 15 min - reconciliation)
GitHub/Bitbucket Actions
    ↓ (creates missing tasks)
Git Repository (auto-commit new tasks)
```

### Key Components

1. **Push Sync** (`sync-tasks-to-jira.yml`)
   - Triggers on every push to `work/tasks/**/*.md`
   - Updates Jira to match current Git state
   - Creates/updates/transitions tickets instantly

2. **Pull Reconciliation** (`sync-jira-to-git.yml`)
   - Runs every 15 minutes (or manually)
   - Finds tickets created in Jira
   - Creates task files in Git
   - Auto-assigns next available task ID
   - Commits changes back to repository

3. **Conflict Resolution**
   - If status differs: Git folder location wins
   - If task missing in Git: Create it
   - If task missing in Jira: Create ticket
   - If ID conflicts: Generate new ID

## Setup Instructions

### Step 1: Configure Base Sync

Follow the [Jira Kanban Setup Guide](./jira-kanban-setup.md) first to set up:
- API credentials
- Custom field for Task ID
- Basic push sync

### Step 2: Enable Pull Reconciliation

1. **Ensure both workflows are present:**
   - `.github/workflows/sync-tasks-to-jira.yml` (push)
   - `.github/workflows/sync-jira-to-git.yml` (pull)

2. **Configure the reconciliation workflow:**
   Edit `.github/workflows/sync-jira-to-git.yml`:
   ```yaml
   # Line 49 - Update with your custom field ID
   TASK_ID_FIELD="customfield_10100"
   ```

3. **Set up Git bot identity:**
   The workflow uses a bot identity for auto-commits:
   ```yaml
   git config --global user.email "bot@5daydocs.local"
   git config --global user.name "5DayDocs Bot"
   ```

### Step 3: Test the System

1. **Test Git → Jira:**
   ```bash
   echo "# Task 100: Test Push Sync" > work/tasks/backlog/100-test-push.md
   git add work/tasks/backlog/100-test-push.md
   git commit -m "Test push sync"
   git push
   # Check Jira - ticket should appear
   ```

2. **Test Jira → Git:**
   - Create a ticket directly in Jira
   - Wait 15 minutes (or trigger manually in Actions)
   - Pull changes: `git pull`
   - New task file should appear in appropriate folder

3. **Test Conflict Resolution:**
   - Move task in Git: `git mv work/tasks/backlog/100-*.md work/tasks/working/`
   - Commit and push
   - Jira ticket should update to "In Progress"

## Automatic Behaviors

### When Someone Creates a Ticket in Jira

1. **Within 15 minutes:**
   - Reconciliation job runs
   - Detects ticket without Task ID
   - Assigns next available ID
   - Creates task file in appropriate folder
   - Updates Jira ticket with Task ID
   - Commits to Git automatically

2. **Task placement based on Jira status:**
   - "To Do" → `backlog/` or `next/` (based on labels)
   - "In Progress" → `working/`
   - "In Review" → `review/`
   - Other → `backlog/` (default)

### When Tasks Move in Git

1. **Immediately on push:**
   - Jira ticket status updates
   - Labels adjust to match folder
   - No manual intervention needed

### When Conflicts Occur

| Conflict Type | Resolution |
|--------------|------------|
| Task in Git, not in Jira | Create Jira ticket |
| Task in Jira, not in Git | Create task file, auto-commit |
| Status mismatch | Update Jira to match Git folder |
| Duplicate IDs | Assign new ID to newer entry |
| Deleted in Git | Close Jira ticket |
| Closed in Jira | Remains in Git (manual move to live/ needed) |

## Working with the System

### For Developers

Continue working normally:
```bash
# Your workflow doesn't change
git mv work/tasks/next/30-feature.md work/tasks/working/
git commit -m "Start work on feature"
git push
```

### For Project Managers

Can create tickets in Jira:
- Create ticket with title and description
- System auto-imports within 15 minutes
- Task appears in Git with proper ID
- Can track progress in Jira kanban

### For AI Assistants

When resolving conflicts:
```bash
# 1. Always pull latest
git pull

# 2. Check STATE.md for current highest ID
cat work/STATE.md

# 3. If creating tasks from Jira tickets, use next ID
# 4. If conflict in IDs, renumber the newer one
# 5. Update STATE.md with new highest
# 6. Commit all changes together
```

## Important Notes

### Task ID Management

- **STATE.md** is the authority for ID assignment
- IDs are sequential, starting from 0
- Never reuse IDs, even if task deleted
- Reconciliation auto-updates STATE.md

### Timing Considerations

- **Git → Jira**: Instant (on push)
- **Jira → Git**: Every 15 minutes
- **Manual trigger**: Go to Actions → "Reconcile Jira with Git" → Run workflow

### Commit History

Auto-commits from reconciliation will appear as:
```
Author: 5DayDocs Bot <bot@5daydocs.local>
Message: Reconcile Jira tickets with Git source of truth
```

### Permissions Required

GitHub repository needs:
- Actions: Write (to run workflows)
- Contents: Write (to commit changes)
- Pull requests: Write (optional, for PR creation)

## Troubleshooting

### Reconciliation Not Running

1. Check Actions tab for workflow runs
2. Verify cron schedule is active
3. Ensure secrets are configured
4. Check workflow permissions

### Tasks Not Appearing in Git

1. Verify Jira ticket exists in correct project
2. Check if ticket already has Task ID (won't recreate)
3. Look at reconciliation logs for errors
4. Ensure custom field is on Jira screens

### Status Not Syncing

1. Confirm Jira workflow has matching status names
2. Check if transitions are allowed
3. Verify folder structure matches expected pattern
4. Review push sync logs

### Duplicate Tasks Created

This shouldn't happen, but if it does:
1. Check STATE.md for highest ID
2. Renumber the duplicate
3. Update Jira ticket with correct ID
4. Commit fixes

## Advanced Configuration

### Change Reconciliation Frequency

Edit `.github/workflows/sync-jira-to-git.yml`:
```yaml
schedule:
  - cron: '*/5 * * * *'  # Every 5 minutes
  - cron: '0 * * * *'    # Every hour
  - cron: '0 */4 * * *'  # Every 4 hours
```

### Customize Folder Mapping

Modify the case statements in both workflows to match your folder structure and Jira statuses.

### Add Custom Fields

Include additional Jira fields in task files by modifying the reconciliation script's task creation section.

## Best Practices

1. **Always pull before starting work:**
   ```bash
   git pull  # Get any auto-imported tasks
   ```

2. **Use clear commit messages:**
   ```bash
   git commit -m "Move task 30 to review"  # Clear
   git commit -m "stuff"                   # Unclear
   ```

3. **Let reconciliation handle imports:**
   - Don't manually create tasks for Jira tickets
   - Wait for auto-import or trigger manually

4. **Monitor the Actions tab:**
   - Check for failed workflows
   - Review logs if sync seems broken

5. **Keep STATE.md accurate:**
   - Never edit manually unless fixing corruption
   - Let workflows maintain it

## Summary

This system ensures:
- ✅ Git is always the source of truth
- ✅ Stakeholders can create tickets in Jira
- ✅ Automatic ID assignment and conflict resolution
- ✅ No manual sync needed
- ✅ Full audit trail in Git history
- ✅ Works with existing workflow

The key is: **Make changes anywhere, Git decides the truth.**