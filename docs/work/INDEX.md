# Work Directory

→ **Full documentation: [DOCUMENTATION.md](/DOCUMENTATION.md#common-workflows)**

**Related:** [/docs/STATE.md](/docs/STATE.md) - Task/bug ID tracking

## What's Here

- **tasks/** - Task pipeline (backlog → next → working → review → live)
- **bugs/** - Bug reports and archived bugs
- **scripts/** - Automation tools
- **designs/** - UI mockups and wireframes
- **examples/** - Code snippets for reuse
- **data/** - Test and sample data

## Quick Commands

```bash
# Move task through pipeline
git mv docs/work/tasks/backlog/ID-name.md docs/work/tasks/next/
git mv docs/work/tasks/next/ID-name.md docs/work/tasks/working/
```

**Rule:** Only one task in working/ at a time.