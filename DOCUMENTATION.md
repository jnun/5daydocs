# 5DayDocs

Project management in markdown files. Like Jira, but folders and plain text.

## Task documents describe outcomes in plain language docs/tasks/*/*
- Explain WHAT should happen so anyone can understand the goal
- Keep implementation details in docs/guides/ and link to them when needed

## Boundaries

**Framework files (do not edit):**
- `DOCUMENTATION.md`
- `5day.sh`
- `docs/5day/` (framework scripts, AI instructions)

**Your content (create and edit freely):**
- `docs/ideas/` — rough ideas being refined
- `docs/features/` — fully defined feature specs
- `docs/tasks/` — your tasks
- `docs/bugs/` — your bug reports
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
├── ideas/              # Rough ideas being refined
├── features/           # Fully defined feature specs
├── tasks/              # Your work items
│   ├── backlog/        # Planned
│   ├── next/           # Sprint queue
│   ├── working/        # In progress
│   ├── review/         # Awaiting approval
│   └── live/           # Complete
├── bugs/               # Your bug reports
├── guides/             # Your documentation
└── tests/              # Your test plans
```

## Commands

```bash
./5day.sh newidea "My rough idea"   # Create idea to refine
./5day.sh newfeature "Name"         # Create feature
./5day.sh newtask "Description"     # Create task
./5day.sh status                    # View work
./5day.sh help                      # All commands
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

**Ideas** = Rough concepts being refined. Start here when unclear.
**Features** = Fully defined specs. What capabilities exist.
**Tasks** = Work items. Move through folders as status changes.
**STATE.md** = Source of truth for IDs.

## Ideas Workflow

When you have a rough idea but haven't thought it through:

```bash
./5day.sh newidea "User notifications"
```

This creates `docs/ideas/user-notifications.md` with a guided refinement process:
1. **Phase 1:** Define the problem (who has it, why it matters)
2. **Phase 2:** Write in plain English (no jargon)
3. **Phase 3:** List what it does (concrete capabilities)
4. **Phase 4:** Surface open questions

Work through it manually, or ask an AI agent to guide you.

## Creating Work

```bash
./5day.sh newtask "Fix login timeout"
```

Creates `docs/tasks/backlog/[next-ID]-fix-login-timeout.md` and updates STATE.md.

## Templates

Use templates in each folder:
- `docs/ideas/TEMPLATE-idea.md`
- `docs/tasks/TEMPLATE-task.md`
- `docs/features/TEMPLATE-feature.md`
- `docs/bugs/TEMPLATE-bug.md`

## Updating 5DayDocs

To update to a newer version, re-run setup from the 5daydocs repo:

```bash
cd /path/to/5daydocs
git pull
./setup.sh
# Enter your project path when prompted
```

Your STATE.md values (task IDs, bug IDs) are preserved during updates.

---

*Plain folders and markdown. That's it.*
