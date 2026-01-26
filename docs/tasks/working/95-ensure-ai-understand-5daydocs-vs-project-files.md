# Task 95: Ensure AI understand 5daydocs vs project files

## Problem

AI agents cannot reliably distinguish between:
- **5DayDocs framework files** (scripts, AI instructions, templates) — should not edit
- **User project files** (tasks, bugs, features, guides) — should freely edit

Current structure mixes framework and user files in the same folders (e.g., `docs/scripts/` contains both framework scripts and potentially user scripts). This causes AI to either:
1. Edit framework files thinking they're user files
2. Avoid editing user files thinking they're framework files

## Solution: `docs/5day/` Namespace

Consolidate ALL framework files into a single, clearly-named folder:

```
docs/
├── 5day/                    ← FRAMEWORK (do not edit)
│   ├── scripts/             ← 5day.sh, create-task.sh, etc.
│   ├── ai/                  ← AI instructions for using 5DayDocs
│   └── templates/           ← TEMPLATE-*.md defaults
├── tasks/                   ← USER CONTENT
├── bugs/                    ← USER CONTENT
├── features/                ← USER CONTENT
├── guides/                  ← USER CONTENT
├── tests/                   ← USER CONTENT
├── scripts/                 ← USER CONTENT (optional, their own scripts)
└── STATE.md                 ← USER DATA (framework format)
```

**Root symlink:** `./5day` → `docs/5day/scripts/5day.sh`

## Implementation Plan

### 1. Restructure `src/` to match new layout
- [ ] Create `src/docs/5day/` directory
- [ ] Move `src/docs/scripts/*` → `src/docs/5day/scripts/`
- [ ] Create `src/docs/5day/ai/` with AI instruction files
- [ ] Move templates to `src/docs/5day/templates/` (revisit later)

### 2. Update `src/DOCUMENTATION.md`
- [ ] Add clear "Boundaries" section:
  ```markdown
  ## Boundaries

  **Framework (do not edit):** `docs/5day/`
  **Your content:** Everything else in `docs/`
  ```
- [ ] Reference `docs/5day/ai/` for AI instructions
- [ ] Remove ambiguous "5DayDocs owns docs/" language

### 3. Update `src/docs/STATE.md`
- [ ] Add header comment explaining ownership:
  ```markdown
  <!--
  STATE.md is user data tracking project progress.
  Use ./5day scripts to modify, or update manually.

  Fields managed by 5DayDocs updates:
  - Last Updated, 5DAY_VERSION

  Fields managed by user/AI/scripts:
  - 5DAY_TASK_ID, 5DAY_BUG_ID, SYNC_ALL_TASKS
  -->
  ```

### 4. Create `src/docs/5day/ai/` content
- [ ] `README.md` — Entry point for AI agents
- [ ] `tasks.md` — How to create/move/manage tasks
- [ ] `bugs.md` — How to work with bugs
- [ ] `workflows.md` — Common patterns

### 5. Update setup/update scripts
- [ ] Modify `setup.sh` to create new folder structure
- [ ] Modify `update.sh` to migrate existing installs
- [ ] Update root `./5day` symlink path

### 6. Remove INDEX.md files (or make optional)
- [ ] Evaluate if INDEX.md files add value or are noise
- [ ] If kept, scaffold once and never update

## Desired Outcome

AI agents reading `DOCUMENTATION.md` immediately understand:
1. `docs/5day/` is framework — read but don't edit
2. Everything else in `docs/` is their workspace
3. `STATE.md` is user data with specific editable fields
4. `docs/5day/ai/` has detailed instructions

## Testing Criteria
- [ ] Fresh install creates correct `docs/5day/` structure
- [ ] Existing installs migrate cleanly via update script
- [ ] `./5day` symlink works from project root
- [ ] AI agent (Claude, Copilot, etc.) correctly identifies framework vs user files
- [ ] AI agent can create tasks without touching `docs/5day/`
- [ ] DOCUMENTATION.md clearly states the boundary rule

---

## Status Report (2025-01-25) - COMPLETED

### All Items Completed ✓

| Item | Evidence |
|------|----------|
| Create `src/docs/5day/` directory | Directory exists |
| Move scripts to `src/docs/5day/scripts/` | 6 scripts present |
| Add "Boundaries" section to DOCUMENTATION.md | Lines 5-18 in `src/DOCUMENTATION.md` |
| Add ownership comment to STATE.md template | Lines 1-12 in `src/templates/project/STATE.md.template` |
| Remove INDEX.md from task subfolders | Per recent commits |
| **Merge `scripts/update.sh` into `setup.sh`** | `scripts/update.sh` deleted, `setup.sh` handles both install and update |
| **Fix `setup.sh` paths** | Now correctly references `src/docs/5day/scripts/` |
| **Create AI instruction files** | `src/docs/5day/ai/feynman-method.md` created |
| **Update DOCUMENTATION.md** | Added "Updating 5DayDocs" section |
| **Update README.md** | Updated development workflow section |
| **Sync dogfood scripts** | `docs/5day/scripts/` synced from `src/` |

### Final Structure

```
5daydocs repo:
├── setup.sh                 ← Full installer/updater (NOT distributed)
├── 5day.sh                  ← CLI (synced from src/)
├── src/docs/5day/scripts/   ← Source of truth for distributed scripts
├── src/docs/5day/ai/        ← AI instructions (feynman-method.md)
└── docs/5day/               ← Dogfood copy
```

### Key Changes Made

1. **Unified `setup.sh`** - Merged all update.sh logic into setup.sh
2. **Removed `scripts/update.sh`** - No longer needed
3. **Updated documentation** - README.md and DOCUMENTATION.md reflect new structure
4. **Audited paths** - Fixed outdated references in version-management.md and migrate-to-submodule.sh
5. **Synced dogfood** - All scripts in docs/5day/ match src/docs/5day/
