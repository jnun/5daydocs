# Task 159: Simplify src/ to mirror deployed layout

**Feature**: none
**Created**: 2026-04-16
**Depends on**: none
**Blocks**: none

## Problem

`src/` is supposed to be the distribution package — what setup.sh installs into a user's project. But it doesn't mirror the deployed layout. Files live in arbitrary locations (`src/templates/project/`, `src/templates/github/`, `src/templates/workflows/`, `src/copilot-instructions.md`) and setup.sh has ~15 hardcoded routing rules that map each one to its actual destination. This makes it hard to reason about what ships where, and every new file requires a new routing rule in setup.sh.

The fix: restructure src/ so file paths match their deployed paths. Then setup.sh walks the tree and copies each file to the same relative path in the target, with a small allow-list of files that get special treatment (prepend-not-overwrite, skip-if-exists, etc.).

## Current src/ → deployed mapping (what needs to change)

### Files that already mirror correctly (no change needed)
- `src/docs/5day/scripts/*.sh` → `docs/5day/scripts/*.sh`
- `src/docs/5day/ai/*.md` → `docs/5day/ai/*.md`
- `src/docs/5day/theory/*.md` → `docs/5day/theory/*.md`
- `src/docs/5day/config.sh` → `docs/5day/config.sh`
- `src/DOCUMENTATION.md` → `DOCUMENTATION.md`

### Files that need to move within src/
| Current location | New location | Deployed path |
|---|---|---|
| `src/docs/5day/scripts/5day.sh` | `src/5day.sh` | `./5day.sh` |
| `src/templates/project/TEMPLATE-task.md` | `src/docs/tasks/TEMPLATE-task.md` | `docs/tasks/TEMPLATE-task.md` |
| `src/templates/project/TEMPLATE-bug.md` | `src/docs/bugs/TEMPLATE-bug.md` | `docs/bugs/TEMPLATE-bug.md` |
| `src/templates/project/TEMPLATE-feature.md` | `src/docs/features/TEMPLATE-feature.md` | `docs/features/TEMPLATE-feature.md` |
| `src/templates/project/TEMPLATE-idea.md` | `src/docs/ideas/TEMPLATE-idea.md` | `docs/ideas/TEMPLATE-idea.md` |
| `src/copilot-instructions.md` | `src/.github/copilot-instructions.md` | `.github/copilot-instructions.md` |
| `src/templates/github/ISSUE_TEMPLATE/*` | `src/.github/ISSUE_TEMPLATE/*` | `.github/ISSUE_TEMPLATE/*` |
| `src/templates/github/pull_request_template.md` | `src/.github/pull_request_template.md` | `.github/pull_request_template.md` |
| `src/templates/workflows/github/*.yml` | `src/.github/workflows/*.yml` | `.github/workflows/*.yml` |
| `src/templates/workflows/bitbucket/pipelines.yml` | `src/bitbucket-pipelines.yml` | `bitbucket-pipelines.yml` |
| `src/templates/project/gitignore.template` | `src/.gitignore.template` | special (see notes) |

### Files that stay put but have special install behavior
These don't move — their paths already match — but setup.sh must NOT blindly overwrite them. They use prepend-or-create logic (`setup_ai_file`):
- `src/CLAUDE.md` → `CLAUDE.md`
- `src/AGENTS.md` → `AGENTS.md`
- `src/.cursorrules` → `.cursorrules`
- `src/.windsurfrules` → `.windsurfrules`
- `src/.github/copilot-instructions.md` → `.github/copilot-instructions.md`

### Files that are read-only metadata (never copied)
- `src/VERSION` — read by setup.sh, stamped into DOC_STATE.md

## setup.sh rewrite plan

Replace the current copy sections (lines ~674–784 and ~960–975) with:

1. **Walk `src/` recursively** (like the existing `find -print0` loop for `src/docs/5day/`), but now covering all of `src/`.
2. **For each file, check behavior against three lists:**
   - `SKIP_FILES` — don't copy at all: `VERSION`
   - `PREPEND_FILES` — use `setup_ai_file` logic (prepend-or-create, never overwrite): `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.windsurfrules`, `.github/copilot-instructions.md`
   - `USER_TERRITORY` — copy only on fresh install, skip if exists: `docs/5day/config.sh`
   - `PLATFORM_GITHUB` — only copy when platform is github-based: `.github/**`
   - `PLATFORM_BITBUCKET` — only copy when platform is bitbucket: `bitbucket-pipelines.yml`
   - Everything else: **overwrite** (standard `safe_copy`)
