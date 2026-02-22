# Shell Configuration Guide

This document explains how shell configuration is organized in these macOS dotfiles.

## Shell Startup Sequence

### ZSH (Primary Shell)

When ZSH starts as a **login shell** (`zsh -l`):
1. `/etc/zprofile` → System login setup
2. `~/.zprofile` → User login setup (if it exists - we don't use)
3. `/etc/zshrc` → System interactive setup
4. `~/.zshrc` → **Our configuration starts here**

When ZSH starts as an **interactive shell** (typing `zsh` in existing shell):
1. `/etc/zshrc` → System interactive setup
2. `~/.zshrc` → **Our configuration starts here**

### Bash (Simplified Support)

When Bash starts as a **login shell** (`bash -l`):
1. `/etc/profile` → System login setup
2. `~/.bash_profile` → **Our configuration starts here**

Our `.bash_profile` sources `~/.bashrc` for interactive shells:
```bash
[ -n "$PS1" ] && source ~/.bash_profile;
```

When Bash starts as an **interactive shell** (not login):
1. `~/.bashrc` → **Our configuration starts here**

## Configuration Loading Order

Both shells use the **same sourcing order** for portability:

### Step 1: Shell-Specific Setup
- **ZSH**: Oh My ZSH initialization, themes, plugins
- **Bash**: Bash completion, bash settings

### Step 2: Common Exports
File: `~/.exports`
- Environment variables (EDITOR, LANG, etc.)
- Python/Node settings
- Tool configurations

### Step 3: Common Aliases
File: `~/.aliases`
- Directory shortcuts (cd .., cd -, etc.)
- Common commands (l, la, ls, grep, etc.)
- Tool aliases (g for git, etc.)

### Step 4: Modular Functions
Directory: `~/.functions.d/*.sh`
Sourced by loop in both shells:
```bash
for func_file in ~/.functions.d/*.sh; do
    [ -r "${func_file}" ] && [ -f "${func_file}" ] && source "${func_file}";
done;
```

Includes:
- `git.sh` - Git helpers
- `system.sh` - System utilities
- `productivity.sh` - Productivity tools
- Custom files - User additions

### Step 5: Secrets
File: `~/.bash_secrets`
Contains environment variables for:
- API keys and tokens
- Database credentials
- Tool-specific secrets

### Step 6: Profile Files (Tool-Specific)
Order matters - later files override earlier ones:
1. `~/.github_profile`
2. `~/.aws_profile`
3. `~/.gcloud_profile`
4. `~/.azure_profile`
5. Add more tool profiles as needed

Each profile file should contain tool-specific configuration without assuming other tools are set up.

### Step 7: User Customizations
Files (sourced last to allow override):
- `~/.bashrc.local` (Bash only)
- `~/.zshrc.local` (ZSH only)

## Key Design Principles

### 1. POSIX Compatibility
All shared code (exports, aliases, functions) uses POSIX-compatible shell syntax so it works identically in Bash and ZSH.

**What this means:**
- No `[[ ]]` conditionals - use `[ ]` instead
- No bash arrays - use variables or function arguments
- No bash-specific string operations
- Functions tested in both shells

### 2. Unified Common Configuration
Bash and ZSH both source the same files:
- `.exports` - Same environment variables
- `.aliases` - Same shortcuts
- `.functions.d/` - Same functions

This means if you update `.exports`, both shells see the change.

### 3. Shell-Specific Customization
Each shell can have its own configuration for features unique to that shell:
- **ZSH**: Oh My ZSH plugins, themes, advanced completion
- **Bash**: Bash completion, bash-specific options

### 4. Tool-Specific Profiles
Each tool gets its own profile file (`.tool_profile`) so:
- Profiles are independent - one broken profile doesn't break others
- Credentials stay in `.bash_secrets`, not in `~/.zshrc`
- Tools can be added/removed without modifying main rc files

## Changing Configuration

### Add an Export (Variable)
Edit `~/.exports`:
```bash
export MY_VARIABLE="value"
```
Both shells will have this variable.

### Add an Alias
Edit `~/.aliases`:
```bash
alias myalias='command with args'
```
Both shells will have this alias.

### Add a Function
Create or edit file in `~/.functions.d/`:
```bash
# ~/.functions.d/my_functions.sh
my_function() {
  # POSIX-compatible code
  echo "Hello"
}
```
Both shells will have this function.

### Add a Secret/Credential
Edit `~/.bash_secrets`:
```bash
export API_KEY="secret_value"
```
Keep permissions at 600: `chmod 600 ~/.bash_secrets`

### Add Tool-Specific Configuration
Create `~/.tool_profile`:
```bash
# ~/.github_profile
export GITHUB_TOKEN="your_token"
export GH_PAGER="cat"
```

This file is sourced after common aliases and functions, so you can use them.

### Add User-Specific Customization
Create `~/.zshrc.local` (ZSH) or `~/.bashrc.local` (Bash):
```bash
# ~/.zshrc.local
# My custom ZSH settings that don't go in the repo
alias myspecial='my command'
```

These files are sourced last and ignored by git, so they're safe for personal customization.

## Troubleshooting

### Variable not available in shell
1. Check `~/.exports` - is it there?
2. Run `env | grep VARNAME` - is it set?
3. Run `echo $VARNAME` after sourcing: `source ~/.exports`
4. If in profile, make sure profile is sourced

### Function not found
1. Check `~/.functions.d/*.sh` - does it exist there?
2. Run `declare -f function_name` - is it defined?
3. Verify syntax: `bash -n ~/.functions.d/file.sh`
4. Try reloading: `source ~/.zshrc` or `source ~/.bash_profile`

### Alias not working
1. Check `~/.aliases` - is it defined?
2. Run `alias myalias` - is it set?
3. Make sure not shadowed by function or builtin: `type myalias`

### Variable conflict between profiles
Variables defined in later profiles override earlier ones. Profile sourcing order (listed in Step 6) determines precedence.

If you need a variable from profile A but profile B overwrites it:
1. Move profile B earlier in the load order, or
2. Consolidate into `.bash_secrets` or `.exports`

## Adding New Tools

When setting up a new tool (e.g., Rust):

1. **Create tool profile**: `~/.rust_profile`
```bash
# ~/.rust_profile
export RUSTUP_HOME="$HOME/.rustup"
export CARGO_HOME="$HOME/.cargo"
export PATH="$PATH:$HOME/.cargo/bin"
```

2. **Add to sourcing order in `.zshrc` and `.bash_profile`** (optional, if special handling needed)

3. **Or apply to all** by using `.bash_secrets` or `.exports` for common settings

4. **Tool-specific variables** go in the tool profile file

## Platform Notes

### macOS/BSD Specifics
- Uses `stat -f` for file attributes (not GNU `stat -c`)
- Uses BSD `sed` (different options than GNU sed)
- Uses BSD `grep` (slightly different defaults)
- Homebrew installs to `/opt/homebrew/` on Apple Silicon

These dotfiles are optimized for macOS and will work on BSD systems. Some functions may need adjustment for Linux if needed.

## See Also

- [CONTRIBUTING.md](../CONTRIBUTING.md) - Function development guidelines
- [README.md](../README.md) - Setup and installation
- https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/ - Shell startup details
