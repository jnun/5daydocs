# Quick Reference Guide

## Essential Commands

### Setup
```bash
chmod +x setup.sh
./setup.sh
```

### Task Management
```bash
# Check current highest task ID
cat docs/STATE.md

# Create new task (manual)
echo "# Task 1: Task Title" > docs/tasks/backlog/1-task-name.md

# Move tasks through pipeline
mv docs/tasks/backlog/1-task.md docs/tasks/next/
mv docs/tasks/next/1-task.md docs/tasks/working/
mv docs/tasks/working/1-task.md docs/tasks/review/
mv docs/tasks/review/1-task.md docs/tasks/live/
```

### Bug Management
```bash
# Check current highest bug ID
cat docs/bugs/BUG_STATE.md

# Create bug report
echo "# Bug: Description" > docs/bugs/001-bug-name.md

# Archive processed bug
mv docs/bugs/001-bug.md docs/bugs/archived/
```

### Status Checks
```bash
# What's being worked on
ls docs/tasks/working/

# Sprint queue
ls docs/tasks/next/

# Backlog
ls docs/tasks/backlog/

# Completed
ls docs/tasks/live/
```

## File Naming Conventions

### Tasks
- Format: `ID-description.md`
- Example: `1-fix-login-bug.md`
- ID is numeric, increments from docs/STATE.md
- Description is kebab-case

### Bugs
- Format: `ID-description.md`
- Example: `001-login-not-working.md`
- ID is 3-digit padded (001, 002, ... 099, 100)
- Description is kebab-case

### Features
- Format: `feature-name.md`
- Example: `authentication.md`
- Name is kebab-case

## Task Lifecycle

```
backlog → next → working → review → live
           ↑         ↓
           ← blocked  ←
```

## Feature Status Values

- **BACKLOG** - Planned, not started
- **NEXT** - Queued for this sprint
- **WORKING** - Being worked on now
- **REVIEW** - Built, awaiting approval
- **LIVE** - In production or approved for deployment

## Bug Severity Levels

- **CRITICAL** - System down (immediate)
- **HIGH** - Major broken (this sprint)
- **MEDIUM** - Has workaround (next sprint)
- **LOW** - Minor/cosmetic (when convenient)

## Git Integration (Optional)

```bash
# Branch per task
git checkout -b task/1-fix-login

# Commit with task reference
git commit -m "Task #1: Fix login bug"

# PR title format
"Task #1: Brief description"
```

## Common Patterns

### Starting a New Feature
1. Create `/docs/features/feature-name.md`
2. List capabilities as BACKLOG
3. Create tasks for each capability
4. Add tasks to `docs/tasks/backlog/`

### Fixing a Bug
1. Create bug report in `docs/bugs/`
2. Create task referencing bug
3. Move bug to `docs/bugs/archived/`
4. Work through task pipeline

### Sprint Planning
1. Review `docs/tasks/backlog/`
2. Move selected tasks to `docs/tasks/next/`
3. Limit `docs/tasks/working/` to 1-3 tasks
4. Complete before taking more from `next/`

## Tips

- Always check STATE.md before creating tasks
- Always update STATE.md after creating tasks
- Keep working tasks minimal (1-3 max)
- Document blockers when moving backwards
- Review folder is mandatory (no skipping)
- Move completed work to live/ for history

---
*For complete documentation, see DOCUMENTATION.md*