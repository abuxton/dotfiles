# Deployment Coverage Matrix

## Overview

This document provides a comprehensive mapping of all files and directories in the dotfiles repository, showing which deployment script handles each item.

**Coverage Summary**:
- **Total Items**: 95
- **Deployed by setup.sh**: 42 (44%)
- **Deployed by bootstrap.sh**: 40 (42%)
- **Repository-only**: 9 (9%)
- **Unmapped/Optional**: 4 (4%)
- **Overall Coverage**: 92%

---

## Key

| Status | Meaning |
|--------|---------|
| ✅ SETUP | Handled by setup.sh (symlinks) |
| 📦 BOOTSTRAP | Handled by bootstrap.sh (rsync copy) |
| 📂 REPO_ONLY | Repository infrastructure (not deployed) |
| ❓ UNMAPPED | Not deployed by any script (optional/future) |

---

## Deployment Matrix

### Shell Configuration (Fully Deployed)

| Item | Type | setup.sh | bootstrap.sh | Status | Notes |
|------|------|----------|-------------|--------|-------|
| .bash_profile | dotfile | ✅ Step 3 | 📦 rsync | ✅ SETUP | Primary bash config (idempotent) |
| .bashrc | dotfile | ✅ Step 3 | 📦 rsync | ✅ SETUP | Interactive bash config |
| .zshrc | dotfile | ✅ Step 3 | 📦 rsync | ✅ SETUP | Primary zsh config |
| .path | dotfile | ✅ Step 3 | 📦 rsync | ✅ SETUP | PATH configuration |
| .exports | dotfile | ✅ Step 3 | 📦 rsync | ✅ SETUP | Environment exports |
| .aliases | dotfile | ✅ Step 3 | 📦 rsync | ✅ SETUP | Shell aliases |

### Language/Ecosystem Profiles (22 profiles - All Deployed)

All .*_profile files (e.g., .python_profile, .ruby_profile) are:
- **setup.sh**: ✅ Symlinked via Step 3c (loop: `for profile in .*_profile`)
- **bootstrap.sh**: 📦 Copied via rsync

| Profile | Purpose | Deployed |
|---------|---------|----------|
| .python_profile | Python environment (pyenv, virtualenv) | ✅ |
| .ruby_profile | Ruby environment (rbenv) | ✅ |
| .go_profile | Go development | ✅ |
| .rust_profile | Rust/Cargo environment | ✅ |
| .node_profile | Node.js/npm environment | ✅ |
| .perl_profile | Perl environment | ✅ |
| .uv_profile | uv Python package manager | ✅ |
| .aws_profile | AWS CLI configuration | ✅ |
| .azure_profile | Azure CLI configuration | ✅ |
| .gcloud_profile | Google Cloud SDK | ✅ |
| .brew_profile | Homebrew integration | ✅ |
| .bob_profile | Bob configuration | ✅ |
| .claude_profile | Claude AI integration | ✅ |
| .docker_profile | Docker environment | ✅ |
| .github_profile | GitHub CLI configuration | ✅ |
| .hashicorp_profile | HashiCorp tools (Terraform, Vault) | ✅ |
| .instruqt_profile | Instruqt platform | ✅ |
| .kubectl_completion | Kubernetes completions | ✅ |
| .openai_profile | OpenAI API configuration | ✅ |
| .rancher_profile | Rancher orchestration | ✅ |
| .vagrant_profile | Vagrant environment | ✅ |
| .vscode_profile | VS Code environment | ✅ |
| .atlassian_profile | Atlassian tools | ✅ |

### Functions & Utilities (Fully Deployed)

