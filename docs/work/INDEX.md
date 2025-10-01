# docs/work/ Directory Index

The `/docs/work/` directory contains all active project management files, task tracking, and operational resources for the 5DayDocs system.

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
- Active bugs: `/docs/work/bugs/[ID]-description.md`
- Archived bugs: `/docs/work/bugs/archived/`
- Bug state tracking: Integrated in `/docs/STATE.md`

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

- `/docs/STATE.md` - Tracks highest task and bug ID numbers (central location)

## Workflow Commands

```bash
# View current work
ls docs/work/tasks/working/

# Move task through pipeline
git mv docs/work/tasks/backlog/ID-name.md docs/work/tasks/next/
git mv docs/work/tasks/next/ID-name.md docs/work/tasks/working/
git mv docs/work/tasks/working/ID-name.md docs/work/tasks/review/
git mv docs/work/tasks/review/ID-name.md docs/work/tasks/live/
```

## Best Practices

1. Always use `git mv` to preserve history when moving tasks
2. Keep only one task in `working/` at a time
3. Update `/docs/STATE.md` when creating new tasks
4. Archive bugs after converting to tasks