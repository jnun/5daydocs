Validate task files against the template format.

Usage:
  ./5day.sh validate              # check all tasks, report issues
  ./5day.sh validate --fix        # check and auto-fix tasks
  ./5day.sh validate --fix --dry-run  # show what would be fixed
  ./5day.sh validate --docs       # check help/*.md for flag drift vs scripts

--docs compares the flags each command's script parses against the flags
its help/*.md documents, and reports either direction of drift. Run it after
touching any command's flags so the docs never fall out of sync. Exit 1 if
drift is found, 0 if clean.
