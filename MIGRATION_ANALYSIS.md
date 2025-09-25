To integrate the 5DayDocs repository into an existing project, the primary approach involves using the provided `setup.sh` script, followed by careful manual adjustments to avoid conflicts and customize the setup to your project's needs.

### 1. Initial Setup using `setup.sh`

The `setup.sh` script is the recommended starting point. It automates the copying of core 5DayDocs components. You should run this script from the *5DayDocs source repository*, providing the path to your *existing project* as the target.

**Steps:**
1.  **Clone 5DayDocs (if you haven't already):**
    ```bash
    git clone https://github.com/5daydocs/5daydocs.git
    cd 5daydocs
    ```
2.  **Make `setup.sh` executable:**
    ```bash
    chmod +x setup.sh
    ```
3.  **Run `setup.sh` and specify your existing project path:**
    ```bash
    ./setup.sh
    ```
    When prompted, enter the absolute or relative path to your existing repository (e.g., `/Users/yourname/myexistingproject`). The script will then:
    *   Create the `docs/`, `work/`, and `.github/workflows` directory structures.
    *   Copy `DOCUMENTATION.md` to your project root.
    *   Copy `5day.sh` and `5d` (the command-line interfaces) to your project root and make them executable.
    *   Copy `CLAUDE.md` to your project root for AI assistant configuration.
    *   Create `work/.platform-config` to store the user's platform choice (GitHub, Jira, or Bitbucket with Jira).
    *   Copy automation scripts (e.g., `create-task.sh`, `create-feature.sh`, `check-alignment.sh`) to `work/scripts/`.
    *   Copy template files (e.g., `docs/organizational-process-assets/templates/TEMPLATE-task.md`, `docs/organizational-process-assets/templates/TEMPLATE-feature.md`) to their respective `work/` and `docs/` subdirectories.
    *   Copy GitHub issue and pull request templates (`bug_report.md`, `feature_request.md`, etc.) into the `.github/` directory.
    *   Offer to add recommended `.gitignore` entries, with an option to append to an existing `.gitignore` file.
    *   Copy relevant GitHub Actions workflows to `.github/workflows/` based on your platform selection (GitHub Issues or GitHub with Jira).

### 2. Handling Potential Conflicts and Customizations

While `setup.sh` handles many aspects, you'll need to manually address certain areas to ensure 5DayDocs coexists harmoniously with your existing project.

#### a. `README.md` Integration

*   **Issue**: Your existing repository likely has its own `README.md`. The `setup.sh` script is designed to *not* overwrite an existing `README.md` but instead creates a basic one if none exists. If you already have a `README.md`, the script will preserve your version.
*   **Modification**: You should manually integrate the "Quick Start" and "Project Structure" sections from the 5DayDocs `README.md` (found in the 5DayDocs source repository) into your existing project's `README.md`. This will provide users of your existing project with information on how to use 5DayDocs within that context.

#### b. CI/CD Workflows (`.github/workflows/`, `bitbucket-pipelines.yml`)

*   **Issue**: If your existing repository already uses GitHub Actions or Bitbucket Pipelines, the 5DayDocs workflow files might conflict or require integration with your existing CI/CD setup.
*   **Modification**:
    *   **GitHub Actions**: The `setup.sh` script copies `docs/organizational-process-assets/templates/github-workflows/sync-tasks-to-issues.yml` (for GitHub Issues) or `docs/organizational-process-assets/templates/github-workflows/sync-tasks-to-jira.yml` and `docs/organizational-process-assets/templates/github-workflows/sync-jira-to-git.yml` (for GitHub with Jira) into your `.github/workflows/` directory. Review these files and ensure they don't conflict with any existing workflows. You might need to merge their functionalities or adjust trigger conditions (`on: push`, `on: pull_request`).
    *   **Bitbucket Pipelines**: The current 5DayDocs repository has templates for Bitbucket Pipelines (`templates/bitbucket-pipelines.yml`), but the `setup.sh` script's integration for Bitbucket/Jira is marked as "coming soon." If you use Bitbucket, you will likely need to manually adapt and integrate the relevant sections from the Bitbucket Pipeline templates into your existing `bitbucket-pipelines.yml` file.

#### c. Adjusting Paths and Customization

*   **Issue**: The 5DayDocs structure assumes `docs/` and `work/` directories are at the project root. If your existing project has conflicting directory names or you prefer a different organization (e.g., `project-docs/` instead of `docs/`), you'll need to adjust paths.
*   **Modification**: This is the most involved customization. You would need to:
    1.  **Rename directories**: Manually rename `docs/` to `project-docs/` (or your preferred name) and `work/` to `project-work/` (or your preferred name) in your existing repository.
    2.  **Modify scripts**: Update all references to `docs/` and `work/` within `5day.sh`, `work/scripts/create-task.sh`, `work/scripts/create-feature.sh`, and `work/scripts/check-alignment.sh` to reflect the new paths. This would involve searching for `/docs/` and `/work/` and replacing them with your custom paths. For example, if you renamed `docs/` to `project-docs/`, you would change `docs/features/` to `project-docs/features/`.
    3.  **Update `DOCUMENTATION.md`**: Ensure any path references within `DOCUMENTATION.md` are updated to reflect your custom directory structure.

#### d. Initial Task and Bug IDs (`work/STATE.md`)

*   **Issue**: If your existing project already has a task or bug tracking system, the initial `5DAY_TASK_ID` and `5DAY_BUG_ID` in the newly created `work/STATE.md` might start from 0, potentially conflicting with existing IDs.
*   **Modification**: The `setup.sh` script is designed to preserve existing ID values in `work/STATE.md` during updates. Manual editing is primarily for the initial setup in a project with pre-existing IDs. After running `setup.sh` for the first time, manually edit `work/STATE.md` in your existing repository. Set `5DAY_TASK_ID` and `5DAY_BUG_ID` to a value higher than any existing task or bug IDs in your project to prevent future conflicts. For example, if your highest existing task ID is 100, set `5DAY_TASK_ID: 100`.

#### e. `.gitignore` Integration

*   **Issue**: Your existing repository likely has its own `.gitignore` file.
*   **Modification**: The `setup.sh` script provides an option to append 5DayDocs' recommended `.gitignore` entries to your existing file, checking for duplicates. This is the safest approach. If you choose not to use the script's option, you should manually add the relevant entries from the 5DayDocs `.gitignore` (especially those related to `work/data/` and `work/designs/`) to your project's `.gitignore` to prevent unnecessary files from being committed.

### 3. Ongoing Usage and Maintenance

Once integrated, 5DayDocs operates as a set of conventions and scripts within your repository. Regular usage will involve:

*   **Using `5day.sh`**: The `5day.sh` script is the primary interface for creating tasks and features, acting as a wrapper for the scripts located in `work/scripts/`. Execute `./5day.sh newtask "Description"` or `./5day.sh newfeature "Name"` from your project root to manage tasks and features.
*   **Git Workflow**: Continue using your standard Git workflow. The 5DayDocs system is designed to be Git-friendly, with tasks and features being plain markdown files that are version-controlled.
*   **Documentation**: Maintain feature documentation in `docs/features/` and technical guides in `docs/guides/`.
*   **Updates**: If the 5DayDocs project itself receives updates, you can re-run the `setup.sh` script from the *source* 5DayDocs repository, pointing it to your existing project. The script is designed to handle updates by preserving existing `STATE.md` values and offering to update other files.

### Conclusion

Integrating 5DayDocs into an existing repository is primarily achieved by running the `setup.sh` script from the 5DayDocs source, targeting your existing project. The key to a successful integration lies in carefully managing potential conflicts with existing `README.md` and CI/CD configurations, and making manual adjustments for initial ID values or custom directory paths if needed. The system's reliance on plain markdown files and shell scripts makes it highly portable and adaptable to various project environments.