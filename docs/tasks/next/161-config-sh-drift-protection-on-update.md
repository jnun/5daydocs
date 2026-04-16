# Task 161: Config.sh drift protection on update

**Feature**: none
**Created**: 2026-04-16
**Depends on**: none
**Blocks**: none

## Problem

`docs/5day/config.sh` is user-territory — setup.sh skips it if it already exists so user edits (model choices, CLI binary, max passes) survive updates. But when we add new scripts with new config variables (e.g. `FIVEDAY_MODEL_CODE_AUDIT`, `FIVEDAY_AUDIT_MAX_PASSES` added in 2.2.1), existing users never get those variables in their config.sh. The scripts fall back to defaults silently, which works but means the user has no visibility into what's configurable and no way to tune new scripts without reading the source.

## Success criteria

- [ ] Running `./setup.sh` on a project with an existing `config.sh` appends any new variables from the distribution `config.sh` that are missing in the user's copy
- [ ] Existing user values are never overwritten — only missing variables are added
- [ ] New variables are appended with their comment block so the user understands what they control
- [ ] If the user's config.sh already has all variables and the function, setup.sh prints "Preserved docs/5day/config.sh (up to date)" and does not modify the file
- [ ] A fresh install (no existing config.sh) still copies the full file as before — no behavior change on that path
- [ ] Verification: set up a temp project with setup.sh, then replace its config.sh with the v2.2.0 fixture below. Re-run setup.sh as an update. Confirm: (a) CODE_AUDIT and AUDIT_MAX_PASSES appear at the end with their comments, (b) PLAN still says `sonnet` (user value preserved), (c) function not duplicated, (d) run setup.sh a third time and confirm it prints "up to date" with no file modification

**v2.2.0 test fixture** (save as `docs/5day/config.sh` before running the update):
```bash
#!/usr/bin/env bash
# docs/5day/config.sh — AI CLI and model configuration for 5DayDocs scripts
FIVEDAY_CLI="${FIVEDAY_CLI:-claude}"
FIVEDAY_MODEL_DEFAULT="${FIVEDAY_MODEL_DEFAULT-}"
# Deep reasoning — single-shot, quality matters.
FIVEDAY_MODEL_PLAN="${FIVEDAY_MODEL_PLAN-sonnet}"
FIVEDAY_MODEL_DEFINE="${FIVEDAY_MODEL_DEFINE-opus}"
FIVEDAY_MODEL_SPLIT="${FIVEDAY_MODEL_SPLIT-opus}"
FIVEDAY_MODEL_SPRINT="${FIVEDAY_MODEL_SPRINT-opus}"
FIVEDAY_MODEL_TASKS="${FIVEDAY_MODEL_TASKS-opus}"
# Bulk / loop operations
FIVEDAY_MODEL_AUDIT="${FIVEDAY_MODEL_AUDIT-sonnet}"

# ── Resolution helper ────────────────────────────────────────────────
fiveday_resolve_model() {
    local var="$1"
    if [ "${!var+set}" = "set" ]; then
        printf '%s' "${!var}"
    else
        printf '%s' "${FIVEDAY_MODEL_DEFAULT-}"
    fi
}
```

## Implementation

### What to change

**File:** `setup.sh`
**Location:** The `else` branch of the config.sh copy block. Find it by searching for the string `Preserved docs/5day/config.sh (user-territory)`. That `else` branch currently just prints the "Preserved" message. Replace it with the merge logic below.

The `if [ ! -f "docs/5day/config.sh" ]` branch (fresh install — full copy) stays exactly as-is.

### Config file structure

`config.sh` has three kinds of content, top to bottom:

1. **File header** — shebang (`#!/usr/bin/env bash`), doc comment block, and any lines before the first `FIVEDAY_` variable. Never touch this.
2. **Variable blocks** — each block is: 0+ comment lines (`^#` or blank) followed by a variable assignment line (`^FIVEDAY_[A-Z_]*=`). These are the merge targets.
3. **The `fiveday_resolve_model` function** — everything from the line matching `^fiveday_resolve_model()` to end-of-file. Treat as a single indivisible block: present or absent. The `# ── Resolution helper` comment section above it is part of this block (include it when appending).

