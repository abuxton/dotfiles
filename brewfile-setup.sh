#!/bin/bash

##
# brewfile-setup.sh - Homebrew Package Management
#
# Manages Homebrew package installations via Brewfile for reproducible system setup.
# Supports: installing all packages, adding/removing from Brewfile, listing installed.
#
# Usage:
#   source brewfile-setup.sh          # Load functions
#   brew_install_from_file            # Install all packages from Brewfile
#   brew_list_installed               # Show installed packages
#   brew_add_to_brewfile <package>    # Add package to Brewfile
#   brew_remove_from_brewfile <pkg>   # Remove package from Brewfile
#
# The Brewfile is sourced from: ~/dotfiles/Brewfile (or specify via BREWFILE env var)
#
# This script follows POSIX shell conventions for compatibility with both Bash and ZSH.
#

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

: "${BREW_HOME:=$HOME/.homebrew}"
: "${BREWFILE:=$BREW_HOME/Brewfile}"
: "${BREW_REPO_URL:=https://github.com/$(whoami)/homebrew-brewfile}"
: "${BREW_LOG_DIR:=$BREW_HOME/log}"
: "${BREW_LOG:=$BREW_LOG_DIR/brew.log}"
: "${DRY_RUN:=false}"

# Color codes for output (compatible with both sed and printf)
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
  printf "${BLUE}ℹ${NC}  %s\n" "$1"
}

log_success() {
  printf "${GREEN}✓${NC}  %s\n" "$1"
}

log_warn() {
  printf "${YELLOW}⚠${NC}  %s\n" "$1" >&2
}

log_error() {
  printf "${RED}✗${NC}  %s\n" "$1" >&2
}

# ============================================================================
# HELP FUNCTION
# ============================================================================

show_help() {
  cat <<'EOF'
Homebrew Package Manager Setup

DESCRIPTION:
  Manages Homebrew package installations via Brewfile for reproducible system setup.
  Install, list, add, and remove packages with easy Brewfile management.

USAGE:
  bash brewfile-setup.sh [OPTIONS]
  source brewfile-setup.sh
  brew_install_from_file [--dry-run]

OPTIONS:
  --help                Show this help message and exit
  --dry-run             Preview packages that would be installed without installing

COMMON FUNCTIONS:
  brew_initialize_home              Clone/update homebrew-brewfile repository
  brew_install_homebrew [silent]    Install Homebrew
  brew_install_from_file [--dry-run] Install all packages from Brewfile
  brew_list_installed               List currently installed packages
  brew_update_packages              Update all installed packages
  brew_add_to_brewfile <pkg>        Add package to Brewfile
  brew_remove_from_brewfile <pkg>   Remove package from Brewfile
  brew_generate_brewfile            Generate Brewfile from installed packages
  brew_show_brewfile                Display Brewfile contents
  brew_validate                     Check Homebrew installation
  brew_doctor                       Run Homebrew diagnostics

EXAMPLES:
  # First time setup:
  bash brewfile-setup.sh --help              # See this help
  source brewfile-setup.sh                   # Load functions
  brew_install_homebrew                     # Install Homebrew if needed
  brew_initialize_home                      # Clone homebrew-brewfile repo
  brew_install_from_file                    # Install packages

  # Preview packages before installing:
  brew_install_from_file --dry-run          # See what would be installed

  # Generate backup of current packages:
  brew_generate_brewfile                    # Creates timestamped backup

  # Add/remove packages:
  brew_add_to_brewfile git                  # Add to Brewfile
  brew_remove_from_brewfile git             # Remove from tracking

  # Update everything:
  brew_update_packages                      # Update all packages

SEE ALSO:
  - docs/DEPLOYMENT_WORKFLOW.md (dotfiles deployment guide)
  - https://brew.sh (Homebrew documentation)
  - https://github.com/Homebrew/homebrew-bundle (brew bundle)
EOF
}

# ============================================================================
# INITIALIZATION
# ============================================================================

