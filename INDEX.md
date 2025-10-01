# 5DayDocs

**The simplest, easiest to use, smallest possible folder-based project management tool.**

## Core Philosophy

- **Simple**: Just folders and markdown files. No databases, no apps.
- **Small**: Minimal structure, maximum clarity.
- **Easy**: Learn the entire system in 5 minutes.

## The Entire System

```
docs/work/tasks/backlog/   → docs/work/tasks/next/   → docs/work/tasks/working/   → docs/work/tasks/review/   → docs/work/tasks/live/
```

Tasks move left to right. One task in working/ at a time. That's it.

## Quick Start

```bash
# Setup (one time)
chmod +x setup.sh
./setup.sh

# Daily workflow
ls docs/work/tasks/next/                                    # What's queued?
mv docs/work/tasks/next/1-task.md docs/work/tasks/working/      # Start work
mv docs/work/tasks/working/1-task.md docs/work/tasks/review/    # Submit for review
```

## Files That Matter

- `DOCUMENTATION.md` - How to use 5DayDocs
- `docs/STATE.md` - Current highest task ID (central location)
- `docs/work/tasks/` - Your task pipeline
- `docs/features/` - Feature documentation
- `templates/` - Templates for GitHub/Jira/Bitbucket workflows (see templates/INDEX.md)

## No Complexity

We resist:
- Extra tools and dependencies
- Complicated workflows
- Feature creep
- Over-engineering

This is a folder structure, not a framework.