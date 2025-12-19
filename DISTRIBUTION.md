
# DISTRIBUTION.md

## Repository Structure & Dogfooding Approach

This project uses a single repository for both development and distribution of the 5DayDocs project management tool. We dogfood the 5DayDocs protocol by using it to manage the development of the tool itself, within this same repository.

**What does this mean?**
- When you clone the 5DayDocs repository, you get both the tool and the complete history of how it was built and managed.
- All development work, experiments, and internal project management are tracked here using the same system distributed to users.
- This approach provides full transparency and real-world testing of the protocol, but may be confusing at first glance. It is intentional and part of our philosophy.

**There is no separate distribution repository.** All users receive the same repository, including its project history and management artifacts.

- `src/`: Contains the clean, distributable version of the project files.
- `docs/`: Contains the internal project management (dogfooding) for 5DayDocs itself.

## Distribution Process

When preparing the repository for distribution, we provide users with:

**Core Scripts:**
- `5day.sh` - Main command interface
- `setup.sh` - Project initialization script

**Templates:**
- `templates/` - All workflow templates
- `.gitignore` - Standard ignores

**Documentation:**
- `README.md` - Includes explanation of dogfooding and project history
- `CLAUDE.md` - AI pair programming instructions
- `LICENSE` - License file

**Folder Structure:**
```
src/
├── CLAUDE.md
├── DOCUMENTATION.md
├── README.md
├── docs/
│   └── scripts/
│       ├── 5day.sh
│       ├── create-task.sh
│       ├── create-feature.sh
│       ├── check-alignment.sh
│       └── ai-context.sh
└── templates/
    ├── project/
    └── workflows/
        ├── github/
        └── bitbucket/

docs/ (Dogfooding - Internal Use)
├── features/
├── guides/
├── ideas/
├── tests/
├── STATE.md
└── work/
    ├── tasks/
    ├── bugs/
    └── scripts/
```

Some internal files and folders (such as this `DISTRIBUTION.md`, internal documentation, and project-specific content) are not intended for end users, but remain in the repository for transparency and development purposes.


## Building Distribution

Run the distribution build script to prepare the repository for users:

```bash
./scripts/build-distribution.sh
```

This script:
1. Cleans and prepares the repository
2. Copies only template files and scripts
3. Creates empty folder structure
4. Updates README for template users
5. Commits and pushes changes

git submodule add https://github.com/yourusername/5daydocs.git 5daydocs

## Usage as Submodule

Users can add 5DayDocs as a submodule to their own projects:

```bash
git submodule add https://github.com/yourusername/5daydocs.git 5daydocs
./5daydocs/setup.sh
./5daydocs/5day.sh [command]
```


## Maintenance

When updating the distribution:
1. Make changes in the main 5DayDocs repository
2. Test thoroughly
3. Run `./scripts/build-distribution.sh`
4. Tag releases as needed


## Philosophy

This approach allows us to:
- Dogfood the product while developing it
- Provide full transparency and real-world usage
- Distribute a clean template alongside project history
- Maintain a single source of truth
- Automate distribution builds