# Create Template Files for STATE.md and BUG_STATE.md

## Problem
Our live STATE.md shows "Highest Task ID: 48" and BUG_STATE.md has our real bug counts. When setup.sh runs, it currently generates fresh STATE files starting at 0, but if we update the format of these files (add new fields, change structure), we need templates that reflect those changes without our project's data.

## Affected Files
- work/STATE.md (currently generated inline in setup.sh)
- work/bugs/BUG_STATE.md (currently generated inline in setup.sh)

## Desired Outcome
- Create work/templates/STATE.md.template with ID: 0
- Create work/templates/BUG_STATE.md.template with ID: 0
- setup.sh copies templates instead of generating inline
- When we update STATE.md format, update the template too
- Templates stay clean while our live files contain real data

## Testing Criteria
- [ ] Template files exist with starting values (0)
- [ ] setup.sh uses templates, not inline generation
- [ ] New projects get clean STATE files
- [ ] Format changes propagate to templates