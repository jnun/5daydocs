# Philosophy

**No databases, no apps—just folders and markdown files.**

- **Simple:** Everything is plain text and version controlled
- **Portable:** Works with any project, any language, any team size
- **Transparent:** All project management is visible and editable
- **Flexible:** Adapt the workflow to your needs
- **Minimal root footprint:** The only file placed in your project root is `DOCUMENTATION.md`
- **Docs folder holds everything:** /docs holds everything related to your project tasks
- **Submodule-friendly:** You can install 5DayDocs as a Git submodule

## Quick Start / Installation

To install 5DayDocs in your project:

```bash
# Option A: Clone standalone (recommended)
git clone https://github.com/jnun/5daydocs.git
cd 5daydocs
chmod +x setup.sh
./setup.sh

# Option B: Clone as a submodule (for enterprise)
git submodule add https://github.com/jnun/5daydocs.git 5daydocs
cd 5daydocs
chmod +x setup.sh
./setup.sh

# When prompted, enter the path to your project root
# (e.g., /Users/yourname/myproject)
```

After setup, your project will have:
- `DOCUMENTATION.md` in root (Your guide to using 5DayDocs)
- `docs/` folder with all 5DayDocs files
- `5day.sh` command script

**👉 See `DOCUMENTATION.md` in your project root for the complete workflow guide.**

## CONTRIBUTING - Repository Structure

**ALL SOURCE FILES ARE IN `./src/`**

- `src/`: Contains the clean, distributable version of the project files.
- `docs/`: Contains the internal project management (dogfooding) for 5DayDocs itself.

**Want to change what users get? Edit `./src/`**

## For 5DayDocs Developers: Distribution & Updates

**If you are maintaining the 5daydocs repository itself**, follow this workflow to properly distribute updates to users:

### Update & Distribution Checklist

1. **Make your changes** to the codebase (in `src/` or scripts).
2. **Increment the VERSION file**.
3. **Test the update process**.
4. **Commit and push**.

### How Update Distribution Works

When users run `./scripts/update.sh`, it copies distributable files from `src/` to their project.

---
*Simple, folder-based task management with clear feature documentation*

