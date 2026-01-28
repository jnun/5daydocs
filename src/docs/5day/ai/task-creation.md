# AI Task Creation Protocol

## Core Principle

**Write tasks in plain English, describing what users see and do.**

Tasks define WHAT needs to happen. The implementer chooses HOW. This separation keeps tasks clear for any team member and allows flexibility in implementation.

## Why Plain English Works

When tasks describe observable behaviors:
- Any team member can understand the goal
- The implementer can choose the best technical approach
- Success is easy to verify ("Can the user do X? Yes/No")
- Tasks remain valid even if technology choices change

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

## Success Criteria Format

Write criteria as observable behaviors - things you can see, click, or measure.

Use patterns like:
- "[Who] can [do what]"
- "[Thing] shows/displays [result]"
- "[Action] completes within [time]"

### Examples

```markdown
## Success criteria
- [ ] User can log in with email and password
- [ ] Error message appears when password is wrong
- [ ] Session persists across browser refresh
- [ ] Logout button clears session and redirects to home
- [ ] Dashboard loads within 2 seconds
- [ ] Search results update as user types
- [ ] Export downloads a CSV with all visible rows
```

Each criterion describes something you can verify by using the app.

## Template for AI Responses

When a user asks to create a task, start with questions:

```
Before I create a task, let me make sure I understand:

1. **What's happening now?**
   [Ask about current state]

2. **What should happen instead?**
   [Ask about desired outcome]

3. **How will we know it's working?**
   [Ask for testable behaviors]
```

After the Q&A, summarize and confirm before creating the task file.

## What Goes in Each Section

### ## Problem
- Plain English description of the situation
- Context someone unfamiliar would need
- The "why" behind the request
- Written as you'd explain it to a colleague

### ## Success criteria
- Behavioral checkboxes: "User can X" or "App shows Y"
- Observable outcomes anyone can verify
- Testable conditions with clear pass/fail

### ## Notes
- Dependencies or blockers
- Links to related docs or issues
- Edge cases worth considering
- Constraints or context for the implementer

## Example Interaction

**User:** "Create a task for adding user authentication"

**AI Response:**
"Before I create this task, a few questions:

1. What kind of authentication? (Email/password? Social login? Both?)
2. What should happen after login? (Redirect somewhere? Show dashboard?)
3. What about existing users - is there a migration needed?
4. How should failed logins behave?"

**After Q&A, task includes:**
```markdown
## Success criteria
- [ ] User can create account with email and password
- [ ] User can log in with valid credentials
- [ ] Invalid credentials show clear error message
- [ ] Logged-in state persists across page refresh
- [ ] User can log out from any page
```

Each criterion describes what someone experiences when using the app.
