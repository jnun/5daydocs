#!/usr/bin/env bash
# Test: find.sh
# Tests the non-AI paths: argument validation, task lookup, prompt-mode output.
# Does NOT test --think or --work (those require an AI CLI).

set -euo pipefail

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIND_SCRIPT="$PROJECT_ROOT/docs/5day/scripts/find.sh"

setup() {
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    mkdir -p "$TMPDIR/docs/5day/scripts"
    mkdir -p "$TMPDIR/docs/5day/cli"
    mkdir -p "$TMPDIR/docs/tasks/backlog"
    mkdir -p "$TMPDIR/docs/tasks/next"
    mkdir -p "$TMPDIR/docs/tasks/doing"
    mkdir -p "$TMPDIR/docs/tasks/blocked"
    mkdir -p "$TMPDIR/docs/tasks/review"
    mkdir -p "$TMPDIR/docs/tasks/done"

    # Copy find.sh and its dependencies
    cp "$FIND_SCRIPT" "$TMPDIR/docs/5day/scripts/find.sh"
    cp "$PROJECT_ROOT/docs/5day/lib.sh" "$TMPDIR/docs/5day/lib.sh"
    cp "$PROJECT_ROOT/docs/5day/config" "$TMPDIR/docs/5day/config"
    if [ -d "$PROJECT_ROOT/docs/5day/cli" ]; then
        cp "$PROJECT_ROOT/docs/5day/cli"/*.sh "$TMPDIR/docs/5day/cli/" 2>/dev/null || true
    fi

    git -C "$TMPDIR" init -q
}

assert_contains() {
    local desc="$1" haystack="$2" needle="$3"
    if echo "$haystack" | grep -qF -- "$needle"; then
        echo "  PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $desc (expected to contain '$needle')"
        FAIL=$((FAIL + 1))
    fi
}

assert_exit_code() {
    local desc="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        echo "  PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $desc (expected exit $expected, got $actual)"
        FAIL=$((FAIL + 1))
    fi
}

# --- Tests ---

echo "=== test-find.sh ==="

# Test 1: No args shows usage and exits 1
echo "Test 1: No args shows usage"
setup
rc=0
output=$(bash "$TMPDIR/docs/5day/scripts/find.sh" 2>&1) || rc=$?
assert_exit_code "Exit code is 1" "1" "$rc"
assert_contains "Shows error" "$output" "Task ID required"
assert_contains "Shows usage" "$output" "Usage:"

# Test 2: Unknown argument exits 1
echo "Test 2: Unknown argument exits 1"
setup
rc=0
output=$(bash "$TMPDIR/docs/5day/scripts/find.sh" --bogus 2>&1) || rc=$?
assert_exit_code "Exit code is 1" "1" "$rc"
assert_contains "Shows unknown arg error" "$output" "Unknown argument"

# Test 3: Nonexistent task ID exits 1
echo "Test 3: Nonexistent task ID exits 1"
setup
rc=0
output=$(bash "$TMPDIR/docs/5day/scripts/find.sh" 999 2>&1) || rc=$?
assert_exit_code "Exit code is 1" "1" "$rc"
assert_contains "Says not found" "$output" "not found"

# Test 4: Prompt mode for backlog task shows prompt
echo "Test 4: Prompt mode for backlog task"
setup
cat > "$TMPDIR/docs/tasks/backlog/42-test-task.md" << 'EOF'
# Task 42: Test task

**Feature**: none
**Created**: 2026-01-01

## Problem
Test problem description.

## Success criteria
- [ ] Thing works
EOF
git -C "$TMPDIR" add -A && git -C "$TMPDIR" commit -q -m "init"
output=$(bash "$TMPDIR/docs/5day/scripts/find.sh" 42 2>&1)
assert_contains "Shows found message" "$output" "Found task"
assert_contains "Shows stage" "$output" "backlog"
assert_contains "Shows PROMPT header" "$output" "PROMPT"
assert_contains "Prompt includes task path" "$output" "docs/tasks/backlog/42-test-task.md"
assert_contains "Shows think hint" "$output" "--think"
assert_contains "Shows work hint" "$output" "--work"

# Test 5: Task in done/ exits early
echo "Test 5: Task in done exits early"
setup
cat > "$TMPDIR/docs/tasks/done/7-finished.md" << 'EOF'
# Task 7: Finished task
EOF
git -C "$TMPDIR" add -A && git -C "$TMPDIR" commit -q -m "init"
rc=0
output=$(bash "$TMPDIR/docs/5day/scripts/find.sh" 7 2>&1) || rc=$?
assert_exit_code "Exit code is 0" "0" "$rc"
assert_contains "Says already done" "$output" "already done"

# Test 6: Prompt mode includes feature ref when present
echo "Test 6: Feature ref included in prompt"
setup
mkdir -p "$TMPDIR/docs/features"
cat > "$TMPDIR/docs/features/my-feature.md" << 'EOF'
# My Feature
EOF
cat > "$TMPDIR/docs/tasks/next/15-with-feature.md" << 'EOF'
# Task 15: Task with feature

**Feature**: docs/features/my-feature.md
**Created**: 2026-01-01

## Problem
Linked to a feature.

## Success criteria
- [ ] Done
EOF
git -C "$TMPDIR" add -A && git -C "$TMPDIR" commit -q -m "init"
output=$(bash "$TMPDIR/docs/5day/scripts/find.sh" 15 2>&1)
assert_contains "Prompt includes feature ref" "$output" "my-feature.md"

# Test 7: Prompt mode embeds task content
echo "Test 7: Prompt embeds task content"
setup
cat > "$TMPDIR/docs/tasks/doing/3-inline.md" << 'EOF'
# Task 3: Inline content test

**Feature**: none
**Created**: 2026-01-01

## Problem
Unique problem marker ABC123.

## Success criteria
- [ ] Criterion one
EOF
git -C "$TMPDIR" add -A && git -C "$TMPDIR" commit -q -m "init"
output=$(bash "$TMPDIR/docs/5day/scripts/find.sh" 3 2>&1)
assert_contains "Task content is embedded" "$output" "Unique problem marker ABC123"

# --- Summary ---
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
