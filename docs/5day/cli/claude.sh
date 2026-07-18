#!/usr/bin/env bash
# docs/5day/cli/claude.sh — Claude Code CLI profile for 5DayDocs
#
# Defines fiveday_provider_exec(), which maps the provider-neutral interface used by
# 5DayDocs scripts to Claude Code's actual CLI flags.
#
# Sourced automatically by config.sh when FIVEDAY_CLI=claude (the default).
#
# Live progress: when a script requests buffered --output-format json but
# stderr is still a terminal, the run is upgraded to stream-json and each
# tool call is narrated on stderr as it happens, while stdout receives the
# same single result-JSON object the caller expected. Call sites that
# redirect stderr (parallel runners, captured audit output) automatically
# fall back to the quiet buffered path — no call-site changes needed.
# Control with FIVEDAY_STREAM: unset = auto (TTY), 1 = force on, 0 = off.
#
# Transient-failure recovery: a dropped connection mid-run ("API Error:
# Connection closed mid-response") wastes every turn already spent. When a
# non-interactive run fails transiently, this profile waits and RESUMES the
# same session ("pick up where you left off"), falling back to a fresh
# rerun when no session id is recoverable. Sessions are persisted for this
# reason. Control with FIVEDAY_RETRIES (default 2, 0 = off) and
# FIVEDAY_RETRY_WAIT (seconds between attempts, default 60).

# Reads stream-json events on stdin; narrates tool activity to stderr and
# emits only the final result event (identical shape to --output-format
# json) on stdout. No single quotes in this code — it is embedded in one.
_FIVEDAY_STREAM_FILTER="$(cat <<'PYEOF'
import json, sys
result_line = None
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        ev = json.loads(line)
    except ValueError:
        continue
    t = ev.get("type")
    if t == "system" and ev.get("subtype") == "init":
        model = ev.get("model", "")
        if model:
            print("  . session started (%s)" % model, file=sys.stderr, flush=True)
    elif t == "assistant":
        for blk in (ev.get("message") or {}).get("content") or []:
            if blk.get("type") == "tool_use":
                name = blk.get("name", "?")
                inp = blk.get("input") or {}
                detail = (inp.get("file_path") or inp.get("path")
                          or inp.get("pattern") or inp.get("command")
                          or inp.get("description") or "")
                detail = " ".join(str(detail).split())
                if len(detail) > 100:
                    detail = detail[:97] + "..."
                msg = "  . %s: %s" % (name, detail) if detail else "  . %s" % name
                print(msg, file=sys.stderr, flush=True)
    elif t == "result":
        result_line = line
if result_line:
    print(result_line)
PYEOF
)"

# Error text that justifies a retry. Deliberately narrow: budget caps, turn
# caps, and flag errors must NOT retry.
_FIVEDAY_TRANSIENT_RE='API Error|Connection (closed|error|reset)|overloaded|rate.?limit|timed? ?out|50[023]|529'