3. **Delete `src/templates/`** directory entirely — its contents have moved into the mirror layout.
4. **gitignore.template** stays special — it's not a direct copy, it's content that gets offered to prepend/append to the user's `.gitignore`. Move to `src/.gitignore.template` (won't be caught by the walker since it doesn't map to `.gitignore` directly). Keep the existing gitignore prompt logic, just change the source path.

## Success criteria

- [x] `src/` layout mirrors deployed layout: every file's relative path under `src/` matches its deployed path in the target project (except VERSION and .gitignore.template)
- [x] `src/templates/` directory no longer exists
- [x] setup.sh copy logic is a single recursive walk of `src/` with behavior determined by list membership, not per-file routing
- [x] Fresh install (`./setup.sh` → new empty dir) produces identical output to current version
- [x] Update install (`./setup.sh` → existing 5daydocs project) preserves user-territory files and prepend-not-overwrite files
- [x] `docs/5day/config.sh` is preserved on update (not overwritten)
- [x] AI files (CLAUDE.md, etc.) prepend correctly when target exists without DOCUMENTATION.md reference
- [x] Platform selection still controls which files are copied (github vs bitbucket vs none)
- [x] `./setup.sh .` (self-targeting dogfood) still works

## Implementation notes

### What changed

**src/ restructured** — all files moved to mirror their deployed paths:
- `src/templates/project/TEMPLATE-*.md` → `src/docs/{tasks,bugs,features,ideas}/.TEMPLATE-*.md`
- `src/templates/github/**` → `src/.github/**`
- `src/templates/workflows/github/*.yml` → `src/.github/workflows/*.yml`
- `src/templates/workflows/bitbucket/pipelines.yml` → `src/bitbucket-pipelines.yml`
- `src/copilot-instructions.md` → `src/.github/copilot-instructions.md`
- `src/templates/project/gitignore.template` → `src/.gitignore.template`
- `src/docs/5day/scripts/5day.sh` → `src/5day.sh`

**src/templates/ deleted** — no longer exists.

**`bitbucket-pipelines-jira.yml` dropped** — never referenced by setup.sh, dead code.

**setup.sh rewritten** (lines ~674–850) — replaced ~15 hardcoded copy rules and 3 separate copy sections with a single `find -print0` walk of `src/`. Behavior is driven by four arrays: `SKIP_FILES`, `PREPEND_FILES`, `USER_TERRITORY`, and glob-based platform filters (`[[ "$rel_path" == .github/* ]]` / `[[ "$rel_path" == bitbucket-* ]]`). Adding a new file to `src/` now requires zero setup.sh changes unless it needs special behavior.

The walk uses fd 3 (`while read <&3 ... done 3< <(find ...)`) so stdin stays available for interactive prompts inside `setup_ai_file`. AI instruction files (PREPEND_FILES) are deferred to a `PENDING_PREPEND` array during the walk, then processed after all standard copies finish — this groups interactive prompts under a "Setting up AI instruction files..." header instead of scattering them between copy messages.

**CLAUDE.md updated** — removed stale references to `src/templates/` and `src/copilot-instructions.md`.

### Bugs caught during audit

1. `FILES_COPIED` was initialized twice — once in the README section (line 596) and again at the top of the walk section. The second initialization zeroed out the README count. Fixed by removing the duplicate.

2. AI file prompts were scattered throughout the copy output because `find` returns files in filesystem order, and PREPEND_FILES were handled inline during the walk. This made piped installs fragile (answer order depended on `find` order) and interactive installs noisy (prompts interleaved with copy messages). Fixed by deferring prepend files to a post-walk loop.

### What didn't change

- README.md handling (pure setup.sh logic, no src/ file)
- .gitignore handling (reads `.gitignore.template` as content source, not a direct-copy)
- Migration versions (untouched, only run for pre-2.2.0)
- `setup_ai_file` function (same prepend-or-create logic, just called from the deferred loop now)
- Validation, summary, and legacy cleanup sections
