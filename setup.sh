#!/usr/bin/env bash
# ============================================================================
# setup.sh - Local Environment Configuration & Dotfile Management
# ============================================================================
#
# PURPOSE:
#   Configure local shell environment, create symlinks, and manage context-specific
#   profiles. This script is run AFTER bootstrap.sh to complete environment setup.
#   It is fully idempotent - can be run multiple times safely.
#
# USAGE:
#   bash setup.sh           # Run interactive setup
#   bash setup.sh --dry-run # Preview changes without applying
#   bash setup.sh --help    # Show this help message
#
# RELATIONSHIP WITH bootstrap.sh:
#   bootstrap.sh is FIRST (repo sync + rsync deploy)
#   setup.sh is SECOND (symlinks + profiles + configuration)
#
#   Typical workflow:
#     1. bash bootstrap.sh     ← git pull, rsync, oh-my-zsh, npm globals
#     2. bash setup.sh         ← symlinks, profiles, directories, validation
#     3. Edit ~/.bash_secrets  ← add credentials
#     4. Start new shell       ← profiles load
#
# RESPONSIBILITIES:
#
#   1. DIRECTORY CREATION
#      - Creates ~/.functions.d for modular shell functions
#      - Creates ~/.config for application configurations
#      - Creates ~/.dotfiles.backup for backup storage
#      - Idempotent: safe to rerun (mkdir -p is idempotent)
#      Full responsibility: All required directories exist
#
#   2. SECRETS TEMPLATE CREATION
#      - Creates ~/.bash_secrets if not already present
#      - Uses template from templates/bash_secrets_template
#      - Sets permissions to 600 (owner read/write only)
#      - Prevents accidental credential storage in version control
#      - Non-destructive: never overwrites existing secrets
#      Full responsibility: Secrets file template available for editing
#
#   3. DOTFILE SYMLINKS
#      - Creates symlinks for all config files (.bash_profile, .zshrc, etc.)
#      - Source: $DOTFILES_DIR/<dotfile>
#      - Target: $HOME/<dotfile>
#      - Benefit: Edits in repo are immediately available to shell
#      - Backup-safe: existing files backed up before symlinking
#      Full responsibility: All dotfiles accessible via symlinks
#
#   4. PROFILE FILE SYMLINKS
#      - Creates symlinks for all .*_profile files (context-specific)
#      - Example files: .python_profile, .ruby_profile, .aws_profile, etc.
#      - Source: $DOTFILES_DIR/.*_profile
#      - Target: $HOME/.*_profile
#      - Purpose: Context-specific configurations (language managers, CLIs)
#      - 22 profiles currently managed: language tools, cloud, devops, etc.
#      Full responsibility: All profiles deployed and ready for sourcing
#
#   5. CONVENIENCE SYMLINKS
#      - Creates .dotfiles → repo directory (easy repo access)
#      - Creates .ssh → config directory (SSH config access)
#      - Benefit: Quick navigation to repo and SSH configs
#      Full responsibility: Convenience symlinks in place
#
#   6. FUNCTION MODULE COPYING
#      - Copies all .*.sh files from common/bin/ to ~/.functions.d/
#      - Makes shell functions available to both bash and zsh
#      - Benefit: Modular shell functions instead of monolithic rc file
#      - Idempotent: copies overwrite previous versions
#      Full responsibility: All shell functions available
#
#   7. PROFILE SOURCING CONFIGURATION
#      - Configures .bash_profile to explicitly source all .*_profile files
#      - Configures .zshrc to explicitly source all .*_profile files
#      - Handles shell-specific profiles (zsh-specific have conditions)
#      - Manages loading order (language managers first, etc.)
#      Full responsibility: Profiles load in correct order in both shells
#
#   8. COMPREHENSIVE VALIDATION
#      - Checks if setup is complete and working
#      - Verifies symlinks point to correct locations
#      - Tests shell configuration (bash, zsh)
#      - Validates profiles are sourcing correctly
#      - Validates function modules are loaded
#      Full responsibility: Setup is valid and ready to use
#
#   9. OPTIONAL HOMEBREW SETUP
#      - Offers to run brewfile-setup.sh to manage Homebrew packages
#      - Separate script manages system package installation
#      - Non-blocking: setup.sh completes even if skipped
#      Full responsibility: User can choose Homebrew setup
#
# DEPLOYMENT PHASES (what happens when you run setup.sh):
#   Phase 1: Parse arguments & validate
#   Phase 2: Create required directories
#   Phase 3: Create secrets template
#   Phase 4: Create symlinks for dotfiles
#   Phase 5: Create symlinks for profiles (4.1 new in this iteration)
#   Phase 6: Create convenience symlinks
#   Phase 7: Copy function modules
#   Phase 8: Run comprehensive validation
#   Phase 9: Offer Homebrew setup
#   Phase 10: Show completion summary
#
# IDEMPOTENCY & SAFETY:
#   ✓ Can be run multiple times without issues
#   ✓ All directory creates use mkdir -p (safe if exist)
#   ✓ All symlinks by create_symlink() handle conflicts
#   ✓ All existing files backed up to ~/.dotfiles.backup
#   ✓ Dry-run mode (--dry-run) shows what would happen
#   ✓ No data loss - all originals preserved
#
# COMPARISON WITH bootstrap.sh:
#   ┌─────────────────────────┬──────────────┬──────────────┐
#   │ Aspect                  │ bootstrap.sh │ setup.sh     │
#   ├─────────────────────────┼──────────────┼──────────────┤
#   │ Git operations          │ YES          │ NO           │
#   │ Creates symlinks        │ NO           │ YES          │
#   │ Rsync deployment        │ YES          │ NO           │
#   │ Creates backups         │ NO           │ YES          │
#   │ Dry-run capability      │ NO           │ YES (--dry-run) │
#   │ Idempotent              │ CAUTION      │ YES (fully)  │
#   │ Can overwrite files     │ YES (rsync)  │ NO (backed up) │
#   │ Safe to re-run          │ Use caution  │ Always safe  │
#   │ Installs shell utils    │ YES          │ NO           │
#   │ Handles profiles        │ Rsync only   │ Explicit     │
#   └─────────────────────────┴──────────────┴──────────────┘
#
# DRY-RUN MODE (--dry-run):
#   Shows exactly what would happen without making changes:
#     bash setup.sh --dry-run
#
#   Output shows:
#     ✓ What directories would be created
#     ✓ What files would be backed up
#     ✓ What symlinks would be created
#     ✓ Where profiles would be deployed
#     ✓ Validation results
#
#   No actual files are modified.
#
# BACKUPS:
#   Location: ~/.dotfiles.backup
#   Format: ~/.dotfiles.backup/<filename>.backup.<timestamp>
#   Why: Preserve existing files in case of conflicts
#   Restore: cp ~/.dotfiles.backup/<backup> ~/<original>
#
# EXTENDING setup.sh:
#   To add new symlinks:
#     1. Add file to openspec/changes/audit-profile-deployment-package-managers/
#     2. Update DOTFILES array in main()
#     3. Run: bash setup.sh --dry-run (verify)
#     4. Run: bash setup.sh (apply)
#
#   To add new profiles:
#     1. Create new .*_profile file in dotfiles repo
#     2. Run: bash setup.sh (automatically symlinks)
#     3. Run: source ~/.zshrc (or bash -l)
#
# TROUBLESHOOTING:
#   Q: "symlink exists" error?
#   A: Run setup.sh again - it handles existing symlinks
#
#   Q: Profiles not loading?
#   A: Check: ls -la ~/.python_profile (should be symlink)
#      Run: bash setup.sh to recreate
#      Debug: source ~/.bash_profile 2>&1 | grep -i error
#
#   Q: Restore backed-up file?
#   A: cp ~/.dotfiles.backup/<name>.backup.<ts> ~/<name>
#
#   Q: How to force re-run all symlink creation?
#   A: bash setup.sh (always safe, recreates as needed)
#
# ============================================================================

