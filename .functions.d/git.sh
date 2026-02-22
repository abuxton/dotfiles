#!/usr/bin/env bash
# Common git helper functions
# POSIX-compatible shell functions for git operations

# Get the current branch name
git_current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached"
}

# Get recently checked out branches
git_recent_branches() {
  git reflog show --pretty=format:"%gs" --all | \
    grep "checkout: moving from" | \
    sed 's/checkout: moving from \(.*\) to.*/\1/' | \
    head -5
}

# Show git status in short format
git_status() {
  git status --short "$@"
}

# Get the root directory of the git repository
git_root() {
  git rev-parse --show-toplevel
}

# Stash changes with a timestamped message
git_stash_timestamp() {
  git stash push -m "stash-$(date +%s)" "$@"
}
