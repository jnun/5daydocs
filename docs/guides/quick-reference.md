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
cat work/STATE.md

# Create new task (manual)
echo "# Task 1: Task Title" > work/tasks/backlog/1-task-name.md

# Move tasks through pipeline
mv work/tasks/backlog/1-task.md work/tasks/next/
mv work/tasks/next/1-task.md work/tasks/active/
mv work/tasks/active/1-task.md work/tasks/review/
mv work/tasks/review/1-task.md work/tasks/archive/
```

### Bug Management
```bash
# Check current highest bug ID
cat work/bugs/BUG_STATE.md

# Create bug report
echo "# Bug: Description" > work/bugs/001-bug-name.md

# Archive processed bug
mv work/bugs/001-bug.md work/bugs/archived/
```

### Status Checks
```bash
# What's being worked on
ls work/tasks/active/

# Sprint queue
ls work/tasks/next/

# Backlog
ls work/tasks/backlog/

# Completed
ls work/tasks/archive/
```

## File Naming Conventions

### Tasks
- Format: `ID-description.md`
- Example: `1-fix-login-bug.md`
- ID is numeric, increments from work/STATE.md
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
backlog → next → active → review → archive
           ↑        ↓
           ← blocked ←
```

## Feature Status Values

- **LIVE** - In production
- **TESTING** - Built, not released
- **BACKLOG** - Planned, not built

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
4. Add tasks to `work/tasks/backlog/`

### Fixing a Bug
1. Create bug report in `work/bugs/`
2. Create task referencing bug
3. Move bug to `work/bugs/archived/`
4. Work through task pipeline

### Sprint Planning
1. Review `work/tasks/backlog/`
2. Move selected tasks to `work/tasks/next/`
3. Limit `work/tasks/active/` to 1-3 tasks
4. Complete before taking more from `next/`

## Tips

- Always check STATE.md before creating tasks
- Always update STATE.md after creating tasks
- Keep active tasks minimal (1-3 max)
- Document blockers when moving backwards
- Review folder is mandatory (no skipping)
- Archive completed work for history

---
*For complete documentation, see DOCUMENTATION.md*