#!/usr/bin/env bash
# Common system helper functions
# POSIX-compatible shell functions for system operations

# Make directory and cd into it
mkd() {
  mkdir -p "$@" && cd "$_" || return
}

# Remove .DS_Store files recursively
rm_dsstore() {
  find "${1:-.}" -type f -name ".DS_Store" -delete && echo "Removed .DS_Store files from ${1:-.}"
}

# List only directories
lsd() {
  ls -lhF "$@" | grep --color=never "^d"
}

# Show disk usage of directory in human-readable format
dus() {
  du -sh "$@" | sort -hr
}

# Find files by name (case-insensitive)
ff() {
  find . -iname "*$1*"
}

# Create a backup of a file
backup() {
  cp "$1" "$1.backup.$(date +%s)" && echo "Backup created: $1.backup.$(date +%s)"
}
