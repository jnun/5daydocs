# Project Scripts

Automation and utility scripts for the 5daydocs system.

## Available Scripts

### setup.sh
**Purpose:** Initial project setup and configuration
**Usage:** `./setup.sh`
**Actions:**
- Creates folder structure if missing
- Copies template files to new project
- Sets up git repository
- Initializes state tracking files
- Makes scripts executable

### check-alignment.sh
**Purpose:** Analyzes feature documentation and task alignment
**Usage:** `./check-alignment.sh`
**Output:** Reports on:
- Feature status distribution (LIVE, TESTING, WORKING, BACKLOG)
- Orphaned tasks without features
- Features without corresponding tasks
- Overall project alignment metrics

### create-task.sh
**Purpose:** Interactive task creation with automatic ID assignment
**Usage:** `./create-task.sh`
**Features:**
- Automatically reads next ID from STATE.md
- Prompts for task title and description
- Creates properly formatted task file
- Updates STATE.md with new ID
- Places task in backlog folder

## Running Scripts

All scripts should be executable. If not:
```bash
chmod +x docs/organizational-process-assets/scripts/*.sh
```

## Script Development Guidelines

### Language
- Prefer bash for portability
- Use `#!/bin/bash` shebang
- Test on macOS and Linux

### Error Handling
```bash
set -e  # Exit on error
set -u  # Error on undefined variables
```

### User Feedback
- Use color output for important messages
- Provide clear success/failure indicators
- Show progress for long operations

### File Paths
- Use relative paths from project root
- Check file existence before operations
- Create directories with `mkdir -p`

## Adding New Scripts

1. Create script in `/docs/organizational-process-assets/scripts/`
2. Make executable: `chmod +x script.sh`
3. Add documentation here with:
   - Script name
   - Purpose
   - Usage example
   - What it does

## Common Script Patterns

### Check Project Root
```bash
if [ ! -f "README.md" ]; then
    echo "Error: Run from project root"
    exit 1
fi
```

### Read State File
```bash
if [ -f "../../../work/STATE.md" ]; then
    CURRENT_ID=$(grep "ID:" ../../../work/STATE.md | awk '{print $NF}')
fi
```

### Safe File Operations
```bash
# Check before overwriting
if [ -f "$FILE" ]; then
    read -p "Overwrite $FILE? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
```