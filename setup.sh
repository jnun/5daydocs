#!/bin/bash
# setup.sh - 5DayDocs unified installer and updater
# Usage: ./setup.sh
#   Prompts for target project path and sets up/updates 5DayDocs structure there
#
# This script handles both fresh installations and updates with version migrations.
# Templates: All distributed templates live under src/templates/.

# Note: We don't use set -e to allow graceful error handling

# Get the 5daydocs source directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIVEDAY_SOURCE_DIR="$SCRIPT_DIR"

# ============================================================================
# MESSAGE SYSTEM - Consistent, color-coded output
# ============================================================================

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
fi

# Track errors for final summary
ERRORS=()
WARNINGS=()

# Message functions
msg_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

msg_success() {
    echo -e "${GREEN}✓${NC} $1"
}

msg_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARNINGS+=("$1")
}

msg_error() {
    echo -e "${RED}✗${NC} $1"
    ERRORS+=("$1")
}

msg_step() {
    echo -e "  ${CYAN}→${NC} $1"
}

msg_header() {
    echo ""
    echo -e "${BOLD}$1${NC}"
}

# Safe file copy with error handling
# Usage: safe_copy "source" "dest" "description"
safe_copy() {
    local src="$1"
    local dest="$2"
    local desc="${3:-$(basename "$src")}"

    if [ ! -f "$src" ]; then
        msg_warning "Source not found: $desc"
        return 1
    fi

    # Check if destination exists and is writable
    if [ -f "$dest" ] && [ ! -w "$dest" ]; then
        msg_error "Cannot write to $dest (permission denied)"
        msg_step "Fix with: chmod u+w \"$dest\""
        return 1
    fi

    # Check if destination directory is writable
    local dest_dir
    dest_dir="$(dirname "$dest")"
    if [ ! -w "$dest_dir" ]; then
        msg_error "Cannot write to directory $dest_dir (permission denied)"
        return 1
    fi

    if cp -f "$src" "$dest" 2>/dev/null; then
        msg_step "Copied $desc"
        return 0
    else
        msg_error "Failed to copy $desc"
        return 1
    fi
}

# Safe directory creation
# Usage: safe_mkdir "path"
safe_mkdir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        return 0
    fi

    if mkdir -p "$dir" 2>/dev/null; then
        msg_step "Created: $dir"
        return 0
    else
        msg_error "Failed to create directory: $dir"
        return 1
    fi
}

# Read current version from source
if [ -f "$FIVEDAY_SOURCE_DIR/src/VERSION" ]; then
    CURRENT_VERSION=$(cat "$FIVEDAY_SOURCE_DIR/src/VERSION")
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
if [ -z "$TARGET_PATH" ]; then
    msg_error "No path provided"
    exit 1
fi

if [ ! -d "$TARGET_PATH" ]; then
    msg_error "Path does not exist: $TARGET_PATH"
    msg_step "Create the directory first, then run setup again"
    exit 1
fi

