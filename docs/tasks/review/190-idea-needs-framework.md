# Task 190: idea needs framework

**Feature**: none
**Created**: 2026-06-24
**Depends on**: none
**Blocks**: none

## Problem

Ideas are where you think — features are where you build. The idea framework is the structured path between a rough hunch and a set of features ready to create. Right now that path doesn't exist. `newidea` drops a blank template and walks away, and the template rushes to convergence: state the problem, describe it plainly, decompose into tasks. That's a documentation exercise, not a thinking exercise. It produces a clean-looking document from whatever limited thinking you walked in with.

A real idea framework has to expand your thinking before it narrows it. It needs to meet you wherever you are (a frustration, a hunch, a "what if"), challenge your assumptions, force you to explore multiple solutions, make you pick one and defend it, stress-test the choice, and only then produce features. Without that, ideas either rot as drafts or get skipped entirely, and features get created with half-baked reasoning behind them.

## Success criteria

### Template (docs/ideas/.TEMPLATE-idea.md)
- [x] Eight phases that move from divergent to convergent thinking:
  1. **The Spark** — raw trigger, unedited (frustration, hunch, observation, opportunity)
  2. **The Problem** — who has it, how do you know, what do they do today, cost of doing nothing
  3. **The Landscape** — prior art, what exists, what's been tried, adjacent solutions
  4. **The Brainstorm** — at least three different approaches (obvious, lazy, ambitious, weird)
  5. **The Bet** — pick a direction, state the core insight as a bet: "We believe [approach] will [solve problem] for [people] because [insight]"
  6. **The Stress Test** — pre-mortem (assume it failed — why?), assumptions check, dependencies
  7. **The Scope** — smallest thing that tests the bet, what's v1 vs. later
  8. **The Handoff** — list of features this idea produces, each traced back to the bet
- [x] Graduation checklist that gates on: problem validated (Phase 2), landscape checked (Phase 3), bet articulated (Phase 5), stress test completed (Phase 6), scope defined (Phase 7), features listed (Phase 8)

### AI-Assisted Mode (./5day.sh newidea — no args)
- [x] Launches an interactive AI session using the same dual-mode pattern as `create-feature.sh`
- [x] AI asks at least one question per phase before writing content for that phase
- [x] During Phases 1-4 (divergent), AI suggests options and angles the user hasn't mentioned rather than converging on what the user said
- [x] During Phase 6, AI explicitly names at least one reason the bet could fail and asks the user to respond
- [x] AI advances to the next phase when the user's answers satisfy that phase's requirements, without requiring the user to say "next"
- [x] AI synthesizes the conversation into a filled-out idea document at the end
- [x] AI evaluates the graduation checklist and flags any gates that aren't met

### AI Guidance (docs/5day/ai/feynman-method.md)
- [x] Updated to reflect the eight-phase framework
- [x] Instructions for AI posture: divergent early (open up), convergent late (close down)
- [x] Guidance on challenging vs. accepting — when to push back, when to move on

## Notes

- Mirror the dual-mode pattern from `create-feature.sh`: argument = fast template, no argument = AI-assisted Q&A
- AI plumbing already exists: `fiveday_run`, model resolution, project profile injection
- The idea doc becomes the permanent record of *why* features exist; features carry the *what*
- The AI posture for ideas is fundamentally different from features: feature definition is convergent (nailing down specifics), idea refinement is divergent-then-convergent (open up before you close down)
- The user doesn't always start with a problem — sometimes it's a hunch, a frustration, something they saw elsewhere. The Spark phase handles all entry points
- Unlike other templates, the idea template has a live copy in `docs/ideas/.TEMPLATE-idea.md` that `create-idea.sh` reads from at runtime. Edit the `docs/` copy first, test, then mirror to `src/`
- Files to update: `docs/ideas/.TEMPLATE-idea.md`, `docs/5day/ai/feynman-method.md`, `docs/5day/scripts/create-idea.sh`
- After testing in docs/, mirror to src/: `src/docs/ideas/.TEMPLATE-idea.md`, `src/docs/5day/ai/feynman-method.md`, `src/docs/5day/scripts/create-idea.sh`
- See `docs/ideas/special-sauce.md` for the depth and specificity each phase should reach — it uses the old 4-phase structure, but the quality of thinking (concrete problem, jargon-free language, resolved open questions) is the benchmark

## Think Notes

- **Reviewed**: 2026-06-24
- Graduation checklist gates intentionally skip Phase 1 (The Spark) and Phase 4 (The Brainstorm) — those are generative phases that produce raw input, not gate-able artifacts
- AI criteria reframed from subjective intent ("acts as a thinking partner") to observable session behaviors (questions per phase, divergent suggestions, explicit failure naming)
- DOCUMENTATION.md deliberately not updated as part of this task — the Ideas Workflow section there will stay as-is for now
- Context window estimate: ~1,000 lines in, ~350 lines out — fits comfortably in a single implementation session
- Fast mode (argument-provided path) already works in `create-idea.sh` and doesn't need its own criteria — it inherits the template changes automatically

## Completed

**Files changed:**
- `docs/ideas/.TEMPLATE-idea.md` — Rewrote from 4-phase (Problem → Plain English → Decomposition → Open Questions) to 8-phase divergent-then-convergent framework (Spark → Problem → Landscape → Brainstorm → Bet → Stress Test → Scope → Handoff). New graduation checklist gates on Phases 2, 3, 5, 6, 7, 8.
- `docs/5day/ai/feynman-method.md` — Rewrote to match 8-phase framework. Added "Two Postures" section (divergent vs convergent), per-phase AI question guidance, graduation gate table, and "Challenging vs Accepting" rules.
- `docs/5day/scripts/create-idea.sh` — Added dual-mode pattern: argument = fast template creation, no argument = AI-assisted interactive session via `fiveday_run`. AI prompt instructs per-phase questioning, divergent suggestions in Phases 1–4, adversarial stress-testing in Phase 6, and graduation checklist evaluation.
- `docs/5day/help/newidea.md` — Updated to document both modes.
- `src/docs/ideas/.TEMPLATE-idea.md` — Mirrored from docs/
- `src/docs/5day/ai/feynman-method.md` — Mirrored from docs/
- `src/docs/5day/scripts/create-idea.sh` — Mirrored from docs/
- `src/docs/5day/help/newidea.md` — Mirrored from docs/

**Tested:** Fast-mode template creation (`./5day.sh newidea "test-name"`) and fresh install via `setup.sh` both verified.

<!--
AI: Full task-writing guidance is in docs/5day/ai/task-creation.md
-->
