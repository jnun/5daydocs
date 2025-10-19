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
  mkdir -p docs/work/tasks/backlog
  mkdir -p docs/work/tasks/next
  mkdir -p docs/work/tasks/working
  mkdir -p docs/work/tasks/review
  mkdir -p docs/work/tasks/live
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
  elif [ -d "work/tasks" ] && [ ! -d "docs/work/tasks" ]; then
    # Handle partial migration - just tasks
    mkdir -p docs/work
    mv work/tasks docs/work/
    echo "✓ Moved work/tasks/ to docs/work/tasks/"
  fi

  # Handle flat task structure (tasks directly in docs/tasks)
  if [ -d "docs/tasks" ] && [ ! -d "docs/work/tasks" ]; then
    mkdir -p docs/work
    mv docs/tasks docs/work/
    echo "✓ Moved docs/tasks/ to docs/work/tasks/"
  fi

  # Ensure pipeline folders exist
  ensure_task_folders

  # Move any loose task files to backlog
  if [ -d "docs/work/tasks" ]; then
    for file in docs/work/tasks/*.md; do
      if [ -f "$file" ]; then
        basename=$(basename "$file")
        # Skip index and template files
        if [[ "$basename" != "INDEX.md" ]] && [[ "$basename" != "TEMPLATE"* ]]; then
          mv "$file" "docs/work/tasks/backlog/" 2>/dev/null || true
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
  mkdir -p docs/work/bugs
  mkdir -p docs/work/bugs/archived
  echo "✓ Ensured bug tracking folders exist"

  # Ensure other work folders exist
  mkdir -p docs/work/scripts
  mkdir -p docs/work/designs
  mkdir -p docs/work/examples
  mkdir -p docs/work/data
  echo "✓ Ensured work support folders exist"

  # Ensure docs folders exist
  mkdir -p docs/features
  mkdir -p docs/guides
  mkdir -p docs/ideas
  echo "✓ Ensured documentation folders exist"

  # Update references in markdown files
  for file in README.md docs/INDEX.md docs/work/tasks/INDEX.md CLAUDE.md; do
    if [ -f "$file" ]; then
      # Update old task paths
      sed -i '' 's|work/tasks/|docs/work/tasks/|g' "$file" 2>/dev/null || true
      sed -i '' 's|docs/tasks/|docs/work/tasks/|g' "$file" 2>/dev/null || true
      echo "✓ Updated references in $file"
    fi
  done

  # Check for orphaned tasks and report
  echo ""
  echo "Checking task distribution:"
  for folder in backlog next working review live; do
    count=$(ls -1 docs/work/tasks/$folder/*.md 2>/dev/null | grep -v TEMPLATE | wc -l | tr -d ' ')
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

# Update distributable files from source
echo ""
echo "Updating distributable files..."

# Update GitHub Actions workflows (only if they already exist in target)
if [ -d "$TARGET_PATH/.github/workflows" ]; then
  echo "Checking for workflow updates..."

  # Check each workflow template
  if [ -d "$FIVEDAY_SOURCE_DIR/templates/workflows/github" ]; then
    for template_workflow in "$FIVEDAY_SOURCE_DIR/templates/workflows/github"/*.yml; do
      if [ -f "$template_workflow" ]; then
        workflow_name=$(basename "$template_workflow")
        target_workflow="$TARGET_PATH/.github/workflows/$workflow_name"

        # Only update if workflow already exists in target
        if [ -f "$target_workflow" ]; then
          cp -f "$template_workflow" "$target_workflow"
          echo "✓ Updated workflow: $workflow_name"
        fi
      fi
    done
  fi
fi

# Update work scripts (create directory if needed)
if [ -d "$FIVEDAY_SOURCE_DIR/docs/work/scripts" ]; then
  mkdir -p "$TARGET_PATH/docs/work/scripts"

  for script in "$FIVEDAY_SOURCE_DIR/docs/work/scripts"/*.sh; do
    if [ -f "$script" ]; then
      script_name=$(basename "$script")
      cp -f "$script" "$TARGET_PATH/docs/work/scripts/$script_name"
      chmod +x "$TARGET_PATH/docs/work/scripts/$script_name"
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

echo ""
echo "✅ Update complete!"
echo "Version updated to: $CURRENT_VERSION"
echo ""
echo "Next steps:"
echo "1. Review docs/STATE.md for task/bug ID tracking"
echo "2. Check task distribution in pipeline folders"
echo "3. Run 'git status' to see all changes"
echo "4. Commit changes when ready"