# Task Pipeline

→ **Full documentation: [DOCUMENTATION.md](/DOCUMENTATION.md#tasks-work-items)**

**Related:** [/docs/STATE.md](/docs/STATE.md) - Task ID tracking

## Pipeline Flow

**backlog/** → **next/** → **working/** → **review/** → **live/**

- **backlog/** - All planned work
- **next/** - Sprint queue
- **working/** - Active now (1 task max!)
- **review/** - Built, needs approval
- **live/** - Completed/deployed

## Quick Commands

```bash
# Move task forward
git mv docs/tasks/backlog/ID-name.md docs/tasks/next/
git mv docs/tasks/next/ID-name.md docs/tasks/working/
git mv docs/tasks/working/ID-name.md docs/tasks/review/
git mv docs/tasks/review/ID-name.md docs/tasks/live/
```

**Critical:** Only ONE task in working/ at a time.