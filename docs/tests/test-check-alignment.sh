#!/bin/bash
# Test: check-alignment.sh
# Tests feature-task alignment checking

set -e

PASS=0
FAIL=0
SCRIPT_UNDER_TEST="$(cd "$(dirname "$0")/../5day/scripts" && pwd)/check-alignment.sh"

setup() {
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    mkdir -p "$TMPDIR/docs/features"
    mkdir -p "$TMPDIR/docs/tasks/backlog"
    mkdir -p "$TMPDIR/docs/tasks/next"
    mkdir -p "$TMPDIR/docs/tasks/working"
    mkdir -p "$TMPDIR/docs/tasks/review"
    mkdir -p "$TMPDIR/docs/tasks/live"

    cp "$SCRIPT_UNDER_TEST" "$TMPDIR/check-alignment.sh"
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

echo "=== test-check-alignment.sh ==="

# Test 1: No features, no tasks — exits 0 (no issues)
echo "Test 1: Empty project exits 0"
setup
rc=0
output=$(cd "$TMPDIR" && bash check-alignment.sh 2>&1) || rc=$?
assert_exit_code "Exits 0" "0" "$rc"
assert_contains "Shows summary" "$output" "Summary"

# Test 2: Feature with matching task — no issues
echo "Test 2: Aligned feature and task exits 0"
setup
cat > "$TMPDIR/docs/features/auth.md" << 'EOF'
# Feature: Auth
## Feature Status: WORKING
Some content.
EOF
cat > "$TMPDIR/docs/tasks/working/1-add-login.md" << 'EOF'
# Task 1: Add login
**Feature**: /docs/features/auth.md
EOF
rc=0
output=$(cd "$TMPDIR" && bash check-alignment.sh 2>&1) || rc=$?
assert_exit_code "Aligned exits 0" "0" "$rc"

# Test 3: Orphaned task (no feature ref) — exits 1
echo "Test 3: Orphaned task causes exit 1"
setup
cat > "$TMPDIR/docs/tasks/backlog/2-orphan.md" << 'EOF'
# Task 2: Orphan
**Feature**: none
EOF
rc=0
output=$(cd "$TMPDIR" && bash check-alignment.sh 2>&1) || rc=$?
assert_exit_code "Orphaned task exits 1" "1" "$rc"
assert_contains "Reports orphan" "$output" "no feature reference"

# Test 4: Task referencing non-existent feature — exits 1
echo "Test 4: Invalid feature reference exits 1"
setup
cat > "$TMPDIR/docs/tasks/backlog/3-bad-ref.md" << 'EOF'
# Task 3: Bad ref
**Feature**: /docs/features/nonexistent.md
EOF
rc=0
output=$(cd "$TMPDIR" && bash check-alignment.sh 2>&1) || rc=$?
assert_exit_code "Bad ref exits 1" "1" "$rc"
assert_contains "Reports missing feature" "$output" "non-existent feature"

# Test 5: Feature with no status — reports issue
echo "Test 5: Feature missing status"
setup
cat > "$TMPDIR/docs/features/bare.md" << 'EOF'
# Feature: Bare
No status here.
EOF
rc=0
output=$(cd "$TMPDIR" && bash check-alignment.sh 2>&1) || rc=$?
assert_contains "Reports no status" "$output" "No status found"

# Test 6: Shows best practices section
echo "Test 6: Shows best practices"
setup
output=$(cd "$TMPDIR" && bash check-alignment.sh 2>&1) || true
assert_contains "Best practices" "$output" "Best Practices"

# --- Summary ---
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
