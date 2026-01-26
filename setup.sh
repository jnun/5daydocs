#!/bin/bash
# setup.sh - 5DayDocs unified installer and updater
# Usage: ./setup.sh
#   Prompts for target project path and sets up/updates 5DayDocs structure there
#
# This script handles both fresh installations and updates with version migrations.
# Templates: Workflow templates are stored in templates/workflows/

set -e  # Exit on error

# Get the 5daydocs source directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIVEDAY_SOURCE_DIR="$SCRIPT_DIR"

# Read current version from source
if [ -f "$FIVEDAY_SOURCE_DIR/VERSION" ]; then
    CURRENT_VERSION=$(cat "$FIVEDAY_SOURCE_DIR/VERSION")
else
    echo "Warning: VERSION file not found, defaulting to 1.0.0"
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
TARGET_PATH="$(cd "$TARGET_PATH" 2>/dev/null && pwd)" || {
    echo "Error: Path '$TARGET_PATH' does not exist or is not accessible."
    exit 1
}

echo ""
echo "Target directory: $TARGET_PATH"
echo ""

# Change to target directory
cd "$TARGET_PATH"

# Self-targeting detection
if [ "$TARGET_PATH" = "$FIVEDAY_SOURCE_DIR" ]; then
    echo "Note: Target is the 5daydocs source directory."
    echo "   This will sync src/ to docs/ for development/testing."
    echo ""
fi

# ============================================================================
# DETECT INSTALLATION STATE
# ============================================================================

INSTALLED_VERSION=""
UPDATE_MODE=false

# Check if 5DayDocs is already installed
if [ -f "docs/STATE.md" ]; then
    # Extract installed version
    INSTALLED_VERSION=$(grep '^\*\*5DAY_VERSION\*\*:' docs/STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | head -1)

    # Fallback if no version found
    if [ -z "$INSTALLED_VERSION" ]; then
        INSTALLED_VERSION="0.0.0"
    fi

    UPDATE_MODE=true
    echo "Existing 5DayDocs installation detected (version $INSTALLED_VERSION)"
    echo "This will update to version $CURRENT_VERSION"
    echo ""
elif [ -d "docs/tasks" ] || [ -d "work/tasks" ] || [ -d "docs/work/tasks" ]; then
    # Legacy structure detected
    INSTALLED_VERSION="0.0.0"
    UPDATE_MODE=true
    echo "Legacy 5DayDocs structure detected"
    echo "This will migrate to the current structure"
    echo ""
elif [ -f "DOCUMENTATION.md" ]; then
    # Partial installation
    INSTALLED_VERSION="0.0.0"
    UPDATE_MODE=true
fi

if $UPDATE_MODE; then
    echo "Do you want to continue with the update? (y/n)"
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Update cancelled."
        exit 0
    fi
fi

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Safely create directories
safe_mkdir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "  Created: $dir"
    fi
}

# Ensure task pipeline folders exist
ensure_task_folders() {
    safe_mkdir "docs/tasks/backlog"
    safe_mkdir "docs/tasks/next"
    safe_mkdir "docs/tasks/working"
    safe_mkdir "docs/tasks/review"
    safe_mkdir "docs/tasks/live"
}

# ============================================================================
# VERSION MIGRATIONS (only run in update mode)
# ============================================================================