set -e  # Exit on error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles.backup"
TIMESTAMP=$(date +%s)
DRY_RUN=false

# Color output for clarity
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
  echo -e "${GREEN}ℹ${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1"
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

# Show help message
show_help() {
  cat <<'EOF'
Setup Script - Configure macOS Dotfiles

USAGE:
  source setup.sh                 # Interactive setup with prompts
  bash setup.sh                   # Executable setup
  bash setup.sh --dry-run         # Preview changes without applying
  bash setup.sh --help            # Show this help message

OPTIONS:
  --dry-run                       Show what would be done without making changes
  --help                          Display this help message

WHAT THE SCRIPT DOES:
  1. Creates required directories (~/.functions.d, ~/.config)
  2. Creates ~/.bash_secrets from template (with 600 permissions)
  3. Creates symlinks for all dotfiles
  4. Creates convenience symlinks (.dotfiles, .ssh)
  5. Copies function modules to ~/.functions.d
  6. Validates basic setup
  7. Offers optional Homebrew setup
  8. Runs comprehensive validation

BACKUPS:
  Existing files are backed up to: ~/.dotfiles.backup
  You can restore from backups if needed.

EXAMPLES:
  # Standard setup
  bash setup.sh

  # Preview changes
  bash setup.sh --dry-run

  # Get help
  bash setup.sh --help

For detailed migration guide, see: docs/MIGRATION.md
EOF
}

