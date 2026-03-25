# 5DayDocs — Agent Reference

> One file. Everything an AI agent needs to work with 5DayDocs in this project.

## What this is

Folder-based project management. Tasks are markdown files that move through pipeline folders. No database, no app — just git.

## Structure

```
docs/
├── STATE.md              # Next IDs — read before creating tasks/bugs
├── tasks/
│   ├── backlog/          # Planned, not started
│   ├── next/             # Sprint queue
│   ├── working/          # In progress (max 1 at a time)
│   ├── review/           # Done, awaiting approval
│   └── live/             # Shipped
├── features/             # Feature specifications
├── ideas/                # Rough concepts (use Feynman protocol)
├── bugs/                 # Bug reports
├── guides/               # How-to docs, technical procedures
├── examples/             # Code samples, configs
└── 5day/                 # Framework (do NOT edit — overwritten on update)
```

## Rules

1. **Check `docs/STATE.md` before creating tasks or bugs** — it has the next available ID
2. **Folder = status** — move files between folders to change status
3. **One task in `working/` at a time**
4. **Never edit files in `docs/5day/`** — they're framework files, overwritten on update
5. **Tasks describe outcomes, not implementation** — write "User can X" not "Add React component"
6. **Technical details go in `docs/guides/` or `docs/features/`**, not in task files

## File naming

| Type | Pattern | Example |
|------|---------|---------|
| Task | `[ID]-[description].md` | `42-add-login-button.md` |
| Bug | `BUG-[ID]-[description].md` | `BUG-3-login-fails.md` |
| Feature | `[name].md` | `user-authentication.md` |
| Idea | `[name].md` | `notification-system.md` |

## Commands

```bash
./5day.sh newtask "Description"     # Create task (auto-increments ID)
./5day.sh newbug "Description"      # Create bug report
./5day.sh newfeature "Name"         # Create feature spec
./5day.sh newidea "Name"            # Create idea for refinement
./5day.sh status                    # Show pipeline overview
./5day.sh help                      # All commands
```

## Task format

```markdown
# Task [ID]: [Short description]

**Feature**: /docs/features/[name].md (or "none")
**Created**: YYYY-MM-DD
**Depends on**: Task [ID] (or "none")
**Blocks**: Task [ID] (or "none")

## Problem
2-5 sentences. What's wrong and why it matters.

## Success criteria
- [ ] User can [do what]
- [ ] System shows [result]
- [ ] [Action] completes within [time]

## Notes
Links, dependencies, edge cases.
```

## Protocols (supplementary reading)

For deeper guidance on specific workflows:

- `docs/5day/ai/task-creation.md` — Interactive Q&A before writing tasks
- `docs/5day/ai/task-writing-rules.md` — What goes where (tasks vs guides vs features)
- `docs/5day/ai/feynman-method.md` — Breaking ideas into tasks (4-phase decomposition)
