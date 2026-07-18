STEP 3 of 3 — Task Execution

Picks up READY tasks from docs/tasks/next/ in order (by leading number)
and works each one in a fresh AI context window.

Readiness gate: only tasks that ./5day.sh define has stamped with
'Status: READY' are executed. A headless run can't ask clarifying
questions, so unvetted tasks are skipped (left in next/) rather than
run half-understood. Override with --force.

For each ready task it:
  - Moves the task file to doing/
  - Reads the task, reads CLAUDE.md, makes all code changes
  - Streams progress live (one line per step); full event log in docs/tmp/
  - Checks off completed items, adds a ## Completed summary
  - Moves the task file to review/ (or blocked/ if it stopped short)
  - Stops on failure so you can inspect

There is no turn limit — the per-run budget cap (BUDGET_TASKS in
docs/5day/config, default $5) is the only guardrail.

Does NOT commit. You review the changes and commit yourself.

Usage:
  ./5day.sh tasks                  # run all ready tasks in next/
  ./5day.sh tasks 3                # run at most 3 tasks
  ./5day.sh tasks 1                # run just the next task
  ./5day.sh tasks --force          # skip the readiness gate
  ./5day.sh tasks --drift          # enable pre-task drift check
  ./5day.sh tasks --audit          # enable post-task code audit
  ./5day.sh tasks --excellence     # enable post-task excellence audit (after --audit)
  ./5day.sh tasks --parallel       # run all tasks concurrently (2 jobs)
  ./5day.sh tasks --fast           # shorthand for --parallel with 4 jobs
  ./5day.sh tasks --jobs N         # run parallel with N concurrent jobs
  ./5day.sh tasks --max            # no budget cap
  ./5day.sh tasks --fast --max     # parallel (4 jobs), no budget cap
  ./5day.sh tasks --assist         # interactive mode picker
  ./5day.sh tasks --verbose        # stream full per-task event detail

Quality chain: --audit runs the correctness audit (review-code) on each task
that lands in review/; --excellence then runs the excellence audit after it
(excellence presumes correctness, so order matters). An excellence BLOCKER
verdict does NOT halt the queue — the task still routes to review/ with the
blocker recorded in its '## Excellence' section, and the end-of-run summary
counts how many blockers were found.

Inside an AI session (Claude Code, Cursor, …) tasks are dispatched to fresh
subagents in the current session. In a plain terminal they run via the CLI in
docs/5day/config. Override per-run with an env prefix:
  FIVEDAY_CLI=codex ./5day.sh tasks   # exec a specific CLI standalone
  FIVEDAY_MODE=emit ./5day.sh tasks   # force prompt emit for any agent

Model selection is handled by docs/5day/config — scripts no longer
hardcode model names. Set FIVEDAY_MODEL_TASKS in your environment or
config to override.

Full workflow:
  ./5day.sh sprint 5        # 1. plan sprint from backlog
  ./5day.sh define          # 2. review & triage queued tasks
  ./5day.sh tasks           # 3. execute the sprint