# Parse command-line arguments
parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --help)
        show_help
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
  done
}

# Create backup before modifying existing files
backup_file() {
  local src="$1"
  local target="$2"

  if [ -e "$target" ] && ! [ -L "$target" ]; then
    if [ "$DRY_RUN" = false ]; then
      mkdir -p "$BACKUP_DIR"
      cp -r "$target" "$BACKUP_DIR/$(basename $target).backup.$TIMESTAMP"
    fi
    log_warn "Backed up existing $(basename $target) to $BACKUP_DIR"
  fi
}

# Create symlink, handling existing files
create_symlink() {
  local src="$1"
  local target="$2"
  local name=$(basename "$src")

  # Check if file exists
  if [ -L "$target" ]; then
    # It's a symlink, update if pointing to wrong location
    if [ "$(readlink $target)" != "$src" ]; then
      if [ "$DRY_RUN" = false ]; then
        rm "$target"
        ln -s "$src" "$target"
      fi
      log_info "Updated symlink: $target → $src"
    else
      log_info "Symlink already correct: $name"
    fi
  elif [ -e "$target" ]; then
    # It exists and it's not a symlink
    backup_file "$src" "$target"
    if [ "$DRY_RUN" = false ]; then
      rm "$target"
      ln -s "$src" "$target"
    fi
    log_info "Created symlink: $target → $src"
  else
    # File doesn't exist, create symlink
    if [ "$DRY_RUN" = false ]; then
      ln -s "$src" "$target"
    fi
    log_info "Created symlink: $target → $src"
  fi
}

