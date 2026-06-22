# Task 180: Project profile onboarding questionnaire

**Feature**: none
**Created**: 2026-06-20
**Depends on**: none
**Blocks**: none

## Problem

When `find --work` executes a task, the spawned AI session gets generic context (CLAUDE.md, DOCUMENTATION.md) but knows nothing about the project's language, framework, test strategy, or coding conventions. This means every task prompt lacks the project-specific policy that would make AI execution significantly more effective. Users shouldn't have to repeat this context in every task file.

We need a profile command that captures a project's key technical choices and writes them to `docs/5day/project.md`. All AI-powered scripts should include this profile in every prompt so tasks inherit project context automatically.

## Success criteria

- [x] `./5day.sh profile` launches an AI-guided session (same pattern as `plan.sh`) that auto-detects what it can from the project (file extensions, package manifests, linter configs, test directories) and confirms with the user
- [x] Profile covers these essentials: primary language, framework/stack, test runner and strategy (where tests live, unit vs integration patterns), style/linting conventions, error handling patterns (Result types, exceptions, error codes, etc.), key directory structure and what lives where
- [x] Output is written to `docs/5day/project.md` — flat key-value style, one screen, human-editable
- [x] Re-running `./5day.sh profile` reads the existing file and asks what's changed
- [x] All AI-powered scripts (`find.sh`, `define.sh`, `sprint.sh`, `tasks.sh`, `plan.sh`) include `docs/5day/project.md` in their context when it exists
- [x] If `project.md` doesn't exist, `find --work` prints a one-line tip (not a blocker)
- [x] Script lives in `docs/5day/scripts/profile.sh`, mirrored to `src/docs/5day/scripts/profile.sh`
- [x] `5day.sh` wired up with `profile` command in help text and case statement
- [x] Fresh install via `setup.sh` verified — profile is not created automatically, only on explicit `./5day.sh profile` invocation

## Notes

- The profile is project-level context, not user-level. It describes the project's stack and conventions, not individual preferences.
- Use AI to do the interviewing, not a bash questionnaire. The AI can read the project to pre-fill obvious answers (language from file extensions, framework from package manifests, test runner from configs) and only ask about what it can't infer. This keeps the interaction to 2-3 confirmations instead of 5-8 manual questions.
- Target output format — flat, scannable, no nesting:
  ```
  # Project Profile
  **Language:** TypeScript
  **Framework:** Next.js 14 (App Router)
  **Tests:** Vitest, tests alongside source in `__tests__/`
  **Style:** ESLint + Prettier, pre-commit hook
  **Error handling:** Zod for validation at boundaries, thrown errors elsewhere
  **Structure:** Feature folders under `src/features/`, shared utilities in `src/lib/`
  **Patterns:** tRPC for API layer, no raw SQL
  ```
- Per CLAUDE.md: edit in `docs/5day/scripts/`, test in place, mirror to `src/docs/5day/scripts/`.
