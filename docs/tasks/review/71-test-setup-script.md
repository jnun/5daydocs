# Task 71: Test setup.sh with New Template Structure

**Feature**: none
**Created**: 2025-10-19


## Objective
Thoroughly test the setup.sh script to ensure it works correctly with the new unified template structure

## Test Scenarios
1. Test fresh installation in a new directory
2. Test GitHub with Issues workflow selection
3. Test GitHub with Jira workflow selection
4. Test Bitbucket with Jira workflow selection
5. Verify STATE.md gets created with correct date substitution

## Test Commands
```bash
# Create test directory
mkdir /tmp/test-5daydocs
cd /tmp/test-5daydocs

# Run setup (test different options)
/path/to/5daydocs/setup.sh

# Verify files were copied correctly
ls -la docs/
ls -la .github/workflows/ 2>/dev/null
ls -la bitbucket-pipelines.yml 2>/dev/null

# Clean up test
rm -rf /tmp/test-5daydocs
```

## Dependencies
- Tasks 66-70 must be completed
- All templates in new structure
- setup.sh updated with new paths

## Success criteria
- setup.sh runs without errors
- Templates copied to correct locations
- STATE.md has current date

## Problem
[Description of what needs to be done]
