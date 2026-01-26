# Task 104: Sync create-task.sh with src/templates/project/TEMPLATE-task.md

**Feature**: none
**Created**: 2026-01-26

## Problem

`create-task.sh` generates tasks with different section names than `src/templates/project/TEMPLATE-task.md`:

| create-task.sh | src/templates/project/TEMPLATE-task.md |
|----------------|------------------|
| `## Desired Outcome` | `## Problem` |
| `## Testing Criteria` | `## Success criteria` |
| — | `## Notes` |

The template is the master. Scripts must generate files that match templates.

## Success criteria

- [ ] `create-task.sh` uses `## Problem` (not `## Desired Outcome`)
- [ ] `create-task.sh` uses `## Success criteria` (not `## Testing Criteria`)
- [ ] `create-task.sh` includes `## Notes` section
- [ ] Test: run `./5day.sh newtask "Test"` and compare output to template
