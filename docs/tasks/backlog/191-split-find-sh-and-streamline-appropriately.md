# Task 191: split find.sh and streamline appropriately

**Feature**: none
**Created**: 2026-07-16
**Depends on**: none
**Blocks**: none

## Problem

`docs/5day/scripts/find.sh` is ~463 lines and is really three tools in one file:
(1) a default prompt-only mode that prints task context to stdout, (2) a `--think`
interactive quality reviewer with a large inline prompt and a sibling-task
collection loop, and (3) a `--work` executor with three stage-specific prompt
variants and a ~40-line signal-routing block that greps the task for
`## Completed` / `## Blocked Analysis` and moves it. The three responsibilities
inflate the file and duplicate logic that other scripts already solved (task
resolution, profile-line, model args). It should be split so each mode is small
and readable, and shared logic should move to `lib.sh`.

This is the last of the workflow scripts still to be converted to the emit/exec
model added in `lib.sh` (`fiveday_run` + `fiveday_ai_mode`). find.sh predates
that work and partially duplicates it; `--think`/`--work` are currently pinned to
exec mode as a stopgap so the new router doesn't emit-and-misroute for them.

## Success criteria

- [ ] `find.sh` default mode uses `fiveday_find_task` from lib.sh instead of its own by-ID resolver
- [ ] `--work` and/or `--think` are extracted into focused scripts (or clearly separated functions), so no single file mixes all three modes
- [ ] find's AI calls route through the mode-aware `fiveday_run` (emit/exec) like plan/sprint/define/split/tasks — and the temporary `FIVEDAY_MODE=exec` pin in find.sh is removed
- [ ] The stage-routing block (`## Completed` / `## Blocked Analysis` → move) is shared with `tasks.sh`'s `_route_result` where the logic overlaps, or extracted to lib.sh
- [ ] Total line count meaningfully reduced; each resulting script is single-purpose
- [ ] Local color-code block removed in favour of lib.sh colours

## Notes

Context: filed during the lib.sh/emit-mode refactor that converted plan, sprint,
define, split, triage, tasks, profile, and newfeature to the mode-aware
`fiveday_run`, and made `tasks` emit a subagent-dispatch plan when Claude Code is
the driver. find.sh was intentionally deferred because its three-in-one structure
needs a design decision (split into separate `./5day.sh` subcommands vs. internal
functions) before mechanical conversion.

Relevant helpers now in `lib.sh`: `fiveday_find_task`, `fiveday_profile_line`,
`fiveday_log_path`, `fiveday_ai_mode`, `fiveday_emitted`, colours. The temporary
exec pin lives near the top of `find.sh` (search for "tracked as its own task").
