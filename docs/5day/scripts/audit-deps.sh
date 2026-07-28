#!/usr/bin/env bash
# audit-deps.sh — Dependency-update audit. Detects the project's package
# ecosystem(s), runs each one's native "outdated" and "audit" tooling, then
# files ONE backlog task ("Audit dependency updates") holding three sections:
#   1. Outdated dependencies
#   2. Security advisories
#   3. Upgrade impact & breaking-change risk
# The deterministic bash half detects ecosystems and captures raw tool output;
# the AI half cleans that into the three sections and greps THIS codebase to
# judge impact. See: ./5day.sh help audit-deps

set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(cd "$SCRIPTS_DIR/.." && pwd)/lib.sh"

MODEL="$(fiveday_resolve_model DEPS)"
TOOLS="Read,Grep,Glob,Edit,Bash,Agent"
PERMISSIONS="auto"
MAX_TURNS=30
LOG_DIR="docs/tmp"
# Per-tool wall-clock cap — a slow or network-bound registry check can't wedge
# the whole audit. Override with FIVEDAY_DEPS_TIMEOUT.
DEPS_TIMEOUT="${FIVEDAY_DEPS_TIMEOUT:-120}"

# ── Preflight ───────────────────────────────────────────────────────
if [ ! -f "docs/5day/DOC_STATE.md" ]; then
  echo -e "${RED}ERROR: docs/5day/DOC_STATE.md not found!${NC}" >&2
  echo "Run ./setup.sh first to initialize the project." >&2
  exit 1
fi

AI_MODE="$(fiveday_ai_mode)"
if [ "$AI_MODE" != "emit" ] && ! command -v "$FIVEDAY_CLI" &>/dev/null; then
  echo "✗ AI CLI '$FIVEDAY_CLI' not found in PATH" >&2
  echo "  Edit docs/5day/config to change CLI, or install the tool." >&2
  exit 1
fi

mkdir -p "$LOG_DIR"
RAW_LOG="$LOG_DIR/audit-deps-raw.$(date +%Y%m%d-%H%M%S).md"
: > "$RAW_LOG"

# ── Ecosystem gathering ──────────────────────────────────────────────
DETECTED=()   # human labels, one per detected ecosystem

# emit_block LABEL TOOL CMD…  — append one raw-output block to $RAW_LOG.
# If TOOL isn't on PATH the block records the skip instead of failing. The
# command's own non-zero exit (npm/composer "outdated" exit 1 when anything is
# outdated) is expected and swallowed — we only want its text.
emit_block() {
  local label="$1" tool="$2"; shift 2
  {
    printf '\n### %s\n\n' "$label"
    if ! command -v "$tool" >/dev/null 2>&1; then
      printf '_skipped — \`%s\` not installed_\n' "$tool"
      return 0
    fi
    local out
    out="$(run_with_timeout "$DEPS_TIMEOUT" "$@" 2>&1)" || true
    [ -n "$out" ] || out="(no output — nothing reported)"
    # Cap each block so a huge tree can't bloat the task file / prompt.
    printf '```\n%s\n```\n' "$(printf '%s' "$out" | head -c 20000)"
  } >> "$RAW_LOG"
}

# Node / JavaScript — pick the package manager the repo actually uses.
if [ -f package.json ]; then
  PM=npm
  [ -f pnpm-lock.yaml ] && PM=pnpm
  [ -f yarn.lock ] && PM=yarn
  DETECTED+=("Node / JavaScript (package.json → $PM)")
  emit_block "Node — outdated ($PM)"       "$PM" "$PM" outdated
  emit_block "Node — security audit ($PM)" "$PM" "$PM" audit
fi

# Python
if [ -f requirements.txt ] || [ -f pyproject.toml ] || [ -f Pipfile ]; then
  DETECTED+=("Python (requirements.txt / pyproject.toml)")
  emit_block "Python — outdated (pip)"              pip       pip list --outdated
  emit_block "Python — security audit (pip-audit)" pip-audit pip-audit
fi

# Rust
if [ -f Cargo.toml ]; then
  DETECTED+=("Rust (Cargo.toml)")
  emit_block "Rust — outdated (cargo-outdated)"   cargo cargo outdated
  emit_block "Rust — security audit (cargo-audit)" cargo cargo audit
fi

# Go
if [ -f go.mod ]; then
  DETECTED+=("Go (go.mod)")
  emit_block "Go — available module updates" go         go list -u -m all
  emit_block "Go — vulnerabilities (govulncheck)" govulncheck govulncheck ./...
fi

# PHP / Composer
if [ -f composer.json ]; then
  DETECTED+=("PHP (composer.json)")
  emit_block "PHP — outdated (composer)"       composer composer outdated
  emit_block "PHP — security audit (composer)" composer composer audit
fi

# Ruby / Bundler
if [ -f Gemfile ]; then
  DETECTED+=("Ruby (Gemfile)")
  emit_block "Ruby — outdated (bundler)"                bundle       bundle outdated
  emit_block "Ruby — vulnerabilities (bundler-audit)"   bundle-audit bundle-audit check --update
fi

if [ "${#DETECTED[@]}" -eq 0 ]; then
  echo "▸ No dependency manifests found at the project root."
  echo "  Looked for: package.json, requirements.txt, pyproject.toml, Pipfile,"
  echo "  Cargo.toml, go.mod, composer.json, Gemfile."
  echo "  Nothing to audit — no task created."
  rm -f "$RAW_LOG"
  exit 0
fi

