# Task 105: Sync create-feature.sh with TEMPLATE-feature.md

**Feature**: none
**Created**: 2026-01-26

## Problem

`create-feature.sh` and `TEMPLATE-feature.md` have completely different structures:

**create-feature.sh generates:**
- User Stories
- Functional/Non-Functional Requirements
- Technical Design (Architecture, Dependencies, API)
- Testing Strategy
- Documentation checklist

**TEMPLATE-feature.md uses:**
- Simple capability-based format
- `## [CAPABILITY-1]` with status

Decision: Features should be complete, detailed guides. The detailed format (create-feature.sh) is correct. Update TEMPLATE-feature.md to match.

## Success criteria

- [ ] TEMPLATE-feature.md updated to detailed format
- [ ] Template includes: Overview, User Stories, Requirements, Technical Design, Tasks, Testing, Notes
- [ ] Remove capability-based structure from template
- [ ] Verify create-feature.sh and template are in sync

## Notes

Features drive development and quality testing. They must be well-defined, clear, and complete.
