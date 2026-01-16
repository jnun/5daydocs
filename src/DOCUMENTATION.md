# 5DayDocs

Project management in markdown files. Like Jira, but folders and plain text.

## Boundaries

**5DayDocs owns:** `DOCUMENTATION.md`, `docs/`
**Your project owns:** Everything else

Updates come from upstream. Use the system as-is.

## AI Agents

This file governs `docs/`. Read it before modifying any task, bug, or feature.

**Rules:**
1. `docs/` is the active project management system — not source code, not stale
2. Tasks in `review/` and `live/` are completed work — old dates mean done, not abandoned
3. Always read `STATE.md` before creating tasks (get next ID)
4. Use `./5day.sh` commands when available — don't create task files manually
5. Move tasks by changing folders — folder location = status

**Folder meanings:**
| Folder | Status |
|--------|--------|
| `backlog/` | Planned, not started |
| `next/` | Queued for current sprint |
| `working/` | Actively being worked on |
| `review/` | Done, awaiting approval |
| `live/` | Shipped/complete |

**Do not assume** old file dates mean abandoned. A task from months ago in `live/` is completed history.

---

## Structure

```
docs/
├── STATE.md            # Task/bug ID tracking (source of truth)
├── tasks/              # Work items moving through pipeline
│   ├── backlog/        # Planned
│   ├── next/           # Sprint queue
│   ├── working/        # In progress
│   ├── review/         # Awaiting approval
│   └── live/           # Complete
├── features/           # What to build (permanent specs)
├── bugs/               # Bug reports
├── guides/             # How things work
└── tests/              # Test plans and results
```

## Commands

```bash
./5day.sh newtask "Description"    # Create task
./5day.sh status                   # View work
./5day.sh help                     # All commands
```

## Moving Tasks

Tasks move through folders. Use `git mv` or `mv` (then commit):

```bash
git mv docs/tasks/backlog/ID-name.md docs/tasks/next/      # Queue
git mv docs/tasks/next/ID-name.md docs/tasks/working/      # Start
git mv docs/tasks/working/ID-name.md docs/tasks/review/    # Submit
git mv docs/tasks/review/ID-name.md docs/tasks/live/       # Complete
```

If `git mv` fails, use `mv` and commit the change.

## Naming

| Type | Format | Example |
|------|--------|---------|
| Task/Bug | `ID-description.md` | `12-fix-auth-error.md` |
| Feature | `name.md` | `user-authentication.md` |

IDs are sequential integers from `STATE.md`. Always check STATE.md for the next ID.

## Key Concepts

**Features** = Permanent specs. What capabilities exist.
**Tasks** = Temporary work. Files that move through folders.
**STATE.md** = Source of truth for IDs. Check before creating tasks/bugs.

## Creating Work

**Task:**
```bash
./5day.sh newtask "Fix login timeout"
```
Creates `docs/tasks/backlog/[next-ID]-fix-login-timeout.md` and updates STATE.md.

**Bug:**
```bash
./5day.sh newbug "Button unresponsive on mobile"
```
Creates `docs/bugs/[next-ID]-button-unresponsive-on-mobile.md` and updates STATE.md.

## Templates

Use templates in each folder:
- `docs/tasks/TEMPLATE-task.md`
- `docs/features/TEMPLATE-feature.md`
- `docs/bugs/TEMPLATE-bug.md`

---

*Plain folders and markdown. That's it.*
