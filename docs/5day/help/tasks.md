STEP 3 of 3 — Task Execution

Picks up tasks from docs/tasks/next/ in order (by leading number)
and works each one in a fresh AI context window.

For each task it:
  - Moves the task file to doing/
  - Reads the task, reads CLAUDE.md, makes all code changes
  - Checks off completed items, adds a ## Completed summary
  - Moves the task file to review/
  - Stops on failure so you can inspect

Does NOT commit. You review the changes and commit yourself.

Usage:
  ./5day.sh tasks                  # run all tasks in next/
  ./5day.sh tasks 3                # run at most 3 tasks
  ./5day.sh tasks 1                # run just the next task
  ./5day.sh tasks --drift          # enable pre-task drift check
  ./5day.sh tasks --audit          # enable post-task code audit
  ./5day.sh tasks --parallel       # run all tasks concurrently (2 jobs)
  ./5day.sh tasks --fast           # shorthand for --parallel with 4 jobs
  ./5day.sh tasks --max            # no turn limit or budget cap
  ./5day.sh tasks --fast --max     # parallel (4 jobs), no limits
  ./5day.sh tasks --assist         # interactive mode picker
  ./5day.sh tasks --claude         # use claude CLI profile
  ./5day.sh tasks --openai         # use openai CLI profile
  ./5day.sh tasks --gemini         # use gemini CLI profile
  ./5day.sh tasks --mistral        # use mistral CLI profile

Model selection is handled by docs/5day/config — scripts no longer
hardcode model names. Set FIVEDAY_MODEL_TASKS in your environment or
config to override.

Full workflow:
  ./5day.sh sprint 5        # 1. plan sprint from backlog
  ./5day.sh define          # 2. review & triage queued tasks
  ./5day.sh tasks           # 3. execute the sprint
