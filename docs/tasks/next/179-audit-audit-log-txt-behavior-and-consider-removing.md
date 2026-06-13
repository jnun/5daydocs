# Task 179: Audit audit-log.txt behavior and consider removing it

**Feature**: none
**Created**: 2026-05-06
**Depends on**: none
**Blocks**: none

## Problem

`docs/5day/scripts/audit-backlog.sh` writes an append-only history of every audit run to `docs/tasks/audit-log.txt` — one header per run plus a `DONE | KEEP | OUTDATED | UNDEFINED | TIMEOUT` line per task evaluated. The only consumer of this file is the script itself, which `tail`s the lines it just wrote at the end of a run (audit-backlog.sh:201) to print that run's summary. Nothing else — no other script, no AI guidance file, no user-facing surface — reads from it. The file grows unboundedly, contains stale verdicts for tasks that have since been deleted or moved, and ships an empty file into every new install (the script `touch`es it on first run). We need to decide whether this log earns its keep or whether the per-run summary should just be captured in memory and the persisted file removed entirely.

## Success criteria

- [ ] Decision recorded (keep / remove / replace) with reasoning
- [ ] If removing: `audit-backlog.sh` no longer writes to or reads from `docs/tasks/audit-log.txt`, in both `docs/` and `src/` mirrors; existing file deleted from this repo; fresh install verified to not create the file
- [ ] If keeping: rationale captured (e.g. in script comment or DOCUMENTATION.md) so this question doesn't get re-asked, and a bound or rotation policy considered for unbounded growth
- [ ] Task 166 note about the log being "append-only, leave it alone" updated or obsoleted to match the new decision

## Notes

- Discovered while reviewing whether the file was leftover trash; it isn't, but its value is marginal.
- Related: `docs/tasks/review/166-remove-jira-and-bitbucket-scaffolding.md:85` explicitly preserves the log today.
- Per CLAUDE.md, any script change must be edited in `docs/5day/scripts/`, tested in place, then mirrored to `src/docs/5day/scripts/`.
- Verify with the standard fresh-install check: `mkdir /tmp/test-5day && ./setup.sh` → confirm no `audit-log.txt` is created until (or unless) intended.

## Sprint Review

### Perspective check

**Chief Platform Architect.** This is a straightforward hygiene win. The audit-log.txt file is architecturally incoherent — it's an append-only log whose only consumer is the script that writes it, and it reads back only the lines it just appended (`tail -n +$log_start_line`). That's a variable disguised as a file. The log contains stale verdicts for tasks that have been deleted or moved, grows without bound, has no rotation or structured format, and nothing — no other script, no AI workflow, no reporting surface — ever reads it. If the goal were genuine observability (trending audit health over time, spotting patterns in stale tasks), the implementation would need to be structured data with a retention policy, not a free-form text file. As it stands, the Architect would push hard to remove: it eliminates an unbounded growth vector, simplifies the script, and shrinks the install footprint. The only thing worth preserving is the per-run summary, which can trivially live in a shell variable instead of being tailed out of a file.

**Chief Experience Officer.** Every fresh install gets an empty `audit-log.txt` via the `touch` on line 75. That's a file users will see, wonder about ("Do I commit this? Should I read it? Is it important?"), and get zero value from. It's small friction, but it's friction in the first-run experience — exactly when trust is most fragile. Removing it makes the installed footprint feel more intentional. The CXO has no attachment to this file and would push to cut it cleanly.

### Tension and resolution

There is essentially no tension between the two perspectives here. The Architect might, in a vacuum, argue for preserving audit history as an observability surface — but the current implementation doesn't deliver that. It's unstructured, unread, and unbounded. If we ever want persistent audit history, it would be a different feature with a different design. Both perspectives converge cleanly on removal.

The one subtlety is the task 166 note that explicitly says "leave it alone, it's an append-only log." That note was a reasonable call at the time — it prevented accidental deletion during a cleanup sweep — but it shouldn't be treated as a permanent policy decision. Task 179 exists precisely to revisit that call with more information, and the answer is now clear. The success criterion that requires updating task 166's note is the right way to close that loop.

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
