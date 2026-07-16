STEP 2 of 3 — Task Definition Review

Reviews each task in docs/tasks/next/ against the current codebase.
For each task it:
  - Checks which action items are already done (and verifies quality)
  - Identifies remaining work
  - Asks clarifying questions with suggestions when decisions are needed
  - Writes a ## Questions section into the task file

Verdicts:
  READY   — task stays in next/, ready for execution
  BLOCKED — task moves to blocked/, needs developer answers first
  DONE    — task moves to review/, all work is already complete

Usage:
  ./5day.sh define          # review all tasks in next/
  ./5day.sh define 3        # review at most 3 tasks
  ./5day.sh define 1        # review just the next task

After running:
  - READY tasks: run ./5day.sh tasks to execute them
  - BLOCKED tasks: answer questions in the file, move back to next/
  - DONE tasks: verify in review/, then move to done/
