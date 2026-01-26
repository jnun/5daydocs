# Task [ID]: [Brief Description]

**Feature**: /docs/features/[FEATURE-NAME].md (or "multiple" or "none")
**Created**: YYYY-MM-DD
**Depends on**: (optional) Task IDs that must complete before this one
**Blocks**: (optional) Task IDs that cannot start until this completes

## Problem
[Clear description of what needs to be fixed or built]

## Success criteria
- [ ] [First measurable criterion]
- [ ] [Second measurable criterion]
- [ ] [Third measurable criterion]

## Notes
[Optional: Any additional context, blockers, or dependencies]

---

<!--
═══════════════════════════════════════════════════════════════════════════
TASK FILE FORMAT REQUIREMENTS - READ THIS CAREFULLY
═══════════════════════════════════════════════════════════════════════════

This template ensures proper synchronization with GitHub Issues. Follow these
rules exactly to avoid sync errors.

📋 FILENAME FORMAT (REQUIRED)
─────────────────────────────
  Format: ID-description.md

  ✓ CORRECT:  29-github-integration.md
  ✓ CORRECT:  123-fix-login-bug.md
  ✗ WRONG:    github-integration.md  (missing ID)
  ✗ WRONG:    task-29.md              (ID not at start)
  ✗ WRONG:    abc-feature.md          (ID must be numeric)

  AI/Human Guidance:
  - ID must be a number (no letters, no prefixes like "task-")
  - Use lowercase with hyphens for description
  - Get next ID from docs/STATE.md (5DAY_TASK_ID field, increment by 1)

📝 TITLE FORMAT (REQUIRED)
─────────────────────────────
  Format: # Task [ID]: [Brief Description]

  ✓ CORRECT:  # Task 29: GitHub Integration
  ✓ CORRECT:  # Task 123: Fix Login Bug
  ✗ WRONG:    # Task: GitHub Integration     (missing ID)
  ✗ WRONG:    # GitHub Integration            (missing "Task [ID]:")
  ✗ WRONG:    ## Task 29: Integration         (wrong heading level)

  AI/Human Guidance:
  - Must start with exactly "# Task " (level 1 heading)
  - ID must match filename ID
  - Keep description brief but descriptive (3-8 words ideal)
  - This becomes the GitHub Issue title

🏷️ METADATA FIELDS
─────────────────────────────
  Required:
    **Feature**: [value]
    **Created**: YYYY-MM-DD

  Optional (include when relevant):
    **Depends on**: [Task IDs]
    **Blocks**: [Task IDs]

  ✓ CORRECT:  **Feature**: /docs/features/github-integration.md
  ✓ CORRECT:  **Feature**: none
  ✓ CORRECT:  **Feature**: multiple
  ✓ CORRECT:  **Created**: 2025-10-19
  ✓ CORRECT:  **Depends on**: Task 42
  ✓ CORRECT:  **Depends on**: Tasks 10, 12
  ✓ CORRECT:  **Blocks**: Task 101
  ✗ WRONG:    Feature: none                   (missing bold asterisks)
  ✗ WRONG:    **Feature:**none                (missing space after colon)
  ✗ WRONG:    **Created**: Oct 19, 2025       (wrong date format)

  AI/Human Guidance:
  - Use exactly "**Field**:" with bold formatting and colon
  - For Feature value, use:
    * Full path to feature file: /docs/features/name.md
    * "none" if not tied to a specific feature
    * "multiple" if spans multiple features
  - Created date must be YYYY-MM-DD format (ISO 8601)
  - Depends on / Blocks: Reference task IDs, optionally with brief context
    * "Task 42" or "Tasks 10, 12" or "Task 42 (auth must exist first)"
    * Omit these fields entirely if no dependencies exist

