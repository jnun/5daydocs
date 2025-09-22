#!/bin/bash
# setup.sh - Initialize project documentation structure
# Usage: ./setup.sh
#   Prompts for target project path and sets up 5DayDocs structure there

set -e  # Exit on error

# Store the 5daydocs source directory (project root, two levels up from this script)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FIVEDAY_SOURCE_DIR="$( cd "$SCRIPT_DIR/../.." && pwd )"

echo "================================================"
echo "  5DayDocs - Project Documentation Setup"
echo "================================================"
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
if [ -f work/STATE.md ] || [ -f DOCUMENTATION.md ]; then
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

# Create directory structure
echo "Creating directory structure..."
mkdir -p work/tasks/{backlog,next,working,review,live}
mkdir -p work/{bugs/archived,designs,examples,data,scripts}
mkdir -p docs/{features,guides}
# DO NOT create scripts/ at root - keep all scripts in work/scripts/

# Only create .github/workflows for GitHub-based platforms
if [ "$PLATFORM" != "bitbucket-jira" ]; then
    mkdir -p .github/workflows  # For GitHub Actions
fi

# Create state tracking files
echo "Creating state tracking files..."
if [ ! -f work/STATE.md ]; then
    cat > work/STATE.md << STATE_EOF
# work/STATE.md

**Last Updated**: $(date +%Y-%m-%d)
**Highest Task ID**: 0
STATE_EOF
    echo "✓ Created work/STATE.md"
else
    echo "⚠ work/STATE.md already exists, skipping"
fi

# Store platform configuration
if [ ! -f work/.platform-config ] || $UPDATE_MODE; then
    cat > work/.platform-config << CONFIG_EOF
# 5DayDocs Platform Configuration
# Generated: $(date +%Y-%m-%d)
PLATFORM="$PLATFORM"
CONFIG_EOF
    echo "✓ Created platform configuration file (work/.platform-config)"
fi

if [ ! -f work/bugs/BUG_STATE.md ]; then
    cat > work/bugs/BUG_STATE.md << BUG_EOF
# work/bugs/BUG_STATE.md

**Last Updated**: $(date +%Y-%m-%d)
**Highest Bug ID**: 0
BUG_EOF
    echo "✓ Created work/bugs/BUG_STATE.md"
else
    echo "⚠ work/bugs/BUG_STATE.md already exists, skipping"
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
./work/scripts/create-task.sh "Task description"

# Check feature-task alignment
./work/scripts/analyze-feature-alignment.sh

# View current work
ls work/tasks/working/

