# File Lifecycle

How files flow through 5DayDocs development and distribution.

## Overview

```
src/                    → Source of truth
    ↓ setup.sh
docs/                   → Dogfood (we use 5DayDocs to build 5DayDocs)
    ↓ setup.sh
user project/docs/      → End user installation
```

## 1. Development (src/)

All product files live in `src/`. This is the source of truth.

```
src/
├── DOCUMENTATION.md           → User-facing docs
├── README.md                  → Project intro (copied if none exists)
├── docs/5day/
│   ├── scripts/*.sh           → CLI tools
│   └── ai/*.md                → AI agent instructions
└── templates/
    └── project/               → Task, feature, bug, idea templates
```

**Rule:** Edit files in `src/`, never directly in `docs/`.

## 2. Dogfooding (docs/)

We use 5DayDocs to manage 5DayDocs itself.

```
docs/
├── tasks/                     → Our development tasks
├── features/                  → Our feature specs
├── ideas/                     → Our rough ideas
└── 5day/                      → Framework files (synced from src/)
```

To sync changes from `src/` to `docs/`:

```bash
./setup.sh .
```

This copies framework files from `src/` to `docs/` while preserving:
- Task files
- STATE.md values (IDs)
- User content

## 3. Version Release

When releasing a new version:

1. Update `VERSION` file
2. Update version in `setup.sh` header
3. Commit with version tag
4. Push

```bash
echo "2.1.0" > VERSION
git add -A
git commit -m "Release 2.1.0"
git tag v2.1.0
git push && git push --tags
```

## 4. User Installation

Users install 5DayDocs in their project:

```bash
# Clone
git clone https://github.com/jnun/5daydocs.git
cd 5daydocs
./setup.sh /path/to/their/project

# Or as submodule
git submodule add https://github.com/jnun/5daydocs.git 5daydocs
cd 5daydocs
./setup.sh /path/to/their/project
```

`setup.sh` copies to their project:
- `DOCUMENTATION.md` → project root
- `5day.sh` → project root
- `docs/5day/` → framework scripts and AI instructions
- `docs/tasks/`, `docs/features/`, etc. → folder structure
- Templates → each folder

## 5. User Updates

When users want the latest 5DayDocs:

```bash
cd 5daydocs
git pull
./setup.sh /path/to/their/project
```

`setup.sh` handles migrations:
- Preserves STATE.md values
- Preserves user content (tasks, features, etc.)
- Updates framework files only

## File Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     5DAYDOCS REPO                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   src/                        docs/                         │
│   ├── DOCUMENTATION.md        ├── tasks/        ← our work │
│   ├── docs/5day/scripts/      ├── features/                 │
│   ├── docs/5day/ai/           ├── ideas/                    │
│   └── templates/              └── 5day/         ← synced    │
│          │                           ↑                      │
│          └───── setup.sh . ──────────┘                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                              │
                        setup.sh /path
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     USER PROJECT                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   DOCUMENTATION.md            docs/                         │
│   5day.sh                     ├── tasks/        ← their work│
│                               ├── features/                 │
│                               ├── ideas/                    │
│                               ├── 5day/         ← framework │
│                               └── STATE.md                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Key Principles

1. **src/ is source of truth** — All edits happen here
2. **setup.sh is the sync tool** — Never manually copy files
3. **User content is preserved** — Tasks, features, STATE.md survive updates
4. **Framework files are replaced** — scripts, templates, docs get overwritten
