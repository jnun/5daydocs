# 5DayDocs Documentation State

Part of the 5daydocs documentation system, not source code for the host project.
Managed by scripts in `docs/5day/scripts/` and by `setup.sh`. Safe to edit by hand
if you need to fix a counter — the field lines below are what scripts parse.

Fields:
- `5DAY_VERSION`   — installed file-structure version; `setup.sh` reads this on upgrade to decide which migrations to run
- `5DAY_TASK_ID`   — highest task ID used; next task = this + 1
- `5DAY_BUG_ID`    — highest bug ID used; next bug = this + 1
- `SYNC_ALL_TASKS` — GitHub Issues sync flag (managed by `sync.sh`)
- `Last Updated`   — ISO date; bump when you change a field

---

**Last Updated**: 2026-04-16
**5DAY_VERSION**: 2.2.1
**5DAY_TASK_ID**: 167
**5DAY_BUG_ID**: 1
**SYNC_ALL_TASKS**: false