### Merge function (add to setup.sh HELPER FUNCTIONS section)

This code is tested and ready to paste. The awk uses `index()` (not regex) for variable matching to avoid issues with shell metacharacters in variable values.

```bash
# merge_config "$src_config" "$user_config"
# Appends missing FIVEDAY_* variable blocks and the resolver function.
# Returns 0 if changes were made, 1 if already up to date.
merge_config() {
    local src="$1"
    local dest="$2"

    # Extract variable names (left of =) from each file
    local src_vars user_vars missing
    src_vars=$(grep -o '^FIVEDAY_[A-Z_]*' "$src" | sort -u)
    user_vars=$(grep -o '^FIVEDAY_[A-Z_]*' "$dest" | sort -u)
    missing=$(comm -23 <(echo "$src_vars") <(echo "$user_vars"))

    # Check if fiveday_resolve_model function is present
    local need_function=false
    if ! grep -q '^fiveday_resolve_model()' "$dest"; then
        need_function=true
    fi

    # Nothing to do?
    if [ -z "$missing" ] && [ "$need_function" = false ]; then
        return 1
    fi

    # Append missing variable blocks
    if [ -n "$missing" ]; then
        {
            echo ""
            echo "# ── Added by setup.sh ($(date +%Y-%m-%d)) ────────────────────"
            while IFS= read -r var; do
                [ -z "$var" ] && continue
                # Extract the variable line + its preceding comment block from src.
                # Rule ordering matters:
                #   1. If this line IS the target variable → print buffer + line, done.
                #   2. If this line is a DIFFERENT variable → reset buffer.
                #   3. If comment or blank → accumulate in buffer.
                #   4. Anything else (shebang, function def) → reset buffer.
                awk -v var="$var" '
                    index($0, var "=") == 1    { printf "%s%s\n", buf, $0; exit }
                    index($0, "FIVEDAY_") == 1 && /=/ { buf=""; next }
                    /^#/ || /^[[:space:]]*$/    { buf = buf $0 "\n"; next }
                    { buf="" }
                ' "$src"
            done <<< "$missing"
        } >> "$dest"
    fi

    # Append resolver function if missing
    if [ "$need_function" = true ]; then
        {
            echo ""
            sed -n '/^# ── Resolution helper/,$ p' "$src"
        } >> "$dest"
    fi

    return 0
}
```

### Integration into setup.sh

Replace the `else` branch:

```bash
# Before (current):
    else
        msg_step "Preserved docs/5day/config.sh (user-territory)"
    fi

# After:
    else
        if merge_config "$FIVEDAY_SOURCE_DIR/src/docs/5day/config.sh" "docs/5day/config.sh"; then
            msg_success "Updated docs/5day/config.sh (added new configuration options)"
        else
            msg_step "Preserved docs/5day/config.sh (up to date)"
        fi
    fi
```

Place the `merge_config` function definition in the HELPER FUNCTIONS section of setup.sh (near `ensure_task_folders`, before the copy sections).

### What NOT to change

- `config.sh` itself (either copy) — no structural changes
- The fresh-install path — `if [ ! -f "docs/5day/config.sh" ]` stays as-is
- Any script that sources config.sh — they already have fallback resolvers
- The `fiveday_resolve_model` function content — copy verbatim from src

## Notes

- **awk rule ordering is critical.** The target-variable match (`index($0, var "=") == 1`) must be rule 1. If the "any other variable" rule fires first, it clears the buffer before the target match can use it. This was tested and confirmed — the code above has the correct ordering.
- **Use `index()`, not regex (`$0 ~ ...`)** for variable matching. Regex breaks on variable values containing shell metacharacters like `:-` which appear in bash default-value syntax.
- **Use `while IFS= read -r` to iterate missing vars**, not `for var in $missing`. The `for` loop can break on variable names if `comm` output has unexpected whitespace.
- Edge case: user intentionally deleted a variable. Re-appending is mildly annoying but not harmful — they can delete it again. Tracking intentional deletions adds complexity for a rare case.
- The dated separator (`# ── Added by setup.sh (YYYY-MM-DD)`) makes it obvious what was auto-added vs. what the user wrote. User can move or reorder after.
- Never touch lines the user already has — even if their value differs from the distribution default. Their value is intentional.
