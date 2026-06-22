# Contributing to 5DayDocs

## Quick start

```bash
git clone <repo-url> && cd 5daydocs
```

No build step. The project is shell scripts and markdown.

## Development workflow

1. **Edit in `docs/`** — this is the live environment. Changes take effect immediately.
2. **Test your changes** — run `./5day.sh` commands to verify behavior.
3. **Sync to `src/`** — copy modified files so they become part of the distribution.
4. **Verify install** — run `./setup.sh` against a temp directory (see below).
5. **Commit.**

### The two trees

- **`docs/`** is where you develop. Scripts run from here. Edit here first.
- **`src/`** is the distribution package — what `setup.sh` installs into user projects. Never edit here first; always sync from `docs/` after testing.

### Verify a fresh install

```bash
mkdir /tmp/test-5day && ./setup.sh
# enter /tmp/test-5day when prompted, verify output, then:
rm -rf /tmp/test-5day
```

If this breaks, it's a release blocker.

## What goes where

| I want to change... | Edit here | Then sync to |
|---|---|---|
| A script | `docs/5day/scripts/` | `src/docs/5day/scripts/` |
| AI guidance | `docs/5day/ai/` | `src/docs/5day/ai/` |
| The user manual | `DOCUMENTATION.md` (root) | `src/DOCUMENTATION.md` |
| The installer | `setup.sh` (root) | — (only one copy) |
| A template | `docs/{tasks,bugs,features,ideas}/.TEMPLATE-*` | `src/docs/{...}/.TEMPLATE-*` |

## Tracking work

This repo uses 5DayDocs to manage itself. Use `./5day.sh` commands to create tasks, bugs, and ideas — never create those files manually.

## Questions

Read `DOCUMENTATION.md` for how the system works end-to-end.
