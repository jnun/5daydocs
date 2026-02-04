# Bug Tracking

→ **Full documentation: [DOCUMENTATION.md](/DOCUMENTATION.md#bug-reports)**

**Related:** [/docs/STATE.md](/docs/STATE.md) - Bug ID tracking

## What's Here

- **Active bugs** - `ID-description.md` files
- **archived/** - Bugs converted to tasks or resolved

## Quick Workflow

```bash
# Report a new bug
./5day.sh newbug "Brief description of the bug"

# Convert to task
./5day.sh newtask "Fix: brief description"

# Archive resolved bug
git mv docs/bugs/ID-description.md docs/bugs/archived/
```

**Note:** Bug IDs tracked in /docs/STATE.md as 5DAY_BUG_ID