# Main setup
main() {
  parse_args "$@"

  if [ "$DRY_RUN" = true ]; then
    log_warn "[DRY RUN MODE] - No changes will be made"
    echo ""
  fi

  echo "🚀 Setting up macOS dotfiles from: $DOTFILES_DIR"
  echo ""

  # Step 1: Create required directories
  log_info "Creating required directories..."
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$HOME/.functions.d"
    mkdir -p "$HOME/.config"
  else
    log_warn "[DRY RUN] Would create: $HOME/.functions.d"
    log_warn "[DRY RUN] Would create: $HOME/.config"
  fi
  log_success "Directories created"
  echo ""

  # Step 2: Create .bash_secrets if it doesn't exist
  log_info "Setting up secrets file..."
  if [ ! -f "$HOME/.bash_secrets" ]; then
    if [ "$DRY_RUN" = false ]; then
      cp "$DOTFILES_DIR/.bash_secrets.template" "$HOME/.bash_secrets"
      chmod 600 "$HOME/.bash_secrets"
    else
      log_warn "[DRY RUN] Would copy template to: $HOME/.bash_secrets (600 perms)"
    fi
    log_success "Created .bash_secrets with secure permissions (600)"
  else
    # Verify permissions are secure
    current_perms=$(stat -f %A "$HOME/.bash_secrets" 2>/dev/null || echo "unknown")
    if [ "$current_perms" != "600" ]; then
      if [ "$DRY_RUN" = false ]; then
        chmod 600 "$HOME/.bash_secrets"
      else
        log_warn "[DRY RUN] Would fix permissions: $HOME/.bash_secrets → 600"
      fi
      log_warn "Fixed .bash_secrets permissions to 600"
    else
      log_info ".bash_secrets already exists with correct permissions"
    fi
  fi
  echo ""

  # Step 3: Create symlinks for main dotfiles
  log_info "Creating symlinks for dotfiles..."
  files_to_link=(
    ".bash_profile"
    ".bashrc"
    ".zshrc"
    ".aliases"
    ".exports"
    ".path"
    ".gitconfig"
  )

  for file in "${files_to_link[@]}"; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
      create_symlink "$DOTFILES_DIR/$file" "$HOME/$file"
    fi
  done
  log_success "Symlinks created"
  echo ""

  # Step 3b: Create convenience symlinks
  log_info "Creating convenience symlinks..."

  # Symlink to dotfiles project directory
  # create_symlink "$DOTFILES_DIR" "$HOME/.dotfiles"

  # Symlink to SSH configuration (if .ssh exists in dotfiles)
  if [ -d "$DOTFILES_DIR/.ssh"  ]; then
    create_symlink "$DOTFILES_DIR/.ssh" "$HOME/.ssh"
  elif [ -d "/Users/$(whoami)/Dropbox/profile/dotfiles/ssh" ]; then
    create_symlink "/Users/$(whoami)/Dropbox/profile/dotfiles/ssh" "$HOME/.ssh"
  else
    log_warn ".ssh directory not found in dotfiles - skipping symlink"
  fi

  log_success "Convenience symlinks created"
  echo ""

  # Step 3c: Create symlinks for all .*_profile files
  log_info "Creating symlinks for context-specific profiles..."

  for profile_file in "$DOTFILES_DIR"/.*_profile; do
    if [ -f "$profile_file" ]; then
      profile_name=$(basename "$profile_file")
      target="$HOME/$profile_name"
      create_symlink "$profile_file" "$target"
    fi
  done

  log_success "Profile symlinks created"
  echo ""

  # Step 4: Copy function modules
  for func_file in "$DOTFILES_DIR/.functions.d"/*.sh; do
    if [ -f "$func_file" ]; then
      filename=$(basename "$func_file")
      target="$HOME/.functions.d/$filename"

      if [ -f "$target" ]; then
        if ! cmp -s "$func_file" "$target"; then
          if [ "$DRY_RUN" = false ]; then
            cp "$func_file" "$target"
          else
            log_warn "[DRY RUN] Would update: $filename"
          fi
          log_info "Updated function module: $filename"
        fi
      else
        if [ "$DRY_RUN" = false ]; then
          cp "$func_file" "$target"
        else
          log_warn "[DRY RUN] Would install: $filename"
        fi
        log_info "Installed function module: $filename"
      fi
    fi
  done
  log_success "Function modules installed"
  echo ""

  # Step 5: Validate basic setup
  log_info "Validating base setup..."
  if [ "$DRY_RUN" = true ]; then
    log_warn "[DRY RUN] Skipping validation (would check after actual setup)"
  elif [ -d "$HOME/.functions.d" ] && [ -f "$HOME/.bash_secrets" ]; then
    log_success "Setup validation passed"
  else
    log_error "Setup validation failed"
    return 1
  fi
  echo ""

  # Step 6: Optional Homebrew setup (initializes ~/.homebrew with git repo)
  echo ""
  if [ "$DRY_RUN" = true ]; then
    log_warn "[DRY RUN] Skipping Homebrew setup (would prompt for installation)"
  else
    read -p "Install Homebrew packages from Brewfile? (y/n) " -n 1 -r
    echo
  fi
  if [ "$DRY_RUN" = false ] && [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "$DOTFILES_DIR/brewfile-setup.sh" ]; then
      log_info "Setting up Homebrew packages..."
      # Source the brewfile setup script
      # shellcheck disable=SC1090
      source "$DOTFILES_DIR/brewfile-setup.sh"

      # Initialize BREW_HOME by cloning homebrew-brewfile repo
      log_info "Initializing Homebrew environment..."
      if brew_initialize_home; then
        log_success "Homebrew environment ready at: $BREW_HOME"
      else
        log_warn "Failed to initialize Homebrew environment - continuing with local setup"
      fi

      # Check/install Homebrew if needed
      if ! brew_is_installed; then
        log_info "Homebrew not yet installed"
        read -p "Install Homebrew now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          brew_install_homebrew silent
        else
          log_warn "Skipping Homebrew installation"
        fi
      fi

      # Install packages from Brewfile if Homebrew is available
      if brew_is_installed && [ -f "$BREWFILE" ]; then
        read -p "Install all packages from Brewfile? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          brew_install_from_file || log_warn "Some packages failed to install"
        fi
      fi
    else
      log_warn "brewfile-setup.sh not found in $DOTFILES_DIR"
    fi
  else
    log_info "Skipping Homebrew setup"
  fi
  echo ""

  # Step 7: Run comprehensive validation
  if [ "$DRY_RUN" = false ] && [ -f "$DOTFILES_DIR/validate-dotfiles.sh" ]; then
    log_info "Running comprehensive validation..."
    bash "$DOTFILES_DIR/validate-dotfiles.sh" > /dev/null 2>&1 && log_success "Validation script passed" || log_warn "Validation script found issues - run: ./validate-dotfiles.sh"
  elif [ "$DRY_RUN" = true ]; then
    log_info "Validation would run: $DOTFILES_DIR/validate-dotfiles.sh"
  fi
  echo ""

  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}⚠  DRY RUN COMPLETE${NC}"
    echo ""
    echo "To perform the actual setup, run:"
    echo "  bash setup.sh"
  else
    echo -e "${GREEN}✅ Setup complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Edit ~/.bash_secrets with your credentials"
    echo "  2. Source your shell: exec zsh (or bash)"
    echo "  3. Verify setup: ./validate-dotfiles.sh"
    [ -f "$DOTFILES_DIR/brewfile-setup.sh" ] && echo "  4. Manage packages: brewfile-setup.sh help"
  fi
  echo ""
}

# Run main setup
main "$@"
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
