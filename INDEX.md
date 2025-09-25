# 5DayDocs

## Overview

This repository contains the 5DayDocs project, a simple, folder-based project management tool. It is designed to be lightweight and easy to use, with a minimal set of features to keep project management straightforward.

## Asset Categories

The repository is organized into the following categories:

*   **[docs](./docs/)**: All project documentation, including feature specifications, technical guides, and operational procedures.
*   **[work](./work/)**: The main working directory, containing all active project management files, task tracking, and operational resources.

## Usage

Use this repository to manage your projects using a simple, folder-based workflow. Refer to the documentation in the `docs` directory for detailed information on how to use the system.

# 5DayDocs

**The simplest, easiest to use, smallest possible folder-based project management tool.**

## Core Philosophy

- **Simple**: Just folders and markdown files. No databases, no apps.
- **Small**: Minimal structure, maximum clarity.
- **Easy**: Learn the entire system in 5 minutes.

## The Entire System

```
work/tasks/backlog/   → work/tasks/next/   → work/tasks/working/   → work/tasks/review/   → work/tasks/live/
```

Tasks move left to right. One task in working/ at a time. That's it.

## Quick Start

```bash
# Setup (one time)
chmod +x work/scripts/setup.sh
./work/scripts/setup.sh

# Daily workflow
ls work/tasks/next/                                    # What's queued?
mv work/tasks/next/1-task.md work/tasks/working/      # Start work
mv work/tasks/working/1-task.md work/tasks/review/    # Submit for review
```

## Files That Matter

- `DOCUMENTATION.md` - How to use 5DayDocs
- `work/STATE.md` - Current highest task ID
- `work/tasks/` - Your task pipeline
- `docs/features/` - Feature documentation
- `templates/` - Templates for GitHub/Jira/Bitbucket workflows (see templates/INDEX.md)

## No Complexity

We resist:
- Extra tools and dependencies
- Complicated workflows
- Feature creep
- Over-engineering

This is a folder structure, not a framework.