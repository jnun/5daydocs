<!--
SYNC NOTE: This template is copied to new projects during setup.sh.
The runtime generator is docs/5day/scripts/create-task.sh.
Keep both in sync manually when making format changes.
-->

# Task [ID]: [Brief Description]

**Feature**: /docs/features/[FEATURE-NAME].md (or "multiple" or "none")
**Created**: YYYY-MM-DD
**Depends on**: none
**Blocks**: none

## Problem

<!-- Write 2-5 sentences explaining what needs solving and why.
     Describe it as you would to a colleague unfamiliar with this area. -->



## Success criteria

<!-- Write observable behaviors: "User can [do what]" or "App shows [result]"
     Each criterion should be verifiable by using the app. -->

- [ ]
- [ ]
- [ ]

## Notes

<!-- Include dependencies, related docs, or edge cases worth considering.
     Leave empty if none, but keep this section. -->

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

WORKFLOW LIFECYCLE
Task files move through folders to track status:
  backlog/ → next/ → working/ → review/ → live/

Move tasks with: git mv docs/tasks/backlog/29-task.md docs/tasks/next/

GITHUB SYNC
Commits to main branch sync automatically:
  - New/updated files sync to GitHub Issues
  - Folder location updates issue labels
  - Files in live/ close the issue
-->
