# Task 171: Trim audit prompts and reduce MAX_TURNS in audit-code.sh

**Feature**: none
**Created**: 2026-04-23
**Depends on**: Task 169
**Blocks**: none

## Problem

The fixer and verifier prompts in audit-code.sh are ~400 words each, with verbose category checklists and step-by-step instructions. MAX_TURNS=75 is excessive for a focused audit pass. There is no per-step cost cap. Both waste tokens on every audit step, and audits can run up to 6 steps.

**Files to change**:
- docs/5day/scripts/audit-code.sh
- src/docs/5day/scripts/audit-code.sh (mirror)

## Success criteria

- [ ] MAX_TURNS reduced from 75 to 30
- [ ] Fixer prompt trimmed to ~100 words (keep: impact graph, audit categories as short list, fix issues, VERDICT output)
- [ ] Verifier prompt trimmed to ~80 words (keep: read-only, verify fixes, VERDICT output)
- [ ] Both prompts still produce correct VERDICT: PASS/FIXED/FAIL/BLOCKED output on last line
- [ ] Add `--max-budget-usd` flag to the CLI invocation in the audit loop, using `FIVEDAY_BUDGET_AUDIT` from config (defined in Task 169)
- [ ] src/docs/5day/scripts/audit-code.sh is an exact copy of docs/5day/scripts/audit-code.sh
- [ ] No other files changed

## Replacement fixer prompt

```
Code auditor with FRESH EYES. CLAUDE.md is auto-loaded.

[TASK_BLOCK]
[PASS_CONTEXT]

CHANGED FILES:
[CHANGED_FILES]

1. Build impact graph: Grep for imports/references to changed files.
2. Audit: correctness, conventions, style (touched lines only), build, safety.
3. Fix issues you find.
[BUILD_BLOCK]

Output ## Summary then VERDICT as LAST LINE:
VERDICT: PASS — no issues | FIXED — fixed all | FAIL — couldn't fix all | BLOCKED — needs human
```

## Replacement verifier prompt

```
Code verifier (READ-ONLY). CLAUDE.md is auto-loaded.

[TASK_BLOCK]
[PASS_CONTEXT]

CHANGED FILES:
[CHANGED_FILES]

1. Read changed files and trace imports/references.
2. Verify: correctness, conventions, safety.
[BUILD_BLOCK]

VERDICT as LAST LINE: PASS or FAIL
```

## How to wire up --max-budget-usd

Read FIVEDAY_BUDGET_AUDIT from config.sh (already sourced). Build the flag conditionally:

```bash
_budget_args=()
[ -n "${FIVEDAY_BUDGET_AUDIT:-}" ] && _budget_args=(--max-budget-usd "$FIVEDAY_BUDGET_AUDIT")
```

Add `"${_budget_args[@]}"` to the CLI invocation inside the audit while loop.

## Notes

Keep the existing TASK_BLOCK, PASS_CONTEXT, BUILD_BLOCK, and FEED_FORWARD variable construction — only replace the prompt assembly where the final PROMPT= is built.
