# Task 145: Stop shipping live INDEX files to user installs

**Feature**: none
**Created**: 2026-04-08
**Depends on**: none
**Blocks**: none

## Problem

The installer copies the `INDEX.md` files that introduce each major directory (`docs/tasks/INDEX.md`, `docs/bugs/INDEX.md`, `docs/features/INDEX.md`, etc.) into every new user project. Per the convention in `CLAUDE.md`, anything that ships to a user project should come from `src/`. These INDEX files do not — the installer reads them from this repo's live working directory `docs/...` and copies them straight into the target project.

This is not optimized because the live `docs/` tree is a working area, not a curated distribution. As we use 5DayDocs on itself, the INDEX files here can accumulate references, examples, or wording that is specific to the 5daydocs project rather than a generic starting point. Whatever happens to be in the live INDEX at install time gets shipped to every new user, with no review step. The same files are also overwritten on every update against existing installs, so any user customization to their own INDEX files is silently clobbered each time they run the installer.

The perfect fix has two outcomes. First, the content shipped to users is curated and lives in `src/`, like every other distributed file. Second, the installer treats user-edited INDEX files the way it already treats user-edited READMEs: introduce them on a fresh install, but don't overwrite them on update. The developer should decide whether "don't overwrite" means a skip, a `.new` sidecar, a prompt, or something else.

## Success criteria

- [x] All INDEX files that the installer ships to user projects have a curated source under `src/`
- [x] The installer no longer reads any user-bound file from this repo's live `docs/` tree
- [x] On a fresh install, every expected INDEX file appears in the target project
- [x] On an update against an existing install with locally edited INDEX files, the user's edits survive
- [x] Editing an INDEX file in this repo's live `docs/` tree (for our own dogfooding) has no effect on what users receive
- [x] Fresh-install verification per `CLAUDE.md` passes

## Notes

- Installer references: `setup.sh` INDEX copy loop (around lines 580-604), which currently iterates a list of `docs/.../INDEX.md` paths and reads them from `$FIVEDAY_SOURCE_DIR/$index_file`.
- Related dogfood escape hatch: the loop already skips when source and target resolve to the same file, which is the only thing preventing self-targeting from corrupting the source. That escape hatch goes away naturally once the source moves under `src/`.
- This task overlaps philosophically with task 144 (single source of truth under `src/`) but is independent in scope and can ship separately.

## Completed

**Approach:** Created curated INDEX files under `src/docs/`, changed the installer to read from `src/` instead of the live `docs/` tree, and made the INDEX copy loop skip files that already exist (preserving user edits on update).

**Files changed:**
- `setup.sh` — INDEX copy loop now reads from `$FIVEDAY_SOURCE_DIR/src/$index_file` instead of `$FIVEDAY_SOURCE_DIR/$index_file`; skips copy when target file already exists
- `src/docs/tasks/INDEX.md` — new curated file
- `src/docs/bugs/INDEX.md` — new curated file
- `src/docs/designs/INDEX.md` — new curated file
- `src/docs/examples/INDEX.md` — new curated file
- `src/docs/data/INDEX.md` — new curated file
- `src/docs/INDEX.md` — new curated file
- `src/docs/features/INDEX.md` — new curated file
- `src/docs/guides/INDEX.md` — new curated file
- `src/docs/5day/scripts/INDEX.md` — already existed, unchanged

**Update behavior:** Simple skip — if the INDEX file already exists at the target path, the installer prints "Skipped (already exists)" and moves on. No `.new` sidecar or prompt needed since INDEX files are lightweight orientation docs that users may customize freely.

**Verified:** Fresh install places all 9 INDEX files. Update with user-edited INDEX files preserves edits (all skipped). The dogfood self-targeting escape hatch is no longer needed since sources now live under `src/`.

<!--
AI TASK CREATION GUIDE

Write as you'd explain to a colleague:
- Problem: describe what needs solving and why
- Success criteria: "User can [do what]" or "App shows [result]"
- Notes: dependencies, links, edge cases

Patterns that work well:
  Filename:    120-add-login-button.md (ID + kebab-case description)
  Title:       # Task 120: Add login button (matches filename ID)
  Feature:     **Feature**: /docs/features/auth.md (or "none" or "multiple")
  Created:     **Created**: 2026-01-28 (YYYY-MM-DD format)
  Depends on:  **Depends on**: Task 42 (or "none")
  Blocks:      **Blocks**: Task 101 (or "none")

Success criteria that verify easily:
  - [ ] User can reset password via email
  - [ ] Dashboard shows total for selected date range
  - [ ] Search returns results within 500ms

Get next ID: docs/STATE.md (5DAY_TASK_ID field + 1)
Full protocol: docs/5day/ai/task-creation.md
-->
