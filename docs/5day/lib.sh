# shellcheck shell=bash
# docs/5day/lib.sh — shared helper library for 5DayDocs scripts
# Sourced (not executed) — no shebang or set -euo pipefail; the caller provides those.
#
# Source this once at the top of any script that needs config or AI access:
#
#     source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"
#
# Provides:
#   Colours: RED GREEN YELLOW BLUE CYAN DIM BOLD NC
#   sed_escape STRING          — escape special chars for sed replacement
#   sed_inplace ARGS...        — portable in-place sed (macOS + Linux)
#   move_file SRC DEST         — git mv with plain mv fallback
#   run_with_timeout SECS CMD… — portable timeout (coreutils, gtimeout, or shell)
#   kebab_case STRING          — lowercase, hyphenated slug
#   fiveday_cfg KEY            — read a value from docs/5day/config
#   fiveday_cfg_set KEY VALUE  — update or append a value in config
#   fiveday_resolve_model SFX  — model resolution: env > config > default
#   fiveday_profile_line       — one-line pointer to project.md (empty if absent)
#   fiveday_find_task ID [dirs…] — resolve a task file by numeric ID
#   fiveday_log_path KIND NAME — timestamped log path under docs/tmp
#   fiveday_load_profile [cli] — source the provider profile (fiveday_provider_exec)
#   fiveday_ai_mode            — "emit" or "exec" for the current environment
#   fiveday_emitted            — true if the last fiveday_run only emitted a prompt
#   fiveday_run ARGS…          — run AI: emit prompt to stdout, or exec the CLI

_FIVEDAY_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colours ──────────────────────────────────────────────────────────
# Honour NO_COLOR by blanking the codes. Consumed by sourcing scripts.
# shellcheck disable=SC2034
if [ -n "${NO_COLOR:-}" ]; then
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' DIM='' BOLD='' NC=''
else
    RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
    BLUE=$'\033[0;34m'; CYAN=$'\033[0;36m'; DIM=$'\033[2m'
    BOLD=$'\033[1m';   NC=$'\033[0m'
fi

# ── Shell utilities ──────────────────────────────────────────────────

sed_escape() {
    printf '%s' "$1" | sed 's;[&/\\];\\&;g'
}

sed_inplace() {
    if sed --version 2>/dev/null | grep -q GNU; then
        sed -i "$@"
    else
        sed -i '' "$@"
    fi
}

move_file() {
    git mv "$1" "$2" 2>/dev/null || mv "$1" "$2"
}

# Portable timeout: run_with_timeout SECONDS CMD [ARGS…]
# macOS lacks GNU coreutils `timeout`; fall back to gtimeout, then a shell
# watchdog. Returns the command's exit code.
run_with_timeout() {
    local secs="$1"; shift
    if command -v timeout >/dev/null 2>&1; then
        timeout "${secs}s" "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout "${secs}s" "$@"
    else
        "$@" &
        local pid=$!
        ( sleep "$secs" && kill "$pid" 2>/dev/null ) &
        local watcher=$!
        wait "$pid" 2>/dev/null
        local ret=$?
        kill "$watcher" 2>/dev/null
        pkill -P "$watcher" 2>/dev/null
        wait "$watcher" 2>/dev/null
        return $ret
    fi
}

# kebab_case "Some Title!" -> "some-title"
kebab_case() {
    printf '%s' "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/[^a-zA-Z0-9-]/-/g; s/--*/-/g; s/^-//; s/-$//'
}

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
        sed_inplace "s|^${key}=.*|${key}=${value}|" "$FIVEDAY_CONFIG_FILE"
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

# ── Task helpers ─────────────────────────────────────────────────────

# Emit a "read project.md" line if a profile exists (else nothing).
# Always returns 0 so it is safe in `var=$(fiveday_profile_line)` under set -e.
fiveday_profile_line() {
    [ -f "docs/5day/project.md" ] || return 0
    printf '%s' "
Also read docs/5day/project.md for project-specific stack and conventions."
}

