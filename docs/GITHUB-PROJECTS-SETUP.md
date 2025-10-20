# GitHub Projects Kanban Board Setup

This guide shows you how to set up the automated GitHub Projects kanban board for 5DayDocs task management.

## What This Does

Automatically syncs your task files to a visual kanban board that non-technical partners can view:

- **Move a file between folders** → Issue updates → Kanban board updates
- **No manual updating** required
- **Share with partners** via GitHub Projects URL

## Status Columns

The board has 5 columns matching your workflow:

1. **Backlog** - Tasks defined but not yet scheduled
2. **Next** - Tasks assigned to current sprint
3. **Working** - Tasks actively being worked on
4. **Review** - Tasks in testing and review
5. **Live** - Completed and approved tasks

## One-Time Setup

### Step 1: Create the Project

Run this command in your terminal (replace `YourProject` with your actual project name):

```bash
gh project create --owner @me --title "YourProject Task Board"
```

For example, if your repo is called "myapp", use:
```bash
gh project create --owner @me --title "myapp Task Board"
```

This will output something like:
```
https://github.com/users/YourUsername/projects/1
```

The number at the end (`1` in this example) is your **PROJECT_NUMBER**.

### Step 2: Find Your Project Number (if needed)

If you need to find it again:

```bash
gh project list --owner @me
```

Look for your project name (e.g., "myapp Task Board") and note the number.

### Step 3: Configure GitHub Repository

1. Go to your repository on GitHub
2. Click **Settings** (top menu)
3. Click **Secrets and variables** → **Actions** (left sidebar)
4. Click the **Variables** tab
5. Click **New repository variable**
6. Enter:
   - **Name**: `PROJECT_NUMBER`
   - **Value**: Your project number (e.g., `1`)
7. Click **Add variable**

### Step 4: Set Up Status Field in Project

1. Go to your project: `https://github.com/users/YourUsername/projects/<PROJECT_NUMBER>`
2. Click the **⋯** (three dots) in the top right
3. Click **Settings**
4. In the left sidebar, click **Custom fields**
5. Find the **Status** field (should already exist)
6. Click **Edit** on the Status field
7. Add these 5 options (if not already present):
   - Backlog
   - Next
   - Working
   - Review
   - Live
8. Click **Save**

### Step 5: Test the Setup

1. Move a task file between folders (e.g., from `backlog` to `next`)
2. Commit and push:
   ```bash
   git add docs/tasks/
   git commit -m "Test: Move task to next folder"
   git push
   ```
3. Go to **Actions** tab in GitHub and watch the workflow run
4. Check your project board - the task should appear in the correct column

## Verification

✅ **Success looks like:**
- Workflow runs without errors
- Issues appear in your project
- Issues are in the correct status column
- Moving files between folders updates the board

## Troubleshooting

### "Could not find project item"
- The item was just added and needs time to sync (usually ~1 second)
- This is a harmless warning on first run

### "Status field may need to be created"
- Complete Step 4 above to configure the Status field
- Ensure the field options match exactly: Backlog, Next, Working, Review, Live

### Workflow doesn't run
- Check that `PROJECT_NUMBER` is set in repository variables
- Verify the workflow has permissions (Settings → Actions → General → Workflow permissions)
- Ensure changes are pushed to the `main` branch

### Project not found
- Verify the PROJECT_NUMBER is correct
- Ensure the project is owned by you (`@me`) or your organization

## Sharing the Board

Once set up, share your board with partners:

1. Go to your project URL
2. Click **⋯** → **Settings**
3. Under **Visibility**, choose:
   - **Private** - Only collaborators can see
   - **Public** - Anyone with the link can view (read-only for non-collaborators)
4. Share the project URL with your partners

## Automation Summary

The workflow automatically:
1. Creates/updates GitHub Issues from task files
2. Adds issues to your project board
3. Sets the status column based on folder location
4. Updates labels to match status
5. Closes issues when tasks move to "live"

**You just move files. Everything else is automatic.**
