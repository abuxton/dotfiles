# Dotfiles

[![Awesome](https://awesome.re/badge.svg)](https://awesome.re)

**Optimized for macOS/BSD with ZSH as primary shell and simplified Bash support.**

[![dotfiles cast](./assets/asciinema/dotfiles-session.gif)](./assets/asciinema/dotfiles-session.gif)

## Quick Start

```bash
git clone https://github.com/abuxton/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash bootstrap.sh    # First-time setup: git pull, oh-my-zsh, rsync deploy
bash setup.sh        # Configure environment: symlinks, profiles, validation
./validate-dotfiles.sh
```

**For first-time setup**, run both scripts in order:
1. `bash bootstrap.sh` - Updates repo, installs shell framework, deploys files
2. `bash setup.sh` - Creates symlinks, configures profiles, sets up environment

**For updating existing setup**, just run:
- `bash setup.sh` - Reconfigures without git operations or overwrites

See [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md) for detailed deployment workflow documentation.

## Installation

**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don't want or need. Don't blindly use my settings unless you know what that entails. Use at your own risk!

### Two-Step Setup (Recommended for new machines)

```bash
git clone https://github.com/abuxton/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash bootstrap.sh    # Step 1: Sync repo, install oh-my-zsh, deploy dotfiles
bash setup.sh        # Step 2: Configure environment, symlinks, profiles
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

### For Existing Setups (or if already cloned)

If you already have the repository cloned, just run:

```bash
bash setup.sh
```

This reconfigures your environment without git operations or overwrites.

For detailed deployment workflow documentation, see [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md).

### Using setup.sh (Recommended)

The easiest way to set up these dotfiles:

```bash
git clone https://github.com/abuxton/dotfiles.git ~/dotfiles
cd ~/dotfiles
source setup.sh
```

The `setup.sh` script is fully **idempotent** - running it multiple times is safe and produces the same result.

### Verify Installation

After installation, verify everything is configured:

```bash
./validate-dotfiles.sh
```

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
