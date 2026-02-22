#!/usr/bin/env bash
# Validate dotfiles setup
# Checks symlinks, permissions, directories, and configuration integrity
#
# VALIDATION CHECKS:
# 1. Directories: ~/.functions.d, ~/.config exist
# 2. Secrets: ~/.bash_secrets exists with 600 permissions
# 3. Symlinks: Core dotfiles (.zshrc, .bash_profile) point to repo
# 4. Functions: Function modules exist in ~/.functions.d
# 5. Configuration: Shell rc files source functions and profiles
# 6. Profiles: All .*_profile files symlinked correctly
# 7. Ecosystems: Language managers (pyenv, rbenv, go, rustup, node) available
# 8. Shell sourcing: Bash and ZSH configurations load without critical errors
# 9. PATH: $HOME/bin is in PATH
#
# WHAT PASSED/FAILED MEANS:
# - ✓ PASSED: Check succeeded, no action needed
# - ✗ FAILED: Check failed, remediation shown in command
# - → STATUS: Summary message (may include counts like "5/7 profiles OK")
#
# For detailed information about each component, see:
# - docs/DEPLOYMENT.md - Deployment workflow
# - docs/LANGUAGE_ECOSYSTEM.md - Language manager setup
# - docs/PROFILE_GUIDE.md - Profile system
#
# Usage:
#   bash validate-dotfiles.sh      # Run validation
#   bash validate-dotfiles.sh -v   # Verbose (shows all checks)

set -e

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0

log_pass() {
  echo -e "${GREEN}✓${NC} $1"
  ((CHECKS_PASSED++)) || true
}

log_fail() {
  echo -e "${RED}✗${NC} $1"
  ((CHECKS_FAILED++)) || true
}

log_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

log_status() {
  echo -e "${YELLOW}→${NC} $1"
}

# Determine dotfiles directory
DOTFILES_DIR="${DOTFILES_DIR:-.}"
if [ ! -f "$DOTFILES_DIR/setup.sh" ]; then
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

echo "🔍 Validating dotfiles setup"
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Home directory: $HOME"
echo ""

# Check 1: Required directories exist
echo "${BLUE}Checking directories...${NC}"
[ -d "$HOME/.functions.d" ] && log_pass "~/.functions.d exists" || log_fail "~/.functions.d does not exist (run: mkdir -p ~/.functions.d)"
[ -d "$HOME/.config" ] && log_pass "~/.config exists" || log_fail "~/.config does not exist (run: mkdir -p ~/.config)"
echo ""

# Check 2: Secrets file exists with correct permissions
echo "${BLUE}Checking secrets file...${NC}"
if [ -f "$HOME/.bash_secrets" ]; then
  log_pass ".bash_secrets exists"
  perms=$(stat -f %A "$HOME/.bash_secrets" 2>/dev/null || echo "unknown")
  if [ "$perms" = "600" ]; then
    log_pass ".bash_secrets has secure permissions (600)"
  else
    log_fail ".bash_secrets has insecure permissions ($perms, should be 600 - run: chmod 600 ~/.bash_secrets)"
  fi
else
  log_fail ".bash_secrets does not exist (run: cp $DOTFILES_DIR/.bash_secrets.template ~/.bash_secrets && chmod 600 ~/.bash_secrets)"
fi
echo ""

# Check 3: Key symlinks are correct
echo "${BLUE}Checking symlinks...${NC}"
symlinks=(
  ".zshrc:$DOTFILES_DIR/.zshrc"
  ".bashrc:$DOTFILES_DIR/.bashrc"
  ".bash_profile:$DOTFILES_DIR/.bash_profile"
)

