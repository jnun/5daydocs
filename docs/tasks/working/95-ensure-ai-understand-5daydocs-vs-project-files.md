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

## Status Report (2025-01-25)

### Completed ✓

| Item | Evidence |
|------|----------|
| Create `src/docs/5day/` directory | Directory exists |
| Move scripts to `src/docs/5day/scripts/` | 6 scripts present |
| Add "Boundaries" section to DOCUMENTATION.md | Lines 5-18 in `src/DOCUMENTATION.md` |
| Add ownership comment to STATE.md template | Lines 1-12 in `src/templates/project/STATE.md.template` |
| Remove INDEX.md from task subfolders | Per recent commits |

### NOT Completed ✗

| Item | Issue |
|------|-------|
| Create AI instruction files in `docs/5day/ai/` | Only `.gitkeep` exists - no content |
| Update `setup.sh` source paths | Still references `src/docs/scripts/` (deleted) |
| Update `setup.sh` target paths | Still creates `docs/scripts/` not `docs/5day/scripts/` |
| Update `scripts/update.sh` source paths | Still references `src/docs/scripts/` (deleted) |
| Update `scripts/update.sh` target paths | Still creates `docs/scripts/` not `docs/5day/scripts/` |
| Reference `docs/5day/ai/` in DOCUMENTATION.md | No explicit reference to AI instructions location |

### Critical Issue

**Both `setup.sh` and `update.sh` are broken** - they reference `src/docs/scripts/` which no longer exists (scripts moved to `src/docs/5day/scripts/`). Fresh installs will fail to copy scripts.

---

## File Audit

### Files That Need Updates (BROKEN)

| File | Line(s) | Issue | Fix Required |
|------|---------|-------|--------------|
| `setup.sh` | 313-357 | References `src/docs/scripts/*.sh` | Change to `src/docs/5day/scripts/*.sh` |
| `setup.sh` | 124, 311-343 | Creates `docs/scripts/` in target | Change to `docs/5day/scripts/` |
| `setup.sh` | 346-357 | Copies `5day.sh` to root from wrong path | Update source path |
| `scripts/update.sh` | 439-450 | References `src/docs/scripts/*.sh` | Change to `src/docs/5day/scripts/*.sh` |
| `scripts/update.sh` | 440 | Creates `docs/scripts/` in target | Change to `docs/5day/scripts/` |

### Files That Need Updates (Content)

| File | Issue | Fix Required |
|------|-------|--------------|
| `src/docs/5day/ai/` | Empty (only `.gitkeep`) | Create README.md, tasks.md, bugs.md, workflows.md |
| `src/DOCUMENTATION.md` | No reference to `docs/5day/ai/` | Add explicit reference to AI instructions |
| `docs/scripts/INDEX.md` | References old structure | Update or remove (this is in dogfood install) |
| `docs/features/task-automation.md` | References `docs/scripts/` | Update to `docs/5day/scripts/` |
| `docs/features/feature-task-alignment.md` | References `docs/scripts/check-alignment.sh` | Update to `docs/5day/scripts/check-alignment.sh` |

### Files Already Correct (No Changes Needed)

| File | Status |
|------|--------|
| `src/DOCUMENTATION.md` | Boundaries section correct, structure diagram shows `docs/5day/` |
| `src/templates/project/STATE.md.template` | Ownership comment added |
| `src/docs/5day/scripts/*.sh` | All 6 scripts present in correct location |
| `5day.sh` (root) | Uses relative path detection, will work |
| `scripts/build-distribution.sh` | Only handles workflows/templates, not scripts |

### Scripts in Source (`src/docs/5day/scripts/`)

1. `5day.sh` - Main CLI entry point
2. `ai-context.sh` - Generate AI context
3. `check-alignment.sh` - Feature/task alignment check
4. `create-feature.sh` - Create new features
5. `create-task.sh` - Create new tasks
6. `validate-tasks.sh` - Validate task files

### Internal Script References

The scripts in `src/docs/5day/scripts/` use relative path detection:
```bash
if [ -d "$SCRIPT_DIR/docs/scripts" ]; then
    PROJECT_ROOT="$SCRIPT_DIR"
else
    PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
fi
```

This needs updating to check for `docs/5day/scripts` instead of `docs/scripts`.

---

## Remaining Work Summary

1. **Fix `setup.sh`** - Update all path references from `src/docs/scripts/` to `src/docs/5day/scripts/` and target from `docs/scripts/` to `docs/5day/scripts/`
2. **Fix `scripts/update.sh`** - Same path updates
3. **Update scripts' path detection** - Change `docs/scripts` to `docs/5day/scripts` in all 6 scripts
4. **Create AI instruction content** - README.md, tasks.md, bugs.md, workflows.md in `src/docs/5day/ai/`
5. **Update DOCUMENTATION.md** - Add explicit reference to `docs/5day/ai/`
6. **Update feature docs** - Fix path references in dogfood docs
7. **Test fresh install** - Verify new structure works
8. **Test migration** - Verify update script migrates old installs
