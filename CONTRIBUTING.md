# Contributing to 5DayDocs

5DayDocs is a file-based project-management system that installs into other people's projects. This repo dogfoods what it builds: we use 5DayDocs to manage 5DayDocs's own development. The dogfooding is incidental — **the product is what ships, not the work we do here.**

## The dual tree

This repo has two parallel trees and you must always know which one you are touching:

```
docs/  --> Live working environment (scripts, tasks, bugs — everything runs from here)
src/   --> Distribution source (what setup.sh installs into user projects)
```

- **`docs/`** is the live development environment. Scripts in `docs/5day/scripts/` actually run when you invoke `./5day.sh`. Tasks in `docs/tasks/` track this repo's own work. Edit and test here.
- **`src/`** is the distribution package. `setup.sh` reads files from here and installs them into a target user's project. It is **not** a development environment. Never iterate inside `src/`; never run anything from it.

The flow is **edit `docs/` → test in place → mirror to `src/`**. A change that lands only in `docs/` works locally but never reaches users. A change that lands only in `src/` ships untested.

`setup.sh` lives at the repo root and is the installer. It is not distributed itself.

## Development workflow

1. **Edit in `docs/`** — this is the live environment. Changes take effect immediately so you can test in real time.
2. **Sync to `src/`** — once your changes work, copy the modified files into `src/` so they become part of the distribution.
3. **Test the install** — run `./setup.sh` against a temporary directory to verify a fresh installation works with your changes.
4. **Commit.**

The flow is `docs/` (develop and test) → `src/` (distribute) → `setup.sh` (install).

### Why this order

Editing `src/` first and running `setup.sh .` to sync into `docs/` is slower — you have to run the installer after every change just to see if it works. Editing `docs/` directly lets you iterate without that overhead. `src/` is the packaging step, not the development step.

## What lives where

| Location | Role | Editing |
|---|---|---|
| `docs/5day/scripts/` | Live scripts that run when you use `./5day.sh` | Edit here first |
| `docs/5day/ai/` | Live AI guidance files | Edit here first |
| `DOCUMENTATION.md` | Live user guide | Edit here first |
| `src/docs/5day/scripts/` | Distribution copy of scripts | Sync from `docs/` after testing |
| `src/docs/5day/ai/` | Distribution copy of AI files | Sync from `docs/` after testing |
| `src/DOCUMENTATION.md` | Distribution copy of user guide | Sync from `docs/` after testing |
| `setup.sh` | Installer (not distributed) | Edit directly |
| `docs/tasks/`, `docs/bugs/` | Project work tracking | Normal 5DayDocs usage |

## What ships and what doesn't

A user installing 5DayDocs gets the **framework**: scripts, templates, the manual (`DOCUMENTATION.md`), minimal AI pointer files, and empty starter folders. **They do not get our work.**

Two things in this repo look like they might be distributable but are not:

1. **Root-level files** — `README.md`, `CLAUDE.md`, this `CONTRIBUTING.md`, and anything else at the repo root that isn't `setup.sh` or `DOCUMENTATION.md` — exist to support development of 5DayDocs. They never reach users. The only path for content to reach a user's project is to be deliberately placed under `src/` and wired into `setup.sh`. **If you can't point to a file under `src/`, it does not ship.**

2. **Our usage of the framework under `docs/`** — `docs/tasks/`, `docs/bugs/`, `docs/features/`, `docs/ideas/` — is *us using 5DayDocs to manage 5DayDocs*. None of it is distributed. Users get empty starter folders, not our task files. The only subtree under `docs/` that ships is `docs/5day/`, which is mirrored into `src/docs/5day/`.

The rule: nothing in this repo reaches users unless it has been deliberately built in `src/`. When in doubt, the answer is no.

A specific trap: do not bloat user-territory files in `src/` with development concerns. `src/CLAUDE.md`, `src/AGENTS.md`, etc. are minimal three-line pointers to `DOCUMENTATION.md` *on purpose* — the user owns those files in their project, and the installer either prepends a single reference or asks before creating one. Never enrich, generate, or templatize them.

## Verifying an install

After mirroring changes to `src/`, verify a fresh install works:

```bash
mkdir /tmp/test-5day && ./setup.sh
# enter /tmp/test-5day when prompted, verify output, then:
rm -rf /tmp/test-5day
```

Anything that breaks here is a release blocker — it means a user's first experience with the change is broken.

## Tracking work in this repo

This repo uses 5DayDocs to manage its own work. The task files in `docs/tasks/` are dev-internal and never distributed. Read `DOCUMENTATION.md` for how the task pipeline works. Always use `./5day.sh` commands to create work items — never create task files manually.
