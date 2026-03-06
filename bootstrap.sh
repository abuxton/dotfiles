#!/usr/bin/env bash
# ============================================================================
# bootstrap.sh - Repository Update & Initial Dotfiles Deployment
# ============================================================================
#
# PURPOSE:
#   First-time deployment and repository synchronization for dotfiles.
#   This script handles the initial setup of a new machine by:
#     0. Checking/installing Xcode Command Line Tools (prerequisite for git)
#     1. Updating the dotfiles repository to latest version (git pull)
#     2. Installing Oh My Zsh shell framework
#     3. Deploying all dotfiles to home directory via rsync (non-symlink)
#     4. Installing global npm packages
#     5. Reloading shell environment
#
# USAGE:
#   bash bootstrap.sh                 # Run with confirmation prompt
#   bash bootstrap.sh --force         # Run without confirmation
#   bash bootstrap.sh -f              # Alias for --force
#   bash bootstrap.sh --dry-run       # Preview what would happen
#   bash bootstrap.sh --help          # Show this help message
#
# RELATIONSHIP WITH setup.sh:
#   bootstrap.sh is the FIRST script to run (repo sync + initial deployment)
#   setup.sh is the SECOND script to run (symlinks + profiles + configuration)
#
#   Workflow: bootstrap.sh → setup.sh → manually add ~/.bash_secrets → restart shell
#
# RESPONSIBILITIES:
#   0. XCODE COMMAND LINE TOOLS (Step 0)
#      - Checks if CLT are installed (required for git/homebrew)
#      - Installs via softwareupdate if missing, or triggers GUI installer
#      - Accepts Xcode license if not yet agreed to
#      - Full responsibility: git is available before Step 1
#
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
#   │ Has dry-run mode        │ YES          │ YES          │
#   │ Safe for re-run         │ CAUTION      │ YES          │
#   │ Can overwrite files     │ YES          │ NO           │
#   └─────────────────────────┴──────────────┴──────────────┘
#
# ============================================================================

cd "$(dirname "${BASH_SOURCE}")";

# ============================================================================
# HELP FUNCTION
# ============================================================================

show_help() {
  cat <<'EOF'
Bootstrap Dotfiles - Initial Setup & Deployment

DESCRIPTION:
  First-time deployment and repository synchronization for dotfiles.
  Handles git pull, oh-my-zsh installation, rsync deployment, and npm globals.

USAGE:
  bash bootstrap.sh [OPTIONS]

OPTIONS:
  --help           Show this help message and exit
  --dry-run        Preview what would be deployed without making changes
  --force, -f      Run without interactive confirmation prompt
  (default)        Run with confirmation prompt

WORKFLOW:
  1. bash bootstrap.sh --dry-run      # Preview changes first
  2. bash bootstrap.sh                # Run with confirmation
  3. bash setup.sh                    # Create symlinks & profiles
  4. Edit ~/.bash_secrets             # Add your secrets
  5. Restart shell                    # Profiles load

WHAT GETS DEPLOYED:
  ✓ All dotfiles (.bash_profile, .zshrc, .aliases, etc.)
  ✓ All profiles (.*_profile files - python, ruby, aws, etc.)
  ✓ All config files (.gitconfig, .curlrc, etc.)
  ✓ Supporting scripts (brew.sh, etc.)
  ✗ EXCLUDED: .git, .DS_Store, *.md files, bootstrap.sh itself

CAUTION:
  This script OVERWRITES existing files in your home directory.
  Always review with --dry-run before running without --force.
  Files are NOT backed up by this script (setup.sh does backups).

AFTER RUNNING:
  Run: bash setup.sh
  This creates symlinks and enables proper dotfile management.

SEE ALSO:
  - docs/DEPLOYMENT_WORKFLOW.md  (decision guide)
  - docs/DEPLOYMENT_REFERENCE.md (technical reference)
  - bootstrap.sh source code      (detailed documentation)
EOF
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      show_help
      exit 0
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --force|-f)
      FORCE=true
      shift
      ;;
    *)
      echo "❌ Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

cd "$(dirname "${BASH_SOURCE}")";

# Print mode indicator
if [ "$DRY_RUN" = true ]; then
  echo "⚠️  [DRY RUN MODE] - Previewing changes only, no files will be modified"
fi

