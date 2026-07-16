Audit tasks for quality.

Usage:
  ./5day.sh audit                    # audit tasks in next/
  ./5day.sh audit backlog            # audit backlog tasks
  ./5day.sh audit backlog 5          # audit at most 5
  ./5day.sh audit backlog 5 10       # start at offset 10

Folders: next (default), backlog, doing, blocked.
Review and done are not auditable (completed work).
