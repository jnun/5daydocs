# Task 44: Copy All Required Documentation Files

## Problem
Projects need the core documentation files to understand and use 5daydocs. Ensure all instruction files are copied or created appropriately without conflicting with the project's own files.

## Desired Outcome
Files created/copied by setup.sh:
- DOCUMENTATION.md (full 5daydocs guide)
- INDEX.md files in 5daydocs folders only (work/, docs/ and their subfolders)
- Template files in appropriate directories (task, bug, feature templates)
- Never touch existing README.md (that belongs to the project, not 5daydocs)

## Testing Criteria
- [ ] DOCUMENTATION.md present after setup
- [ ] Existing README.md is never modified or replaced
- [ ] INDEX.md files in work/ and docs/ folders explain their purpose
- [ ] Templates available in work/tasks/, work/bugs/, docs/organizational-process-assets/templates/
- [ ] Documentation is self-contained and tool-agnostic