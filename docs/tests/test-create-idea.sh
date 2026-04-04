#!/bin/bash
# Test: create-idea.sh
# Tests idea creation and error cases

set -e

PASS=0
FAIL=0
SCRIPT_UNDER_TEST="$(cd "$(dirname "$0")/../5day/scripts" && pwd)/create-idea.sh"

setup() {
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    mkdir -p "$TMPDIR/docs/5day/scripts"
    mkdir -p "$TMPDIR/docs/ideas"

    cp "$SCRIPT_UNDER_TEST" "$TMPDIR/docs/5day/scripts/create-idea.sh"

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

echo "=== test-create-idea.sh ==="

# Test 1: Happy path — creates idea file
echo "Test 1: Happy path creates idea file"
setup
(cd "$TMPDIR" && bash docs/5day/scripts/create-idea.sh "AI Code Review" > /dev/null 2>&1)
assert_file_exists "Idea file created" "$TMPDIR/docs/ideas/ai-code-review.md"

# Test 2: Idea file contains correct title
echo "Test 2: Idea file has correct title"
content=$(cat "$TMPDIR/docs/ideas/ai-code-review.md")
assert_contains "Title correct" "$content" "# Idea: AI Code Review"

# Test 3: Idea file has Feynman phases
echo "Test 3: Idea file has Feynman phases"
assert_contains "Phase 1" "$content" "## Phase 1: The Problem"
assert_contains "Phase 2" "$content" "## Phase 2: Plain English"
assert_contains "Phase 3" "$content" "## Phase 3: What It Does"
assert_contains "Phase 4" "$content" "## Phase 4: Open Questions"

# Test 4: Status is DRAFT
echo "Test 4: Status is DRAFT"
assert_contains "Status DRAFT" "$content" "**Status:** DRAFT"

# Test 5: Created date is today
echo "Test 5: Created date is today"
today=$(date +%Y-%m-%d)
assert_contains "Created date" "$content" "**Created:** $today"

# Test 6: Missing idea name — should fail
echo "Test 6: Missing name exits 1"
setup
if (cd "$TMPDIR" && bash docs/5day/scripts/create-idea.sh "" > /dev/null 2>&1); then
    echo "  FAIL: Should have exited non-zero"
    FAIL=$((FAIL + 1))
else
    echo "  PASS: Exits non-zero on empty name"
    PASS=$((PASS + 1))
fi

# Test 7: Duplicate idea — should fail
echo "Test 7: Duplicate idea exits 1"
setup
(cd "$TMPDIR" && bash docs/5day/scripts/create-idea.sh "Caching" > /dev/null 2>&1)
if (cd "$TMPDIR" && bash docs/5day/scripts/create-idea.sh "Caching" > /dev/null 2>&1); then
    echo "  FAIL: Should have exited non-zero for duplicate"
    FAIL=$((FAIL + 1))
else
    echo "  PASS: Exits non-zero on duplicate idea"
    PASS=$((PASS + 1))
fi

# --- Summary ---
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
