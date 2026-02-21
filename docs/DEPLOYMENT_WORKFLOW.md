# Deployment Workflow Guide

## Quick Reference: Which Script Do I Run?

### 🚀 TL;DR Decision Tree

```
Is this your first time setting up these dotfiles on this machine?
├─ YES → Run bootstrap.sh FIRST, then setup.sh
│
└─ NO → Just run setup.sh
    (It's idempotent—safe to run many times)
```

**That's it!** No matter what version or updates you're applying, the answer is always one of those two scenarios.

---

## Detailed Scenarios

### Scenario 1: First Time Setup (New Machine or Fresh Clone)

**Goal**: Download dotfiles repo and deploy everything to home directory

**Situation**:
- You have a fresh machine or fresh user account
- $HOME is empty or minimal
- This is the first time you're deploying these dotfiles

**Steps**:

```bash
# 1. Clone the repository (if not already cloned)
git clone https://github.com/abuxton/dotfiles.git ~/.dotfiles

# 2. Run bootstrap.sh (first-time setup only)
cd ~/.dotfiles
./bootstrap.sh
# This will:
# - Pull latest from git
# - Install oh-my-zsh (shell framework)
# - rsync-copy all files into $HOME
# - Install npm global packages
# - Reload shell

# 3. Run setup.sh (idempotent configuration)
./setup.sh
# This will:
# - Create necessary directories (~/.functions.d, ~/.config)
# - Create/update symlinks to track repo changes
# - Deploy profile system for language environments
# - Copy function modules
# - Validate setup
```

**Result**:
- ✅ Everything deployed
- ✅ Shell reloaded with all configurations
- ✅ Profiles loaded for Python, Ruby, Go, Node, AWS, Azure, etc.
- ✅ Ready to use

**Safe to re-run `setup.sh`**? YES (idempotent—creates/updates symlinks safely)

**Safe to re-run `bootstrap.sh`**? NO (rsync will overwrite files)

---

### Scenario 2: Updating Configurations on Existing Setup

**Goal**: Get latest config changes from repository

**Situation**:
- You already have dotfiles deployed
- New changes were pushed to the repo
- You want to pull in updates

**Steps**:

```bash
# Just run setup.sh (handles git pull + configuration)
cd ~/.dotfiles
./setup.sh --dry-run    # Optional: preview what will change
./setup.sh              # Apply updates
```

**Result**:
- ✅ Latest configs from repo deployed
- ✅ All symlinks verified/refreshed
- ✅ New profiles automatically deployed
- ✅ Functions updated
- ✅ Safe to run many times

**Why not bootstrap.sh?**
- bootstrap.sh is for first-time setup only
- It runs rsync, which OVERWRITES files (dangerous to rerun)
- It reinstalls oh-my-zsh (already installed)
- It's not meant for updates—just initial deployment

---

### Scenario 3: Adding a New Dotfile to the Repository

**Goal**: Deploy a new dotfile I added to the repo

**Situation**:
- You added a new dotfile to the repository (e.g., `.newfile`)
- You want to deploy it to your home directory
- Other machines should also get it

**Steps**:

```bash
# 1. Commit your new dotfile to the repository
git add .newfile
git commit -m "feat: add new dotfile configuration"
git push

# 2. On any machine: just run setup.sh
cd ~/.dotfiles
./setup.sh                    # Automatically detects and deploys new file
```

**If you created a new .*_profile file**:
- `setup.sh` Step 3c automatically symlinks ALL `.*_profile` files
- No changes needed—just run `./setup.sh`

**Result**:
- ✅ New dotfile deployed to $HOME
- ✅ Symlinked (tracks repo changes)
- ✅ All machines can get it via `./setup.sh`

---

### Scenario 4: Testing Changes in Dry-Run Mode

**Goal**: Preview what will happen without making changes

**Situation**:
- You're nervous about running setup.sh
- You want to see exactly what will happen
- You want to verify no important files will be backed up

**Steps**:

```bash
# Run setup.sh with --dry-run flag
./setup.sh --dry-run

# Output will show:
# - Which files will be symlinked
# - Which files will be backed up
# - Which directories will be created
# - Validation checks that will happen
```

**Safe?** Absolutely—no files are modified

**Result**:
- ✅ Preview all changes
- ✅ No modifications to your system
- ✅ Can review backup locations
- ✅ Confidence to run the real command

---

### Scenario 5: Recovering from Backup

**Goal**: Restore a file that was backed up during setup

**Situation**:
- setup.sh backed up an existing file (e.g., `~/.bash_profile`)
- You want to restore or compare the backup
- You need to see where backups are stored

**Steps**:

```bash
# Backups are stored in: ~/.backup/dotfiles/<TIMESTAMP>/

# 1. Find your backups
ls -la ~/.backup/dotfiles/

# 2. List a specific backup
ls -la ~/.backup/dotfiles/2024.01.15-143022/

# 3. Compare your backup with current
diff ~/.backup/dotfiles/2024.01.15-143022/.bash_profile ~/.bash_profile

# 4. Restore a backup if needed
cp ~/.backup/dotfiles/2024.01.15-143022/.bash_profile ~/

# 5. Re-run setup.sh to re-symlink
./setup.sh
```

**Backup naming convention**: `YYYY.MM.DD-HHMMSS` (sortable by date/time)

**Result**:
- ✅ Can recover any backed-up file
- ✅ Can compare versions
- ✅ Backups kept for reference

