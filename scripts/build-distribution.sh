#!/bin/bash

# build-distribution.sh
# Builds the clean 5daydocs distribution repository from the dogfooding version

set -e

# Configuration
DIST_REPO="5daydocs"
DIST_PATH="../${DIST_REPO}"
CURRENT_DIR=$(pwd)

echo "🔨 Building 5daydocs distribution..."

# Check if distribution repo exists
if [ ! -d "$DIST_PATH" ]; then
    echo "📦 Creating distribution repository at $DIST_PATH"
    mkdir -p "$DIST_PATH"
    cd "$DIST_PATH"
    git init
    cd "$CURRENT_DIR"
else
    echo "✓ Distribution repository exists at $DIST_PATH"
fi

# Clean distribution directory (preserve .git)
echo "🧹 Cleaning distribution directory..."
cd "$DIST_PATH"
git rm -rf . 2>/dev/null || true
find . -mindepth 1 -name '.git' -prune -o -exec rm -rf {} + 2>/dev/null || true
cd "$CURRENT_DIR"

# Copy core scripts
echo "📄 Copying core scripts..."
cp 5day.sh "$DIST_PATH/"
cp setup.sh "$DIST_PATH/"  # Already has safe directory creation
chmod +x "$DIST_PATH/5day.sh"
chmod +x "$DIST_PATH/setup.sh"

# Copy templates
echo "📋 Copying templates..."
cp -r templates "$DIST_PATH/"

# Copy documentation (selective)
echo "📚 Copying documentation..."
cp LICENSE "$DIST_PATH/" 2>/dev/null || true
cp CLAUDE.md "$DIST_PATH/"

# Copy distribution templates
echo "📝 Copying distribution templates..."
cp distribution-templates/README.md "$DIST_PATH/README.md"

# Note: No .gitignore needed for submodule distribution
# Users manage their own .gitignore in their project

# Create empty folder structure with .gitkeep files
echo "📁 Creating folder structure..."
mkdir -p "$DIST_PATH/docs/work/tasks/"{backlog,next,working,review,live}
mkdir -p "$DIST_PATH/docs/work/bugs/archived"
mkdir -p "$DIST_PATH/docs/work/"{scripts,designs,examples,data}
mkdir -p "$DIST_PATH/docs/"{features,guides}

# Add .gitkeep to preserve empty directories
find "$DIST_PATH/docs" -type d -empty -exec touch {}/.gitkeep \;

# Create initial STATE.md from template
echo "📊 Creating initial STATE.md..."
sed "s/{{DATE}}/$(date +%Y-%m-%d)/g" distribution-templates/STATE.md > "$DIST_PATH/docs/STATE.md"

# Update setup.sh paths for distribution use
echo "🔧 Adjusting setup.sh for distribution..."
cd "$DIST_PATH"
# The setup.sh should work from the submodule directory
# Users will run ./5daydocs/setup.sh from their project root

# Git operations
echo "📤 Preparing distribution repository..."
git add .
git commit -m "Build distribution from dogfooding repository" || echo "No changes to commit"

echo "✅ Distribution build complete!"
echo ""
echo "Next steps:"
echo "1. cd $DIST_PATH"
echo "2. git remote add origin https://github.com/yourusername/5daydocs.git"
echo "3. git push -u origin main"
echo ""
echo "Users can then add as submodule:"
echo "git submodule add https://github.com/yourusername/5daydocs.git 5daydocs"