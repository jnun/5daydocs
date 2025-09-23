# Work Folder Structure

The `/work` directory contains all active project management files, task tracking, and operational resources for the 5daydocs system.

## Core Directories

### /tasks
Task management pipeline with folder-based workflow states. Tasks flow through:
- `backlog/` - Planned, not started
- `next/` - Queued for current sprint
- `working/` - Currently being worked on (limit 1 per developer)
- `review/` - Built and awaiting approval
- `live/` - Completed and deployed

### /bugs
Bug tracking and archiving system:
- Active bugs: `/work/bugs/[ID]-description.md`
- Archived bugs: `/work/bugs/archived/`
- Bug state tracking: `BUG_STATE.md`

### /scripts
Automation and utility scripts:
- `setup.sh` - Initial project setup
- `check-alignment.sh` - Feature status analysis
- Other project-specific automation

### /designs
UI/UX mockups and design documentation. Store visual designs, wireframes, and interaction specifications here.

### /examples
Code snippets and implementation examples. Reference implementations that can be reused across the project.

### /data
Test and sample data files. Store JSON, CSV, and other data files used for testing or demonstrations.

## Key Files

- `STATE.md` - Tracks highest task ID number
- `bugs/BUG_STATE.md` - Tracks highest bug ID number

## Workflow Commands

```bash
# View current work
ls work/tasks/working/

# Move task through pipeline
git mv work/tasks/backlog/ID-name.md work/tasks/next/
git mv work/tasks/next/ID-name.md work/tasks/working/
git mv work/tasks/working/ID-name.md work/tasks/review/
git mv work/tasks/review/ID-name.md work/tasks/live/
```

## Best Practices

1. Always use `git mv` to preserve history when moving tasks
2. Keep only one task in `working/` at a time
3. Update STATE.md when creating new tasks
4. Archive bugs after converting to tasks