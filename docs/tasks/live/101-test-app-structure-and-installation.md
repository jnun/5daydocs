# Task 101: Test src/ Structure and Installation

**Feature**: none
**Created**: 2025-10-21
**Updated**: 2026-01-26
**Depends on**: none (migrations are stable as of v2.1.0)

## Description

Thoroughly test the `src/` structure and `setup.sh` installation script to ensure:
1. Fresh installations work correctly
2. Updates work correctly (including version migrations)
3. Dogfooding works (installing to 5daydocs itself)
4. All files are properly distributed
5. CLI commands function after installation

---

## Part 1: File Structure Verification

Before running tests, verify the source structure is correct:

### Expected src/ Structure
```
src/
├── DOCUMENTATION.md
├── README.md
├── docs/
│   └── 5day/
│       ├── ai/
│       │   ├── .gitkeep
│       │   └── feynman-method.md
│       └── scripts/
│           ├── 5day.sh
│           ├── ai-context.sh
│           ├── check-alignment.sh
│           ├── create-feature.sh
│           ├── create-idea.sh
│           ├── create-task.sh
│           ├── INDEX.md
│           └── validate-tasks.sh
└── templates/
    ├── project/
    │   ├── STATE.md.template
    │   ├── TEMPLATE-bug.md
    │   ├── TEMPLATE-feature.md
    │   ├── TEMPLATE-idea.md
    │   └── TEMPLATE-task.md
    ├── github/
    │   ├── ISSUE_TEMPLATE/
    │   │   ├── bug_report.md
    │   │   ├── feature_request.md
    │   │   └── task.md
    │   └── pull_request_template.md
    └── workflows/
        ├── github/
        │   └── sync-tasks-to-issues.yml
        └── bitbucket/
            ├── pipelines.yml
            └── pipelines-jira.yml
```

### Expected Root templates/ Structure
```
templates/
├── project/
│   ├── README.md
│   └── STATE.md.template
├── github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── task.md
│   └── pull_request_template.md
└── workflows/
    ├── github/
    │   └── sync-tasks-to-issues.yml
    └── bitbucket/
        ├── pipelines.yml
        └── pipelines-jira.yml
```

**Note**: setup.sh reads GitHub/workflow templates from root `templates/` and project templates from `src/templates/project/`. The root `templates/` is the canonical source for GitHub issue templates and workflows.

---

## Part 2: Test Scenarios

### Scenario 1: Fresh Install to New Project (GitHub Issues - Default)

```bash
# Setup
mkdir /tmp/test-fresh-install
cd /tmp/test-fresh-install

# Run
/path/to/5daydocs/setup.sh
# Enter: /tmp/test-fresh-install
# Platform: 1 (GitHub Issues - default)
# Gitignore: y

# Verify Directory Structure
[ -d "docs/tasks/backlog" ]
[ -d "docs/tasks/next" ]
[ -d "docs/tasks/working" ]
[ -d "docs/tasks/review" ]
[ -d "docs/tasks/live" ]
[ -d "docs/bugs/archived" ]
[ -d "docs/ideas" ]
[ -d "docs/features" ]
[ -d "docs/guides" ]
[ -d "docs/tests" ]
[ -d "docs/designs" ]
[ -d "docs/examples" ]
[ -d "docs/data" ]
[ -d "docs/5day/scripts" ]
[ -d "docs/5day/ai" ]
[ -d ".github/workflows" ]
[ -d ".github/ISSUE_TEMPLATE" ]

# Verify Files Exist
[ -f "DOCUMENTATION.md" ]
[ -f "README.md" ]
[ -f "5day.sh" ]
[ -f "docs/STATE.md" ]
[ -f "docs/.platform-config" ]
[ -f "docs/tasks/TEMPLATE-task.md" ]
[ -f "docs/bugs/TEMPLATE-bug.md" ]
[ -f "docs/features/TEMPLATE-feature.md" ]
[ -f "docs/ideas/TEMPLATE-idea.md" ]
[ -f "docs/5day/ai/feynman-method.md" ]
[ -f "docs/5day/scripts/create-task.sh" ]
[ -f "docs/5day/scripts/create-feature.sh" ]
[ -f "docs/5day/scripts/create-idea.sh" ]
[ -f "docs/5day/scripts/ai-context.sh" ]
[ -f "docs/5day/scripts/check-alignment.sh" ]
[ -f ".github/workflows/sync-tasks-to-issues.yml" ]
[ -f ".github/ISSUE_TEMPLATE/bug_report.md" ]
[ -f ".github/ISSUE_TEMPLATE/feature_request.md" ]
[ -f ".github/ISSUE_TEMPLATE/task.md" ]
[ -f ".github/pull_request_template.md" ]
[ -f ".gitignore" ]

# Verify Scripts Executable
[ -x "5day.sh" ]
[ -x "docs/5day/scripts/create-task.sh" ]
[ -x "docs/5day/scripts/create-feature.sh" ]
[ -x "docs/5day/scripts/create-idea.sh" ]

# Verify STATE.md Contents
grep -q "5DAY_VERSION" docs/STATE.md
grep -q "5DAY_TASK_ID" docs/STATE.md
grep -q "5DAY_BUG_ID" docs/STATE.md

# Verify Platform Config
grep -q 'PLATFORM="github-issues"' docs/.platform-config

# Verify No src/ Copied
[ ! -d "src" ]
```

