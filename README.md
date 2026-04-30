# 5DayDocs

## What is this

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

## Install

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

After install, your project root stays clean — just `5day.sh`, `DOCUMENTATION.md`, and `CLAUDE.md`. Everything else lives under `docs/`:

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

## What it does

### Create work items

```bash
./5day.sh newtask "Fix login timeout"          # --> docs/tasks/backlog/42-fix-login-timeout.md
./5day.sh newbug "Button unresponsive"          # --> docs/bugs/8-button-unresponsive.md
./5day.sh newfeature "User authentication"      # --> docs/features/user-authentication.md
./5day.sh newidea "Push notifications"          # --> docs/ideas/push-notifications.md
```

Each task and bug gets an auto-incrementing ID from `docs/5day/DOC_STATE.md`. Files are named `{ID}-{description}.md` and created from templates.

### Check status

```bash
./5day.sh status            # Task counts by folder, open bugs, feature status
./5day.sh checkfeatures     # Verify feature/task alignment
./5day.sh ai-context        # Quick project state summary for AI agents
```

### Move tasks through the pipeline

```bash
git mv docs/tasks/backlog/42-fix-login-timeout.md docs/tasks/next/
git mv docs/tasks/next/42-fix-login-timeout.md docs/tasks/working/
git mv docs/tasks/working/42-fix-login-timeout.md docs/tasks/blocked/   # Needs decision
git mv docs/tasks/blocked/42-fix-login-timeout.md docs/tasks/next/      # Unblocked
git mv docs/tasks/working/42-fix-login-timeout.md docs/tasks/review/
git mv docs/tasks/review/42-fix-login-timeout.md docs/tasks/live/
```

### Run a sprint with AI (optional)

5DayDocs ships a three-step pipeline for AI-assisted sprints. Build a sprint from your backlog, test that the queued tasks are actually ready, then run them as a batch. You review and commit between each step — the AI never commits for you.

```bash
# Step 1 — BUILD: pick ~5 tasks from backlog/, write a plan to docs/tmp/sprint-plan.md
./5day.sh sprint 5
./5day.sh sprint 5 "security"        # focus the sprint on a keyword
./5day.sh sprint 19 "parent:425"     # pull every child of a split task

# Step 2 — TEST: review each queued task against the current codebase.
# Marks tasks READY (stay in next/), BLOCKED (move to blocked/), or DONE
# (already shipped — move straight to review/). Adds a ## Questions section
# to anything that needs a human decision before execution.
./5day.sh define
./5day.sh define 3                   # only review the first 3 in next/

# Step 3 — RUN: execute the queued tasks in a fresh AI context per task.
# Each task is moved to working/, worked, then promoted to review/ on success
# (or blocked/ if it exceeds the turn budget). No commits — you review the diff.
./5day.sh tasks                      # run every task in next/ (sequential)
./5day.sh tasks 3                    # cap to the next 3 tasks
```

### Run batches of tasks (`./5day.sh tasks`)

The task runner is designed to chew through a whole sprint in one invocation. Common flags:

| Flag | What it does |
|---|---|
| `--parallel` | Run tasks concurrently (2 jobs by default) |
| `--fast` | Shorthand for `--parallel` with 4 concurrent jobs |
| `--jobs N` | Set the concurrency level explicitly |
| `--max` | Drop the per-task turn limit and budget cap (no guardrails) |
| `--drift` | Pre-task drift check — skip tasks already done, fix or block stale ones |
| `--audit` | Post-task code audit on each completed task |
| `--assist` | Interactive picker: standard / fast / full-quality / full-quality+fast |
| `--claude` / `--openai` / `--gemini` / `--mistral` | Override the AI CLI profile for this run |

Examples:

```bash
./5day.sh tasks --fast               # 4-way parallel, fastest path through a sprint
./5day.sh tasks --max --audit        # no limits + code audit on each task
./5day.sh tasks --max --audit --fast # the works: parallel, no limits, audited
./5day.sh tasks --assist             # let the runner ask which mode you want
```

When a task exceeds the turn budget it lands in `blocked/` with a hint to split it: `./5day.sh split <path>` breaks a too-large task into atomic subtasks you can re-queue.

### Task file format

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

### For AI agents working in a 5DayDocs project

1. Read `DOCUMENTATION.md` first. It is the complete reference.
2. Read `docs/5day/DOC_STATE.md` before creating any task or bug (to get the current ID).
3. Use `./5day.sh` commands to create work items. Do not create task files manually.
4. Do not edit files under `docs/5day/`. Those are framework files managed by `setup.sh`.
5. Tasks in `blocked/` need a human decision before work can continue. Do not attempt to unblock them.
6. Tasks in `review/` and `live/` are completed work. Do not modify them.
7. Folder = status. Move files between folders to change status.

## Contributing

This repo uses 5DayDocs to manage itself (dogfooding) and has a dual-tree layout: edit live in `docs/`, mirror to `src/` for distribution. See [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow, the file map, and how to verify an install.

---

*Simple, folder-based project management with markdown files and optional AI automation.*
