# Templates

## Overview

This directory contains standardized templates for creating new project artifacts, such as features and tasks. These templates are used to ensure that all project documents follow a consistent format and include all necessary information.

## Asset Categories

The templates are organized into the following categories:

*   **[Bitbucket Pipelines Jira](./bitbucket-pipelines-jira.yml)**: A template for Bitbucket Pipelines configuration with Jira integration.
*   **[JIRA Integration Setup](./JIRA_INTEGRATION_SETUP.md)**: A template for documenting the setup of Jira integration.
*   **[State Template](./STATE.md.template)**: A template for the state management file.
*   **[Bug Template](./TEMPLATE-bug.md)**: A template for creating new bug reports.
*   **[Feature Template](./TEMPLATE-feature.md)**: A template for creating new feature documents.
*   **[Task Template](./TEMPLATE-task.md)**: A template for creating new task files.
*   **[GitHub Workflows](./github-workflows/)**: A directory containing templates for GitHub Actions workflows.

## Usage

Use these templates when creating new project artifacts to ensure consistency and completeness. Copy the relevant template and fill in the required information as described in the template.

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

1.  **Platform Selection**: The setup script asks which platform you're using
2.  **Template Copying**: Based on your selection, appropriate templates are copied:
    *   **GitHub with Issues**: Copies `./github-workflows/sync-tasks-to-issues.yml` to `.github/workflows/`
    *   **GitHub with Jira**: Copies Jira sync workflows to `.github/workflows/`
    *   **Bitbucket with Jira**: Copies `./bitbucket-pipelines-jira.yml` to project root

## For 5daydocs Development

**Important**: The 5daydocs repository itself uses GitHub Issues, so only `sync-tasks-to-issues.yml` is active in `.github/workflows/`. All other workflows remain as templates here.

### Making Changes to Workflows

1.  **For the 5daydocs repo itself**: Edit `./github-workflows/sync-tasks-to-issues.yml`
2.  **For templates**: Edit files in this `templates/` directory
3.  **Keep in sync**: If you update the active workflow, also update its template version

### Adding New Platform Support

To add support for a new platform (e.g., GitLab):

1.  Create workflow templates in `templates/gitlab-workflows/` (or appropriate directory)
2.  Update `work/scripts/setup.sh` to:
    *   Add the new platform option
    *   Copy the appropriate templates during setup
3.  Document the integration setup requirements

## Template Guidelines

- All templates should be tested and working before committing
- Include clear comments in workflow files about required secrets/configuration
- Document any platform-specific requirements in separate `.md` files
- Use clear, descriptive filenames that indicate the platform and purpose