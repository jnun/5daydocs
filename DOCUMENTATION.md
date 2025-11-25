# Documentation and Workflow Guide

> **Quick Reference**: [Commands](#quick-reference-commands) | [File Formats](#file-formats) | [Workflows](#common-workflows)

## Philosophy

Simple folder-based task management. Plain markdown files, no databases, no complexity.

## Initial Setup

```bash
chmod +x setup.sh && ./setup.sh
```

Creates directory structure, initializes STATE.md, makes scripts executable.

## Using 5day.sh

```bash
./5day.sh help              # Show commands
./5day.sh newtask "desc"    # Create task (auto-increments ID)
./5day.sh newfeature name   # Create feature doc
./5day.sh status            # Check current work
./5day.sh checkfeatures     # Verify alignment
```


## Naming Conventions

| File Type | Format | Example |
|-----------|--------|---------|
| Task/Bug files | `ID-description.md` | `[N]-fix-bug-name.md` |
| Feature files | `feature-name.md` | `feature-name.md` |
| Scripts | `script-name.sh` | `script-name.sh` |
| Guides | `topic-name.md` | `topic-name.md` |

**Rules:**
- Use kebab-case (lowercase, hyphens)
- Task/Bug IDs are sequential integers (0, 1, 2, 3...)
- Status values: BACKLOG, NEXT, WORKING, REVIEW, LIVE
- Bug severity: CRITICAL, HIGH, MEDIUM, LOW

**Why 5DAY_ prefix?** Variables like `5DAY_TASK_ID` prevent AI from confusing tracking IDs with your project code.

## Directory Structure

```
docs/
├── STATE.md           # Task/bug ID tracking
├── features/          # Capability specifications
├── tasks/             # Work items moving through folders
│   ├── backlog/       # Planned work
│   ├── next/          # Sprint queue
│   ├── working/       # In progress
│   ├── review/        # Awaiting approval
│   └── live/          # Completed
├── bugs/              # Bug reports
│   └── archived/      # Processed bugs
├── guides/            # Technical documentation
├── scripts/           # Automation tools
└── [project-specific folders]
```

## How It Works

## File Formats

### Feature Document
```markdown
# Feature: [Feature Name]

## [Capability Name]
**Status**: LIVE
Description of what this capability does

## [Another Capability]  
**Status**: BACKLOG
Description of planned capability
```

**Status values:** BACKLOG → NEXT → WORKING → REVIEW → LIVE

### Task Document
```markdown
# Task [N]: [Brief description of task]

**Feature**: /docs/features/RELATED-FEATURE.md (or "multiple" or "none")
**Created**: YYYY-MM-DD  <!-- Replace with actual date -->

## Problem
Description of what needs to be fixed or built

## Success Criteria
- [ ] First criterion
- [ ] Second criterion
- [ ] Third criterion

## Related Tasks (optional - only if dependencies exist)
- Complete task [X] first (reason why)
- See also task [Y] (related work)
```

### Bug Report
```markdown
# Bug: [Brief description]

**Reported By**: [Name]
**Date**: YYYY-MM-DD  <!-- Replace with actual date -->
**Severity**: CRITICAL | HIGH | MEDIUM | LOW

## Description
What is happening that shouldn't be

## Expected Behavior
What should happen instead

## Steps to Reproduce
1. First step
2. Second step
3. Third step

## Environment
Browser/OS/Device information
```

**Severity levels:** CRITICAL (system down) | HIGH (major feature broken) | MEDIUM (has workaround) | LOW (minor/cosmetic)

## Common Workflows

### Creating a Task

**Automated (recommended):**
```bash
./5day.sh newtask "Task description"
```
Auto-increments ID from STATE.md, creates file in backlog/, updates STATE.md.

**Manual:**
1. Check `docs/STATE.md` for current `5DAY_TASK_ID`
2. Create `docs/tasks/backlog/[ID+1]-description.md`
3. Update `5DAY_TASK_ID` in STATE.md
4. Commit both files together

### Moving Tasks Through Pipeline

```bash
git mv docs/tasks/backlog/ID-name.md docs/tasks/next/      # Queue for sprint
git mv docs/tasks/next/ID-name.md docs/tasks/working/      # Start work
git mv docs/tasks/working/ID-name.md docs/tasks/review/    # Submit for review
git mv docs/tasks/review/ID-name.md docs/tasks/live/       # Complete

# If blocked:
git mv docs/tasks/working/ID-name.md docs/tasks/next/      # Move back to queue
```

### Creating a Feature

```bash
./5day.sh newfeature feature-name
```
Creates `docs/features/feature-name.md` with template. Mark capabilities as BACKLOG initially, update to LIVE when completed.

### Converting Bugs to Tasks

1. Create task: `./5day.sh newtask "Fix [bug description]"`
2. Reference bug in task: `**Bug Report**: /docs/bugs/ID-description.md`
3. Archive bug: `mv docs/bugs/ID-description.md docs/bugs/archived/`

### Checking Alignment

```bash
./5day.sh checkfeatures
```
Verifies feature statuses match task locations. Run after moving tasks to review/live.

## Key Concepts

**Features = Permanent** - What capabilities exist in the system
**Tasks = Temporary** - Work being done to build/improve capabilities

A feature can be LIVE while having backlog tasks for enhancements. Update feature status to LIVE when first capability works, not when all possible work is done.

## STATE.md Format

```markdown
# docs/STATE.md

**Last Updated**: YYYY-MM-DD
**5DAY_VERSION**: X.X.X
**5DAY_TASK_ID**: [N]
**5DAY_BUG_ID**: [N]
**SYNC_ALL_TASKS**: true | false
```

**Critical:** STATE.md is the source of truth for IDs. Next task = current `5DAY_TASK_ID` + 1. Don't count files.

## Automation Scripts

Scripts in `docs/scripts/` automate common workflows. Run `./5day.sh help` for available commands.

**Creating custom scripts:**
```bash
#!/bin/bash
# docs/scripts/script-name.sh
set -e
# Your automation here
```

Make executable: `chmod +x docs/scripts/script-name.sh`

## Optional Integrations

**GitHub Issues/Projects:** Sync tasks to visual boards for stakeholders. See `.github/workflows/` for setup.

**Jira:** Two-way sync with Git as source of truth. See workflow templates in repository.

## Quick Reference Commands

```bash
# Creating
./5day.sh newtask "description"          # Create task
./5day.sh newfeature name                 # Create feature
./5day.sh status                          # Check current work
./5day.sh checkfeatures                   # Verify alignment

# Moving tasks
git mv docs/tasks/backlog/ID-name.md docs/tasks/next/      # Queue
git mv docs/tasks/next/ID-name.md docs/tasks/working/      # Start
git mv docs/tasks/working/ID-name.md docs/tasks/review/    # Submit
git mv docs/tasks/review/ID-name.md docs/tasks/live/       # Complete

# Viewing
ls docs/tasks/working/    # Current work
ls docs/tasks/next/       # Sprint queue
ls docs/tasks/backlog/    # Planned work
ls docs/features/         # All capabilities
```

## Common Issues

**Task doesn't relate to a feature?** Use `**Feature**: none` for infrastructure/tooling tasks.

**Task relates to multiple features?** Use `**Feature**: multiple` and list them in Problem section.

**Scripts not executable?** Run `chmod +x docs/scripts/*.sh` or `./setup.sh`

**Missing directories?** Run `./setup.sh`

**Task ID conflicts?** Always check `docs/STATE.md` first - it's the source of truth.

---

*Simple folder-based task management. Plain markdown files, no complexity.*
