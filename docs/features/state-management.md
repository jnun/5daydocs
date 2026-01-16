# Feature: State Management

## Feature Status: LIVE

Centralized state tracking for tasks and bugs through a unified markdown file.

## Unified State Management
**Status**: LIVE
`docs/STATE.md` tracks both task and bug IDs:
- Tasks: Sequential integer IDs starting from 0
- Bugs: Sequential integer IDs starting from 0
- Single source of truth for all IDs
- Prevents ID collisions
- Updated with each new task or bug

## Task ID Section
**Status**: LIVE
- Located in `docs/STATE.md` under "Task State"
- Sequential integers (0, 1, 2, ...)
- Tracks highest used ID
- Updated when creating tasks

## Bug ID Section
**Status**: LIVE
- Located in `docs/STATE.md` under "Bug State"
- Sequential integers (0, 1, 2, ...)
- Tracks highest used bug ID
- Updated when creating bugs

## State File Format
**Status**: LIVE
Unified markdown format in `docs/STATE.md`:
- Separate sections for tasks and bugs
- Last updated timestamp for each section
- Highest ID tracking for each type
- Human-readable format
- Version controlled

## Automatic Initialization
**Status**: LIVE
State file created by setup.sh:
- Creates unified STATE.md from template
- Initializes task ID at 0
- Initializes bug ID at 0
- Sets proper format with both sections
- Ready for immediate use

## Manual State Updates
**Status**: LIVE
Clear process for maintaining state:
- Check STATE.md before creating items
- Update appropriate section (Task or Bug)
- Update timestamp and ID for that section
- Commit together with new items
- Single source of truth principle