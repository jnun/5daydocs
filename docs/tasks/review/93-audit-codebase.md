# Task 93: Audit Entire Codebase

**Feature**: none
**Created**: 2025-01-15

## Problem
After significant restructuring and cleanup, the codebase needs a systematic audit to ensure all files, scripts, and references are consistent and correct. This includes verifying paths, removing stale references, and ensuring documentation matches implementation.

## Success criteria
- [x] Audit all shell scripts (setup.sh, update.sh, 5day.sh, docs/scripts/*.sh) for outdated paths
- [x] Audit all templates in src/templates/ for accuracy
- [x] Verify GitHub workflow files reference correct paths
- [x] Check all markdown files for broken links or outdated references
- [x] Ensure src/ and docs/ are properly synchronized where needed
- [x] Verify setup.sh copies all necessary files from src/
- [x] Confirm update.sh pulls from correct source locations
- [x] Remove any remaining references to old structure (work/, CLAUDE.md, etc.)

## Notes
This audit follows the restructuring work that:
- Removed CLAUDE.md from distribution
- Added AGENTS.md and llms.txt as AI discovery files (not distributed)
- Simplified DOCUMENTATION.md
- Cleaned up redundant files (DISTRIBUTION.md, INDEX.md)
- Added templates to src/templates/project/

## Completion Notes (2025-01-15)

### Changes Made
1. **Templates (src/templates/, templates/, tmp/)**: Updated all GitHub templates, workflow files, and issue templates to use `docs/tasks/`, `docs/bugs/`, `docs/STATE.md` instead of `work/tasks/`, `work/bugs/`, `work/STATE.md`

2. **GitHub templates (.github/)**: Updated pull_request_template.md, bug_report.md, feature_request.md, task.md with correct paths

3. **Documentation (docs/)**:
   - Updated INDEX.md files in docs/tasks/, docs/bugs/, docs/scripts/
   - Updated feature docs (bug-tracking.md, sprint-planning.md, state-management.md, task-automation.md, feature-task-alignment.md, jira-integration.md)
   - Updated guides (quick-reference.md, git-source-of-truth-sync.md, jira-kanban-setup.md, jira-integration-setup.md)

4. **setup.sh**: Removed dead fallback code for docs/work/INDEX.md (old structure)

5. **Backlog tasks**: Updated task descriptions in backlog/ to reflect new paths

### Files Intentionally Not Changed
- `scripts/update.sh`: Contains migration detection code that checks for old structure - this is intentional
- `docs/tasks/live/` and `docs/tasks/review/`: Historical records describing past changes - preserved for history
- `docs/guides/version-management.md`: Documents the old→new path mapping for reference
