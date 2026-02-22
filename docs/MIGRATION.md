# Migration Guide: From bootstrap.sh to setup.sh

If you're upgrading from the old `bootstrap.sh` system to the new `setup.sh`, here's what you need to know.

## What Changed

| Aspect | Old (`bootstrap.sh`) | New (`setup.sh`) |
|--------|-------------------|-----------------|
| **Deployment** | Manual symlink/permission commands | Fully automated in script |
| **Idempotency** | Not idempotent; could cause issues if run twice | Fully idempotent; safe to run multiple times |
| **Secrets** | Manual `.bash_secrets` creation | Automatic from `.bash_secrets.template` |
| **Validation** | No built-in validation | Built-in checks; separate `validate-dotfiles.sh` |
| **Backups** | No backups of existing config | Automatic backups to `.dotfiles.backup/` |
| **Function Loading** | Mixed in `.functions` file | Modular `.functions.d/` directory |

## Step-by-Step Migration

### 1. Backup Your Current Configuration

```bash
# Create a backup just in case
mkdir -p ~/dotfiles-backup
cp -r ~/.{bashrc,bash_profile,zshrc,aliases,exports,bash_secrets} ~/dotfiles-backup/
```

### 2. Clone/Update the Dotfiles Repository

```bash
# If you have a local clone, update it
cd ~/dotfiles
git pull origin main

# OR if you haven't cloned yet
git clone https://github.com/abuxton/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Run the New setup.sh

```bash
source setup.sh
```

This will:
- Create `.functions.d/` directory if it doesn't exist
- Create `.config/` directory if it doesn't exist
- Create `.bash_secrets` from template (if it doesn't exist)
- Create symlinks for all dotfiles
- Set correct permissions (600 on `.bash_secrets`)
- Validate the setup

**Important:** Any existing rc files (`.bashrc`, `.zshrc`, etc.) will be backed up to `~/.dotfiles.backup/` before being replaced by symlinks.

### 4. Review and Restore Backups if Needed

If anything went wrong or you want to restore from backup:

```bash
# See what was backed up
ls -la ~/.dotfiles.backup/

# Restore a specific file if needed
cp ~/.dotfiles.backup/.zshrc.backup.* ~/.zshrc
```

### 5. Update Your Secrets

The new `~/.bash_secrets` is created from a template. Add your credentials:

```bash
vim ~/.bash_secrets

# Make sure permissions are secure
chmod 600 ~/.bash_secrets
```

### 6. Verify the Setup

```bash
./validate-dotfiles.sh
```

This checks:
- All required directories exist
- Symlinks point to correct targets
- `.bash_secrets` has secure permissions
- Shell configuration is complete

### 7. Restart Your Shells

```bash
# Reload ZSH
exec zsh

# Or reload Bash
exec bash
```

## What If Something Breaks?

### My aliases/exports aren't working

The new system still sources `.aliases` and `.exports`, just in a different order. Reload your shell:

```bash
source ~/.zshrc   # or source ~/.bash_profile for bash
```

### My custom functions don't work

If you had custom functions in old `~/.functions`:

1. Create new file in `~/.functions.d/`:
   ```bash
   cp ~/.functions ~/.functions.d/custom.sh
   ```

2. Reload shell:
   ```bash
   exec zsh  # or exec bash
   ```

### My credentials aren't loaded

Credentials should now go in `~/.bash_secrets` instead of scattered across profiles.

1. Copy credentials to `~/.bash_secrets`:
   ```bash
   cat ~/.github_profile >> ~/.bash_secrets
   chmod 600 ~/.bash_secrets
   ```

2. Remove or clean up old profile files
3. Reload shell

### I want to go back to the old system

Your old configuration is backed up:

```bash
# See backups
ls ~/.dotfiles.backup/

