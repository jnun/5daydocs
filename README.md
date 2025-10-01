# Philosophy

**No databases, no apps—just folders and markdown files.**

- **Simple:** Everything is plain text and version controlled
- **Portable:** Works with any project, any language, any team size
- **Transparent:** All project management is visible and editable
- **Flexible:** Adapt the workflow to your needs
- **Minimal root footprint:** The only file placed in your project root is `DOCUMENTATION.md`
- **Docs folder holes evrerything:** /docs holds everything related to your project tasks
- **Submodule-friendly:** You can install 5DayDocs as a Git submodule

## Installation as a Submodule

To use 5DayDocs in your project, add it as a submodule:
## Quick Start / Installation

To install 5DayDocs in your project:

```bash
# 1. Add 5DayDocs as a submodule (recommended)
git submodule add https://github.com/yourusername/5daydocs.git 5daydocs

# 2. Run the setup script (from inside the submodule)
cd 5daydocs
chmod +x setup.sh
./setup.sh

# 3. When prompted, enter the path to your project root
#    (e.g., /Users/yourname/myproject)

# 4. After setup, your project will have:
#    - DOCUMENTATION.md in root
#    - docs/ folder with all 5DayDocs files

# 5. Start using 5DayDocs automation scripts
cd /path/to/your-project
./docs/work/scripts/create-task.sh "Your first task"
```

# Check feature/task alignment
./docs/work/scripts/check-alignment.sh
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

## Submodule Structure

When installed as a Git submodule, 5daydocs provides this structure in your project:

```
your-project/
├── 5daydocs/                    # The submodule
│   ├── 5day.sh                  # Command interface
│   ├── setup.sh                 # Initialization script
│   ├── templates/               # Workflow templates
│   ├── CLAUDE.md               # AI pair programming guide
│   └── README.md               # This file
└── docs/                        # Created by setup.sh
    ├── features/               # Feature specs (your data)
    ├── guides/                 # Technical docs (your data)
    └── work/                   # Work items (your data)
        ├── STATE.md            # ID tracking (your data)
        ├── tasks/              # Task pipeline (your data)
        │   ├── backlog/
        │   ├── next/
        │   ├── working/
        │   ├── review/
        │   └── live/
        ├── bugs/               # Bug tracking (your data)
        └── scripts/            # Custom automation (your data)
```

**Key Points:**
- The `5daydocs/` submodule contains only the framework
- Your `docs/` folder contains all your project documentation and work items
- Updates to 5daydocs won't affect your content
- Your content is tracked in your main repository, not the submodule

---
*Simple, folder-based task management with clear feature documentation*
