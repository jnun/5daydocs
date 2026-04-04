# Task 131: Remove duplicate task content in split.sh prompt

**Feature**: none
**Created**: 2026-04-03
**Depends on**: none
**Blocks**: none

## Problem

In split.sh, the task content is embedded in the prompt via `$TASK_CONTENT` between `---` markers, AND the file path is given so the AI can read it from disk. The AI receives the same content twice, wasting context window tokens.

## Success criteria

- [x] split.sh prompt either embeds the content OR points to the file path, not both
- [x] The AI still has full access to the task content

## Notes

File to change: `docs/scripts/split.sh` (prompt text, lines 55-66)
Preferred approach: keep the file path reference and remove the inline `$TASK_CONTENT` embed. The AI will read it via the Read tool. This also avoids issues with large tasks or special characters in the content breaking the prompt string.

## Completed

Removed the duplicate task content embedding from the split.sh prompt in both copies:

- **`docs/scripts/split.sh`**: Removed `TASK_CONTENT=$(cat "$TASK_FILE")` variable and the inline `$TASK_CONTENT` block between `---` markers. Replaced with instruction to read the file from disk.
- **`src/docs/5day/scripts/split.sh`**: Same changes applied to the source template.

The prompt now tells the AI "Read this file to understand the full task content" instead of embedding it inline. The AI still has full access via the Read tool and the file path reference.
