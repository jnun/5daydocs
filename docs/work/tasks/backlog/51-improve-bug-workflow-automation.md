# Task 51: Improve Bug Workflow Automation

## Problem
Bug handling is partially implemented but lacks the automation that tasks have. Users must manually create bug files, update BUG_STATE.md, and convert bugs to tasks.

## Missing Components
- No create-bug.sh script (unlike create-task.sh)
- No convert-bug-to-task.sh script
- BUG_STATE.md must be manually updated
- No INDEX.md in work/bugs/ explaining the workflow

## Desired Outcome
- Create work/scripts/create-bug.sh to automate bug creation
- Create work/scripts/bug-to-task.sh to convert bugs to tasks
- Both scripts update BUG_STATE.md automatically
- Add work/bugs/INDEX.md explaining bug workflow
- Bugs are as easy to manage as tasks

## Testing Criteria
- [ ] Can create bug with: ./work/scripts/create-bug.sh "Login fails"
- [ ] BUG_STATE.md automatically updated with new bug ID
- [ ] Can convert bug to task with one command
- [ ] Bug automatically moves to archived/ after conversion
- [ ] INDEX.md clearly explains the bug workflow