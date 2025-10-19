#!/bin/bash

# migrate-to-submodule.sh
# Migrates an existing 5daydocs installation to use the submodule distribution

set -e

echo "================================================"
echo "  5DayDocs - Migration to Submodule"
echo "================================================"
echo ""

# Check if we're in a project with 5daydocs installed
if [ ! -f "docs/STATE.md" ]; then
    echo "❌ Error: No 5daydocs installation found in current directory."
    echo "  Please run this script from your project root."
    exit 1
fi

# Check for existing work content
echo "Checking existing 5daydocs content..."
TASK_COUNT=$(find docs/work/tasks -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
BUG_COUNT=$(find docs/work/bugs -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
DOC_COUNT=$(find docs -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo "Found:"
echo "  - $TASK_COUNT task files"
echo "  - $BUG_COUNT bug files"
echo "  - $DOC_COUNT documentation files"
echo ""

# Backup existing work
echo "Creating backup of existing work..."
BACKUP_DIR="5daydocs-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup work directory
if [ -d "work" ]; then
    cp -r work "$BACKUP_DIR/"
    echo "  ✓ Backed up docs/work/ to $BACKUP_DIR/"
fi

# Backup docs directory
if [ -d "docs" ]; then
    cp -r docs "$BACKUP_DIR/"
    echo "  ✓ Backed up docs/ to $BACKUP_DIR/"
fi

# Backup any custom scripts
if [ -f "5day.sh" ]; then
    cp 5day.sh "$BACKUP_DIR/"
fi
if [ -f "setup.sh" ]; then
    cp setup.sh "$BACKUP_DIR/"
fi

echo ""
echo "Backup created at: $BACKUP_DIR"
echo ""

# Remove old standalone files
echo "Removing old standalone installation files..."
REMOVED_FILES=0

# Remove old scripts (but not docs/work/scripts)
if [ -f "5day.sh" ]; then
    rm -f 5day.sh
    ((REMOVED_FILES++))
    echo "  ✓ Removed 5day.sh"
fi

if [ -f "setup.sh" ]; then
    rm -f setup.sh
    ((REMOVED_FILES++))
    echo "  ✓ Removed setup.sh"
fi

# Remove templates if they exist at root
if [ -d "templates" ]; then
    rm -rf templates
    ((REMOVED_FILES++))
    echo "  ✓ Removed templates/"
fi

if [ $REMOVED_FILES -eq 0 ]; then
    echo "  → No standalone files found to remove"
fi

echo ""

# Add submodule
echo "Adding 5daydocs as git submodule..."
echo "Enter the 5daydocs distribution repository URL:"
echo "(e.g., https://github.com/yourusername/5daydocs.git)"
read -r REPO_URL

# Check if submodule already exists
if [ -d "5daydocs" ] && [ -f ".gitmodules" ] && grep -q "5daydocs" .gitmodules; then
    echo "⚠ Submodule 5daydocs already exists. Updating instead..."
    cd 5daydocs
    git pull origin main
    cd ..
else
    git submodule add "$REPO_URL" 5daydocs
    git submodule update --init --recursive
fi

echo "  ✓ Added 5daydocs submodule"
echo ""

# Restore work content
echo "Restoring your project content..."

# Ensure directories exist (setup.sh will handle this safely too)
./5daydocs/setup.sh

# Restore work content
if [ -d "$BACKUP_DIR/work" ]; then
    # Copy task files
    for folder in backlog next working review live; do
        if [ -d "$BACKUP_DIR/docs/tasks/$folder" ]; then
            cp -n "$BACKUP_DIR/docs/tasks/$folder"/*.md "docs/tasks/$folder/" 2>/dev/null || true
        fi
    done

    # Copy bug files
    if [ -d "$BACKUP_DIR/docs/work/bugs" ]; then
        find "$BACKUP_DIR/docs/work/bugs" -name "*.md" -exec cp -n {} docs/bugs/ \; 2>/dev/null || true
    fi

    # Copy custom scripts
    if [ -d "$BACKUP_DIR/docs/work/scripts" ]; then
        cp -n "$BACKUP_DIR/docs/work/scripts"/* "docs/scripts/" 2>/dev/null || true
    fi

    # Restore STATE.md (preserving IDs)
    if [ -f "$BACKUP_DIR/docs/STATE.md" ]; then
        cp "$BACKUP_DIR/docs/STATE.md" "docs/STATE.md"
        echo "  ✓ Restored STATE.md with existing IDs"
    fi

    echo "  ✓ Restored work content"
fi

# Restore docs content
if [ -d "$BACKUP_DIR/docs" ]; then
    # Copy feature docs
    if [ -d "$BACKUP_DIR/docs/features" ]; then
        cp -n "$BACKUP_DIR/docs/features"/*.md "docs/features/" 2>/dev/null || true
    fi

    # Copy guides
    if [ -d "$BACKUP_DIR/docs/guides" ]; then
        cp -n "$BACKUP_DIR/docs/guides"/*.md "docs/guides/" 2>/dev/null || true
    fi

    echo "  ✓ Restored documentation"
fi

echo ""
echo "================================================"
echo "  Migration Complete!"
echo "================================================"
echo ""
echo "Your project has been migrated to use 5daydocs as a submodule."
echo ""
echo "Next steps:"
echo "1. Review the migration:"
echo "   - Check docs/tasks/ for your tasks"
echo "   - Verify docs/STATE.md has correct IDs"
echo "   - Ensure docs/ has your documentation"
echo ""
echo "2. Commit the changes:"
echo "   git add .gitmodules 5daydocs"
echo "   git commit -m \"Migrate to 5daydocs submodule\""
echo ""
echo "3. Use 5daydocs commands:"
echo "   ./5daydocs/5day.sh status"
echo "   ./5daydocs/5day.sh new \"Your task\""
echo ""
echo "Backup preserved at: $BACKUP_DIR"
echo "(You can remove this after verifying the migration)"
echo ""