📂 REQUIRED SECTIONS (MUST EXIST)
─────────────────────────────
  ## Problem
  [Content describing what needs to be solved]

  ## Success criteria
  - [ ] [Measurable outcome 1]
  - [ ] [Measurable outcome 2]

  ## Notes
  [Optional content, but section header must exist]

  ✓ CORRECT:  Uses exactly these section names (## Problem, ## Success criteria, ## Notes)
  ✗ WRONG:    ## Desired Outcome        (use "## Success criteria")
  ✗ WRONG:    ## Testing Criteria       (use "## Success criteria")
  ✗ WRONG:    ## Description            (use "## Problem")
  ✗ WRONG:    ### Problem                (wrong heading level, must be ##)

  AI/Human Guidance:
  - Section names are CASE SENSITIVE and must match exactly
  - All sections must use ## (level 2 headings)
  - Use sentence case for headings (per technical writing best practices)
  - GitHub workflow parses content BETWEEN these section markers
  - Order matters: Problem → Success criteria → Notes

✍️ CONTENT GUIDELINES
─────────────────────────────

  ## Problem Section:
  - Explain WHAT needs to be done and WHY
  - Provide context for someone unfamiliar with the task
  - Include relevant background, current issues, or motivations
  - 2-5 sentences ideal for most tasks

  Example:
    The current GitHub integration creates issues but doesn't sync status
    changes back to task files. This creates a one-way sync that leads to
    drift between the two systems.

  ## Success criteria section:
  - List SPECIFIC, MEASURABLE outcomes
  - Use GitHub markdown checkboxes: - [ ]
  - Each criterion should be testable/verifiable
  - Check off items as completed: - [x]
  - Include both implementation AND testing criteria

  Good Examples:
    - [ ] Script creates GitHub issues for new task files
    - [ ] Status changes in GitHub sync back to move files
    - [ ] All existing tasks sync without errors

  Bad Examples:
    - [ ] Make it work             (too vague)
    - [ ] Improve performance      (not measurable)
    - Write good code              (missing checkbox)

  ## Notes Section:
  - Include dependencies, blockers, or related work
  - Link to relevant PRs, issues, or documentation
  - Add technical considerations or edge cases
  - Can be empty, but section header must exist

  Example:
    Depends on completing Task 28 (webhook setup).
    See docs/guides/github-integration.md for API details.

🔄 WORKFLOW LIFECYCLE
─────────────────────────────
  Task files move through folders to track status:

  1. backlog/  → Planned work, not started
  2. next/     → Queued for current sprint
  3. working/  → Actively being worked on (LIMIT: 1 task max!)
  4. review/   → Implementation complete, awaiting approval
  5. live/     → Approved and deployed (closes GitHub issue)

  Move tasks with git mv:
    git mv docs/tasks/backlog/29-task.md docs/tasks/next/
    git mv docs/tasks/next/29-task.md docs/tasks/working/

  Folder location automatically updates GitHub issue labels and status.

⚠️ COMMON MISTAKES TO AVOID
─────────────────────────────

  For AI Assistants:
  ✗ Don't invent your own section names (stick to Problem/Success criteria/Notes)
  ✗ Don't skip required metadata fields (Feature and Created are required)
  ✗ Don't use wrong heading levels (# for title, ## for sections)
  ✗ Don't forget to check the filename matches the ID in the title
  ✗ Don't create tasks with duplicate IDs (check docs/STATE.md)
  ✓ DO use Depends on/Blocks when tasks have dependencies

  For Humans:
  ✗ Don't manually type IDs (use docs/STATE.md 5DAY_TASK_ID + 1 for new tasks)
  ✗ Don't use spaces in filenames (use hyphens: some-task.md not "some task.md")
  ✗ Don't edit files directly in live/ (they're completed, create new tasks instead)
  ✗ Don't have multiple tasks in working/ at once (focus on one!)

✅ VALIDATION CHECKLIST
─────────────────────────────
  Before committing, verify:

  [ ] Filename is numeric-description.md format
  [ ] Title is "# Task [ID]: [Description]" with matching ID
  [ ] **Feature**: and **Created**: fields exist with proper formatting
  [ ] **Depends on**: / **Blocks**: added if task has dependencies
  [ ] All three sections exist: ## Problem, ## Success criteria, ## Notes
  [ ] Success criteria use - [ ] checkbox format
  [ ] File is in correct folder for current status
  [ ] 5DAY_TASK_ID in docs/STATE.md was incremented (for new tasks)

🤖 GITHUB SYNC BEHAVIOR
─────────────────────────────
  When you commit task files to main branch:

  - New files → Creates GitHub issue with "5day-task" label
  - Updated files → Updates existing GitHub issue
  - Moved files → Changes labels and status (backlog/sprint/in-progress/review/completed)
  - Deleted files → Closes corresponding GitHub issue
  - Files in live/ → Closes GitHub issue with "completed" label

  The workflow parses ## Problem and ## Success criteria sections.
  It identifies tasks using HTML comment in issue body:
    <!-- 5daydocs-task-id: [ID] -->

  Do not manually edit this in GitHub issues.

═══════════════════════════════════════════════════════════════════════════
END OF FORMAT REQUIREMENTS
═══════════════════════════════════════════════════════════════════════════
-->