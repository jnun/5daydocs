# Philosophy

**No databases, no apps—just folders and markdown files.**

- **Simple:** Everything is plain text and version controlled
- **Portable:** Works with any project, any language, any team size
- **Transparent:** All project management is visible and editable
- **Flexible:** Adapt the workflow to your needs
- **Minimal root footprint:** Only `DOCUMENTATION.md` and `5day.sh` in your project root
- **Docs folder holds everything:** /docs holds everything related to your project tasks
- **Submodule-friendly:** You can install 5DayDocs as a Git submodule

## Quick Start / Installation

To install 5DayDocs in your project:

```bash
# Option A: Clone standalone (recommended)
git clone https://github.com/jnun/5daydocs.git
cd 5daydocs
chmod +x setup.sh
./setup.sh

# Option B: Clone as a submodule (for enterprise)
git submodule add https://github.com/jnun/5daydocs.git 5daydocs
cd 5daydocs
chmod +x setup.sh
./setup.sh

# When prompted, enter the path to your project root
# (e.g., /Users/yourname/myproject)
```

After setup, your project will have:
- `DOCUMENTATION.md` in root (Your guide to using 5DayDocs)
- `docs/` folder with all 5DayDocs files
- `5day.sh` command script

**👉 See `DOCUMENTATION.md` in your project root for the complete workflow guide.**

## Development Workflow (Contributing to 5DayDocs)

This repo dogfoods itself. We use 5DayDocs to manage 5DayDocs.

So,

```
src/   → The product. What users receive.
docs/  → Our task tracking. Like Jira, but markdown.
```

The actual files that will land in your project folder come from src/

The bash scripts place things where they need to be, including this project

### How to Make Changes

1. **Edit in `src/`** — All product files live here
2. **Run `./setup.sh` targeting `.`** — Syncs your changes to `docs/` (dogfood mode)
3. **Test it** — Use the updated 5DayDocs on this project
4. **If it works, commit. If it breaks, don't.**

This lets you experiment safely before pushing changes.

### Project Structure

```
./setup.sh                 ← Installer/updater (NOT distributed)
./5day.sh                  ← CLI (synced from src/)
src/docs/5day/scripts/     ← Source of truth for distributed scripts
docs/                      ← Dogfood: we use 5DayDocs to manage 5DayDocs
```

### Tracking Work

Use `docs/` to track tasks, bugs, and features:

```bash
./5day.sh newtask "Add new feature"
./5day.sh status
```

---
*Simple, folder-based task management with clear feature documentation*

