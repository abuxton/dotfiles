# Deployment Workflow & Script Responsibilities

This document clarifies the deployment workflow for dotfiles and explains the responsibilities of `bootstrap.sh` and `setup.sh`.

## Quick Start

```bash
# First-time setup on a new machine
bash bootstrap.sh

# Updating or reconfiguring existing setup
bash setup.sh
```

## Deployment Workflow

The deployment process has two main stages:

```
Stage 1: Bootstrap (bootstrap.sh)
  ├─ git pull                    # Update repo to latest version
  ├─ oh-my-zsh setup             # Install/configure shell framework
  ├─ rsync deployment            # Sync dotfiles to home directory
  ├─ npm global packages         # Install global Node tools
  └─ Shell reload                # Source .zshrc for new environment

Stage 2: Setup (setup.sh) - can be run independently or as part of deployment
  ├─ Directory creation          # Create ~/.functions.d, ~/.config, etc.
  ├─ .bash_secrets template      # Create template for credentials
  ├─ Dotfile symlinks            # Link config files to home
  ├─ Convenience symlinks        # Link .dotfiles, .ssh
  ├─ Profile deployments         # Symlink all .*_profile files
  ├─ Function modules            # Copy ~/.functions.d/* modules
  ├─ Profile sourcing setup      # Configure explicit profile loading
  └─ Validation & setup          # Check everything is working
```

## bootstrap.sh - Repository Setup & Initial Deployment

**Purpose**: First-time deployment and repository synchronization

**Responsibilities**:
- `git pull origin main` — Keep repository/dotfiles up to date
- `rsync` — Sync dotfiles to home directory (destructive, with exclusions)
- `oh-my-zsh setup` — Install or update Oh My Zsh shell framework
- npm globals — Install global Node.js utilities (`add-gitignore`, etc.)
- Shell source — Reload .zshrc to activate new environment

**When to Use**:
- ✅ Initial setup on a new machine
- ✅ Periodic updates to keep repo in sync
- ✅ After major changes to core dotfiles
- ✅ When you want one command to do everything

**When NOT to Use**:
- ❌ You only want to update shell profiles
- ❌ You're testing configuration changes
- ❌ You need to see what changes before applying

**How It Works**:

```bash
#!/usr/bin/env bash
# 1. Navigate to script directory
cd "$(dirname "${BASH_SOURCE}")";

# 2. Update repo to latest code
git pull origin main;

# 3. Define rsync deployment function
function doIt() {
  rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude "assets/" \
    --exclude "*.md" \
    -avh --no-perms . ~;
  source ~/.zshrc;
}

# 4. Install oh-my-zsh if not present
function makeItHappen() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# 5. Install npm global packages
function nodeKnows() {
  if ! [ -x "$(command -v add-gitignore)" ]; then
    npm i -g add-gitignore
  fi
}

# 6. Execute with confirmation
if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt;
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    makeItHappen;
    doIt;
    nodeKnows;
  fi;
fi;
```

**Rsync Exclusions** (not deployed by bootstrap.sh):
- `.git/` — Repository metadata
- `.DS_Store` — macOS folder metadata
- `assets/` — Documentation assets
- `*.md` — All markdown documentation
- `bootstrap.sh`, `brew.sh` — Scripts themselves
- `LICENSE` — License file

**Idempotency**: bootstrap.sh can be run multiple times safely:
- `git pull` won't fail if already up-to-date
- `oh-my-zsh` installation handles existing installations
- `rsync` with no changes produces no overwrites
- npm install checks if package exists before installing

## setup.sh - Complete Local Environment Configuration

**Purpose**: Configure local shell environment, symlink dotfiles, and manage profiles

