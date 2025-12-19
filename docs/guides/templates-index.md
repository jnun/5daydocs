# Templates Directory

This directory contains template files that are copied to new projects during setup. These templates are NOT active in the 5daydocs development repository - they are build artifacts created during the distribution build process.

## Directory Structure

```
templates/
├── project/
│   ├── README.md                     # Template for project README
│   └── STATE.md.template             # Template for STATE.md with placeholders
├── workflows/
│   ├── github/
│   │   └── sync-tasks-to-issues.yml  # GitHub Issues integration workflow
│   └── bitbucket/
│       ├── pipelines.yml             # Basic Bitbucket Pipelines config
│       └── pipelines-jira.yml        # Bitbucket Pipelines with Jira integration
└── github/
    ├── ISSUE_TEMPLATE/
    │   ├── bug_report.md             # GitHub bug report template
    │   ├── feature_request.md        # GitHub feature request template
    │   └── task.md                   # GitHub task template
    └── pull_request_template.md      # GitHub PR template
```

## Architecture: Build-Time Template Generation

**Key Concept**: Templates in the distribution repo are build artifacts, not manually maintained files.

### In the Development Repository

- **Active workflows** live in `.github/workflows/` and `.github/ISSUE_TEMPLATE/`
- These are the ONLY manually edited workflow files
- The `templates/` directory in dev does NOT contain GitHub workflow templates
- Single source of truth: `.github/` directory

### During Distribution Build (`build-distribution.sh`)

The build script automatically:
1. Copies `.github/workflows/*.yml` → `templates/workflows/github/`
2. Copies `.github/ISSUE_TEMPLATE/*.md` → `templates/github/ISSUE_TEMPLATE/`
3. Copies `.github/pull_request_template.md` → `templates/github/`

**Result**: Distribution repo contains workflow templates WITHOUT an active `.github/` directory

### During User Installation (`setup.sh`)

When users install 5daydocs in their project:
1. **Platform Selection**: Script asks which platform they're using
2. **Template Copying**: Based on selection, copies from `templates/` to user's `.github/`:
   - **GitHub Issues**: Copies `templates/workflows/github/sync-tasks-to-issues.yml` → `.github/workflows/`
   - **GitHub Templates**: Copies all templates from `templates/github/` → `.github/`
   - **Bitbucket**: Copies `templates/workflows/bitbucket/pipelines.yml` → root directory

## For 5daydocs Development

### Making Changes to GitHub Workflows or Templates

**IMPORTANT**: Only edit files in `.github/` directory - NEVER edit `templates/workflows/github/` or `templates/github/`

1. **Edit workflows**: Modify `.github/workflows/sync-tasks-to-issues.yml`
2. **Edit issue templates**: Modify `.github/ISSUE_TEMPLATE/*.md`
3. **Edit PR template**: Modify `.github/pull_request_template.md`
4. **Build distribution**: Run `scripts/build-distribution.sh` to automatically copy to templates

**Why this approach?**
- ✅ Single source of truth (DRY principle)
- ✅ No manual sync required between dev and distribution
- ✅ Workflow changes are automatically included in next distribution build
- ✅ Development repo can test workflows before distribution

### Adding New Platform Support

To add support for a new platform (e.g., GitLab):

1. Create workflow files in `templates/workflows/gitlab/` directory (manually, since there's no active GitLab in dev repo)
2. Update `scripts/build-distribution.sh` to copy platform-specific templates
3. Update `setup.sh` to:
   - Add the new platform option
   - Copy the appropriate templates during setup
4. Document the integration setup requirements

### Testing the Distribution Build

**WARNING**: The build script must be run from a repository with a different name than "5daydocs" to avoid accidentally cleaning the development repo.

Safe workflow:
```bash
# Clone or rename your dev repo to something else
git clone <repo-url> 5daydocs-dev
cd 5daydocs-dev

# Now build-distribution.sh will create ../5daydocs (safe)
./scripts/build-distribution.sh
```

The script includes safety checks to prevent cleaning the source directory.

## Template Guidelines

- **GitHub workflows/templates**: Edit in `.github/` only, never in `templates/`
- **Other platforms**: Create/edit directly in `templates/workflows/<platform>/`
- Include clear comments about required secrets/configuration
- Test workflows before committing
- Document platform-specific requirements in README or separate guides