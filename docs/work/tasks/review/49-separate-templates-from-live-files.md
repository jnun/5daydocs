# Task 49: Separate Template Files from Live Project Files

## Problem
We're dogfooding 5daydocs to build 5daydocs, which means our actual project files (STATE.md, task files, etc.) are mixed with what should be template files for new projects. When setup.sh runs, it needs clean templates, not our active project data.

Currently setup.sh creates a fresh STATE.md starting at 0, but we should ensure ALL copied files are appropriate templates, not snapshots of our working project.

## Desired Outcome
- Create a templates/ directory with clean starter files
- Templates should be generic, not containing our project's specific data
- setup.sh copies from templates/, not from our live working files
- Clear separation between "5daydocs the project" and "5daydocs the tool"
- Documentation explains we dogfood the tool

## Testing Criteria
- [ ] New projects don't receive any of our task numbers or project-specific content
- [ ] Templates contain helpful starter content without live data
- [ ] setup.sh only copies from designated template sources
- [ ] Users understand the distinction between the tool and our project using it