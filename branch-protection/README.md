# Automating Branch Protection Rules with GitHub Actions

This guide explains how to use GitHub Actions to automate the setup of branch protection rules across repositories using the GitHub REST API.

---

## Prerequisites

1. **GitHub Personal Access Token (PAT):**

   * Generate a Personal Access Token from your GitHub account with the following scopes:

     * `repo` (for private repositories)
     * `admin:repo_hook` (for managing hooks and settings)
   * [Generate your PAT here](https://github.com/settings/tokens).

2. **Store the PAT as a Secret:**

   * Navigate to your repository on GitHub.
   * Go to **Settings > Secrets and variables > Actions**.
   * Add a new secret named `GH_TOKEN` and paste your PAT.

---

## Steps to Set Up the Workflow

### 1. Create a Workflow File

Create a new file named `.github/workflows/branch-protection.yml` in your repository with the following content:

```yaml
name: Set Branch Protection Rules

on:
  workflow_dispatch: # Allows you to trigger the workflow manually

jobs:
  set-branch-protection:
    runs-on: ubuntu-latest

    steps:
    - name: Set branch protection rules
      env:
        GH_TOKEN: ${{ secrets.GH_TOKEN }}
      run: |
        REPO_NAME="owner/repository-name" # Replace with the actual owner and repository
        BRANCH="main" # Replace with the branch you want to protect

        curl -X PUT \
          -H "Authorization: token $GH_TOKEN" \
          -H "Accept: application/vnd.github.v3+json" \
          https://api.github.com/repos/$REPO_NAME/branches/$BRANCH/protection \
          -d '{
            "required_status_checks": {
              "strict": true,
              "contexts": []
            },
            "enforce_admins": true,
            "required_pull_request_reviews": {
              "dismissal_restrictions": {},
              "dismiss_stale_reviews": true,
              "require_code_owner_reviews": true,
              "required_approving_review_count": 1
            },
            "restrictions": null
          }'
```

### 2. Customize the Workflow

* **`REPO_NAME`**: Replace `owner/repository-name` with your repository's owner and name.
* **`BRANCH`**: Specify the branch you want to protect (e.g., `main`).
* Adjust the payload in the `-d` option to match your branch protection requirements.

### 3. Trigger the Workflow

1. Go to the **Actions** tab in your repository.
2. Select the `Set Branch Protection Rules` workflow.
3. Click **Run workflow** and provide any required inputs (if applicable).

---

## Applying Rules Across Multiple Repositories

To apply the same branch protection rules to multiple repositories:

1. Replace the `REPO_NAME` with a loop in the script:

```bash
REPOS=("owner/repo1" "owner/repo2" "owner/repo3")
BRANCH="main"

for REPO in "${REPOS[@]}"; do
  curl -X PUT \
    -H "Authorization: token $GH_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$REPO/branches/$BRANCH/protection \
    -d '{
      "required_status_checks": {
        "strict": true,
        "contexts": []
      },
      "enforce_admins": true,
      "required_pull_request_reviews": {
        "dismissal_restrictions": {},
        "dismiss_stale_reviews": true,
        "require_code_owner_reviews": true,
        "required_approving_review_count": 1
      },
      "restrictions": null
    }'
done
```

2. Update the list of repositories in `REPOS` to include all the repositories you want to configure.

---

## Notes

* Ensure that the Personal Access Token has the necessary permissions to manage branch protections.
* Use this workflow responsibly, especially in large organizations, to avoid unintentional changes to critical repositories.

For further customization, refer to the [GitHub REST API documentation for branch protection](https://docs.github.com/en/rest/branches/branch-protection).
