#!/bin/zsh
# update.sh - 5DayDocs version-aware update and migration script
# Usage: ./update.sh
#   Prompts for target project path and updates 5DayDocs structure there

set -e

# Store the 5daydocs source directory (where this script lives)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-$0}" )" && pwd )"
# Get the 5daydocs root directory (parent of scripts/)
FIVEDAY_SOURCE_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "================================================"
echo "  5DayDocs - Update Script"
echo "================================================"
echo ""

# Read current version from source VERSION file
if [ -f "$FIVEDAY_SOURCE_DIR/VERSION" ]; then
    CURRENT_VERSION=$(cat "$FIVEDAY_SOURCE_DIR/VERSION")
else
    echo "❌ Error: Cannot find VERSION file in 5daydocs source directory"
    echo "   Expected at: $FIVEDAY_SOURCE_DIR/VERSION"
    exit 1
fi

# Ask for target project path
echo "Enter the path to your project where 5DayDocs is installed:"
echo "(e.g., /Users/yourname/myproject or ../myproject)"
read -r TARGET_PATH

# Expand tilde and resolve relative paths
TARGET_PATH="${TARGET_PATH/#\~/$HOME}"
TARGET_PATH="$( cd "$TARGET_PATH" 2>/dev/null && pwd )" || {
    echo "❌ Error: Path '$TARGET_PATH' does not exist or is not accessible."
    exit 1
}

echo ""
echo "Updating 5DayDocs in: $TARGET_PATH"
echo ""

# Change to target directory
cd "$TARGET_PATH"

# Check if 5DayDocs is installed in this directory (check both old and new structures)
# At least one of these should exist for 5DayDocs to be considered installed
if [ ! -d "docs/work/tasks" ] && [ ! -d "work/tasks" ] && [ ! -f "docs/STATE.md" ] && [ ! -f "work/STATE.md" ]; then
    echo "❌ Error: 5DayDocs doesn't appear to be installed in $TARGET_PATH"
    echo "   Please run setup.sh first to install 5DayDocs in this directory."
    exit 1
fi

# Read installed version from STATE.md
if [ -f "docs/STATE.md" ]; then
  INSTALLED_VERSION=$(awk '/5DAY_VERSION/{print $NF}' docs/STATE.md)

  # If no version field exists, check for old VERSION file
  if [ -z "$INSTALLED_VERSION" ] && [ -f "docs/VERSION" ]; then
    INSTALLED_VERSION=$(cat "docs/VERSION")
  fi

  # Default to 0.0.0 if still not found
  if [ -z "$INSTALLED_VERSION" ]; then
    INSTALLED_VERSION="0.0.0"
  fi
else
  # No STATE.md - check for old structure indicators
  if [ -d "work" ] || [ -f "work/STATE.md" ]; then
    echo "Found work/ directory at root - old structure detected"
    INSTALLED_VERSION="0.0.0"
  else
    INSTALLED_VERSION="0.0.0"
  fi
fi

echo "Installed version: $INSTALLED_VERSION"
echo "Target version: $CURRENT_VERSION"

# Function to ensure task pipeline folders exist
ensure_task_folders() {
  mkdir -p docs/tasks/backlog
  mkdir -p docs/tasks/next
  mkdir -p docs/tasks/working
  mkdir -p docs/tasks/review
  mkdir -p docs/tasks/live
  echo "✓ Ensured task pipeline folders exist"
}

# Function to ensure STATE.md exists
ensure_state_file() {
  if [ ! -f "docs/STATE.md" ]; then
    cat > docs/STATE.md << 'EOF'
# STATE.md

## Last Updated
2024-01-01 00:00:00

## Task State
- **Current ID**: 0
- **Next Available**: 1

## Bug State
- **Current ID**: 0
- **Next Available**: 1
EOF
    echo "✓ Created docs/STATE.md"
  fi
}

