# Feature: Bug Tracking

## Feature Status: LIVE

The bug tracking system is fully implemented for capturing and managing bug reports.

## Bug Report Creation
**Status**: LIVE
Bug reports can be created in `docs/bugs/` with sequential IDs and severity levels.

## Severity Classification
**Status**: LIVE
Four severity levels for prioritization:
- CRITICAL: System down, data loss, security breach
- HIGH: Major feature broken, blocking users
- MEDIUM: Feature partially broken, has workaround
- LOW: Minor issue, cosmetic

## Bug-to-Task Conversion
**Status**: LIVE
Bugs can be converted to tasks for tracking through the development pipeline:
- Create task referencing bug report
- Move bug to `docs/bugs/archived/`
- Track fix through standard task workflow

## Bug State Management
**Status**: LIVE
Automatic ID management through `docs/STATE.md`:
- Bug IDs tracked in unified state file
- Sequential integer IDs (0, 1, 2, ...)
- Central tracking in "Bug State" section
- Prevents ID collisions

## Archival System
**Status**: LIVE
Processed bugs moved to `docs/bugs/archived/` for historical reference:
- Maintains complete bug history
- Keeps active bug directory clean
- Preserves original reports

## Bug Report Format
**Status**: LIVE
Standardized markdown template for consistency:
- Reporter information
- Severity level
- Description and expected behavior
- Reproduction steps
- Environment details