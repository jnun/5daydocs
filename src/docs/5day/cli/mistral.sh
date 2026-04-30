#!/usr/bin/env bash
# docs/5day/cli/mistral.sh — Mistral CLI profile for 5DayDocs
#
# Defines fiveday_run(), which maps the provider-neutral interface used by
# 5DayDocs scripts to the Mistral (Le Chat) CLI flags.
#
# Sourced automatically by config.sh when FIVEDAY_CLI=mistral.
#
# STATUS: stub — flags based on Mistral CLI docs as of 2026-04.
#   Assumed: prompt as positional argument, --model flag.
#   Unverified: most flags — Mistral's coding CLI is newer and less documented.
#   This profile is conservative; unknown flags are silently dropped.

fiveday_run() {
  # ── Parse provider-neutral arguments ──────────────────────────────
  local prompt="" model="" max_turns="" tools="" permissions=""
  local output_format="" budget="" name="" system_prompt=""
  local skip_permissions=0
  local -a extra_args=()

  while [ $# -gt 0 ]; do
    case "$1" in
      -p)                    prompt="$2";        shift 2 ;;
      --model)               model="$2";         shift 2 ;;
      --max-turns)           max_turns="$2";     shift 2 ;;
      --tools)               tools="$2";         shift 2 ;;
      --permissions)         permissions="$2";   shift 2 ;;
      --output-format)       output_format="$2"; shift 2 ;;
      --budget)              budget="$2";        shift 2 ;;
      --name)                name="$2";          shift 2 ;;
      --append-system-prompt) system_prompt="$2"; shift 2 ;;
      --skip-permissions)    skip_permissions=1; shift ;;
      --)                    shift; extra_args+=("$@"); break ;;
      *)                     extra_args+=("$1"); shift ;;
    esac
  done

  # ── Build Mistral CLI command ────────────────────────────────────
  local -a cmd=("$FIVEDAY_CLI")

  # Model selection (assumed supported)
  [ -n "$model" ] && cmd+=(--model "$model")

  # Prompt: pass as positional argument. If a system prompt is also set,
  # prepend it to the main prompt since a separate flag is unverified.
  if [ -n "$system_prompt" ] && [ -n "$prompt" ]; then
    cmd+=("${system_prompt}\n\n${prompt}")
  elif [ -n "$system_prompt" ]; then
    cmd+=("$system_prompt")
  elif [ -n "$prompt" ]; then
    cmd+=("$prompt")
  fi

  # NOTE: The following flags have no confirmed Mistral CLI equivalents and
  # are silently dropped. As the CLI matures, map them here.
  #   --max-turns       → (no equivalent found)
  #   --tools           → (no equivalent found)
  #   --permissions     → (no equivalent found)
  #   --skip-permissions → (no equivalent found)
  #   --budget          → (no equivalent found)
  #   --name            → (no equivalent found)
  #   --output-format   → (no equivalent found)

  # Pass through any extra arguments
  if [ ${#extra_args[@]} -gt 0 ]; then
    cmd+=("${extra_args[@]}")
  fi

  "${cmd[@]}"
}
