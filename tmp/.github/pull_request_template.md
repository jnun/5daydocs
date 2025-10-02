## Summary
<!-- Brief description of changes -->

## Related Task(s)
<!-- Reference task IDs from work/tasks/ -->
- Closes #[TASK_ID]
- Related: `work/tasks/[stage]/[ID]-[description].md`

## Changes Made
<!-- List key changes -->
-
-
-

## Testing
<!-- How were these changes tested? -->
- [ ] Manual testing completed
- [ ] Scripts run successfully
- [ ] Documentation updated

## Task Movement
<!-- Which tasks are moving through the pipeline? -->
```bash
# Tasks moving to review:
git mv work/tasks/working/ID-*.md work/tasks/review/

# Tasks moving to live:
git mv work/tasks/review/ID-*.md work/tasks/live/
```

## Checklist
- [ ] Task ID referenced in commit message
- [ ] work/STATE.md updated if new tasks created
- [ ] Task moved to appropriate folder
- [ ] Testing criteria from task completed
- [ ] Documentation updated if needed

---
*Following the 5DayDocs workflow: backlog → next → working → review → live*