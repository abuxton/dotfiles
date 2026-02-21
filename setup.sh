#!/usr/bin/env bash
# Setup prerequisites for dotfiles installation

set -e

echo "Setting up dotfiles environment..."

# Ensure zsh is available
if ! command -v zsh &>/dev/null; then
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y zsh
    elif command -v brew &>/dev/null; then
        brew install zsh
    else
        echo "Cannot install zsh: no supported package manager found" >&2
        exit 1
    fi
    echo "zsh installed: $(zsh --version)"
else
    echo "zsh already available: $(zsh --version)"
fi

echo "Setup complete"