##
# Initialize BREW_HOME by cloning homebrew-brewfile repository
# Creates $BREW_HOME directory and sets up log directory
# Returns: 0 on success, 1 on failure
#
brew_initialize_home() {
  # Create log directory if doesn't exist
  if [ ! -d "$BREW_LOG_DIR" ]; then
    mkdir -p "$BREW_LOG_DIR"
    log_success "Created log directory: $BREW_LOG_DIR"
  fi

  # Check if BREW_HOME already initialized
  if [ -f "$BREWFILE" ]; then
    log_success "BREW_HOME already initialized at: $BREW_HOME"
    return 0
  fi

  # Clone homebrew-brewfile repository
  if [ -d "$BREW_HOME/.git" ]; then
    log_info "homebrew-brewfile repository already cloned"
    log_info "Updating repository..."
    (cd "$BREW_HOME" && git pull) || log_warn "Failed to update repository"
    return 0
  fi

  # If BREW_HOME exists but isn't a git repo, back it up
  if [ -d "$BREW_HOME" ]; then
    local backup_dir="${BREW_HOME}.backup.$(date +%s)"
    log_warn "BREW_HOME exists but is not a git repository"
    log_info "Backing up to: $backup_dir"
    mv "$BREW_HOME" "$backup_dir"
  fi

  log_info "Cloning homebrew-brewfile repository..."
  if git clone "$BREW_REPO_URL" "$BREW_HOME"; then
    log_success "Cloned homebrew-brewfile to: $BREW_HOME"

    # Recreate log directory (it may have been cloned)
    mkdir -p "$BREW_LOG_DIR"
    log_success "Initialized BREW_HOME at: $BREW_HOME"
    return 0
  else
    log_error "Failed to clone homebrew-brewfile from: $BREW_REPO_URL"
    return 1
  fi
}

# ============================================================================
# HOMEBREW INSTALLATION
# ============================================================================

##
# Check if Homebrew is installed
# Returns: 0 if installed, 1 if not
#
brew_is_installed() {
  command -v brew >/dev/null 2>&1
}

