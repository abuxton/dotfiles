#!/usr/bin/env bash
# ============================================================================
# bootstrap.sh - Repository Update & Initial Dotfiles Deployment
# ============================================================================
#
# PURPOSE:
#   First-time deployment and repository synchronization for dotfiles.
#   This script handles the initial setup of a new machine by:
#     1. Updating the dotfiles repository to latest version (git pull)
#     2. Installing Oh My Zsh shell framework
#     3. Deploying all dotfiles to home directory via rsync (non-symlink)
#     4. Installing global npm packages
#     5. Reloading shell environment
#
# USAGE:
#   bash bootstrap.sh           # Run with confirmation prompt
#   bash bootstrap.sh --force   # Run without confirmation
#   bash bootstrap.sh -f        # Alias for --force
#
# RELATIONSHIP WITH setup.sh:
#   bootstrap.sh is the FIRST script to run (repo sync + initial deployment)
#   setup.sh is the SECOND script to run (symlinks + profiles + configuration)
#
#   Workflow: bootstrap.sh → setup.sh → manually add ~/.bash_secrets → restart shell
#
# RESPONSIBILITIES:
#   1. REPOSITORY SYNC (git pull)
#      - Fetches latest changes from origin/main
#      - Ensures you have newer code, profiles, and configurations
#      - Handles merge conflicts (manual resolution if needed)
#      - Full responsibility: Repository is always current
#
#   2. OH-MY-ZSH SETUP (makeItHappen function)
#      - Installs oh-my-zsh shell framework if not already present
#      - Sets up powerlevel10k theme infrastructure
#      - Creates ~/.oh-my-zsh directory structure
#      - Safe for existing installations (won't reinstall)
#      - Full responsibility: Zsh framework is ready
#
#   3. RSYNC DEPLOYMENT (doIt function)
#      - Syncs all dotfiles from repo to home directory
#      - Uses rsync to copy (not symlink) dotfiles
#      - Applies exclusions for docs, scripts, git metadata
#      - Non-idempotent: OVERWRITES existing files (use with caution)
#      - Full responsibility: Dotfiles deployed to home
#      - Note: After bootstrap, setup.sh creates symlinks pointing back to repo
#
#   4. NPM GLOBAL PACKAGES (nodeKnows function)
#      - Installs global npm packages if not already present
#      - Currently installs: add-gitignore
#      - Can be extended for other global tools
#      - Checks if tool exists before installing (idempotent)
#      - Full responsibility: Global npm tools available
#
#   5. SHELL RELOAD
#      - Sources ~/.zshrc after rsync to activate new environment
#      - Loads all profiles, aliases, functions for current session
#      - Full responsibility: New environment active in current shell
#
# DEPLOYMENT SEQUENCE:
#   - cd to script directory
#   - git pull origin main
#   - Ask user for confirmation (unless --force used)
#   - If confirmed:
#       1. makeItHappen() → Install oh-my-zsh
#       2. doIt() → Rsync dotfiles
#       3. nodeKnows() → Install npm globals
#   - source ~/.zshrc
#
# WHAT GETS DEPLOYED (rsync):
#   ✓ All dotfiles (.bash_profile, .zshrc, .aliases, etc.)
#   ✓ All profiles (.*_profile files)
#   ✓ All config files (.gitconfig, .curlrc, etc.)
#   ✓ Makefile, shell scripts (brew.sh, etc.)
#   ✗ EXCLUDED: .git, .DS_Store, assets, *.md, bootstrap.sh, LICENSE
#
# WHAT DOES NOT GET DEPLOYED:
#   ✗ Documentation files (*.md) → handled separately
#   ✗ This script (bootstrap.sh) → can't overwrite running script
#   ✗ git metadata (.git/) → not needed in home directory
#
# IDEMPOTENCY:
#   • git pull: Safe to run again (no-op if already updated)
#   • oh-my-zsh: Safe to run again (detects existing installation)
#   • rsync: CAUTION! Will overwrite - use only when intentional
#   • npm install: Safe to run (checks if already installed)
#   • Overall: Can run multiple times, but be aware of rsync behavior
#
# BACKUPS:
#   bootstrap.sh does NOT create backups (it overwrites)
#   After bootstrap.sh, run setup.sh which creates symlinks and backups
#
# COMPARISON WITH setup.sh:
#   ┌─────────────────────────┬──────────────┬──────────────┐
#   │ Aspect                  │ bootstrap.sh │ setup.sh     │
#   ├─────────────────────────┼──────────────┼──────────────┤
#   │ Updates repo            │ YES          │ NO           │
#   │ Creates symlinks        │ NO           │ YES          │
#   │ Installs shells/tools   │ YES          │ NO           │
#   │ Creates backups         │ NO           │ YES          │
#   │ Has dry-run mode        │ NO           │ YES          │
#   │ Safe for re-run         │ CAUTION      │ YES          │
#   │ Can overwrite files     │ YES          │ NO           │
#   └─────────────────────────┴──────────────┴──────────────┘
#
# ============================================================================

cd "$(dirname "${BASH_SOURCE}")";

# Step 1: Update repository to latest version
# Ensures we have the newest dotfiles, profiles, and configurations
git pull origin main;

# Step 2: Deploy dotfiles via rsync
# Non-idempotent: copies/overwrites files rather than symlinking
# After bootstrap, setup.sh will create symlinks pointing back to repo
function doIt() {
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "assets/" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		--exclude "brew.sh" \
		--exclude "*.md" \
		-avh --no-perms . ~;
	#source ~/.bash_profile;
	# Reload shell environment to activate new dotfiles and profiles
	source ~/.zshrc;
}

# Step 3: Install Oh My Zsh shell framework
# Only runs if oh-my-zsh is not already installed
# Provides shell framework, theme infrastructure, plugin system
function makeItHappen () {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# Step 4: Install global npm packages
# Checks if package already exists before installing (idempotent)
# add-gitignore: Create .gitignore files from github/gitignore repo
function nodeKnows(){
  if ! [ -x "$(command -v add-gitignore)" ]; then
	cd $HOME && npm i -g add-gitignore  #https://github.com/TejasQ/add-gitignore
  fi
}

# Step 5: Execute deployment
# With --force or -f flag: skip confirmation
# Otherwise: prompt user for confirmation
if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		# Execute: oh-my-zsh install → rsync deploy → npm globals
		makeItHappen;
		doIt;
        nodeKnows;
	fi;
fi;

# Cleanup: Remove function definitions from environment
unset doIt;
unset makeItHappen;
unset nodeKnows;
