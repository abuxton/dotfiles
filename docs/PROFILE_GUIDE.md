# Profile Management & Configuration Guide

This guide explains how to work with profiles in dotfiles, how to create new ones, and best practices for managing tool-specific configurations.

## What Are Profiles?

**Profiles** are shell configuration files (`.*.profile` or `.*_profile`) that extend the base shell environment with tool-specific settings. They enable modular, organized configuration without cluttering `.zshrc` or `.bash_profile`.

### Profile Characteristics

- **Naming**: `.{toolname}_profile` format (e.g., `.python_profile`, `.aws_profile`)
- **Location**: Home directory (`~/.{toolname}_profile`)
- **Sourcing**: Automatically loaded by `.zshrc` and `.bash_profile` in explicit order
- **Visibility**: Hidden files (start with `.`) - don't show by default
- **Permissions**: Typically 644 (world-readable, user-writable)
- **Scope**: Context-specific configuration for one tool or area
- **Dependencies**: Some profiles may depend on others (e.g., `.python_profile` depends on pyenv)

## Profile Categories

Dots files profiles are organized by category:

### 1. Language Managers (Must Load First)
Create development environment by initializing language version managers

| Profile | Manager | Purpose | Status |
|---------|---------|---------|--------|
| `.python_profile` | pyenv | Python version management & tools | ✅ Active |
| `.ruby_profile` | rbenv | Ruby version management & gems | ✅ Active |
| `.go_profile` | go install | Go environment & tools | ✅ Active |
| `.rust_profile` | rustup | Rust toolchain management | ✅ Active |
| `.node_profile` | npm | Node.js environment & packages | ✅ Active |
| `.perl_profile` | perlbrew | Perl version management | ⏸️ Planned |

**Why they load first**: Tools in other ecosystems (web bundlers, build systems, etc.) may depend on these language runtimes being available.

### 2. Cloud Platforms (Load After Languages)
Configure CLI authentication and environment for cloud deployments

| Profile | Service | Purpose | Status |
|---------|---------|---------|--------|
| `.aws_profile` | AWS | AWS CLI configuration, credentials, regions | ✅ Active |
| `.azure_profile` | Azure | Azure CLI login, subscriptions | ✅ Active |
| `.gcloud_profile` | GCP | Google Cloud SDK initialization | ✅ Active |

### 3. DevOps & Containers (Load After Clouds)
Configure container & orchestration tools

| Profile | Tool | Purpose | Status |
|---------|------|---------|--------|
| `.docker_profile` | Docker | Docker daemon config, registries | ✅ Active |
| `.kubernetes_profile` | Kubernetes | kubectl config, context switching | ✅ Active |
| `.rancher_profile` | Rancher | Rancher CLI initialization | ✅ Active |
| `.vault_profile` | HashiCorp Vault | Vault authentication, policies | ✅ Active |
| `.terraform_profile` | Terraform | Provider configuration, plugins | ✅ Active |

### 4. Package Managers (Load After DevOps)
Initialize package manager environments

| Profile | Manager | Purpose | Status |
|---------|---------|---------|--------|
| `.brew_profile` | Homebrew | Homebrew initialization & paths | ✅ Active |

### 5. Development Platforms & Services
Configure specific development platforms

| Profile | Service | Purpose | Status |
|---------|---------|---------|--------|
| `.github_profile` | GitHub | GitHub CLI config, SSH keys, tokens | ✅ Active |
| `.gitlab_profile` | GitLab | GitLab CLI configuration | ⏸️ Planned |
| `.openai_profile` | OpenAI | OpenAI API key, model defaults | ✅ Active |
| `.claude_profile` | Anthropic Claude | Claude API configuration | ✅ Active |
| `.instruqt_profile` | Instruqt | Instruqt lab environment | ✅ Active |

### 6. Editor & IDE Configuration
Configure development editors

| Profile | Tool | Purpose | Status |
|---------|------|---------|--------|
| `.vscode_profile` | VS Code | VS Code workspace paths, extensions | ✅ Active |
| `.vim_profile` | Vim | Vim settings, plugins | ⏸️ Planned |

### 7. Specialized Tools
Miscellaneous development utilities

| Profile | Tool | Purpose | Status |
|---------|------|---------|--------|
| `.bob_profile` | Bob (Neovim) | Neovim version manager | ✅ Active |
| `.atlassian_profile` | Atlassian Tools | Jira, Confluence, Bitbucket CLI | ✅ Active |
| `.hashicorp_profile` | HashiCorp | Terraform, Vault, Consul plugins | ✅ Active |
| `.vagrant_profile` | Vagrant | Virtual machine configuration | ✅ Active |
| `.uv_profile` | UV (Python) | UV package manager for Python | ✅ Active (ZSH-specific) |

## Working With Profiles

### Viewing Profiles

