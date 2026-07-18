Interactive walk-through of the task pipeline.

AI assesses each task, human decides what to do. Walks blocked/,
next/, backlog/ in priority order.

Usage:
  ./5day.sh triage            # triage all
  ./5day.sh triage 5          # triage at most 5 tasks

Related commands (how they differ):
  triage  — this command: interactive. AI assesses, you decide per task
            (work/define/kill/skip).
  audit   — the non-interactive form: the AI applies the verdict itself
            (DONE→review, OUTDATED→delete, UNDEFINED→blocked) with no prompts.
  define  — a deeper, per-task pre-sprint review of next/ that writes the
            ## Questions readiness gate ./5day.sh tasks enforces.
