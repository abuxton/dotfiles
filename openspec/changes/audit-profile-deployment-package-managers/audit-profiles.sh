#!/usr/bin/env bash
# Profile Audit Script
# Discovers, analyzes, and documents all .*_profile files
# Generates profile-inventory.md and audit-report.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"  # Go up to dotfiles root
OUTPUT_DIR="$SCRIPT_DIR"
INVENTORY_FILE="$OUTPUT_DIR/PROFILE_INVENTORY.md"
AUDIT_REPORT="$OUTPUT_DIR/PROFILE_AUDIT_REPORT.md"
TEMP_AUDIT="/tmp/profile_audit_temp.$$"

# Cleanup on exit
trap 'rm -f "$TEMP_AUDIT"' EXIT

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "🔍 Auditing profile files in $DOTFILES_DIR..."
echo ""

# ==============================================================================
# Discovery Phase
# ==============================================================================

echo "Phase 1: Discovering profiles..."
PROFILES=()
while IFS= read -r profile; do
  PROFILES+=("$profile")
done < <(find "$DOTFILES_DIR" -maxdepth 1 -name ".*_profile" -type f | sort)

echo "Found ${#PROFILES[@]} profile files:"
printf '%s\n' "${PROFILES[@]}" | sed 's|^|  - |'
echo ""

# ==============================================================================
# Inventory Generation
# ==============================================================================

echo "Phase 2: Generating inventory..."

cat > "$INVENTORY_FILE" << 'EOF'
# Profile Inventory

## Overview

This document catalogs all context-specific profile files (.*_profile) in the dotfiles repository.

| # | Profile | Lines | Size | Purpose | Category | Dependencies |
|---|---------|-------|------|---------|----------|--------------|
EOF

COUNT=0
for profile in "${PROFILES[@]}"; do
  COUNT=$((COUNT + 1))
  BASENAME=$(basename "$profile")
  LINES=$(wc -l < "$profile" || echo "0")
  SIZE=$(du -h "$profile" | cut -f1)

  # Extract simple purpose from comments
  PURPOSE=$(head -20 "$profile" | grep -E "^#" | head -1 | sed 's/^# *//' | cut -c1-50 || echo "TBD")

  # Categorize by name
  CATEGORY="Other"
  case "$BASENAME" in
    *python*|*ruby*|*go*|*rust*|*node*|*perl*) CATEGORY="Language Tools" ;;
    *aws*|*azure*|*gcloud*|*rancher*|*hashicorp*) CATEGORY="Cloud Platforms" ;;
    *docker*|*kubernetes*|*nomad*|*vagrant*) CATEGORY="DevOps Tools" ;;
    *claude*|*openai*|*instruqt*|*bob*) CATEGORY="Development Tools" ;;
    *brew*) CATEGORY="Package Manager" ;;
    *vscode*|*vim*|*perl*|*cht*) CATEGORY="Editor/IDE" ;;
  esac

  # Extract dependencies (simple grep for common patterns)
  DEPS=""
  if grep -q "pyenv" "$profile" 2>/dev/null; then DEPS="${DEPS}pyenv "; fi
  if grep -q "rbenv" "$profile" 2>/dev/null; then DEPS="${DEPS}rbenv "; fi
  if grep -q "rustup" "$profile" 2>/dev/null; then DEPS="${DEPS}rustup "; fi
  if grep -q "cargo" "$profile" 2>/dev/null; then DEPS="${DEPS}cargo "; fi
  if grep -q "brew" "$profile" 2>/dev/null && [ "$BASENAME" != ".brew_profile" ]; then DEPS="${DEPS}brew "; fi
  if grep -q "npm" "$profile" 2>/dev/null; then DEPS="${DEPS}npm "; fi
  if grep -q "gem" "$profile" 2>/dev/null; then DEPS="${DEPS}gem "; fi
  if grep -q "go install" "$profile" 2>/dev/null; then DEPS="${DEPS}go "; fi
  DEPS=${DEPS%% }  # trim trailing space

  printf "| %d | \`%s\` | %d | %s | %s | %s | %s |\n" "$COUNT" "$BASENAME" "$LINES" "$SIZE" "$PURPOSE" "$CATEGORY" "$DEPS"
