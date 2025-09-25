# Documentation and Workflow Guide

> **Quick Reference**: See [Common Workflows](#common-workflows) to get started quickly.

## Philosophy

**Keep what works. Change only what's broken.**

5DayDocs is intentionally simple:
- Plain folders and markdown files
- No databases, no apps, no complexity
- Add only tools that demonstrably improve workflow
- Resist feature creep

If it works, don't fix it. If it's clear, don't clarify it.

## Initial Setup

**First time setup after cloning/importing:**
```bash
# Make setup script executable and run it
chmod +x setup.sh
./setup.sh
```

**Note:** The setup script will automatically copy and make executable the `5day.sh` command interface to your project.

This will:
- Create all required directories
- Set up state tracking file (STATE.md)
- Make all scripts in scripts/ executable
- Create .gitignore if needed
- Add sample content if directories are empty

## Using the 5day.sh Script

The `5day.sh` script is a convenient command interface for running common 5DayDocs tasks. It's automatically copied and made executable by the setup script.

**Usage:**
```bash
# View available commands
./5day.sh help

# Create a new task
./5day.sh newtask "Task description"

# Create a new feature document
./5day.sh newfeature feature-name

# Check task status
./5day.sh status

# Check feature alignment
./5day.sh checkfeatures

# Optional: Add an alias for quicker access
# Add this to your ~/.bashrc or ~/.zshrc:
# alias 5day='./5day.sh'
```

**What it does:**
- Provides quick access to daily task management operations
- Simplifies common workflows like creating tasks, moving them through stages, and checking status
- Run `./5day.sh` without arguments to see available commands

**Manual setup (if setup.sh is not available):**
```bash
# Example commands - replace placeholders with actual values
# Create directory structure
mkdir -p work/tasks/{backlog,next,working,review,live}
mkdir -p work/{bugs/archived,designs,examples,data}
mkdir -p docs/{features,guides}
mkdir -p work/scripts

# Create state file ($(date +%Y-%m-%d) will generate current date)
echo "# work/STATE.md\n\n**Last Updated**: $(date +%Y-%m-%d)\n**5DAY_TASK_ID**: 0\n**5DAY_BUG_ID**: 0" > work/STATE.md

# Make scripts executable
chmod +x work/scripts/*.sh
```

## Document Conventions

- **UPPERCASE-WORDS** = placeholders to replace with actual values
- **kebab-case** = lowercase words separated by hyphens (e.g., fix-login-bug)
- **OPTION1 | OPTION2** = choose one of the options
- When you see "ID-DESCRIPTION.md" replace ID with a number and DESCRIPTION with kebab-case text
- All paths use forward slashes (/) even on Windows
- Commands shown are for bash/unix shells

### Why 5DAY_ Prefixes

All 5DayDocs system variables use `5DAY_` prefix (like `5DAY_TASK_ID`) to prevent AI confusion with your actual project code. This ensures AI assistants never mix up our tracking with your variables.

## Naming Conventions for 5DayDocs

### File Naming
- **Task files**: `ID-description.md` (kebab-case description)
- **Feature files**: `feature-name.md` (kebab-case)
- **Bug files**: `ID-description.md` (three-digit ID, kebab-case description)
- **Scripts**: `script-name.sh` (kebab-case with .sh extension)
- **Guides**: `topic-name.md` (kebab-case)

### Code Style Guidelines (for scripts and examples)
- **Variables**: `snake_case` for bash scripts, `camelCase` for JavaScript/TypeScript
- **Functions**: `snake_case` for bash, `camelCase` for JS/TS
- **Constants**: `SCREAMING_SNAKE_CASE` for all languages
- **Classes/Components**: `PascalCase` (when applicable)
- **Environment variables**: `SCREAMING_SNAKE_CASE`

### Markdown Content
- **Section headers**: Title Case for main sections, Sentence case for subsections
- **Task titles**: Human readable title (e.g., "Fix Login Bug")
- **Feature names**: Clear descriptive names (e.g., "User Authentication")
- **Status values**: ALL CAPS (LIVE, TESTING, WORKING, REVIEW, BACKLOG)
- **Severity levels**: ALL CAPS (CRITICAL, HIGH, MEDIUM, LOW)

## Project Structure

```
/
├── DOCUMENTATION.md             # This guide
├── README.md                    # Quick start and setup
├── docs/                        # Documentation (source of truth)
│   ├── features/                # Feature specifications (one file per feature)
│   │   └── FEATURE-NAME.md      # Status-tagged capabilities (LIVE/TESTING/BACKLOG)
│   ├── guides/                  # Technical guides, setup instructions, architecture docs
│   │   └── TOPIC-NAME.md        # Markdown format, technical documentation
│   └── data/                    # Data layer documentation (schemas, migrations, architecture)
└── work/
    ├── STATE.md                 # Current highest task ID
    ├── scripts/                 # Work automation scripts
    │   ├── setup.sh             # Initial setup script
    │   ├── create-task.sh       # Task creation helper
    │   └── check-alignment.sh # Feature status checker
    ├── tasks/                   # Task management
    │   ├── backlog/             # Not prioritized
    │   ├── next/                # Sprint queue
    │   ├── working/             # Being worked on now
    │   ├── review/              # Awaiting approval
    │   └── live/                # Completed
    ├── designs/                 # UI mockups and wireframes (any format: PNG, SVG, HTML)
    ├── examples/                # Code examples and snippets (markdown or code files)
    ├── data/                    # Database design, sample data, and storage planning (see Database & Storage section)
    └── bugs/                    # Bug reports (see Bug Reports section below)
        └── archived/            # Processed bug reports
```

## How It Works

### Features (Source of Truth)

Each feature gets one file in `/docs/features/` describing how it works.

**Feature File Format (Template - replace placeholders)**:
```markdown
# Feature: FEATURE-NAME

## CAPABILITY-NAME
**Status**: STATUS-VALUE
Description of capability
```

Where:
- FEATURE-NAME = the feature being documented
- CAPABILITY-NAME = specific capability within the feature  
- STATUS-VALUE = one of: BACKLOG, NEXT, WORKING, REVIEW, or LIVE
- Description = explanation of how it works or will work

**Status Meanings**:
- **BACKLOG** = Planned, not started
- **NEXT** = Queued for this sprint
- **WORKING** = Being worked on now
- **REVIEW** = Built, awaiting approval
- **LIVE** = In production or approved for deployment

### Tasks (Work Items)

Each task is a file with a unique ID that moves between folders.

**Task File Format (Template - replace placeholders)**:
```markdown
# Task ID: BRIEF-DESCRIPTION

**Feature**: /docs/features/RELATED-FEATURE.md (or "multiple" or "none")
**Created**: YYYY-MM-DD  <!-- Replace with actual date -->

## Problem
Description of what needs to be fixed or built

## Success Criteria
- [ ] First criterion
- [ ] Second criterion
```

**Placeholder meanings:**
- ID = task number from work/STATE.md
- BRIEF-DESCRIPTION = short summary of the task
- RELATED-FEATURE = name of the feature file (without .md extension)
- YYYY-MM-DD = actual date in year-month-day format (e.g., 2024-03-15)

**Optional Section - Related Tasks**:
When a task has dependencies or should be done in a specific order with other tasks, add:
```markdown
## Related Tasks
- Complete task ID-X first (reason why)
- See also task ID-Y (related work)
- Do this before task ID-Z (which depends on this)
```

Only include this section when tasks have actual dependencies. Most tasks should be independent and can be worked in any order.

**Task Flow**:
1. Create in `work/tasks/backlog/` with next ID (check work/STATE.md)
2. Sprint planning: Move to `work/tasks/next/`
3. Start work: Move to `work/tasks/working/`
4. Complete work: Move to `work/tasks/review/`
5. After approval: Move to `work/tasks/live/`
6. If blocked: Move back to `work/tasks/next/`
7. Run `./work/scripts/check-alignment.sh` to check feature status
8. Update feature doc status when capabilities go LIVE

## Common Workflows

### Adding a Feature
1. Create `/docs/features/FEATURE-NAME.md` using the Feature File Format shown above
2. Mark all capabilities as **Status**: BACKLOG initially
3. Create tasks for each capability to build
4. Add tasks to `work/tasks/backlog/` following task creation process

### Creating a New Task

**Using the 5day.sh script (recommended)**:
```bash
# After running setup.sh, use the 5day command:
./5day.sh newtask "Task description"
```

This automatically:
- Checks the current highest ID in `work/STATE.md`
- Creates the task file in `work/tasks/backlog/`
- Updates `work/STATE.md` with the new ID
- Commits both files together

**Where things are stored**:
- **Task IDs**: Tracked in `work/STATE.md` (contains `5DAY_TASK_ID`)
- **New tasks**: Created in `work/tasks/backlog/` folder
- **Task files**: Named as `ID-description.md` (e.g., `5-fix-login.md`)
- **Task format**: Each task file contains title, feature reference, creation date, problem description, and success criteria

**Manual approach** (if you prefer):
1. Check `work/STATE.md` for the current highest task ID
2. Create a new file in `work/tasks/backlog/` with ID+1
3. Update `work/STATE.md` with the new highest ID
4. Commit both files together


### Bug Reports

Bug reports are created in `work/bugs/` by users, clients, or stakeholders reporting issues.

**Bug File Naming**: ID-DESCRIPTION.md
- Use sequential integer IDs starting from 0 (just like tasks: 0, 1, 2, 3...)
- Keep DESCRIPTION brief and kebab-case
- Track highest bug ID in work/STATE.md as 5DAY_BUG_ID

**Bug Report Format (Template - replace ALL CAPS with actual values)**:
```markdown
# Bug: BRIEF-DESCRIPTION

**Reported By**: NAME
**Date**: YYYY-MM-DD  <!-- Use actual date -->
**Severity**: Choose one: CRITICAL | HIGH | MEDIUM | LOW

## Description
What is happening that shouldn't be

## Expected Behavior
What should happen instead

## Steps to Reproduce
1. First step
2. Second step

## Environment
- Browser/OS/Version info
```

**Severity Levels**:
- **CRITICAL**: System down, data loss, security breach (fix immediately)
- **HIGH**: Major feature broken, blocking users (fix this sprint)
- **MEDIUM**: Feature partially broken, has workaround (fix next sprint)
- **LOW**: Minor issue, cosmetic (fix when convenient)

### Converting Bugs to Tasks

When ready to fix a bug:
1. Review bug report in `work/bugs/`
2. Create a task following the normal task creation process
3. Reference the bug report in the task:
   ```markdown
   # Task ID: TITLE-DESCRIBING-FIX
   
   **Bug Report**: /work/bugs/ID-DESCRIPTION.md
   **Feature**: /docs/features/RELATED-FEATURE.md
   ```
4. Move bug report to `work/bugs/archived/` after task is created:
   ```bash
   mkdir -p work/bugs/archived
   mv work/bugs/ID-DESCRIPTION.md work/bugs/archived/
   ```
5. Proceed with task through normal workflow

### Task Review Process

When a task is complete:
1. Developer moves task to `work/tasks/review/`
2. Reviewer checks success criteria are met
3. If approved: Move to `work/tasks/live/`
4. If rejected: Move back to `work/tasks/next/` with notes
5. Update related feature status if applicable

## Data Architecture

Documentation about your data layer belongs in `docs/data/` - it's reference material for understanding your project's data setup.

The `docs/data/` directory should contain:
- What database/framework you're using
- Where schemas and migrations live in your codebase
- How to run migrations and modify the database
- Architecture decisions and trade-offs

Most frameworks have their own locations for seed data (Prisma has prisma/seed.ts, Rails has db/seeds.rb, etc). Use those instead of creating duplicate structures.

Keep documentation simple and clear. The goal is to help anyone working on tasks know where to look and what commands to run.

### Git Workflow (Optional)

For teams using git branches:
1. Branch naming: `task/ID-DESCRIPTION` (matches task filename)
2. One branch per task in `work/tasks/working/`
3. PR title: "Task ID: Brief Description"
4. PR description: Link to task file and success criteria
5. Merge to main after task moves to `live/`
6. Delete branch after merge

### Finding Things
- **What works now?** → Check features marked LIVE
- **What's being built?** → Check `work/tasks/working/` folder  
- **What's up next?** → Check `work/tasks/next/` folder
- **What needs prioritizing?** → Check `work/tasks/backlog/` folder

## Task Numbering

- Start at 0, increment by 1
- **ALWAYS check work/STATE.md for highest ID before creating**
- **ALWAYS update work/STATE.md after creating a new task**
- Number never changes once assigned
- Format: ID-DESCRIPTION.md (where ID is the number, DESCRIPTION is kebab-case: words-separated-by-hyphens)
- Reference as "task #ID" or "task ID" (where ID is the actual number)

### work/STATE.md Format
```markdown
# work/STATE.md

**Last Updated**: YYYY-MM-DD
**5DAY_TASK_ID**: ID
**5DAY_BUG_ID**: ID
```

**Example**:
```markdown
# work/STATE.md

**Last Updated**: 2024-01-15
**5DAY_TASK_ID**: 42
**5DAY_BUG_ID**: 7
```

**Critical**: Count tasks by STATE.md, not by number of files. If STATE.md shows highest ID is N, next task is N+1.
Always use the ID from work/STATE.md, not a count of existing task files.

## Sprint Planning

Move tasks through the pipeline using git mv:
```bash
# For all commands below: replace ID-DESCRIPTION.md with actual filename  
# Pattern: NUMBER-KEBAB-CASE-DESCRIPTION.md

git mv work/tasks/backlog/ID-DESCRIPTION.md work/tasks/next/    # planning sprint
git mv work/tasks/next/ID-DESCRIPTION.md work/tasks/working/    # starting work
git mv work/tasks/working/ID-DESCRIPTION.md work/tasks/next/    # if blocked
```

- `work/tasks/next/` = your sprint queue
- `work/tasks/working/` = what you're working on RIGHT NOW (keep minimal)
- Blocked tasks go back to `work/tasks/next/` to be reworked

## Scripts Directory

The `work/scripts/` directory contains 5DayDocs automation tools for common workflows. We prioritize bash scripts for universality and avoid framework dependencies. This keeps 5DayDocs scripts separate from any application-specific scripts.

### Script Naming Convention
- **New scripts**: Use `.sh` extension and descriptive kebab-case names
- **Examples**: `create-task.sh`, `move-to-review.sh`, `check-status.sh`
- **Legacy**: Existing `.ts` and `.js` scripts are being phased out

### Creating Automation Scripts

```bash
#!/bin/bash
# Script: work/scripts/SCRIPT-NAME.sh
# Purpose: Brief description
# Usage: ./work/scripts/SCRIPT-NAME.sh [arguments]

set -e  # Exit on error

# Script logic here
```

**Important**: All scripts must be made executable:
```bash
chmod +x work/scripts/SCRIPT-NAME.sh
```

### Provided Automation Scripts

After running `./setup.sh`, these scripts will be available in `work/scripts/`:

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup.sh` | Initial setup (in root) | `./setup.sh` |
| `create-task.sh` | Create new task with auto-ID | `./work/scripts/create-task.sh "Description" [feature]` |
| `check-alignment.sh` | Check feature/task alignment | `./work/scripts/check-alignment.sh` |

## Integration Options

### GitHub Issues (Optional)

When this repository is hosted on GitHub, the included GitHub Action (`.github/workflows/sync-tasks-to-issues.yml`) automatically:
- Creates GitHub issues when tasks are committed to `backlog/` or `next/`
- Updates issue labels as tasks move between folders
- Closes issues when tasks reach `live/`

### Jira Kanban Board (Optional)

For stakeholder visibility, you can sync tasks to Jira as a kanban board:
- Automatically creates/updates Jira tickets based on folder movements
- Imports Jira-created tickets back to Git (maintaining Git as source of truth)
- Automatic conflict resolution with Git always winning
- Works with both GitHub and Bitbucket repositories

**Setup Guides**:
- [Basic Setup](./docs/guides/jira-kanban-setup.md) - One-way sync for visualization
- [Full Sync with Git Authority](./docs/guides/git-source-of-truth-sync.md) - Two-way sync with automatic reconciliation

### How It Works
Simply use your normal git workflow. The GitHub Action handles everything:

```bash
# Example workflow (replace ID and DESCRIPTION with actual values)
# Creating a task:
echo "# Task ID: TITLE" > work/tasks/backlog/ID-DESCRIPTION.md
git add work/tasks/backlog/ID-DESCRIPTION.md
git commit -m "Add task ID: DESCRIPTION"
git push  # GitHub Action creates issue automatically

# Moving through pipeline:
git mv work/tasks/backlog/ID-DESCRIPTION.md work/tasks/working/
git commit -m "Start task ID"
git push  # GitHub Action updates issue label

# Completing:
git mv work/tasks/review/ID-DESCRIPTION.md work/tasks/live/
git commit -m "Complete task ID"
git push  # GitHub Action closes issue
```

### Issue Labels
The Action automatically applies these labels:
- `5day-task` - Identifies all 5DayDocs tasks
- `backlog` - Tasks in backlog folder
- `sprint` - Tasks in next folder
- `in-progress` - Tasks in working folder
- `review` - Tasks in review folder
- `completed` - Tasks in live folder (issue closed)

### No Additional Tools Required
The integration works entirely through GitHub Actions. No need to install GitHub CLI or run special commands locally.

### Disabling Integration
To disable: Simply delete `.github/workflows/sync-tasks-to-issues.yml`

## Quick Reference Commands

```bash
# Check current task status
ls work/tasks/working/      # What's being worked on
ls work/tasks/next/         # What's in the queue
ls work/tasks/backlog/      # What needs prioritization

# Move tasks through workflow
git mv work/tasks/backlog/ID-name.md work/tasks/next/    # Queue for sprint
git mv work/tasks/next/ID-name.md work/tasks/working/     # Start work
git mv work/tasks/working/ID-name.md work/tasks/review/   # Submit for review
git mv work/tasks/review/ID-name.md work/tasks/live/      # Complete task
```

## Feature-Task Alignment

### Key Principle
Features track **what capabilities exist**, while tasks track **work being done**. A feature can be LIVE even while having tasks in backlog for enhancements.

### Checking Alignment
Run the analysis script to check feature-task alignment:
```bash
./work/scripts/check-alignment.sh
```

This script will:
- Show all features and their current status
- List tasks that reference each feature
- Identify misalignments between task locations and feature statuses
- Find orphaned tasks without feature references

### When to Update Feature Status
- When a capability first goes LIVE → Update feature to LIVE
- When starting work on a new capability → Keep feature status unchanged
- Tasks are temporary, features are permanent
- Feature status = highest completed capability state

### Best Practices
- **For AI Assistants**: Always run the alignment check after moving tasks to review or live
- **For Developers**: Check alignment before sprint planning
- **For Features**: Track individual capability statuses within the feature doc

## Edge Cases & FAQs

**Q: What if a task doesn't relate to any feature?**
A: Use `**Feature**: none` for infrastructure, tooling, or documentation tasks.

**Q: What if a task relates to multiple features?**
A: Use `**Feature**: multiple` and list features in the Problem section.

**Q: What if a bug has no existing feature?**
A: Create the feature doc first (as BACKLOG), then create the bug task.

**Q: Can I skip review and go straight to live?**
A: No. All tasks must pass through review for quality control.

**Q: What if I need to work on an urgent bug?**
A: Move directly from `backlog/` to `working/`, document the urgency in the task.

**Q: How do I handle tasks that get stuck?**
A: After 2 weeks in `working/`, move back to `next/` and add blocker notes.

## Troubleshooting

**Scripts not executable?**
```bash
# Quick fix for all scripts
chmod +x work/scripts/*.sh
chmod +x 5day.sh
# Or run the setup script
./setup.sh
```

**Missing directories?** Run `./setup.sh` or create manually:
```bash
mkdir -p work/tasks/{backlog,next,working,review,live}
mkdir -p work/{bugs/archived,designs,examples,data}
mkdir -p docs/{features,guides}
mkdir -p work/scripts
```

**Task ID conflicts?** Always check work/STATE.md first. The STATE.md file is the source of truth for task IDs.

**Git status showing deleted files?** This is normal after reorganization. Review and commit changes when ready.

**Permission denied when running scripts?**
- Ensure the script is executable: `ls -la work/scripts/`
- Run with bash directly: `bash work/scripts/script-name.sh`
- Or make executable: `chmod +x work/scripts/script-name.sh`

---
*Simple, folder-based task management with clear feature documentation*
