# Features Documentation

## Feature Status: LIVE

This directory contains detailed specifications for all product features.

## Feature Status Tags

Each feature document includes a status tag indicating its current state:

- **[LIVE]** - Feature is deployed and available in production
- **[TESTING]** - Feature is built and undergoing testing/review
- **[WORKING]** - Feature is currently being developed
- **[BACKLOG]** - Feature is planned but work hasn't started

## File Naming Convention

Feature files use kebab-case naming: `feature-name.md`

Examples:
- `user-authentication.md`
- `data-export.md`
- `real-time-notifications.md`

## Feature Document Template

Each feature document should include:

```markdown
# Feature Name [STATUS]

## Overview
Brief description of what the feature does and why it's needed.

## User Stories
- As a [user type], I want to [action] so that [benefit]
- ...

## Requirements
### Functional Requirements
- Specific functionality needed
- User interactions
- System behaviors

### Non-Functional Requirements
- Performance criteria
- Security requirements
- Accessibility standards

## Implementation Notes
Technical considerations, dependencies, or constraints.

## Testing Criteria
How to verify the feature works correctly.

## Related Tasks
Links to task IDs in work/tasks/ that implement this feature.
```

## Workflow

1. **Planning**: Create feature doc with [BACKLOG] status
2. **Development Start**: Update to [WORKING] when implementation begins
3. **Testing**: Change to [TESTING] when ready for review
4. **Release**: Mark as [LIVE] when deployed to production

## Current Features

Feature documents in this directory represent the complete feature set of the project. Review existing features before proposing new ones to avoid duplication.