### Scenario 2: Fresh Install - Preserve Existing README

```bash
# Setup
mkdir /tmp/test-existing-readme
cd /tmp/test-existing-readme
echo "# My Existing Project" > README.md
echo "This should not change." >> README.md

# Run
/path/to/5daydocs/setup.sh
# Enter: /tmp/test-existing-readme

# Verify
grep -q "My Existing Project" README.md
grep -q "This should not change" README.md
[ -f "DOCUMENTATION.md" ]
```

### Scenario 3: Update Existing Installation

```bash
# Setup: Use test-fresh-install from Scenario 1
cd /tmp/test-fresh-install

# Create user content that should be preserved
./5day.sh newtask "User created task"
echo "Custom content" >> docs/guides/my-guide.md

# Record current state
ORIGINAL_TASK_ID=$(grep "5DAY_TASK_ID" docs/STATE.md)

# Run update
/path/to/5daydocs/setup.sh
# Enter: /tmp/test-fresh-install
# Confirm: y

# Verify Preservation
[ -f "docs/tasks/backlog/1-user-created-task.md" ]  # User task preserved
grep -q "Custom content" docs/guides/my-guide.md     # User content preserved
grep -q "$ORIGINAL_TASK_ID" docs/STATE.md || \
  [ $(grep "5DAY_TASK_ID" docs/STATE.md | grep -o '[0-9]*') -ge 1 ]  # ID preserved or incremented

# Verify Updates Applied
# (Scripts should be latest version)
```

### Scenario 4: Dogfooding (Install to 5daydocs itself)

```bash
# Run from 5daydocs repo
cd /path/to/5daydocs
./setup.sh
# Enter: .
# Confirm: y

# Verify
[ -f "DOCUMENTATION.md" ]
[ -f "5day.sh" ]
[ -d "docs/5day/scripts" ]

# Verify src/ NOT overwritten
[ -d "src" ]
[ -f "src/DOCUMENTATION.md" ]

# Verify existing tasks preserved
[ -d "docs/tasks/backlog" ]
[ -d "docs/tasks/next" ]
ls docs/tasks/*/  # Should show existing task files

# Verify no infinite loops (setup completes)
echo "Dogfood test passed"
```

### Scenario 5: Install as Git Submodule

```bash
# Setup
mkdir /tmp/test-submodule-project
cd /tmp/test-submodule-project
git init

# Add 5daydocs as submodule
git submodule add /path/to/5daydocs 5daydocs

# Run
./5daydocs/setup.sh
# Enter: /tmp/test-submodule-project

# Verify
[ -f "DOCUMENTATION.md" ]
[ -f "5day.sh" ]
[ -d "docs" ]
[ -d "5daydocs" ]  # Submodule still exists
[ -f "5daydocs/setup.sh" ]  # Submodule intact
```

### Scenario 6: Platform Selection - Bitbucket/Jira

