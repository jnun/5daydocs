# AI Task Creation Protocol

## Core Principle

**Write tasks in plain English, describing what users see and do.** Tasks define WHAT needs to happen. The implementer chooses HOW.

## Where Content Belongs

| Content Type | Location |
|---|---|
| Problems and outcomes | `docs/tasks/` |
| How to implement | `docs/guides/` |
| Code samples and patterns | `docs/examples/` |
| System specifications | `docs/features/` |

## The Q&A Process

Before creating any task, work through these questions with the user:

### 1. Understand the Problem

Ask:
- "What's happening now?"
- "What should happen instead?"
- "When does this occur? (Always? Sometimes? Under specific conditions?)"

Wait for answers. Build understanding together.

### 2. Clarify the Scope

Ask:
- "Is this about [specific thing] or something broader?"
- "Are there related issues we should address together or separately?"
- "What's the boundary of this task?"

### 3. Define Success Behaviorally

Ask:
- "When this is done, what will a user be able to do?"
- "How would you test that it works?"
- "What would you check to verify it's complete?"

The answers become the success criteria.

### 4. Confirm Understanding

Before writing anything, summarize back:
- "So the problem is [X], and we'll know it's fixed when [Y]. Is that right?"

Proceed after confirmation.

## Task Structure

### Problem Section

Write 2-5 sentences explaining what needs solving and why. Describe it as you would to a colleague unfamiliar with this area.

### Success Criteria Section

Write observable behaviors that anyone can verify.

Patterns that work:
- "User can [do what]"
- "App shows [result]"
- "[Action] completes within [time]"

Example:
```markdown
## Success criteria
- [ ] User can log in with email and password
- [ ] Error message appears when password is wrong
- [ ] Session persists across browser refresh
```

### Notes Section

Link to technical context when the implementer needs specifications, procedures, or code samples.

Example:
```markdown
## Notes
Technical specification: docs/features/task-automation.md
Implementation guide: docs/guides/script-template-sync.md
```

## Verify Before Saving

1. Someone unfamiliar with the codebase can understand the problem
2. Success criteria describe observable behaviors
3. Technical context lives in `docs/guides/`, `docs/examples/`, or `docs/features/`
4. The Notes section links to any technical documents the implementer needs