for link_check in "${symlinks[@]}"; do
  link_name="${link_check%%:*}"
  link_target="${link_check##*:}"
  link_path="$HOME/$link_name"

  if [ -L "$link_path" ]; then
    actual_target=$(readlink "$link_path")
    if [ "$actual_target" = "$link_target" ]; then
      log_pass "$link_name → $link_target"
    else
      log_fail "$link_name points to wrong target: $actual_target (expected: $link_target) - run: ln -sf $link_target $link_path"
    fi
  elif [ -f "$link_path" ]; then
    log_fail "$link_name exists but is not a symlink (should be: ln -sf $link_target $link_path)"
  else
    log_fail "$link_name does not exist (run: ln -s $link_target $link_path)"
  fi
done
echo ""

# Check 4: Function modules exist
echo "${BLUE}Checking function modules...${NC}"
functions_count=$(find "$HOME/.functions.d" -maxdepth 1 -name "*.sh" 2>/dev/null | wc -l)
if [ "$functions_count" -gt 0 ]; then
  log_pass "Function modules installed ($functions_count files found)"

  # Check for expected modules
  [ -f "$HOME/.functions.d/git.sh" ] && log_pass "git.sh found" || log_fail "git.sh not found - run: setup.sh"
  [ -f "$HOME/.functions.d/system.sh" ] && log_pass "system.sh found" || log_fail "system.sh not found - run: setup.sh"
  [ -f "$HOME/.functions.d/productivity.sh" ] && log_pass "productivity.sh found" || log_fail "productivity.sh not found - run: setup.sh"
else
  log_fail "No function modules found in ~/.functions.d (run: setup.sh)"
fi
echo ""

# Check 5: Shell configuration sourcing
echo "${BLUE}Checking shell configuration...${NC}"
if grep -q "\.functions\.d" "$HOME/.zshrc" 2>/dev/null; then
  log_pass ".zshrc sources .functions.d"
else
  log_fail ".zshrc does not source .functions.d - run: setup.sh"
fi

if grep -q "\.functions\.d" "$HOME/.bash_profile" 2>/dev/null; then
  log_pass ".bash_profile sources .functions.d"
else
  log_fail ".bash_profile does not source .functions.d - run: setup.sh"
fi
echo ""

# Check 6: Profile symlinks (new in Phase 5)
echo "${BLUE}Checking profile symlinks...${NC}"
profile_count=0
profiles_ok=0

for profile_file in "$DOTFILES_DIR"./.*_profile; do
  [ -f "$profile_file" ] || continue
  profile_name=$(basename "$profile_file")
  profile_path="$HOME/$profile_name"

  ((profile_count++))

  if [ -L "$profile_path" ]; then
    actual_target=$(readlink "$profile_path")
    if [ "$actual_target" = "$profile_file" ]; then
      log_pass "Profile $profile_name symlinked correctly"
      ((profiles_ok++))
    else
      log_fail "Profile $profile_name points to wrong target: $actual_target (expected: $profile_file)"
    fi
  elif [ -f "$profile_path" ]; then
    log_fail "Profile $profile_name exists but is not a symlink (should be: ln -sf $profile_file $profile_path)"
  else
    log_fail "Profile $profile_name does not exist or is not symlinked (run: setup.sh)"
  fi
done

if [ $profile_count -gt 0 ]; then
  log_status "Profile symlinks: $profiles_ok/$profile_count correct"
else
  log_fail "No profile files found in dotfiles directory"
fi
echo ""

# Check 7: Language ecosystem validation (new in Phase 5)
echo "${BLUE}Checking language ecosystems...${NC}"
ecosystem_ok=0
ecosystem_checks=0

# Check Python/pyenv
((ecosystem_checks++))
if [ -x "$(command -v pyenv)" ]; then
  log_pass "Python/pyenv is available: $(pyenv --version 2>/dev/null | head -1)"
  ((ecosystem_ok++))
elif [ -f "$HOME/.pyenv/bin/pyenv" ]; then
  log_pass "Python/pyenv installed at: $HOME/.pyenv/bin/pyenv"
  ((ecosystem_ok++))
else
  log_fail "Python/pyenv not found - optional, run: brew install pyenv (or see docs/LANGUAGE_ECOSYSTEM.md)"
fi