if $UPDATE_MODE; then
    echo ""
    echo "Running version migrations..."

    # Migration from pre-0.1.0 (work/ at root)
    if [[ "$INSTALLED_VERSION" < "0.1.0" ]]; then
        echo ""
        echo "Migrating from pre-0.1.0 structure..."

        if [ -d "work" ]; then
            if [ ! -d "docs/work" ]; then
                mkdir -p docs
                mv work docs/
                echo "  Moved work/ to docs/work/"
            else
                echo "  Both work/ and docs/work/ exist - backing up and merging..."
                mv work work.backup
                echo "  Moved old work/ to work.backup/"
            fi

            if [ -f "docs/work/STATE.md" ]; then
                mv docs/work/STATE.md docs/
                echo "  Moved STATE.md to docs/"
            fi
        fi

        ensure_task_folders

        # Move loose task files to backlog
        if [ -d "docs/tasks" ]; then
            for file in docs/tasks/*.md; do
                if [ -f "$file" ]; then
                    basename=$(basename "$file")
                    if [[ "$basename" != "INDEX.md" ]] && [[ "$basename" != "TEMPLATE"* ]]; then
                        mv "$file" "docs/tasks/backlog/" 2>/dev/null || true
                        echo "  Moved $basename to backlog/"
                    fi
                fi
            done
        fi

        INSTALLED_VERSION="0.1.0"
    fi

    # Migration from 0.1.0 to 1.0.0
    if [[ "$INSTALLED_VERSION" < "1.0.0" ]]; then
        echo ""
        echo "Migrating from 0.1.0 to 1.0.0..."

        ensure_task_folders
        safe_mkdir "docs/bugs"
        safe_mkdir "docs/bugs/archived"
        safe_mkdir "docs/5day/scripts"
        safe_mkdir "docs/5day/ai"
        safe_mkdir "docs/designs"
        safe_mkdir "docs/examples"
        safe_mkdir "docs/data"
        safe_mkdir "docs/features"
        safe_mkdir "docs/guides"

        find docs -type d -empty -exec touch {}/.gitkeep \; 2>/dev/null || true

        INSTALLED_VERSION="1.0.0"
    fi

    # Migration from 1.x to 2.0.0 - Flatten docs/work/ hierarchy
    if [[ "$INSTALLED_VERSION" < "2.0.0" ]]; then
        if [ -d "docs/work" ]; then
            echo ""
            echo "================================================"
            echo "  Migrating to 2.0.0 - Structure Simplification"
            echo "================================================"
            echo ""
            echo "Flattening directory structure:"
            echo "  docs/work/tasks/ -> docs/tasks/"
            echo "  docs/work/bugs/ -> docs/bugs/"
            echo "  docs/work/scripts/ -> docs/5day/scripts/"
            echo ""

            BACKUP_DIR="docs/work-backup-$(date +%Y%m%d-%H%M%S)"
            cp -R "docs/work" "$BACKUP_DIR"
            echo "  Backup created at $BACKUP_DIR"

            # Migrate directories
            for subdir in tasks bugs designs examples data; do
                if [ -d "docs/work/$subdir" ]; then
                    if [ -d "docs/$subdir" ]; then
                        cp -R "docs/work/$subdir/." "docs/$subdir/"
                    else
                        mv "docs/work/$subdir" "docs/$subdir"
                    fi
                    echo "  Migrated docs/work/$subdir -> docs/$subdir"
                fi
            done

            # Special handling for scripts -> 5day/scripts
            if [ -d "docs/work/scripts" ]; then
                mkdir -p "docs/5day/scripts"
                cp -R "docs/work/scripts/." "docs/5day/scripts/"
                echo "  Migrated docs/work/scripts -> docs/5day/scripts"
            fi

            # Move platform config
            if [ -f "docs/work/.platform-config" ]; then
                mv "docs/work/.platform-config" "docs/.platform-config"
            fi

            # Clean up
            rm -rf "docs/work"
            echo "  Removed docs/work/ directory"
        fi

        INSTALLED_VERSION="2.0.0"
    fi

    # Migration from 2.0.0 to 2.1.0 - Framework namespace
    if [[ "$INSTALLED_VERSION" < "2.1.0" ]]; then
        echo ""
        echo "Migrating to 2.1.0 - Framework namespace..."

        mkdir -p "docs/5day/scripts"
        mkdir -p "docs/5day/ai"

        # Move scripts from docs/scripts/ if it exists
        if [ -d "docs/scripts" ]; then
            for script in docs/scripts/*.sh; do
                if [ -f "$script" ]; then
                    mv "$script" "docs/5day/scripts/"
                    echo "  Moved $(basename "$script") -> docs/5day/scripts/"
                fi
            done
        fi

        INSTALLED_VERSION="2.1.0"
    fi

    echo ""
    echo "Migrations complete."
fi

# ============================================================================
# PLATFORM CONFIGURATION
# ============================================================================

# Only ask for platform selection on fresh install
if ! $UPDATE_MODE; then
    echo "Select your platform configuration:"
    echo "1) GitHub with GitHub Issues (default)"
    echo "2) GitHub with Jira (coming soon)"
    echo "3) Bitbucket with Jira (coming soon)"
    echo ""
    echo "Enter your choice (1-3, or press Enter for default):"
    read -r PLATFORM_CHOICE

    case "$PLATFORM_CHOICE" in
        2)
            PLATFORM="github-jira"
            echo "Selected: GitHub with Jira (Note: Integration not fully implemented yet)"
            ;;
        3)
            PLATFORM="bitbucket-jira"
            echo "Selected: Bitbucket with Jira (Note: Integration not fully implemented yet)"
            ;;
        *)
            PLATFORM="github-issues"
            echo "Selected: GitHub with GitHub Issues"
            ;;
    esac
    echo ""
else
    # Read existing platform config
    if [ -f "docs/.platform-config" ]; then
        PLATFORM=$(grep '^PLATFORM=' docs/.platform-config | cut -d'"' -f2)
    else
        PLATFORM="github-issues"
    fi
fi

# ============================================================================
# CREATE DIRECTORY STRUCTURE
# ============================================================================

echo "Creating directory structure..."

# Task pipeline
ensure_task_folders

# Other directories
safe_mkdir "docs/bugs/archived"
safe_mkdir "docs/designs"
safe_mkdir "docs/examples"
safe_mkdir "docs/data"
safe_mkdir "docs/5day/scripts"
safe_mkdir "docs/5day/ai"
safe_mkdir "docs/features"
safe_mkdir "docs/guides"
safe_mkdir "docs/tests"

# Platform-specific directories
if [ "$PLATFORM" != "bitbucket-jira" ]; then
    safe_mkdir ".github/workflows"
    safe_mkdir ".github/ISSUE_TEMPLATE"
fi

# Add .gitkeep files to preserve empty directories
find docs -type d -empty -exec touch {}/.gitkeep \; 2>/dev/null || true
echo "  Added .gitkeep files to empty directories"

# ============================================================================
# STATE.MD MANAGEMENT
# ============================================================================

echo ""
echo "Managing state tracking..."

if [ ! -f "docs/STATE.md" ]; then
    # Create new STATE.md
    cat > docs/STATE.md << STATE_EOF
# docs/STATE.md

**Last Updated**: $(date +%Y-%m-%d)
**5DAY_VERSION**: $CURRENT_VERSION
**5DAY_TASK_ID**: 0
**5DAY_BUG_ID**: 0
**SYNC_ALL_TASKS**: false
STATE_EOF
    echo "  Created docs/STATE.md"
else
    # Reconcile STATE.md - preserve user data, update version
    EXISTING_DATE=$(grep '^\*\*Last Updated\*\*:' docs/STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | head -1)
    EXISTING_TASK_ID=$(grep '^\*\*5DAY_TASK_ID\*\*:' docs/STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | grep -o '^[0-9]*' | head -1)
    EXISTING_BUG_ID=$(grep '^\*\*5DAY_BUG_ID\*\*:' docs/STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | grep -o '^[0-9]*' | head -1)
    EXISTING_SYNC_FLAG=$(grep '^\*\*SYNC_ALL_TASKS\*\*:' docs/STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | head -1)

    # Validate and set defaults
    [[ "$EXISTING_TASK_ID" =~ ^[0-9]+$ ]] || EXISTING_TASK_ID=0
    [[ "$EXISTING_BUG_ID" =~ ^[0-9]+$ ]] || EXISTING_BUG_ID=0
    [[ "$EXISTING_SYNC_FLAG" == "true" || "$EXISTING_SYNC_FLAG" == "false" ]] || EXISTING_SYNC_FLAG="false"

    cat > docs/STATE.md << STATE_EOF
# docs/STATE.md

**Last Updated**: $(date +%Y-%m-%d)
**5DAY_VERSION**: $CURRENT_VERSION
**5DAY_TASK_ID**: $EXISTING_TASK_ID
**5DAY_BUG_ID**: $EXISTING_BUG_ID
**SYNC_ALL_TASKS**: $EXISTING_SYNC_FLAG
STATE_EOF
    echo "  Updated docs/STATE.md (preserved IDs: task=$EXISTING_TASK_ID, bug=$EXISTING_BUG_ID)"
fi

# Store platform configuration
cat > docs/.platform-config << CONFIG_EOF
# 5DayDocs Platform Configuration
# Generated: $(date +%Y-%m-%d)
PLATFORM="$PLATFORM"
CONFIG_EOF

# ============================================================================
# COPY DOCUMENTATION FILES
# ============================================================================

echo ""
echo "Setting up documentation files..."

# Track counters
FILES_COPIED=0

# Copy README.md only if project has none
if [ ! -f "README.md" ]; then
    if [ -f "$FIVEDAY_SOURCE_DIR/src/README.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/src/README.md" README.md
        echo "  Created README.md"
        ((FILES_COPIED++))
    fi
fi

# Copy DOCUMENTATION.md
if [ ! -f "DOCUMENTATION.md" ] || $UPDATE_MODE; then
    if [ -f "$FIVEDAY_SOURCE_DIR/src/DOCUMENTATION.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/src/DOCUMENTATION.md" DOCUMENTATION.md
        echo "  Copied DOCUMENTATION.md"
        ((FILES_COPIED++))
    fi
fi

# Copy template files
if [ -f "$FIVEDAY_SOURCE_DIR/src/templates/project/TEMPLATE-task.md" ]; then
    cp "$FIVEDAY_SOURCE_DIR/src/templates/project/TEMPLATE-task.md" docs/tasks/
    echo "  Copied task template"
    ((FILES_COPIED++))
fi

if [ -f "$FIVEDAY_SOURCE_DIR/src/templates/project/TEMPLATE-bug.md" ]; then
    cp "$FIVEDAY_SOURCE_DIR/src/templates/project/TEMPLATE-bug.md" docs/bugs/
    echo "  Copied bug template"
    ((FILES_COPIED++))
fi

if [ -f "$FIVEDAY_SOURCE_DIR/src/templates/project/TEMPLATE-feature.md" ]; then
    cp "$FIVEDAY_SOURCE_DIR/src/templates/project/TEMPLATE-feature.md" docs/features/
    echo "  Copied feature template"
    ((FILES_COPIED++))
fi

# ============================================================================
# COPY SCRIPTS
# ============================================================================

echo ""
echo "Setting up automation scripts..."

# Copy all scripts from src/docs/5day/scripts/
if [ -d "$FIVEDAY_SOURCE_DIR/src/docs/5day/scripts" ]; then
    for script in "$FIVEDAY_SOURCE_DIR/src/docs/5day/scripts"/*.sh; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            cp -f "$script" "docs/5day/scripts/$script_name"
            chmod +x "docs/5day/scripts/$script_name"
            echo "  Copied $script_name"
            ((FILES_COPIED++))
        fi
    done
fi

# Copy AI context files
if [ -d "$FIVEDAY_SOURCE_DIR/src/docs/5day/ai" ]; then
    for ai_file in "$FIVEDAY_SOURCE_DIR/src/docs/5day/ai"/*.md; do
        if [ -f "$ai_file" ]; then
            ai_name=$(basename "$ai_file")
            cp -f "$ai_file" "docs/5day/ai/$ai_name"
            echo "  Copied $ai_name"
            ((FILES_COPIED++))
        fi
    done
fi

# Copy 5day.sh to project root (main CLI interface)
if [ -f "$FIVEDAY_SOURCE_DIR/src/docs/5day/scripts/5day.sh" ]; then
    cp -f "$FIVEDAY_SOURCE_DIR/src/docs/5day/scripts/5day.sh" ./5day.sh
    chmod +x ./5day.sh
    echo "  Copied 5day.sh to project root"
    ((FILES_COPIED++))
fi

# ============================================================================
# COPY INDEX.MD FILES
# ============================================================================

echo ""
echo "Setting up INDEX.md documentation files..."

INDEX_FILES=(
    "docs/tasks/INDEX.md"
    "docs/bugs/INDEX.md"
    "docs/5day/scripts/INDEX.md"
    "docs/designs/INDEX.md"
    "docs/examples/INDEX.md"
    "docs/data/INDEX.md"
    "docs/INDEX.md"
    "docs/features/INDEX.md"
    "docs/guides/INDEX.md"
)

for index_file in "${INDEX_FILES[@]}"; do
    if [ -f "$FIVEDAY_SOURCE_DIR/$index_file" ]; then
        # Skip if source and target are the same file (dogfood mode)
        if [ "$FIVEDAY_SOURCE_DIR/$index_file" -ef "$TARGET_PATH/$index_file" ] 2>/dev/null; then
            continue
        fi

        mkdir -p "$(dirname "$index_file")"
        cp -f "$FIVEDAY_SOURCE_DIR/$index_file" "$index_file"
        echo "  Copied $index_file"
        ((FILES_COPIED++))
    fi
done

# ============================================================================
# GITHUB/BITBUCKET WORKFLOWS
# ============================================================================

if [ "$PLATFORM" != "bitbucket-jira" ]; then
    echo ""
    echo "Setting up GitHub Actions..."

    if [ -f "$FIVEDAY_SOURCE_DIR/templates/workflows/github/sync-tasks-to-issues.yml" ]; then
        cp "$FIVEDAY_SOURCE_DIR/templates/workflows/github/sync-tasks-to-issues.yml" .github/workflows/
        echo "  Copied sync-tasks-to-issues.yml"
    fi

    # Copy issue and PR templates
    if [ -f "$FIVEDAY_SOURCE_DIR/templates/github/ISSUE_TEMPLATE/bug_report.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/templates/github/ISSUE_TEMPLATE/bug_report.md" .github/ISSUE_TEMPLATE/
        echo "  Copied bug report template"
    fi

    if [ -f "$FIVEDAY_SOURCE_DIR/templates/github/ISSUE_TEMPLATE/feature_request.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/templates/github/ISSUE_TEMPLATE/feature_request.md" .github/ISSUE_TEMPLATE/
        echo "  Copied feature request template"
    fi

    if [ -f "$FIVEDAY_SOURCE_DIR/templates/github/ISSUE_TEMPLATE/task.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/templates/github/ISSUE_TEMPLATE/task.md" .github/ISSUE_TEMPLATE/
        echo "  Copied task template"
    fi

    if [ -f "$FIVEDAY_SOURCE_DIR/templates/github/pull_request_template.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/templates/github/pull_request_template.md" .github/
        echo "  Copied pull request template"
    fi
else
    echo ""
    echo "Setting up Bitbucket Pipelines..."

    if [ -f "$FIVEDAY_SOURCE_DIR/templates/bitbucket-pipelines.yml" ]; then
        if [ ! -f "bitbucket-pipelines.yml" ] || $UPDATE_MODE; then
            cp "$FIVEDAY_SOURCE_DIR/templates/bitbucket-pipelines.yml" bitbucket-pipelines.yml
            echo "  Copied bitbucket-pipelines.yml"
        fi
    fi
fi

# ============================================================================
# HANDLE .GITIGNORE
# ============================================================================

if ! $UPDATE_MODE; then
    echo ""
    echo "Would you like to add 5DayDocs recommended .gitignore entries? (y/n)"
    read -r GITIGNORE_CHOICE

    if [[ "$GITIGNORE_CHOICE" =~ ^[Yy]$ ]]; then
        GITIGNORE_CONTENT="# OS Files
.DS_Store
Thumbs.db
desktop.ini

# Editor Files
.vscode/
.idea/
*.swp
*.swo
*~

# Temporary Files
*.tmp
*.temp
*.bak
*.log

# Environment and secrets
.env
.env.*
*.pem
*.key
secrets/

# Local data
docs/data/*.csv
docs/data/*.json
docs/data/*.db

# Design files (large binaries)
docs/designs/*.psd
docs/designs/*.sketch
docs/designs/*.fig"

        if [ ! -f ".gitignore" ]; then
            echo "$GITIGNORE_CONTENT" > .gitignore
            echo "  Created .gitignore"
        else
            echo "" >> .gitignore
            echo "# === 5DayDocs Recommended Entries ===" >> .gitignore
            echo "$GITIGNORE_CONTENT" >> .gitignore
            echo "  Appended to .gitignore"
        fi
    fi
fi

# ============================================================================
# CLEANUP LEGACY FILES
# ============================================================================

# Check for legacy INDEX.md files in task subfolders
LEGACY_INDEX_FILES=""
for folder in backlog next working review live; do
    if [ -f "docs/tasks/$folder/INDEX.md" ]; then
        LEGACY_INDEX_FILES="$LEGACY_INDEX_FILES docs/tasks/$folder/INDEX.md"
    fi
done

if [ -n "$LEGACY_INDEX_FILES" ]; then
    echo ""
    echo "Legacy INDEX.md files detected in task subfolders."
    echo "These are no longer used. Consider deleting:"
    for f in $LEGACY_INDEX_FILES; do
        echo "  rm $f"
    done
fi

# ============================================================================
# VALIDATION
# ============================================================================

echo ""
echo "Running validation checks..."
VALIDATION_PASSED=true

# Check required directories
for dir in docs/tasks/backlog docs/tasks/next docs/tasks/working docs/tasks/review docs/tasks/live docs/bugs docs/5day/scripts docs/features docs/guides; do
    if [ ! -d "$dir" ]; then
        VALIDATION_PASSED=false
        echo "  Missing directory: $dir"
    fi
done

# Check required files
for file in docs/STATE.md DOCUMENTATION.md; do
    if [ ! -f "$file" ]; then
        VALIDATION_PASSED=false
        echo "  Missing file: $file"
    fi
done

# Check script executability
for script in docs/5day/scripts/*.sh; do
    if [ -f "$script" ] && [ ! -x "$script" ]; then
        chmod +x "$script"
    fi
done

if [ -f "./5day.sh" ] && [ ! -x "./5day.sh" ]; then
    chmod +x ./5day.sh
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "================================================"
if [ "$VALIDATION_PASSED" = true ]; then
    echo "  Setup Complete - All Checks Passed!"
else
    echo "  Setup Complete - With Issues"
fi
echo "================================================"
echo ""

if $UPDATE_MODE; then
    echo "5DayDocs updated to version $CURRENT_VERSION"
    echo ""
    echo "Changes:"
    echo "  - Scripts synced from source"
    echo "  - STATE.md reconciled"
    echo "  - Templates updated"
else
    echo "5DayDocs installed to: $TARGET_PATH"
    echo "Platform: $PLATFORM"
    echo ""
    echo "Directory structure created in docs/"
    echo "Scripts available at docs/5day/scripts/"
    echo "Documentation at DOCUMENTATION.md"
    echo ""
    echo "Get started:"
    echo "  ./5day.sh help            # Show available commands"
    echo "  ./5day.sh newtask \"...\"   # Create a task"
    echo "  ./5day.sh status          # Show task status"
fi

if [ "$VALIDATION_PASSED" = true ]; then
    echo ""
    echo "5DayDocs is ready! Try:"
    echo "  ./5day.sh newtask \"Build user authentication\""
fi

echo ""
