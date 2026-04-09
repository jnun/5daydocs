# Task 149: AI-bootstrap CLAUDE.md / AGENTS.md / cursor / windsurf / copilot files

**Feature**: none
**Created**: 2026-04-08
**Depends on**: none
**Blocks**: 150

## Problem

The AI bootstrap files we ship today (`src/CLAUDE.md`, `src/AGENTS.md`, `src/.cursorrules`, `src/.windsurfrules`, `src/copilot-instructions.md`) are minimal pointers that say "read DOCUMENTATION.md". That's the right *direction* — never duplicate truth, always link to the canonical source — but it's the weakest possible execution of it. An AI agent landing in a user's repo with one of these files learns nothing about *that specific project*: its structure, its conventions, its key directories, the relationships between its features and its tasks.

The result is that AI agents either (a) ignore the file and run their own discovery, or (b) read DOCUMENTATION.md and get generic 5DayDocs guidance with zero project-specific grounding. Either way, they drift away from the project's actual conventions on every session, because nothing primes them on what's already there.

The fix is to generate these files from an analysis of the user's actual codebase. The generated file is still mostly pointers — but the pointers are *project-specific*, durable, and lead the agent into `DOCUMENTATION.md` and the relevant `docs/` files in the right order. The file should be bulletproof: never restate facts that live in `docs/`, only reference them, so the file itself never goes stale.

## Success criteria

- [ ] User can run `./5day.sh bootstrap-ai` (or equivalent) to generate all AI bootstrap files for their project
- [ ] Generator analyzes the user's codebase: top-level structure, primary language, framework markers, presence of `docs/features/`, `docs/tasks/`, `docs/guides/`, etc.
- [ ] Generator produces a CLAUDE.md (and the other variants) that:
  - [ ] Names the project and its primary language/framework
  - [ ] Tells the agent to read `DOCUMENTATION.md` first, and explains why (single source of truth for the 5DayDocs system)
  - [ ] Lists the project-specific `docs/` files the agent should read at the start of each task, with one-line "why" annotations
  - [ ] Lists the project-specific conventions worth knowing (where features live, where tasks live, the pipeline flow)
  - [ ] Contains zero facts that duplicate `DOCUMENTATION.md` or `docs/` content — only references
- [ ] Generated file is checked against a structural template so it can't omit required sections
- [ ] Each variant (`AGENTS.md`, `.cursorrules`, `.windsurfrules`, `copilot-instructions.md`) is a format-appropriate rendering of the same underlying content
- [ ] Generator can run with or without an LLM. Without an LLM: produces a strong template-driven version using static analysis. With an LLM available: enriches the template with project-specific reasoning.
- [ ] Re-running the generator is safe: it diffs against existing files and asks for confirmation, like task 148

## Notes

- Live in `src/docs/5day/scripts/bootstrap-ai.sh`
- Reuses the project profile from task 148 if available (`docs/5day/project.yml`)
- The "bulletproof" property is enforced by the template: every generated section is either a literal pointer (`See: docs/features/INDEX.md`) or an annotated pointer (`See docs/features/auth.md — describes the auth flow used throughout the codebase`). No section is allowed to contain prose that could go stale.
- This is the file that task 150 will use to enforce DOCUMENTATION.md priming — so the structural template must include a "Read these first" section that task 150 can rely on.
- Out of scope: managing the AI files in *this* repo's `src/` tree. Those continue to be hand-edited minimal pointers, because this repo is the source distribution, not a user project.
