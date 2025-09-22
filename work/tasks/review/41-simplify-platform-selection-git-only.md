# Simplify Platform Selection to Git + GitHub Issues Only

## Problem
Setup.sh offers Jira and Bitbucket options that aren't implemented yet. This confuses users and creates false expectations.

## Desired Outcome
- Platform selection shows GitHub Issues as default/only option
- Jira and Bitbucket marked as "Coming Soon" if shown at all
- Script focuses on fully functional Git + GitHub Issues workflow
- Clear messaging that additional platforms are planned

## Testing Criteria
- [x] Setup only configures GitHub Issues workflow
- [x] No broken Jira/Bitbucket paths
- [x] User sees clear message about supported platforms
- [x] Script proceeds without platform selection or defaults to GitHub Issues