```bash
# Setup
mkdir /tmp/test-bitbucket
cd /tmp/test-bitbucket

# Run
/path/to/5daydocs/setup.sh
# Enter: /tmp/test-bitbucket
# Platform: 3 (Bitbucket with Jira)

# Verify
[ ! -d ".github" ]  # No GitHub directories
grep -q 'PLATFORM="bitbucket-jira"' docs/.platform-config
```

---

## Part 3: CLI Functional Tests

After installation, verify CLI commands work:

```bash
cd /tmp/test-fresh-install

# Test help
./5day.sh help
# Should display command list without errors

# Test status
./5day.sh status
# Should show task counts without errors

# Test newtask
./5day.sh newtask "Test task from CLI"
[ -f "docs/tasks/backlog/2-test-task-from-cli.md" ]
# ID should increment

# Test newfeature
./5day.sh newfeature "Test Feature"
[ -f "docs/features/test-feature.md" ]

# Test newidea
./5day.sh newidea "Test Idea"
[ -f "docs/ideas/test-idea.md" ]

# Verify STATE.md updated
grep "5DAY_TASK_ID.*2" docs/STATE.md

# Test status shows new items
./5day.sh status | grep -q "Backlog"
```

---

## Part 4: Version Migration Tests

Migrations are stable as of v2.1.0. Test all migration paths.

### Migration Test 1: Fresh Install (No Migration Needed)
```bash
# Fresh install should not run any migrations
# Verify no "Migrating" messages in output
```

### Migration Test 2: Update from Pre-0.1.0
```bash
# Setup: Create legacy structure (work/ at root level)
mkdir /tmp/test-legacy
cd /tmp/test-legacy
mkdir -p work/tasks
echo "# Old task" > work/tasks/1-old-task.md
echo "**5DAY_TASK_ID**: 1" > work/STATE.md

# Run
/path/to/5daydocs/setup.sh
# Enter: /tmp/test-legacy
# Confirm: y

# Verify migration path: pre-0.1.0 -> 0.1.0 -> 1.0.0 -> 2.0.0 -> 2.1.0
[ -f "docs/tasks/backlog/1-old-task.md" ]  # Moved through all migrations
[ ! -d "work" ]                             # Old root work/ removed
[ -d "docs/5day/scripts" ]                  # Framework namespace created
[ -d "docs/5day/ai" ]                       # AI folder created
```

### Migration Test 3: Update from 1.0.0 to 2.1.0
```bash
# Setup: Create 1.0.0 structure (with docs/work/ hierarchy)
mkdir /tmp/test-v1
cd /tmp/test-v1
mkdir -p docs/work/tasks docs/work/bugs docs/work/scripts
echo "**5DAY_VERSION**: 1.0.0" > docs/STATE.md
echo "# Old task" > docs/work/tasks/1-old-task.md
echo "PLATFORM=\"github-issues\"" > docs/work/.platform-config

# Run
/path/to/5daydocs/setup.sh
# Enter: /tmp/test-v1
# Confirm: y

# Verify 2.0.0 migration (flatten docs/work/)
[ -f "docs/tasks/backlog/1-old-task.md" ]  # Task moved to new location
[ ! -d "docs/work" ]                        # Old structure removed
[ -f "docs/.platform-config" ]              # Platform config moved

# Verify 2.1.0 migration (framework namespace)
[ -d "docs/5day/scripts" ]
[ -d "docs/5day/ai" ]
```

### Migration Test 4: Update from 2.0.0 to 2.1.0
```bash
# Setup: Create 2.0.0 structure (flat, but scripts in docs/scripts/)
mkdir /tmp/test-v2
cd /tmp/test-v2
mkdir -p docs/tasks/backlog docs/bugs docs/scripts
echo "**5DAY_VERSION**: 2.0.0" > docs/STATE.md
echo "#!/bin/bash" > docs/scripts/create-task.sh
chmod +x docs/scripts/create-task.sh

# Run
/path/to/5daydocs/setup.sh
# Enter: /tmp/test-v2
# Confirm: y

# Verify 2.1.0 migration (framework namespace)
[ -f "docs/5day/scripts/create-task.sh" ]  # Script moved to 5day namespace
[ -d "docs/5day/ai" ]                       # AI folder created
grep -q "2.1.0" docs/STATE.md || grep -q "$CURRENT_VERSION" docs/STATE.md
```

