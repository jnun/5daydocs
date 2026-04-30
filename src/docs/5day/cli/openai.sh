#!/usr/bin/env bash
# docs/5day/cli/openai.sh — OpenAI Codex CLI profile for 5DayDocs
#
# Defines fiveday_run(), which maps the provider-neutral interface used by
# 5DayDocs scripts to the OpenAI Codex CLI flags.
#
# Sourced automatically by config.sh when FIVEDAY_CLI=codex.
#
# STATUS: stub — flags based on codex CLI docs as of 2026-04.
#   Assumed: -p for prompt, --model, --full-auto, positional prompt fallback.
#   Unverified: --max-turns equivalent, budget caps, output format control.

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

  # ── Build Codex CLI command ──────────────────────────────────────
  local -a cmd=("$FIVEDAY_CLI")

  # Codex uses --full-auto for non-interactive (no approval prompts).
  # When skip_permissions is set or we have a -p prompt, assume non-interactive.
  if [ "$skip_permissions" -eq 1 ]; then
    cmd+=(--full-auto)
  fi

  # Model selection (verified flag)
  [ -n "$model" ] && cmd+=(--model "$model")

  # Prompt: Codex accepts the prompt as a positional argument.
  # System prompt support is not confirmed — pass as part of prompt if set.
  if [ -n "$system_prompt" ] && [ -n "$prompt" ]; then
    cmd+=("${system_prompt}\n\n${prompt}")
  elif [ -n "$system_prompt" ]; then
    cmd+=("$system_prompt")
  elif [ -n "$prompt" ]; then
    cmd+=("$prompt")
  fi

  # NOTE: The following flags have no confirmed Codex equivalents and are
  # silently dropped. When Codex adds support, map them here.
  #   --max-turns   → (no equivalent found)
  #   --tools       → (no equivalent found — Codex manages its own tool access)
  #   --budget      → (no equivalent found)
  #   --name        → (no equivalent found)
  #   --output-format → (no equivalent found)

  # Pass through any extra arguments
  if [ ${#extra_args[@]} -gt 0 ]; then
    cmd+=("${extra_args[@]}")
  fi

  "${cmd[@]}"
}
