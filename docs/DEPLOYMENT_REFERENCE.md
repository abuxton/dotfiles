# Deployment Reference & Troubleshooting Guide

## Quick Reference: Which Script Do I Run?

| Situation | Script | Safe to Re-run? |
|-----------|--------|---|
| **First time on new machine** | bootstrap.sh → setup.sh | bootstrap: NO, setup: YES |
| **Updating configs** | setup.sh | ✅ YES |
| **Adding new dotfile** | setup.sh | ✅ YES |
| **Testing changes** | setup.sh --dry-run | ✅ YES |
| **Recovering from error** | setup.sh --dry-run, then setup.sh | ✅ YES |

**The Rule**: bootstrap.sh **once** → setup.sh **as many times as you want**

---

## Dry-Run Mode: Preview Changes Before Applying

### Why Use Dry-Run?

Dry-run mode shows exactly what will happen without making any changes to your system.

### How to Use

```bash
cd ~/.dotfiles

# Run setup.sh in dry-run mode
./setup.sh --dry-run
```

### What Dry-Run Shows

```
=== DRY RUN MODE: Preview only, no changes ===

[[ Creating directories ]]
mkdir -p /Users/you/.functions.d
mkdir -p /Users/you/.config

[[ Processing secrets template ]]
Would copy: .bash_secrets.template → ~/.bash_secrets.template

[[ Processing symlinks ]]
Symlink: ~/.bash_profile → ~/.dotfiles/.bash_profile (backing up existing)
Symlink: ~/.zshrc → ~/.dotfiles/.zshrc
...

[[ Processing profiles ]]
Symlink: ~/.python_profile → ~/.dotfiles/.python_profile
Symlink: ~/.ruby_profile → ~/.dotfiles/.ruby_profile
...

[[ Copying function modules ]]
Copy: .functions.d/git.sh → ~/.functions.d/git.sh
...

[[ Validation ]]
Checking directories... OK
Checking symlinks... Would create X symlinks
```

### Backup Preview

Dry-run shows where backups would be created:

```
BACKUP_DIR would be: ~/.backup/dotfiles/2024.01.15-143022/

Files that would be backed up:
- ~/.bash_profile (existing file)
- ~/.zshrc (older version)
- ~/.gitconfig (custom version)
```

### Interpreting Dry-Run Output

- **"Would copy"** → File would be copied (check if intentional)
- **"backing up existing"** → Old file would be preserved in ~/.backup/
- **"Would create X symlinks"** → That many symlinks would be created/updated
- **"Check OK"** → Validation passed

### Decision After Dry-Run

```
Reviewed dry-run output?

Looks good? → Run: ./setup.sh
Concerned about backups? → Check: ls ~/.backup/dotfiles/
Need to keep a file? → Move it temporarily, then run setup.sh
Want to understand more? → Check: DEPLOYMENT_WORKFLOW.md
```

---

## Idempotency & Safety Guarantees

### What Does "Idempotent" Mean?

**Idempotent** means you can run the same command many times with the same result—no unwanted side effects.

```bash
# Idempotent example:
mkdir -p ~/dir
mkdir -p ~/dir    # Safe to run again—doesn't error
mkdir -p ~/dir    # Still safe

# NOT idempotent example:
rm ~/file
rm ~/file         # ERROR: file doesn't exist
```

### setup.sh: Fully Idempotent ✅

| Operation | Idempotent? | Why |
|-----------|---|---|
| mkdir -p | ✅ YES | Creating existing directory is safe |
| ln -sf | ✅ YES | Overwrites old symlink safely |
| cp (with compare) | ✅ YES | Only copies if target is older |
| File backup | ✅ YES | Only backs up if file will change |
| Validation | ✅ YES | Just checks, doesn't modify |

**Result**: Safe to run setup.sh 1x, 10x, 100x—always same outcome

```bash
# All safe:
./setup.sh
./setup.sh
./setup.sh
# Same symlinks, same files, same state
```

### bootstrap.sh: NOT Idempotent ⚠️