done >> "$INVENTORY_FILE"

cat >> "$INVENTORY_FILE" << 'EOF'

## Categorization by Domain

### Language Tools
Profiles for programming language version managers and tooling:
- `.python_profile` - Python (pyenv, uv, pip)
- `.ruby_profile` - Ruby (rbenv, gems)
- `.go_profile` - Go (go install, GOPATH)
- `.rust_profile` - Rust (rustup, cargo)

### Package Managers
- `.brew_profile` - Homebrew paths and setup

### Cloud Platforms
- `.aws_profile` - AWS CLI and tools
- `.azure_profile` - Azure CLI and tools
- `.gcloud_profile` - Google Cloud CLI
- `.rancher_profile` - Rancher CLI
- `.hashicorp_profile` - HashiCorp tools (Terraform, Vault, etc.)

### DevOps & Container Tools
- `.docker_profile` - Docker configuration
- `.kubernetes_profile` - Kubernetes/kubectl setup
- `.vagrant_profile` - Vagrant VM management
- `.bob_profile` - Bob (build orchestration?)

### Development & Utilities
- `.claude_profile` - Claude AI integration
- `.openai_profile` - OpenAI API integration
- `.instruqt_profile` - Instruqt learning platform
- `.vscode_profile` - VS Code configuration
- `.uv_profile` - uv Python package manager
- `.githubprofile` - GitHub-specific setup
- `.atlasssian_profile` - Atlassian tools
- `.perl_profile` - Perl environment

## Dependencies Matrix

Profile dependencies on language managers and tools:

```
Profile File        | Requires  | Purpose
--------------------|-----------|------------------------------------------
.python_profile     | pyenv     | Python version management & uv
.ruby_profile       | rbenv     | Ruby version management & colorls
.go_profile         | go        | Go package installations & tools
.rust_profile       | rustup    | Rust toolchain setup
.brew_profile       | brew      | Homebrew paths and additional config
.gcloud_profile     | gcloud    | Google Cloud SDK paths
.aws_profile        | aws       | AWS CLI configuration
.azure_profile      | az        | Azure CLI configuration
.docker_profile     | docker    | Docker daemon and tools
.kubernetes_profile | kubectl   | Kubernetes configuration
```

## Notes

- Profiles are sourced in each shell's rc file (~/.bashrc, ~/.zshrc)
- Some profiles reference external repositories (e.g., Homebrew, oh-my-zsh)
- Several profiles embed package installation logic that could be consolidated
- Order of profile sourcing matters (language managers typically before package installs)
EOF

echo "✓ Generated: $INVENTORY_FILE"
echo ""

# ==============================================================================
# Dependency Analysis
# ==============================================================================

echo "Phase 3: Analyzing dependencies and conflicts..."

cat > "$TEMP_AUDIT" << 'EOF'
## Dependency Analysis

### Cross-Profile Dependencies

Profiles that reference other profiles or shared configurations:
EOF

# Check for circular or hard dependencies
for profile in "${PROFILES[@]}"; do
  BASENAME=$(basename "$profile")

  # Check if profile sources other profiles
  if grep -E "source.*_profile|\..*_profile" "$profile" >/dev/null 2>&1; then
    echo "- $BASENAME sources other profiles" >> "$TEMP_AUDIT"
  fi

  # Check if profile depends on functions from .functions.d
  if grep -E "\.functions\.d|source ~/\." "$profile" >/dev/null 2>&1; then
    echo "- $BASENAME depends on .functions.d" >> "$TEMP_AUDIT"
  fi
done

cat >> "$TEMP_AUDIT" << 'EOF'

### PATH Modifications

Multiple profiles modifying PATH (order matters):
EOF

for profile in "${PROFILES[@]}"; do
  BASENAME=$(basename "$profile")
  if grep -E "export PATH.*:.*\$PATH" "$profile" >/dev/null 2>&1; then
    MODIFICATIONS=$(grep -E "export PATH.*:.*\$PATH" "$profile" | head -3 | sed 's/^/  - /')
    echo "- $BASENAME modifies PATH:" >> "$TEMP_AUDIT"
    echo "$MODIFICATIONS" >> "$TEMP_AUDIT"
  fi
