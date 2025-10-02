# Templates Directory

This directory contains template files that are copied to new projects during setup. These templates are NOT active in the 5daydocs repository itself - they're only used when installing 5daydocs in other projects.

## Directory Structure

```
templates/
├── INDEX.md                           # This file
├── bitbucket-pipelines-jira.yml      # Bitbucket Pipelines config for Jira integration
├── JIRA_INTEGRATION_SETUP.md         # Documentation for setting up Jira integration
└── github-workflows/                  # GitHub Actions workflow templates
    ├── sync-tasks-to-issues.yml      # GitHub Issues integration (default)
    ├── sync-tasks-to-jira.yml        # GitHub to Jira sync
    ├── sync-jira-to-git.yml          # Jira to Git sync (bidirectional)
    └── sync-tasks-to-jira-github.yml # Alternative Jira sync workflow
```

## How Templates Are Used

When you run `work/scripts/setup.sh` in a new project:

1. **Platform Selection**: The setup script asks which platform you're using
2. **Template Copying**: Based on your selection, appropriate templates are copied:
   - **GitHub with Issues**: Copies `sync-tasks-to-issues.yml` to `.github/workflows/`
   - **GitHub with Jira**: Copies Jira sync workflows to `.github/workflows/`
   - **Bitbucket with Jira**: Copies `bitbucket-pipelines-jira.yml` to project root

## For 5daydocs Development

**Important**: The 5daydocs repository itself uses GitHub Issues, so only `sync-tasks-to-issues.yml` is active in `.github/workflows/`. All other workflows remain as templates here.

### Making Changes to Workflows

1. **For the 5daydocs repo itself**: Edit `.github/workflows/sync-tasks-to-issues.yml`
2. **For templates**: Edit files in this `templates/` directory
3. **Keep in sync**: If you update the active workflow, also update its template version

### Adding New Platform Support

To add support for a new platform (e.g., GitLab):

1. Create workflow templates in `templates/gitlab-workflows/` (or appropriate directory)
2. Update `work/scripts/setup.sh` to:
   - Add the new platform option
   - Copy the appropriate templates during setup
3. Document the integration setup requirements

## Template Guidelines

- All templates should be tested and working before committing
- Include clear comments in workflow files about required secrets/configuration
- Document any platform-specific requirements in separate `.md` files
- Use clear, descriptive filenames that indicate the platform and purpose