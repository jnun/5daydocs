# Add Dogfooding Explanation to README

## Problem
The README.md doesn't clearly explain that the 5daydocs repository itself is an active example of using the 5daydocs system. This creates confusion about what files are framework templates vs. active project files.

Users need to understand:
1. This repo is both the tool AND an example of using it
2. When they clone/setup, they get clean templates, not our active work
3. The separation between "5daydocs the framework" and "5daydocs the project"

## Desired Outcome
Add a clear section to README.md that:
- Explains we're dogfooding the system
- Clarifies that setup.sh provides clean templates
- Shows this repo as a living example of 5daydocs in action
- Distinguishes between framework files and active project files

Example section:
```markdown
## This Repository is Dogfooding 5daydocs

This repository serves two purposes:
1. **The 5daydocs framework** - Templates and tools you can use in any project
2. **A living example** - We use 5daydocs to manage the development of 5daydocs itself

When you run `setup.sh`, you get clean templates starting from task ID 0, not our active project data. Our `work/` folder shows real usage with 50+ tasks, while your new project starts fresh.
```

## Testing Criteria
- [ ] README clearly explains the dual nature of this repo
- [ ] New users understand they get clean templates
- [ ] The distinction between framework and example is clear
- [ ] No confusion about inheriting our project's tasks/data