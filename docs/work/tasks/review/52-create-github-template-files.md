# Task 52: Create GitHub Issue and PR Template Files

## Problem
The 5daydocs project should include GitHub template files (.github/ISSUE_TEMPLATE/ and .github/pull_request_template.md) that align with the 5DayDocs workflow, making it easier for users to contribute and report issues using the folder-based task management system.

## Desired Outcome
Create template files that:
- Issue templates for bugs and feature requests that map to 5DayDocs task structure
- PR template that references task IDs and follows the workflow
- Templates should guide users to follow the 5DayDocs methodology
- Should be copied by setup.sh when installing to user projects

## Implementation Details
1. Create .github/ISSUE_TEMPLATE/bug_report.md
2. Create .github/ISSUE_TEMPLATE/feature_request.md
3. Create .github/pull_request_template.md
4. Update setup.sh to copy these templates during installation
5. Templates should reference task IDs and the folder-based workflow

## Testing Criteria
- [ ] Bug report template creates issues that map to work/bugs/
- [ ] Feature request template creates issues that map to work/tasks/backlog/
- [ ] PR template encourages linking to task IDs
- [ ] Setup.sh copies templates to target projects
- [ ] Templates render correctly on GitHub