# 5DayDocs

Project management that lives in your repo as folders and markdown files. No databases, no apps, no syncing — just `git` and a text editor. Humans and AI agents work from the same files, so nothing falls out of sync when you switch tools, add teammates, or hand work to an agent. A task's status is which folder it's in:

```
docs/tasks/backlog/   Planned, not started
docs/tasks/next/      Queued for current sprint
docs/tasks/doing/     In progress
docs/tasks/blocked/   Waiting on a decision
docs/tasks/review/    Done, awaiting approval
docs/tasks/done/      Shipped
```

## Getting Started

### 1. Install

```bash
cd 5daydocs
./setup.sh
# enter your project path when prompted
```

This creates the folder structure, CLI, templates, and docs in your project. You now have `./5day.sh` and a `docs/` folder ready to go.

### 2. Profile your project

```bash
./5day.sh profile
```

An AI-guided interview about your stack, conventions, and goals. The answers are saved to `docs/5day/project.md` so every command that follows already knows what you're building and how.

### 3. Define your features

```bash
./5day.sh newfeature "User authentication"
./5day.sh newfeature "Payment processing"
```

Each command creates a feature spec in `docs/features/` with guided sections to fill in. Features describe *what the system does* — they're the big picture that tasks break down into.

### 4. Create tasks

```bash
./5day.sh newtask "Add login endpoint"
./5day.sh newtask "Set up Stripe integration"
./5day.sh newtask "Write auth middleware"
```

Tasks land in `docs/tasks/backlog/` with an auto-assigned ID. Each file is built from a battle-tested template, and AI guides you through defining success criteria, dependencies, and scope. Also: `./5day.sh newbug "description"` and `./5day.sh newidea "description"`.

### 5. Work the board

Move tasks through folders as you work. The folder a task is in *is* its status.

```bash
# Queue a task for your current sprint
git mv docs/tasks/backlog/1-add-login-endpoint.md docs/tasks/next/

# Start working on it
git mv docs/tasks/next/1-add-login-endpoint.md docs/tasks/doing/

# Finished — send to review
git mv docs/tasks/doing/1-add-login-endpoint.md docs/tasks/review/

# Approved — done
git mv docs/tasks/review/1-add-login-endpoint.md docs/tasks/done/
```

Check where things stand at any time:

```bash
./5day.sh status
```

For the full workflow reference — task format, feature specs, bug reports, and conventions — see [`DOCUMENTATION.md`](DOCUMENTATION.md).

---

## AI-Assisted Workflow

Once you have tasks in your backlog, AI can help plan, validate, and execute them.

```bash
# Plan a sprint — pick tasks from backlog into next/
./5day.sh sprint 5

# Validate — catch done, underspecified, or blocked tasks before execution
./5day.sh define

# Execute — one fresh AI context per task
./5day.sh tasks
```

### Task runner

`./5day.sh tasks` runs everything in `next/`. Start with `--assist` to choose a mode interactively, or pick your own:

```bash
./5day.sh tasks --assist               # interactive mode picker
./5day.sh tasks --fast                 # 4 concurrent jobs
./5day.sh tasks --parallel --jobs N    # set concurrency explicitly
./5day.sh tasks --max                  # remove per-task turn/budget limits
./5day.sh tasks --audit                # code audit after each task
./5day.sh tasks --drift                # skip done tasks, fix stale ones
./5day.sh tasks --claude               # also --openai, --gemini, --mistral
```

Flags combine: `./5day.sh tasks --max --audit --fast`

### Useful commands

```bash
./5day.sh find <id> --work             # analyze, move, and work a single task
./5day.sh triage [limit]               # walk through the task pipeline interactively
./5day.sh plan <task-id>               # interactive Q&A to define a task
./5day.sh split <path>                 # break a large task into subtasks
./5day.sh audit [folder] [limit]       # audit tasks for quality
./5day.sh review-code <file> [passes]  # code audit on changed files
./5day.sh review-sprint                # dual-persona sprint review
./5day.sh validate [--fix]             # validate task files against template
./5day.sh sync [--all]                 # push task changes to GitHub
```

## For AI Agents

Start with [`DOCUMENTATION.md`](DOCUMENTATION.md) — it's the complete reference. Use `./5day.sh` commands to create work items, never create files manually, and don't edit anything under `docs/5day/`. Folder = status.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
