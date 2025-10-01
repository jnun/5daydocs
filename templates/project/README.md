# 5daydocs

A folder-based documentation and task management system using plain text files and directory structure for project workflow management.

## Quick Start

### As a Submodule (Recommended)

Add 5daydocs to your existing project:

```bash
# Add as submodule
git submodule add https://github.com/yourusername/5daydocs.git 5daydocs

# Initialize submodule
git submodule update --init --recursive

# Run setup in your project root
./5daydocs/setup.sh

# Use 5daydocs commands
./5daydocs/5day.sh status
```

### Standalone Installation

Clone and setup directly:

```bash
git clone https://github.com/yourusername/5daydocs.git
cd 5daydocs
./setup.sh
```

## Core Commands

```bash
# Task management
./5daydocs/5day.sh new "Task description"    # Create new task
./5daydocs/5day.sh status                    # View task status
./5daydocs/5day.sh working                   # List active tasks
./5daydocs/5day.sh next                      # List queued tasks

# Move tasks through workflow
git mv work/tasks/backlog/ID-name.md work/tasks/next/    # Queue
git mv work/tasks/next/ID-name.md work/tasks/working/    # Start
git mv work/tasks/working/ID-name.md work/tasks/review/  # Review
git mv work/tasks/review/ID-name.md work/tasks/live/     # Complete
```

## Project Structure

When installed, 5daydocs creates this structure in your project:

```
your-project/
├── 5daydocs/                    # The submodule (this repository)
│   ├── 5day.sh                  # Command interface
│   ├── setup.sh                 # Initialization script
│   ├── templates/               # Workflow templates
│   ├── CLAUDE.md               # AI pair programming guide
│   └── README.md               # This file
├── work/                        # Your project work (created by setup.sh)
│   ├── STATE.md                # ID tracking
│   ├── tasks/                  # Task pipeline
│   │   ├── backlog/            # Planned tasks
│   │   ├── next/               # Sprint queue
│   │   ├── working/            # Active work
│   │   ├── review/             # Awaiting review
│   │   └── live/               # Completed
│   ├── bugs/                   # Bug reports
│   └── scripts/                # Automation
└── docs/                        # Your documentation (created by setup.sh)
    ├── features/               # Feature specs
    └── guides/                 # Technical docs
```

## Philosophy

5daydocs is intentionally simple:
- Plain markdown files
- Standard folder structure
- Git for version control
- No databases or complex apps
- Everything is transparent

## Key Concepts

### Task Pipeline
Tasks flow through folders representing their state:
1. **backlog/** - Planned but not started
2. **next/** - Queued for this sprint
3. **working/** - Currently being worked on
4. **review/** - Built and awaiting approval
5. **live/** - Completed or in production

### State Management
The `work/STATE.md` file tracks the highest ID numbers for tasks and bugs. Always check and update this file when creating new items.

### Feature Documentation
Features are documented in `docs/features/` with status tags:
- **LIVE** - In production
- **TESTING** - Built but not released
- **WORKING** - Currently being developed
- **BACKLOG** - Planned but not started

## License

MIT License - See LICENSE file for details