# Task 106: Standardize script output and error handling

**Feature**: none
**Created**: 2026-01-26

## Problem

Scripts have inconsistent patterns:

| Issue | Files |
|-------|-------|
| Says `5d newtask` not `./5day.sh newtask` | create-task.sh:93, create-feature.sh:93 |
| Verbose "Next steps" output | create-task.sh:144-147, create-feature.sh:91-94 |
| Missing `set -e` | create-feature.sh |
| Missing Ideas in context | ai-context.sh |

Output philosophy (LEAN):
- Ideas: high level, in development → minimal output
- Features: well defined, complete → confirmation + location
- Tasks: atomic, actionable → confirmation + location
- All: fail fast (`set -e`), consistent command references

## Success criteria

- [ ] All scripts use `set -e`
- [ ] All scripts reference `./5day.sh` not `5d`
- [ ] Output is minimal: confirmation + file path
- [ ] ai-context.sh includes Ideas section
- [ ] Consistent color usage across all scripts

## Notes

create-idea.sh is the model for clean output:
```
Created idea: docs/ideas/name.md

Next: Open the file and work through each section.
```