**Responsibilities**:
- Directory creation — `~/.functions.d`, `~/.config`
- Secrets template — Generate `~/.bash_secrets` with proper permissions
- Dotfile symlinks — Create symlinks for all dotconfig files
- Convenience symlinks — Create `.dotfiles` → repo, `.ssh` → config
- Profile deployment — Symlink all `.*_profile` files
- Function modules — Copy shell functions to `~/.functions.d`
- Validation — Verify setup integrity

**When to Use**:
- ✅ After running `bootstrap.sh` (natural next step)
- ✅ To reconfigure profiles and symlinks
- ✅ To test deployment changes safely (`--dry-run`)
- ✅ To reset/reapply environment on existing machine
- ✅ When you want to preview changes before applying

**When NOT to Use**:
- ❌ You need to update the git repository (use `bootstrap.sh`)
- ❌ You're installing new tools system-wide (use `brew.sh`)
- ❌ You want a non-interactive deployment (add confirmation bypass)

**How It Works**:

```bash
#!/usr/bin/env bash
set -e  # Exit on error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles.backup"
DRY_RUN=false

# Step 1: Create required directories
mkdir -p "$HOME/.functions.d"
mkdir -p "$HOME/.config"

# Step 2: Create bash_secrets template if missing
if [ ! -f "$HOME/.bash_secrets" ]; then
  cp "$DOTFILES_DIR/templates/bash_secrets_template" "$HOME/.bash_secrets"
  chmod 600 "$HOME/.bash_secrets"
fi

# Step 3: Create symlinks for dotfiles
# This uses create_symlink() which handles backups & conflicts
for dotfile in .bash_profile .zshrc .aliases .exports; do
  create_symlink "$DOTFILES_DIR/$dotfile" "$HOME/$dotfile"
done

# Step 3c: Create symlinks for all profile files
# These are context-specific configurations for language/tool managers
for profile_file in "$DOTFILES_DIR"/.*_profile; do
  [ -f "$profile_file" ] && create_symlink "$profile_file" "$HOME/$(basename "$profile_file")"
done

# Step 4: Create convenience symlinks
create_symlink "$DOTFILES_DIR" "$HOME/.dotfiles"

# ... continue with validation ...
```

**Backup Strategy**:
- First run backs up existing files to `~/.dotfiles.backup/<timestamp>/`
- Subsequent runs verify existing symlinks are correct
- No data loss — all originals preserved

**Dry-Run Mode** (`bash setup.sh --dry-run`):
- Shows exactly what would be created/backed up
- No actual changes applied
- Useful for verification before applying

**Idempotency**: setup.sh can be run multiple times:
- Checks if symlinks already exist
- Validates they point to correct locations
- Skips already-present files
- Reapplies profiles if needed

## Relationship & Sequence

```
Initial Setup Process (First-Time Machine):
  1. Run bootstrap.sh
     └─ Updates repo, installs oh-my-zsh, deploys dotfiles via rsync, installs npm globals
  2. Run setup.sh
     └─ Creates directories, symlinks, profiles, configures shell loading
  3. Manually add secrets to ~/.bash_secrets (API keys, etc.)
  4. Open new shell or source ~/.zshrc
     └─ Profiles load, language managers initialize, environment ready

Update Existing Environment:
  • Option A: Just update repo
    └─ Run: bootstrap.sh (full sync, careful with overwrites)
  • Option B: Just reconfigure setup
    └─ Run: setup.sh (no git operations, just local setup)
  • Option C: Full update
    └─ Run: bootstrap.sh, then setup.sh
```

## Script Decision Matrix

| Scenario | Use bootstrap.sh | Use setup.sh | Notes |
|----------|-----------------|------------|-------|
| First-time setup | ✅ | ✅ | Run bootstrap.sh first, then setup.sh |
| Update repo code | ✅ | ❌ | Changes files in repo and syncs |
| Add new dotfile | ❌ | ✅ | Run after adding file to repo |
| Reconfigure profiles | ❌ | ✅ | Only recreates symlinks/loading |
| Test dry-run | ❌ | ✅ | See what would happen with --dry-run |
| Install npm globals | ✅ | ❌ | Part of bootstrap setup |
| Fix broken symlinks | ❌ | ✅ | Reapplies all symlinks correctly |
| Update oh-my-zsh | ✅ | ❌ | Part of bootstrap setup |
| Deploy new *_profile | ❌ | ✅ | After adding profile file to repo |

