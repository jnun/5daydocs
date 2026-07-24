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

Helpful context for the implementer — not part of the task definition itself. Leave empty if there is nothing to add. When it helps, point to:

- **Guides/specs that help** — `docs/guides/…`, `docs/features/…` for the procedures, specifications, or code samples the implementer will need.
- **Existing files this touches — reuse, don't reinvent** — name the files you already know are involved so the implementer repurposes existing code instead of rebuilding it. This is also what an audit later checks for design fit.
- **Edge cases or non-obvious constraints** — anything that isn't obvious from the Problem or Success criteria.

Keep these as pointers, not payload: link to the guide or file, don't inline the implementation. The task says WHAT; guides and examples say HOW.

Example:
```markdown
## Notes
Guides/specs: docs/features/task-automation.md, docs/guides/script-template-sync.md
Existing files (reuse, don't reinvent): docs/5day/lib.sh (sed helpers), docs/5day/scripts/create-task.sh
Edge case: template HTML comments must survive placeholder substitution
```

## Verify Before Saving

1. Someone unfamiliar with the codebase can understand the problem
2. Success criteria describe observable behaviors
3. Technical context lives in `docs/guides/`, `docs/examples/`, or `docs/features/`
4. The Notes section links to any technical documents the implementer needs
