# Task 201: Test the talk feature completely

**Feature**: none
**Created**: 2026-07-23
**Depends on**: none
**Blocks**: none
**Parent**: none

## Problem

<!-- What needs solving and why — 2-5 sentences, plain English. -->

Verify the `talk` feature (`docs/5day/scripts/talk.sh`) works as a *shipped* feature, not just inside this repo. Cut a release candidate of 5DayDocs, install it into a real project the way an actual user would (via `setup.sh`), then run `talk` on that project's genuine, under-specified tasks. Judge whether the give-and-take Q&A actually turns a vague task into a workable one — a filled-in Problem, verifiable Success criteria, and Notes with sensible technology choices and references. Where talk fails to deliver its promised outcomes, capture that as concrete feedback. This is a manual, end-to-end acceptance test in a real installed environment: the proof is a genuinely useful task at the end plus a clear list of any gaps found.


## Success criteria

<!-- Observable behaviors: "User can [do what]" / "App shows [result]" -->

- [ ] `./setup.sh` installs a fresh copy into a real test project when pointed at it; `talk` and its dependencies (talk.sh, lib.sh, ai guidance) land and are runnable there
- [ ] Running `./5day.sh talk <task-id>` on a real, under-specified task in that project launches an interactive Q&A session (or, if the environment can't do interactive, it says so honestly and does a single refinement pass — it does not fake a conversation)
- [ ] The session asks one question at a time — a real loop through the task, one detail per turn — not a batch of questions or a single rewrite at the end
- [ ] The task file is updated after each answer/decision, so progress is visible in the file as the conversation moves, not only when it finishes
- [ ] When the walk-through finishes, the task has a filled-in Problem, verifiable Success criteria checkboxes, and Notes with sensible technology choices and references
- [ ] When the task is really several jobs, talk splits it into good sequential minitasks — atomic, ordered so dependencies come first, each independently workable
- [ ] The resulting task reads as a fully functional task — a developer who never saw the conversation could pick it up and build it
- [ ] The user evaluates the resulting task file and reports the outcome: whether talk delivered its promised outcomes, and where it fell short

## Notes

This is a manual, user-judged acceptance test — there is no automated harness and no auto-filed bugs. The tester runs the flow and reports the outcome by hand.

**The procedure:**
1. `./setup.sh` and point it at a real test project (a fresh copy — nothing real gets mutated).
2. In that project, pick a genuine, under-specified task: `./5day.sh talk <task-id>`.
3. Answer the questions one at a time and watch the file update after each decision.
4. When it finishes, read the resulting task and judge whether it's fully functional.

**Promised outcomes talk must deliver (this is the pass bar):**
- A real one-detail-at-a-time loop — one question per turn, polished together before it lands.
- The task file edited incrementally after each answer, not batched to the end.
- A finished task with a filled Problem, verifiable Success criteria, and Notes carrying technology choices (with reasoning) and references.
- When the task is several jobs, a clean split into sequential minitasks — atomic, dependency-ordered, each independently workable.

**Pass definition:** running the flow end-to-end and reporting the result is itself a successful test. Surfacing shortfalls is a good outcome, not a failure — the deliverable is a fully functional task file *plus* the tester's report of where talk did or didn't deliver.

**Precondition:** `talk` installs from `src/`, so before cutting the RC confirm `src/docs/5day/` is mirrored from the tested `docs/5day/` (talk.sh, lib.sh, and the ai/ + guides/ files it reads). A stale `src/` is exactly the class of bug this test exists to catch.

**References:**
- `docs/5day/scripts/talk.sh` — the feature under test; the appended system prompt at lines 64-103 is the literal specification of talk's promised behavior.
- `docs/5day/guides/use_talk.md` — user-facing guide for the talk experience and interactive requirements.
- `docs/5day/ai/task-creation.md` — the task-writing standard the resulting file should meet.
- `setup.sh` (repo root) — the installer that produces the release candidate in the test project.

<!--
AI: Full task-writing guidance is in docs/5day/ai/task-creation.md
-->