# Step 0: Check Xcode Command Line Tools
# Git (used in Step 1) requires CLT; install before attempting git pull.
echo ""
echo "🛠️  Step 0: Checking Xcode Command Line Tools..."
if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then
  echo "   Xcode Command Line Tools not found - installing..."
  if [ "$DRY_RUN" = true ]; then
    echo "   [DRY RUN] Would install Xcode Command Line Tools via softwareupdate"
  else
    CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    sudo touch "$CLT_PLACEHOLDER"
    CLT_PACKAGE=$(softwareupdate -l 2>&1 \
      | grep -B 1 "Command Line Tools" \
      | awk -F"*" '/^ *\*/ {print $2}' \
      | sed -e 's/^ *Label: //' -e 's/^ *//' \
      | sort -V \
      | tail -n1)
    if [ -n "$CLT_PACKAGE" ]; then
      sudo softwareupdate -i "$CLT_PACKAGE"
      sudo rm -f "$CLT_PLACEHOLDER"
      # Accept Xcode license if prompted
      if /usr/bin/xcrun clang 2>&1 | grep -q license; then
        sudo xcodebuild -license accept
      fi
      echo "   ✓ Xcode Command Line Tools installed"
    else
      sudo rm -f "$CLT_PLACEHOLDER"
      echo "   Launching GUI installer - complete it then re-run bootstrap.sh"
      xcode-select --install
      exit 1
    fi
  fi
else
  echo "   ✓ Xcode Command Line Tools already installed"
fi

# Step 1: Update repository to latest version
echo ""
echo "📦 Step 1: Updating dotfiles repository..."
if [ "$DRY_RUN" = true ]; then
  echo "   [DRY RUN] Would run: git pull origin main"
else
  git pull origin main;
fi

# Step 2: Deploy dotfiles via rsync
# Non-idempotent: copies/overwrites files rather than symlinking
# After bootstrap, setup.sh will create symlinks pointing back to repo

echo "📂 Step 2: Deploying dotfiles..."
function doIt() {
	echo "   Running rsync deployment..."
	if [ "$DRY_RUN" = true ]; then
	  echo "   [DRY RUN] Would deploy files via rsync (excluding .git, .DS_Store, *.md, etc.)"
	  echo "   [DRY RUN] Would source ~/.zshrc to reload environment"
	else
	  rsync --exclude ".git/" \
	    --exclude ".gitignore" \
	    --exclude ".github/" \
      --exclude ".vscode/" \
	    --exclude "docs/" \
	    --exclude "scripts/" \
		  --exclude "common/" \
		  --exclude ".claude/" \
		  --exclude ".openai/" \
		  --exclude ".opencode/" \
		  --exclude "openspec/" \
		  --exclude ".dependabot/" \
	    --exclude ".DS_Store" \
	    --exclude ".osx" \
		  --exclude "assets/" \
		  --exclude "*.sh" \
		  --exclude "README.md" \
		  --exclude "LICENSE*" \
			--exclude "agents" \
		  --exclude "*.md" \
		  --exclude "*_profile" \
		  -avh --no-perms . ~;
	  # Reload shell environment to activate new dotfiles and profiles
	  source ~/.zshrc;
	fi
}

# Step 3: Install Oh My Zsh shell framework
# Only runs if oh-my-zsh is not already installed
# Provides shell framework, theme infrastructure, plugin system

echo "🔧 Step 3: Setting up Oh My Zsh..."
function makeItHappen () {
  if [ "$DRY_RUN" = true ]; then
    echo "   [DRY RUN] Would install oh-my-zsh via: curl | sh"
  else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
}

# Step 4: Install global npm packages
# Checks if package already exists before installing (idempotent)
# add-gitignore: Create .gitignore files from github/gitignore repo

echo "📦 Step 4: Installing global npm packages..."
function nodeKnows(){
  if [ "$DRY_RUN" = true ]; then
    echo "   [DRY RUN] Would check for: add-gitignore"
    echo "   [DRY RUN] Would run: npm i -g add-gitignore (if needed)"
  else
    if ! [ -x "$(command -v add-gitignore)" ]; then
      cd $HOME && npm i -g add-gitignore  #https://github.com/TejasQ/add-gitignore
    else
      echo "   ✓ add-gitignore already installed"
    fi
  fi
}

# Step 5: Execute deployment
# With --force or -f flag: skip confirmation
# Otherwise: prompt user for confirmation

echo ""
if [ "$DRY_RUN" = true ]; then
  # In dry-run mode, always execute (no confirmation needed)
  echo "Executing deployment preview..."
  makeItHappen;
  doIt;
  nodeKnows;
  echo ""
  echo "✓ DRY RUN COMPLETE - No changes were made"
  echo "To apply these changes, run: bash bootstrap.sh"
elif [ "$FORCE" = true ]; then
  # Force mode: skip confirmation
  echo "Executing deployment (force mode)..."
  makeItHappen;
  doIt;
  nodeKnows;
  echo ""
  echo "✓ Deployment complete! Next step: bash setup.sh"
else
  # Interactive mode: ask for confirmation
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Execute: oh-my-zsh install → rsync deploy → npm globals
    makeItHappen;
    doIt;
    nodeKnows;
    echo ""
    echo "✓ Deployment complete! Next step: bash setup.sh"
  else
    echo "Deployment cancelled."
  fi;
fi;

# Cleanup: Remove function definitions from environment
unset doIt;
unset makeItHappen;
unset nodeKnows;
