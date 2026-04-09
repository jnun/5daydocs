# 5DayDocs

**Project management using folders and markdown files. No databases, no apps.**

5DayDocs installs into any project and gives you a `docs/` folder where tasks, bugs, features, and ideas are tracked as plain markdown files. A task's status is determined by which folder it lives in. Moving a file between folders changes its status.

```
docs/tasks/backlog/   -->  Planned, not started
docs/tasks/next/      -->  Queued for current sprint
docs/tasks/working/   -->  In progress
docs/tasks/blocked/   -->  Waiting on a product owner or engineer decision
docs/tasks/review/    -->  Done, awaiting approval
docs/tasks/live/      -->  Shipped
```

That's the core idea. Everything else builds on it.

## What you get after installation

Running `setup.sh` on your project adds:

| File/Folder | Purpose |
|---|---|
| `5day.sh` | CLI for creating tasks, bugs, features, and checking status |
| `DOCUMENTATION.md` | Complete workflow guide (the real manual) |
| `CLAUDE.md` | Auto-loaded context for Claude Code / AI agents |
| `docs/5day/DOC_STATE.md` | Tracks auto-incrementing task and bug IDs |
| `docs/tasks/` | Task pipeline folders (backlog, next, working, blocked, review, live) |
| `docs/bugs/` | Bug reports |
| `docs/features/` | Feature specifications |
| `docs/ideas/` | Ideas in refinement |
| `docs/5day/scripts/` | Automation scripts powering the CLI |
| `docs/5day/ai/` | AI guidance files for task writing |

Your project root stays clean: just `5day.sh`, `DOCUMENTATION.md`, and `CLAUDE.md`.

## Installation

```bash
# Option A: Clone standalone (recommended)
git clone https://github.com/jnun/5daydocs.git
cd 5daydocs
chmod +x setup.sh
./setup.sh
# When prompted, enter the path to your project root (e.g., /Users/you/myproject)

# Option B: As a Git submodule
git submodule add https://github.com/jnun/5daydocs.git 5daydocs
cd 5daydocs
chmod +x setup.sh
./setup.sh
```

To update an existing installation, re-run `setup.sh` pointing at the same project. Your `DOC_STATE.md` (task/bug IDs) is preserved.

## CLI Commands

### Creating work items

```bash
./5day.sh newtask "Fix login timeout"          # --> docs/tasks/backlog/42-fix-login-timeout.md
./5day.sh newbug "Button unresponsive"          # --> docs/bugs/8-button-unresponsive.md
./5day.sh newfeature "User authentication"      # --> docs/features/user-authentication.md
./5day.sh newidea "Push notifications"          # --> docs/ideas/push-notifications.md
```

Each task and bug gets an auto-incrementing ID from `docs/5day/DOC_STATE.md`. Files are named `{ID}-{description}.md` and created from templates.

### Checking status

```bash
./5day.sh status            # Task counts by folder, open bugs, feature status
./5day.sh checkfeatures     # Verify feature/task alignment
./5day.sh ai-context        # Quick project state summary for AI agents
```

### Moving tasks through the pipeline

```bash
git mv docs/tasks/backlog/42-fix-login-timeout.md docs/tasks/next/
git mv docs/tasks/next/42-fix-login-timeout.md docs/tasks/working/
git mv docs/tasks/working/42-fix-login-timeout.md docs/tasks/blocked/   # Needs decision
git mv docs/tasks/blocked/42-fix-login-timeout.md docs/tasks/next/      # Unblocked
git mv docs/tasks/working/42-fix-login-timeout.md docs/tasks/review/
git mv docs/tasks/review/42-fix-login-timeout.md docs/tasks/live/
```

### AI-driven sprint workflow (optional)

5DayDocs includes three scripts for AI-assisted sprint execution:

```bash
# Step 1: Plan a sprint (picks tasks from backlog, writes tmp/sprint-plan.md)
bash docs/5day/scripts/sprint.sh 5

# Step 2: Review queued tasks against current code (marks READY, BLOCKED, or DONE)
bash docs/5day/scripts/define.sh

# Step 3: Execute tasks (Claude makes code changes, moves completed tasks to review/)
bash docs/5day/scripts/tasks.sh
```

You review and commit after each step.

## Task file format

Every task follows this structure:

```markdown
# Task 42: Fix login timeout

**Feature**: /docs/features/user-authentication.md
**Created**: 2026-04-04
**Depends on**: none
**Blocks**: none

## Problem
[What needs solving and why]

## Success criteria
- [ ] [Observable, verifiable behavior]

## Notes
[Dependencies, edge cases, links]
```

Bug reports follow a similar structure with severity levels and reproduction steps.

## For AI agents

If you are an AI agent working in a project that uses 5DayDocs:

1. Read `DOCUMENTATION.md` first. It is the complete reference.
2. Read `docs/5day/DOC_STATE.md` before creating any task or bug (to get the current ID).
3. Use `./5day.sh` commands to create work items. Do not create task files manually.
4. Do not edit files under `docs/5day/`. Those are framework files managed by `setup.sh`.
5. Tasks in `blocked/` need a human decision before work can continue. Do not attempt to unblock them.
6. Tasks in `review/` and `live/` are completed work. Do not modify them.
7. Folder = status. Move files between folders to change status.

## Contributing to 5DayDocs

This repo uses 5DayDocs to manage itself (dogfooding). Two directories matter:

```
docs/  --> Live working environment (scripts, tasks, bugs — everything runs from here)
src/   --> Distribution source (what setup.sh installs into user projects)
```

### Development workflow

1. **Edit in `docs/`** — this is the live environment. Changes take effect immediately so you can test in real time.
2. **Sync to `src/`** — once your changes work, copy the modified files into `src/` so they become part of the distribution.
3. **Test the install** — run `./setup.sh` against a temporary directory to verify a fresh installation works with your changes.
4. **Commit.**

The flow is `docs/` (develop and test) → `src/` (distribute) → `setup.sh` (install).

### What lives where

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

### Why this order

Editing `src/` first and running `setup.sh .` to sync into `docs/` is slower — you have to run the installer after every change just to see if it works. Editing `docs/` directly lets you iterate without that overhead. `src/` is the packaging step, not the development step.

---

*Simple, folder-based project management with markdown files and optional AI automation.*
