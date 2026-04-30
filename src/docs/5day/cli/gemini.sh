#!/usr/bin/env bash
# docs/5day/cli/gemini.sh — Gemini CLI profile for 5DayDocs
#
# Defines fiveday_run(), which maps the provider-neutral interface used by
# 5DayDocs scripts to the Gemini CLI flags.
#
# Sourced automatically by config.sh when FIVEDAY_CLI=gemini.
#
# STATUS: stub — flags based on Gemini CLI docs as of 2026-04.
#   Assumed: -p for prompt, --model, --sandbox for safe execution.
#   Unverified: turn limits, budget caps, tool filtering, output format.

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

  # ── Build Gemini CLI command ─────────────────────────────────────
  local -a cmd=("$FIVEDAY_CLI")

  # Prompt: Gemini CLI accepts prompt via -p flag (same as neutral interface).
  if [ -n "$prompt" ]; then
    cmd+=(-p "$prompt")
  fi

  # Model selection (verified flag)
  [ -n "$model" ] && cmd+=(--model "$model")

  # Sandbox mode: when skip_permissions is set, use --sandbox to allow
  # Gemini to run commands without individual approval.
  if [ "$skip_permissions" -eq 1 ]; then
    cmd+=(--sandbox)
  fi

  # System prompt: Gemini CLI may support --system-prompt or similar.
  # Passing as extra arg for now — refine once verified.
  if [ -n "$system_prompt" ]; then
    cmd+=(--system-prompt "$system_prompt")
  fi

  # NOTE: The following flags have no confirmed Gemini CLI equivalents and
  # are silently dropped. When the CLI adds support, map them here.
  #   --max-turns     → (no equivalent found)
  #   --tools         → (no equivalent found)
  #   --budget        → (no equivalent found)
  #   --name          → (no equivalent found)
  #   --output-format → (no equivalent found)

  # Pass through any extra arguments
  if [ ${#extra_args[@]} -gt 0 ]; then
    cmd+=("${extra_args[@]}")
  fi

  "${cmd[@]}"
}
