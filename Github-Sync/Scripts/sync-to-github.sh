# This script performs a one-way sync from Azure DevOps to GitHub. It will only write new files and changes to existing files.
# Files that have been moved or deleted will not sync. Reconciliation of deleted files will need to occur manually within the GitHub repository.
# - Files that have been moved will be duplicated in the GitHub repository, the new location will synchronize, but it will not be removed from the original location.
# - Since this pipeline uses a Azure DevOps service connection linked to a GitHub Fine-grained PAT, it will not be able to delete files in the GitHub repository.
# 
# Additionally, this pipeline ignores any files in the 'WIP' folder within Azure DevOps. This is intentional since this folder is treated as a staging area for files that are not ready to be synced to GitHub.
# - To remove this dependency, remove ':!WIP' from the git add command.
#
# Usage: sync-to-github.sh <gitUserEmail> <gitUserName> <github_token> <gitHubRepo> <gitHubBranch> <BuildSourceBranchName>
# 
# Arguments:
#   gitUserEmail: The email address to configure for Git
#   gitUserName: The username to configure for Git
#   github_token: The GitHub token for authentication
#   gitHubRepo: The GitHub repository to sync to
#   gitHubBranch: The branch within the GitHub repository to sync to
#   BuildSourceBranchName: The source branch name from Azure DevOps
# 
# Author: Marcus Jacobson
# Version: 1.0.0
# Last Updated: February 15, 2025

#!/bin/bash

# Check if the correct number of arguments are provided
git config --global user.email "$1"
git config --global user.name "$2"
git config --global pull.rebase true

# Add the GitHub remote repository using the provided token and repository name, then fetch it
git remote add github https://$3@github.com/$4.git
git fetch github

# Create and checkout the branch if it doesn't exist, otherwise checkout the existing branch
git checkout -b $5 || git checkout $5 

# Stash any unstaged changes
git stash push -m "Stash before pull"

# Pull the latest changes from the GitHub branch, rebase, and resolve conflicts by favoring the Azure DevOps version
git pull github $5 --rebase || { 
  echo 'Merge conflict detected'; 
  echo 'Conflicted files:';
  git diff --name-only --diff-filter=U;
  
  # Resolve conflicts by favoring the Azure DevOps version for all files
  for file in $(git diff --name-only --diff-filter=U); do
    git checkout --theirs $file
    git add $file
  done
  GIT_EDITOR=true git rebase --continue || git rebase --skip
}

# Verify if there are still conflicts and exit if conflicts are not resolved
if git diff --name-only --diff-filter=U | grep -q 'Github-Sync/Pipeline/github-sync.yml'; then
  echo 'Conflict resolution failed for Github-Sync/Pipeline/github-sync.yml'
  exit 1
fi

# Explicitly commit the latest version of all files from Azure DevOps, excluding the WIP folder
git add -A ':!WIP'
git commit -m "Ensure Azure DevOps version of all files, excluding WIP" || true

# Push the changes to the GitHub branch, forcing the push to ensure the GitHub branch matches the Azure DevOps branch
git push --force github $6:$5 || { echo 'Git push failed'; exit 1; }