### Migration Test 5: Idempotency
```bash
# Run setup.sh twice on same project
# Second run should not duplicate or break anything
cd /tmp/test-fresh-install
/path/to/5daydocs/setup.sh  # First run already done
/path/to/5daydocs/setup.sh  # Second run
# Enter: /tmp/test-fresh-install
# Confirm: y

# Verify no duplicates, no errors
./5day.sh status  # Should work normally
```

---

## Part 5: Edge Cases

### Edge Case 1: Non-Existent Target Directory
```bash
/path/to/5daydocs/setup.sh
# Enter: /tmp/does-not-exist

# Expected: Clear error message, script exits gracefully
```

### Edge Case 2: Target is a File
```bash
touch /tmp/not-a-directory
/path/to/5daydocs/setup.sh
# Enter: /tmp/not-a-directory

# Expected: Error message
```

### Edge Case 3: Partial Installation Recovery
```bash
# Setup: Create partial structure
mkdir /tmp/test-partial
cd /tmp/test-partial
mkdir -p docs/tasks/backlog
echo "**5DAY_TASK_ID**: 5" > docs/STATE.md
# Missing: other folders, scripts, etc.

# Run
/path/to/5daydocs/setup.sh

# Verify: Missing pieces added, existing STATE.md ID preserved
```

### Edge Case 4: Read-Only Files
```bash
# Setup
mkdir /tmp/test-readonly
cd /tmp/test-readonly
touch DOCUMENTATION.md
chmod 444 DOCUMENTATION.md

# Run
/path/to/5daydocs/setup.sh

# Expected: Handles gracefully (warning or request to fix permissions)
```

---

## Part 6: Validation Checklist

Run after EVERY test scenario:

### File Checks
- [ ] No error messages during installation
- [ ] All expected directories exist
- [ ] All expected files exist
- [ ] All .sh scripts are executable (chmod +x)
- [ ] No unexpected files copied (especially no src/)
- [ ] .gitkeep files in empty directories

### Content Checks
- [ ] STATE.md has valid version number
- [ ] STATE.md has valid task/bug IDs
- [ ] .platform-config has correct platform
- [ ] DOCUMENTATION.md matches src/DOCUMENTATION.md
- [ ] Templates have correct content

### Functional Checks
- [ ] `./5day.sh help` works
- [ ] `./5day.sh status` works
- [ ] `./5day.sh newtask "test"` creates task
- [ ] `./5day.sh newfeature "test"` creates feature
- [ ] `./5day.sh newidea "test"` creates idea
- [ ] Task IDs increment correctly

### Git Checks
- [ ] No unintended tracked files modified
- [ ] New files can be staged and committed
- [ ] .gitignore entries don't break project

---

## Success Criteria

- [ ] All 6 test scenarios pass (Part 2)
- [ ] All CLI functional tests pass (Part 3)
- [ ] All 5 migration tests pass (Part 4)
- [ ] All 4 edge cases handled gracefully (Part 5)
- [ ] Validation checklist passes for each scenario (Part 6)
- [ ] No regressions from previous versions

---

## Test Execution Script

Create `test-installation.sh` to automate:

```bash
#!/bin/bash
# Automated test runner for 5DayDocs installation
# Run from 5daydocs repo root

set -e
FIVEDAY_DIR="$(pwd)"
TEST_BASE="/tmp/5daydocs-tests-$(date +%s)"

mkdir -p "$TEST_BASE"
cd "$TEST_BASE"

echo "=== Test 1: Fresh Install ==="
mkdir test1 && cd test1
echo "/tmp/5daydocs-tests/test1" | "$FIVEDAY_DIR/setup.sh"
# Add assertions...

echo "=== All tests passed ==="
```

---

## Rollback Plan

If tests fail:
1. Document the specific failure (scenario, step, error message)
2. Do NOT proceed to production use
3. Fix issues in setup.sh or src/ structure
4. Re-run failing test
5. Re-run full test suite to check for regressions

## Notes

Updated 2026-01-26. All parts can be tested - migrations are stable as of v2.1.0. Structure verified against current codebase.
