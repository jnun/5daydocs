# Feature: State Management

## Feature Status: LIVE

Centralized state tracking for tasks and bugs through dedicated markdown files.

## Task ID Management
**Status**: LIVE
`work/STATE.md` tracks task IDs:
- Sequential integer IDs starting from 0
- Single source of truth for next ID
- Prevents ID collisions
- Updated with each new task

## Bug ID Management
**Status**: LIVE
`work/bugs/BUG_STATE.md` tracks bug IDs:
- Three-digit format (001, 002, etc.)
- Separate sequence from tasks
- Central tracking file
- Updated with each new bug

## State File Format
**Status**: LIVE
Consistent markdown format for state files:
- Last updated timestamp
- Highest ID tracking
- Human-readable format
- Version controlled

## Automatic Initialization
**Status**: LIVE
State files created by setup.sh:
- Creates STATE.md with ID 0
- Creates BUG_STATE.md with ID 0
- Sets proper initial format
- Ready for immediate use

## Manual State Updates
**Status**: LIVE
Clear process for maintaining state:
- Check before creating items
- Update after creation
- Commit together with new items
- Single source of truth principle