# Bug Tracking System

Simple file-based bug tracking using markdown files and folder organization.

## Bug Lifecycle

### 1. Report Bug
Create a new bug file in `/work/bugs/`:
```bash
# Check BUG_STATE.md for next ID
cat work/bugs/BUG_STATE.md

# Create bug report
echo "# Bug Title" > work/bugs/001-description.md
```

### 2. Bug File Format
```markdown
# Bug Title

## Environment
- Browser/OS/Version
- Reproduction rate

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Notes
Additional context, error messages, screenshots
```

### 3. Convert to Task
Bugs become actionable through task creation:
```bash
# Create task referencing bug
echo "# Fix [Bug Title] (Bug #001)" > work/tasks/backlog/ID-fix-bug-001.md

# Archive the bug
git mv work/bugs/001-bug.md work/bugs/archived/
```

### 4. Archive
Once a bug is converted to a task or resolved:
```bash
git mv work/bugs/001-bug.md work/bugs/archived/
```

## File Naming Convention

- Format: `ID-description.md`
- IDs: Three-digit format (001, 002, 003)
- Description: kebab-case summary
- Examples:
  - `001-login-timeout-error.md`
  - `002-data-export-fails.md`
  - `003-ui-responsive-issue.md`

## BUG_STATE.md

Tracks the highest bug ID to prevent conflicts:
```markdown
# Bug State Tracking
Last Updated: YYYY-MM-DD
Current Highest Bug ID: 003
```

**Always update after creating a new bug!**

## Quick Commands

```bash
# View active bugs
ls work/bugs/*.md

# View archived bugs
ls work/bugs/archived/

# Search for specific bug
grep -r "search term" work/bugs/

# Count active bugs
ls work/bugs/*.md 2>/dev/null | wc -l
```

## Best Practices

1. **One bug, one file** - Keep reports focused
2. **Reproducible steps** - Always include how to recreate
3. **Convert quickly** - Bugs should become tasks ASAP
4. **Archive completed** - Keep active list clean
5. **Update BUG_STATE.md** - Prevent ID conflicts

## Integration with Tasks

Bugs are triaged and prioritized by converting them to tasks. This allows bugs to flow through the standard development pipeline (backlog → next → working → review → live).

Reference the original bug ID in the task for traceability:
- Task: `15-fix-login-bug-001.md`
- Links to: `archived/001-login-timeout-error.md`