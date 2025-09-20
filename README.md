# 5-Day Docs Template

A simple, folder-based documentation and task management system for software projects.

## Quick Start

```bash
# 1. Clone or copy this template to your project
cp -r /path/to/5daydocs/* /your/project/

# 2. Run setup script
chmod +x setup.sh
./setup.sh

# 3. Review the documentation
cat DOCUMENTATION.md
```

## What's Included

- **Task Management**: Folder-based workflow (backlog → next → active → review → archive)
- **Feature Documentation**: Status-tagged capabilities (LIVE/TESTING/BACKLOG)
- **Bug Tracking**: Simple bug report system with severity levels
- **Automation Scripts**: Bash scripts for common operations
- **State Tracking**: Automatic ID management for tasks and bugs

## Structure Overview

```
/
├── DOCUMENTATION.md     # Complete workflow guide
├── README.md           # This file
├── setup.sh            # Initial setup script
├── docs/               # Documentation
│   ├── features/       # Feature specifications
│   └── guides/         # Technical guides
├── scripts/            # Automation scripts
└── work/              # Work items
    ├── scripts/       # Work automation scripts
    ├── tasks/         # Task pipeline
    ├── bugs/          # Bug reports
    ├── designs/       # UI mockups
    ├── examples/      # Code samples
    └── data/          # Test data
```

## Quick Commands

```bash
# Create a new task (automated)
./work/scripts/create-task.sh "Task description"

# Check what's being worked on
ls work/tasks/active/
```

See `DOCUMENTATION.md` for complete workflow guide.

## Philosophy

- **Simple**: No databases, no apps - just folders and markdown files
- **Portable**: Works with any project, any language, any team size
- **Transparent**: Everything is plain text and version controlled
- **Flexible**: Adapt the workflow to your needs

## Learn More

See `DOCUMENTATION.md` for the complete guide including:
- Creating and managing tasks
- Feature documentation
- Bug reporting workflow
- Sprint planning
- Automation scripts
- Edge cases and FAQs

---
*Simple, folder-based task management with clear feature documentation*
