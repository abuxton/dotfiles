# bootstrap.sh Operations - Complete Reference

## Overview
Comprehensive line-by-line documentation of every operation performed by bootstrap.sh, including operation types, locations, purposes, and classification.

## Initial Context Setup (Lines 46-48)

### Operation 0.1: Change to Script Directory
- **Line 46**: `cd "$(dirname "${BASH_SOURCE}")"`,
- **Type**: Directory change
- **Purpose**: Ensure git pull operates in repository directory
- **Location**: Repository root (same as script location)
- **Idempotent**: Yes

## Step 1: Repository Update (Line 49-50)

### Operation 1.1: Git Pull
- **Line 49-50**: `git pull origin main`,
- **Type**: Git operation
- **Purpose**: Update repository to latest version
- **Prerequisites**: git installed, network available, git repo initialized
- **Idempotent**: No (git pull modifies repository state, but idempotent in behavior - running twice is safe)
- **Classification**: IDEMPOTENT (safe to re-run, no-op if already up-to-date)
- **Notes**: Updates all dotfiles, profiles, and configurations from latest main branch
- **Error handling**: Could fail if merge conflicts exist (requires manual resolution)
- **Associated with**: bootstrap.sh unique responsibility

## Step 2: Rsync Deployment (Lines 51-67)

### Operation 2.1: Rsync Dotfiles Deploy
- **Function**: `doIt()` (lines 51-67)
- **Type**: Recursive file synchronization (copy, not symlink)
- **Purpose**: Deploy all dotfiles from repo to $HOME
- **Method**: rsync with exclusions (see below)

**Rsync Command (lines 52-58)**:
```bash
rsync --exclude ".git/" \
  --exclude ".DS_Store" \
  --exclude ".osx" \
  --exclude "assets/" \
  --exclude "bootstrap.sh" \
  --exclude "README.md" \
  --exclude "LICENSE-MIT.txt" \
  --exclude "brew.sh" \
  --exclude "*.md" \
  -avh --no-perms . ~
```

**What Gets Deployed**:
- ✅ All dotfiles (.bash_profile, .zshrc, .aliases, .path, .exports, .gitconfig, etc.)
- ✅ All profiles (.*_profile files - should be ~22)
- ✅ All hidden directories except .git (.vim, .functions, .zsh.d, etc.)
- ✅ Configuration files (.curlrc, .wgetrc, .screenrc, .tmux.conf, etc.)
- ✅ Scripts and executables (bin/, brewfile-setup.sh, validate-dotfiles.sh)
- ✅ Makefile and main scripts (.macos, .osx, etc.)

**What Gets Excluded**:
- ❌ .git/ - version control metadata (not needed in home)
- ❌ .DS_Store - macOS metadata (not needed)
- ❌ .osx - OS customization script (repo-only tool)
- ❌ assets/ - documentation assets (repo-only)
- ❌ bootstrap.sh - can't overwrite running script
- ❌ README.md, LICENSE - documentation (repo-only)
- ❌ brew.sh - auxiliary script (repo-only)
- ❌ *.md - all markdown (documentation, repo-only)

