# 5DayDocs

Project management in markdown files. Like Jira, but folders and plain text.

## Boundaries

**Framework files (do not edit):**
- `DOCUMENTATION.md`
- `5day.sh` (root symlink)
- `docs/5day/` (framework scripts, AI instructions, docs)

**Your content (create and edit freely):**
- `docs/tasks/` — your tasks
- `docs/bugs/` — your bug reports
- `docs/features/` — your feature specs
- `docs/guides/` — your documentation
- `docs/tests/` — your test plans
- `docs/STATE.md` — your project state (see format below)

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
├── 5day/               # FRAMEWORK (do not edit)
│   ├── scripts/        # 5day.sh, create-task.sh, etc.
│   └── ai/             # AI instructions
├── STATE.md            # Project state (ID tracking)
├── tasks/              # Your work items
│   ├── backlog/        # Planned
│   ├── next/           # Sprint queue
│   ├── working/        # In progress
│   ├── review/         # Awaiting approval
│   └── live/           # Complete
├── features/           # Your feature specs
├── bugs/               # Your bug reports
├── guides/             # Your documentation
└── tests/              # Your test plans
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
