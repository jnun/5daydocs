# Task 98: Create src/ Directory Structure

**Feature**: none
**Created**: 2025-10-21
**Depends on**: Task 97 (audit must be complete)

## Description

Create the new `src/` directory structure that will hold all distributable 5daydocs template files. This becomes the single source of truth for what users get when they install 5daydocs.

## Structure to Create

```
src/
├── docs/
│   ├── tasks/
│   │   ├── backlog/
│   │   ├── next/
│   │   ├── working/
│   │   ├── review/
│   │   ├── live/
│   │   ├── INDEX.md
│   │   └── TEMPLATE-task.md
│   ├── bugs/
│   │   ├── archived/
│   │   ├── INDEX.md
│   │   └── TEMPLATE-bug.md
│   ├── features/
│   │   ├── INDEX.md
│   │   └── TEMPLATE-feature.md
│   ├── scripts/
│   │   ├── create-task.sh
│   │   ├── create-feature.sh
│   │   ├── validate-tasks.sh
│   │   ├── check-alignment.sh
│   │   └── INDEX.md
│   ├── designs/
│   ├── examples/
│   ├── data/
│   ├── guides/
│   │   └── INDEX.md
│   ├── ideas/
│   ├── INDEX.md
│   └── STATE.md.template
├── github/
│   ├── workflows/
│   │   └── sync-tasks-to-issues.yml
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── task.md
│   └── pull_request_template.md
├── 5day.sh (command interface - copied to user's project root)
├── DOCUMENTATION.md
└── README.md (template for user projects)
```

**Installation Flow:**
1. User runs `install.sh` from repository root
2. `install.sh` copies all `src/` contents to target directory
3. User gets `docs/` structure, `5day.sh` in root, and optional `.github/` workflows
4. `install.sh` stays in the 5daydocs repository (not copied to target)
```

**Installation Flow:**
1. User runs `install.sh` from repository root
2. `install.sh` copies all `src/` contents to target directory
3. User gets `docs/` structure, `5day.sh` in root, and optional `.github/` workflows
4. `install.sh` and `update.sh` stay in the 5daydocs repository (not copied to target)

**Example Usage:**
```bash
$ git clone 5daydocs.git ./
$ cd 5daydocs/
$ sh ./install.sh
Where are you installing 5daydocs? Key in the path or location:
$ ~/path/to/my/repo
# installs src/ contents to ~/path/to/my/repo/
# Result: ~/path/to/my/repo/docs/ + ~/path/to/my/repo/5day.sh
```

## Tasks

- [ ] Create src/ directory with all subdirectories
- [ ] Add .gitkeep files to empty directories
- [ ] Document what each directory contains
- [ ] Verify structure matches 5daydocs design principles

## Success Criteria

- [ ] src/ directory exists with complete structure
- [ ] All necessary folders created
- [ ] Structure ready to receive template files
- [ ] No actual content copied yet (that's next task)
