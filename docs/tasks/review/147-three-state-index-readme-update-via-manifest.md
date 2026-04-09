# Task 147: Three-state INDEX/README update via install manifest

**Feature**: none
**Created**: 2026-04-08
**Depends on**: none
**Blocks**: 148

## Problem

`setup.sh` previously had two policies for user-territory files:

- `README.md`: copy only if missing → defaults frozen forever once installed.
- `INDEX.md` files: blanket skip on update → same problem, plus the prior fix in task 145 silently clobbered user edits via the dynamic 5day loop (caught in audit of tasks 143/144/145).

Both policies are wrong in opposite directions. The right behavior is three-state:

1. File matches the version we originally shipped → still the default → safe to update.
2. File differs from what we shipped → user customized → preserve.
3. No record of what we shipped → conservative preserve, with a recovery path.

Without this distinction, projects either drift away from defaults forever, or have user customizations silently destroyed on update. Both lead to documentation rot.

## Success criteria

- [x] Fresh install records a sha256 manifest of every user-territory file at install time
- [x] Update where the file is unchanged from the recorded sha overwrites with the new default and refreshes the manifest entry
- [x] Update where the file differs from the recorded sha leaves the user's file alone and reports it as preserved
- [x] Update against a pre-manifest install adopts files into the manifest if they already match the source; conservatively preserves them otherwise
- [x] Manifest is human-readable and verifiable with `shasum -a 256 -c MANIFEST`
- [x] No regression in fresh-install behavior — all expected files still ship
- [x] All scenarios verified empirically (fresh / idempotent update / customized / upstream change / pre-manifest recovery)

## Notes

- Manifest location: `docs/5day/MANIFEST` (visible, version-tracked, plain text)
- Format: `<sha256>  <relative_path>` per line — same as `shasum -a 256` output, so `shasum -a 256 -c docs/5day/MANIFEST` works as a verification command out of the box
- Cross-platform sha256: `compute_sha` tries `sha256sum` (Linux) then `shasum -a 256` (macOS), falls back to skip-if-exists if neither is available
- Scope: only user-territory files (README.md, all INDEX.md). Scripts, AI files, and templates are still owned by 5DayDocs and overwrite unconditionally — this matches the existing convention and keeps the manifest small and meaningful.
- Replaces the blanket `if [ -f "$index_file" ]; then continue; fi` skip introduced in task 145, which silently clobbered any INDEX.md file the dynamic 5day loop also touched.

## Completed

**Implementation:**

- `setup.sh` — added manifest infrastructure: `MANIFEST_PATH`, `compute_sha`, `manifest_get_sha`, `manifest_set_sha`, and `safe_install_user_file` (the three-state installer). Replaced the README copy and the INDEX_FILES loop body with calls to `safe_install_user_file`. The dynamic 5day loop already excludes `INDEX.md` (fixed in the audit pass), so INDEX files are now owned exclusively by the manifest path.

**Verified scenarios** (all passed):

1. Fresh install — manifest written with sha for every user-territory file
2. Idempotent update — every file reports `Up to date`
3. User edits `docs/5day/scripts/INDEX.md` → update preserves the edit
4. Upstream default for `docs/tasks/INDEX.md` changes → user file still matches old recorded sha → installer copies new default and refreshes manifest sha
5. Manifest deleted (simulating pre-manifest install) → unedited files are adopted into a fresh manifest, edited file stays preserved; subsequent update behaves correctly (`Up to date` for adopted, `Preserved` for edited)

**Files changed:**

- `setup.sh` — manifest helpers + three-state installer + two call-site rewrites (README, INDEX_FILES loop)
