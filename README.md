# Philosophy

**No databases, no apps—just folders and markdown files.**

- **Simple:** Everything is plain text and version controlled
- **Portable:** Works with any project, any language, any team size
- **Transparent:** All project management is visible and editable
- **Flexible:** Adapt the workflow to your needs
- **Minimal root footprint:** The only file placed in your project root is `DOCUMENTATION.md`
- **Docs folder holds everything:** /docs holds everything related to your project tasks
- **Submodule-friendly:** You can install 5DayDocs as a Git submodule

## Quick Start / Installation

To install 5DayDocs in your project:

```bash
# Option 1: Clone as a submodule (recommended)
git submodule add https://github.com/jnun/5daydocs.git 5daydocs
cd 5daydocs
chmod +x setup.sh
./setup.sh

# Option 2: Clone standalone
git clone https://github.com/jnun/5daydocs.git
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
    ├── ideas/                  # Brainstorming (your data)
    ├── STATE.md                # ID tracking (your data)
    └── work/                   # Work items (your data)
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

## For 5DayDocs Developers: Distribution & Updates

**If you are maintaining the 5daydocs repository itself**, follow this workflow to properly distribute updates to users:

### Update & Distribution Checklist

When making changes to 5daydocs, follow these steps in order:

1. **Make your changes** to the codebase
   - Update scripts, workflows, documentation, etc.
   - Test changes in a local project

2. **Update templates to match new behavior**
   - **CRITICAL:** If you modified `.github/workflows/*.yml`, copy it to `templates/workflows/github/`
   - If you modified `docs/work/scripts/*.sh`, these are automatically distributed by update.sh
   - Templates are what get copied to user projects during updates

3. **Increment the VERSION file**
   - Update `/VERSION` using semantic versioning:
     - **Patch (1.1.X):** Bug fixes, small improvements
     - **Minor (1.X.0):** New features, workflow changes
     - **Major (X.0.0):** Breaking changes to structure
   - Add migration logic to `scripts/update.sh` if needed (see existing migrations)

4. **Test the update process**
   ```bash
   # In a test project with 5daydocs installed:
   cd 5daydocs-submodule
   git pull origin main
   cd ..
   ./5daydocs-submodule/scripts/update.sh
   # Enter path to test project
   # Verify files were updated correctly
   ```

5. **Commit and push**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin main
   ```

### How Update Distribution Works

When users run `./scripts/update.sh`:

1. Script reads version from `5daydocs/VERSION` (source)
2. Compares with `docs/VERSION` (installed version)
3. Runs any migration logic between versions
4. **Copies distributable files:**
   - Workflows from `templates/workflows/github/` → `.github/workflows/`
   - Scripts from `docs/work/scripts/` → user's `docs/work/scripts/`
5. Updates `docs/VERSION` to match source version

### Critical Files to Keep in Sync

**Always update both locations:**
- `.github/workflows/*.yml` AND `templates/workflows/github/*.yml`
- Any changes to workflow behavior must be in both places

**Auto-distributed files:**
- `docs/work/scripts/*.sh` - Automatically copied by update.sh
- `templates/workflows/github/*.yml` - Copied if workflow already exists

### Version Migration Pattern

Add version checks to `scripts/update.sh`:

```bash
# Migration from X.X.X to X.X.X+1
if [[ "$INSTALLED_VERSION" < "X.X.X" ]]; then
  echo ""
  echo "Migrating from previous to X.X.X..."
  # Add migration steps here
  INSTALLED_VERSION="X.X.X"
fi
```

### Testing Changes

Before releasing updates:
1. Test in a project with existing 5daydocs installation
2. Verify `update.sh` correctly updates all files
3. Verify workflows trigger and run correctly
4. Check STATE.md flags are preserved during updates

---
*Simple, folder-based task management with clear feature documentation*
