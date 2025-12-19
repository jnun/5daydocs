# CLAUDE.md - AI Guide for 5DayDocs

## Philosophy
**No databases, no apps—just folders and markdown files.**
- Everything is plain text and version controlled.
- The `docs/` folder holds everything related to project tasks.
- `STATE.md` is the single source of truth for IDs and versioning.

## Directory Structure
- `docs/tasks/`: Task pipeline (backlog → next → working → review → live).
- `docs/bugs/`: Bug tracking.
- `docs/features/`: Feature specifications.
- `docs/guides/`: Technical and user guides.
- `docs/tests/`: Test plans and results.
- `docs/scripts/`: Automation scripts.
- `docs/STATE.md`: Tracks task/bug IDs and global state.

## Common Commands
Always use the provided scripts in `docs/scripts/` or the `5day.sh` wrapper.

- **Create Task**: `./docs/scripts/create-task.sh "Task Name"`
- **Create Feature**: `./docs/scripts/create-feature.sh "Feature Name"`
- **Check Alignment**: `./docs/scripts/check-alignment.sh`
- **Get Context**: `./docs/scripts/ai-context.sh` (if available)

## Rules for Editing
1.  **STATE.md**: NEVER edit `STATE.md` manually unless you are fixing a corruption. Use scripts to increment IDs.
2.  **Task Moves**: Use `git mv` to move tasks between folders (e.g., `git mv docs/tasks/next/123-task.md docs/tasks/working/`).
3.  **File Naming**: Follow the pattern `ID-description.md` (e.g., `101-login-page.md`).
4.  **Task Content**: Always update the status header in task files when moving them.

## Style Guide
- Use Markdown for all documentation.
- Keep descriptions concise but clear.
- Use checkboxes `[ ]` for sub-tasks.