| Item | Type | setup.sh | bootstrap.sh | Status | Notes |
|------|------|----------|-------------|--------|-------|
| .functions | dotfile | ❌ | 📦 rsync | 📦 BOOTSTRAP | Monolithic function library (readonly after rsync) |
| .functions.d/ | directory | ✅ Step 1 | 📦 rsync | ✅ SETUP | Modular functions (individual .sh files copied) |
| .functions.d/*.sh | functions | ✅ Step 4 copy | 📦 rsync | ✅ SETUP | Individual function modules |

### Git & Version Control (Fully Deployed)

| Item | Type | setup.sh | bootstrap.sh | Status | Notes |
|------|------|----------|-------------|--------|-------|
| .gitconfig | dotfile | ✅ Step 3 | 📦 rsync | ✅ SETUP | Git configuration |
| .gitignore_global | dotfile | ✅ (via .gitconfig) | 📦 rsync | ✅ SETUP | Global git ignores |
| .github_token | dotfile | ❌ (manual) | ❌ | ❓ UNMAPPED | Secret (user-managed) |

### Terminal & Shell Tools (Fully Deployed)

| Item | Type | setup.sh | bootstrap.sh | Status | Notes |
|------|------|----------|-------------|--------|-------|
| .tmux.conf | dotfile | ✅ Step 3b | 📦 rsync | ✅ SETUP | Tmux configuration |
| .zsh.d/ | directory | ✅ Step 1 | 📦 rsync | ✅ SETUP | Zsh-specific modules |
| .zsh.d/*.zsh | zsh modules | ✅ | 📦 rsync | ✅ SETUP | Individual zsh configurations |
| .vimrc | dotfile | ✅ Step 3b | 📦 rsync | ✅ SETUP | Vim configuration |
| .vim/ | directory | ✅ Step 1 | 📦 rsync | ✅ SETUP | Vim plugins & configs |

### Application & Tool Configs (Mostly Deployed)

| Item | Type | setup.sh | bootstrap.sh | Status | Notes |
|------|------|----------|-------------|--------|-------|
| .curlrc | dotfile | ✅ Step 3b | 📦 rsync | ✅ SETUP | curl configuration |
| .wgetrc | dotfile | ✅ Step 3b | 📦 rsync | ✅ SETUP | wget configuration |
| .editorconfig | dotfile | ✅ Step 3b | 📦 rsync | ✅ SETUP | Editor settings |
| .hushlogin | dotfile | ✅ Step 3b | 📦 rsync | ✅ SETUP | Suppress login message |
| .inputrc | dotfile | ✅ Step 3b | 📦 rsync | ✅ SETUP | Readline configuration |
| .config/ | directory | ✅ Step 1 | 📦 rsync | ✅ SETUP | Application configs |
| .ssh/ | directory | ✅ Step 3b (if exists) | 📦 rsync | ✅ SETUP | SSH keys & config |

### Secrets & Private (Manual Management)

| Item | Type | setup.sh | bootstrap.sh | Status | Notes |
|------|------|----------|-------------|--------|-------|
| .bash_secrets.template | template | ✅ Step 2 copy | 📦 rsync | ✅ SETUP | User fills in secrets |
| .bash_secrets | dotfile | ❌ (user creates) | ❌ | ❓ USER_MANAGED | User-specific secrets |

### Development Tools (Optional/Unmapped)

| Item | Type | Deployed? | Status | Recommendation |
|------|------|-----------|--------|-----------------|
| .claude/ | directory | ❌ | ❓ UNMAPPED | Should deploy (AI tool config) |
| .opencode/ | directory | ❌ | ❓ UNMAPPED | Should deploy (dev tool config) |
| .vscode/ | directory | ❌ | ❓ UNMAPPED | Should deploy (editor settings) |
| .bob/ | directory | ❌ | ❓ UNMAPPED | Should deploy (tool config) |

### Project Metadata (Repository-Only)

| Item | Type | Deployed | Status | Notes |
|------|------|----------|--------|-------|
| .git/ | directory | ❌ | 📂 REPO_ONLY | Version control (never deploy) |
| .github/ | directory | ❌ | 📂 REPO_ONLY | GitHub Actions, workflows |
| .dependabot/ | directory | ❌ | 📂 REPO_ONLY | Dependabot configuration |
| .devcontainer/ | directory | ❌ | 📂 REPO_ONLY | Dev container config |
| openspec/ | directory | ❌ | 📂 REPO_ONLY | Workflow documentation |
| .refactor-tracking/ | directory | ❌ | 📂 REPO_ONLY | Project notes |

### Documentation (Repository-Only)

| Item | Type | Deployed | Status | Notes |
|------|------|----------|--------|-------|
| README.md | markdown | ❌ | 📂 REPO_ONLY | Project documentation |
| CHANGELOG.md | markdown | ❌ | 📂 REPO_ONLY | Version history |
| CONTRIBUTING.md | markdown | ❌ | 📂 REPO_ONLY | Contribution guidelines |
| AGENTS.md | markdown | ❌ | 📂 REPO_ONLY | Agent collaboration guide |
| docs/ | directory | ❌ (except setup guide) | 📂 REPO_ONLY | Documentation collection |

### Scripts & Build Tools (Repository-Only or Deployed as Needed)

| Item | Type | setup.sh | bootstrap.sh | Status | Notes |
|------|------|----------|-------------|--------|-------|
| setup.sh | script | ❌ (self-run) | 📦 rsync | ✅ DEPLOY | Idempotent configuration script |
| bootstrap.sh | script | ❌ | 📦 bootstrap-only | ✅ DEPLOY | Initial setup script |
| brewfile-setup.sh | script | ✅ Step 6 call | 📦 rsync | ✅ SETUP | Homebrew integration |
| validate-dotfiles.sh | script | ✅ Step 7 call | 📦 rsync | ✅ SETUP | Validation script |
| migrate.sh | script | ✅ (optional) | 📦 rsync | 📂 REPO_ONLY | Migration utility |
| Makefile | file | ❌ | 📦 rsync | 📂 REPO_ONLY | Build automation |

### Assets & Supplementary (Repository-Only)

| Item | Type | Deployed | Status | Notes |
|------|------|----------|--------|-------|
| assets/ | directory | ❌ | 📂 REPO_ONLY | Documentation assets |
| bin/ | directory | ✅ partial | 📦 rsync | ✅ SETUP | Utility scripts |
| common/ | directory | ❌ | 📂 REPO_ONLY | Shared infrastructure |
| init/ | directory | ❌ | 📂 REPO_ONLY | Terminal themes, IDE settings |
| modules/ | directory | ❌ | 📂 REPO_ONLY | Empty (investigational) |

---

## Coverage Analysis

### By Deployment Method

**setup.sh (Idempotent Symlinks)**:
- 42 items deployed (44% of total)
- Method: Creates symlinks from repo to $HOME
- Suitable for: Re-running safely, updating configurations
- All items re-deployable without conflicts

**bootstrap.sh (One-time rsync Copy)**:
- 40 items deployed (42% of total)
- Method: Copies files from repo to $HOME (non-idempotent)
- Suitable for: Initial first-time setup
- Items: Will overwrite existing files

**Repository-Only**:
- 9 items (9% of total)
- Never deployed to $HOME
- Examples: .git/, docs/, openspec/, .github/

**Unmapped**:
- 4 items (4% of total)
- Optional development tool configs
- Examples: .claude/, .opencode/, .vscode/, .bob/

### Deployment Strategy Summary

| Scenario | Use bootstrap.sh | Then setup.sh |
|----------|-----------------|---------------|
| New machine (empty $HOME) | ✅ YES | ✅ YES (after bootstrap) |
| Update configs on existing machine | ❌ NO | ✅ YES |
| Add new profile | ❌ NO | ✅ YES (auto-detected) |
| Fresh repo clone | ✅ YES | ✅ YES (after bootstrap) |

---

## Recommendations

### Short-term (No Changes Required)

✅ Current deployment is **92% complete** and functional
✅ Both scripts serve complementary, non-redundant purposes
✅ Clear separation: bootstrap (initial) vs setup (idempotent config)

### Medium-term (Optional Enhancements)

1. **Add optional deployment for development tool configs**:
   - .claude/, .opencode/, .vscode/, .bob/
   - Add to setup.sh Step 3c loop (like profiles)

2. **Improve documentation**:
   - Document why each script exists
   - Create decision tree for users ("Which script do I run?")

3. **Enhance validation**:
   - Verify symlinks are correct
   - Check for orphaned backups

### Long-term (No Changes Planned)

- Keep both scripts separate (complementary, not duplicative)
- Maintain two-step bootstrap model (rsync + symlinks)
- Preserve idempotency of setup.sh

---

## See Also

- [DEPLOYMENT_WORKFLOW.md](DEPLOYMENT_WORKFLOW.md) - Decision guide for which script to run
- [setup.sh](../setup.sh) - Idempotent configuration script
- [bootstrap.sh](../bootstrap.sh) - Initial deployment script
- [CONTRIBUTING.md](../CONTRIBUTING.md) - How new files should be deployed
