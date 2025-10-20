# Task 94: Document VERSION file distribution strategy

**Feature**: none
**Created**: 2025-10-19

## Problem
The `build-distribution.sh` script doesn't copy the VERSION file to the distribution directory. This may be intentional (since version is tracked in STATE.md), but it should be documented and verified that this is the desired behavior.

Currently:
- Source repo has VERSION file with "2.0.0"
- Distribution repo gets STATE.md with version via template substitution
- No standalone VERSION file in distribution
- update.sh and setup.sh both look for VERSION file (scripts/update.sh:19, setup.sh:16)

## Success Criteria
- [ ] Analyze how VERSION file is used across all scripts
- [ ] Determine if VERSION file should be distributed
- [ ] Document the decision in VERSION_MANAGEMENT.md
- [ ] Identify any script changes needed based on decision
- [ ] Document findings for Task 95 implementation

## Dependencies
- **Depends on**: None
- **Blocks**: Task 95 (implementation of decision)

## Analysis Steps
1. Review VERSION file usage in all scripts (grep for VERSION references)
2. Check how update.sh and setup.sh handle missing VERSION files
3. Review current STATE.md structure and 5DAY_VERSION field usage
4. Determine if VERSION file is needed in distributions based on how setup.sh and update.sh work

## Questions to Answer
1. **Is VERSION file only for the 5daydocs source repo?**
   - Examine where scripts look for VERSION file

2. **Should installed projects have their own VERSION tracking?**
   - Consider the use cases and dependencies

3. **Is 5DAY_VERSION in STATE.md sufficient for all use cases?**
   - Consider version checks, compatibility, migration logic

4. **Should build-distribution.sh copy VERSION to distribution?**
   - If distribution is used as a submodule, do scripts need to find VERSION there?

## Expected Output
Create `VERSION_MANAGEMENT.md` in the project root documenting:
- Purpose of VERSION file
- Where it should exist (source only vs distribution too)
- How VERSION flows from source → distribution → target project STATE.md
- How scripts handle missing VERSION files
- Decision on whether build-distribution.sh should copy VERSION

## Implementation Guidance

After analysis, create VERSION_MANAGEMENT.md with sections covering:
- File locations (source repo, distribution, target projects)
- How setup.sh and update.sh use VERSION
- Version tracking flow diagram
- Current issues and fixes needed

## Notes
The analysis should determine definitively whether VERSION file is required in distributions or if the current approach (STATE.md only) is sufficient.

---

<!--
Workflow Reminder:
1. Start in docs/tasks/backlog/
2. Move to docs/tasks/next/ during sprint planning
3. Move to docs/tasks/working/ when starting work
4. Move to docs/tasks/review/ when complete
5. Move to docs/tasks/live/ after approval

If blocked, move back to docs/tasks/next/
-->