| Operation | Idempotent? | Why |
|-----------|---|---|
| git pull | ⚠️ MOSTLY | Gets latest, but modifies repo state |
| oh-my-zsh install | ⚠️ CONDITIONAL | Second run may fail if already installed |
| rsync | ❌ NO | Overwrites files without comparing |
| npm install | ✅ YES | Can run multiple times safely |

**Result**: Only run bootstrap.sh once per machine

```bash
./bootstrap.sh    # First time: ✅ OK
./bootstrap.sh    # Second time: ⚠️ Overwrites, may cause issues
```

### Symlink Guarantees

All dotfiles (except those in bootstrap.sh's exclusion list) are managed as **symlinks**:

```bash
~/.bash_profile → ~/.dotfiles/.bash_profile
~/.zshrc → ~/.dotfiles/.zshrc
~/.python_profile → ~/.dotfiles/.python_profile
...
```

**Guarantee**: Symlinks always point to repo, so:
- ✅ Changes in repo automatically visible in $HOME
- ✅ No duplication of files
- ✅ Easy to track with git

### Backup Guarantee

Before overwriting any file, setup.sh creates a backup:

```bash
# Example backup sequence:
~/.bash_profile exists
↓
setup.sh creates symlink, backs up original to:
~/.backup/dotfiles/2024.01.15-143022/.bash_profile
↓
Now ~/.bash_profile → ~/.dotfiles/.bash_profile
```

**Guarantee**: No data loss—all overwrites backed up first

**Backup location**: `~/.backup/dotfiles/<TIMESTAMP>/`

---

## Troubleshooting Guide

### Problem: "Permission denied" on setup.sh

**Error**:
```
bash: ./setup.sh: Permission denied
```

**Cause**: Script is not executable

**Fix**:
```bash
chmod +x setup.sh bootstrap.sh
./setup.sh
```

---

### Problem: "git pull" fails in bootstrap.sh

**Error**:
```
fatal: not a git repository (or any of the parent directories)
```

**Cause**: Not in git repository or git not installed

**Check**:
```bash
cd ~/.dotfiles
git status    # Should show repo status, not error
```

**Fix**:
```bash
# If repo path wrong, re-clone:
cd ~
git clone https://github.com/abuxton/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh    # Install is git is not available, install it
```

---

### Problem: "command not found" for shell tools

**Error**:
```
bash_profile:15: shopt: command not found
```

**Cause**: Profile sourced in wrong shell (zsh trying to run bash command)

**Fix**:
```bash
# Check which shell you're using
echo $SHELL           # Should match your actual shell

# Explicitly source correct profile:
source ~/.bash_profile    # For bash
source ~/.zshrc           # For zsh

# Or restart terminal to auto-source
```

---

### Problem: Symlink broken after moving ~/.dotfiles

**Error**:
```
/Users/you/.bash_profile: No such file or directory
```

**Cause**: Symlink points to old repo location

**Example**:
```bash
# You moved repo:
mv ~/.dotfiles ~/Projects/dotfiles

# But symlinks still point to old location:
~/.bash_profile → ~/.dotfiles/.bash_profile  # ❌ doesn't exist
```

**Fix**:
```bash
# 1. Not in new repo location
cd ~/Projects/dotfiles

# 2. Re-run setup.sh to recreate symlinks
./setup.sh
# This updates all symlinks to new path

# Result:
# ~/.bash_profile → ~/Projects/dotfiles/.bash_profile  # ✅ correct
```

---

### Problem: "file exists" when creating symlink

**Error**:
```
ln: /Users/you/.bash_profile: File exists
```

**Cause**: File already exists, symlink creation blocked

**This should NOT happen** because setup.sh handles this. If you see it:

**Fix**:
```bash
# 1. Check what's there
ls -la ~/.bash_profile    # Is it a file or symlink?

# 2. If it's a file (not symlink), setup.sh will back it up:
./setup.sh
# Should see: "Backing up existing file"

# 3. If still fails, check backup location:
ls ~/.backup/dotfiles/*/   # Should see backups

# 4. Force re-creation:
rm ~/.bash_profile
./setup.sh
```

---

### Problem: Variables not loading after setup

**Symptoms**:
- `$PYTHON_VERSION` is empty
- `$RUBY_VERSION` is empty
- PATH doesn't include new directories

**Cause**: Shell hasn't sourced profiles yet (need to reload)

**Fix**:
```bash
# Option 1: Reload current shell
bash -l                   # bash: login shell
zsh -l                    # zsh: login shell

# Option 2: Source profiles manually
source ~/.bash_profile    # bash
source ~/.zshrc           # zsh

# Option 3: Open new terminal tab
# (New terminals auto-source)

# Verify profile loaded:
source ~/.bash_profile
echo $PYENV_ROOT          # Should show path if profiles loaded
```

---

### Problem: "no such file" in backup

**Error**:
```
cp: /Users/you/.backup/dotfiles/...: No such file or directory
```

**Cause**: Backup directory path is wrong or directory doesn't exist yet

**Fix**:
```bash
# 1. Check backup directory exists
ls -la ~/.backup/dotfiles/

# If not:
mkdir -p ~/.backup/dotfiles

# 2. Re-run setup.sh
./setup.sh
```

---

### Problem: Profiles not loading (Python/Ruby/etc. not available)

**Error**:
- `rbenv: command not found`
- `pyenv: command not found`
- Python version not detected

**Cause**: Profiles didn't load, or profile files have errors

**Diagnose**:
```bash
# Test bash profile loading
bash -c "source ~/.bash_profile && env | grep PYENV"

# Test zsh profile loading
zsh -c "source ~/.zshrc && env | grep RBENV"

# Check if profiles are symlinks
ls -la ~/.??*_profile | head -5
# Should show: lrwxr-xr-x  (indicated symlink by 'l')
```

**Fix**:
```bash
# 1. Re-run setup.sh to recreate symlinks
./setup.sh

# 2. Reload shell
source ~/.bash_profile

# 3. Test:
echo $PYENV_ROOT          # Should show path
pyenv versions            # Should list versions
```

---

### Problem: "line X: unexpected operator"

**Error**:
```
/Users/you/.bash_profile: line 15: [[: command not found
```

**Cause**: Bash-specific syntax in zsh (or vice versa)

**Usually happens when**:
- Defining profiles that mix bash/zsh syntax
- Opening bash when zsh is configured
- Profile assumes different shell

**Fix**:
```bash
# 1. Check which shell you're actually using
echo $SHELL

# 2. Check profile for shell-specific syntax:
# Look for: [[ ]] (bash), (( )) (bash), etc
grep -n '[[' ~/.??*_profile

# 3. Fix profiles to be shell-agnostic, or use /usr/bin/env
# Rather than:
#!/bin/bash
# Use:
#!/usr/bin/env bash

# 4. Source with correct shell:
bash ~/.bash_profile     # Force bash
zsh ~/.zshrc             # Force zsh
```

---

### Problem: Changes not persisting after setup.sh

**Issue**:
- You run setup.sh
- Everything looks good
- But next terminal session, changes are gone

**Cause**:
- Shell didn't reload profiles
- Or wrong shell configuration file

**Fix**:
```bash
# 1. Verify symlinks point to repo
ls -la ~/.bash_profile
# Should show: ~/.bash_profile -> /path/to/repo/.bash_profile

# 2. Force shell reload
exec $SHELL -l           # Restart current login shell

# 3. Verify profiles sourcing:
grep -n 'source.*profile' ~/.bash_profile
# Should show: loops sourcing profiles

# 4. If still not working, check shell startup file:
cat ~/.bash_profile | grep -A5 "source"
# Verify: it's actually sourcing ~/.??*_profile files
```

---

### Problem: Lost backup or need to recover file

**Situation**: You want to recover a backed-up file

**Steps**:

```bash
# 1. Find backups by date
ls -ltr ~/.backup/dotfiles/
# Shows backups newest last

# 2. Find specific backup you want
ls -la ~/.backup/dotfiles/2024.01.15-143022/

# 3. List backed-up files
find ~/.backup/dotfiles -name ".bash_profile" | sort

# 4. Restore a specific backup
cp ~/.backup/dotfiles/2024.01.15-143022/.bash_profile ~/_backup.bash_profile
# (copy to different name first to compare)

# 5. Compare with current
diff ~/.bash_profile ~/_backup.bash_profile

# 6. Use the one you prefer
cp ~/_backup.bash_profile ~/.bash_profile

# 7. Re-create symlink
./setup.sh
```

---

### Problem: Too many backups using disk space

**Issue**: `~/.backup/dotfiles/` has many old backups taking up space

**Solution**:

```bash
# 1. See total size
du -sh ~/.backup/dotfiles/

# 2. List all backups
ls -ltr ~/.backup/dotfiles/
# Shows oldest first (sorted by date)

# 3. Keep only recent backups (optional)
# Keep last 10, delete older:
cd ~/.backup/dotfiles
ls -ltr | head -n -10 | awk '{print $NF}' | xargs rm -rf

# 4. Or manually select which to keep
rm -rf ~/.backup/dotfiles/OLD_BACKUP_TIMESTAMP
```

**Backup rotation recommendation**: Keep 5-10 most recent backups, delete older ones monthly

---

## Advanced Topics

### Modifying Deployment Behavior

**setup.sh Options**:

```bash
./setup.sh                    # Normal run (applies changes)
./setup.sh --dry-run          # Preview only
./setup.sh --help             # Show help
```

### Adding Custom Profiles

To add a new language/ecosystem profile:

```bash
# 1. Create new profile in repo
cat > ~/.dotfiles/.go_profile << 'EOF'
# Go environment
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF

# 2. Commit to repo
cd ~/.dotfiles
git add .go_profile
git commit -m "feat: add Go profile"

# 3. On any machine, run setup.sh (auto-detects)
./setup.sh

# 4. Reload shell
source ~/.bash_profile
```

**Why it works**: setup.sh Step 3c uses a loop:
```bash
for profile in .*_profile; do
    ln -sf "$profile" ~/"$profile"
done
```

So new profiles are automatically symlinked without code changes.

### Excluding Files During Deployment

To exclude something from deployment:

**For bootstrap.sh**: Edit `rsync --exclude` patterns (default excludes: .git, .DS_Store, *.md)

**For setup.sh**: Files not matching the deployment patterns are automatically skipped

### Testing Before Deploying

```bash
# 1. Create test machine/docker container
# 2. Clone repo
git clone https://github.com/abuxton/dotfiles.git ~/.dotfiles

# 3. Run bootstrap.sh
cd ~/.dotfiles
./bootstrap.sh

# 4. Verify
echo "Setup complete" | grep -q "complete" && echo "✅ Success"
```

---

## FAQ

**Q: Can I edit files in ~/.dotfiles/ or should I edit in the repo?**
A: Edit in the repo (it's the source of truth). Symlinks in $HOME track repo changes automatically.

**Q: What if I need a machine-specific configuration?**
A: Keep machine-specific settings in separate files (not in repo) or use `.bash_secrets` (which is not symlinked).

**Q: Can I run setup.sh from a different directory?**
A: It's designed to be run from `~/.dotfiles` directory. If run from elsewhere, paths might not work.

**Q: Do I need to commit everything to git before running setup.sh?**
A: No, setup.sh uses files from disk. But it's good practice to commit before deploying to multiple machines.

**Q: What happens if I delete ~/.dotfiles after setup.sh?**
A: Symlinks will break. You'd need to re-clone and re-run setup.sh to fix them.

**Q: Can I run bootstrap.sh on an existing setup without breaking things?**
A: Not recommended. Use setup.sh instead for updates. If you must, back everything up first.

---

## See Also

- [DEPLOYMENT_WORKFLOW.md](DEPLOYMENT_WORKFLOW.md) — Detailed scenario-based guide
- [DEPLOYMENT_MATRIX.md](DEPLOYMENT_MATRIX.md) — Complete list of all deployed items
- [../setup.sh](../setup.sh) — The actual setup.sh script (readable)
- [../bootstrap.sh](../bootstrap.sh) — The actual bootstrap.sh script (readable)
- [../CONTRIBUTING.md](../CONTRIBUTING.md) — Contributing guidelines
