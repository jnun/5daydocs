# idea-incubator (Claude Code skill)

A Lean Startup idea incubator with a **bias for action**. It takes a raw idea and
loops it — compress → rank assumptions → smallest test → pre-commit the verdict →
*go act* → come back → pivot or persevere — until the idea is validated, pivoted,
or killed. The destination is never a tidy plan; it's **one cheap test with a date
on it.** Planning is the time suck; action is the first win.

Domain-agnostic (startup, product, song, content, service, side project).

## Three modes — it asks which up front

- **Quick gut check (Sprint)** — the default. Gets you to a test in under ~15 min.
- **Full work-up (Deep)** — the 8-phase Validation Canvas, for an idea that's
  earned the scrutiny.
- **Continuing a loop (Re-entry)** — you ran a test; it coaches **pivot or
  persevere** against the metric you pre-committed, and logs each loop.

## Install

Drop the `idea-incubator/` folder into one of:

- **Project skill** (this repo only): `.claude/skills/idea-incubator/`
- **Personal skill** (all your projects): `~/.claude/skills/idea-incubator/`

So the file lands at, e.g., `~/.claude/skills/idea-incubator/SKILL.md`. Start a
new Claude Code session so it picks up the skill.

## Use

- "Incubate this idea: ..." / "Quick gut check on ..."
- "What should I test first?" / "Design an MVP for ..."
- "I ran the test — here's what happened." (re-entry / pivot-or-persevere)

It asks which mode, then runs a one-question-at-a-time interview and ends on a
dated action.

## The loop log

In Re-entry mode it maintains `idea-log-<slug>.md` — one block per loop (assumption
tested, test, pre-committed line, result, verdict, next action). That's how it
coaches you across sessions instead of starting cold each time. Template is in
`references/worked-example.md`.

## Files

```
idea-incubator/
  SKILL.md                    # modes, the loop, interview rules, outputs
  references/
    frameworks.md             # Lean/VPC/Mom Test crosswalk + optional scoring
    worked-example.md         # sprint example + deep canvas + loop-log template
  README.md
```

## Roadmap

- Scoring is deliberately light (qualitative reads + weak-link flags); a numeric
  rubric lives in `references/frameworks.md`.
- Possible next step: auto-grade each answer against the Mom Test rules so it
  challenges weak evidence ("that's a compliment, not a commitment") on its own.
