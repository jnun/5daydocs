<!--
SYNC NOTE: This template is for human reference. The actual task generator
is create-task.sh. Keep both in sync manually when making format changes.
-->

# Task [ID]: [Brief Description]

**Feature**: /docs/features/[FEATURE-NAME].md (or "multiple" or "none")
**Created**: YYYY-MM-DD
**Depends on**: none
**Blocks**: none

## Problem

<!-- Write 2-5 sentences explaining what needs solving and why.
     Describe it as you would to a colleague unfamiliar with this area.
     Use natural language only. -->



## Success criteria

<!-- Write observable behaviors: "User can [do what]" or "System shows [result]"
     Each criterion should be verifiable by using the system. -->

- [ ]
- [ ]
- [ ]

## Notes

<!-- Link to technical context when the implementer needs it.
     Example:
       Technical specification: docs/features/task-automation.md
       Implementation guide: docs/guides/script-template-sync.md
       Code patterns: docs/examples/task-generation.sh
-->

<!--
AI TASK CREATION RULES

WRITE TASKS IN NATURAL LANGUAGE
Tasks describe problems and outcomes. Technical details live elsewhere.

WHERE CONTENT BELONGS
| Content Type              | Location         |
|---------------------------|------------------|
| Problems and outcomes     | docs/tasks/      |
| How to implement          | docs/guides/     |
| Code samples and patterns | docs/examples/   |
| System specifications     | docs/features/   |

PROBLEM SECTION
Write 2-5 sentences explaining what needs solving and why.
Describe it as you would to a colleague unfamiliar with this area.

Example:
  Users are confused when creating new tasks because the generated files
  look different from the template. The section headings vary, which makes
  it hard to know which format is correct.

SUCCESS CRITERIA SECTION
Write observable behaviors that anyone can verify.

Use these patterns:
  - "User can [do what]"
  - "System shows [result]"
  - "[Action] completes within [time]"

Example:
  - [ ] User can create a task and it matches the template format
  - [ ] All section headings are consistent between generated and template files

NOTES SECTION
Link to technical documents the implementer needs.

Example:
  Technical specification: docs/features/task-automation.md
  Implementation guide: docs/guides/script-template-sync.md
  Code patterns: docs/examples/task-generation.sh

VERIFY BEFORE SAVING
1. Someone unfamiliar with the codebase can understand the problem
2. Success criteria describe observable behaviors
3. Technical context lives in docs/guides/, docs/examples/, or docs/features/
4. The Notes section links to any technical documents needed

FILE NAMING
  Filename:    120-add-login-button.md (ID + kebab-case description)
  Title:       # Task 120: Add login button (matches filename ID)

METADATA
  Feature:     **Feature**: /docs/features/auth.md (or "none" or "multiple")
  Created:     **Created**: 2026-01-28 (YYYY-MM-DD format)
  Depends on:  **Depends on**: Task 42 (or "none")
  Blocks:      **Blocks**: Task 101 (or "none")

Get next ID: docs/STATE.md (5DAY_TASK_ID field + 1)
Full protocol: docs/5day/ai/task-creation.md
Writing rules: docs/5day/ai/task-writing-rules.md

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