TARGET_PATH="$(cd "$TARGET_PATH" 2>/dev/null && pwd)" || {
    msg_error "Cannot access path: $TARGET_PATH"
    msg_step "Check that you have read permissions for this directory"
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
if [ -f "docs/5day/DOC_STATE.md" ]; then
    # 2.2.0+ install
    INSTALLED_VERSION=$(grep '^\*\*5DAY_VERSION\*\*:' docs/5day/DOC_STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | head -1)

    if [ -z "$INSTALLED_VERSION" ]; then
        INSTALLED_VERSION="0.0.0"
    fi

    UPDATE_MODE=true
    echo "Existing 5DayDocs installation detected (version $INSTALLED_VERSION)"
    echo "This will update to version $CURRENT_VERSION"
    echo ""
elif [ -f "docs/STATE.md" ]; then
    # Pre-2.2.0 install — STATE.md still at old location, will be migrated
    INSTALLED_VERSION=$(grep '^\*\*5DAY_VERSION\*\*:' docs/STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | head -1)

    if [ -z "$INSTALLED_VERSION" ]; then
        INSTALLED_VERSION="0.0.0"
    fi

    UPDATE_MODE=true
    echo "Existing 5DayDocs installation detected (version $INSTALLED_VERSION, pre-2.2.0 layout)"
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

# Ensure task pipeline folders exist
ensure_task_folders() {
    safe_mkdir "docs/tasks/backlog"
    safe_mkdir "docs/tasks/next"
    safe_mkdir "docs/tasks/working"
    safe_mkdir "docs/tasks/blocked"
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

    # Migration from 2.1.x to 2.2.0 - Move STATE.md into docs/5day/ as DOC_STATE.md
    if [[ "$INSTALLED_VERSION" < "2.2.0" ]]; then
        if [ -f "docs/STATE.md" ] && [ ! -f "docs/5day/DOC_STATE.md" ]; then
            echo ""
            echo "Migrating to 2.2.0 - Moving STATE.md to docs/5day/DOC_STATE.md..."
            mkdir -p "docs/5day"
            mv docs/STATE.md docs/5day/DOC_STATE.md
            echo "  Moved docs/STATE.md -> docs/5day/DOC_STATE.md"
        fi

        INSTALLED_VERSION="2.2.0"
    fi

    echo ""
    echo "Migrations complete."
fi

# ============================================================================
# PLATFORM CONFIGURATION
# ============================================================================

# Determine current platform (used as default during updates)
CURRENT_PLATFORM=""
if $UPDATE_MODE && [ -f "docs/.platform-config" ]; then
    CURRENT_PLATFORM=$(grep '^PLATFORM=' docs/.platform-config | cut -d'"' -f2)
fi

if $UPDATE_MODE; then
    echo "Select your platform configuration:"
    echo "  Current: ${CURRENT_PLATFORM:-github-issues (default)}"
else
    echo "Select your platform configuration:"
fi
echo "1) GitHub with GitHub Issues (default)"
echo "2) GitHub with Jira (coming soon)"
echo "3) Bitbucket with Jira (coming soon)"
echo "4) No sync — opt out of GitHub/Jira issue tracking"
echo ""
if $UPDATE_MODE; then
    echo "Enter your choice (1-4, or press Enter to keep current):"
else
    echo "Enter your choice (1-4, or press Enter for default):"
fi
read -r PLATFORM_CHOICE

case "$PLATFORM_CHOICE" in
    1)
        PLATFORM="github-issues"
        echo "Selected: GitHub with GitHub Issues"
        ;;
    2)
        PLATFORM="github-jira"
        echo "Selected: GitHub with Jira (Note: Integration not fully implemented yet)"
        ;;
    3)
        PLATFORM="bitbucket-jira"
        echo "Selected: Bitbucket with Jira (Note: Integration not fully implemented yet)"
        ;;
    4)
        PLATFORM="none"
        echo "Selected: No sync — opting out of issue tracker integration"
        ;;
    "")
        if $UPDATE_MODE && [ -n "$CURRENT_PLATFORM" ]; then
            PLATFORM="$CURRENT_PLATFORM"
            echo "Keeping current: $PLATFORM"
        else
            PLATFORM="github-issues"
            echo "Selected: GitHub with GitHub Issues"
        fi
        ;;
    *)
        PLATFORM="github-issues"
        echo "Selected: GitHub with GitHub Issues"
        ;;
esac
echo ""

# ============================================================================
# CREATE DIRECTORY STRUCTURE
# ============================================================================

msg_header "Creating directory structure..."

# Task pipeline
ensure_task_folders

# Other directories
safe_mkdir "docs/ideas"
safe_mkdir "docs/bugs/archived"
safe_mkdir "docs/designs"
safe_mkdir "docs/examples"
safe_mkdir "docs/data"
safe_mkdir "docs/5day/scripts"
safe_mkdir "docs/5day/ai"
safe_mkdir "docs/features"
safe_mkdir "docs/guides"
safe_mkdir "docs/tests"
safe_mkdir "docs/tmp"

# Platform-specific directories
if [ "$PLATFORM" != "bitbucket-jira" ] && [ "$PLATFORM" != "none" ]; then
    safe_mkdir ".github/workflows"
    safe_mkdir ".github/ISSUE_TEMPLATE"
