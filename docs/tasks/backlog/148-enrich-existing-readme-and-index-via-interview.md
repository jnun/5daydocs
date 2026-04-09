# Task 148: Enrich existing README and INDEX files via interactive interview

**Feature**: none
**Created**: 2026-04-08
**Depends on**: 147
**Blocks**: none

## Problem

Task 147 makes the installer respect user-customized README and INDEX files. That's necessary but not sufficient. Many users land with a README/INDEX that's *technically* customized (so the installer leaves it alone) but is still mostly the original boilerplate with one or two project-specific edits — drift in the other direction. The user has no good path to enrich those files without either (a) hand-editing them blind or (b) running the installer and watching it skip.

The installer is the wrong place for this — it must stay non-interactive enough to be safe for unattended updates. This needs a separate, opt-in flow: an interview script that talks to the user about their project, reads what's already in their README and INDEX files, and produces enriched versions that preserve their customization while filling in the gaps.

The script must never overwrite without showing a diff and getting explicit confirmation. The point is to *increase* user trust, not introduce a new clobber risk.

## Success criteria

- [ ] User can run `./5day.sh enrich` (or equivalent CLI surface) to start the interview
- [ ] Script discovers all enrichable files in the project: `README.md`, `docs/INDEX.md`, all per-folder `docs/<sub>/INDEX.md`, and reports their manifest state (default / customized / no record) before doing anything
- [ ] For each file, script asks the user a small set of project-specific questions (project name, one-line description, primary language, key directories, etc.) — questions appropriate to that file
- [ ] Script produces a proposed new version, shows the user a diff against the current file, and asks for accept / reject / edit
- [ ] On accept, the new version is written and the manifest entry is refreshed to the new sha (so future installer updates won't try to overwrite it)
- [ ] Script never proceeds without user confirmation
- [ ] Script works whether or not the user has an LLM available — graceful fallback to question-driven templating
- [ ] If an LLM is available (e.g., the user is running this inside Claude Code, Cursor, etc.), the script can offer to use it for richer enrichment, but never as the only path

## Notes

- Live in `src/docs/5day/scripts/enrich.sh` (synced to `docs/5day/scripts/enrich.sh` per the dev workflow)
- Wire into `5day.sh` dispatcher as `enrich` subcommand
- The manifest from task 147 is what makes this safe: after enrichment the new sha is recorded, so the installer's three-state logic correctly leaves the enriched file alone on subsequent updates
- Consider: the interview answers themselves might be worth persisting to a `docs/5day/project.yml` so other generators (task 149) can reuse them without re-asking
- Out of scope: rewriting the user's actual prose. The script proposes structural enrichment (sections, links, references), not content rewrites of customized prose. User prose is sacred.
