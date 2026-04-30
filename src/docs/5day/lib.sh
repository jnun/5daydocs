#!/usr/bin/env bash
# docs/5day/lib.sh — shared helper library for 5DayDocs scripts
#
# Source this once at the top of any script that needs config or AI access:
#
#     source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"
#
# Provides:
#   fiveday_cfg KEY            — read a value from docs/5day/config
#   fiveday_cfg_set KEY VALUE  — update or append a value in config
#   fiveday_resolve_model SUFFIX — model resolution: env > config > default
#   fiveday_load_profile [cli] — source the CLI profile defining fiveday_run()

_FIVEDAY_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIVEDAY_CONFIG_FILE="${FIVEDAY_CONFIG_FILE:-${_FIVEDAY_LIB_DIR}/config}"

# ── Config reader ────────────────────────────────────────────────────
# Reads KEY from the flat config file. Returns empty string if the key
# is absent or the file doesn't exist.
fiveday_cfg() {
    local key="$1"
    [ -f "$FIVEDAY_CONFIG_FILE" ] || return 0
    awk -F= -v k="$key" '!/^[[:space:]]*#/ && $1 == k { print substr($0, length(k)+2) }' "$FIVEDAY_CONFIG_FILE" | tail -1
}

# ── Config writer ────────────────────────────────────────────────────
# Updates a key in-place, or appends it if not present.
fiveday_cfg_set() {
    local key="$1" value="$2"
    if [ ! -f "$FIVEDAY_CONFIG_FILE" ]; then
        echo "${key}=${value}" > "$FIVEDAY_CONFIG_FILE"
        return
    fi
    if grep -q "^${key}=" "$FIVEDAY_CONFIG_FILE"; then
        sed -i '' "s|^${key}=.*|${key}=${value}|" "$FIVEDAY_CONFIG_FILE"
    else
        echo "${key}=${value}" >> "$FIVEDAY_CONFIG_FILE"
    fi
}

# ── Model resolver ───────────────────────────────────────────────────
# Usage: model=$(fiveday_resolve_model TASKS)
#
# Precedence: env FIVEDAY_MODEL_<SUFFIX> > config MODEL_<SUFFIX>
#             > config MODEL_DEFAULT > empty (CLI picks its own)
fiveday_resolve_model() {
    local suffix="$1"
    local env_var="FIVEDAY_MODEL_${suffix}"

    # Environment variable wins
    if [ "${!env_var+set}" = "set" ]; then
        printf '%s' "${!env_var}"
        return
    fi

    # Config per-script model
    local val
    val=$(fiveday_cfg "MODEL_${suffix}")
    if [ -n "$val" ]; then
        printf '%s' "$val"
        return
    fi

    # Config global default
    val=$(fiveday_cfg "MODEL_DEFAULT")
    printf '%s' "$val"
}

# ── CLI profile loader ───────────────────────────────────────────────
# Sources the provider profile that defines fiveday_run().
# Profiles live in docs/5day/cli/<provider>.sh.
fiveday_load_profile() {
    local cli="${1:-$FIVEDAY_CLI}"
    FIVEDAY_CLI="$cli"

    local cli_dir="${_FIVEDAY_LIB_DIR}/cli"
    local profile="${cli_dir}/${cli}.sh"
    if [ -f "$profile" ]; then
        # shellcheck source=/dev/null
        source "$profile"
    else
        # shellcheck source=/dev/null
        source "${cli_dir}/default.sh"
    fi
}

# ── Auto-load on source ─────────────────────────────────────────────
# Populate shell variables from config, with env overrides and defaults.
FIVEDAY_CLI="${FIVEDAY_CLI:-$(fiveday_cfg CLI)}"
: "${FIVEDAY_CLI:=claude}"

FIVEDAY_BUDGET_TASKS="${FIVEDAY_BUDGET_TASKS:-$(fiveday_cfg BUDGET_TASKS)}"
: "${FIVEDAY_BUDGET_TASKS:=5.00}"

FIVEDAY_BUDGET_AUDIT="${FIVEDAY_BUDGET_AUDIT:-$(fiveday_cfg BUDGET_AUDIT)}"
: "${FIVEDAY_BUDGET_AUDIT:=3.00}"

FIVEDAY_AUDIT_MAX_PASSES="${FIVEDAY_AUDIT_MAX_PASSES:-$(fiveday_cfg AUDIT_MAX_PASSES)}"
: "${FIVEDAY_AUDIT_MAX_PASSES:=2}"

# Load CLI profile (defines fiveday_run)
fiveday_load_profile "$FIVEDAY_CLI"
