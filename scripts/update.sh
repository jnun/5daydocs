#!/bin/zsh
# update.sh - 5DayDocs version-aware update and migration script

set -e

VERSION_FILE="docs/VERSION"
CURRENT_VERSION="1.0.0"

# Read installed version
if [ -f "$VERSION_FILE" ]; then
  INSTALLED_VERSION=$(cat "$VERSION_FILE")
else
  INSTALLED_VERSION="0.0.0"
fi

echo "5DayDocs Update Script"
echo "Current version: $INSTALLED_VERSION"
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

  # Handle old work/tasks structure (if exists)
  if [ -d "work/tasks" ] && [ ! -d "docs/work/tasks" ]; then
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

# Write updated version
echo "$CURRENT_VERSION" > "$VERSION_FILE"

echo ""
echo "✅ Update complete!"
echo "Version updated to: $CURRENT_VERSION"
echo ""
echo "Next steps:"
echo "1. Review docs/STATE.md for task/bug ID tracking"
echo "2. Check task distribution in pipeline folders"
echo "3. Run 'git status' to see all changes"
echo "4. Commit changes when ready"