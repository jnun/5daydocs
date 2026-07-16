Interactive Q&A session to define an incomplete or complex task.

Finds a task by ID, reads it, then launches a conversational session
that asks probing questions to fill in the Problem, Success criteria,
and Notes sections — producing an actionable task.

Usage:
  ./5day.sh plan <task-id>

After running:
  - The task file is updated in place with a complete definition
  - If the task was in blocked/, it moves to backlog/
