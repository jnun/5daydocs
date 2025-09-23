# 5DayDocs
See `DOCUMENTATION.md` for complete workflow guide.

**INSTALL THIS IN YOUR PROJECT TO USE IT BY RUNNING work/scripts/setup.sh**

## Philosophy

- **Simple**: No databases, no apps - just folders and markdown files
- **Portable**: Works with any project, any language, any team size
- **Transparent**: Everything is plain text and version controlled
- **Flexible**: Adapt the workflow to your needs

**Core Rule for New Features**: Before adding ANY new feature, ask:
"Does this simplify the use of the app or create more difficulty?"
If it doesn't clearly simplify, don't add it.

A simple, folder-based documentation and task management system for software projects.

## Quick Start

```bash
# 1. Clone this installer in a folder that's not in your working project folder
git clone https://github.com/yourusername/5daydocs.git
cd /path/to/5daydocs

# 2. Run setup (it will ask for YOUR project path)
chmod +x work/scripts/setup.sh
./work/scripts/setup.sh

# 3. Go to YOUR project and start working
cd /path/to/your-project
./work/scripts/create-task.sh "Your first task"
```

## What Gets Installed

The setup script creates this structure in YOUR project:

```
/
├── DOCUMENTATION.md     # Complete workflow guide
├── README.md           # This file
├── docs/               # Documentation
│   ├── features/       # Feature specifications
│   └── guides/         # Technical guides
└── work/              # Work items
    ├── scripts/       # 5DayDocs automation scripts
    │   ├── setup.sh       # Initial setup script
    │   ├── create-task.sh # Task creation helper
    │   └── check-alignment.sh # Feature status checker
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
ls work/tasks/working/

# Check feature/task alignment
./work/scripts/check-alignment.sh
```

## Learn More

See `DOCUMENTATION.md` for the complete guide including:
- Creating and managing tasks
- Feature documentation
- Bug reporting workflow
- Sprint planning
- Automation scripts
- Edge cases and FAQs

## AI Assistant Instructions

**IMPORTANT: If you are an AI assistant working with this codebase, follow these steps BEFORE making any changes:**

1. **Read ALL CAPITAL letter files in root directory** - These contain critical project context (README.md, INDEX.md, CLAUDE.md, DOCUMENTATION.md, etc.)
2. **Follow links mentioned in README.md and INDEX.md (if they exist)** if they are relevant to the task - These point to relevant project documentation and existing implementations
3. **Search for existing code before creating new files** - Use search/grep to find similar functionality that might already exist
4. **Reuse and update existing tools** - Never create duplicate functionality; always prefer updating existing code
5. **Understand project conventions** - Match the existing code style, file naming patterns, and directory structure
6. **Check project configuration** - Review package.json, Makefile, or equivalent files for dependencies and scripts

**Remember:** Research first, code second. Understanding the existing structure prevents duplicate work and maintains consistency.

---
*Simple, folder-based task management with clear feature documentation*