---

### Scenario 6: Troubleshooting: Script Failed / Error Occurred

**Goal**: Understand what went wrong and how to recover

**Common Issues**:

#### Issue: `permission denied` on setup.sh

```bash
# Setup scripts need to be executable
chmod +x setup.sh bootstrap.sh
./setup.sh
```

#### Issue: `git pull` failed in bootstrap.sh

```bash
# Usually means git repo is not initialized
cd ~/.dotfiles
git status    # Check git status

# If error, try:
git remote -v  # Check remote
git fetch     # Fetch latest
git pull      # Try again
```

#### Issue: Variables not loading after setup

```bash
# Reload your shell profile
source ~/.bash_profile    # bash
source ~/.zshrc           # zsh

# Or just open a new terminal
```

#### Issue: Symlink conflicts

```bash
# If setup.sh reports symlink conflicts:
# 1. Check what's conflicting
ls -la ~/[filename]

# 2. Compare backup vs current
diff ~/.backup/dotfiles/*/[filename] ~/[filename]

# 3. Decide which to keep
# 4. Re-run setup.sh

./setup.sh
```

---

## Profile System

All language/ecosystem profiles (e.g., `.python_profile`, `.ruby_profile`) are automatically:

1. **Symlinked** by setup.sh Step 3c
2. **Sourced** by .bash_profile and .zshrc
3. **Loaded on shell startup**

### How Profiles Work

Your `.bash_profile` and `.zshrc` contain a loop:

```bash
# Source all profiles
for profile in ~/.??*_profile; do
    [ -r "$profile" ] && source "$profile"
done
```

This means:
- ✅ All 22+ profiles automatically loaded
- ✅ Adding a new profile = just create the file and run setup.sh
- ✅ Each profile is independent (one breaking doesn't break others)
- ✅ Profiles must be sourced-able shell scripts

### Testing Profiles

```bash
# Test bash loading
bash -c "source ~/.bash_profile && echo 'Profiles loaded successfully'"

# Test zsh loading
zsh -c "source ~/.zshrc && echo 'Profiles loaded successfully'"

# Verify a specific profile
source ~/.python_profile
echo $PYENV_ROOT    # If set, profile loaded
```

---

## Idempotency Guarantees

### ✅ What's Safe to Re-Run Many Times: setup.sh

```bash
./setup.sh
./setup.sh  # Run again—no problem
./setup.sh  # Run again—no problem
```

**Why?** Every operation checks before modifying:
- **mkdir**: Uses `mkdir -p` (safe if already exists)
- **Symlinks**: Uses `ln -sf` (overwrites old symlinks, safe)
- **Copy**: Uses `cp` with size/time comparison (skips if target is newer)
- **Backups**: Only backs up if file will be overwritten

### ⚠️ NOT Idempotent: bootstrap.sh

```bash
./bootstrap.sh
./bootstrap.sh  # Will overwrite files—don't re-run!
```

**Why?** rsync overwrites without comparing:
- Designed for first-time setup only
- Each run will re-copy files, potentially overwriting changes
- Use setup.sh for updates instead

---

## Decision Logic

When deciding which script to run, ask yourself:

| Question | Answer → Action |
|----------|---|
| Is this my first time deploying dotfiles on this machine? | YES → bootstrap.sh first, then setup.sh |
| Am I updating existing configuration? | YES → setup.sh only |
| Have I run bootstrap.sh on this machine before? | YES → setup.sh only (don't re-run bootstrap) |
| Did something break and I need to fix it? | Pick scenario below ↓ |

### Troubleshooting Decision Tree

```
Something broke...

Did you just run bootstrap.sh for the first time?
├─ YES (failed) → Fix the error, don't re-run bootstrap
│                 Errors usually: git, network, permissions
│                 Try: chmod +x, git status, connectivity
│
├─ NO
│   │
│   Did you modify a dotfile manually?
│   ├─ YES → Either revert your change or re-run setup.sh
│   │
│   └─ NO
│       │
│       Did you add a new dotfile to the repo?
│       ├─ YES → Just run setup.sh (auto-detects new files)
│       │
│       └─ NO → Run setup.sh --dry-run to see what's wrong
```

---

## Safe Practices & Best Practices

### ✅ DO:

- ✅ Run `setup.sh --dry-run` before applying major changes
- ✅ Run setup.sh frequently to stay in sync with repo
- ✅ Commit new dotfiles to the repository before deploying
- ✅ Check backups if you're concerned about overwriting
- ✅ Use git to track changes to dotfiles

### ❌ DON'T:

- ❌ Re-run bootstrap.sh—it's one-time only
- ❌ Manually edit symlinked dotfiles in ~/.
  (Changes will be overwritten next time repo is synced—edit in repo instead)
- ❌ Delete ~/.dotfiles after running bootstrap.sh
  (symlinks will break)
- ❌ Run bootstrap.sh on every machine for updates
  (that's setup.sh's job)

---

## More Information

- [DEPLOYMENT_MATRIX.md](DEPLOYMENT_MATRIX.md) — See all 95 items and which script handles each
- [../setup.sh](../setup.sh) — Read the actual setup.sh script
- [../bootstrap.sh](../bootstrap.sh) — Read the actual bootstrap.sh script
- [../CONTRIBUTING.md](../CONTRIBUTING.md) — How to contribute new dotfiles
- [../README.md](../README.md) — General project information