# Check Ruby/rbenv
((ecosystem_checks++))
if [ -x "$(command -v rbenv)" ]; then
  log_pass "Ruby/rbenv is available: $(rbenv --version 2>/dev/null)"
  ((ecosystem_ok++))
elif [ -f "$HOME/.rbenv/bin/rbenv" ]; then
  log_pass "Ruby/rbenv installed at: $HOME/.rbenv/bin/rbenv"
  ((ecosystem_ok++))
else
  log_fail "Ruby/rbenv not found - optional, run: brew install rbenv"
fi

# Check Go
((ecosystem_checks++))
if [ -x "$(command -v go)" ]; then
  log_pass "Go is available: $(go version 2>/dev/null)"
  ((ecosystem_ok++))
else
  log_fail "Go not found - optional, run: brew install go"
fi

# Check Rust/rustup
((ecosystem_checks++))
if [ -x "$(command -v rustc)" ]; then
  log_pass "Rust/rustup is available: $(rustc --version 2>/dev/null)"
  ((ecosystem_ok++))
elif [ -f "$HOME/.cargo/bin/rustc" ]; then
  log_pass "Rust/rustup installed at: $HOME/.cargo/bin/rustc"
  ((ecosystem_ok++))
else
  log_fail "Rust/rustup not found - optional, run: brew install rustup"
fi

# Check Node.js
((ecosystem_checks++))
if [ -x "$(command -v node)" ]; then
  log_pass "Node.js is available: $(node --version 2>/dev/null)"
  ((ecosystem_ok++))
else
  log_fail "Node.js not found - optional, run: brew install node"
fi

log_status "Language ecosystems: $ecosystem_ok/$ecosystem_checks available"
echo ""

# Check 8: Shell sourcing validation (new in Phase 5)
echo "${BLUE}Checking shell configuration sourcing...${NC}"

# Test zsh sourcing
if command -v zsh >/dev/null 2>&1; then
  zsh_test=$(zsh -i -c 'echo "OK"' 2>&1)
  if echo "$zsh_test" | grep -q "OK"; then
    log_pass "ZSH configuration sources without critical errors"
  else
    log_fail "ZSH sourcing failed - check for syntax errors in {.zshrc,.zsh_profile}"
  fi
else
  log_fail "ZSH not installed - expected on macOS"
fi

# Test bash sourcing
if command -v bash >/dev/null 2>&1; then
  bash_test=$(bash -i -c 'echo "OK"' 2>&1)
  if echo "$bash_test" | grep -q "OK"; then
    log_pass "Bash configuration sources without critical errors"
  else
    log_fail "Bash sourcing failed - check for syntax errors in {.bash_profile,.bashrc}"
  fi
else
  log_fail "Bash not installed"
fi


echo "${BLUE}Checking PATH...${NC}"
if echo "$PATH" | grep -q "$HOME/bin"; then
  log_pass "$HOME/bin is in PATH"
else
  log_fail "$HOME/bin is not in PATH (add to your rc file)"
fi
echo ""

# ============================================================================
# VALIDATION SUMMARY & EXIT
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "Checks passed: ${GREEN}$CHECKS_PASSED${NC}"
echo -e "Checks failed: ${RED}$CHECKS_FAILED${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All checks passed! Dotfiles setup is valid.${NC}"
  echo ""
  echo "Your environment is properly configured:"
  echo "  • Directories created"
  echo "  • Secrets file in place"
  echo "  • All symlinks correct"
  echo "  • Shell configuration loads without errors"
  echo "  • Language ecosystems available"
  echo ""
  echo "You can now start a new shell or run: exec zsh"
  exit 0
else
  echo -e "${RED}⚠️  Some checks failed. See above for remediation steps.${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Review failed checks above"
  echo "  2. Run the suggested commands for each failure"
  echo "  3. Run this script again to verify"
  echo ""
  echo "For help, see:"
  echo "  • docs/DEPLOYMENT.md"
  echo "  • docs/PROFILE_GUIDE.md"
  echo "  • README.md"
  exit 1
fi
