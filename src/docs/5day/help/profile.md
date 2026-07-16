AI-guided project profile generator.

Auto-detects the project's stack from files and manifests, confirms
with the user, and writes a flat profile to docs/5day/project.md.
All AI-powered commands include that profile in their context so
tasks inherit project-specific conventions automatically.

Usage:
  ./5day.sh profile           # create or update project profile

After running:
  - docs/5day/project.md exists with project conventions
  - find, define, sprint, tasks, and plan pick it up automatically
