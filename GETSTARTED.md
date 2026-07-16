# Getting Started with 5DayDocs

`./5day.sh help` any time to see them all.

## The loop

```
idea  →  feature  →  task  →  done  →  test
 ▲                                       │
 └───────────  new idea / feature  ◄─────┘
```

You have an idea. You sharpen it into features. You break features into tasks.

You move tasks to done. You test the result and feed what you learn back in.

DOCUMENTATION.md outlines the entire ruleset for docs.

## Step 1 — Capture the idea

Start here when you have a rough concept.

```bash
./5day.sh newidea "Let people share playlists"
```

This creates `docs/ideas/let-people-share-playlists.md` with a guided thinking
framework. Work through it to move from a rough spark to a clear bet: who has
the problem, what you'll build, and the smallest version worth testing.

**Do this:** Fill in the phases. End with a short list of features that serve
the idea.

## Step 2 — Define the features

Turn each feature from your idea into a defined capability.

```bash
./5day.sh newfeature "Playlist sharing"
```

This creates `docs/features/playlist-sharing.md`. Describe what the feature does
in plain language — what someone can do once it exists.

**Do this:** Write the feature so anyone can understand the goal without reading
code. Want help thinking it through? Run `./5day.sh newfeature` with no name for
a guided Q&A.

## Step 3 — Break it into tasks

Split each feature into specific, buildable work items.

```bash
./5day.sh newtask "Add a Share button to the playlist page"
```

This creates a numbered task in `docs/tasks/backlog/`. Each task describes one
concrete piece of work.

**Do this:** Write one task per piece of work. Keep each small enough to finish
and check.

## Step 4 — Move tasks to done

Tasks live in folders, and the folder is the status. Move a task by moving its
file.

| Folder | Meaning |
|--------|---------|
| `backlog/` | Planned |
| `next/` | Queued to work now |
| `doing/` | In progress |
| `review/` | Done, awaiting a check |
| `done/` | Complete |

```bash
git mv docs/tasks/backlog/12-add-share-button.md docs/tasks/next/
git mv docs/tasks/next/12-add-share-button.md docs/tasks/doing/
git mv docs/tasks/doing/12-add-share-button.md docs/tasks/review/
git mv docs/tasks/review/12-add-share-button.md docs/tasks/done/
```

**Do this:** Pull a task into `next/`, build it, then move it toward `done/`.
Check progress any time with `./5day.sh status`.

## Step 5 — Test the thing

Once the feature is built and deployed, validate it. You decide how to test —
real users, a demo, a metric you watch.

```bash
./5day.sh newtest "Playlist sharing gets used"
```

This creates `docs/tests/playlist-sharing-gets-used.md`. Write the claim you're
testing, run your test your way, and record what happened.

**Do this:** Turn each learning into the next piece of work — `./5day.sh
newfeature` for a new capability, `./5day.sh newtask` for a specific change. That
closes the loop and starts the next one.

---

## What's in the package

Five ways to create work. Each command writes a file with inline guidance — fill
in the sections, then commit.

| Type | Command | What to do |
|------|---------|-----------|
| **Idea** | `newidea "..."` | Refine a rough concept into a clear bet and a list of features |
| **Feature** | `newfeature "..."` | Describe a capability in plain language |
| **Task** | `newtask "..."` | Write one specific, buildable work item |
| **Bug** | `newbug "..."` | Report something that needs fixing |
| **Test** | `newtest "..."` | Validate a deployed thing, then route learnings into new work |

**Folders you own** — create and edit freely:

- `docs/ideas/` — rough concepts being refined
- `docs/features/` — defined capabilities
- `docs/tasks/` — work items, organized by status folder
- `docs/bugs/` — bug reports
- `docs/tests/` — your test loops
- `docs/guides/` — your documentation

**Handy commands:**

- `./5day.sh status` — see counts and what's in progress
- `./5day.sh help` — list every command
- `./5day.sh help <command>` — details for one command

For the full reference, read `DOCUMENTATION.md`.

---

*Plain folders and markdown. Start with an idea, end with a test.*
