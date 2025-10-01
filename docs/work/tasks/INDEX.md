# Task Management Pipeline

The task pipeline implements a folder-based workflow where tasks physically move through directories representing their current state.

## Pipeline Stages

### 1. backlog/
**Purpose:** Repository of all planned work
**When to use:** New ideas, feature requests, improvements
**Naming:** `ID-description.md` (e.g., `12-add-search-feature.md`)

### 2. next/
**Purpose:** Sprint queue - tasks ready to start
**When to use:** Prioritized work for current/next sprint
**Move here:** When planning sprint or pulling from backlog

### 3. working/
**Purpose:** Active development (limit 1 per developer)
**When to use:** Task you're actively coding RIGHT NOW
**Important:** Keep minimal - if switching tasks, move current one back to next/

### 4. review/
**Purpose:** Code complete, awaiting review/testing
**When to use:** Feature built, tests passing, ready for QA
**Next step:** Either back to working/ (if issues) or to live/

### 5. live/
**Purpose:** Deployed or approved for deployment
**When to use:** Task is in production or merged to main
**Archive:** Old tasks can be moved to live/archived/ periodically

## Task Lifecycle Commands

```bash
# Create new task (check STATE.md for next ID first!)
echo "# Task Title" > work/tasks/backlog/ID-description.md

# Move through pipeline
git mv work/tasks/backlog/12-feature.md work/tasks/next/
git mv work/tasks/next/12-feature.md work/tasks/working/
git mv work/tasks/working/12-feature.md work/tasks/review/
git mv work/tasks/review/12-feature.md work/tasks/live/

# Check pipeline status
ls work/tasks/*/
```

## Task File Format

```markdown
# Task Title

## Problem
What issue does this solve?

## Desired Outcome
What does success look like?

## Implementation Notes
Technical details, dependencies, considerations

## Testing Criteria
- [ ] Test case 1
- [ ] Test case 2
```

## Rules & Best Practices

1. **One task in working/ at a time** - Prevents context switching
2. **Always use git mv** - Preserves git history
3. **Update STATE.md** - Track highest ID after creating tasks
4. **Small, atomic tasks** - Easier to review and deploy
5. **Clear descriptions** - Use kebab-case in filenames

## Converting Bugs to Tasks

```bash
# 1. Review bug
cat work/bugs/001-login-error.md

# 2. Create task referencing bug
echo "# Fix Login Error (Bug #001)" > work/tasks/backlog/13-fix-login-bug-001.md

# 3. Archive bug
git mv work/bugs/001-login-error.md work/bugs/archived/
```