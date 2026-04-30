#!/usr/bin/env bash
# docs/5day/cli/default.sh — Bare-minimum CLI profile for 5DayDocs
#
# Fallback profile used when FIVEDAY_CLI is set to an unsupported provider
# or when no provider-specific profile exists.  Passes only the prompt via
# -p and any extra arguments.  All other flags are silently ignored.
#
# Sourced automatically by config.sh when no matching profile is found.

fiveday_run() {
  local prompt=""
  local -a extra_args=()

  while [ $# -gt 0 ]; do
    case "$1" in
      -p)                    prompt="$2"; shift 2 ;;
      # Consume known flags so they don't leak to the CLI
      --model|--max-turns|--tools|--permissions|--output-format|--budget|--name|--append-system-prompt)
                             shift 2 ;;
      --skip-permissions)    shift ;;
      --)                    shift; extra_args+=("$@"); break ;;
      *)                     extra_args+=("$1"); shift ;;
    esac
  done

  local -a cmd=("$FIVEDAY_CLI")
  [ -n "$prompt" ] && cmd+=(-p "$prompt")

  if [ ${#extra_args[@]} -gt 0 ]; then
    cmd+=("${extra_args[@]}")
  fi

  "${cmd[@]}"
}
