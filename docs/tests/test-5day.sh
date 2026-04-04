#!/bin/bash
# Test: 5day.sh
# Tests the CLI router: help, unknown commands, missing args, status output
# Does NOT test end-to-end dispatch (covered by individual create-script tests)

set -e

PASS=0
FAIL=0
SCRIPT_UNDER_TEST="$(cd "$(dirname "$0")/../5day/scripts" && pwd)/5day.sh"

setup() {
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    # 5day.sh checks if $SCRIPT_DIR/docs/5day/scripts exists to decide PROJECT_ROOT.
    # We place it at the project root level so it finds docs/5day/scripts relative to itself.
    mkdir -p "$TMPDIR/docs/5day/scripts"
    mkdir -p "$TMPDIR/docs/tasks/backlog"
    mkdir -p "$TMPDIR/docs/tasks/next"
    mkdir -p "$TMPDIR/docs/tasks/working"
    mkdir -p "$TMPDIR/docs/tasks/review"
    mkdir -p "$TMPDIR/docs/tasks/live"

    cp "$SCRIPT_UNDER_TEST" "$TMPDIR/docs/5day/scripts/5day.sh"

    # Copy all helper scripts so run_script() can find them
    local src_dir
    src_dir="$(cd "$(dirname "$0")/../5day/scripts" && pwd)"
    for script in "$src_dir"/*.sh; do
        cp "$script" "$TMPDIR/docs/5day/scripts/"
    done

    cat > "$TMPDIR/docs/STATE.md" << 'EOF'
# docs/STATE.md

**Last Updated**: 2026-01-01
**5DAY_VERSION**: 2.1.3
**5DAY_TASK_ID**: 10
**5DAY_BUG_ID**: 1
**SYNC_ALL_TASKS**: false
EOF

    git -C "$TMPDIR" init -q
}

assert_contains() {
    local desc="$1" haystack="$2" needle="$3"
    if echo "$haystack" | grep -qF "$needle"; then
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

echo "=== test-5day.sh ==="

# Test 1: Help output (no args)
echo "Test 1: No args shows help"
setup
output=$(bash "$TMPDIR/docs/5day/scripts/5day.sh" 2>&1) || true
assert_contains "Shows CLI title" "$output" "5day - Five Day Docs CLI"
assert_contains "Shows commands" "$output" "newtask"

# Test 2: help command
echo "Test 2: help command shows help"
setup
output=$(bash "$TMPDIR/docs/5day/scripts/5day.sh" help 2>&1)
assert_contains "Help has usage" "$output" "Usage:"

# Test 3: --help flag
echo "Test 3: --help flag shows help"
setup
output=$(bash "$TMPDIR/docs/5day/scripts/5day.sh" --help 2>&1)
assert_contains "--help shows usage" "$output" "Usage:"

# Test 4: Unknown command exits 1
echo "Test 4: Unknown command exits 1"
setup
rc=0
output=$(bash "$TMPDIR/docs/5day/scripts/5day.sh" foobar 2>&1) || rc=$?
assert_exit_code "Exit code is 1" "1" "$rc"
assert_contains "Error mentions unknown" "$output" "Unknown command: foobar"

# Test 5: newtask without description exits 1
echo "Test 5: newtask without args exits 1"
setup
rc=0
bash "$TMPDIR/docs/5day/scripts/5day.sh" newtask 2>/dev/null || rc=$?
assert_exit_code "newtask no-arg exits 1" "1" "$rc"

# Test 6: newfeature without name exits 1
echo "Test 6: newfeature without args exits 1"
setup
rc=0
bash "$TMPDIR/docs/5day/scripts/5day.sh" newfeature 2>/dev/null || rc=$?
assert_exit_code "newfeature no-arg exits 1" "1" "$rc"

# Test 7: newidea without name exits 1
echo "Test 7: newidea without args exits 1"
setup
rc=0
bash "$TMPDIR/docs/5day/scripts/5day.sh" newidea 2>/dev/null || rc=$?
assert_exit_code "newidea no-arg exits 1" "1" "$rc"

# Test 8: newbug without description exits 1
echo "Test 8: newbug without args exits 1"
setup
rc=0
bash "$TMPDIR/docs/5day/scripts/5day.sh" newbug 2>/dev/null || rc=$?
assert_exit_code "newbug no-arg exits 1" "1" "$rc"

# Test 9: split without path exits 1
echo "Test 9: split without args exits 1"
setup
rc=0
bash "$TMPDIR/docs/5day/scripts/5day.sh" split 2>/dev/null || rc=$?
assert_exit_code "split no-arg exits 1" "1" "$rc"

# Test 10: status command shows project status
echo "Test 10: status command shows counts"
setup
# Add a task file to backlog
cat > "$TMPDIR/docs/tasks/backlog/1-test-task.md" << 'EOF'
# Task 1: Test task
EOF
output=$(bash "$TMPDIR/docs/5day/scripts/5day.sh" status 2>&1)
assert_contains "Shows Project Status header" "$output" "Project Status"
assert_contains "Shows Backlog count" "$output" "Backlog:"

# Test 11: status with working task shows in-progress
echo "Test 11: status shows working tasks"
setup
cat > "$TMPDIR/docs/tasks/working/5-active-task.md" << 'EOF'
# Task 5: Active task
EOF
output=$(bash "$TMPDIR/docs/5day/scripts/5day.sh" status 2>&1)
assert_contains "Shows in progress section" "$output" "In progress:"
assert_contains "Shows task name" "$output" "5-active-task"

# --- Summary ---
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