# View sprint queue
ls work/tasks/next/
\`\`\`

## Project Structure

- \`work/tasks/\` - Task pipeline (backlog → next → working → review → live)
- \`docs/features/\` - Feature documentation with status tracking
- \`work/bugs/\` - Bug reports and tracking

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

# Copy CLAUDE.md for AI assistance
if [ ! -f CLAUDE.md ]; then
    if [ -f "$FIVEDAY_SOURCE_DIR/CLAUDE.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/CLAUDE.md" CLAUDE.md
        echo "✓ Copied CLAUDE.md (AI assistant configuration)"
        ((FILES_COPIED++))
    fi
else
    echo "⚠ CLAUDE.md already exists, skipping"
fi

# Copy template files
echo "Setting up template files..."
if [ ! -f work/tasks/TEMPLATE-task.md ] || $UPDATE_MODE; then
    if [ -f "$FIVEDAY_SOURCE_DIR/work/tasks/TEMPLATE-task.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/work/tasks/TEMPLATE-task.md" work/tasks/
        echo "✓ Copied task template"
        ((FILES_COPIED++))
    fi
fi

if [ ! -f work/bugs/TEMPLATE-bug.md ] || $UPDATE_MODE; then
    if [ -f "$FIVEDAY_SOURCE_DIR/work/bugs/TEMPLATE-bug.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/work/bugs/TEMPLATE-bug.md" work/bugs/
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

# Copy scripts (all go in work/scripts/)
echo "Setting up automation scripts..."
if [ -f "$FIVEDAY_SOURCE_DIR/work/scripts/analyze-feature-alignment.sh" ]; then
    cp "$FIVEDAY_SOURCE_DIR/work/scripts/analyze-feature-alignment.sh" work/scripts/
    chmod +x work/scripts/analyze-feature-alignment.sh
    echo "✓ Copied analyze-feature-alignment.sh to work/scripts/"
    ((FILES_COPIED++))
    ((SCRIPTS_READY++))
fi

if [ -f "$FIVEDAY_SOURCE_DIR/work/scripts/create-task.sh" ]; then
    cp "$FIVEDAY_SOURCE_DIR/work/scripts/create-task.sh" work/scripts/
    chmod +x work/scripts/create-task.sh
    echo "✓ Copied create-task.sh to work/scripts/"
    ((FILES_COPIED++))
    ((SCRIPTS_READY++))
fi

# Copy GitHub workflows (only for GitHub-based platforms)
if [ "$PLATFORM" != "bitbucket-jira" ]; then
    echo "Setting up GitHub Actions workflows..."

    # Ensure .github/workflows directory exists
    mkdir -p .github/workflows

    # Copy appropriate workflow files based on platform
    if [ "$PLATFORM" = "github-jira" ]; then
        # Copy Jira-related workflows
        if [ -f "$FIVEDAY_SOURCE_DIR/.github/workflows/sync-tasks-to-jira.yml" ]; then
            cp "$FIVEDAY_SOURCE_DIR/.github/workflows/sync-tasks-to-jira.yml" .github/workflows/
            echo "✓ Copied sync-tasks-to-jira.yml"
        fi
        if [ -f "$FIVEDAY_SOURCE_DIR/.github/workflows/sync-jira-to-git.yml" ]; then
            cp "$FIVEDAY_SOURCE_DIR/.github/workflows/sync-jira-to-git.yml" .github/workflows/
            echo "✓ Copied sync-jira-to-git.yml"
        fi
        echo "  Note: You'll need to configure Jira integration in your repository settings"
    else
        # Copy GitHub Issues workflow
        if [ -f "$FIVEDAY_SOURCE_DIR/.github/workflows/sync-tasks-to-issues.yml" ]; then
            cp "$FIVEDAY_SOURCE_DIR/.github/workflows/sync-tasks-to-issues.yml" .github/workflows/
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
    echo "⚠ Skipping GitHub Actions and templates (not applicable for Bitbucket)"
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
work/data/*.csv
work/data/*.json
work/data/*.xml
work/data/*.sql
work/data/*.db
work/data/*.sqlite

# Design files (binary/large files)
work/designs/*.psd
work/designs/*.ai
work/designs/*.sketch
work/designs/*.fig
work/designs/*.xd

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
    "work/INDEX.md"
    "work/tasks/INDEX.md"
    "work/bugs/INDEX.md"
    "work/scripts/INDEX.md"
    "work/designs/INDEX.md"
    "work/examples/INDEX.md"
    "work/data/INDEX.md"
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
        if [ "$index_file" = "work/INDEX.md" ] && ([ ! -f "$index_file" ] || $UPDATE_MODE); then
            cat > work/INDEX.md << 'INDEX_EOF'
# work/ Directory Index

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
  - `analyze-feature-alignment.sh` - Check feature/task alignment
  - `setup.sh` - Initialize 5DayDocs structure

- **designs/** - UI mockups and design assets
- **examples/** - Code snippets and implementation examples
- **data/** - Test data and sample datasets

## Key Files

- **STATE.md** - Tracks highest task ID number
- **bugs/BUG_STATE.md** - Tracks highest bug ID number
- **.platform-config** - Platform configuration (GitHub/Jira/Bitbucket)

## Usage

See `/DOCUMENTATION.md` for complete workflow guide.
INDEX_EOF
            echo "✓ Created fallback work/INDEX.md"
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
    if [ ! -f "work/tasks/$folder/INDEX.md" ] || $UPDATE_MODE; then
        case $folder in
            backlog)
                cat > "work/tasks/$folder/INDEX.md" << 'EOF'
# backlog/ - Task Backlog

Tasks that are planned but not yet scheduled for work.

## Purpose
- Store all identified tasks
- No commitment to timeline
- Reviewed during planning sessions

## Moving Tasks Forward
```bash
git mv work/tasks/backlog/ID-task.md work/tasks/next/
```
EOF
                ;;
            next)
                cat > "work/tasks/$folder/INDEX.md" << 'EOF'
# next/ - Sprint Queue

Tasks scheduled for the current or next sprint.

## Purpose
- Tasks ready to be worked on
- Prioritized for current sprint
- Clear scope and requirements

## Starting Work
```bash
git mv work/tasks/next/ID-task.md work/tasks/working/
```
EOF
                ;;
            working)
                cat > "work/tasks/$folder/INDEX.md" << 'EOF'
# working/ - Active Development

Tasks currently being worked on.

## Rules
- Maximum 1 task per developer
- Should be completed quickly
- Move to review when done

## Completing Work
```bash
git mv work/tasks/working/ID-task.md work/tasks/review/
```
EOF
                ;;
            review)
                cat > "work/tasks/$folder/INDEX.md" << 'EOF'
# review/ - Pending Review

Completed tasks awaiting review and approval.

## Purpose
- Code review
- Testing verification
- Documentation check

## Approval Process
```bash
git mv work/tasks/review/ID-task.md work/tasks/live/
```
EOF
                ;;
            live)
                cat > "work/tasks/$folder/INDEX.md" << 'EOF'
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
        echo "✓ Created work/tasks/$folder/INDEX.md"
        ((FILES_COPIED++))
        ((INDEX_FILES_COPIED++))
    fi
done

# Ensure all scripts are executable (double-check)
echo "Ensuring all scripts have execute permissions..."
if [ -d work/scripts ]; then
    # Find all .sh files and make them executable
    SCRIPT_COUNT=0
    for script in work/scripts/*.sh; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            basename_script=$(basename "$script")
            echo "  ✓ Made $basename_script executable"
            ((SCRIPT_COUNT++))
        fi
    done

    if [ $SCRIPT_COUNT -gt 0 ]; then
        echo "✓ All $SCRIPT_COUNT scripts in work/scripts/ are now executable"
        SCRIPTS_READY=$SCRIPT_COUNT
    fi
fi

# Count created folders
FOLDERS_CREATED=$(find work docs .github -type d 2>/dev/null | wc -l | tr -d ' ')

# Validation checks
echo ""
echo "Running validation checks..."
VALIDATION_PASSED=true
VALIDATION_ERRORS=""

# Check required directories
for dir in work/tasks/backlog work/tasks/next work/tasks/working work/tasks/review work/tasks/live work/bugs work/scripts docs/features docs/guides; do
    if [ ! -d "$dir" ]; then
        VALIDATION_PASSED=false
        VALIDATION_ERRORS="$VALIDATION_ERRORS\n  ❌ Missing directory: $dir"
    fi
done

# Check required files
for file in work/STATE.md work/bugs/BUG_STATE.md DOCUMENTATION.md; do
    if [ ! -f "$file" ]; then
        VALIDATION_PASSED=false
        VALIDATION_ERRORS="$VALIDATION_ERRORS\n  ❌ Missing file: $file"
    fi
done

# Check script executability
for script in work/scripts/*.sh; do
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
echo "✓ Directory structure created in work/, docs/"
echo "✓ Scripts are executable at work/scripts/"
echo "✓ Documentation available at DOCUMENTATION.md"
echo "✓ $INDEX_FILES_COPIED INDEX.md files installed for self-documentation"
echo "✓ Task templates ready in work/tasks/"
echo "✓ Bug tracking initialized in work/bugs/"

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
    echo "   - work/tasks/ - Task pipeline (backlog → next → working → review → live)"
    echo "   - docs/features/ - Feature documentation"
    echo "   - work/bugs/ - Bug tracking"
    echo ""
    echo "🛠 Available Scripts:"
    echo "   - ./work/scripts/create-task.sh - Create new tasks"
    echo "   - ./work/scripts/analyze-feature-alignment.sh - Check feature/task alignment"
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

    echo "📚 Get Started Now:"
    echo ""
    echo "   Create your first task:"
    echo "   $ ./work/scripts/create-task.sh \"Your first task description\""
    echo ""
    echo "   Or check feature alignment:"
    echo "   $ ./work/scripts/analyze-feature-alignment.sh"
    echo ""
    echo "To update 5DayDocs in the future, run this setup script again."
fi

if [ "$VALIDATION_PASSED" = true ]; then
    echo ""
    echo "🚀 5DayDocs is ready! Try creating a task now:"
    echo "   ./work/scripts/create-task.sh \"Build user authentication\""
fi

echo ""