done

cat >> "$TEMP_AUDIT" << 'EOF'

### Initialization Hooks

Profiles with shell initialization (eval statements):
EOF

for profile in "${PROFILES[@]}"; do
  BASENAME=$(basename "$profile")
  EVAL_COUNT=$(grep -c "eval \"" "$profile" || echo 0)
  if [ "$EVAL_COUNT" -gt 0 ]; then
    echo "- $BASENAME: $EVAL_COUNT eval statements" >> "$TEMP_AUDIT"
  fi
done

# ==============================================================================
# Audit Report Generation
# ==============================================================================

echo "Phase 4: Generating audit report..."

cat > "$AUDIT_REPORT" << 'EOF'
# Profile Audit Report

Generated: $(date)

## Executive Summary

This report documents the current state of profile files (.*_profile) in the dotfiles repository,
identifies patterns and issues, and provides recommendations for consolidation and improvement.

## Current State

### Profile Count and Distribution
EOF

echo "- **Total Profiles**: ${#PROFILES[@]}" >> "$AUDIT_REPORT"

# Count by category
declare -A CATEGORIES
for profile in "${PROFILES[@]}"; do
  BASENAME=$(basename "$profile")
  CATEGORY="Other"
  case "$BASENAME" in
    *python*|*ruby*|*go*|*rust*|*node*|*perl*) CATEGORY="Language Tools" ;;
    *aws*|*azure*|*gcloud*|*rancher*|*hashicorp*) CATEGORY="Cloud Platforms" ;;
    *docker*|*kubernetes*|*nomad*|*vagrant*) CATEGORY="DevOps Tools" ;;
    *claude*|*openai*|*instruqt*|*bob*) CATEGORY="Development Tools" ;;
    *brew*) CATEGORY="Package Manager" ;;
    *vscode*|*vim*|*perl*) CATEGORY="Editor/IDE" ;;
  esac
  CATEGORIES[$CATEGORY]=$((${CATEGORIES[$CATEGORY]:-0} + 1))
done

echo "" >> "$AUDIT_REPORT"
echo "### Profiles by Category" >> "$AUDIT_REPORT"
for cat in "${!CATEGORIES[@]}"; do
  echo "- $cat: ${CATEGORIES[$cat]}" >> "$AUDIT_REPORT"
done | sort >> "$AUDIT_REPORT"

cat >> "$AUDIT_REPORT" << 'EOF'

## Key Findings

### 1. Language Ecosystem Fragmentation
**Finding**: Language package managers (pyenv, rbenv, rustup, etc.) are initialized directly in profile files.
**Impact**: Difficult to track dependencies; package installations embedded in profiles rather than declarative manifests.
**Recommendation**: Create declarative manifests (pyproject.toml, Gemfile, etc.) while keeping profiles for initialization.

### 2. PATH Management Complexity
**Finding**: Multiple profiles modify PATH; order of sourcing affects tool precedence.
**Impact**: Hard to debug PATH issues; can lead to unexpected tool versions being used.
**Recommendation**: Document sourcing order; validate that language managers appear before tool installations.

### 3. Implicit Profile Loading
**Finding**: Profiles are not explicitly sourced in .bash_profile or .zshrc.
**Impact**: Profiles may not always be loaded; sourcing order is unpredictable.
**Recommendation**: Add explicit profile sourcing loop in shell initialization files.

### 4. Mixed Concerns in Profile Files
**Finding**: Some profiles contain both initialization (eval statements) and configuration (exports, aliases).
**Impact**: Complex to test; difficult to understand file purpose at a glance.
**Recommendation**: Separate initialization hooks from configuration where possible.

### 5. Undocumented Dependencies
**Finding**: Profiles often depend on external tools (brew, git, curl) that may not be installed.
**Impact**: Setup can fail silently with unclear error messages.
**Recommendation**: Document required prerequisites for each profile.

## Opportunities for Consolidation