echo "▸ Ecosystems detected:"
for e in "${DETECTED[@]}"; do echo "    - $e"; done
echo "  Raw tool output: $RAW_LOG"
echo ""

# ── Create the backlog task (canonical path: ID, lock, DOC_STATE) ────
CREATE_OUT="$(bash "$SCRIPTS_DIR/create-task.sh" "Audit dependency updates")"
TASK_FILE="$(printf '%s\n' "$CREATE_OUT" | grep -oE 'docs/tasks/backlog/[^ ]+\.md' | tail -1)"
if [ -z "$TASK_FILE" ] || [ ! -f "$TASK_FILE" ]; then
  echo "✗ Could not create the backlog task." >&2
  printf '%s\n' "$CREATE_OUT" >&2
  exit 1
fi

# ── Seed the task with the section skeleton + raw source data ────────
# Placeholders keep the task useful even if no AI ever runs; the raw appendix
# is the AI's (or a human's) source material and can be trimmed once analysed.
{
  echo ""
  echo "## Ecosystems detected"
  echo ""
  for e in "${DETECTED[@]}"; do echo "- $e"; done
  echo ""
  echo "## Outdated dependencies"
  echo ""
  echo "_Pending analysis — see Source data below._"
  echo ""
  echo "## Security advisories"
  echo ""
  echo "_Pending analysis — see Source data below._"
  echo ""
  echo "## Upgrade impact & breaking-change risk"
  echo ""
  echo "_Pending analysis — see Source data below._"
  echo ""
  echo "---"
  echo ""
  echo "## Source data (raw tool output)"
  echo ""
  echo "_Generated by \`./5day.sh audit-deps\` on $(date +%Y-%m-%d). Delete once the sections above are filled._"
  cat "$RAW_LOG"
} >> "$TASK_FILE"

echo "▸ Filed task: $TASK_FILE"

# ── Build the analysis prompt ────────────────────────────────────────
PROFILE_LINE="$(fiveday_profile_line)"

PROMPT="Dependency-update audit. CLAUDE.md is auto-loaded.${PROFILE_LINE}

A backlog task has been created with raw dependency-tool output embedded under
its '## Source data' section:

  TASK FILE: $TASK_FILE

Ecosystems detected: $(printf '%s; ' "${DETECTED[@]}")

Edit that task file (do not create a new one). Replace the three placeholder
sections using the raw Source data plus the actual code in this repo:

1. '## Outdated dependencies' — a clean table:
   | Package | Ecosystem | Current | Latest stable | Bump (patch/minor/major) |
   Use the LATEST STABLE release, not pre-release/beta. Sort major bumps first.

2. '## Security advisories' — a table of known vulnerabilities from the audit
   output:
   | Package | Advisory (CVE/GHSA) | Severity | Vulnerable | Fixed in |
   If the audit output is empty or the tool was skipped, say so explicitly —
   never imply 'clean' when a scanner did not run.

3. '## Upgrade impact & breaking-change risk' — for each notable update
   (every major bump, and any dependency flagged by a security advisory):
   - the semver jump and what typically breaks across it,
   - where THIS codebase uses it — grep/glob for imports and call sites,
   - a risk rating (Low / Medium / High) and the smallest safe next step.
   Skip dependencies this repo does not actually import.

Then delete the '## Source data' section and its heading — the three sections
above replace it. Keep '## Ecosystems detected' as-is.

Do not modify any file other than $TASK_FILE. Finish with a final line:
VERDICT: FILED — <n> outdated, <m> advisories | CLEAN — nothing outdated"

# ── Run ──────────────────────────────────────────────────────────────
# Emit mode: hand the prompt to the surrounding agent (checked via AI_MODE,
# not fiveday_emitted — the exec path runs fiveday_run in a command
# substitution where the mode flag can't propagate).
if [ "$AI_MODE" = "emit" ]; then
  fiveday_run -p "$PROMPT"
  echo ""
  echo "✓ Task filed with raw source data: $TASK_FILE"
  echo "  Run the emitted prompt above to fill in the three analysis sections."
  exit 0
fi

_model_args=()
[ -n "$MODEL" ] && _model_args=(--model "$MODEL")
_budget_args=()
[ -n "${FIVEDAY_BUDGET_DEPS:-}" ] && _budget_args=(--budget "$FIVEDAY_BUDGET_DEPS")

LOG_FILE="$(fiveday_log_path deps "$(basename "$TASK_FILE")")"

OUTPUT=$(fiveday_run -p "$PROMPT" \
  ${_model_args[@]+"${_model_args[@]}"} \
  ${_budget_args[@]+"${_budget_args[@]}"} \
  --tools "$TOOLS" \
  --permissions "$PERMISSIONS" \
  --max-turns "$MAX_TURNS" \
  --output-format json 2>/dev/null | tee "$LOG_FILE") || true

VERDICT=$(printf '%s' "$OUTPUT" | fiveday_parse_verdict 'FILED|CLEAN')
[ -z "$VERDICT" ] && VERDICT="UNCLEAR"

echo ""
case "$VERDICT" in
  FILED|CLEAN)
    echo "✓ Dependency audit complete ($VERDICT): $TASK_FILE"
    exit 0
    ;;
  *)
    echo "? Dependency audit: could not parse a verdict — see $LOG_FILE"
    echo "  The task with raw source data is still filed: $TASK_FILE"
    if [ ! -s "$LOG_FILE" ]; then
      echo "  Log is empty — the AI CLI likely failed to start (check '$FIVEDAY_CLI' install/auth)"
    fi
    exit 1
    ;;
esac
