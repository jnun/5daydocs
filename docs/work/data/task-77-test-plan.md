# Test Plan: GitHub Actions Workflow - Task 77

**Date**: 2025-10-19
**Task**: 77-improve-github-actions-workflow-resilience.md
**Tester**: Human verification required

## Test Objectives
Verify that the improved GitHub Actions workflow correctly:
1. Creates GitHub issues from new tasks
2. Updates issue labels when tasks move between folders
3. Updates issue content when task files change
4. Handles INDEX.md files without errors

## Test Scenario 1: Task Creation in Backlog

### Steps
1. ✅ Create task file: `docs/work/tasks/backlog/77-improve-github-actions-workflow-resilience.md`
2. ✅ Update `docs/STATE.md` with new task ID
3. ⏳ Commit changes to main branch
4. ⏳ Navigate to GitHub Actions tab
5. ⏳ Find "Sync Tasks to GitHub Issues" workflow run
6. ⏳ Verify workflow completes successfully

### Expected Results
- Workflow should process the file
- Workflow should skip INDEX.md without errors
- Log should show: "Processing: docs/work/tasks/backlog/77-improve-github-actions-workflow-resilience.md"
- Log should show: "✓ Created issue #N" (where N is the issue number)
- No errors related to INDEX.md processing

## Test Scenario 2: Task Movement to Sprint

### Steps
1. ⏳ Move task: `git mv docs/work/tasks/backlog/77-*.md docs/work/tasks/next/`
2. ⏳ Commit changes to main branch
3. ⏳ Navigate to GitHub Actions tab
4. ⏳ Find new "Sync Tasks to GitHub Issues" workflow run
5. ⏳ Verify workflow completes successfully
6. ⏳ Navigate to GitHub Issues tab

### Expected Results
- Workflow should detect the moved file
- Log should show: "Updating existing issue #N..."
- Log should show: "✓ Updated to status: Sprint Queue"
- Issue labels should change from "backlog" to "sprint"
- Issue should remain open
- Issue body should contain: `<!-- 5daydocs-task-id: 77 -->`

## Test Scenario 3: GitHub Issue Verification

### Steps
1. ⏳ Open GitHub Issues tab in repository
2. ⏳ Find issue with title: "Task 77: Improve GitHub Actions Workflow Resilience"
3. ⏳ Verify issue details

### Expected Results
- Issue exists with correct title
- Issue has label: "5day-task"
- Issue has label: "sprint" (after movement)
- Issue body contains:
  - Status: Sprint Queue
  - Feature: github-issue-sync
  - Problem section with description
  - Success Criteria section with checkboxes
  - HTML comment: `<!-- 5daydocs-task-id: 77 -->`

## Success Metrics
- ✅ All workflow runs complete without errors
- ⏳ Issue created in GitHub with correct metadata
- ⏳ Issue labels updated correctly when task moves
- ⏳ Workflow logs show structured output with ✓ marks
- ⏳ No INDEX.md processing errors

## Notes
- Workflow uses HTML comment metadata for reliable issue lookup
- This test validates both idempotency and error handling improvements
- Future runs should update the same issue, not create duplicates
