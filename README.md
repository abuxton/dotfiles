# Dotfiles

[![Awesome](https://awesome.re/badge.svg)](https://awesome.re)

**Optimized for macOS/BSD with ZSH as primary shell and simplified Bash support.**

[![dotfiles cast](./assets/asciinema/dotfiles-session.gif)](./assets/asciinema/dotfiles-session.gif)

## Quick Start

```bash
git clone https://github.com/abuxton/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash bootstrap.sh       # First-time setup: git pull, oh-my-zsh, rsync deploy
bash setup.sh           # Configure environment: symlinks, profiles
bash deploy-agents.sh   # Deploy AI agent configurations
./validate-dotfiles.sh
```

**For first-time setup**, run all three scripts in order:
1. `bash bootstrap.sh` - Updates repo, installs shell framework, deploys files
2. `bash setup.sh` - Creates symlinks, configures profiles, sets up environment
3. `bash deploy-agents.sh` - Deploys AI agent configurations to `~/.agents/`, `~/AGENTS.md`, etc.

**For updating existing setup**, just run:
- `bash setup.sh` - Reconfigures without git operations or overwrites (idempotent)
- `bash deploy-agents.sh` - Updates agent configurations (idempotent)

See [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md) for detailed deployment workflow documentation.

## Agent Configuration

This repository includes AI agent configurations for multiple agent platforms (Claude, OpenAI via Git-Copilot, OpenCode, etc.). Run `bash deploy-agents.sh` to deploy these configurations.

**Reference:** After deployment, see `$HOME/AGENTS.md` for complete agent workflow documentation.

## Deployment Workflow Guides

**New to dotfiles?** Start here:

- **[DEPLOYMENT_WORKFLOW.md](./docs/DEPLOYMENT_WORKFLOW.md)** - Decision guide
  - "Which script should I run?" (quick reference)
  - Scenario-based instructions (first-time, updates, troubleshooting)
  - Safe practices and best practices

- **[DEPLOYMENT_MATRIX.md](./docs/DEPLOYMENT_MATRIX.md)** - Complete coverage
  - All 95 files and which script handles each
  - Deployment status and recommendations
  - Coverage analysis

- **[DEPLOYMENT_REFERENCE.md](./docs/DEPLOYMENT_REFERENCE.md)** - Technical reference
  - Dry-run mode (preview before applying)
  - Idempotency guarantees
  - Comprehensive troubleshooting

**TL;DR**: See "Quick Start" above, or run `./setup.sh --dry-run` to preview changes.

## Installation

**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don't want or need. Don't blindly use my settings unless you know what that entails. Use at your own risk!

### Three-Step Setup (Recommended for new machines)

```bash
git clone https://github.com/abuxton/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash bootstrap.sh       # Step 1: Sync repo, install oh-my-zsh, deploy dotfiles
bash setup.sh           # Step 2: Configure environment, symlinks, profiles
bash deploy-agents.sh   # Step 3: Deploy AI agent configurations
```

**Step 1: bootstrap.sh** - Repository and Shell Framework Setup
- Updates dotfiles repository to latest version (`git pull`)
- Installs/updates Oh My Zsh shell framework
- Deploys all dotfiles to home directory via rsync
- Installs global npm packages
- Non-idempotent: Use once per machine (will overwrite existing files)

**Step 2: setup.sh** - Local Environment Configuration
- Creates required directories (`~/.functions.d/`, `~/.config/`)
- Creates `.bash_secrets` with secure permissions (600)
- Creates symlinks for all dotfiles and profiles
- Copies function modules
- Fully idempotent: Safe to run multiple times

**Step 3: deploy-agents.sh** - AI Agent Configuration Deployment
- Symlinks `~/.agents/` for centralized agent skill/prompt storage
- Deploys agent-specific configs (`~/.bob/`, `~/.claude/`, `~/.github/`, `~/.opencode/`)
- Symlinks `~/AGENTS.md` for agent workflow reference
- Enables system-wide access to agent resources and documentation
- Fully idempotent: Safe to run multiple times

### For Existing Setups (or if already cloned)

If you already have the repository cloned, run the setup scripts that you need:

```bash
# Reconfigure dotfiles and environment
bash setup.sh

# Deploy or update agent configurations
bash deploy-agents.sh
```

Both scripts are fully **idempotent** - safe to run multiple times without side effects.

For detailed deployment workflow documentation, see [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md).

### Understanding the Three Scripts

| Script | Runs | Idempotent | Primary Purpose |
|--------|------|------------|--------------------------------|
| `bootstrap.sh` | Once per machine | No | Repository sync + initial deployment |
| `setup.sh` | Multiple times | Yes | Symlinks, profiles, environment setup |
| `deploy-agents.sh` | Multiple times | Yes | Agent configuration deployment |

**Workflow timeline:**
1. Run `bootstrap.sh` first on a new machine
2. Run `setup.sh` after bootstrap, or anytime to reconfigure
3. Run `deploy-agents.sh` after setup, or anytime to update agent configs
4. All subsequent runs use `setup.sh` and `deploy-agents.sh` as needed

### Verify Installation

After running all three scripts, verify everything is configured:

```bash
./validate-dotfiles.sh
```

Verify agent configurations are deployed:

```bash
ls -la ~/.agents/
cat ~/AGENTS.md
```

## Agent Configuration Details

### Available Agent Resources

After running `deploy-agents.sh`, the following agent resources are available:

**Deployed Locations:**
- `~/.agents/` - Central agent resource repository
  - `skills/` - All available skills (OpenSpec, git-workflow, domain-specific)
  - `prompts/` - Agent-specific prompt templates
  - `commands/` - CLI command definitions
  - `settings.json` - Central agent configuration
- `~/.bob/` - Bob agent configuration
- `~/.claude/` - Claude agent configuration
- `~/.github/` - GitHub Copilot configuration
- `~/.opencode/` - OpenCode CLI configuration
- `~/AGENTS.md` - Primary agent workflow documentation (symlinked from `agents/AGENTS.md`)

**Agent Skills Included:**
- **OpenSpec Workflow:** `openspec-new-change`, `openspec-apply-change`, `openspec-explore`, `openspec-verify-change`, `openspec-ff-change`, `openspec-archive-change`, and more
- **Git Workflow:** Branching strategies, conventional commits, PR workflows, CI/CD integration, release management
- **Domain-Specific:** Go development patterns, shell scripting, infrastructure as code

**Getting Started with Agents:**
1. Review `~/AGENTS.md` for complete agent workflow documentation
2. Configure agent-specific settings in `~/.agents/settings.json`
3. Start using agents with Copilot, Claude, OpenCode CLI, etc.

## Configuration

### Secrets Management

Create `~/.bash_secrets` for sensitive environment variables (API keys, tokens):

```bash
# Template is created automatically by setup.sh
# Edit to add your secrets
vim ~/.bash_secrets

# Verify permissions are secure (600)
ls -la ~/.bash_secrets
```

### Shell Configuration

- **ZSH (Primary)**: Full feature support with Oh My ZSH, Powerlevel10k theme
- **Bash (Simplified)**: Same core functionality with simpler setup

### Function Modules

Shell functions are organized in `~/.functions.d/`:
- **git.sh** - Git helpers
- **system.sh** - System utilities
- **productivity.sh** - Productivity tools

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

### Profile Management

Dotfiles supports optional tool-specific profiles that extend configuration:

#### Profile Sourcing Order

The shell startup loads profiles in this order (last value wins for conflicts):

1. **`.bash_profile` or `.zshrc`** - Core setup (exports, aliases, functions)
2. **`.functions.d/*`** - Function modules (loaded in alphabetical order)
3. **`.bash_secrets`** - Secure credentials (handled specially, 600 permissions)
4. **`.github_profile`** - GitHub-specific settings (optional)
5. **`.aws_profile`** - AWS-specific settings (optional)
6. **`.bashrc.local`** - User customizations (optional, deprecated in favor of `.bash_secrets`)

See [SHELL_CONFIGURATION.md](./docs/SHELL_CONFIGURATION.md) for detailed load sequence documentation.

#### Using Tool-Specific Profiles

Create optional tool profiles to keep settings organized:

```bash
# Create GitHub profile
echo 'export GITHUB_TOKEN="your-token"' > ~/.github_profile

# Create AWS profile
echo 'export AWS_PROFILE="default"' > ~/.aws_profile

# Profiles are automatically sourced by shell startup
exec zsh
```

#### Consolidating Profiles to .bash_secrets

For security, consider consolidating tool-specific settings into `.bash_secrets`:

```bash
# Instead of separate profiles, add to .bash_secrets:
cat >> ~/.bash_secrets <<EOF
export GITHUB_TOKEN="your-token"
export AWS_PROFILE="default"
EOF

# Remove or comment out separate profiles
# rm ~/.github_profile ~/.aws_profile

# Restart shells
exec zsh
```

#### Backward Compatibility

The system maintains backward compatibility with `.bashrc.local`:

```bash
# Old approach still works
echo 'export MY_VAR="value"' >> ~/.bashrc.local

# Will be sourced after all profiles
exec zsh
```

#### Profile Troubleshooting

**Variables not loading:**
1. Check profile file exists: `ls ~/.github_profile`
2. Check permissions: `cat ~/.github_profile` (should be readable)
3. Check load order: Variables set in later profiles override earlier ones
4. Reload shell: `exec zsh` or `exec bash`

**Conflicting variables:**
- Later profiles override earlier ones - last one wins
- Check which profile sets final value: `echo $VARIABLE; grep -r "VARIABLE=" ~/.`

**Security concerns:**
- Never commit `.bash_secrets` (in `.gitignore`)
- Limited tool profiles: `chmod 600 ~/.github_profile` if storing tokens
- Use `.bash_secrets` for all sensitive data (automatic 600 permissions)

## Troubleshooting

Run the validation script to diagnose issues:

```bash
./validate-dotfiles.sh
```

See README section for common issues and solutions.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed guidelines and POSIX-compatible shell patterns.

## License

MIT © Adam Buxton
