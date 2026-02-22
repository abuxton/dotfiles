#!/bin/bash

##
# migrate.sh - Automated Migration from bootstrap.sh to setup.sh
#
# Automates the migration from old bootstrap system to new setup.sh system.
# Handles backups, repository setup, and configuration migration.
#
# Usage:
#   bash migrate.sh                 # Interactive migration with confirmations
#   bash migrate.sh --auto          # Automatic migration (no prompts)
#   bash migrate.sh --dry-run       # Show what would be done (no changes)
#   bash migrate.sh --help          # Show this help message
#
# The script:
# 1. Creates backups of existing configuration
# 2. Clones/updates dotfiles repository
# 3. Runs setup.sh to configure new system
# 4. Validates the setup
# 5. Offers to migrate custom functions and secrets
#

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HOME_BACKUP_DIR="$HOME/dotfiles-backup.$(date +%Y%m%d_%H%M%S)"
readonly DOTFILES_REPO_URL="${DOTFILES_REPO_URL:-https://github.com/abuxton/dotfiles.git}"
readonly DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Operational flags
AUTO_MODE=false
DRY_RUN=false

# Color codes
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

log_header() {
  echo ""
  echo "╔════════════════════════════════════════════════════════════════╗"
  printf "║  %s\n" "$1"
  echo "╚════════════════════════════════════════════════════════════════╝"
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

##
# Ask user for confirmation (y/n)
# Returns: 0 for yes, 1 for no
#
confirm() {
  local prompt="$1"
  local response

  if [ "$AUTO_MODE" = true ]; then
    return 0  # Auto-confirm in auto mode
  fi

  read -p "$(echo -e ${BLUE}?)  $prompt (y/n) " -n 1 -r response
  echo
  [[ $response =~ ^[Yy]$ ]]
}

##
# Execute command, optionally dry-run
#
run_cmd() {
  local description="$1"
  shift

  log_info "$description"

  if [ "$DRY_RUN" = true ]; then
    log_warn "  [DRY RUN] Would execute: $*"
    return 0
  fi

  if "$@"; then
    log_success "  Complete"
    return 0
  else
    log_error "  Failed: $*"
    return 1
  fi
}

# ============================================================================
# MIGRATION FUNCTIONS
# ============================================================================

##
# Display migration introduction
#
show_intro() {
  log_header "DOTFILES MIGRATION - bootstrap.sh → setup.sh"
  echo ""
  echo "This script will guide you through migrating your dotfiles configuration"
  echo "from the old bootstrap.sh system to the new setup.sh system."
  echo ""
  echo "The migration will:"
  echo "  • Create timestamped backups of current configuration"
  echo "  • Clone or update the dotfiles repository"
  echo "  • Run setup.sh to configure the new system"
  echo "  • Validate everything is working correctly"
  echo "  • Help migrate custom functions and secrets"
  echo ""

  if [ "$DRY_RUN" = true ]; then
    log_warn "DRY RUN MODE - No changes will be made"
    echo ""
  fi
}

##
# Step 1: Backup current configuration
#
step_backup() {
  log_header "STEP 1: Backup Current Configuration"

  if [ "$DRY_RUN" = true ]; then
    log_warn "  [DRY RUN] Would backup to: $HOME_BACKUP_DIR"
    return 0
  fi

  mkdir -p "$HOME_BACKUP_DIR"

  # Files to backup
  local files_to_backup=(
    ".bashrc"
    ".bash_profile"
    ".zshrc"
    ".aliases"
    ".exports"
    ".path"
    ".functions"
    ".github_profile"
    ".aws_profile"
    ".bash_secrets"
  )

  local backed_up=0
  for file in "${files_to_backup[@]}"; do
    if [ -e "$HOME/$file" ]; then
      cp -r "$HOME/$file" "$HOME_BACKUP_DIR/" 2>/dev/null || true
      ((backed_up++))
    fi
  done

  if [ $backed_up -gt 0 ]; then
    log_success "Backed up $backed_up files/directories to: $HOME_BACKUP_DIR"
  else
    log_warn "No configuration files found to backup"
  fi
}

##
# Step 2: Clone or update dotfiles repository
#
step_clone_repo() {
  log_header "STEP 2: Clone/Update Dotfiles Repository"

  if [ -d "$DOTFILES_DIR/.git" ]; then
    log_info "Repository already exists at: $DOTFILES_DIR"

    if [ "$DRY_RUN" = false ]; then
      run_cmd "Updating repository" git -C "$DOTFILES_DIR" pull
    fi
  else
    if [ -d "$DOTFILES_DIR" ]; then
      log_warn "Directory exists but is not a git repository: $DOTFILES_DIR"
      if ! confirm "Move existing directory aside and clone fresh?"; then
        log_error "Migration cancelled"
        return 1
      fi

      if [ "$DRY_RUN" = false ]; then
        mv "$DOTFILES_DIR" "$DOTFILES_DIR.old.$(date +%s)"
      else
        log_warn "  [DRY RUN] Would move existing directory"
      fi
    fi

    run_cmd "Cloning dotfiles repository" \
      git clone "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
  fi

  return 0
}

##
# Step 3: Run setup.sh
#
step_run_setup() {
  log_header "STEP 3: Run Setup Script"

  if [ ! -f "$DOTFILES_DIR/setup.sh" ]; then
    log_error "setup.sh not found in: $DOTFILES_DIR"
    return 1
  fi

  if [ "$DRY_RUN" = true ]; then
    log_warn "  [DRY RUN] Would run: source $DOTFILES_DIR/setup.sh"
    return 0
  fi

  log_info "Running setup.sh (this may prompt for Homebrew setup)..."
  echo ""

  # Source setup.sh - suppress auto-exit on error for better control
  if bash "$DOTFILES_DIR/setup.sh"; then
    log_success "Setup script completed successfully"
    return 0
  else
    log_warn "Setup script completed with warnings (see above)"
    return 0  # Don't fail - continue with migration
  fi
}

##
# Step 4: Validate setup
#
step_validate() {
  log_header "STEP 4: Validate New Setup"

  if [ ! -f "$DOTFILES_DIR/validate-dotfiles.sh" ]; then
    log_warn "validate-dotfiles.sh not found - skipping validation"
    return 0
  fi

  if [ "$DRY_RUN" = true ]; then
    log_warn "  [DRY RUN] Would run: bash $DOTFILES_DIR/validate-dotfiles.sh"
    return 0
  fi

  log_info "Running validation script..."
  echo ""

  if bash "$DOTFILES_DIR/validate-dotfiles.sh"; then
    log_success "Validation passed!"
    return 0
  else
    log_warn "Validation found issues (see above)"
    log_info "Run: $DOTFILES_DIR/validate-dotfiles.sh to see details"
    return 0  # Don't fail
  fi
}

##
# Step 5: Migrate custom functions
#
step_migrate_functions() {
  log_header "STEP 5: Migrate Custom Functions (Optional)"

  if [ ! -f "$HOME/.functions" ]; then
    log_info "No custom ~/.functions file found - skipping"
    return 0
  fi

  log_info "Found custom functions in ~/.functions"
  echo ""
  echo "The new system uses modular functions in ~/.functions.d/"
  echo "Your custom functions can be migrated easily:"
  echo ""

  if confirm "Migrate ~/.functions to ~/.functions.d/custom.sh?"; then
    if [ "$DRY_RUN" = false ]; then
      cp "$HOME/.functions" "$HOME/.functions.d/custom.sh"
      log_success "Migrated custom functions to: ~/.functions.d/custom.sh"
      log_info "Reload shell to use: exec zsh (or bash)"
    else
      log_warn "  [DRY RUN] Would copy ~/.functions to ~/.functions.d/custom.sh"
    fi
  fi

  return 0
}

##
# Step 6: Migrate secrets
#
step_migrate_secrets() {
  log_header "STEP 6: Migrate Secrets and Credentials (Optional)"

  log_info "The new system centralizes secrets in ~/.bash_secrets"
  echo ""

  # Check for scattered credentials
  local has_credentials=false

  if [ -f "$HOME_BACKUP_DIR/.github_profile" ]; then
    log_warn "Found ~/.github_profile (backed up)"
    has_credentials=true
  fi

  if [ -f "$HOME_BACKUP_DIR/.aws_profile" ]; then
    log_warn "Found ~/.aws_profile (backed up)"
    has_credentials=true
  fi

  if [ "$has_credentials" = false ]; then
    log_info "No scattered credential files found"
    return 0
  fi

  echo ""
  if confirm "Consolidate credentials into ~/.bash_secrets?"; then
    if [ "$DRY_RUN" = false ]; then
      # Create ~/.bash_secrets if it doesn't exist
      if [ ! -f "$HOME/.bash_secrets" ]; then
        cp "$DOTFILES_DIR/.bash_secrets.template" "$HOME/.bash_secrets"
        chmod 600 "$HOME/.bash_secrets"
      fi

      # Append credentials from backed-up profiles
      if [ -f "$HOME_BACKUP_DIR/.github_profile" ]; then
        cat "$HOME_BACKUP_DIR/.github_profile" >> "$HOME/.bash_secrets"
        log_info "Added GitHub credentials to ~/.bash_secrets"
      fi

      if [ -f "$HOME_BACKUP_DIR/.aws_profile" ]; then
        cat "$HOME_BACKUP_DIR/.aws_profile" >> "$HOME/.bash_secrets"
        log_info "Added AWS credentials to ~/.bash_secrets"
      fi

      log_warn "Verify credentials in ~/.bash_secrets and remove duplicates if any"
      log_success "Secrets consolidated"
    else
      log_warn "  [DRY RUN] Would consolidate credentials to ~/.bash_secrets"
    fi
  fi

  return 0
}

##
# Step 7: Cleanup and final instructions
#
step_final() {
  log_header "STEP 7: Final Steps"

  echo ""
  echo "✅ Migration complete!"
  echo ""
  echo "Next steps:"
  echo "  1. Review and update ~/dotfiles-backup for any custom configs"
  echo "  2. Edit ~/.bash_secrets with your credentials"
  echo "  3. Reload your shell: exec zsh (or bash)"
  echo "  4. Run validation: $DOTFILES_DIR/validate-dotfiles.sh"
  echo ""
  echo "If something breaks:"
  echo "  • Check backups: ls -la $HOME_BACKUP_DIR"
  echo "  • Restore file: cp $HOME_BACKUP_DIR/.zshrc ~/.zshrc"
  echo "  • Re-run migration: bash migrate.sh"
  echo ""

  if [ "$DRY_RUN" = true ]; then
    echo "This was a dry run. To perform the actual migration, run:"
    echo "  bash migrate.sh"
    echo ""
  fi
}

##
# Show help message
#
show_help() {
  cat <<'EOF'
Automated Migration Script: bootstrap.sh → setup.sh

USAGE:
  bash migrate.sh                 # Interactive migration with confirmations
  bash migrate.sh --auto          # Automatic migration (no prompts)
  bash migrate.sh --dry-run       # Show what would be done (no changes)
  bash migrate.sh --help          # Show this help message

OPTIONS:
  --auto                          Skip prompts and auto-confirm all steps
  --dry-run                       Show what would happen without making changes
  --help                          Display this help message

ENVIRONMENT VARIABLES:
  DOTFILES_DIR                    Location of dotfiles repository (default: $HOME/dotfiles)
  DOTFILES_REPO_URL               Repository URL (default: https://github.com/abuxton/dotfiles.git)

WHAT THE SCRIPT DOES:
  1. Backs up current configuration to ~/dotfiles-backup.TIMESTAMP
  2. Clones or updates the dotfiles repository
  3. Runs setup.sh to configure the new system
  4. Validates the setup with validate-dotfiles.sh
  5. Optionally migrates custom functions and secrets
  6. Provides instructions for next steps

BACKUP LOCATION:
  All existing configuration is backed up to: ~/dotfiles-backup.TIMESTAMP
  You can safely restore from this if needed.

EXAMPLES:
  # Interactive migration (recommended first time)
  bash migrate.sh

  # Preview changes without making them
  bash migrate.sh --dry-run

  # Automatic migration (for automation/CI)
  bash migrate.sh --auto

FOR HELP:
  See docs/MIGRATION.md for detailed migration guide
  Run: ./validate-dotfiles.sh to diagnose issues

EOF
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

##
# Parse command-line arguments
#
parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --auto)
        AUTO_MODE=true
        shift
        ;;
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

##
# Main migration flow
#
main() {
  parse_args "$@"

  show_intro

  if ! confirm "Begin migration?"; then
    log_warn "Migration cancelled"
    exit 0
  fi

  echo ""

  # Execute migration steps
  step_backup || log_warn "Backup step had issues"
  step_clone_repo || { log_error "Failed to clone repository"; exit 1; }
  step_run_setup || log_warn "Setup step had issues"
  step_validate || log_warn "Validation had issues"
  step_migrate_functions || log_warn "Function migration had issues"
  step_migrate_secrets || log_warn "Secrets migration had issues"
  step_final

  exit 0
}

# Run main if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