```bash
# List all profiles in dotfiles
ls -la ~/dotfiles/.*_profile | head -20

# List all profiles in home directory (symlinked)
ls -la ~/ | grep "_profile"

# View contents of a profile
cat ~/.python_profile

# Which profiles are sourced by current shell
grep -E "^\s*(source|\.)\s+.*_profile" ~/.zshrc ~/.bash_profile
```

### Creating a New Profile

#### Step 1: Create the profile file in the dotfiles repo

```bash
# Create new profile in dotfiles
vim ~/dotfiles/.{toolname}_profile

# Example: AWS-specific configuration
cat > ~/dotfiles/.myservice_profile << 'EOF'
#!/usr/bin/env bash
# MyService Configuration
# Descriptions help others understand the profile

# API endpoints
export MYSERVICE_API_URL="https://api.myservice.io"
export MYSERVICE_DEBUG=false

# Authentication
export MYSERVICE_API_KEY="${MYSERVICE_API_KEY:-}"

# Check if API key is configured
if [ -z "$MYSERVICE_API_KEY" ]; then
  echo "Warning: MYSERVICE_API_KEY not set - some features will be disabled"
fi

# Paths
export MYSERVICE_CONFIG_DIR="$HOME/.config/myservice"
mkdir -p "$MYSERVICE_CONFIG_DIR"

# Aliases for common operations
alias myservice-status='curl -s $MYSERVICE_API_URL/health | jq .'
alias myservice-login='myservice auth login'
EOF
```

#### Step 2: Run setup.sh to symlink the profile

```bash
# This will automatically symlink all .*_profile files including your new one
bash ~/dotfiles/setup.sh
```

#### Step 3: Source the profile or restart shell

```bash
# Option 1: Source immediately (for testing)
source ~/.{toolname}_profile

# Option 2: Start new shell (to load all profiles)
exec zsh

# Option 3: Verify it's working
echo $MYSERVICE_API_URL  # Should show configured value
```

### Modifying Existing Profiles

Since profiles are symlinked to the dotfiles repo, you can edit them in either location:

```bash
# Option 1: Edit in dotfiles (recommended for version control)
vim ~/dotfiles/.python_profile

# Option 2: Edit in home directory
vim ~/.python_profile

# Either way, changes are visible immediately (if symlinked)
# To verify it's a symlink:
ls -la ~/.python_profile
```

### Disabling a Profile

If a profile causes issues, temporarily disable it:

```bash
# Backup and remove symlink
mv ~/.python_profile ~/.python_profile.disabled

# Or unlink it
unlink ~/.python_profile

# Restart shell
exec zsh
```

## Profile Best Practices

### 1. Keep Profiles Focused

Each profile should handle ONE tool or domain:

✅ Good:
```bash
# .aws_profile - only AWS configuration
export AWS_REGION="us-west-2"
eval "$(saml2aws login)"
```

❌ Bad:
```bash
# .aws_profile - mixing multiple services
export AWS_REGION="us-west-2"
export AZURE_SUBSCRIPTION_ID="..."
export GCP_PROJECT="..."
```

### 2. Document Profile Purpose

Add comments at the top explaining what the profile does:

```bash
#!/usr/bin/env bash
# Python Environment Configuration
# Sets up pyenv for Python version management, pip configuration,
# and virtual environment defaults.
# Dependencies: pyenv (install via: brew install pyenv)
```

### 3. Handle Shell Differences

Some features are shell-specific. Handle them gracefully:

```bash
# .python_profile
eval "$(pyenv init --path)"

# ZSH-specific completions
if [ -n "$ZSH_VERSION" ]; then
  autoload -U compinit && compinit
fi

# Bash-specific options
if [ -n "$BASH_VERSION" ]; then
  shopt -s histappend
fi
```

### 4. Make Profiles Optional

Profiles shouldn't break if dependencies aren't installed:

```bash
# Bad - will exit if docker not installed
docker --version > /dev/null
export DOCKER_HOST="unix:///var/run/docker.sock"

# Good - handles missing docker gracefully
if [ -x "$(command -v docker)" ]; then
  export DOCKER_HOST="unix:///var/run/docker.sock"
else
  # Optional: warn user
  # echo "Docker not installed - some features unavailable"
  true  # or just continue silently
fi
```

### 5. Use Secure Permissions for Sensitive Profiles

Profiles containing secrets should have restricted permissions:

```bash
# Create profile with secrets
cat > ~/.myservice_profile << 'EOF'
export API_TOKEN="secret-value-here"
EOF

# Set secure permissions (owner read/write only)
chmod 600 ~/.myservice_profile

# Verify permissions
ls -la ~/.myservice_profile  # Should show: -rw-------
```

### 6. Order Matters for Dependencies

Profiles that depend on other profiles should load later:

```bash
# .bash_profile sourcing order (first to last):
# 1. Language tools (python, ruby, go, rust) - SET UP BY DEFAULT
#    These load language runtimes and PATHs
# 2. Cloud platforms (aws, azure, gcloud)
#    These run after languages available
# 3. DevOps (docker, kubernetes)
#    These may depend on cloud CLIs
# 4. Your custom profiles
#    Load after all defaults configured
```

