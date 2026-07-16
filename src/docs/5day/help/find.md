Find a task by ID, analyze its state, and optionally work it.

Without flags: prints a prompt you can copy/paste into any AI tool.
With --think: interactive analysis session to stress-test task quality.
With --work: runs the full lifecycle in one AI call:
  1. Reads the task file and checks the codebase
  2. If done — marks ## Completed, moves to review/
  3. If blocked — writes ## Blocked Analysis, moves to blocked/
  4. If workable — implements, marks ## Completed, moves to review/

Usage:
  ./5day.sh find <task-id>           # show prompt
  ./5day.sh find <task-id> --think   # analyze task quality (interactive)
  ./5day.sh find <task-id> --work    # analyze, move, work
