# Bug Tracking

→ **Full documentation: [DOCUMENTATION.md](/DOCUMENTATION.md#bug-reports)**

**Related:** [/docs/STATE.md](/docs/STATE.md) - Bug ID tracking

## What's Here

- **Active bugs** - `ID-description.md` files
- **archived/** - Bugs converted to tasks or resolved

## Quick Workflow

```bash
# Report bug (check STATE.md for ID)
echo "# Bug Title" > docs/work/bugs/ID-description.md

# Convert to task
echo "# Fix Bug #ID" > docs/work/tasks/backlog/TASK-ID-fix-bug.md
git mv docs/work/bugs/ID-bug.md docs/work/bugs/archived/
```

**Note:** Bug IDs tracked in /docs/STATE.md as 5DAY_BUG_ID