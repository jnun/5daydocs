# 5DayDocs Development

This repo builds 5DayDocs, a folder-based project management tool. It also dogfoods itself.

## Architecture

- `src/` — Source of truth for all distributed files. Edit here.
- `docs/` — Dogfood: we use 5DayDocs to manage 5DayDocs. Synced from `src/` via `./setup.sh .`
- `templates/` — GitHub/Bitbucket templates distributed to users
- `setup.sh` — Installer/updater that copies `src/` to user projects

Never edit `docs/5day/` directly — it's synced from `src/docs/5day/`.

## Key files

- `src/VERSION` — Current version
- `docs/STATE.md` — Next task/bug IDs (check before creating tasks)
- `src/docs/5day/AGENT.md` — Agent reference shipped to users
- `src/docs/5day/scripts/5day.sh` — Main CLI (also copied to project root)
- `src/DOCUMENTATION.md` — User-facing documentation

## Commands

```bash
./setup.sh .              # Sync src/ to docs/ (dogfood)
./5day.sh newtask "..."   # Create task
./5day.sh status          # Pipeline overview
./5day.sh help            # All commands
```

## Task conventions

Read docs/5day/AGENT.md for the full reference (same file shipped to users).
