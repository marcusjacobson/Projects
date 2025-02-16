# GitHub Sync

**Author:** Marcus Jacobson  
**Version:** 1.0.0  
**Last Updated:** February 15, 2025

This project performs a one-way sync from Azure DevOps to GitHub using a pipeline and a script. It will only write new files and changes to existing files.

<span style="color:red">**Important** Files that have been moved will appear in both the original and new location, since the deletion from the original location will not take place since files that have been deleted will not sync. Reconciliation of deleted files will need to occur manually within the GitHub repository. </span>

## Prerequisites

### 1. Create a Fine-Grained Personal Access Token in GitHub

1. Go to your GitHub account settings.
2. Navigate to **Developer settings** > **Personal access tokens** > **Fine-grained tokens**.
3. Click on **Generate new token**.
4. Provide a name for the token and set an expiration date.
5. Under **Resource owner**, select your account.
6. Under **Repository access**, select the repositories you want to grant access to.
7. Under **Permissions**, grant the following permissions:
   - **Contents**: Read and write
   - **Metadata**: Read-only
8. Click **Generate token** and copy the token. You will need it for the Azure DevOps service connection.

### 2. Link the Token to an Azure DevOps Service Connection

1. Go to your Azure DevOps project.
2. Navigate to **Project settings** > **Service connections**.
3. Click on **New service connection** and select **GitHub**.
4. Choose **Personal Access Token** and click **Next**.
5. Provide a name for the service connection.
6. Paste the Fine-Grained Personal Access Token you generated in GitHub.
7. Click **Verify and save**.

### 3. Create a New Repository in GitHub and Perform Initial Check-In

1. Go to your GitHub account.
2. Click on the **+** icon in the top right corner and select **New repository**.
3. Provide a name for your repository and fill in the other required fields.
4. Click **Create repository**.
5. Follow the instructions to clone the repository to your local machine.
6. Open the cloned repository in VSCode.
7. Add a README file or any initial files you want to include.
8. In VSCode, go to the **Source Control** view.
9. You should see the new files listed under **Changes**.
10. Select the files and click the **+** icon to stage the changes.
11. Enter a commit message, such as "Initial commit", and click the **✔** icon to commit the changes.
12. Click the **...** icon in the Source Control view and select **Push** to push the changes to GitHub.

### 4. Initialize the Local Repository and Configure Git

1. Open a terminal in the root directory of your local repository.
2. Initialize the local repository:

    ```sh
    git init
    ```

3. Configure your Git user name and email:

    ```sh
    git config user.name "Your Name"
    git config user.email "your.email@example.com"
    ```

## Pipeline and Script Interaction

### Pipeline

The pipeline is defined in [github-sync.yml](Pipeline/github-sync.yml). It triggers on changes to the main branch and runs the `sync-to-github.sh` script to perform the sync operation.

Key steps in the pipeline:

- Checkout the repository.
- Create a GitHub release.
- Run the `sync-to-github.sh` script.

### Script

The script is defined in [sync-to-github.sh](Scripts/sync-to-github.sh). It configures Git, fetches the GitHub repository, handles conflicts, and pushes changes to GitHub.

Key steps in the script:

- Configure Git user email and name.
- Add the GitHub remote repository.
- Checkout the branch.
- Stash any unstaged changes.
- Pull the latest changes and resolve conflicts.
- Commit and push changes to GitHub.

## Usage

### Adding Files to Azure DevOps

#### Method 1: If you already have the repo cloned locally

1. Open your local repository in VSCode.
2. Copy the **Github-Sync** folder and it's contents to the appropriate directory in your local repository.
3. In VSCode, go to the **Source Control** view.
4. You should see the copied files listed under **Changes**.
5. Select the files and click the **+** icon to stage the changes.
6. Enter a commit message, such as "Add GitHub Sync pipeline and script", and click the **✔** icon to commit the changes.
7. Click the **...** icon in the Source Control view and select **Push** to push the changes to Azure DevOps.

#### Method 2: Upload the entirety of the GitHub-Sync folder within the Azure DevOps site

1. Go to your Azure DevOps project.
2. Navigate to **Repos** > **Files**.
3. Click on **Upload files**.
4. Select the entire `Github-Sync` folder from your local machine.
5. Commit the changes to the repository.

### Setting Up the Pipeline

1. Go to your Azure DevOps project.
2. Navigate to **Pipelines** > **Pipelines**.
3. Click on **New pipeline**.
4. Select **Azure Repos Git** as the source.
5. Select your repository.
6. Choose **Existing Azure Pipelines YAML file**.
7. Set the path to the `github-sync.yml` file (e.g., `/Pipeline/github-sync.yml`).
8. Click **Continue**.
9. Review the pipeline configuration and click **Run** to start the pipeline.

### Manual Script Usage

The script is automatically called as part of the pipeline. To manually run the script, use the following command and update the variable references:

```sh
./sync-to-github.sh <gitUserEmail> <gitUserName> <github_token> <gitHubRepo> <gitHubBranch> <BuildSourceBranchName>```