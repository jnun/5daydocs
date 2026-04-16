#!/usr/bin/env bash
# docs/5day/config.sh — AI CLI and model configuration for 5DayDocs scripts
#
# This file is sourced by scripts in docs/5day/scripts/.  Edit freely: your
# changes are preserved across setup.sh updates (via the install manifest).
#
# Any variable here can also be overridden by the shell environment or a
# one-off command-line export:
#
#     FIVEDAY_MODEL_PLAN=sonnet ./5day.sh plan 42
#
# Set any model to an empty string ("") to let the CLI pick its own default.
# This is often the smartest choice — your CLI always uses its latest model,
# and 5DayDocs never hardcodes a model name that can go stale.

# ── AI CLI binary ─────────────────────────────────────────────────────
# The command scripts shell out to. Must accept these flags:
#   -p / --append-system-prompt, --model, --allowedTools,
#   --dangerously-skip-permissions, --name
# Examples: claude, cursor-agent, aider
FIVEDAY_CLI="${FIVEDAY_CLI:-claude}"

# ── Global default model ─────────────────────────────────────────────
# Fallback for any per-script model that is not set below.
# Empty string = let the CLI use its own default (recommended for "always
# latest model" behavior).
FIVEDAY_MODEL_DEFAULT="${FIVEDAY_MODEL_DEFAULT-}"

# ── Per-script models ────────────────────────────────────────────────
# Each script has its own variable so you can trade off cost and quality
# script by script.  The supplied defaults reflect the original intent:
#
#   • Deep single-shot reasoning scripts use a high-capability model.
#   • The audit loop uses a cheaper model because it runs across many
#     tasks and token cost dominates.
#
# To "use the CLI default" for one script, set its value to the empty
# string ("").  To remove a line entirely, the global default above
# takes over.

# Deep reasoning — single-shot, quality matters.
FIVEDAY_MODEL_PLAN="${FIVEDAY_MODEL_PLAN-opus}"     # interactive task planning
FIVEDAY_MODEL_DEFINE="${FIVEDAY_MODEL_DEFINE-opus}" # task definition review
FIVEDAY_MODEL_SPLIT="${FIVEDAY_MODEL_SPLIT-opus}"   # task splitting
FIVEDAY_MODEL_SPRINT="${FIVEDAY_MODEL_SPRINT-opus}" # sprint execution
FIVEDAY_MODEL_TASKS="${FIVEDAY_MODEL_TASKS-opus}"   # batched task review

# Code audit — iterative, quality-critical, bounded passes.
FIVEDAY_MODEL_CODE_AUDIT="${FIVEDAY_MODEL_CODE_AUDIT-opus}"
FIVEDAY_AUDIT_MAX_PASSES="${FIVEDAY_AUDIT_MAX_PASSES:-3}"

# Bulk / loop operations — runs over many items, token cost matters.
FIVEDAY_MODEL_AUDIT="${FIVEDAY_MODEL_AUDIT-sonnet}" # backlog audit loop

# ── Resolution helper ────────────────────────────────────────────────
# Usage inside a script:
#
#     model="$(fiveday_resolve_model FIVEDAY_MODEL_PLAN)"
#     model_args=()
#     [ -n "$model" ] && model_args=(--model "$model")
#     "$FIVEDAY_CLI" "${model_args[@]}" ...
#
# Returns: the per-script value if set (even if empty), else the global
# default if set (even if empty), else empty.  An empty return means the
# script should omit the --model flag entirely so the CLI uses its own
# default.
fiveday_resolve_model() {
    local var="$1"
    # The "-" (not ":-") operator distinguishes "set but empty" from "unset",
    # so a user can explicitly set a script to "" to mean "use CLI default".
    if [ "${!var+set}" = "set" ]; then
        printf '%s' "${!var}"
    else
        printf '%s' "${FIVEDAY_MODEL_DEFAULT-}"
    fi
}
