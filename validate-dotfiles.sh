#!/usr/bin/env bash
# Validate dotfiles setup
# Checks symlinks, permissions, directories, and configuration integrity

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
  ((CHECKS_PASSED++))
}

log_fail() {
  echo -e "${RED}✗${NC} $1"
  ((CHECKS_FAILED++))
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

# Check 6: PATH verification
echo "${BLUE}Checking PATH...${NC}"
if echo "$PATH" | grep -q "$HOME/bin"; then
  log_pass "$HOME/bin is in PATH"
else
  log_fail "$HOME/bin is not in PATH (add to your rc file)"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "Checks passed: ${GREEN}$CHECKS_PASSED${NC}"
echo -e "Checks failed: ${RED}$CHECKS_FAILED${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All checks passed! Dotfiles setup is valid.${NC}"
  exit 0
else
  echo -e "${RED}⚠️  Some checks failed. See above for remediation steps.${NC}"
  exit 1
fi
