# Task Writing Rules

## Core Rule

**Write tasks in natural language. Put technical details in docs/guides/, docs/examples/, or docs/features/.**

## Where Content Belongs

| Content Type | Location | Example |
|--------------|----------|---------|
| Problems and outcomes | `docs/tasks/` | "Users need to log in faster" |
| How to implement something | `docs/guides/` | Step-by-step procedures |
| Code samples and patterns | `docs/examples/` | Shell scripts, config files |
| System specifications | `docs/features/` | API contracts, data schemas |

## Task Structure

### Problem Section

Write 2-5 sentences explaining what needs solving and why. Describe it as you would to a colleague unfamiliar with this area.

**Example:**
```markdown
## Problem

Users are confused when creating new tasks because the generated files
look different from the template. The section headings vary, which makes
it hard to know which format is correct.
```

### Success Criteria Section

Write observable behaviors that anyone can verify by using the system.

**Patterns that work:**
- "User can [do what]"
- "System shows [result]"
- "[Action] completes within [time]"

**Example:**
```markdown
## Success criteria

- [ ] User can create a task and it matches the template format
- [ ] All section headings are consistent between generated and template files
- [ ] Running the task creation command produces a valid task file
```

### Notes Section

Link to technical context when the implementer needs specifications, procedures, or code samples.

**Example:**
```markdown
## Notes

Technical specification: docs/features/task-automation.md
Implementation guide: docs/guides/script-template-sync.md
Code patterns: docs/examples/task-generation.sh
```

## The Test

Before saving a task, verify:

1. Someone unfamiliar with the codebase can understand the problem
2. Success criteria describe observable behaviors
3. Technical context lives in docs/guides/, docs/examples/, or docs/features/
4. The Notes section links to any technical documents the implementer needs

## Quick Reference

| When you need to write... | Put it in... |
|---------------------------|--------------|
| "The user can..." | Task success criteria |
| "Run this command..." | docs/guides/ |
| "Here's the code..." | docs/examples/ |
| "This endpoint returns..." | docs/features/ |
| "Compare these configs..." | docs/guides/ or docs/features/ |
| "This file should contain..." | docs/features/ or docs/guides/ |
