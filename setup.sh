#!/bin/bash
# setup.sh - Initialize 5DayDocs project documentation structure
# Usage: ./setup.sh
#   Prompts for target project path and sets up 5DayDocs structure there
#
# Templates: Workflow templates are stored in templates/workflows/
#   These are copied to the target project based on platform selection

set -e  # Exit on error

# Store the 5daydocs source directory (project root, same directory as this script)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FIVEDAY_SOURCE_DIR="$SCRIPT_DIR"

# Read current version from source
if [ -f "$FIVEDAY_SOURCE_DIR/VERSION" ]; then
    CURRENT_VERSION=$(cat "$FIVEDAY_SOURCE_DIR/VERSION")
else
    CURRENT_VERSION="1.0.0"
fi

echo "================================================"
echo "  5DayDocs - Project Documentation Setup"
echo "================================================"
echo "  Version: $CURRENT_VERSION"
echo ""

# Ask for target project path
echo "Enter the path to your project where 5DayDocs should be installed:"
echo "(e.g., /Users/yourname/myproject or ../myproject)"
read -r TARGET_PATH

# Expand tilde and resolve relative paths
TARGET_PATH="${TARGET_PATH/#\~/$HOME}"
TARGET_PATH="$( cd "$TARGET_PATH" 2>/dev/null && pwd )" || {
    echo "❌ Error: Path '$TARGET_PATH' does not exist or is not accessible."
    exit 1
}

echo ""
echo "Installing 5DayDocs to: $TARGET_PATH"
echo ""

# Platform configuration selection
echo "Select your platform configuration:"
echo "1) GitHub with GitHub Issues (default) - ✓ Fully supported"
echo "2) GitHub with Jira - ⚠️ Coming soon (not fully implemented)"
echo "3) Bitbucket with Jira - ⚠️ Coming soon (not fully implemented)"
echo ""
echo "Enter your choice (1-3, or press Enter for default):"
read -r PLATFORM_CHOICE

# Set platform configuration based on choice
case "$PLATFORM_CHOICE" in
    2)
        PLATFORM="github-jira"
        echo "⚠️  Selected: GitHub with Jira (Note: Integration not fully implemented yet)"
        echo "   The folder structure will be created but Jira sync is still in development."
        ;;
    3)
        PLATFORM="bitbucket-jira"
        echo "⚠️  Selected: Bitbucket with Jira (Note: Integration not fully implemented yet)"
        echo "   The folder structure will be created but Bitbucket/Jira sync is still in development."
        ;;
    *)
        PLATFORM="github-issues"
        echo "✓ Selected: GitHub with GitHub Issues (Fully supported)"
        ;;
esac

echo ""

# Change to target directory
cd "$TARGET_PATH"

# Check if we're in the 5daydocs source directory
if [ "$TARGET_PATH" = "$FIVEDAY_SOURCE_DIR" ]; then
    echo "❌ Error: Cannot install 5DayDocs into its own source directory."
    echo "Please specify a different project path."
    exit 1
fi

# Check if 5DayDocs is already installed
if [ -f docs/STATE.md ] || [ -f DOCUMENTATION.md ]; then
    echo "⚠ 5DayDocs appears to be already installed in this project."
    echo "Do you want to update/refresh the installation? (y/n)"
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    UPDATE_MODE=true
else
    UPDATE_MODE=false
fi

# Create directory structure with safety checks
echo "Creating directory structure..."

# Function to safely create directories
safe_mkdir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "  ✓ Created: $dir"
    else
        echo "  → Exists: $dir"
    fi
}

# Create work directories
safe_mkdir "docs/work/tasks/backlog"
safe_mkdir "docs/work/tasks/next"
safe_mkdir "docs/work/tasks/working"
safe_mkdir "docs/work/tasks/review"
safe_mkdir "docs/work/tasks/live"
safe_mkdir "docs/work/bugs/archived"
safe_mkdir "docs/work/designs"
safe_mkdir "docs/work/examples"
safe_mkdir "docs/work/data"
safe_mkdir "docs/work/scripts"

# Create docs directories
safe_mkdir "docs/features"
safe_mkdir "docs/guides"

# Only create .github/workflows for GitHub-based platforms
if [ "$PLATFORM" != "bitbucket-jira" ]; then
    safe_mkdir ".github/workflows"
