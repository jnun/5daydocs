# AGENTS.md — AI Context for 5DayDocs Development

## This is a meta-project

We use 5DayDocs to build 5DayDocs.

## Directory meaning

* `src/` = product source (templates installed into other projects)
* `docs/` = active local 5DayDocs install (real tasks tracking this repo)
* `setup.sh .` = updates `docs/` from `src/` (dogfooding)

## `docs/` is NOT stale

Tasks in `review/` and `live/` are completed work. Old dates mean “done”, not “abandoned”.

## Workflow

1. Edit templates in `src/`
2. Run `./setup.sh .` to update the local install in `docs/`
3. Use `./5day.sh` to manage tasks for this repo
4. Read `DOCUMENTATION.md` for all 5DayDocs usage rules

## Help files

* `README.md` = dev workflow (edit `src/`, update, test)
* `DOCUMENTATION.md` = project management rules (governs `docs/`)

## Important note

We use 5DayDocs to manage 5DayDocs, so `docs/` is live and active for this project.
