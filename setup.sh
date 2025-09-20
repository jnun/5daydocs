#!/bin/bash
# setup.sh - Initialize project documentation structure
# Usage: ./setup.sh
#   Prompts for target project path and sets up 5DayDocs structure there

set -e  # Exit on error

# Store the 5daydocs source directory (where this script is located)
FIVEDAY_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "================================================"
echo "  5-Day Docs - Project Documentation Setup"
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
mkdir -p work/tasks/{backlog,next,active,review,archive}
mkdir -p work/{bugs/archived,designs,examples,data}
mkdir -p docs/{features,guides}
mkdir -p scripts

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

# Copy DOCUMENTATION.md if it doesn't exist or in update mode
echo "Setting up documentation files..."
if [ ! -f DOCUMENTATION.md ] || $UPDATE_MODE; then
    if [ -f "$FIVEDAY_SOURCE_DIR/DOCUMENTATION.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/DOCUMENTATION.md" DOCUMENTATION.md
        echo "✓ Copied DOCUMENTATION.md"
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
    fi
else
    echo "⚠ CLAUDE.md already exists, skipping"
fi

# Create .gitignore if it doesn't exist
echo "Setting up .gitignore..."
if [ ! -f .gitignore ]; then
    cat > .gitignore << GITIGNORE_EOF
# OS Files
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
\#*\#
.\#*

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
._*
GITIGNORE_EOF
    echo "✓ Created .gitignore"
else
    echo "⚠ .gitignore already exists, skipping"
fi

# Make all scripts executable
if ls scripts/*.sh 1> /dev/null 2>&1; then
    chmod +x scripts/*.sh
    echo "✓ Made all scripts executable"
fi

echo ""
echo "================================================"
echo "  Setup Complete!"
echo "================================================"
echo ""
echo "✓ 5DayDocs installed to: $TARGET_PATH"
echo ""
if $UPDATE_MODE; then
    echo "✓ 5DayDocs structure updated"
    echo "✓ Existing project files preserved"
else
    echo "Next steps:"
    echo "1. cd $TARGET_PATH"
    echo "2. Review DOCUMENTATION.md for detailed workflow"
    echo "3. Customize CLAUDE.md for your project's AI assistance needs"
    echo "4. Create your first task in work/tasks/backlog/"
    echo "5. Track features in docs/features/"
    echo ""
    echo "To update 5DayDocs in the future, run this setup script again."
fi
echo ""
