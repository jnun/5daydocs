# Task 50: Create Template Files for STATE.md and BUG_STATE.md

## Problem
Our live STATE.md shows "Highest Task ID: 48" and BUG_STATE.md has our real bug counts. When setup.sh runs, it currently generates fresh STATE files starting at 0, but if we update the format of these files (add new fields, change structure), we need templates that reflect those changes without our project's data.

## Affected Files
- work/STATE.md (currently generated inline in setup.sh)
- work/bugs/BUG_STATE.md (currently generated inline in setup.sh)

## Desired Outcome
- One simplified STATE.md file that contains all state related details in a unform easily automated manner
- Create work/templates/STATE.md.template with ID: 0
- Remove work/bugs/BUG_STATE.md and ensure that its purpose is managed by STATE.md
- setup.sh copies template instead of generating inline
- When we update STATE.md format, update the template too
- Templates stay clean while our live files contain real data
- Update feature documentation in docs/features that mention state management
- Update feature documentation in docs/features that mention bugs or the bug feature in this tool

## Testing Criteria
- [ ] Template files exist with starting values (0)
- [ ] setup.sh uses templates, not inline generation
- [ ] New projects get clean STATE file
- [ ] Format changes propagate to templates (update README.md)
- [ ] Docs in docs/features are up to date and accurately reflect the location and functions of state related files
