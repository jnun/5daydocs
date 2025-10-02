
#!/bin/zsh
# update.sh - 5DayDocs version-aware update and migration script

set -e

VERSION_FILE="docs/VERSION"
CURRENT_VERSION="0.1.0"


# Read installed version
if [ -f "$VERSION_FILE" ]; then
  INSTALLED_VERSION=$(cat "$VERSION_FILE")
else
  INSTALLED_VERSION="0.0.0"
fi

echo "5DayDocs Update Script"
echo "Current version: $INSTALLED_VERSION"
echo "Target version: $CURRENT_VERSION"

# Migration: Move work/tasks to docs/tasks if needed
if [ "$INSTALLED_VERSION" = "0.0.0" ]; then
  if [ -d "work/tasks" ]; then
    mkdir -p docs/tasks
    mv work/tasks/* docs/tasks/
    rmdir work/tasks
    echo "Moved work/tasks/ to docs/tasks/"
  else
    echo "No work/tasks/ directory found. Skipping move."
  fi

  # Update README.md references
  if [ -f "README.md" ]; then
    sed -i '' 's|work/tasks/|docs/tasks/|g' README.md
    echo "Updated README.md references."
  fi

  # Update docs/INDEX.md references
  if [ -f "docs/INDEX.md" ]; then
    sed -i '' 's|work/tasks/|docs/tasks/|g' docs/INDEX.md
    echo "Updated docs/INDEX.md references."
  fi

  # Update version file
  echo "$CURRENT_VERSION" > "$VERSION_FILE"
  echo "Updated version to $CURRENT_VERSION."
fi

echo "Update complete. Please review README.md and docs/INDEX.md for any manual adjustments."
