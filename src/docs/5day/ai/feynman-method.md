# Feynman Protocol: AI Execution Guide

> **Theory:** [docs/5day/theory/feynman-method.md](../theory/feynman-method.md)

## When to Use

Run this protocol when refining an idea in `docs/ideas/`. Typically triggered by `./5day.sh newidea <name>`.

## How to Execute

Work inside the idea file. Follow the four phases in order. Never skip a phase.

### Phase 1-2: Interactive Discovery

1. Read the idea file.
2. Ask the user the Phase 1 questions (What problem? Who benefits? What does success look like?).
3. Wait for answers. Do not assume or fill in.
4. Rewrite answers in plain English (Phase 2). Flag any jargon and replace with analogies or plain definitions.
5. Confirm with the user: "Does this capture it?"

### Phase 3: Decomposition

1. Break the feature into atomic pieces.
2. Present each piece to the user with a tag: `[READY]`, `[RESEARCH]`, or `[BLOCKED]`.
3. Ask the user to validate the tags.
4. Resolve any `[BLOCKED]` items before proceeding.

### Phase 4: Task Generation

1. Only proceed after the user confirms the Phase 3 breakdown.
2. Convert `[READY]` items into task files in `docs/tasks/backlog/`.
3. Each task title: 10 words max.
4. Each task must be completable independently.
5. If a task feels too broad, recurse it through Phase 3.

## Rules

- Work within the idea file. Update it as you go.
- Ask questions, wait for answers. Don't fill sections without user input.
- One phase at a time. Confirm before advancing.
- `[BLOCKED]` items halt progress to Phase 4 until resolved.