fi

# Add .gitkeep files to preserve empty directories
find docs -type d -empty -exec touch {}/.gitkeep \; 2>/dev/null || true
msg_step "Added .gitkeep files to empty directories"

# ============================================================================
# STATE.MD MANAGEMENT
# ============================================================================

msg_header "Managing state tracking..."

safe_mkdir "docs/5day"

if [ ! -f "docs/5day/DOC_STATE.md" ]; then
    # Create new DOC_STATE.md
    if cat > docs/5day/DOC_STATE.md << STATE_EOF
# 5DayDocs Documentation State

Part of the 5daydocs documentation system, not source code for the host project.
Managed by scripts in \`docs/5day/scripts/\` and by \`setup.sh\`. Safe to edit by hand
if you need to fix a counter — the field lines below are what scripts parse.

Fields:
- \`5DAY_VERSION\`   — installed file-structure version; \`setup.sh\` reads this on upgrade to decide which migrations to run
- \`5DAY_TASK_ID\`   — highest task ID used; next task = this + 1
- \`5DAY_BUG_ID\`    — highest bug ID used; next bug = this + 1
- \`SYNC_ALL_TASKS\` — GitHub Issues sync flag (managed by \`sync.sh\`)
- \`Last Updated\`   — ISO date; bump when you change a field

---

**Last Updated**: $(date +%Y-%m-%d)
**5DAY_VERSION**: $CURRENT_VERSION
**5DAY_TASK_ID**: 0
**5DAY_BUG_ID**: 0
**SYNC_ALL_TASKS**: false
STATE_EOF
    then
        msg_step "Created docs/5day/DOC_STATE.md"
    else
        msg_error "Failed to create docs/5day/DOC_STATE.md"
    fi
else
    # Reconcile DOC_STATE.md - preserve user data, update version
    EXISTING_TASK_ID=$(grep '^\*\*5DAY_TASK_ID\*\*:' docs/5day/DOC_STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | grep -o '^[0-9]*' | head -1)
    EXISTING_BUG_ID=$(grep '^\*\*5DAY_BUG_ID\*\*:' docs/5day/DOC_STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | grep -o '^[0-9]*' | head -1)
    EXISTING_SYNC_FLAG=$(grep '^\*\*SYNC_ALL_TASKS\*\*:' docs/5day/DOC_STATE.md 2>/dev/null | sed 's/.*:[[:space:]]*//' | head -1)

    # Validate and set defaults
    [[ "$EXISTING_TASK_ID" =~ ^[0-9]+$ ]] || EXISTING_TASK_ID=0
    [[ "$EXISTING_BUG_ID" =~ ^[0-9]+$ ]] || EXISTING_BUG_ID=0
    [[ "$EXISTING_SYNC_FLAG" == "true" || "$EXISTING_SYNC_FLAG" == "false" ]] || EXISTING_SYNC_FLAG="false"

    if cat > docs/5day/DOC_STATE.md << STATE_EOF
# 5DayDocs Documentation State

Part of the 5daydocs documentation system, not source code for the host project.
Managed by scripts in \`docs/5day/scripts/\` and by \`setup.sh\`. Safe to edit by hand
if you need to fix a counter — the field lines below are what scripts parse.

Fields:
- \`5DAY_VERSION\`   — installed file-structure version; \`setup.sh\` reads this on upgrade to decide which migrations to run
- \`5DAY_TASK_ID\`   — highest task ID used; next task = this + 1
- \`5DAY_BUG_ID\`    — highest bug ID used; next bug = this + 1
- \`SYNC_ALL_TASKS\` — GitHub Issues sync flag (managed by \`sync.sh\`)
- \`Last Updated\`   — ISO date; bump when you change a field

---

**Last Updated**: $(date +%Y-%m-%d)
**5DAY_VERSION**: $CURRENT_VERSION
**5DAY_TASK_ID**: $EXISTING_TASK_ID
**5DAY_BUG_ID**: $EXISTING_BUG_ID
**SYNC_ALL_TASKS**: $EXISTING_SYNC_FLAG
STATE_EOF
    then
        msg_step "Updated docs/5day/DOC_STATE.md (preserved IDs: task=$EXISTING_TASK_ID, bug=$EXISTING_BUG_ID)"
    else
        msg_error "Failed to update docs/5day/DOC_STATE.md"
    fi
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

msg_header "Setting up documentation files..."

# Track counters
FILES_COPIED=0

# README.md — we don't ship one (the user owns theirs). If a README exists,
# prepend a pointer to DOCUMENTATION.md so readers know where the project
# docs live. Same pattern as the AI instruction files below.
README_POINTER='> **Project documentation** → see [`DOCUMENTATION.md`](DOCUMENTATION.md) (managed by [5DayDocs](https://github.com/jnun/5daydocs))'

# Strict yes/no prompt — loops until the user gives an unambiguous answer.
# Sets the variable named in $1 to "yes" or "no". $2 is the prompt text.
# On EOF (closed stdin, e.g. piped/CI install) defaults to "no" so we never
# mutate user files without an explicit yes, and never hang.
prompt_yes_no() {
    local __varname="$1"
    local __prompt="$2"
    local __answer
    while true; do
        echo "$__prompt (yes/no)"
        if ! read -r __answer; then
            echo "  (no input — defaulting to no)"
            printf -v "$__varname" "no"
            return 0
        fi
        case "$__answer" in
            [Yy]|[Yy][Ee][Ss])  printf -v "$__varname" "yes"; return 0 ;;
            [Nn]|[Nn][Oo])      printf -v "$__varname" "no";  return 0 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

if [ ! -f "README.md" ]; then
    echo ""
    prompt_yes_no README_CHOICE "No README.md found. Create one with a 5DayDocs documentation pointer?"

    if [ "$README_CHOICE" = "yes" ]; then
        if printf '%s\n' "$README_POINTER" > "README.md" 2>/dev/null; then
            msg_success "Created README.md with documentation pointer"
            ((FILES_COPIED++))
        else
            msg_error "Failed to create README.md"
        fi
    else
        msg_step "Skipped README.md creation"
    fi
else
    if grep -q "DOCUMENTATION.md" "README.md" 2>/dev/null; then
        msg_step "README.md already references DOCUMENTATION.md"
    else
        echo ""
        prompt_yes_no README_PREPEND_CHOICE "README.md exists but does not reference DOCUMENTATION.md. Prepend a 5DayDocs documentation pointer to it?"

        if [ "$README_PREPEND_CHOICE" = "yes" ]; then
            tmpfile=""
            tmpfile="$(mktemp "README.md.XXXXXX")" || tmpfile=""
            if [ -z "$tmpfile" ]; then
                msg_error "Failed to create temp file for README.md"
            else
                # Make sure a stray temp file never survives an interrupt
                # or a failed cat/mv. Cleared on successful mv below.
                trap 'rm -f "$tmpfile"' EXIT INT TERM
                if { printf '%s\n\n' "$README_POINTER"; cat "README.md"; } > "$tmpfile" 2>/dev/null \
                   && mv -f "$tmpfile" "README.md"; then
                    tmpfile=""
                    trap - EXIT INT TERM
                    msg_success "Prepended 5DayDocs documentation pointer to README.md"
                else
                    rm -f "$tmpfile"
                    tmpfile=""
                    trap - EXIT INT TERM
                    msg_error "Failed to prepend to README.md"
                fi
            fi
        else
            msg_step "Preserved README.md (no pointer added)"
        fi
    fi
fi

# Copy DOCUMENTATION.md
if [ ! -f "DOCUMENTATION.md" ] || $UPDATE_MODE; then
    if safe_copy "$FIVEDAY_SOURCE_DIR/src/DOCUMENTATION.md" "DOCUMENTATION.md" "DOCUMENTATION.md"; then
        ((FILES_COPIED++))
    fi
fi

# Copy template files
if safe_copy "$FIVEDAY_SOURCE_DIR/src/templates/project/TEMPLATE-task.md" "docs/tasks/TEMPLATE-task.md" "task template"; then
    ((FILES_COPIED++))
fi

if safe_copy "$FIVEDAY_SOURCE_DIR/src/templates/project/TEMPLATE-bug.md" "docs/bugs/TEMPLATE-bug.md" "bug template"; then
    ((FILES_COPIED++))
fi

if safe_copy "$FIVEDAY_SOURCE_DIR/src/templates/project/TEMPLATE-feature.md" "docs/features/TEMPLATE-feature.md" "feature template"; then
    ((FILES_COPIED++))
fi

if safe_copy "$FIVEDAY_SOURCE_DIR/src/templates/project/TEMPLATE-idea.md" "docs/ideas/TEMPLATE-idea.md" "idea template"; then
    ((FILES_COPIED++))
fi

# ============================================================================
# COPY 5DAY TREE (scripts, ai, theory, and any future additions)
# ============================================================================

msg_header "Setting up automation scripts and guides..."

# Mirror every file under src/docs/5day/ into the target project, recursively.
# This ensures new content categories (theory, etc.) and any nested layout
# ship automatically without requiring installer edits.
SRC_5DAY="$FIVEDAY_SOURCE_DIR/src/docs/5day"
if [ -d "$SRC_5DAY" ]; then
    while IFS= read -r -d '' src_file; do
        rel_path="${src_file#"$SRC_5DAY"/}"
        dest_path="docs/5day/$rel_path"

        # config.sh is user-territory — installed separately with skip-if-exists
        # so user edits survive updates.
        if [ "$rel_path" = "config.sh" ]; then
            continue
        fi

        safe_mkdir "$(dirname "$dest_path")"
        if safe_copy "$src_file" "$dest_path" "$dest_path"; then
            # Make shell scripts executable
            if [[ "$src_file" == *.sh ]]; then
                chmod +x "$dest_path" 2>/dev/null || msg_warning "Could not make $dest_path executable"
            fi
            ((FILES_COPIED++))
        fi
    done < <(find "$SRC_5DAY" -type f -print0)
fi

# AI CLI/model config (user-territory: skip if already present so edits survive)
if [ -f "$FIVEDAY_SOURCE_DIR/src/docs/5day/config.sh" ]; then
    if [ ! -f "docs/5day/config.sh" ]; then
        if safe_copy "$FIVEDAY_SOURCE_DIR/src/docs/5day/config.sh" "docs/5day/config.sh" "docs/5day/config.sh (AI CLI/model configuration)"; then
            ((FILES_COPIED++))
        fi
    else
        msg_step "Preserved docs/5day/config.sh (user-territory)"
    fi
fi

# Copy 5day.sh to project root (main CLI interface)
if safe_copy "$FIVEDAY_SOURCE_DIR/src/docs/5day/scripts/5day.sh" "./5day.sh" "5day.sh to project root"; then
    chmod +x ./5day.sh 2>/dev/null || msg_warning "Could not make 5day.sh executable"
    ((FILES_COPIED++))
fi

# ============================================================================
# GITHUB/BITBUCKET WORKFLOWS
# ============================================================================

if [ "$PLATFORM" = "none" ]; then
    msg_header "Skipping issue tracker integration (opted out of GitHub/Jira sync)"

    # If a previous install left the sync workflow in place, remove it so opting
    # out actually stops the sync. Issue templates and PR template are user-owned
    # GitHub conventions, so we leave those alone.
    if [ -f ".github/workflows/sync-tasks-to-issues.yml" ]; then
        if rm -f ".github/workflows/sync-tasks-to-issues.yml" 2>/dev/null; then
            msg_step "Removed .github/workflows/sync-tasks-to-issues.yml"
        else
            msg_warning "Could not remove .github/workflows/sync-tasks-to-issues.yml"
        fi
    fi
elif [ "$PLATFORM" != "bitbucket-jira" ]; then
    msg_header "Setting up GitHub Actions..."

    safe_copy "$FIVEDAY_SOURCE_DIR/src/templates/workflows/github/sync-tasks-to-issues.yml" ".github/workflows/sync-tasks-to-issues.yml" "sync-tasks-to-issues.yml"
    safe_copy "$FIVEDAY_SOURCE_DIR/src/templates/github/ISSUE_TEMPLATE/bug_report.md" ".github/ISSUE_TEMPLATE/bug_report.md" "bug report template"
    safe_copy "$FIVEDAY_SOURCE_DIR/src/templates/github/ISSUE_TEMPLATE/feature_request.md" ".github/ISSUE_TEMPLATE/feature_request.md" "feature request template"
    safe_copy "$FIVEDAY_SOURCE_DIR/src/templates/github/ISSUE_TEMPLATE/task.md" ".github/ISSUE_TEMPLATE/task.md" "task issue template"
    safe_copy "$FIVEDAY_SOURCE_DIR/src/templates/github/pull_request_template.md" ".github/pull_request_template.md" "pull request template"
else
    msg_header "Setting up Bitbucket Pipelines..."

    if [ ! -f "bitbucket-pipelines.yml" ] || $UPDATE_MODE; then
        safe_copy "$FIVEDAY_SOURCE_DIR/src/templates/workflows/bitbucket/pipelines.yml" "bitbucket-pipelines.yml" "bitbucket-pipelines.yml"
    fi
fi

# ============================================================================
# HANDLE .GITIGNORE
# ============================================================================

msg_header "Checking .gitignore..."

# Load gitignore content from template or use inline fallback
GITIGNORE_TEMPLATE="$FIVEDAY_SOURCE_DIR/src/templates/project/gitignore.template"
if [ -f "$GITIGNORE_TEMPLATE" ]; then
    GITIGNORE_CONTENT=$(cat "$GITIGNORE_TEMPLATE")
else
    # Fallback if template not found
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
fi

if [ ! -f ".gitignore" ]; then
    # No .gitignore exists
    echo ""
    echo "No .gitignore found. Would you like to create one with 5DayDocs recommended entries? (y/n)"
    read -r GITIGNORE_CHOICE

    if [[ "$GITIGNORE_CHOICE" =~ ^[Yy]$ ]]; then
        if echo "$GITIGNORE_CONTENT" > .gitignore 2>/dev/null; then
            msg_success "Created .gitignore"
        else
            msg_error "Failed to create .gitignore"
        fi
    else
        msg_step "Skipped .gitignore creation"
    fi
else
    # .gitignore exists - check if it already has 5DayDocs entries
    if grep -q "5DayDocs" .gitignore 2>/dev/null; then
        msg_step ".gitignore already contains 5DayDocs entries"
    else
        echo ""
        echo "Existing .gitignore found. Would you like to add 5DayDocs recommended entries?"
        echo "1) Prepend (add at the beginning)"
        echo "2) Append (add at the end)"
        echo "3) Skip"
        echo ""
        echo "Enter your choice (1-3):"
        read -r GITIGNORE_CHOICE

        case "$GITIGNORE_CHOICE" in
            1)
                # Prepend
                EXISTING_CONTENT=$(cat .gitignore)
                if { echo "# === 5DayDocs Recommended Entries ==="; echo "$GITIGNORE_CONTENT"; echo ""; echo "# === Project-Specific Entries ==="; echo "$EXISTING_CONTENT"; } > .gitignore 2>/dev/null; then
                    msg_success "Prepended 5DayDocs entries to .gitignore"
                else
                    msg_error "Failed to prepend to .gitignore"
                fi
                ;;
            2)
                # Append
                if { echo ""; echo "# === 5DayDocs Recommended Entries ==="; echo "$GITIGNORE_CONTENT"; } >> .gitignore 2>/dev/null; then
                    msg_success "Appended 5DayDocs entries to .gitignore"
                else
                    msg_error "Failed to append to .gitignore"
                fi
                ;;
            *)
                msg_step "Skipped .gitignore modification"
                ;;
        esac
    fi
fi

# ============================================================================
# HANDLE AI INSTRUCTION FILES
# ============================================================================

msg_header "Setting up AI instruction files..."

# Fallback content if source templates not found
AI_FALLBACK='Read `DOCUMENTATION.md` before making any changes. It is the single source of truth for how this project is organized, how tasks are managed, and how to use the 5DayDocs system.'

# setup_ai_file "source_template" "target_path" "display_name"
# - If target doesn't exist, ask to create it
# - If target exists without DOCUMENTATION.md reference, prepend automatically
# - If target already references DOCUMENTATION.md, skip
setup_ai_file() {
    local src="$1"
    local target="$2"
    local name="$3"

    # Load content from source template or use fallback
    local content
    if [ -f "$src" ]; then
        content=$(cat "$src")
    else
        content="$AI_FALLBACK"
    fi

    if [ ! -f "$target" ]; then
        echo ""
        echo "No $name found. Would you like to create one with 5DayDocs instructions? (y/n)"
        read -r AI_CHOICE

        if [[ "$AI_CHOICE" =~ ^[Yy]$ ]]; then
            # Ensure parent directory exists
            local target_dir
            target_dir="$(dirname "$target")"
            if [ "$target_dir" != "." ]; then
                safe_mkdir "$target_dir"
            fi

            if printf '%s\n' "$content" > "$target" 2>/dev/null; then
                msg_success "Created $name"
                ((FILES_COPIED++))
            else
                msg_error "Failed to create $name"
            fi
        else
            msg_step "Skipped $name"
        fi
    else
        if grep -q "DOCUMENTATION.md" "$target" 2>/dev/null; then
            msg_step "$name already references DOCUMENTATION.md"
        else
            # Use temp file to avoid clobbering target during prepend
            local tmpfile
            tmpfile="$(mktemp "${target}.XXXXXX")" || {
                msg_error "Failed to create temp file for $name"
                return 1
            }

            if { printf '%s\n' "$content"; echo ""; cat "$target"; } > "$tmpfile" 2>/dev/null; then
                mv -f "$tmpfile" "$target"
                msg_success "Prepended 5DayDocs reference to $name"
            else
                rm -f "$tmpfile"
                msg_error "Failed to prepend to $name"
            fi
        fi
    fi
}

# Claude Code
setup_ai_file "$FIVEDAY_SOURCE_DIR/src/CLAUDE.md" "CLAUDE.md" "CLAUDE.md"

# OpenAI Codex
setup_ai_file "$FIVEDAY_SOURCE_DIR/src/AGENTS.md" "AGENTS.md" "AGENTS.md"

# GitHub Copilot (only for GitHub-based projects)
if [ "$PLATFORM" != "bitbucket-jira" ] && [ "$PLATFORM" != "none" ]; then
    setup_ai_file "$FIVEDAY_SOURCE_DIR/src/copilot-instructions.md" ".github/copilot-instructions.md" ".github/copilot-instructions.md"
fi

# Cursor
setup_ai_file "$FIVEDAY_SOURCE_DIR/src/.cursorrules" ".cursorrules" ".cursorrules"

# Windsurf
setup_ai_file "$FIVEDAY_SOURCE_DIR/src/.windsurfrules" ".windsurfrules" ".windsurfrules"

# ============================================================================
# CLEANUP LEGACY FILES
# ============================================================================

# Legacy INDEX.md cleanup. Earlier versions of 5DayDocs shipped a curated set
# of INDEX.md files into docs/ as per-folder orientation pages. They turned
# out to be confusing and useless, so they were removed. Offer to delete any
# that are still sitting in the user's project from an older install.
LEGACY_INDEX_PATHS=(
    "docs/INDEX.md"
    "docs/tasks/INDEX.md"
    "docs/bugs/INDEX.md"
    "docs/features/INDEX.md"
    "docs/designs/INDEX.md"
    "docs/examples/INDEX.md"
    "docs/data/INDEX.md"
    "docs/guides/INDEX.md"
    "docs/5day/scripts/INDEX.md"
)

LEGACY_INDEX_FOUND=()
for f in "${LEGACY_INDEX_PATHS[@]}"; do
    [ -f "$f" ] && LEGACY_INDEX_FOUND+=("$f")
done

if [ ${#LEGACY_INDEX_FOUND[@]} -gt 0 ]; then
    msg_header "Legacy INDEX.md files detected"
    echo "In older versions of 5DayDocs we supported INDEX.md files, but decided"
    echo "they were confusing and useless."
    echo ""
    echo "Files to be deleted:"
    for f in "${LEGACY_INDEX_FOUND[@]}"; do
        echo "  $f"
    done
    echo ""
    echo "Do you want to remove these files from your docs/ directory? [Y]es/No"
    read -r LEGACY_INDEX_CHOICE

    if [[ -z "$LEGACY_INDEX_CHOICE" ]] || [[ "$LEGACY_INDEX_CHOICE" =~ ^[Yy] ]]; then
        for f in "${LEGACY_INDEX_FOUND[@]}"; do
            if git rm -f "$f" >/dev/null 2>&1; then
                msg_success "git rm $f"
            elif rm -f "$f" 2>/dev/null; then
                msg_success "rm $f"
            else
                msg_error "Failed to remove $f"
            fi
        done
    else
        msg_step "Skipped legacy INDEX.md cleanup"
    fi
fi

# ============================================================================
# VALIDATION
# ============================================================================

msg_header "Running validation checks..."
VALIDATION_PASSED=true

# Check required directories
for dir in docs/tasks/backlog docs/tasks/next docs/tasks/working docs/tasks/blocked docs/tasks/review docs/tasks/live docs/bugs docs/5day/scripts docs/features docs/guides; do
    if [ ! -d "$dir" ]; then
        VALIDATION_PASSED=false
        msg_error "Missing directory: $dir"
    fi
done

# Check required files
for file in docs/5day/DOC_STATE.md DOCUMENTATION.md; do
    if [ ! -f "$file" ]; then
        VALIDATION_PASSED=false
        msg_error "Missing file: $file"
    fi
done

# Check script executability
for script in docs/5day/scripts/*.sh; do
    if [ -f "$script" ] && [ ! -x "$script" ]; then
        chmod +x "$script" 2>/dev/null || msg_warning "Could not make $script executable"
    fi
done

if [ -f "./5day.sh" ] && [ ! -x "./5day.sh" ]; then
    chmod +x ./5day.sh 2>/dev/null || msg_warning "Could not make ./5day.sh executable"
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "================================================"
if [ "$VALIDATION_PASSED" = true ] && [ ${#ERRORS[@]} -eq 0 ]; then
    echo -e "  ${GREEN}Setup Complete - All Checks Passed!${NC}"
elif [ ${#ERRORS[@]} -gt 0 ]; then
    echo -e "  ${RED}Setup Complete - With Errors${NC}"
else
    echo -e "  ${YELLOW}Setup Complete - With Warnings${NC}"
fi
echo "================================================"

# Show error summary if any
if [ ${#ERRORS[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}Errors (${#ERRORS[@]}):${NC}"
    for err in "${ERRORS[@]}"; do
        echo "  • $err"
    done
fi

# Show warning summary if any
if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Warnings (${#WARNINGS[@]}):${NC}"
    for warn in "${WARNINGS[@]}"; do
        echo "  • $warn"
    done
fi

echo ""

if $UPDATE_MODE; then
    msg_success "5DayDocs updated to version $CURRENT_VERSION"
    echo ""
    echo "Changes:"
    echo "  - Scripts synced from source"
    echo "  - DOC_STATE.md reconciled"
    echo "  - Templates updated"
else
    msg_success "5DayDocs installed to: $TARGET_PATH"
    echo "Platform: $PLATFORM"
    echo ""
    echo "Directory structure created in docs/"
    echo "Scripts available at docs/5day/scripts/"
    echo "Documentation at DOCUMENTATION.md"
    echo "AI CLI/model config at docs/5day/config.sh (edit to change CLI or models)"
    echo ""
    echo "Get started:"
    echo "  ./5day.sh help            # Show all commands"
    echo "  ./5day.sh newtask \"...\"   # Create a task"
    echo "  ./5day.sh newbug \"...\"    # Report a bug"
    echo "  ./5day.sh status          # Show project status"
fi

if [ "$VALIDATION_PASSED" = true ] && [ ${#ERRORS[@]} -eq 0 ]; then
    echo ""
    msg_info "5DayDocs is ready! Try:"
    echo "  ./5day.sh newtask \"Build user authentication\""
fi

echo ""

# Exit with error code if there were errors
if [ ${#ERRORS[@]} -gt 0 ]; then
    exit 1
fi
