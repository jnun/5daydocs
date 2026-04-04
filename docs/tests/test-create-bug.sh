#!/bin/bash
# Test: create-bug.sh
# Tests bug creation, STATE.md updates, error cases

set -e

PASS=0
FAIL=0
SCRIPT_UNDER_TEST="$(cd "$(dirname "$0")/../5day/scripts" && pwd)/create-bug.sh"

setup() {
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    mkdir -p "$TMPDIR/docs/5day/scripts"
    mkdir -p "$TMPDIR/docs/bugs"

    cp "$SCRIPT_UNDER_TEST" "$TMPDIR/docs/5day/scripts/create-bug.sh"

    cat > "$TMPDIR/docs/STATE.md" << 'EOF'
# docs/STATE.md

**Last Updated**: 2026-01-01
**5DAY_VERSION**: 2.1.3
**5DAY_TASK_ID**: 10
**5DAY_BUG_ID**: 5
**SYNC_ALL_TASKS**: false
EOF

    git -C "$TMPDIR" init -q
}

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        echo "  PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $desc (expected '$expected', got '$actual')"
        FAIL=$((FAIL + 1))
    fi
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

assert_file_exists() {
    local desc="$1" path="$2"
    if [ -f "$path" ]; then
        echo "  PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $desc (file not found: $path)"
        FAIL=$((FAIL + 1))
    fi
}

# --- Tests ---

echo "=== test-create-bug.sh ==="

# Test 1: Happy path — creates bug file
echo "Test 1: Happy path creates bug file"
setup
(cd "$TMPDIR" && bash docs/5day/scripts/create-bug.sh "Login button broken" > /dev/null 2>&1)
assert_file_exists "Bug file created" "$TMPDIR/docs/bugs/6-login-button-broken.md"

# Test 2: Bug file contains correct title
echo "Test 2: Bug file has correct title"
content=$(cat "$TMPDIR/docs/bugs/6-login-button-broken.md")
assert_contains "Title has bug ID" "$content" "# Bug 6: Login button broken"

# Test 3: Bug file contains severity placeholder
echo "Test 3: Bug file has severity field"
assert_contains "Severity field present" "$content" "**Severity:**"

# Test 4: Bug file contains required sections
echo "Test 4: Bug file has required sections"
assert_contains "Problem section" "$content" "## Problem"
assert_contains "Steps to reproduce" "$content" "## Steps to reproduce"
assert_contains "Success criteria" "$content" "## Success criteria"

# Test 5: STATE.md updated with new bug ID
echo "Test 5: STATE.md updated"
state=$(cat "$TMPDIR/docs/STATE.md")
assert_contains "Bug ID incremented to 6" "$state" "**5DAY_BUG_ID**: 6"

# Test 6: Missing description — should fail
echo "Test 6: Missing description exits 1"
setup
if (cd "$TMPDIR" && bash docs/5day/scripts/create-bug.sh "" > /dev/null 2>&1); then
    echo "  FAIL: Should have exited non-zero"
    FAIL=$((FAIL + 1))
else
    echo "  PASS: Exits non-zero on empty description"
    PASS=$((PASS + 1))
fi

# Test 7: Missing STATE.md — should fail
echo "Test 7: Missing STATE.md exits 1"
setup
rm "$TMPDIR/docs/STATE.md"
if (cd "$TMPDIR" && bash docs/5day/scripts/create-bug.sh "Some bug" > /dev/null 2>&1); then
    echo "  FAIL: Should have exited non-zero"
    FAIL=$((FAIL + 1))
else
    echo "  PASS: Exits non-zero without STATE.md"
    PASS=$((PASS + 1))
fi

# Test 8: Created date is today
echo "Test 8: Created date is today"
setup
(cd "$TMPDIR" && bash docs/5day/scripts/create-bug.sh "Date check" > /dev/null 2>&1)
content=$(cat "$TMPDIR/docs/bugs/6-date-check.md")
today=$(date +%Y-%m-%d)
assert_contains "Created date is today" "$content" "**Created**: $today"

# --- Summary ---
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