# Resolve a task file by numeric ID. Prints "path<TAB>stage-dir" on success.
# Default search order matches the task lifecycle.
fiveday_find_task() {
    local id="$1"; shift
    local dirs=("$@")
    if [ ${#dirs[@]} -eq 0 ]; then
        dirs=(docs/tasks/blocked docs/tasks/backlog docs/tasks/next docs/tasks/doing)
    fi
    local dir match
    for dir in "${dirs[@]}"; do
        match=$(find "$dir" -maxdepth 1 -name "${id}-*.md" 2>/dev/null | head -1) || true
        if [ -n "$match" ]; then
            printf '%s\t%s' "$match" "$dir"
            return 0
        fi
    done
    return 1
}

# Timestamped log path: fiveday_log_path define 42-fix-thing.md
fiveday_log_path() {
    local kind="$1" name="$2"
    printf 'docs/tmp/log-%s-%s-%s.json' "$kind" "${name%.md}" "$(date +%Y%m%d-%H%M%S)"
}

# The task lifecycle folders, in order. One source of truth for every script
# that iterates stages (status, search, triage, validate, check-alignment…).
# shellcheck disable=SC2034
FIVEDAY_STAGES=(backlog next doing blocked review done)

# task_id "12-fix-auth.md" (or a full path) -> "12"
task_id() {
    local b="${1##*/}"
    printf '%s' "${b%%-*}"
}

# task_title FILE -> first "# " heading, without "# " or a "Task N: " prefix.
# Guards grep so a heading-less file yields empty (not a pipefail non-zero
# that would trip set -e in `x=$(task_title f)`).
task_title() {
    { grep -m1 '^# ' "$1" 2>/dev/null || true; } | sed 's/^# *//; s/^Task [0-9]*: *//'
}

# task_feature FILE -> value of the **Feature**: field (empty if absent).
# Same pipefail/set -e guard as task_title.
task_feature() {
    { grep -m1 '\*\*Feature\*\*:' "$1" 2>/dev/null || true; } | sed 's/.*\*\*Feature\*\*: *//'
}

# ── DOC_STATE (ID allocation) and templates ──────────────────────────

FIVEDAY_DOC_STATE="${FIVEDAY_DOC_STATE:-docs/5day/DOC_STATE.md}"

# alloc_id KEY [STATE] -> prints HIGHEST+1 for "**KEY**: N"; returns 1 if the
# file or a valid current value is missing (caller prints the error).
alloc_id() {
    local key="$1" state="${2:-$FIVEDAY_DOC_STATE}" highest
    [ -f "$state" ] || return 1
    highest=$(grep "^\*\*${key}\*\*:" "$state" | sed 's/.*: *//' | tr -d '[:space:]')
    [[ "$highest" =~ ^[0-9]+$ ]] || return 1
    printf '%s' "$((highest + 1))"
}

# bump_doc_state KEY VALUE [STATE] -> set "**KEY**: VALUE" (append if missing).
bump_doc_state() {
    local key="$1" value="$2" state="${3:-$FIVEDAY_DOC_STATE}"
    if grep -q "^\*\*${key}\*\*:" "$state" 2>/dev/null; then
        sed_inplace "s|^\*\*${key}\*\*:.*|**${key}**: ${value}|" "$state"
    else
        printf '**%s**: %s\n' "$key" "$value" >> "$state"
    fi
}

# copy_template SRC DEST -> validate SRC exists, mkdir DEST's dir, copy.
# Returns 1 if SRC is missing (caller prints the error).
copy_template() {
    local src="$1" dest="$2"
    [ -f "$src" ] || return 1
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
}

# ── Provider profile loader ──────────────────────────────────────────
# Sources the provider profile that defines fiveday_provider_exec().
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

# ── AI execution mode ────────────────────────────────────────────────
# emit — print the prompt to stdout for the surrounding agent to execute
#        (used when already inside an AI session, or no CLI is installed).
# exec — spawn the configured CLI binary (standalone terminal, loops, CI).
#
# Precedence: FIVEDAY_MODE env > config MODE > auto-detect.
# Auto-detect: a coding-agent session → emit; else exec if the CLI exists,
# otherwise emit as a last resort (better to show the prompt than to fail).
fiveday_ai_mode() {
    local m="${FIVEDAY_MODE:-$(fiveday_cfg MODE)}"
    if [ -n "$m" ]; then printf '%s' "$m"; return; fi

    if [ -n "${CLAUDECODE:-}" ] || [ -n "${CLAUDE_CODE_SESSION_ID:-}" ] \
       || [ -n "${CURSOR_TRACE_ID:-}" ] || [ -n "${CURSOR_SESSION_ID:-}" ] \
       || [ -n "${AI_AGENT:-}" ] || [ -n "${FIVEDAY_IN_AGENT:-}" ]; then
        printf 'emit'; return
    fi

    if command -v "$FIVEDAY_CLI" >/dev/null 2>&1; then
        printf 'exec'
    else
        printf 'emit'
    fi
}

FIVEDAY_LAST_MODE=""
fiveday_emitted() { [ "$FIVEDAY_LAST_MODE" = "emit" ]; }

# Print the prompt (system prompt + user prompt + trailing positionals) for
# the surrounding agent to act on. Provider-only flags are consumed/ignored.
fiveday_emit_prompt() {
    local prompt="" system_prompt=""
    local -a rest=()
    while [ $# -gt 0 ]; do
        case "$1" in
            -p)                     prompt="$2";        shift 2 ;;
            --append-system-prompt) system_prompt="$2"; shift 2 ;;
            --model|--max-turns|--tools|--permissions|--output-format|--budget|--name)
                                    shift 2 ;;
            --skip-permissions)     shift ;;
            --)                     shift; rest+=("$@"); break ;;
            *)                      rest+=("$1"); shift ;;
        esac
    done

    printf '%s\n' "── 5DayDocs: run the following in this session ──────────────"
    [ -n "$system_prompt" ] && printf '%s\n\n' "$system_prompt"
    [ -n "$prompt" ] && printf '%s\n' "$prompt"
    [ ${#rest[@]} -gt 0 ] && printf '%s\n' "${rest[*]}"
    printf '%s\n' "─────────────────────────────────────────────────────────────"
}

# fiveday_run — route an AI request to emit or exec based on the mode.
# Same argument surface as the provider profiles.
fiveday_run() {
    FIVEDAY_LAST_MODE="$(fiveday_ai_mode)"
    if [ "$FIVEDAY_LAST_MODE" = "emit" ]; then
        fiveday_emit_prompt "$@"
        return 0
    fi
    fiveday_provider_exec "$@"
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

# Load provider profile (defines fiveday_provider_exec)
fiveday_load_profile "$FIVEDAY_CLI"
