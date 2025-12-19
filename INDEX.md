# 5DayDocs

**The simplest, easiest to use, smallest possible folder-based project management tool.**

## Dev Cycle on this 
This is a tool developers can use to manage projects in simple text files

* We write source code in src/
* We run update.sh to test locally
* We dogfood the tool by running update.sh to update our local files
* The files in ./ and docs/ are for helping us build the tool
* The files in ./ and docs/ are not the project we distribute, but how the sausage is made
* When installed by a developer, it serves the same role it does in this repository

## Core Philosophy

- **Simple**: Just folders and markdown files. No databases, no apps.
- **Small**: Minimal structure, maximum clarity.
- **Easy**: Learn the entire system in 5 minutes.

## The Entire System

```
docs/tasks/backlog/   → docs/tasks/next/   → docs/tasks/working/   → docs/tasks/review/   → docs/tasks/live/
```

Tasks move left to right. One task in working/ at a time. That's it.

## Quick Start

```bash
# Setup (one time)
chmod +x setup.sh
./setup.sh

# Daily workflow
ls docs/tasks/next/                                    # What's queued?
mv docs/tasks/next/1-task.md docs/tasks/working/      # Start work
mv docs/tasks/working/1-task.md docs/tasks/review/    # Submit for review
```

## Files That Matter

- `DOCUMENTATION.md` - How to use 5DayDocs
- `docs/STATE.md` - Current highest task ID (central location)
- `docs/tasks/` - Your task pipeline
- `docs/features/` - Feature documentation
- `templates/` - Templates for GitHub/Jira/Bitbucket workflows (see templates/INDEX.md)

## No Complexity

We resist:
- Extra tools and dependencies
- Complicated workflows
- Feature creep
- Over-engineering

This is a folder structure, not a framework.