## Delegation & Sub-script Orchestration

Both scripts follow a delegation pattern—they orchestrate other specialized scripts rather than implementing everything themselves.

### setup.sh → brewfile-setup.sh (Homebrew Management)

**When**: After symlinks are created, setup.sh offers to delegate Homebrew package management

**How it works**:
```bash
# setup.sh prompts user
read -p "Install Homebrew packages from Brewfile? (y/n) " -n 1 -r

# If yes, source brewfile-setup.sh (loads functions)
source "$DOTFILES_DIR/brewfile-setup.sh"

# Call brewfile functions to initialize and install
brew_initialize_home    # Set up ~/.homebrew git repo
brew_is_installed       # Check if Homebrew cli installed
brew_install_homebrew   # Install Homebrew if missing
```

**Responsibilities**:
- **setup.sh**: User interaction, directory prep, error handling, workflow orchestration
- **brewfile-setup.sh**: Homebrew-specific logic (install, manage packages, Brewfile operations)

**Why delegation**:
- Keeps scripts focused on their domain
- brewfile-setup.sh can be sourced independently if needed
- Makes Homebrew setup optional without bloating setup.sh
- Allows Homebrew script to be maintained separately

### Principles of Delegation

1. **Single Responsibility**: Each script handles one area (repo sync, config setup, Homebrew)
2. **Composable**: Scripts can be run independently or in sequence
3. **Optional**: Non-critical features (Homebrew) are delegated and skippable
4. **Clear Boundaries**: Each script knows what it owns and what it doesn't
5. **Orchestration**: Parent script handles user interaction, child script handles technical details

## Important Differences

| Aspect | bootstrap.sh | setup.sh |
|--------|-------------|----------|
| **What it deploys** | Entire dotfiles via rsync | Symlinks to dotfiles |
| **Git operations** | Yes (git pull) | No |
| **Shell packages** | Yes (oh-my-zsh, npm) | No |
| **Profile handling** | Rsync only | Explicit symlinks |
| **Backups** | Overwrites (careful!) | Backup-safe |
| **Idempotent** | Yes, but overwrites | Yes, completely |
| **Safe rerun** | Use with caution | Always safe |
| **Dry-run** | No | Yes (--dry-run) |
| **Time to run** | ~2-5 min | ~10-30 sec |

## Troubleshooting

### "symlink exists" error
This means neither script is the issue—your home directory already has that dotfile. Both scripts handle this, but check with:
```bash
ls -la ~/<filename>
```

### Profiles not loading
Check if profile is symlinked:
```bash
ls -la ~/.python_profile  # Should point to repo
```

If missing, run:
```bash
bash setup.sh
```

### Want to undo changes
Restore from backups:
```bash
# Find backup directory
ls -la ~/.dotfiles.backup

# Restore specific file
cp ~/.dotfiles.backup/<timestamp>/<filename> ~/<filename>
```

### Rsync overwrote important file
If bootstrap did something unexpected:
```bash
# Check what was excluded
cat bootstrap.sh | grep "exclude"

# Restore from git
git checkout <filename>
```

## See Also

- [README.md](../README.md) — Overview of dotfiles project
- [MIGRATION.md](./MIGRATION.md) — Migrating from old configuration
- [SHELL_CONFIGURATION.md](./SHELL_CONFIGURATION.md) — Shell setup details
- [PROFILE_GUIDE.md](./PROFILE_GUIDE.md) — Managing context-specific profiles
- [LANGUAGE_ECOSYSTEM.md](./LANGUAGE_ECOSYSTEM.md) — Language manager setup
