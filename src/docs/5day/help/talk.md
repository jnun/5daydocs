Talk an existing task through, refining it — and splitting it if needed.

Finds a task by ID, reads it, then launches a conversation that first
sizes the task up: is it one atomic job, or several jobs bundled together?

  - If it's several, it proposes a breakdown, and on your OK creates the
    sub-tasks with `./5day.sh newtask` (real IDs, standard template,
    **Parent** linked back so `sprint parent:N` still gathers them), then
    talks through each microtask to add real detail. The original is
    retired once its children exist.
  - If it's genuinely one job, it refines in place — one detail at a time:
    ask a question, polish your answer with you, edit the file right then,
    move to the next gap.

Either way the result is an executive-summary-level brief — clear about
what "done" looks like, with suggested technology choices and references,
but no code.

Use this when a task you wrote feels half-baked and you want to think it
through out loud. To fill in a blank task from scratch, use `plan`; to
split a task without the conversation, use `split`.

Usage:
  ./5day.sh talk <task-id>

What it does:
  - Sizes the task up first, then splits or refines accordingly
  - Asks one focused question at a time, targeting the biggest gap
  - Lays out open technical decisions with a recommended default and its
    rationale, flagging security and performance trade-offs
  - Polishes each answer, then edits immediately (atomic edits, not one
    rewrite at the end)
  - Fills ## Problem, ## Success criteria, and ## Notes at a summary
    altitude — technologies and reasons, plus references to repo files and
    external docs; never code snippets

Searches: blocked/, backlog/, next/, doing/