**Flags**:
- `-a` (archive mode: recursively copy, preserve permissions & times)
- `-v` (verbose: show files being transferred)
- `-h` (human-readable: print numbers in human format)
- `--no-perms` (don't set destination file permissions based on source)

**Idempotent**: No - rsync will OVERWRITE existing files
- **Classification**: NON-IDEMPOTENT (can destroy modifications if files changed locally)
- **Risk**: Users with local changes will have them overwritten
- **Mitigation**: setup.sh creates symlinks after bootstrap, symlinks point back to repo copies
- **Safety**: Should only run on fresh machines or after backing up

### Operation 2.2: Shell Reload After Deploy
- **Line 60**: (commented out) `# source ~/.bash_profile;`
- **Line 62**: `source ~/.zshrc;`
- **Type**: Shell environment reload
- **Purpose**: Activate newly deployed dotfiles and profiles in current shell session
- **Idempotent**: Yes
- **Side effects**: All dotfiles/profiles from repo are now active

## Step 3: Oh-My-Zsh Installation (Lines 71-76)

### Operation 3.1: Install Oh-My-Zsh Shell Framework
- **Function**: `makeItHappen()` (lines 71-76)
- **Type**: External script installation
- **Purpose**: Install oh-my-zsh shell framework and infrastructure
- **Command**: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- **Prerequisites**: curl installed, network available
- **Idempotent**: Conditional - installer script checks if already installed
- **Classification**: FIRST_TIME_ONLY (idempotent in installer logic, but changes system state)
- **What it installs**:
  - ~/.oh-my-zsh/ directory structure
  - oh-my-zsh plugin system
  - Theme infrastructure (e.g., powerlevel10k base)
  - Shell function and completion infrastructure
- **What it does to shell config**: Modifies ~/.zshrc to bootstrap oh-my-zsh
- **Conflict risk**: Creates or modifies ~/.zshrc - potential conflict with repo's symlinked .zshrc
- **Side effects**: Changes default shell to zsh (via chsh command executed by installer)

## Step 4: NPM Global Packages Installation (Lines 79-84)

### Operation 4.1: Install add-gitignore NPM Package
- **Function**: `nodeKnows()` (lines 79-84)
- **Type**: NPM package installation
- **Purpose**: Install add-gitignore tool for creating .gitignore files
- **Command**: `npm i -g add-gitignore`
- **Prerequisites**: npm installed, network available
- **Idempotent**: Yes (checks if command exists first)
- **Classification**: IDEMPOTENT
- **Detection**: Uses `command -v` to check if already installed (line 80)
- **Working directory**: Changes to $HOME before install (line 81)
- **Reference**: https://github.com/TejasQ/add-gitignore

**Can be extended to**:
- Add more global npm packages
- Check availability before installing each
- Make it a loop over package list

## Step 5: Deployment Execution (Lines 87-101)

### Operation 5.1: User Confirmation Check
- **Line 87**: `if [ "$1" == "--force" -o "$1" == "-f" ]`
- **Type**: Conditional confirmation
- **Purpose**: Prevent accidental overwrite of home directory
- **Modes**:
  - **Default**: Prompt user (lines 89-90)
  - **--force or -f flag**: Skip confirmation, execute immediately
- **Prompts**: "This may overwrite existing files in your home directory. Are you sure? (y/n)"

### Operation 5.2: Execution Sequence
- **Lines 91-98**: If user confirms:
  1. **Line 94**: `makeItHappen;` - Install oh-my-zsh first
  2. **Line 95**: `doIt;` - Rsync deployment second
  3. **Line 96**: `nodeKnows;` - Install npm globals third
- **Order matters**: oh-my-zsh creates ~/.zshrc infrastructure before rsync overwrites it

### Operation 5.3: Cleanup
- **Lines 101-103**: Remove function definitions from environment
  - unset doIt
  - unset makeItHappen
  - unset nodeKnows
- **Purpose**: Clean shell namespace after script execution
- **Type**: Shell variable cleanup

## Classification Summary

| Operation | Classification | Idempotent? | Safe Re-run? | Risk Level |
|---|---|---|---|---|
| git pull | IDEMPOTENT | Mostly yes | Yes (no-op if updated) | Low |
| rsync deploy | NON-IDEMPOTENT | No | Only on fresh machine | HIGH |
| oh-my-zsh install | FIRST_TIME_ONLY | Conditional | Usually, unless conflicts | Medium |
| npm install | IDEMPOTENT | Yes | Yes | Low |
| shell reload | IDEMPOTENT | Yes | Yes (re-sources) | Low |

## Bootstrap.sh Responsibilities

### UNIQUE (Not in setup.sh):
1. **Git pull** - Repository update/sync
2. **Rsync deployment** - Bulk file copy to home
3. **Oh-my-zsh installation** - Shell framework setup
4. **npm globals** - Global tool installation

### DUPLICATED (Overlaps with setup.sh):
1. **Shell reload** - Both may do this
2. **Profile sourcing** - setup.sh manages symlinks, bootstrap deploys files

### CONFLICTS IDENTIFIED:
1. **rsync copies files → setup.sh symlinks back to repo copies**
   - Risk: Two different paths to same functionality
   - Mitigation: Intended two-step (deploy first, then symlink)
   - Unclear: Who owns the files in home after both scripts run?

2. **Oh-my-zsh modifies ~/.zshrc → setup.sh symlinks .zshrc**
   - Risk: oh-my-zsh creates ~/.zshrc, then bootstrap overwrites with symlink
   - Mitigation: setup.sh runs AFTER bootstrap, so symlink takes precedence
   - Question: Does this break oh-my-zsh's self-management?

## Workflow Sequence

**Intended workflow**:
```
1. bash bootstrap.sh → git pull, make ~/.oh-my-zsh, rsync files, npm globals
2. Manual: edit ~/.bash_secrets with credentials
3. bash setup.sh → create symlinks back to repo files
4. Manual: start new shell to activate environment
```

**First-time machine setup**:
- bootstrap.sh is necessary (oh-my-zsh installation, repo sync)
- setup.sh completes configuration (symlinks, profile management)

**Existing setup update**:
- Can bootstrap.sh alone suffice? (rsync would overwrite local changes)
- Can setup.sh alone suffice? (git pull wouldn't happen, only symlinks refreshed)
- Question: Which command should existing users run to update?

## Prerequisites Analysis

**bootstrap.sh requires**:
- bash/zsh shell (script is bash)
- git installed and in PATH
- Network access (git pull, curl for oh-my-zsh, npm install)
- npm installed (for npm globals)
- curl installed (for oh-my-zsh installer)
- At least ~ 50MB free disk space (oh-my-zsh)

**setup.sh requires**:
- bash/zsh shell
- Repository already exists (must have run bootstrap or cloned manually)
- File system permissions to create symlinks
- ~1MB free disk space

**Dependency chain**: bootstrap.sh prerequisites ⊃ setup.sh prerequisites

## Recommended Next Steps

1. **Clarify role of each script** in project documentation
2. **Resolve conflict**: rsync + symlink design (intended or problematic?)
3. **Test workflow**: Fresh machine from scratch, verify both scripts work in sequence
4. **Decide**: Is bootstrap.sh necessary or can it be replaced/merged?
5. **Update documentation**: Clear user guidance on when to run which script
