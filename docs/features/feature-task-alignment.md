# Feature: Feature-Task Alignment

## Feature Status: LIVE

System for maintaining consistency between feature documentation and task implementation.

## Feature Status Tracking
**Status**: LIVE
Each feature capability has an explicit status tag:
- Tracks individual capability progress
- Matches folder-based task states
- Clear visibility of feature completeness

## Task-Feature Linking
**Status**: LIVE
Every task references its related feature:
- `**Feature**: /docs/features/FEATURE.md` in task files
- Supports "multiple" for cross-feature tasks
- Supports "none" for infrastructure tasks

## Alignment Analysis Script
**Status**: LIVE
`work/scripts/analyze-feature-alignment.sh` validates consistency:
- Shows all features and current status
- Lists tasks per feature
- Identifies misalignments
- Finds orphaned tasks without features

## Status Synchronization
**Status**: LIVE
Feature status updates when capabilities complete:
- Feature marked LIVE when capability ships
- Tasks can continue for enhancements
- Features persist, tasks are temporary

## Best Practices Enforcement
**Status**: LIVE
Guidelines for maintaining alignment:
- Run alignment check after moving to review/live
- Check before sprint planning
- Update feature docs when capabilities go live
- Track capability-level status within features