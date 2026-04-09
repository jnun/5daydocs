# Task 158: Centralize AI CLI and model configuration via `docs/5day/config.sh`

**Feature**: none
**Created**: 2026-04-09
**Depends on**: none
**Blocks**: none

## Problem

Six AI-driven scripts in `docs/5day/scripts/` each hardcoded their own model choice and called the `claude` binary directly. Five used `opus` (single-shot deep reasoning: `plan`, `define`, `split`, `sprint`, `tasks`) and one used `sonnet` (`audit-backlog`, which runs in a loop and was deliberately downshifted to save tokens). There was no config surface: changing the model meant editing each script, and switching to a non-Claude CLI meant a grep-and-replace across seven files.

This contradicts the project's stated LLM-agnostic posture — the scripts silently *assumed* Claude Code was installed, with a specific model picked per script, and gave users no way to override either choice short of forking the scripts.

Two things needed fixing together:

1. **Per-script granular control.** The cost/speed split (opus for single-shot, sonnet for the audit loop) is real and intentional, but it was invisible to users and un-configurable.
2. **CLI independence.** The six scripts shelled out to `claude` by name. Any user with a different AI CLI (cursor, aider, etc.) had no override path.

The fix had to respect three additional principles, stated during the design pass:

- **Speed is the goal** — the default install path should be zero prompts, zero friction.
- **Setup-time config, not runtime prompts** — never ask the user model questions during script execution; it wastes context and confuses the model.
- **Support "use the CLI's own default"** — so users who want "always latest model" don't have to track model names as they evolve.

## Success criteria

- [x] A single sourced config file at `docs/5day/config.sh` defines `FIVEDAY_CLI`, a global `FIVEDAY_MODEL_DEFAULT`, and six per-script model variables
- [x] All six scripts source the config at startup and fall back to hardcoded defaults if it's missing (so a source checkout without the config still works)
- [x] Resolution precedence: per-call env var > `FIVEDAY_MODEL_<SCRIPT>` > `FIVEDAY_MODEL_DEFAULT` > hardcoded fallback
- [x] Setting any model to the empty string `""` makes the script omit the `--model` flag entirely, so the CLI picks its own default ("always latest" behavior)
- [x] All six scripts call `$FIVEDAY_CLI` instead of the literal `claude`
- [x] Error messages when the CLI is missing point to `docs/5day/config.sh` as the override path, with Claude Code as an example install
- [x] `config.sh` is shipped via `safe_install_user_file` (manifest-tracked) so user edits survive `setup.sh` updates
- [x] `config.sh` is excluded from the dynamic `docs/5day/` copy loop in `setup.sh` to avoid double-installation and blanket overwrites
- [x] Fresh install behavior verified: config installed, manifest recorded, one-line notice printed
- [x] Update behavior verified: unchanged config reports `Up to date`; user-edited config reports `Preserved (user-customized)`
- [x] Config resolution verified empirically for all four cases: default, env override, empty-string override, unset-falls-back-to-default

## Implementation notes

### Config file structure (`docs/5day/config.sh`)

```bash
FIVEDAY_CLI="${FIVEDAY_CLI:-claude}"
FIVEDAY_MODEL_DEFAULT="${FIVEDAY_MODEL_DEFAULT-}"

# Deep reasoning — single-shot
FIVEDAY_MODEL_PLAN="${FIVEDAY_MODEL_PLAN-opus}"
FIVEDAY_MODEL_DEFINE="${FIVEDAY_MODEL_DEFINE-opus}"
FIVEDAY_MODEL_SPLIT="${FIVEDAY_MODEL_SPLIT-opus}"
FIVEDAY_MODEL_SPRINT="${FIVEDAY_MODEL_SPRINT-opus}"
FIVEDAY_MODEL_TASKS="${FIVEDAY_MODEL_TASKS-opus}"

# Bulk loops
FIVEDAY_MODEL_AUDIT="${FIVEDAY_MODEL_AUDIT-sonnet}"

fiveday_resolve_model() { ... }
```

The `-` (not `:-`) operator in each variable is load-bearing: it distinguishes "set but empty" from "unset". An empty string means *use CLI default*; an unset variable means *fall through to `FIVEDAY_MODEL_DEFAULT`*. `:-` would collapse these into one case and break the "always latest" use case.

### Script pattern

Each of the six scripts got a config-loading header:

```bash
_CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config.sh"
[ -f "$_CONFIG" ] && source "$_CONFIG"
: "${FIVEDAY_CLI:=claude}"
: "${FIVEDAY_MODEL_<SCRIPT>=<default>}"
```

And at the call site:

```bash
_model_args=()
[ -n "$MODEL" ] && _model_args=(--model "$MODEL")
"$FIVEDAY_CLI" -p "$PROMPT" "${_model_args[@]}" ...
```

Using a bash array for the model args lets the script omit `--model` entirely when the resolved value is empty, rather than passing `--model ""` which would break the CLI.

### Setup flow

Zero interactive questions. `setup.sh`:

1. The dynamic `docs/5day/` copy loop skips `config.sh` (it would otherwise blanket-overwrite on every update).
2. After the loop, `safe_install_user_file` ships `config.sh` with three-state update logic from task 147. First-time installs get the defaults + a manifest entry; subsequent updates preserve user edits.
3. The install summary adds one line: `AI CLI/model config at docs/5day/config.sh (edit to change CLI or models)`.

This preserves "speed is the goal" — the 95% case is a single Enter keystroke at the target-path prompt and the defaults stand. Power users discover the config via the summary line or by reading the file.

### Files changed

- `docs/5day/config.sh` — new
- `docs/5day/scripts/plan.sh` — config load + CLI var + model array
- `docs/5day/scripts/define.sh` — same
- `docs/5day/scripts/split.sh` — same
- `docs/5day/scripts/sprint.sh` — same
- `docs/5day/scripts/tasks.sh` — same
- `docs/5day/scripts/audit-backlog.sh` — same (with the sonnet default preserved for its bulk-loop use case)
- `src/docs/5day/config.sh` — mirrored from `docs/`
- `src/docs/5day/scripts/*.sh` — mirrored
- `setup.sh` — exclude `config.sh` from dynamic loop; install via `safe_install_user_file`; summary line

## Verification

All five scenarios tested empirically against `/tmp/config-test`:

| Scenario | Expected | Result |
|---|---|---|
| Fresh install | `config.sh` installed, manifest recorded | ✓ |
| Update, no changes | `Up to date: docs/5day/config.sh` | ✓ |
| User edits config.sh, update | `Preserved … (user-customized)`, edit intact | ✓ |
| `fiveday_resolve_model` with default | returns `opus` | ✓ |
| Env override `FIVEDAY_MODEL_PLAN=haiku` | returns `haiku` | ✓ |
| Empty string `FIVEDAY_MODEL_PLAN=""` | returns `""` (omit `--model`) | ✓ |
| Unset + `FIVEDAY_MODEL_DEFAULT=myglobal` | returns `myglobal` | ✓ |
| `bash -n` syntax check on all seven changed files | clean | ✓ |

## Notes for future work

- `shasum -a 256 -c docs/5day/MANIFEST` will show `FAILED` for any file the user has edited. That's **correct** — the manifest records the shipped sha so the installer can detect customization; it is not a live integrity check of the current state. The `FAILED` line is how the three-state logic knows to preserve user edits.
- Adding a new AI-driven script is now two lines: add a `FIVEDAY_MODEL_<NAME>` line to `config.sh`, and use the standard pattern in the new script. No installer changes needed.
- When tasks 148/149/150 land, they will use this same config surface. They should never hardcode a model or a CLI binary.
