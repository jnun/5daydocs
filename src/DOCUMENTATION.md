# Documentation Workflow

- **Features** (`docs/features/`) - Permanent specifications defining what to build
- **Tasks** (`docs/tasks/`) - Temporary work items moving through folders
- **STATE.md** (`docs/STATE.md`) - Sequential ID tracking

## Core Structure

```
docs/
├── STATE.md            # Current task and bug IDs
├── VERSION             # 5DayDocs version identifier
├── api/                # API documentation
├── bugs/               # Bug reports (template: TEMPLATE-bug.md)
├── data/               # Data references and database seeding content
├── design/             # Design outlines, standards, and descriptions
├── examples/           # Files, text, and examples used for work
├── features/           # Capability specifications (template: TEMPLATE-feature.md)
├── guides/             # Guides, outlines, and tutorials
├── ideas/              # Concepts not yet formalized as features
├── tests/              # Test plans, cases, and validation results
└── tasks/              # Work items (template: TEMPLATE-task.md)
    ├── backlog/        # Planned work
    ├── next/           # Queued for current sprint
    ├── working/        # In progress
    ├── review/         # Built, awaiting approval
    └── live/           # Completed
```

## Naming Conventions

**Task and Bug Files**:
- Format: `ID-description.md`
- ID: Sequential number (0, 1, 2, 3...)
- Description: Lowercase, kebab-case, action-oriented
- Example: `12-fix-authentication-error.md`

**Feature Files**:
- Format: `feature-name.md`
- No ID prefix
- Lowercase, kebab-case
- Example: `user-authentication.md`

**All other files**:
- Lowercase except root documentation (README.md, DOCUMENTATION.md)
- Use kebab-case for multi-word names

## Feature Documents

Features define what to build. Use `docs/features/TEMPLATE-feature.md` as the structure template.

## Task Documents

Tasks define specific work and move through folders as they progress. Use `docs/tasks/TEMPLATE-task.md` as the structure template.

## Workflow

Tasks move through folders:

1. **backlog/** - Planned work
2. **next/** - Current sprint
3. **working/** - In progress
4. **review/** - Built, needs testing and approval
5. **live/** - Approved and promoted to production

Move priority tasks from `backlog/` to `next/` to start a sprint. Work progresses: `working/` → `review/` → `live/`.

## Essential Operations

### Creating a Task

**Automated**:
```bash
./5day.sh newtask "Task description"
```
Auto-increments ID from `docs/STATE.md`, creates file in `docs/tasks/backlog/`, updates STATE.md.

**Manual**:
1. Get next ID from `docs/STATE.md`
2. Create `docs/tasks/backlog/[ID+1]-description.md`
3. Update `docs/STATE.md`
4. Commit both files together

### Moving Tasks

```bash
# Move through the pipeline (replace ID-description.md with actual filename)
git mv docs/tasks/backlog/ID-description.md docs/tasks/next/      # Queue it
git mv docs/tasks/next/ID-description.md docs/tasks/working/      # Start work
git mv docs/tasks/working/ID-description.md docs/tasks/review/    # Submit
git mv docs/tasks/review/ID-description.md docs/tasks/live/       # Complete
```

### Updating Features

- Features = permanent documentation
- Tasks = temporary work items
- Update feature status to LIVE when first capability works
- Update capability checkboxes as they complete
- LIVE features can have backlog tasks for enhancements

## What to Read

- **Feature files** - Specifications and requirements
- **Task files** - Current work scope and success criteria
- **STATE.md** - Task and bug ID tracking

## Guides & Tests

### Guides (`docs/guides/`)
Permanent documentation for how things work.
- **Technical Guides**: Architecture, API usage, setup.
- **User Manuals**: How to use the features.
- **Process Docs**: Team workflows (like this one).

### Tests (`docs/tests/`)
Validation artifacts.
- **Test Plans**: Strategy for testing features.
- **Test Cases**: Specific scenarios to verify.
- **Validation Results**: Proof of testing (logs, screenshots).


## Bug Reports

Format: `ID-description.md` in `docs/bugs/`
- IDs tracked in `docs/STATE.md` as `5DAY_BUG_ID`
- Sequential IDs: 0, 1, 2, 3...
- Use `docs/bugs/TEMPLATE-bug.md` as structure template

**Convert bug to task**:
1. Create task referencing bug
2. Move bug to `docs/bugs/archived/`

## STATE.md Format

Check `docs/STATE.md` before creating tasks or bugs.

```markdown
# STATE.md

**Last Updated**: YYYY-MM-DD
**5DAY_VERSION**: X.X.X
**5DAY_TASK_ID**: <number>  // current highest task ID, next task = prior + 1
**5DAY_BUG_ID**: <number>    // current highest bug ID, next bug = prior + 1
**SYNC_ALL_TASKS**: <boolean>
```

Rules:
- Next ID = Current ID + 1
- IDs never change
- STATE.md is source of truth

## Key Rules

1. Always check `docs/STATE.md` first for current IDs
2. IDs come from STATE.md, not file counts
3. Move files with `git mv` to preserve history
4. Update feature status to LIVE only when capability first works
5. Features are permanent, tasks are temporary
6. One task = one file moving through folders
7. Commit STATE.md with new task/bug files
8. Read features for specs, tasks for work scope

## Quick Commands

```bash
# Create task
./5day.sh newtask "Description"

# Move tasks
git mv docs/tasks/backlog/ID-name.md docs/tasks/next/
git mv docs/tasks/next/ID-name.md docs/tasks/working/
git mv docs/tasks/working/ID-name.md docs/tasks/review/
git mv docs/tasks/review/ID-name.md docs/tasks/live/

# Check alignment
./docs/scripts/check-alignment.sh

# List work
ls docs/tasks/next/         # Current sprint
ls docs/tasks/backlog/      # Planned work
ls docs/features/           # All capabilities
```

---

*Plain folders and markdown. That's it.*
