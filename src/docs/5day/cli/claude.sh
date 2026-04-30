#!/usr/bin/env bash
# docs/5day/cli/claude.sh — Claude Code CLI profile for 5DayDocs
#
# Defines fiveday_run(), which maps the provider-neutral interface used by
# 5DayDocs scripts to Claude Code's actual CLI flags.
#
# Sourced automatically by config.sh when FIVEDAY_CLI=claude (the default).

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

  # ── Build Claude Code command ─────────────────────────────────────
  local -a cmd=("$FIVEDAY_CLI")

  # Prompt mode: -p for non-interactive, --append-system-prompt for interactive
  if [ -n "$system_prompt" ]; then
    cmd+=(--append-system-prompt "$system_prompt")
  elif [ -n "$prompt" ]; then
    cmd+=(-p "$prompt")
  fi

  [ -n "$model" ]         && cmd+=(--model "$model")
  [ -n "$max_turns" ]     && cmd+=(--max-turns "$max_turns")
  [ -n "$tools" ]         && cmd+=(--allowedTools "$tools")
  [ -n "$output_format" ] && cmd+=(--output-format "$output_format")
  [ -n "$budget" ]        && cmd+=(--max-budget-usd "$budget")
  [ -n "$name" ]          && cmd+=(--name "$name")

  # Permissions: --dangerously-skip-permissions or --permission-mode
  if [ "$skip_permissions" -eq 1 ]; then
    cmd+=(--dangerously-skip-permissions)
  elif [ -n "$permissions" ]; then
    cmd+=(--permission-mode "$permissions")
  fi

  # Non-interactive runs should not persist sessions
  if [ -n "$prompt" ] && [ -z "$system_prompt" ]; then
    cmd+=(--no-session-persistence)
  fi

  # Pass through any extra arguments
  if [ ${#extra_args[@]} -gt 0 ]; then
    cmd+=("${extra_args[@]}")
  fi

  "${cmd[@]}"
}
