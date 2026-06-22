# Feynman Protocol: Idea Refinement

Transform rough ideas into clear, actionable tasks. No jargon. No ambiguity. Plain English that anyone on the team can understand.

## When to Use

Run this protocol when refining an idea in `docs/ideas/`. Typically triggered by `./5day.sh newidea <name>`.

## How to Execute

Work inside the idea file. Follow the four phases in order. Never skip a phase. Ask questions, wait for answers — don't fill sections without user input.

### Phase 1: The Problem (What & Why)

Capture the human outcome, not the technical solution.

Ask the user:
- What problem does this solve?
- Who benefits and how?
- What does success look like?

Block implementation details. Words like "React," "Postgres," "microservice" are premature — focus on the job to be done. Test: "If this feature were a person, what job would they be hired to do?"

Confirm with the user: "Does this capture it?"

### Phase 2: Plain English (Clarity Filter)

Rewrite Phase 1 so any team member — regardless of role — can understand it.

Flag technical terms (API, backend, database, interface, endpoint, etc.). When detected:
- Replace with analogies ("a messenger," "a filing cabinet," "a gatekeeper")
- Or define in one plain sentence

Test: Could a new hire with no project context understand this?

### Phase 3: Decomposition (Gap Audit)

Break the feature into atomic pieces. For each piece, ask: "Do we have everything needed to build this right now?"

Tag each piece:
- `[READY]` — Clear path forward. Can become a task.
- `[RESEARCH]` — Knowledge gap. Needs investigation first.
- `[BLOCKED]` — Dependency or logical gap.

Present tags to the user for validation. `[BLOCKED]` items halt progress to Phase 4 until resolved.

### Phase 4: Task Generation

Only proceed after the user confirms the Phase 3 breakdown.

Convert `[READY]` items into task files in `docs/tasks/backlog/`. Each task title: 10 words max. Each task must be completable independently. If a task feels too broad, recurse it through Phase 3.

## Workflow

```
docs/ideas/     -> Raw ideas being refined (this protocol)
docs/features/  -> Fully defined features
docs/tasks/*/*  -> Actionable work items
```

## Error States

| Condition | Action |
|-----------|--------|
| Jargon detected in Phase 2 | Flag it. Rewrite with analogy. |
| `[BLOCKED]` item in Phase 3 | Cannot proceed to Phase 4 until resolved. |
| Task too broad in Phase 4 | Recurse to Phase 3 for that item. |
