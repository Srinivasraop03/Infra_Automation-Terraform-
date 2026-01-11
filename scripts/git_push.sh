#!/bin/bash

# Check if a commit message was provided
if [ -z "$1" ]; then
  echo "Error: No commit message provided."
  echo "Usage: $0 \"your commit message\""
  exit 1
fi

# Navigate to the root of the git repository to ensure commands run for the whole project
GIT_ROOT=$(git rev-parse --show-toplevel)
if [ -z "$GIT_ROOT" ]; then
    echo "Error: Not in a git repository."
    exit 1
fi
cd "$GIT_ROOT"

echo "1. Adding all changes from project root..."
git add .

echo "2. Committing with message: \"$1\"..."
git commit -m "$1"

echo "3. Pushing to origin main..."
git push origin main

echo "Done! Code successfully pushed to GitHub."
