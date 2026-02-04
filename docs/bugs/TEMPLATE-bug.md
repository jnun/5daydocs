<!--
SYNC NOTE: This template is copied to new projects during setup.sh.
Keep in sync with docs/bugs/TEMPLATE-bug.md when making format changes.
-->

# Bug [ID]: [Brief Description]

**Severity:** [CRITICAL | HIGH | MEDIUM | LOW]
**Created**: YYYY-MM-DD

## Problem

<!-- What is happening, and what should happen instead?
     Be specific about the unexpected behavior. -->



## Steps to reproduce

<!-- Numbered steps someone can follow to see the bug. -->

1.
2.
3.

## Success criteria

<!-- How do you know this is fixed?
     Write observable behaviors: "User can [do what]" or "System shows [result]" -->

- [ ]

## Notes

<!-- Environment details, screenshots, error messages, related files, or any other context.
     Leave empty if none, but keep this section. -->



<!--
AI BUG GUIDE

Severity levels:
  CRITICAL: System down, data loss, security issue
  HIGH: Major feature broken, blocks users
  MEDIUM: Feature impaired, workaround exists
  LOW: Minor issue, cosmetic

Bug file naming: ID-description.md (e.g., 3-login-timeout.md)

After documenting the bug:
1. Create a task to fix it (./5day.sh newtask "Fix: [bug description]")
2. Reference this bug file in the task
3. Move this file to docs/bugs/archived/ when fixed
-->
