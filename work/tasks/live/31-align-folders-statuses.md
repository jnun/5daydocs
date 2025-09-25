# Task 31: Align Folder Names with Status Values

**Feature**: /docs/organizational-process-assets/processes/folder-based-project-management.md
**Created**: 2025-01-20

## Problem
The system uses inconsistent naming between task folders and feature statuses:
- Folder `active/` vs status `WORKING`
- Folder `archive/` vs status `LIVE`
- Various documents reference old folder names
- GitHub and Jira integrations use old mappings

## Success Criteria
- [x] Create feature documentation for folder-based project management
- [x] Rename folders: active/ → working/, archive/ → live/
- [x] Update DOCUMENTATION.md with new folder structure
- [x] Update CLAUDE.md with new conventions
- [x] Update README.md with new folder names
- [x] Update setup.sh to create correct folders
- [x] Update all scripts in work/scripts/ and scripts/
- [x] Update GitHub workflow files for new folder mappings
- [x] Update Bitbucket pipeline for new folder mappings
- [x] Update feature template with new status values
- [x] Update all guides that reference old folders
- [x] Ensure Jira status mappings align
- [x] Test complete workflow with new structure

## Files to Update

### Core Documentation (COMPLETED)
- [x] DOCUMENTATION.md - Updated folder structure and status meanings
- [x] CLAUDE.md - Updated all references to working/ and live/
- [x] README.md - Updated workflow and status list
- [x] docs/organizational-process-assets/templates/TEMPLATE-feature.md - Added all five status values
- [x] work/tasks/TEMPLATE-task.md - Updated to reference working/ and live/

### Scripts (COMPLETED)
- [x] setup.sh - Updated to create working/ and live/ folders
- [x] work/scripts/create-task.sh - No changes needed (no folder refs found)

### Integrations (COMPLETED)
- [x] .github/workflows/sync-tasks-to-jira.yml - Updated to working/live mappings
- [x] .github/workflows/sync-jira-to-git.yml - Updated to working folder
- [x] .github/workflows/sync-tasks-to-issues.yml - Updated labels and folders
- [x] bitbucket-pipelines.yml - Updated to working/live mappings

### Guides (COMPLETED)
- [x] docs/guides/git-source-of-truth-sync.md - Updated all examples
- [x] docs/guides/jira-kanban-setup.md - Updated folder mapping table
- [x] docs/guides/quick-reference.md - Updated commands and lifecycle
- [x] docs/organizational-process-assets/integrations/jira-integration.md - Changed status to WORKING

## Status Alignment Table

| Old Folder | New Folder | Status Value | Description |
|------------|------------|--------------|-------------|
| backlog/ | backlog/ | BACKLOG | Planned, not started |
| next/ | next/ | NEXT | Queued for this sprint |
| active/ | working/ | WORKING | Being worked on now |
| review/ | review/ | REVIEW | Built, awaiting approval |
| archive/ | live/ | LIVE | In production or approved for deployment |

## Correct Project Structure

```
work/
├── tasks/                  # Task management
│   ├── backlog/            # Planned, not started
│   ├── next/               # Queued for this sprint
│   ├── working/            # Being worked on now
│   ├── review/             # Built, awaiting approval
│   └── live/               # In production or approved for deployment
```

## Status Order (Workflow Progression)

1. **BACKLOG** - Planned, not started
2. **NEXT** - Queued for this sprint
3. **WORKING** - Being worked on now
4. **REVIEW** - Built, awaiting approval
5. **LIVE** - In production or approved for deployment