# Task 34: .gitignore Created Without User Consent

**Feature**: none
**Created**: 2025-10-19


## Problem
The setup.sh script automatically creates a new .gitignore file if one doesn't exist, without asking the user. It should ask permission and offer to append to an existing .gitignore if present.

## Success criteria
- User is asked if they want .gitignore defaults added
- If .gitignore exists, offer to append (checking for duplicates)
- If .gitignore doesn't exist, offer to create with defaults
- User can decline and handle .gitignore manually

- [ ] Script prompts user about .gitignore handling
- [ ] Existing .gitignore is preserved and appended to (not overwritten)
- [ ] User can decline .gitignore modifications