# Migration from 0.0.0 (very old structure without proper folders)
if [[ "$INSTALLED_VERSION" < "0.1.0" ]]; then
  echo ""
  echo "Migrating from pre-0.1.0 structure..."

  # Handle old work/ structure at root (if exists)
  if [ -d "work" ]; then
    if [ ! -d "docs/work" ]; then
      # Simple case: docs/work doesn't exist, just move
      mkdir -p docs
      mv work docs/
      echo "✓ Moved work/ to docs/work/"
    else
      # Complex case: both exist - need to merge
      echo "Found both work/ and docs/work/ - merging content..."

      # Compare STATE.md dates to determine which is newer
      ROOT_DATE="1970-01-01"
      DOCS_DATE="1970-01-01"

      if [ -f "work/STATE.md" ]; then
        ROOT_DATE=$(grep "Last Updated" work/STATE.md | sed 's/.*: //' || echo "1970-01-01")
      fi

      if [ -f "docs/work/STATE.md" ] || [ -f "docs/STATE.md" ]; then
        if [ -f "docs/STATE.md" ]; then
          DOCS_DATE=$(grep "Last Updated" docs/STATE.md | sed 's/.*: //' || echo "1970-01-01")
        else
          DOCS_DATE=$(grep "Last Updated" docs/work/STATE.md | sed 's/.*: //' || echo "1970-01-01")
        fi
      fi

      # If root work/ is newer, backup docs/work and replace
      if [[ "$ROOT_DATE" > "$DOCS_DATE" ]]; then
        echo "Root work/ is newer (${ROOT_DATE} vs ${DOCS_DATE})"
        if [ -d "docs/work.backup" ]; then
          rm -rf "docs/work.backup"
        fi
        mv docs/work docs/work.backup
        mv work docs/
        echo "✓ Backed up old docs/work/ to docs/work.backup/"
        echo "✓ Moved newer work/ to docs/work/"
      else
        echo "docs/work/ is newer or same date - removing old root work/"
        echo "Consider manually checking work/ before removing it"
        mv work work.backup
        echo "✓ Moved old work/ to work.backup/"
      fi
    fi

    # Move STATE.md if it exists in docs/work/
    if [ -f "docs/work/STATE.md" ]; then
      mv docs/work/STATE.md docs/
      echo "✓ Moved STATE.md to docs/"
    fi
  elif [ -d "work/tasks" ] && [ ! -d "docs/tasks" ]; then
    # Handle partial migration - just tasks
    mkdir -p docs
    mv work/tasks docs/
    echo "✓ Moved work/tasks/ to docs/tasks/"
  fi

  # Ensure pipeline folders exist
  ensure_task_folders

  # Move any loose task files to backlog
  if [ -d "docs/tasks" ]; then
    for file in docs/tasks/*.md; do
      if [ -f "$file" ]; then
        basename=$(basename "$file")
        # Skip index and template files
        if [[ "$basename" != "INDEX.md" ]] && [[ "$basename" != "TEMPLATE"* ]]; then
          mv "$file" "docs/tasks/backlog/" 2>/dev/null || true
          echo "✓ Moved $basename to backlog/"
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

  # Ensure all required folders exist
  ensure_task_folders
  ensure_state_file

  # Ensure bugs folders exist
  mkdir -p docs/bugs
  mkdir -p docs/bugs/archived
  echo "✓ Ensured bug tracking folders exist"

  # Ensure other folders exist
  mkdir -p docs/5day/scripts
  mkdir -p docs/designs
  mkdir -p docs/examples
  mkdir -p docs/data
  echo "✓ Ensured support folders exist"

  # Ensure docs folders exist
  mkdir -p docs/features
  mkdir -p docs/guides
  mkdir -p docs/ideas
  echo "✓ Ensured documentation folders exist"

  # Add .gitkeep files to preserve empty directories
  echo "✓ Adding .gitkeep files to empty directories..."
  find docs -type d -empty -exec touch {}/.gitkeep \;

  # Update references in markdown files
  for file in README.md docs/INDEX.md docs/tasks/INDEX.md DOCUMENTATION.md; do
    if [ -f "$file" ]; then
      # Update old task paths
      sed -i '' 's|work/tasks/|docs/tasks/|g' "$file" 2>/dev/null || true
      sed -i '' 's|docs/tasks/|docs/tasks/|g' "$file" 2>/dev/null || true
      echo "✓ Updated references in $file"
    fi
  done

  # Check for orphaned tasks and report
  echo ""
  echo "Checking task distribution:"
  for folder in backlog next working review live; do
    count=$(ls -1 docs/tasks/$folder/*.md 2>/dev/null | grep -v TEMPLATE | wc -l | tr -d ' ')
    echo "  $folder: $count tasks"
  done

  INSTALLED_VERSION="1.0.0"
fi

# Migration from 1.0.0 to 1.1.0
if [[ "$INSTALLED_VERSION" < "1.1.0" ]]; then
  echo ""
  echo "Migrating from 1.0.0 to 1.1.0..."
  echo "✓ Update script now prompts for target directory"
  echo "✓ No structural changes required"

  INSTALLED_VERSION="1.1.0"
fi

# Migration from 1.1.0 to 1.1.3
if [[ "$INSTALLED_VERSION" < "1.1.3" ]]; then
  echo ""
  echo "Migrating from 1.1.0 to 1.1.3..."
  echo "✓ Updating distributable files (workflows, scripts)"

  INSTALLED_VERSION="1.1.3"
fi

# Migration from 1.1.3 to 1.1.4
if [[ "$INSTALLED_VERSION" < "1.1.4" ]]; then
  echo ""
  echo "Migrating from 1.1.3 to 1.1.4..."

  # Add SYNC_ALL_TASKS field to STATE.md if it doesn't exist
  if [ -f "$TARGET_PATH/docs/STATE.md" ]; then
    if ! grep -q "SYNC_ALL_TASKS" "$TARGET_PATH/docs/STATE.md"; then
      echo "Adding SYNC_ALL_TASKS field to STATE.md..."
      echo "**SYNC_ALL_TASKS**: false" >> "$TARGET_PATH/docs/STATE.md"
      echo "✓ Added SYNC_ALL_TASKS field"
    else
      echo "✓ SYNC_ALL_TASKS field already exists"
    fi
  fi

  INSTALLED_VERSION="1.1.4"
fi

# Migration from 1.x to 2.0.0 - Major structural change: Flatten docs/work/ hierarchy
if [[ "$INSTALLED_VERSION" < "2.0.0" ]]; then
  echo ""
  echo "================================================"
  echo "  Migrating to 2.0.0 - Structure Simplification"
  echo "================================================"
  echo ""
  echo "This update flattens the directory structure:"
  echo "  docs/work/tasks/ → docs/tasks/"
  echo "  docs/work/bugs/ → docs/bugs/"
  echo "  docs/work/scripts/ → docs/5day/scripts/"
  echo "  docs/work/designs/ → docs/designs/"
  echo "  docs/work/examples/ → docs/examples/"
  echo "  docs/work/data/ → docs/data/"
  echo ""
  echo "All your data will be safely migrated."
  echo ""

  # Create backup directory with timestamp
  BACKUP_DIR="docs/work-backup-$(date +%Y%m%d-%H%M%S)"

  # Function to safely move directory with content preservation
  safe_migrate_dir() {
    local source="$1"
    local dest="$2"

    if [ -d "$source" ]; then
      # Create parent directory if needed
      mkdir -p "$(dirname "$dest")"

      if [ -d "$dest" ]; then
        # Destination exists - merge content
        echo "  Merging $source into existing $dest..."
        cp -R "$source/." "$dest/"
        echo "  ✓ Merged content from $source to $dest"
      else
        # Simple move
        mv "$source" "$dest"
        echo "  ✓ Moved $source → $dest"
      fi
    else
      echo "  → Skipped $source (doesn't exist)"
    fi
  }

  # Backup the entire docs/work/ directory first
  if [ -d "docs/work" ]; then
    echo "Creating backup at $BACKUP_DIR..."
    cp -R "docs/work" "$BACKUP_DIR"
    echo "✓ Backup created"
    echo ""
  fi

  echo "Migrating directories..."

  # Migrate each subdirectory
  safe_migrate_dir "docs/work/tasks" "docs/tasks"
  safe_migrate_dir "docs/work/bugs" "docs/bugs"
  safe_migrate_dir "docs/work/scripts" "docs/5day/scripts"
  safe_migrate_dir "docs/work/designs" "docs/designs"
  safe_migrate_dir "docs/work/examples" "docs/examples"
  safe_migrate_dir "docs/work/data" "docs/data"

  # Move platform config if it exists
  if [ -f "docs/work/.platform-config" ]; then
    mv "docs/work/.platform-config" "docs/.platform-config"
    echo "  ✓ Moved platform config to docs/"
  fi

  # Move any INDEX.md from docs/work/ to appropriate locations
  if [ -f "docs/work/INDEX.md" ]; then
    # Archive the old work INDEX.md as it's no longer relevant
    mv "docs/work/INDEX.md" "$BACKUP_DIR/INDEX.md" 2>/dev/null || true
  fi

  # Clean up any remaining files in docs/work/ subdirectories
  # These are template/index files that don't need to be migrated
  echo ""
  echo "Cleaning up old docs/work/ directory..."

  # Archive any remaining INDEX.md files
  for subdir in tasks bugs scripts designs examples data; do
    if [ -f "docs/work/$subdir/INDEX.md" ]; then
      mv "docs/work/$subdir/INDEX.md" "$BACKUP_DIR/$subdir-INDEX.md" 2>/dev/null || true
      echo "  ✓ Archived docs/work/$subdir/INDEX.md to backup"
    fi
  done

  # Remove any remaining empty directories and the work directory itself
  if [ -d "docs/work" ]; then
    # Remove all empty subdirectories first
    find "docs/work" -type d -empty -delete 2>/dev/null || true

    # Force remove docs/work/ - everything important is already migrated and backed up
    if [ -d "docs/work" ]; then
      # Move any remaining files to backup as a safety measure
      if [ -n "$(ls -A docs/work 2>/dev/null)" ]; then
        echo "  ⚠ Moving remaining docs/work/ contents to backup..."
        cp -R docs/work/. "$BACKUP_DIR/remaining-files/" 2>/dev/null || true
      fi
      # Now safe to remove
      rm -rf "docs/work"
      echo "  ✓ Removed docs/work/ directory"
    fi
  fi

  echo ""
  echo "✓ Migration to 2.0.0 structure complete!"
  echo "  Backup preserved at: $BACKUP_DIR"
  echo ""

  # Verify migration success
  echo "Verifying migration..."
  MIGRATION_OK=true
  for dir in docs/tasks/backlog docs/tasks/next docs/tasks/working docs/tasks/review docs/tasks/live docs/bugs docs/5day/scripts; do
    if [ ! -d "$dir" ]; then
      echo "  ⚠ Warning: Expected directory not found: $dir"
      MIGRATION_OK=false
    fi
  done

  if $MIGRATION_OK; then
    echo "✓ All expected directories present"
  else
    echo "⚠ Some directories missing - please review"
  fi

  INSTALLED_VERSION="2.0.0"
fi

# Migration from 2.0.0 to 2.1.0 - Move scripts to docs/5day/ namespace
if [[ "$INSTALLED_VERSION" < "2.1.0" ]]; then
  echo ""
  echo "================================================"
  echo "  Migrating to 2.1.0 - Framework Namespace"
  echo "================================================"
  echo ""
  echo "This update moves framework scripts to docs/5day/:"
  echo "  docs/scripts/ → docs/5day/scripts/"
  echo ""
  echo "This separates framework files from your content."
  echo ""

  # Create the 5day directory structure
  mkdir -p "$TARGET_PATH/docs/5day/scripts"
  mkdir -p "$TARGET_PATH/docs/5day/ai"

  # Migrate scripts from docs/scripts/ to docs/5day/scripts/
  if [ -d "$TARGET_PATH/docs/scripts" ]; then
    echo "Migrating framework scripts..."

    # Move all .sh files (framework scripts)
    for script in "$TARGET_PATH/docs/scripts"/*.sh; do
      if [ -f "$script" ]; then
        script_name=$(basename "$script")
        mv "$script" "$TARGET_PATH/docs/5day/scripts/$script_name"
        echo "  ✓ Moved $script_name → docs/5day/scripts/"
      fi
    done

    # Check if docs/scripts/ is now empty (only .gitkeep or INDEX.md)
    remaining=$(find "$TARGET_PATH/docs/scripts" -type f ! -name ".gitkeep" ! -name "INDEX.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$remaining" -eq 0 ]; then
      echo "  ✓ docs/scripts/ is now empty (available for your own scripts)"
    else
      echo "  → Some files remain in docs/scripts/ (your custom files preserved)"
    fi
  fi

  echo ""
  echo "✓ Migration to 2.1.0 structure complete!"
  echo ""

  INSTALLED_VERSION="2.1.0"
fi

# Update distributable files from source
echo ""
echo "Updating distributable files..."

# Update GitHub Actions workflows (only if they already exist in target)
if [ -d "$TARGET_PATH/.github/workflows" ]; then
  echo "Checking for workflow updates..."

  # Copy workflows from source .github/workflows/ (single source of truth)
  if [ -d "$FIVEDAY_SOURCE_DIR/.github/workflows" ]; then
    for source_workflow in "$FIVEDAY_SOURCE_DIR/.github/workflows"/*.yml; do
      if [ -f "$source_workflow" ]; then
        workflow_name=$(basename "$source_workflow")
        target_workflow="$TARGET_PATH/.github/workflows/$workflow_name"

        # Only update if workflow already exists in target
        if [ -f "$target_workflow" ]; then
          cp -f "$source_workflow" "$target_workflow"
          echo "✓ Updated workflow: $workflow_name"
        fi
      fi
    done
  fi
fi

# Update scripts from src/ (the distributable source)
if [ -d "$FIVEDAY_SOURCE_DIR/src/docs/5day/scripts" ]; then
  mkdir -p "$TARGET_PATH/docs/5day/scripts"

  for script in "$FIVEDAY_SOURCE_DIR/src/docs/5day/scripts"/*.sh; do
    if [ -f "$script" ]; then
      script_name=$(basename "$script")
      cp -f "$script" "$TARGET_PATH/docs/5day/scripts/$script_name"
      chmod +x "$TARGET_PATH/docs/5day/scripts/$script_name"
      echo "✓ Updated script: $script_name"
    fi
  done
fi

# Ensure all scripts have proper permissions
echo ""
echo "Setting executable permissions on scripts..."

# Make main scripts executable
if [ -f "$TARGET_PATH/5day.sh" ]; then
  chmod +x "$TARGET_PATH/5day.sh"
  echo "✓ Set permissions for 5day.sh"
fi

if [ -f "$TARGET_PATH/setup.sh" ]; then
  chmod +x "$TARGET_PATH/setup.sh"
  echo "✓ Set permissions for setup.sh"
fi

# Make work scripts executable (already done above, skip to avoid duplicate messages)

# Make distribution scripts executable if updating the source
if [ -d "$TARGET_PATH/scripts" ]; then
  for script in "$TARGET_PATH/scripts"/*.sh; do
    if [ -f "$script" ]; then
      chmod +x "$script"
      echo "✓ Set permissions for $(basename "$script")"
    fi
  done
fi

# Reconcile STATE.md with template to ensure all fields exist
# This ensures STATE.md always has complete field structure without losing user data
# Template structure must match templates/project/STATE.md.template
echo ""
echo "Reconciling STATE.md with template..."

if [ -f "docs/STATE.md" ]; then
  # Extract existing values from current STATE.md
  EXISTING_DATE=$(awk -F': ' '/\*\*Last Updated\*\*/{print $2}' docs/STATE.md | tr -d '\r')
  EXISTING_VERSION=$(awk -F': ' '/\*\*5DAY_VERSION\*\*/{print $2}' docs/STATE.md | tr -d '\r')
  EXISTING_TASK_ID=$(awk -F': ' '/\*\*5DAY_TASK_ID\*\*/{print $2}' docs/STATE.md | tr -d '\r')
  EXISTING_BUG_ID=$(awk -F': ' '/\*\*5DAY_BUG_ID\*\*/{print $2}' docs/STATE.md | tr -d '\r')
  EXISTING_SYNC_FLAG=$(awk -F': ' '/\*\*SYNC_ALL_TASKS\*\*/{print $2}' docs/STATE.md | tr -d '\r')

  # Validate and set defaults for missing or invalid values
  # Date: preserve existing or use today
  if [[ "$EXISTING_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    RECONCILED_DATE="$EXISTING_DATE"
  else
    RECONCILED_DATE=$(date +%Y-%m-%d)
    echo "  Setting Last Updated: $RECONCILED_DATE"
  fi

  # Version: always update to current version
  RECONCILED_VERSION="$CURRENT_VERSION"

  # Task ID: preserve existing or default to 0
  if [[ "$EXISTING_TASK_ID" =~ ^[0-9]+$ ]]; then
    RECONCILED_TASK_ID="$EXISTING_TASK_ID"
  else
    RECONCILED_TASK_ID="0"
    echo "  Initializing Task ID: 0"
  fi

  # Bug ID: preserve existing or default to 0
  if [[ "$EXISTING_BUG_ID" =~ ^[0-9]+$ ]]; then
    RECONCILED_BUG_ID="$EXISTING_BUG_ID"
  else
    RECONCILED_BUG_ID="0"
    echo "  Initializing Bug ID: 0"
  fi

  # Sync flag: preserve existing or default to false
  if [ "$EXISTING_SYNC_FLAG" = "true" ] || [ "$EXISTING_SYNC_FLAG" = "false" ]; then
    RECONCILED_SYNC_FLAG="$EXISTING_SYNC_FLAG"
  else
    RECONCILED_SYNC_FLAG="false"
    echo "  Setting SYNC_ALL_TASKS: false"
  fi

  # Rewrite STATE.md using template structure with reconciled values
  cat > docs/STATE.md << STATE_EOF
# docs/STATE.md

**Last Updated**: $RECONCILED_DATE
**5DAY_VERSION**: $RECONCILED_VERSION
**5DAY_TASK_ID**: $RECONCILED_TASK_ID
**5DAY_BUG_ID**: $RECONCILED_BUG_ID
**SYNC_ALL_TASKS**: $RECONCILED_SYNC_FLAG
STATE_EOF

  echo "✓ Reconciled STATE.md with template structure"
  echo "  Preserved: Task ID=$RECONCILED_TASK_ID, Bug ID=$RECONCILED_BUG_ID, Sync=$RECONCILED_SYNC_FLAG"
  echo "  Updated: Version=$RECONCILED_VERSION"
fi

# Check for legacy INDEX.md files in task subfolders (deprecated in 2.1.0+)
LEGACY_INDEX_FILES=""
for folder in backlog next working review live; do
    if [ -f "$TARGET_PATH/docs/tasks/$folder/INDEX.md" ]; then
        LEGACY_INDEX_FILES="$LEGACY_INDEX_FILES docs/tasks/$folder/INDEX.md"
    fi
done

if [ -n "$LEGACY_INDEX_FILES" ]; then
    echo ""
    echo "⚠️  Legacy INDEX.md files detected in task subfolders."
    echo "   These files are no longer used and may interfere with task counting."
    echo "   Please delete them:"
    for f in $LEGACY_INDEX_FILES; do
        echo "     rm $f"
    done
fi

echo ""
echo "✅ Update complete!"
echo "Version updated to: $CURRENT_VERSION"
echo ""
echo "Next steps:"
echo "1. Review docs/STATE.md for task/bug ID tracking"
echo "2. Check task distribution in pipeline folders"
echo "3. Run 'git status' to see all changes"
echo "4. Commit changes when ready"