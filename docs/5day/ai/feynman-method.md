# Feynman Protocol: Recursive Feature Decomposition

## Mission

Transform complex features into clear, actionable tasks using the Feynman Technique. No jargon. No ambiguity. Just plain English that anyone on the team can understand.

This protocol governs how features become tasks in 5DayDocs.

## The Four Phases

### Phase 1: The Problem (What & Why)

**Goal:** Capture the human outcome, not the technical solution.

**Questions to ask:**
- What problem does this solve?
- Who benefits and how?
- What does success look like?

**Constraint:** Block implementation details. Words like "React," "Postgres," "microservice" are premature. Focus on the *job to be done*.

**Validation:** "If this feature were a person, what job would they be hired to do?"

---

### Phase 2: Plain English (Clarity Filter)

**Goal:** Rewrite Phase 1 so any team member—regardless of role—can understand it.

**Jargon detection:** Flag technical terms (API, backend, database, interface, endpoint, etc.). When detected:
- Replace with analogies ("a messenger," "a filing cabinet," "a gatekeeper")
- Or define in one plain sentence

**Success test:** Could a new hire with no project context understand this?

---

### Phase 3: Decomposition (Gap Audit)

**Goal:** Break the feature into atomic pieces and validate each one.

**For each piece, ask:** *"Do we have everything needed to build this right now?"*

**Tag each piece:**
- `[READY]` — Clear path forward. Can become a task.
- `[RESEARCH]` — Knowledge gap. Needs investigation first.
- `[BLOCKED]` — Dependency or logical gap (e.g., "Can't send emails without a sender address").

**Output:** A list of atomic operations with their tags.

---

### Phase 4: Task Generation (Build Instructions)

**Goal:** Convert `[READY]` items into task descriptions.

**Constraints:**
- Each task title: 10 words max
- Each task should be completable independently
- If a task feels "heavy," recurse: run it through Phase 3 again

**Output:** Task files in `docs/tasks/backlog/`

---

## Workflow

```
docs/ideas/     → Raw ideas being refined (this protocol)
docs/features/  → Fully defined features
docs/tasks/*/*  → Actionable work items
```

### CLI Usage

```bash
./5day.sh newidea "User notifications"
```

Creates `docs/ideas/user-notifications.md` with embedded instructions.

---

## For AI Agents

When running this protocol:

1. **Phase 1-2:** Interactive. Ask questions, wait for answers. Don't assume.
2. **Phase 3:** Present decomposition, ask user to validate tags.
3. **Phase 4:** Generate tasks only after user confirms the breakdown.

Work within the idea file. Never skip phases.

---

## Error States

| Condition | Action |
|-----------|--------|
| Jargon detected in Phase 2 | Flag it. Rewrite with analogy. |
| `[BLOCKED]` item in Phase 3 | Cannot proceed to Phase 4 until resolved. |
| Task too broad in Phase 4 | Recurse to Phase 3 for that item. |