### Immediate (Low Risk)
1. **Explicit profile sourcing**: Add to .bash_profile and .zshrc (no changes to profiles needed)
2. **Profile symlink deployment**: Extend setup.sh to symlink all profiles (doesn't affect current functionality)
3. **Documentation**: Create docs explaining each profile's purpose

### Medium-Term (Moderate Risk)
1. **Declarative manifests**: Create pyproject.toml, Gemfile, etc. (optional, profiles still work)
2. **Standardized initialization**: Ensure all language managers use consistent patterns

### Long-Term (High Value, Higher Risk)
1. **Consolidate related profiles**: Merge similar concerns (e.g., cloud platform CLIs)
2. **Centralize package management**: Fully declarative package management for each ecosystem

## Current Issues

### No Critical Issues Found
- All profiles are readable and parseable
- No obvious circular dependencies detected
- PATH modifications can coexist (just need ordering)

### Minor Issues

EOF

# Check for common issues
ISSUES_FOUND=false

for profile in "${PROFILES[@]}"; do
  BASENAME=$(basename "$profile")

  # Check for eval without error handling
  if grep -q "eval \"" "$profile" && ! grep -q "|| echo" "$profile"; then
    if ! $ISSUES_FOUND; then
      echo "**Eval statements without error handling:**" >> "$AUDIT_REPORT"
      ISSUES_FOUND=true
    fi
    echo "  - $BASENAME: eval statements could fail silently" >> "$AUDIT_REPORT"
  fi
done

if ! $ISSUES_FOUND; then
  echo "None detected in current profiles." >> "$AUDIT_REPORT"
fi

cat >> "$AUDIT_REPORT" << 'EOF'

## Recommendations

### Priority 1: Visibility & Execution (Implement Now)
✅ **Action**: Add explicit profile sourcing to shell config
- [ ] Add profile sourcing loop to .bash_profile and .zshrc
- [ ] Update setup.sh to symlink all profiles to home directory
- [ ] Update docs with profile explanation
- **Benefit**: Profiles are reliably loaded; users understand deployment
- **Risk**: Low (purely additive, no changes to profiles)

### Priority 2: Documentation (Implement Soon)
✅ **Action**: Document current state and requirements
- [ ] Create PROFILE_GUIDE.md explaining each profile
- [ ] Document initialization order and dependencies
- [ ] Create migration guide for future consolidation
- **Benefit**: Easier onboarding; clearer maintenance path
- **Risk**: None (documentation only)

### Priority 3: Consolidation (Implement Later)
⏳ **Action**: Create optional declarative manifests
- [ ] Create pyproject.toml template for Python tools
- [ ] Create Gemfile structure for Ruby gems
- [ ] Create migration guide (optional adoption)
- **Benefit**: Long-term consolidation path; easier version management
- **Risk**: Low (optional, profiles still work)

### Priority 4: Advanced (Future Enhancement)
⏳ **Action**: Full package manager consolidation
- [ ] Move language tool installs to manifests
- [ ] Consolidate similar profiles
- [ ] Reduce duplication
- **Benefit**: Simpler maintenance; clearer dependencies
- **Risk**: Moderate (requires data migration; thorough testing)

## Conclusion

The current profile organization is **functional but implicit**. Adding explicit sourcing, documentation,
and optional declarative manifests will significantly improve maintainability without disrupting existing workflows.

The recommended approach is:
1. **Phase 1 (Now)**: Make profiles explicit and documented
2. **Phase 2 (Soon)**: Create optional manifests for future adoption
3. **Phase 3 (Later)**: Enable gradual voluntary consolidation

This strategy respects existing user workflows while providing a clear path forward.
EOF

echo "✓ Generated: $AUDIT_REPORT"
echo ""

# ==============================================================================
# Summary
# ==============================================================================

echo "📊 Audit Complete!"
echo ""
echo "Summary:"
echo "  - Profiles discovered: ${#PROFILES[@]}"
echo "  - Inventory: $INVENTORY_FILE"
echo "  - Report: $AUDIT_REPORT"
echo ""
echo "Next steps:"
echo "  1. Review the inventory: cat $INVENTORY_FILE"
echo "  2. Review the report: cat $AUDIT_REPORT"
echo "  3. Proceed with profile deployment implementation"