## Managing Secrets in Profiles

### Never Commit Secrets

Secrets should NOT be in version control:

```bash
# BAD - don't do this!
export API_KEY="super-secret-12345"  # In .gitignored .aws_profile

# GOOD - use ~/.bash_secrets instead
# .aws_profile sources ~/.bash_secrets at end
[ -f "$HOME/.bash_secrets" ] && source "$HOME/.bash_secrets"
```

### Secrets Management Pattern

```bash
# .aws_profile - PUBLIC (in dotfiles)
export AWS_REGION="us-west-2"
export AWS_OUTPUT_FORMAT="json"

# .bash_secrets - PRIVATE (in .gitignore)
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

# Setup for accessing secrets
if [ -f "$HOME/.bash_secrets" ]; then
  source "$HOME/.bash_secrets"
fi
```

### Generating Secrets Template

When adding a new profile that needs secrets:

```bash
# Add template section in profile
cat >> ~/dotfiles/.myservice_profile << 'EOF'

# SECRETS CONFIGURATION
# Add these to ~/.bash_secrets (never commit to version control):
# export MYSERVICE_API_TOKEN="your-token-here"
# export MYSERVICE_WEBHOOK_SECRET="your-secret-here"

# Load secrets if available
[ -f "$HOME/.bash_secrets" ] && source "$HOME/.bash_secrets"
EOF
```

## Troubleshooting Profiles

### Profile not loading

```bash
# 1. Check if symlinked correctly
ls -la ~/.myservice_profile
# Should show: ~/.myservice_profile -> /Users/username/dotfiles/.myservice_profile

# 2. Check if .zshrc sources it
grep "myservice_profile" ~/.zshrc

# 3. Manually source to test
source ~/.myservice_profile
echo "Exit code: $?"  # Should be 0

# 4. Check for syntax errors
bash -n ~/.myservice_profile
zsh -n ~/.myservice_profile
```

### Profile causes shell startup error

```bash
# 1. Check which profile is failing
# Re-source with debug output
bash -x ~/.bash_profile 2>&1 | tail -20
zsh -x ~/.zshrc 2>&1 | tail -20

# 2. Disable the offending profile
mv ~/.myservice_profile ~/.myservice_profile.disabled

# 3. Restart shell and check if error goes away
exec zsh

# 4. Fix the profile and re-enable
# See error details in the profile content
vim ~/dotfiles/.myservice_profile

# 5. Re-enable
mv ~/.myservice_profile.disabled ~/.myservice_profile
```

### Variable from profile not available

```bash
# 1. Verify profile is sourced
grep "myservice_profile" ~/.zshrc  # Check it's in shell rc

# 2. Check if variable is exported
grep "export MY_VAR" ~/.myservice_profile

# 3. Manually source and check
source ~/.myservice_profile
echo $MY_VAR

# 4. Check if shell sourcing works
bash -c 'source ~/.myservice_profile && echo $MY_VAR'
zsh -c 'source ~/.myservice_profile && echo $MY_VAR'
```

## Creating Local-Only Profiles

For machine-specific configurations that shouldn't be in dotfiles:

```bash
# Create profile in home directory, WITHOUT symlinking to dotfiles
cat > ~/.local_profile << 'EOF'
# Machine-specific configuration
# This is NOT in version control, only on this machine
export MACHINE_ID="my-laptop-01"
export LOCAL_BUILD_DIR="/fast/ssd/builds"
EOF

# Source manually in .bash_profile or .zshrc
cat >> ~/.zshrc << 'EOF'
# Load machine-specific configuration
[ -f "$HOME/.local_profile" ] && source "$HOME/.local_profile"
EOF
```

## Migrating Old Dotfiles

If you have legacy shell configuration scattered in multiple places:

```bash
# OLD STRUCTURE
# ~/.bash_profile has everything
# ~/.bashrc has more
# ~/.zshrc has even more complex setup

# NEW STRUCTURE
# Split into profiles for clarity
# .bash_profile (core shell setup)
# .python_profile (Python setup)
# .aws_profile (AWS setup)
# ... one profile per tool

# Migration steps:
# 1. Identify standalone configuration sections
# 2. Extract into new *.profile file
# 3. Test the new profile
# 4. Remove from .bash_profile/.zshrc
# 5. Run setup.sh to symlink
```

## See Also

- [LANGUAGE_ECOSYSTEM.md](./LANGUAGE_ECOSYSTEM.md) - Language-specific profiles
- [DEPLOYMENT.md](./DEPLOYMENT.md) - How profiles get deployed
- [SHELL_CONFIGURATION.md](./SHELL_CONFIGURATION.md) - Shell startup sequence
- [README.md](../README.md) - Quick start guide
- [PACKAGE_MANAGER_GUIDE.md](./PACKAGE_MANAGER_GUIDE.md) - Package management per ecosystem
