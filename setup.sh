#!/usr/bin/env bash
# Reproducible dotfiles setup script
# Sets up shell environment, symlinks, directories, and secrets
# This script is fully idempotent - running it multiple times produces the same result

set -e  # Exit on error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles.backup"
TIMESTAMP=$(date +%s)

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

# Create backup before modifying existing files
backup_file() {
  local src="$1"
  local target="$2"

  if [ -e "$target" ] && ! [ -L "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    cp -r "$target" "$BACKUP_DIR/$(basename $target).backup.$TIMESTAMP"
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
      rm "$target"
      ln -s "$src" "$target"
      log_info "Updated symlink: $target → $src"
    else
      log_info "Symlink already correct: $name"
    fi
  elif [ -e "$target" ]; then
    # It exists and it's not a symlink
    backup_file "$src" "$target"
    rm "$target"
    ln -s "$src" "$target"
    log_info "Created symlink: $target → $src"
  else
    # File doesn't exist, create symlink
    ln -s "$src" "$target"
    log_info "Created symlink: $target → $src"
  fi
}

# Main setup
main() {
  echo "🚀 Setting up macOS dotfiles from: $DOTFILES_DIR"
  echo ""

  # Step 1: Create required directories
  log_info "Creating required directories..."
  mkdir -p "$HOME/.functions.d"
  mkdir -p "$HOME/.config"
  log_success "Directories created"
  echo ""

  # Step 2: Create .bash_secrets if it doesn't exist
  log_info "Setting up secrets file..."
  if [ ! -f "$HOME/.bash_secrets" ]; then
    cp "$DOTFILES_DIR/.bash_secrets.template" "$HOME/.bash_secrets"
    chmod 600 "$HOME/.bash_secrets"
    log_success "Created .bash_secrets with secure permissions (600)"
  else
    # Verify permissions are secure
    current_perms=$(stat -f %A "$HOME/.bash_secrets" 2>/dev/null || echo "unknown")
    if [ "$current_perms" != "600" ]; then
      chmod 600 "$HOME/.bash_secrets"
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

  # Step 4: Copy function modules
  log_info "Installing function modules..."
  for func_file in "$DOTFILES_DIR/.functions.d"/*.sh; do
    if [ -f "$func_file" ]; then
      filename=$(basename "$func_file")
      target="$HOME/.functions.d/$filename"

      if [ -f "$target" ]; then
        if ! cmp -s "$func_file" "$target"; then
          cp "$func_file" "$target"
          log_info "Updated function module: $filename"
        fi
      else
        cp "$func_file" "$target"
        log_info "Installed function module: $filename"
      fi
    fi
  done
  log_success "Function modules installed"
  echo ""

  # Step 5: Run validation
  log_info "Validating setup..."
  if [ -d "$HOME/.functions.d" ] && [ -f "$HOME/.bash_secrets" ]; then
    log_success "Setup validation passed"
  else
    log_error "Setup validation failed"
    return 1
  fi
  echo ""

  # Step 6: Optional Homebrew setup
  echo ""
  read -p "Install Homebrew packages from Brewfile? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
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

  # Step 7: Run comprehensive validation if script exists
  if [ -f "$DOTFILES_DIR/validate-dotfiles.sh" ]; then
    log_info "Running comprehensive validation..."
    bash "$DOTFILES_DIR/validate-dotfiles.sh" > /dev/null 2>&1 && log_success "Validation script passed" || log_warn "Validation script found issues - run: ./validate-dotfiles.sh"
  fi
  echo ""

  echo -e "${GREEN}✅ Setup complete!${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Edit ~/.bash_secrets with your credentials"
  echo "  2. Source your shell: exec zsh (or bash)"
  echo "  3. Verify setup: ./validate-dotfiles.sh"
  [ -f "$DOTFILES_DIR/brewfile-setup.sh" ] && echo "  4. Manage packages: brewfile-setup.sh help"
  echo ""
}

# Run main setup
main "$@"