fi

# Create or update state tracking files
echo "Managing state tracking files..."
if [ ! -f docs/STATE.md ]; then
    # Create new STATE.md
    # Check if template exists in source directory
    if [ -f "$FIVEDAY_SOURCE_DIR/templates/project/STATE.md.template" ]; then
        # Copy template and replace placeholders
        sed -e "s/{{DATE}}/$(date +%Y-%m-%d)/g" \
            -e "s/{{VERSION}}/$CURRENT_VERSION/g" \
            "$FIVEDAY_SOURCE_DIR/templates/project/STATE.md.template" > docs/STATE.md
        echo "✓ Created docs/STATE.md from template"
    else
        # Fallback to inline generation if template doesn't exist
        cat > docs/STATE.md << STATE_EOF
# docs/STATE.md

**Last Updated**: $(date +%Y-%m-%d)
**5DAY_VERSION**: $CURRENT_VERSION
**5DAY_TASK_ID**: 0
**5DAY_BUG_ID**: 0
**SYNC_ALL_TASKS**: false
STATE_EOF
        echo "✓ Created docs/STATE.md (fallback inline generation)"
    fi
else
    # STATE.md exists - preserve the ID numbers during updates
    if $UPDATE_MODE; then
        echo "  Preserving existing STATE.md values during update..."

        # Extract existing values with robust parsing and validation
        EXISTING_VERSION=$(awk '/5DAY_VERSION/{print $NF}' docs/STATE.md 2>/dev/null)
        EXISTING_TASK_ID=$(grep "5DAY_TASK_ID" docs/STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | grep -o '^[0-9]*' | head -1)
        EXISTING_BUG_ID=$(grep "5DAY_BUG_ID" docs/STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | grep -o '^[0-9]*' | head -1)
        EXISTING_SYNC_FLAG=$(awk '/SYNC_ALL_TASKS/{print $NF}' docs/STATE.md 2>/dev/null)
        EXISTING_DATE=$(grep "Last Updated" docs/STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1)

        # Validate and sanitize extracted values
        # Preserve existing version or use current if missing
        if [ -n "$EXISTING_VERSION" ]; then
            PRESERVE_VERSION="$EXISTING_VERSION"
        else
            PRESERVE_VERSION="$CURRENT_VERSION"
            echo "    Info: Adding version field: $CURRENT_VERSION"
        fi

        # Ensure IDs are valid numbers, default to 0 if not
        if [[ "$EXISTING_TASK_ID" =~ ^[0-9]+$ ]]; then
            PRESERVE_TASK_ID=$EXISTING_TASK_ID
        else
            PRESERVE_TASK_ID=0
            echo "    Warning: Invalid task ID found, using 0"
        fi

        if [[ "$EXISTING_BUG_ID" =~ ^[0-9]+$ ]]; then
            PRESERVE_BUG_ID=$EXISTING_BUG_ID
        else
            PRESERVE_BUG_ID=0
            echo "    Warning: Invalid bug ID found, using 0"
        fi

        # Validate sync flag
        if [ "$EXISTING_SYNC_FLAG" = "true" ] || [ "$EXISTING_SYNC_FLAG" = "false" ]; then
            PRESERVE_SYNC_FLAG="$EXISTING_SYNC_FLAG"
        else
            PRESERVE_SYNC_FLAG="false"
            echo "    Info: Adding SYNC_ALL_TASKS field: false"
        fi

        # Validate date format (YYYY-MM-DD), use today if invalid
        if [[ "$EXISTING_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            PRESERVE_DATE="$EXISTING_DATE"
        else
            PRESERVE_DATE=$(date +%Y-%m-%d)
            echo "    Warning: Invalid date format found, using today's date"
        fi

        echo "    Preserved Last Updated: $PRESERVE_DATE"
        echo "    Preserved Version: $PRESERVE_VERSION"
        echo "    Preserved Task ID: $PRESERVE_TASK_ID"
        echo "    Preserved Bug ID: $PRESERVE_BUG_ID"
        echo "    Preserved Sync Flag: $PRESERVE_SYNC_FLAG"

        # Simply rewrite STATE.md with preserved values
        cat > docs/STATE.md << STATE_EOF
# docs/STATE.md

**Last Updated**: $PRESERVE_DATE
**5DAY_VERSION**: $PRESERVE_VERSION
**5DAY_TASK_ID**: $PRESERVE_TASK_ID
**5DAY_BUG_ID**: $PRESERVE_BUG_ID
**SYNC_ALL_TASKS**: $PRESERVE_SYNC_FLAG
STATE_EOF
        echo "✓ Updated STATE.md while preserving values"
    else
        echo "⚠ docs/STATE.md already exists, preserving existing file"
    fi
fi

# Store platform configuration
if [ ! -f docs/work/.platform-config ] || $UPDATE_MODE; then
    cat > docs/work/.platform-config << CONFIG_EOF
# 5DayDocs Platform Configuration
# Generated: $(date +%Y-%m-%d)
PLATFORM="$PLATFORM"
CONFIG_EOF
    echo "✓ Created platform configuration file (docs/work/.platform-config)"
fi

# BUG_STATE.md is now integrated into STATE.md
# Create a migration notice if old BUG_STATE.md exists
if [ -f docs/work/bugs/BUG_STATE.md ]; then
    echo "ℹ️  Note: Bug state tracking is now managed in docs/STATE.md"
    echo "  The old docs/work/bugs/BUG_STATE.md can be removed after migration."
fi

# Copy documentation files
echo "Setting up documentation files..."

# Track counters for validation
FOLDERS_CREATED=0
FILES_COPIED=0
SCRIPTS_READY=0
INDEX_FILES_COPIED=0

# Copy README.md if it doesn't exist
if [ ! -f README.md ]; then
    if [ -f "$FIVEDAY_SOURCE_DIR/README.md" ]; then
        # Create a project-specific README with 5DayDocs reference
        cat > README.md << README_EOF
# Project Name

This project uses [5DayDocs](https://github.com/5daydocs/5daydocs) for task and documentation management.

## Quick Start

See \`DOCUMENTATION.md\` for the complete workflow guide.

### Common Commands

\`\`\`bash
# Create a new task
./docs/work/scripts/create-task.sh "Task description"

# Check feature-task alignment
./docs/work/scripts/analyze-feature-alignment.sh

# View current work
ls docs/work/tasks/working/

# View sprint queue
ls docs/work/tasks/next/
\`\`\`

## Project Structure

- \`docs/work/tasks/\` - Task pipeline (backlog → next → working → review → live)
- \`docs/features/\` - Feature documentation with status tracking
- \`docs/work/bugs/\` - Bug reports and tracking

---
*Powered by 5DayDocs - Simple, folder-based project management*
README_EOF
        echo "✓ Created project README.md"
    fi
else
    echo "⚠ README.md already exists, preserving your version"
fi

# Copy DOCUMENTATION.md if it doesn't exist or in update mode
if [ ! -f DOCUMENTATION.md ] || $UPDATE_MODE; then
    if [ -f "$FIVEDAY_SOURCE_DIR/DOCUMENTATION.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/DOCUMENTATION.md" DOCUMENTATION.md
        echo "✓ Copied DOCUMENTATION.md"
        ((FILES_COPIED++))
    else
        echo "⚠ DOCUMENTATION.md not found in source directory"
    fi
else
    echo "⚠ DOCUMENTATION.md already exists, skipping"
fi

# Copy template files
echo "Setting up template files..."
if [ ! -f docs/work/tasks/TEMPLATE-task.md ] || $UPDATE_MODE; then
    if [ -f "$FIVEDAY_SOURCE_DIR/docs/work/tasks/TEMPLATE-task.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/docs/work/tasks/TEMPLATE-task.md" docs/work/tasks/
        echo "✓ Copied task template"
        ((FILES_COPIED++))
    fi
fi

if [ ! -f docs/work/bugs/TEMPLATE-bug.md ] || $UPDATE_MODE; then
    if [ -f "$FIVEDAY_SOURCE_DIR/docs/work/bugs/TEMPLATE-bug.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/docs/work/bugs/TEMPLATE-bug.md" docs/work/bugs/
        echo "✓ Copied bug template"
        ((FILES_COPIED++))
    fi
fi

if [ ! -f docs/features/TEMPLATE-feature.md ] || $UPDATE_MODE; then
    if [ -f "$FIVEDAY_SOURCE_DIR/docs/features/TEMPLATE-feature.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/docs/features/TEMPLATE-feature.md" docs/features/
        echo "✓ Copied feature template"
        ((FILES_COPIED++))
    fi
fi

# Copy scripts (all go in docs/work/scripts/)
echo "Setting up automation scripts..."
if [ -f "$FIVEDAY_SOURCE_DIR/docs/work/scripts/check-alignment.sh" ]; then
    cp "$FIVEDAY_SOURCE_DIR/docs/work/scripts/check-alignment.sh" docs/work/scripts/
    chmod +x docs/work/scripts/check-alignment.sh
    echo "✓ Copied check-alignment.sh to docs/work/scripts/"
    ((FILES_COPIED++))
    ((SCRIPTS_READY++))
fi

if [ -f "$FIVEDAY_SOURCE_DIR/docs/work/scripts/create-task.sh" ]; then
    cp "$FIVEDAY_SOURCE_DIR/docs/work/scripts/create-task.sh" docs/work/scripts/
    chmod +x docs/work/scripts/create-task.sh
    echo "✓ Copied create-task.sh to docs/work/scripts/"
    ((FILES_COPIED++))
    ((SCRIPTS_READY++))
fi

if [ -f "$FIVEDAY_SOURCE_DIR/docs/work/scripts/create-feature.sh" ]; then
    cp "$FIVEDAY_SOURCE_DIR/docs/work/scripts/create-feature.sh" docs/work/scripts/
    chmod +x docs/work/scripts/create-feature.sh
    echo "✓ Copied create-feature.sh to docs/work/scripts/"
    ((FILES_COPIED++))
    ((SCRIPTS_READY++))
fi

# Copy the main 5day.sh command script to project root
if [ -f "$FIVEDAY_SOURCE_DIR/5day.sh" ]; then
    if [ ! -f ./5day.sh ] || $UPDATE_MODE; then
        cp "$FIVEDAY_SOURCE_DIR/5day.sh" ./5day.sh
        chmod +x ./5day.sh
        echo "✓ Copied 5day.sh command script to project root"
        ((FILES_COPIED++))
    else
        echo "⚠ 5day.sh already exists, preserving your version"
    fi
else
    echo "⚠ Warning: 5day.sh not found in source directory"
fi

# Note: 5d symlink removed for clarity - use 5day.sh as the single command interface

# Copy GitHub workflows (only for GitHub-based platforms)
if [ "$PLATFORM" != "bitbucket-jira" ]; then
    echo "Setting up GitHub Actions workflows..."

    # Ensure .github/workflows directory exists
    mkdir -p .github/workflows

    # Copy appropriate workflow files from templates based on platform
    if [ "$PLATFORM" = "github-jira" ]; then
        # Jira integration placeholder
        echo "  Note: Jira integration workflows are not yet implemented"
        echo "  You'll need to configure Jira integration manually"
    else
        # Copy GitHub Issues workflow from templates
        if [ -f "$FIVEDAY_SOURCE_DIR/templates/workflows/github/sync-tasks-to-issues.yml" ]; then
            cp "$FIVEDAY_SOURCE_DIR/templates/workflows/github/sync-tasks-to-issues.yml" .github/workflows/
            echo "✓ Copied sync-tasks-to-issues.yml"
        fi
        echo "  Remember to configure secrets in your GitHub repository settings"
    fi

    # Copy GitHub issue and PR templates
    echo "Setting up GitHub issue and PR templates..."
    mkdir -p .github/ISSUE_TEMPLATE

    if [ -f "$FIVEDAY_SOURCE_DIR/.github/ISSUE_TEMPLATE/bug_report.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/.github/ISSUE_TEMPLATE/bug_report.md" .github/ISSUE_TEMPLATE/
        echo "✓ Copied bug report template"
    fi

    if [ -f "$FIVEDAY_SOURCE_DIR/.github/ISSUE_TEMPLATE/feature_request.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/.github/ISSUE_TEMPLATE/feature_request.md" .github/ISSUE_TEMPLATE/
        echo "✓ Copied feature request template"
    fi

    if [ -f "$FIVEDAY_SOURCE_DIR/.github/ISSUE_TEMPLATE/task.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/.github/ISSUE_TEMPLATE/task.md" .github/ISSUE_TEMPLATE/
        echo "✓ Copied task template"
    fi

    if [ -f "$FIVEDAY_SOURCE_DIR/.github/pull_request_template.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/.github/pull_request_template.md" .github/
        echo "✓ Copied pull request template"
    fi
else
    # Bitbucket platform - copy bitbucket-pipelines.yml from templates
    echo "Setting up Bitbucket Pipelines..."

    if [ -f "$FIVEDAY_SOURCE_DIR/templates/bitbucket-pipelines.yml" ]; then
        if [ ! -f bitbucket-pipelines.yml ] || $UPDATE_MODE; then
            cp "$FIVEDAY_SOURCE_DIR/templates/bitbucket-pipelines.yml" bitbucket-pipelines.yml
            echo "✓ Copied bitbucket-pipelines.yml to project root"
            ((FILES_COPIED++))
        else
            echo "⚠ bitbucket-pipelines.yml already exists, preserving your version"
        fi
    else
        echo "⚠ Warning: bitbucket-pipelines.yml template not found in templates directory"
    fi

    echo "⚠ Note: Bitbucket/Jira integration is not fully implemented yet"
fi

# Handle .gitignore configuration
echo ""
echo "Would you like to add 5DayDocs recommended .gitignore entries? (y/n)"
read -r GITIGNORE_CHOICE

if [[ "$GITIGNORE_CHOICE" =~ ^[Yy]$ ]]; then
    GITIGNORE_CONTENT="# OS Files
.DS_Store
Thumbs.db
desktop.ini
*.lnk

# Editor Files
.vscode/
.idea/
*.sublime-*
.nova/
*.swp
*.swo
*~
#*#
.#*

# Temporary Files
*.tmp
*.temp
*.bak
*.backup
*.old
*.orig
*.log
.~lock.*

# Shell/Script artifacts
*.pid
*.seed
*.pid.lock
nohup.out

# Archive Files (if users zip up old work)
*.zip
*.tar
*.tar.gz
*.rar
*.7z

# Environment and secrets
.env
.env.*
*.pem
*.key
secrets/

# Local data examples (expand as needed)
docs/work/data/*.csv
docs/work/data/*.json
docs/work/data/*.xml
docs/work/data/*.sql
docs/work/data/*.db
docs/work/data/*.sqlite

# Design files (binary/large files)
docs/work/designs/*.psd
docs/work/designs/*.ai
docs/work/designs/*.sketch
docs/work/designs/*.fig
docs/work/designs/*.xd

# Documentation builds (if using doc generators)
docs/_build/
docs/.doctrees/
site/

# macOS Finder
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent
.AppleDouble
.LSOverride
Icon?
._*"

    if [ ! -f .gitignore ]; then
        echo "$GITIGNORE_CONTENT" > .gitignore
        echo "✓ Created .gitignore with recommended settings"
    else
        echo ""
        echo ".gitignore already exists. Would you like to:"
        echo "1) Append 5DayDocs entries (checking for duplicates)"
        echo "2) Keep existing .gitignore unchanged"
        echo "Enter choice (1 or 2):"
        read -r APPEND_CHOICE

        if [ "$APPEND_CHOICE" = "1" ]; then
            # Create temp file with unique entries to add
            echo "$GITIGNORE_CONTENT" > /tmp/gitignore_to_add.tmp

            # Append with separator comment
            echo "" >> .gitignore
            echo "# === 5DayDocs Recommended Entries ===" >> .gitignore

            # Add each line if not already present
            while IFS= read -r line; do
                if [ -n "$line" ] && ! grep -Fxq "$line" .gitignore; then
                    echo "$line" >> .gitignore
                fi
            done < /tmp/gitignore_to_add.tmp

            rm -f /tmp/gitignore_to_add.tmp
            echo "✓ Appended 5DayDocs entries to existing .gitignore"
        else
            echo "✓ Keeping existing .gitignore unchanged"
        fi
    fi
else
    echo "✓ Skipping .gitignore configuration"
fi

# Copy INDEX.md files for navigation and documentation
echo "Setting up INDEX.md documentation files..."

# List of INDEX.md files to copy from source
INDEX_FILES=(
    "docs/work/INDEX.md"
    "docs/work/tasks/INDEX.md"
    "docs/work/bugs/INDEX.md"
    "docs/work/scripts/INDEX.md"
    "docs/work/designs/INDEX.md"
    "docs/work/examples/INDEX.md"
    "docs/work/data/INDEX.md"
    "docs/INDEX.md"
    "docs/features/INDEX.md"
    "docs/guides/INDEX.md"
)

# Copy each INDEX.md file
for index_file in "${INDEX_FILES[@]}"; do
    # Check if source file exists
    if [ -f "$FIVEDAY_SOURCE_DIR/$index_file" ]; then
        # Check if target file exists
        if [ ! -f "$index_file" ] || $UPDATE_MODE; then
            # Ensure directory exists
            mkdir -p "$(dirname "$index_file")"

            # Copy the file
            cp "$FIVEDAY_SOURCE_DIR/$index_file" "$index_file"
            echo "✓ Copied $index_file"
            ((FILES_COPIED++))
            ((INDEX_FILES_COPIED++))
        else
            echo "⚠ $index_file already exists, preserving your version"
        fi
    else
        # If source doesn't exist, create basic version for essential directories
        if [ "$index_file" = "docs/work/INDEX.md" ] && ([ ! -f "$index_file" ] || $UPDATE_MODE); then
            cat > docs/work/INDEX.md << 'INDEX_EOF'
# docs/work/ Directory Index

This is the main operational directory for 5DayDocs project management.

## Directory Structure

- **tasks/** - Task pipeline management
  - `backlog/` - Planned tasks not yet started
  - `next/` - Tasks queued for current/next sprint
  - `working/` - Tasks actively being worked on (limit 1 per developer)
  - `review/` - Tasks completed and awaiting review
  - `live/` - Tasks deployed to production

- **bugs/** - Bug tracking and management
  - Active bug reports stored here
  - `archived/` - Resolved or converted bugs

- **scripts/** - Automation and utility scripts
  - `create-task.sh` - Create new tasks
  - `check-alignment.sh` - Check feature/task alignment
  - `setup.sh` - Initialize 5DayDocs structure

- **designs/** - UI mockups and design assets
- **examples/** - Code snippets and implementation examples
- **data/** - Test data and sample datasets

## Key Files

- **STATE.md** - Tracks highest task and bug ID numbers
- **.platform-config** - Platform configuration (GitHub/Jira/Bitbucket)

## Usage

See `/DOCUMENTATION.md` for complete workflow guide.
INDEX_EOF
            echo "✓ Created fallback docs/work/INDEX.md"
            ((FILES_COPIED++))
            ((INDEX_FILES_COPIED++))
        elif [ "$index_file" = "docs/INDEX.md" ] && ([ ! -f "$index_file" ] || $UPDATE_MODE); then
            cat > docs/INDEX.md << 'INDEX_EOF'
# docs/ Directory Index

This directory contains all project documentation.

## Directory Structure

- **features/** - Feature documentation with status tracking
  - Each feature documented with clear status (LIVE/TESTING/WORKING/BACKLOG)
  - Single source of truth for feature specifications
  - Template: `TEMPLATE-feature.md`

- **guides/** - Technical and user guides
  - How-to documentation
  - API references
  - Development guides
  - User manuals

## Documentation Standards

All documentation should:
1. Use clear, descriptive titles
2. Include status markers where applicable
3. Follow markdown best practices
4. Be kept up-to-date with implementation

## Feature Status Tags

- **LIVE** - Feature is in production
- **TESTING** - Feature is built and being tested
- **WORKING** - Feature is actively being developed
- **BACKLOG** - Feature is planned but not started

## Usage

See `/DOCUMENTATION.md` for complete workflow guide.
INDEX_EOF
            echo "✓ Created fallback docs/INDEX.md"
            ((FILES_COPIED++))
            ((INDEX_FILES_COPIED++))
        fi
    fi
done

# Create INDEX.md for task subfolders
for folder in backlog next working review live; do
    if [ ! -f "docs/work/tasks/$folder/INDEX.md" ] || $UPDATE_MODE; then
        case $folder in
            backlog)
                cat > "docs/work/tasks/$folder/INDEX.md" << 'EOF'
# backlog/ - Task Backlog

Tasks that are planned but not yet scheduled for work.

## Purpose
- Store all identified tasks
- No commitment to timeline
- Reviewed during planning sessions

## Moving Tasks Forward
```bash
git mv docs/work/tasks/backlog/ID-task.md docs/work/tasks/next/
```
EOF
                ;;
            next)
                cat > "docs/work/tasks/$folder/INDEX.md" << 'EOF'
# next/ - Sprint Queue

Tasks scheduled for the current or next sprint.

## Purpose
- Tasks ready to be worked on
- Prioritized for current sprint
- Clear scope and requirements

## Starting Work
```bash
git mv docs/work/tasks/next/ID-task.md docs/work/tasks/working/
```
EOF
                ;;
            working)
                cat > "docs/work/tasks/$folder/INDEX.md" << 'EOF'
# working/ - Active Development

Tasks currently being worked on.

## Rules
- Maximum 1 task per developer
- Should be completed quickly
- Move to review when done

## Completing Work
```bash
git mv docs/work/tasks/working/ID-task.md docs/work/tasks/review/
```
EOF
                ;;
            review)
                cat > "docs/work/tasks/$folder/INDEX.md" << 'EOF'
# review/ - Pending Review

Completed tasks awaiting review and approval.

## Purpose
- Code review
- Testing verification
- Documentation check

## Approval Process
```bash
git mv docs/work/tasks/review/ID-task.md docs/work/tasks/live/
```
EOF
                ;;
            live)
                cat > "docs/work/tasks/$folder/INDEX.md" << 'EOF'
# live/ - Deployed/Completed

Tasks that have been deployed to production or fully completed.

## Purpose
- Historical record
- Reference for similar tasks
- Success metrics tracking

## Archive
Tasks remain here as permanent record of completed work.
EOF
                ;;
        esac
        echo "✓ Created docs/work/tasks/$folder/INDEX.md"
        ((FILES_COPIED++))
        ((INDEX_FILES_COPIED++))
    fi
done

# Ensure all scripts are executable (double-check)
echo "Ensuring all scripts have execute permissions..."
if [ -d docs/work/scripts ]; then
    # Find all .sh files and make them executable
    SCRIPT_COUNT=0
    for script in docs/work/scripts/*.sh; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            basename_script=$(basename "$script")
            echo "  ✓ Made $basename_script executable"
            ((SCRIPT_COUNT++))
        fi
    done

    if [ $SCRIPT_COUNT -gt 0 ]; then
        echo "✓ All $SCRIPT_COUNT scripts in docs/work/scripts/ are now executable"
        SCRIPTS_READY=$SCRIPT_COUNT
    fi
fi

# Also ensure 5day.sh in project root is executable
if [ -f ./5day.sh ]; then
    chmod +x ./5day.sh
    echo "✓ Ensured 5day.sh is executable"
fi

# Note: 5d symlink removed - using 5day.sh as single command interface

# Count created folders
FOLDERS_CREATED=$(find docs .github -type d 2>/dev/null | wc -l | tr -d ' ')

# Validation checks
echo ""
echo "Running validation checks..."
VALIDATION_PASSED=true
VALIDATION_ERRORS=""

# Check required directories
for dir in docs/work/tasks/backlog docs/work/tasks/next docs/work/tasks/working docs/work/tasks/review docs/work/tasks/live docs/work/bugs docs/work/scripts docs/features docs/guides; do
    if [ ! -d "$dir" ]; then
        VALIDATION_PASSED=false
        VALIDATION_ERRORS="$VALIDATION_ERRORS\n  ❌ Missing directory: $dir"
    fi
done

# Check required files
for file in docs/STATE.md DOCUMENTATION.md; do
    if [ ! -f "$file" ]; then
        VALIDATION_PASSED=false
        VALIDATION_ERRORS="$VALIDATION_ERRORS\n  ❌ Missing file: $file"
    fi
done

# Check script executability
for script in docs/work/scripts/*.sh; do
    if [ -f "$script" ] && [ ! -x "$script" ]; then
        VALIDATION_PASSED=false
        VALIDATION_ERRORS="$VALIDATION_ERRORS\n  ❌ Script not executable: $script"
    fi
done

echo ""
echo "================================================"
if [ "$VALIDATION_PASSED" = true ]; then
    echo "  ✅ Setup Complete - All Checks Passed!"
else
    echo "  ⚠️  Setup Complete - With Issues"
fi
echo "================================================"
echo ""
echo "📊 Setup Summary:"
echo "  • $FOLDERS_CREATED folders created"
echo "  • $FILES_COPIED files copied"
echo "  • $INDEX_FILES_COPIED INDEX.md files processed"
echo "  • $SCRIPTS_READY scripts ready to use"
echo ""
echo "✓ 5DayDocs installed to: $TARGET_PATH"
echo "✓ Platform configured: $PLATFORM"
echo "✓ Directory structure created in docs/"
echo "✓ Scripts are executable at docs/work/scripts/"
echo "✓ Documentation available at DOCUMENTATION.md"
echo "✓ $INDEX_FILES_COPIED INDEX.md files installed for self-documentation"
echo "✓ Task templates ready in docs/work/tasks/"
echo "✓ Bug tracking initialized in docs/work/bugs/"

if [ "$VALIDATION_PASSED" = false ]; then
    echo ""
    echo "⚠️  Validation Issues Found:"
    echo -e "$VALIDATION_ERRORS"
fi

echo ""
if $UPDATE_MODE; then
    echo "✓ 5DayDocs structure updated"
    echo "✓ Existing project files preserved"
else
    echo "What's ready for you:"
    echo ""
    echo "📁 Project Structure:"
    echo "   - docs/work/tasks/ - Task pipeline (backlog → next → working → review → live)"
    echo "   - docs/features/ - Feature documentation"
    echo "   - docs/work/bugs/ - Bug tracking"
    echo ""
    echo "🛠 Available Scripts:"
    echo "   - ./5day.sh - Main command interface for 5DayDocs"
    echo "   - ./docs/work/scripts/create-task.sh - Create new tasks"
    echo "   - ./docs/work/scripts/check-alignment.sh - Check feature/task alignment"
    echo ""

    # Platform-specific setup info
    case "$PLATFORM" in
        "github-jira")
            echo "🔗 Platform Integration (GitHub + Jira):"
            echo "   ⚠️  Note: Jira integration is not fully implemented yet"
            echo "   - GitHub workflows installed in .github/workflows/"
            echo "   - Manual Jira sync required until integration is complete"
            echo "   - Full integration coming in a future release"
            echo ""
            ;;
        "bitbucket-jira")
            echo "🔗 Platform Integration (Bitbucket + Jira):"
            echo "   ⚠️  Note: Bitbucket/Jira integration is not fully implemented yet"
            echo "   - Manual sync required until integration is complete"
            echo "   - Full integration coming in a future release"
            echo ""
            ;;
        *)
            echo "🔗 Platform Integration (GitHub + Issues):"
            echo "   - GitHub Actions workflows ready in .github/workflows/"
            echo "   - Configure repository secrets for integrations"
            echo ""
            ;;
    esac

    # Copy Bitbucket pipeline configuration for Bitbucket platform
    if [ "$PLATFORM" = "bitbucket-jira" ]; then
        echo "⚠ Bitbucket Pipelines configuration not yet implemented"
        echo "  You'll need to create bitbucket-pipelines.yml manually"
    fi

    echo "📚 Get Started Now:"
    echo ""
    echo "   Use the 5day.sh command interface:"
    echo "   $ ./5day.sh help                    # Show available commands"
    echo "   $ ./5day.sh newtask \"Your task\"     # Create a task"
    echo "   $ ./5day.sh status                  # Show task status"
    echo ""
    echo "   Or use scripts directly:"
    echo "   $ ./docs/work/scripts/create-task.sh \"Your first task description\""
    echo "   $ ./docs/work/scripts/check-alignment.sh"
    echo ""
    echo "To update 5DayDocs in the future, run this setup script again."
fi

if [ "$VALIDATION_PASSED" = true ]; then
    echo ""
    echo "🚀 5DayDocs is ready! Try creating a task now:"
    echo "   ./5day.sh newtask \"Build user authentication\""
    echo ""
    echo "   Or use the traditional method:"
    echo "   ./docs/work/scripts/create-task.sh \"Build user authentication\""
fi

echo ""
