# Task 69: Update setup.sh Script for New Template Paths

## Objective
Update all template paths in `setup.sh` to use the new unified `/templates/` structure

## Path Changes Required
```bash
# Old paths → New paths
distribution-templates/README.md → templates/project/README.md
distribution-templates/STATE.md → templates/project/STATE.md
docs/work/templates/STATE.md.template → templates/project/STATE.md.template
templates/github-workflows/*.yml → templates/workflows/github/*.yml
templates/bitbucket-pipelines.yml.template → templates/workflows/bitbucket/bitbucket-pipelines.yml.template
```

## Files to Update
- `/setup.sh` (main setup script)
- Any other scripts that reference template paths

## Dependencies
- Tasks 67 and 68 must be completed (files moved to new locations)

## Success Criteria
- setup.sh uses only new template paths
- Running setup.sh successfully copies templates from new locations
- No references to old template paths remain