# Restore everything manually if needed
cp ~/.dotfiles.backup/.bashrc.backup.* ~/.bashrc
```

Or delete the repository and restore from your manual backup:

```bash
cd ~
rm -rf ~/dotfiles
cp -r ~/dotfiles-backup/.{bashrc,bash_profile,zshrc,aliases,exports,bash_secrets} .
```

## Key Differences to Know

### 1. Function Modules Are Modular

Old system had one `~/.functions` file. New system has multiple files in `~/.functions.d/`:

- `git.sh` - Git functions
- `system.sh` - System utilities
- `productivity.sh` - Todo, timer helpers
- Custom files you add

**Benefit:** Easier to maintain, find, and add functions.

### 2. Automatic Backups

When `setup.sh` runs, it automatically backs up existing files:

```bash
~/.bashrc → ~/.dotfiles.backup/.bashrc.backup.1645634400
```

No more risk of losing your config!

### 3. Automatic Secrets Creation

`~/.bash_secrets` is created automatically from template if it doesn't exist.

**Keep this safe:** Make sure permissions stay at 600:
```bash
chmod 600 ~/.bash_secrets
```

### 4. Setup Is Idempotent

Run `setup.sh` once, twice, or many times - same result:

```bash
source setup.sh
source setup.sh  # Safe to run again
source setup.sh  # Still safe
```

No re-creation of symlinks, no permission changes - idempotent.

### 5. Validation Is Built-In

Run `validate-dotfiles.sh` to verify everything is set up correctly:

```bash
./validate-dotfiles.sh
```

Checks all critical components and suggests fixes if issues found.

## Feature Comparison

### Old bootstrap.sh Features → New Equivalent

| Old Feature | New Equivalent |
|------------|------------------|
| Manual symlink creation | Automatic in `setup.sh` |
| Manual permission setting | Automatic in `setup.sh` |
| Bootstrap whole system | `setup.sh` handles it |
| Check if things worked | `validate-dotfiles.sh` |
| Backup existing config | Automatic in `setup.sh` |

### New Features in setup.sh

| New Feature | Benefit |
|-----------|---------|
| Modular `.functions.d/` | Easier to maintain functions |
| POSIX-compatible functions | Works identically in Bash and ZSH |
| Secure secrets management | Automatic 600 permissions |
| CI/CD validation | GitHub Actions workflow |
| Migration guide (this document) | Easy upgrade path |

## Troubleshooting Migration

### Q: My PATH is broken after setup.sh

**A:** Check if `setup.sh` created symlinks correctly:
```bash
ls -la ~/.bashrc ~/.bash_profile ~/.zshrc
```

Should show symlinks (→) to dotfiles directory.

### Q: Extras file (.extra) was lost

**A:** Old `.extra` is not replaced, just not sourced by default. Migrate if needed:
```bash
# Check if it still exists
cat ~/.extra

# Add content to appropriate place:
# - Exports → ~/.exports
# - Aliases → ~/.aliases
# - Functions → ~/.functions.d/custom.sh
# - Credentials → ~/.bash_secrets
```

### Q: Some profiles are missing

**A:** Add them to the sourcing order in `~/.zshrc` and `~/.bash_profile` if not auto-detected.

### Q: Old bootstrap.sh is gone

The old `bootstrap.sh` is replaced by `setup.sh`. If you need it:
```bash
git show HEAD~1:bootstrap.sh > old_bootstrap.sh
```

But use `setup.sh` instead - it's better!

## Getting Help

- Run `./validate-dotfiles.sh` to diagnose issues
- Read [SHELL_CONFIGURATION.md](./SHELL_CONFIGURATION.md) for config details
- Check [CONTRIBUTING.md](../CONTRIBUTING.md) for function development
- See [README.md](../README.md) for general information

## Questions or Issues?

If migration doesn't go smoothly:

1. Run `./validate-dotfiles.sh` - it will suggest fixes
2. Check your backups in `~/.dotfiles.backup/`
3. Open an issue on GitHub with what went wrong

Welcome to the new dotfiles! 🎉
