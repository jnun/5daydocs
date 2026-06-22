# Task 185: Script housekeeping

**Feature**: none
**Created**: 2026-06-22
**Depends on**: none
**Blocks**: none

## Problem

Cleanup pass over scripts, templates, and AI guidance files to remove dead references, reduce duplication, and fix naming confusion.

## Completed

1. ~~`./5day.sh promote` doesn't exist~~ — Removed from idea template, create-idea.sh heredoc, and special-sauce.md. Replaced with working `newfeature` + `newtask` commands.
2. ~~`review-sprint.sh` duplicates `sprint-review.md` inline~~ — Deleted `sprint-review.md` (redundant). Script already had full protocol inline; removed the dead file reference.
3. ~~`sprint-review.md` figure out if needed~~ — Not needed, deleted.
4. ~~`.gitkeep` unneeded~~ — Deleted from `docs/5day/ai/` (directory has real files).
5. ~~Idea template references nonexistent promote command~~ — Fixed, points to real commands now.

## Remaining (spin into new tasks)

6. **`audit-backlog.sh` naming confusion** — Filename says "backlog", default folder is "next", banner says "Backlog Audit", header comment says "audit-next". Needs a Q&A to decide how this should really work and then rename/relabel consistently.
7. **`sed_escape()`, `sed_inplace()`, `move_file()` reimplemented in 5+ scripts** — These shared utilities should move into `lib.sh` so create-bug, create-task, create-feature, create-idea, and audit-backlog can source them instead of duplicating.
8. **Every create script embeds a full heredoc copy of its template** — Scripts should read and transform the `.TEMPLATE-*` file at runtime instead of maintaining a second copy.
9. **`.TEMPLATE-bug.md` bloated** — 16-line embedded AI block, self-referencing SYNC NOTE. Already tracked as Task 184.

## Success criteria

- [ ] Items 6-8 tracked as separate tasks
- [ ] This task moved to done/

## Notes

Task 184 covers the template AI block cleanup (item 9).
Items 7 and 8 are related — if scripts read templates at runtime, the shared utilities become even more important.

<!--
AI: Full task-writing guidance is in docs/5day/ai/task-creation.md
-->
