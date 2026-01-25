# Scripts Directory

> **Full documentation: [DOCUMENTATION.md](/DOCUMENTATION.md#scripts-directory)**

## What's Here

Automation scripts for 5DayDocs workflows (bash preferred).

## Common Scripts

- **setup.sh** - Initial project setup
- **create-task.sh** - Create task with auto-ID
- **check-alignment.sh** - Verify feature/task status

## Usage

```bash
# Make executable
chmod +x docs/5day/scripts/*.sh

# Run script
./docs/5day/scripts/script-name.sh
```

**Note:** Prefer bash for portability. Use `set -e` for error handling.
