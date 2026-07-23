# 5DayDocs

Project management in markdown files. Folders and plain text.

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
- `docs/5day/DOC_STATE.md` — your project state (see format below)

## AI Agents

This file governs `docs/`. Read it before modifying any task, bug, or feature.

**Rules:**
1. `docs/` is the active project management system — not source code, not stale
2. Tasks in `review/` and `done/` are completed work — old dates mean done, not abandoned
3. Always read `docs/5day/DOC_STATE.md` before creating tasks (get next ID)
4. Use `./5day.sh` commands when available — don't create task files manually
5. Move tasks by changing folders — folder location = status

**Folder meanings:**
| Folder | Status |
|--------|--------|
| `backlog/` | Planned, not started |
| `next/` | Queued for current sprint |
| `doing/` | Actively being worked on |
| `blocked/` | Can't be worked — docs changed, dependencies shifted, or the task itself is undefined given current conditions |
| `review/` | Done, awaiting approval |
| `done/` | Shipped/complete |

**Do not assume** old file dates mean abandoned. A task from months ago in `done/` is completed history.

---

## Structure

```
docs/
├── 5day/               # FRAMEWORK (do not edit)
│   ├── scripts/        # 5day.sh, create-task.sh, etc.
│   ├── ai/             # AI instructions
│   └── DOC_STATE.md    # Project state (ID tracking)
├── ideas/              # Rough ideas being refined
├── features/           # Fully defined feature specs
├── tasks/              # Your work items
│   ├── backlog/        # Planned
│   ├── next/           # Sprint queue
│   ├── doing/          # In progress
│   ├── blocked/        # Can't be worked given current state
│   ├── review/         # Awaiting approval
│   └── done/           # Complete
├── bugs/               # Your bug reports
├── guides/             # Your documentation
├── tests/              # Your test plans
└── tmp/                # Scratch workspace (gitignored)
```

## Creating Work

| What | When | Command |
|------|------|---------|
| **Idea** | Rough concept, needs refinement | `./5day.sh newidea "User notifications"` |
| **Feature** | Defined capability to build | `./5day.sh newfeature "User auth"` or `./5day.sh newfeature` (AI Q&A) |
| **Task** | Specific work item | `./5day.sh newtask "Add login button"` |
| **Bug** | Something broken | `./5day.sh newbug "Login fails on mobile"` |
| **Test** | Validate a deployed thing, then route what you learn into new work | `./5day.sh newtest "Signup converts visitors"` |

Each command creates a file with inline guidance. Fill in the sections, then commit.

## Commands

```bash
# Creating work
./5day.sh newidea "My rough idea"   # Create idea to refine
./5day.sh newfeature "Name"         # Create feature (quick)
./5day.sh newfeature                # Create feature (AI Q&A)
./5day.sh newtask "Description"     # Create task
./5day.sh newbug "Description"      # Report a bug
./5day.sh newtest "Name"            # Create a test loop to validate a deployed thing
./5day.sh status                    # View project status
./5day.sh checkfeatures             # Analyze feature alignment
./5day.sh ai-context                # Generate AI context summary

# Workflow (AI-powered — requires Claude CLI)
./5day.sh profile                   # Create or update project profile
./5day.sh search <keyword>          # Search tasks by keyword
./5day.sh find <task-id> [--think|--work]  # Find task, analyze quality, or execute
./5day.sh plan <task-id>            # Interactive Q&A to define a task
./5day.sh talk <task-id>            # Discuss a task with AI to make it well-defined and workable
./5day.sh sprint [count] [focus]    # Plan a sprint from backlog
./5day.sh define [limit]            # Review and refine tasks in next/ (stamps Status: READY)
./5day.sh tasks [limit] [--fast]    # Execute READY tasks from next/ (--force to skip the gate; --audit --excellence to chain quality audits)
./5day.sh split <path>              # Split a large task into subtasks
./5day.sh review-sprint             # Review sprint via dual-persona analysis
./5day.sh review-code <file>        # Run code audit on a task's changes
./5day.sh excellence <file>         # Judge finished work against a higher bar; file enhancements
./5day.sh audit [folder] [limit]    # Audit tasks in next/ (or specified folder)
./5day.sh triage [limit]            # Interactive walk-through of task pipeline

# Sync
./5day.sh sync [--all]              # Push task changes to GitHub

# Maintenance
./5day.sh validate [--fix] [--dry-run]  # Validate task files (--docs checks help/ for flag drift)
./5day.sh cleanup [--delete|--force|--all]  # Clean stale files from docs/tmp/
./5day.sh help                      # Show all commands
```

## Moving Tasks

Tasks move through folders. Use `git mv` or `mv` (then commit):

```bash
git mv docs/tasks/backlog/ID-name.md docs/tasks/next/      # Queue
git mv docs/tasks/next/ID-name.md docs/tasks/doing/      # Start
git mv docs/tasks/doing/ID-name.md docs/tasks/blocked/   # Can't proceed — context changed
git mv docs/tasks/blocked/ID-name.md docs/tasks/next/      # Unblocked, re-queue
git mv docs/tasks/doing/ID-name.md docs/tasks/review/    # Submit
git mv docs/tasks/review/ID-name.md docs/tasks/done/       # Complete
```

If `git mv` fails, use `mv` and commit the change.

## Naming

| Type | Format | Example |
|------|--------|---------|
| Task | `ID-description.md` | `12-fix-auth-error.md` |
| Bug | `ID-description.md` | `3-login-fails.md` |
| Feature/Idea | `name.md` | `user-authentication.md` |

IDs come from `docs/5day/DOC_STATE.md` (5DAY_TASK_ID for tasks, 5DAY_BUG_ID for bugs).

## Key Concepts

**Ideas** = Rough concepts being refined. Start here when unclear.
**Features** = Fully defined specs. What capabilities exist.
**Tasks** = Work items. Move through folders as status changes.
**DOC_STATE.md** = Source of truth for IDs (`docs/5day/DOC_STATE.md`).

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

## Templates

Use templates in each folder:
- `docs/ideas/.TEMPLATE-idea.md`
- `docs/tasks/.TEMPLATE-task.md`
- `docs/features/.TEMPLATE-feature.md`
- `docs/bugs/.TEMPLATE-bug.md`
- `docs/tests/.TEMPLATE-test.md`

## Updating 5DayDocs

To update to a newer version, re-run setup from the 5daydocs repo:

```bash
cd /path/to/5daydocs
git pull
./setup.sh
# Enter your project path when prompted
```

Your DOC_STATE.md values (task IDs, bug IDs) are preserved during updates.

---

*Plain folders and markdown. That's it.*