##
# Install Homebrew (interactive or silent)
# Arguments:
#   $1 - optional: "silent" for non-interactive install
#
brew_install_homebrew() {
  if brew_is_installed; then
    log_success "Homebrew already installed at: $(command -v brew)"
    return 0
  fi

  log_info "Installing Homebrew..."

  if [ "${1:-}" = "silent" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if brew_is_installed; then
    log_success "Homebrew installed successfully"
    return 0
  else
    log_error "Failed to install Homebrew"
    return 1
  fi
}

##
# Validate Homebrew installation
# Returns: 0 if valid, 1 if not
#
brew_validate() {
  if ! brew_is_installed; then
    log_error "Homebrew not installed. Run: brew_install_homebrew"
    return 1
  fi

  # Check if Homebrew is functional
  if ! brew --version >/dev/null 2>&1; then
    log_error "Homebrew installed but not functional"
    return 1
  fi

  log_success "Homebrew is installed and functional"
  return 0
}

# ============================================================================
# BREWFILE MANAGEMENT
# ============================================================================

##
# Validate Brewfile exists and is readable
# Returns: 0 if valid, 1 if not
#
brew_brewfile_exists() {
  if [ ! -f "$BREWFILE" ]; then
    log_error "Brewfile not found at: $BREWFILE"
    return 1
  fi

  if [ ! -r "$BREWFILE" ]; then
    log_error "Brewfile not readable: $BREWFILE"
    return 1
  fi

  log_success "Brewfile found: $BREWFILE"
  return 0
}

##
# Show Brewfile contents with line numbers
#
brew_show_brewfile() {
  if ! brew_brewfile_exists; then
    return 1
  fi

  log_info "Contents of $BREWFILE:"
  cat -n "$BREWFILE"
}

##
# Count packages in Brewfile
# Returns: Number of packages (non-comment, non-empty lines)
#
brew_count_packages() {
  if ! brew_brewfile_exists; then
    echo 0
    return 1
  fi

  # Count non-comment, non-empty lines
  grep -v '^#' "$BREWFILE" | grep -v '^[[:space:]]*$' | wc -l
}

# ============================================================================
# PACKAGE INSTALLATION
# ============================================================================

##
# Install all packages from Brewfile
# Arguments:
#   $1 - optional: "--dry-run" to preview without installing
#
brew_install_from_file() {
  local dry_run=false

  # Check for --dry-run flag
  if [ "${1:-}" = "--dry-run" ]; then
    dry_run=true
  fi

  if ! brew_validate; then
    return 1
  fi

  if ! brew_brewfile_exists; then
    return 1
  fi

  local count
  count=$(brew_count_packages)

  if [ "$dry_run" = true ]; then
    log_info "[DRY RUN] Would install $count packages from Brewfile"
  else
    log_info "Installing $count packages from Brewfile..."
    log_info "This may take several minutes..."
  fi

  local packages
  packages=$(grep -v '^#' "$BREWFILE" | grep -v '^[[:space:]]*$' | tr '\n' ' ')

  if [ -z "$packages" ]; then
    log_warn "No packages found in Brewfile"
    return 1
  fi

  if [ "$dry_run" = true ]; then
    log_info "[DRY RUN] Packages that would be installed:"
    echo "$packages" | tr ' ' '\n' | sed 's/^/  - /'
    log_success "[DRY RUN] COMPLETE - No packages were installed"
    return 0
  fi

  # Install all packages (only if not dry-run)
  # shellcheck disable=SC2086
  if brew install $packages; then
    log_success "All packages installed successfully"
    return 0
  else
    log_warn "Some packages failed to install. Check output above."
    return 1
  fi
}

##
# Update all installed packages
#
brew_update_packages() {
  if ! brew_validate; then
    return 1
  fi

  log_info "Updating Homebrew..."
  brew update

  log_info "Upgrading installed packages..."
  brew upgrade

  log_success "Packages updated successfully"
}

##
# List currently installed packages
#
brew_list_installed() {
  if ! brew_validate; then
    return 1
  fi

  log_info "Installed Homebrew packages:"
  brew list --cask 2>/dev/null || true
  brew list 2>/dev/null || true
}

# ============================================================================
# BREWFILE EDITING
# ============================================================================

##
# Add package to Brewfile
# Arguments:
#   $1 - Package name
#
brew_add_to_brewfile() {
  local package="$1"

  if [ -z "$package" ]; then
    log_error "Usage: brew_add_to_brewfile <package-name>"
    return 1
  fi

  # Create Brewfile if doesn't exist
  if [ ! -f "$BREWFILE" ]; then
    mkdir -p "$(dirname "$BREWFILE")"
    {
      echo "# Homebrew Brewfile for macOS dotfiles"
      echo "# Managed by brewfile-setup.sh"
      echo ""
    } > "$BREWFILE"
    log_info "Created new Brewfile at: $BREWFILE"
  fi

  # Check if package already in Brewfile
  if grep -q "^${package}\$" "$BREWFILE" 2>/dev/null; then
    log_warn "Package already in Brewfile: $package"
    return 0
  fi

  # Add package to Brewfile
  echo "$package" >> "$BREWFILE"
  log_success "Added to Brewfile: $package"

  # Optionally install immediately
  if [ "${2:-}" = "install" ]; then
    brew install "$package"
  fi
}

##
# Remove package from Brewfile (doesn't uninstall)
# Arguments:
#   $1 - Package name
#
brew_remove_from_brewfile() {
  local package="$1"

  if [ -z "$package" ]; then
    log_error "Usage: brew_remove_from_brewfile <package-name>"
    return 1
  fi

  if ! brew_brewfile_exists; then
    return 1
  fi

  # Use sed to remove the line (compatible with both GNU and BSD sed)
  if grep -q "^${package}\$" "$BREWFILE" 2>/dev/null; then
    # Create backup
    cp "$BREWFILE" "$BREWFILE.bak"

    # Remove package (portable sed for both GNU and macOS/BSD)
    sed -i '' "/^${package}\$/d" "$BREWFILE"

    log_success "Removed from Brewfile: $package"
    log_info "Backup saved to: $BREWFILE.bak"
    return 0
  else
    log_warn "Package not found in Brewfile: $package"
    return 1
  fi
}

# ============================================================================
# CLEANUP & MAINTENANCE
# ============================================================================

##
# Clean up unused Homebrew packages (leaves formulae, removes dependents)
#
brew_cleanup() {
  if ! brew_validate; then
    return 1
  fi

  log_info "Cleaning up Homebrew..."
  brew cleanup
  log_success "Cleanup complete"
}

##
# Generate Brewfile from currently installed packages
# Uses 'brew bundle dump' if available, otherwise falls back to manual generation
# Creates: Brewfile.bck.TIMESTAMP (timestamped backup)
# Returns: 0 on success, 1 on failure
#
brew_generate_brewfile() {
  if ! brew_validate; then
    return 1
  fi

  # Ensure log directory exists
  mkdir -p "$BREW_LOG_DIR"

  local timestamp
  timestamp=$(date +%Y%m%d_%H%M%S)
  local output_file="$BREW_HOME/Brewfile.bck.$timestamp"

  log_info "Generating Brewfile from currently installed packages..."

  # Check if brew bundle is available
  if brew bundle --help >/dev/null 2>&1; then
    log_info "Using 'brew bundle dump' for Brewfile generation..."

    if brew bundle dump --file="$output_file" --force; then
      log_success "Generated Brewfile saved to: $output_file"
      log_info "Brewfile contains current system packages (via brew bundle dump)"
      return 0
    else
      log_warn "brew bundle dump failed, falling back to manual generation"
    fi
  else
    log_info "brew bundle not available, using manual generation"
  fi

  # Fallback: manual generation if brew bundle unavailable
  log_info "Generating Brewfile manually (brew bundle not available)..."
  {
    echo "# Auto-generated Brewfile (manual mode)"
    echo "# Generated: $(date)"
    echo ""
    echo "# Regular packages"
    brew list --formula 2>/dev/null || echo "# (no formula packages)"
    echo ""
    echo "# Cask applications"
    brew list --cask 2>/dev/null || echo "# (no cask packages)"
    echo ""
    echo "# Taps"
    brew tap 2>/dev/null | sed 's/^/tap /g' || echo "# (no taps)"
  } > "$output_file"

  log_success "Generated Brewfile saved to: $output_file"
  log_info "Review and copy to $BREWFILE if desired"
  return 0
}

# ============================================================================
# DIAGNOSTIC & INFORMATION
# ============================================================================

##
# Show Homebrew diagnostic information
#
brew_doctor() {
  if ! brew_validate; then
    return 1
  fi

  log_info "Running Homebrew doctor diagnostics..."
  brew doctor || true
}

##
# Show help for available functions
#
brew_help() {
  cat <<'EOF'
Homebrew Setup Functions

INSTALLATION:
  brew_install_homebrew [silent]    Install Homebrew (optional: silent mode)
  brew_validate                      Check if Homebrew is installed/functional

INITIALIZATION:
  brew_initialize_home               Clone/update homebrew-brewfile repository

BREWFILE MANAGEMENT:
  brew_show_brewfile                 Display Brewfile contents
  brew_brewfile_exists               Check if Brewfile exists
  brew_count_packages                Count packages in Brewfile
  brew_generate_brewfile             Generate Brewfile from installed packages (uses brew bundle dump)

PACKAGE MANAGEMENT:
  brew_install_from_file             Install all packages from Brewfile
  brew_list_installed                List currently installed packages
  brew_update_packages               Update all installed packages
  brew_add_to_brewfile <pkg>         Add package to Brewfile (optional: install)
  brew_remove_from_brewfile <pkg>    Remove package from Brewfile

MAINTENANCE:
  brew_cleanup                       Clean up unused packages
  brew_doctor                        Run Homebrew diagnostics

HELP:
  brew_help                          Show this message

EXAMPLES:
  # First time setup:
  source brewfile-setup.sh
  brew_initialize_home                # Clone homebrew-brewfile repo to ~/.homebrew
  brew_install_homebrew
  brew_install_from_file

  # Generate backup of current packages:
  brew_generate_brewfile              # Uses brew bundle dump (creates timestamped backup)

  # Add a new package:
  brew_add_to_brewfile git

  # Remove from tracking (but keep installed):
  brew_remove_from_brewfile git

  # Update all packages:
  brew_update_packages

  # Save changes to homebrew-brewfile repository:
  git -C $BREW_HOME add .
  git -C $BREW_HOME commit -m "Update: $(date)"
  git -C $BREW_HOME push
EOF
}

# ============================================================================
# ARGUMENT HANDLING
# ============================================================================

# If sourced with a command as first argument, execute it
if [ $# -gt 0 ]; then
  case "$1" in
    --help|-h)
      show_help
      ;;
    --dry-run)
      # Pass --dry-run to functions that support it
      # For now, just show help about how to use --dry-run
      show_help
      echo ""
      echo "Examples of --dry-run usage:"
      echo "  brew_install_from_file --dry-run    # Preview packages"
      ;;
    *)
      # Call function with remaining arguments
      "$@"
      ;;
  esac
fi
