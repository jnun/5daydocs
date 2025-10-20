# Task 32: Add Platform Configuration to Setup Script

**Feature**: none
**Created**: 2025-10-19


## Problem
Allow users to configure their platform choice during setup:
- GitHub with GitHub Issues (default)
- GitHub with Jira
- Bitbucket with Jira

Configuration will determine whether GitHub Actions workflows are included.

## Requirements
1. Add platform selection prompt after project path input
2. Store configuration choice
3. Conditionally copy GitHub Actions based on selection
4. Maintain backward compatibility with existing installations

## Implementation Notes
- Use simple text-based menu (1,2,3 selection)
- Default to GitHub + GitHub Issues if user presses Enter

## Success criteria
- [ ] [Add success criteria here]
