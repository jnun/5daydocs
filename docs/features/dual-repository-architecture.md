# Dual Repository Architecture

**Status:** WORKING
**Version:** 1.0.0
**Last Updated:** 2025-09-24

## Overview

5daydocs operates as two distinct repositories serving different purposes:

1. **5daydocs-dogfooding** - Internal development repository (private)
2. **5daydocs** - Clean distribution for submodule use (public)

This separation allows us to use our own tool to build itself while providing a clean, lightweight template for others.

## Repository Purposes

### 5daydocs-dogfooding (Development)

The internal repository where 5daydocs is actively developed and managed using 5daydocs itself.

**Contains:**
- Active development work in `work/tasks/`
- Bug tracking and fixes in `work/bugs/`
- Internal documentation in `docs/`
- Development scripts and experiments
- Full commit history and iterations
- Distribution build tools
- Project-specific configurations

**Purpose:**
- Dogfooding our own product
- Testing new features
- Managing the 5daydocs project itself
- Building distribution releases

### 5daydocs (Distribution)

The clean template repository designed for submodule inclusion in other projects.

**Contains:**
- Core scripts (`5day.sh`, `setup.sh`)
- Template structures
- Empty folder hierarchies
- Minimal documentation
- Clean .gitignore
- No project content

**Purpose:**
- Lightweight submodule inclusion
- Quick project initialization
- Zero-configuration start
- Clean slate for new projects

## Distribution Process

### Build Pipeline

```bash
# From 5daydocs-dogfooding repository
./scripts/build-distribution.sh
```

This script:
1. Creates/updates parallel `5daydocs` directory
2. Removes all existing content (preserves .git)
3. Copies only essential files
4. Creates empty folder structure
5. Generates clean README
6. Prepares for git push

### Files Included

```
5daydocs/
├── 5day.sh              # Main command interface
├── setup.sh             # Safe initialization
├── templates/           # Workflow templates
├── CLAUDE.md           # AI instructions
├── README.md           # User documentation
├── LICENSE             # MIT license
├── .gitignore          # Standard ignores
├── work/
│   ├── STATE.md        # ID tracking
│   ├── tasks/
│   │   ├── backlog/.gitkeep
│   │   ├── next/.gitkeep
│   │   ├── working/.gitkeep
│   │   ├── review/.gitkeep
│   │   └── live/.gitkeep
│   ├── bugs/
│   │   └── archived/.gitkeep
│   └── scripts/.gitkeep
└── docs/
    ├── features/.gitkeep
    └── guides/.gitkeep
```

## Submodule Integration

### User Installation

```bash
# Add 5daydocs as submodule
git submodule add https://github.com/org/5daydocs.git 5daydocs

# Initialize in project
./5daydocs/setup.sh

# Use commands
./5daydocs/5day.sh new "First task"
```

### Safe Initialization

The `setup.sh` script includes safety checks:

```bash
# Check if folder exists before creating
if [ ! -d "work/tasks/backlog" ]; then
    mkdir -p work/tasks/backlog
fi

# Preserve existing STATE.md content
if [ -f "work/STATE.md" ]; then
    # Update timestamps only
    # Preserve existing IDs
else
    # Create new STATE.md
fi
```

### Update Mechanism

Users can update their submodule:

```bash
# Update to latest version
cd 5daydocs
git pull origin main
cd ..
./5daydocs/setup.sh  # Re-run safe setup
```

## Migration Support

### Moving From Standalone to Submodule

```bash
# Backup existing work
cp -r work work.backup

# Remove old installation
rm -rf 5day.sh setup.sh templates/

# Add as submodule
git submodule add https://github.com/org/5daydocs.git 5daydocs

# Restore work content
cp -r work.backup/* work/
rm -rf work.backup
```

### Preserving Project Data

The setup script never destroys:
- Existing task files
- Current STATE.md IDs
- Custom scripts in work/scripts/
- Documentation in docs/

It only:
- Creates missing directories
- Updates timestamps in STATE.md
- Adds missing template files

## Version Management

### Dogfooding Repository

- Tagged with full version: `v1.2.3-dev`
- Includes all features and experiments
- May contain breaking changes

### Distribution Repository

- Tagged with stable version: `v1.2.3`
- Only stable, tested features
- Backward compatibility maintained
- Clear upgrade paths

## Benefits

### For Developers (Dogfooding)

- Full project history
- Experimentation space
- Real-world testing
- Complete documentation
- Development tools

### For Users (Distribution)

- Minimal footprint (~100KB)
- Clean start
- No unnecessary files
- Quick integration
- Stable releases only

## Future Enhancements

### Planned Features

1. **Automatic sync** - GitHub Action to build distribution on release
2. **Version checking** - Notify users of updates
3. **Migration tools** - Automated upgrade scripts
4. **Template library** - Additional workflow templates
5. **Plugin system** - Extended functionality without core changes

### Compatibility Promise

- Folder structure remains stable
- Core commands never break
- STATE.md format preserved
- Backward compatibility for 2 major versions

## Implementation Status

- [x] Dual repository structure designed
- [x] Build distribution script created
- [x] Safe setup.sh with existence checks
- [ ] GitHub Action for automated builds
- [ ] Migration scripts for version upgrades
- [ ] Version compatibility checker

## Related Documentation

- [DISTRIBUTION.md](/DISTRIBUTION.md) - Build process details
- [setup.sh](/setup.sh) - Safe initialization logic
- [build-distribution.sh](/scripts/build-distribution.sh) - Distribution builder