fiveday_provider_exec() {
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

  # ── Decide on live streaming ──────────────────────────────────────
  # FIVEDAY_STREAM: 0 = never, 1 = always, unset/other = auto (stderr TTY).
  local stream=0
  if [ "$output_format" = "json" ] && command -v python3 >/dev/null 2>&1; then
    case "${FIVEDAY_STREAM:-auto}" in
      0) stream=0 ;;
      1) stream=1 ;;
      *) [ -t 2 ] && stream=1 ;;
    esac
  fi
  local effective_format="$output_format"
  [ "$stream" -eq 1 ] && effective_format="stream-json"

  # ── Retry policy ──────────────────────────────────────────────────
  # Resume only makes sense for non-interactive prompt runs.
  local max_retries="${FIVEDAY_RETRIES:-2}"
  local wait_s="${FIVEDAY_RETRY_WAIT:-60}"
  [ -n "$prompt" ] || max_retries=0

  local resume_prompt="Our connection broke mid-response and this session has been resumed. Review the conversation above and pick up exactly where you left off — do not redo completed work. If no prior progress is visible, start the task from the beginning using the original instructions. The original output requirements still apply."

  local attempt=0 rc=0 session=""
  local out errf
  out="$(mktemp)" || return 1
  errf="$(mktemp)" || { rm -f "$out"; return 1; }

  while :; do
    attempt=$((attempt + 1))

    # ── Build the command for this attempt ──────────────────────────
    local -a cmd=("$FIVEDAY_CLI")
    if [ "$attempt" -gt 1 ] && [ -n "$session" ]; then
      cmd+=(--resume "$session" -p "$resume_prompt")
    elif [ -n "$system_prompt" ]; then
      cmd+=(--append-system-prompt "$system_prompt")
    elif [ -n "$prompt" ]; then
      cmd+=(-p "$prompt")
    fi

    [ -n "$model" ]            && cmd+=(--model "$model")
    [ -n "$max_turns" ]        && cmd+=(--max-turns "$max_turns")
    [ -n "$tools" ]            && cmd+=(--allowedTools "$tools")
    [ -n "$effective_format" ] && cmd+=(--output-format "$effective_format")
    [ -n "$budget" ]           && cmd+=(--max-budget-usd "$budget")
    [ -n "$name" ]             && cmd+=(--name "$name")
    # stream-json in -p mode requires --verbose
    [ "$stream" -eq 1 ]        && cmd+=(--verbose)

    if [ "$skip_permissions" -eq 1 ]; then
      cmd+=(--dangerously-skip-permissions)
    elif [ -n "$permissions" ]; then
      cmd+=(--permission-mode "$permissions")
    fi

    if [ ${#extra_args[@]} -gt 0 ]; then
      cmd+=("${extra_args[@]}")
    fi

    # ── Execute ─────────────────────────────────────────────────────
    # CLI stderr is captured for the transient check and replayed at the
    # end; the stream filter's progress lines still reach stderr live.
    : > "$out"; : > "$errf"
    if [ "$stream" -eq 1 ]; then
      local -a _ps
      "${cmd[@]}" 2>"$errf" | python3 -c "$_FIVEDAY_STREAM_FILTER" > "$out" \
        && _ps=("${PIPESTATUS[@]}") || _ps=("${PIPESTATUS[@]}")
      rc="${_ps[0]}"
    else
      "${cmd[@]}" > "$out" 2>"$errf" && rc=0 || rc=$?
    fi

    # ── Evaluate: success, hard failure, or transient? ──────────────
    local failed=0
    if [ "$rc" -ne 0 ]; then
      failed=1
    elif grep -q '"is_error": *true' "$out" 2>/dev/null; then
      # Exit 0 but the result object itself reports an error (this is how
      # a mid-response connection drop actually presents).
      failed=1
    fi

    local transient=0
    if [ "$failed" -eq 1 ] && { [ -s "$out" ] || [ -s "$errf" ]; }; then
      # Silent startup deaths (empty output) and non-transient errors
      # (bad flags, budget/turn caps) never retry.
      grep -qiE "$_FIVEDAY_TRANSIENT_RE" "$out" "$errf" 2>/dev/null && transient=1
    fi

    if [ "$failed" -eq 0 ] || [ "$transient" -eq 0 ] || [ "$attempt" -gt "$max_retries" ]; then
      cat "$out"
      [ -s "$errf" ] && cat "$errf" >&2
      rm -f "$out" "$errf"
      return "$rc"
    fi

    # ── Transient failure with retries left: pause, then resume ─────
    local found
    found=$(grep -oE '"session_id" *: *"[^"]*"' "$out" 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)"$/\1/') || true
    [ -n "$found" ] && session="$found"

    if [ -n "$session" ]; then
      echo "⚠ Transient API failure (attempt $attempt/$((max_retries + 1))) — waiting ${wait_s}s, then resuming session ${session:0:8}…" >&2
    else
      echo "⚠ Transient API failure (attempt $attempt/$((max_retries + 1))) — waiting ${wait_s}s, then retrying from scratch…" >&2
    fi
    sleep "$wait_s"
  done
}
