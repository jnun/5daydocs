#!/bin/bash
# setup.sh - Initialize project documentation structure
# Usage: ./setup.sh
#   Prompts for target project path and sets up 5DayDocs structure there

set -e  # Exit on error

# Store the 5daydocs source directory (where this script is located)
FIVEDAY_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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
mkdir -p .github/workflows  # For GitHub Actions (optional)

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

# Copy documentation files
echo "Setting up documentation files..."

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

# Copy template files
echo "Setting up template files..."
if [ ! -f work/tasks/TEMPLATE-task.md ] || $UPDATE_MODE; then
    if [ -f "$FIVEDAY_SOURCE_DIR/work/tasks/TEMPLATE-task.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/work/tasks/TEMPLATE-task.md" work/tasks/
        echo "✓ Copied task template"
    fi
fi

if [ ! -f work/bugs/TEMPLATE-bug.md ] || $UPDATE_MODE; then
    if [ -f "$FIVEDAY_SOURCE_DIR/work/bugs/TEMPLATE-bug.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/work/bugs/TEMPLATE-bug.md" work/bugs/
        echo "✓ Copied bug template"
    fi
fi

if [ ! -f docs/features/TEMPLATE-feature.md ] || $UPDATE_MODE; then
    if [ -f "$FIVEDAY_SOURCE_DIR/docs/features/TEMPLATE-feature.md" ]; then
        cp "$FIVEDAY_SOURCE_DIR/docs/features/TEMPLATE-feature.md" docs/features/
        echo "✓ Copied feature template"
    fi
fi

# Copy scripts (all go in work/scripts/)
echo "Setting up automation scripts..."
if [ -f "$FIVEDAY_SOURCE_DIR/work/scripts/analyze-feature-alignment.sh" ]; then
    cp "$FIVEDAY_SOURCE_DIR/work/scripts/analyze-feature-alignment.sh" work/scripts/
    chmod +x work/scripts/analyze-feature-alignment.sh
    echo "✓ Copied analyze-feature-alignment.sh to work/scripts/"
fi

if [ -f "$FIVEDAY_SOURCE_DIR/work/scripts/create-task.sh" ]; then
    cp "$FIVEDAY_SOURCE_DIR/work/scripts/create-task.sh" work/scripts/
    chmod +x work/scripts/create-task.sh
    echo "✓ Copied create-task.sh to work/scripts/"
fi

# Copy GitHub workflows (optional)
if [ -d "$FIVEDAY_SOURCE_DIR/.github/workflows" ] && [ ! -d .github/workflows ]; then
    echo "Would you like to set up GitHub Actions integration? (y/n)"
    read -r SETUP_GITHUB
    if [[ "$SETUP_GITHUB" =~ ^[Yy]$ ]]; then
        cp -r "$FIVEDAY_SOURCE_DIR/.github/workflows" .github/
        echo "✓ Copied GitHub Actions workflows"
        echo "  Remember to configure secrets in your GitHub repository settings"
    fi
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

# Ensure all scripts are executable (double-check)
echo "Verifying script permissions..."
if [ -d work/scripts ]; then
    find work/scripts -name "*.sh" -type f -exec chmod +x {} \;
fi
echo "✓ All scripts are executable"

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
    echo "4. Create your first task using: ./work/scripts/create-task.sh"
    echo "5. Track features in docs/features/"
    echo "6. Check alignment with: ./work/scripts/analyze-feature-alignment.sh"
    echo ""
    echo "To update 5DayDocs in the future, run this setup script again."
fi
echo ""
