Clear scratch files from docs/tmp/.

Usage:
  ./5day.sh cleanup              # dry run — show what would be cleaned
  ./5day.sh cleanup --delete     # delete stale files (with confirmation)
  ./5day.sh cleanup --force      # delete stale files (no confirmation)
  ./5day.sh cleanup --all        # delete everything (with confirmation)

--force is --delete without the interactive prompt — for scripts and CI
where no one is at the keyboard to answer y/N.
