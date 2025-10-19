# Task 79: Update All Documentation File Paths

**Feature**: /docs/features/core-workflow.md
**Created**: 2025-10-19

## Problem
After flattening, all documentation files (DOCUMENTATION.md, README.md, CLAUDE.md, INDEX.md files) contain references to old `docs/work/*` paths that need updating to new `docs/*` paths.

## Success Criteria
- [x] DOCUMENTATION.md updated with new paths
- [x] README.md updated with new paths
- [x] CLAUDE.md updated with new paths
- [x] All INDEX.md files updated with new paths
- [x] All path references are consistent and correct

## Related Tasks
- Depends on Task 78 (planning)

## Completion Notes
- Updated DOCUMENTATION.md structure diagram and all path references
- Updated README.md with sed batch replacements
- Updated CLAUDE.md task management section
- Updated INDEX.md with new simplified paths
- Used sed for batch replacements: docs/work/tasks/ → docs/tasks/, etc.
