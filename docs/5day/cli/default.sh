#!/usr/bin/env bash
# docs/5day/cli/default.sh — Bare-minimum CLI profile for 5DayDocs
#
# Fallback profile used when FIVEDAY_CLI is set to an unsupported provider
# or when no provider-specific profile exists.  Passes only the prompt via
# -p and any extra arguments.  All richer flags (model, tools, budget, turn
# and output-format caps) are dropped — but no longer silently: the first
# time a run actually supplies one, a one-line warning naming the dropped
# capabilities is printed to stderr (once per shell session).
#
# Sourced automatically by config.sh when no matching profile is found.

fiveday_provider_exec() {
  local prompt=""
  local -a extra_args=()
  local -a dropped=()

  while [ $# -gt 0 ]; do
    case "$1" in
      -p)                    prompt="$2"; shift 2 ;;
      # Consume richer flags so they don't leak to the CLI, but note any that
      # carry a real value so we can warn the user they were dropped.
      --model)               [ -n "$2" ] && dropped+=("model selection");  shift 2 ;;
      --tools)               [ -n "$2" ] && dropped+=("tool restriction");  shift 2 ;;
      --budget)              [ -n "$2" ] && dropped+=("budget caps");       shift 2 ;;
      --max-turns)           [ -n "$2" ] && dropped+=("turn caps");         shift 2 ;;
      --output-format)       [ -n "$2" ] && dropped+=("JSON output");       shift 2 ;;
      --permissions|--name|--append-system-prompt)
                             shift 2 ;;
      --skip-permissions)    shift ;;
      --)                    shift; extra_args+=("$@"); break ;;
      *)                     extra_args+=("$1"); shift ;;
    esac
  done

  # Warn once per session, only when a dropped flag actually carried a value.
  if [ ${#dropped[@]} -gt 0 ] && [ -z "${_FIVEDAY_DROP_WARNED:-}" ]; then
    local list
    list=$(printf '%s, ' "${dropped[@]}"); list="${list%, }"
    printf '5DayDocs: %s has no profile — %s unsupported, running without them.\n' \
      "$FIVEDAY_CLI" "$list" >&2
    _FIVEDAY_DROP_WARNED=1
  fi

  local -a cmd=("$FIVEDAY_CLI")
  [ -n "$prompt" ] && cmd+=(-p "$prompt")

  if [ ${#extra_args[@]} -gt 0 ]; then
    cmd+=("${extra_args[@]}")
  fi

  "${cmd[@]}"
}
