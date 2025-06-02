#!/bin/bash

set -e

REPO="${GITHUB_REPOSITORY}"
AUTH="Authorization: token $GH_TOKEN"

echo "🔍 Checking branches in $REPO..."

# Get all branches
branches=$(curl -s -H "$AUTH" "https://api.github.com/repos/$REPO/branches" | jq -r '.[].name')

for branch in $branches; do
  # Skip protected branches
  if [[ "$branch" == "main" || "$branch" == "master" || "$branch" == "develop" ]]; then
    echo "⏭️  Skipping protected branch: $branch"
    continue
  fi

  # Get last commit date
  last_commit_date=$(curl -s -H "$AUTH" "https://api.github.com/repos/$REPO/commits/$branch" | jq -r '.commit.committer.date')
  branch_age=$(( ( $(date +%s) - $(date -d "$last_commit_date" +%s) ) / 86400 ))

  echo "📁 Branch: $branch | Last updated: $branch_age days ago"

  if [ "$branch_age" -gt 90 ]; then
    echo "🧹 Deleting branch: $branch (older than 90 days)"
    git push origin --delete "$branch"
  fi
done
