# Task 155: Triage obsolete INDEX-related tasks in queue

**Feature**: none
**Created**: 2026-04-08
**Depends on**: none
**Blocks**: none

## Problem

The decision to remove `INDEX.md` files from 5DayDocs has made several existing tasks obsolete or partially obsolete. They sit in `review/` and `backlog/` describing work that either no longer needs to happen, has already been overtaken by the removal, or needs to be rewritten in light of the new direction. Leaving them in the queue is misleading: the next person to plan a sprint will see them, treat them as live work, and either waste effort or get confused. Each one needs an explicit decision — close it, archive it, or rewrite it — rather than letting it rot.

## Definition of done

Every task in `docs/tasks/` that was authored under the assumption that INDEX.md files exist has been explicitly handled. None of them are left in `next/`, `working/`, or `backlog/` in their original form. Each one's disposition is recorded so a future reader can tell what was decided and why.

## Success criteria

- [ ] `docs/tasks/review/137-update-stale-index-md-files-remove-work-references.md` is moved to `live/` (work is moot, mark resolved) or deleted, with a note in this task explaining which and why
- [ ] `docs/tasks/review/145-stop-shipping-live-index-files-to-user-installs.md` is moved to `live/` (the removal accomplished it) or deleted, with a note here
- [ ] `docs/tasks/review/147-three-state-index-readme-update-via-manifest.md` has its INDEX scope removed; if anything remains for README.md it stays as a rewritten task, otherwise it is closed
- [ ] `docs/tasks/backlog/148-enrich-existing-readme-and-index-via-interview.md` has its INDEX scope removed; remaining README work is preserved if still wanted, otherwise the task is closed
- [ ] `docs/tasks/backlog/149-ai-bootstrap-claude-agents-cursor-files.md` has been read end-to-end to confirm whether its INDEX references are load-bearing; if so, rewrite, if not, leave a note
- [ ] No task in `next/`, `working/`, or `backlog/` still describes shipping or maintaining INDEX.md as future work
- [ ] This task's notes section lists each of the 5 tasks above with a one-line disposition (closed / rewritten / kept-with-edits)
- [ ] `git status` after the triage shows only the intended moves/edits, no accidental changes

## Notes

- The 5 candidate tasks were identified by the conversation that produced this task. Verify the list is still complete with: `grep -rln 'INDEX.md\|INDEX file' docs/tasks/{next,working,backlog,review}/ 2>/dev/null` and check each hit against the criteria above.
- "Closed" in 5DayDocs terms means moving to `live/` (the project's terminal state for completed work) or deleting outright. There is no separate "cancelled" state — the task author should pick whichever leaves the cleanest history. For tasks made moot by an external decision, prefer moving to `live/` with a one-line note in the file explaining "closed: superseded by INDEX.md removal" so the history is preserved.
- Do **not** edit historical task files in `docs/tasks/live/` — those are records of work already done.
- Use `git mv` for any folder transitions so the move is tracked properly.
- Related context: see the conversation around tasks 145 and 147, and `setup.sh`'s legacy cleanup block, for background on why INDEX.md was removed.

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

Get next ID: docs/5day/DOC_STATE.md (5DAY_TASK_ID field + 1)
Full protocol: docs/5day/ai/task-creation.md
-->
