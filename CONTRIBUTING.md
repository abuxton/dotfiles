# Contributing to Dotfiles

This project optimizes shell configuration for macOS/BSD systems using ZSH as primary shell with simplified Bash support.

## Shell Compatibility Requirements

All functions and shared shell scripts must use **POSIX-compatible** shell syntax to work identically in both Bash and ZSH.

### What to Avoid

Your functions must NOT use these bash-specific features:

#### ❌ Bash-specific conditionals
```bash
# DON'T use [[ ]] - this is bash-specific
if [[ "$var" == "value" ]]; then
  ...
fi

# DO use [ ] instead - POSIX compatible
if [ "$var" = "value" ]; then
  ...
fi
```

#### ❌ Arrays
```bash
# DON'T use bash arrays
my_array=("item1" "item2" "item3")
for item in "${my_array[@]}"; do
  echo "$item"
done

# DO use simple variables or parameters instead
# Pass multiple arguments instead of using arrays
my_function() {
  for item in "$@"; do
    echo "$item"
  done
}
```

#### ❌ Bash-specific string operations
```bash
# DON'T use parameter expansion
${var:0:5}        # substring
${var#*pattern}   # prefix removal (ZSH has different behavior)

# DO use sed/cut which work identically
echo "$var" | cut -c1-5
echo "$var" | sed 's/.*prefix//'
```

#### ❌ Associative arrays (ZSH-specific)
```bash
# DON'T use
declare -A my_map
my_map["key"]="value"

# DO use environment variables or function parameters
KEY="value"
```

#### ❌ Command substitution with backticks
```bash
# DON'T use (can cause nesting issues)
result=`command`

# DO use $() syntax
result=$(command)
```

### What to Use

#### ✅ POSIX-compatible conditionals
```bash
# Simple equality test
if [ "$var" = "value" ]; then
  ...
fi

# Test if file exists
if [ -f "$file" ]; then
  ...
fi

# Test if directory exists
if [ -d "$dir" ]; then
  ...
fi

# Chain conditions with && and ||
if [ -f "$file" ] && [ -r "$file" ]; then
  ...
fi

# Multiple conditions
if [ "$var1" = "a" ] || [ "$var2" = "b" ]; then
  ...
fi
```

#### ✅ Variables and word splitting
```bash
# Use double quotes to protect variables
echo "Hello $name"

# Use unquoted for intentional splitting
for file in *.txt; do
  process "$file"
done

# Indirect variable reference
eval value=\$$var_name  # Use cautiously, documented as eval
```

#### ✅ Functions with flexible arguments
```bash
# Accept multiple arguments
my_function() {
  for item in "$@"; do
    process "$item"
  done
}

# Use $1, $2, $3... for positional args
my_func() {
  local first="$1"
  local second="$2"
  echo "$first and $second"
}
```

#### ✅ Command substitution
```bash
# Always use $() syntax
result=$(command)
file_count=$(find . -name "*.sh" | wc -l)
```

#### ✅ Local variables in functions
```bash
my_function() {
  local my_var="value"    # POSIX-compatible
  local count=0
  ...
}
```

#### ✅ Globbing and wildcards
```bash
# File globbing works identically
find . -name "*.js"
for file in "$dir"/*.md; do
  process "$file"
done
```

## Deployment Responsibilities

When contributing new files to this dotfiles repository, it's important to understand how and when your files get deployed to user machines.

### Two-Script Deployment Model

Dotfiles uses a two-script approach:

#### bootstrap.sh (First-Time Setup)
- **When**: Run once per machine (first-time deployment)
- **Method**: rsync (copies files from repo to $HOME)
- **Non-idempotent**: Will overwrite existing files (don't re-run)
- **Responsibilities**:
  - `git pull origin main` - Update repo to latest
  - Install oh-my-zsh shell framework
  - Bulk deploy files via rsync
  - Install global npm packages
  - Run shell reload

#### setup.sh (Idempotent Configuration)
- **When**: Run anytime to reconfigure (safe to run many times)
- **Method**: Symlinks (creates links from repo to $HOME)
- **Fully idempotent**: Safe to run multiple times
- **Responsibilities**:
  - Create required directories (`~/.functions.d`, `~/.config`)
  - Create symlinks for dotfiles (including new files auto-detected)
  - Deploy profile system (22+ language/ecosystem profiles)
  - Copy function modules with size comparison
  - Validate installation

### Adding New Files: What Gets Deployed Where?

When you add a new file to the repository, here's how it will be deployed:

#### ✅ Automatically Deployed

**Shell dotfiles** (`.bash_profile`, `.zshrc`, etc.):
- Handled by setup.sh Step 3: Main dotfile symlinks
- Line reference: setup.sh lines 375-396

**Profile files** (`.*_profile`):
- Handled by setup.sh Step 3c: Profile loop
- Line reference: setup.sh lines 414-424
- How: `for profile in .*_profile; do ln -sf "$profile" ~/"$profile"; done`
- **Key point**: ALL `.*_profile` files automatically symlinked—no code changes needed!

**Function modules** (`~/.functions.d/*.sh`):
- Handled by setup.sh Step 4: Function module copying
- Line reference: setup.sh lines 427-452
- How: Copy with size comparison (skip if target is newer)
- **Key point**: Individual `.sh` files automatically copied

**Configuration files** (`.gitconfig`, `.tmux.conf`, etc.):
- Handled by bootstrap.sh: rsync-copied
- Handled by setup.sh Step 3: symlinked (if added to symlink loop)
- Both: respect the file type pattern

#### ⚙️ Requires Code Changes

**New directories** not yet in deployment lists:
- Add to setup.sh Step 1 (mkdir -p)
- Or add to bootstrap.sh rsync exclusion review

**New dotfiles with different deployment method**:
- May require adding to setup.sh Step 3 symlink loop
- Contact repo maintainer to discuss

**Tool-specific configurations** (e.g., `.claude/`, `.opencode/`):
- Currently unmapped (optional)
- Could be added to setup.sh: (future enhancement)

#### 📂 Never Deployed (Repository Infrastructure)

These stay in the repo and never get deployed to $HOME:
- `.git/` - Version control
- `.github/` - GitHub Actions, workflows
- `docs/` - Documentation
- `openspec/` - Workflow tracking
- `.gitignore`, `LICENSE*.txt` - Git infrastructure
- Test/CI files

### Adding New Directories

If you're adding a new directory that should be deployed:

1. **Is it a config directory?**
   - ✅ Add to setup.sh Step 1 (`mkdir -p`)
   - Example: `.zsh.d/`, `.vim/`, `.config/`

2. **Is it a tool-specific config archive?**
   - ✅ Consider adding to deployment (discuss with maintainer)
   - Example: `.vscode/`, `.claude/`, `.opencode/`

3. **Is it project infrastructure?**
   - ❌ Keep in repo only (don't deploy)
   - Example: `.github/`, `docs/`, `openspec/`

### Adding New Dotfiles

If you're adding a new dotfile (file starting with `.`):

1. **Shell configuration** (`.bash_*`, `.zsh*`, etc.)
   - Automatically handled by bootstrap.sh rsync
   - Automatically handled by setup.sh symlink loop (if matching pattern)

2. **Tool profile** (`.{toolname}_profile`)
   - Automatically handled by setup.sh Step 3c profile loop
   - **No code changes needed!** Just add the file and commit

3. **Application config** (`.gitconfig`, `.tmux.conf`, etc.)
   - Add to bootstrap.sh by default (rsync includes it)
   - Add to setup.sh Step 3 if needs special handling

### Examples: Where Do New Contributions Go?

| Contribution | Where | Deployed | Handler |
|---|---|---|---|
| `.kubernetes_profile` | repo root | ✅ Auto | setup.sh Step 3c |
| `.functions.d/docker.sh` | functions.d/ | ✅ Auto | setup.sh Step 4 |
| `.config/myapp/` | .config/myapp/ | ✅ Auto | bootstrap.sh rsync |
| utility script | bin/ | ✅ Auto | bootstrap.sh rsync |
| `.gitconfig` changes | repo root | ✅ Auto | setup.sh Step 3 |
| documentation | docs/ | ❌ No | stays in repo |

### Deployment Verification

After adding a new file, verify deployment:

```bash
# 1. Run setup.sh in dry-run mode
./setup.sh --dry-run | grep "your-new-file"

# 2. Run setup.sh for real
./setup.sh

# 3. Verify the file deployed
ls -la ~/ | grep "your-new-file"

# 4. For symlinked files, verify the symlink
ls -la ~/.your_new_file
# Should show: your_new_file -> /path/to/repo/your_new_file
```

### Deployment Decision Tree

When adding a new file, ask:

```
Is it a profile file (.{toolname}_profile)?
├─ YES → Just add it, setup.sh auto-deploys via Step 3c loop
│
└─NO
  │
  Is it a function module (.functions.d/*.sh)?
  ├─ YES → Just add it, setup.sh auto-deploys via Step 4 copy loop
  │
  └─NO
    │
    Is it a shell configuration file?
    ├─ YES → bootstrap.sh rsync handles it
    │
    └─NO
      │
      Is it a tool config (.{tool}config, .{tool}rc)?
      ├─ YES → Add to setup.sh Step 3 symlink list (or PR for discussion)
      │
      └─NO → Likely repo-only (put in .gitignore or docs/)
```

### Communicating Deployment Needs

When submitting a PR with new files:

1. **Mention your files** in the PR description:
   ```
   Added: .myapp_profile (new tool profile for MyApp)
   Modified: .functions.d/myapp.sh (helper functions)
   Status: Should auto-deploy via existing setup.sh patterns
   ```

2. **If special deployment needed**, note it:
   ```
   Added: .myapp/ (new config directory)
   TODO: Needs to be added to setup.sh Step 1 mkdir-p list
   ```

3. **Link to deployment docs**:
   ```
   See docs/DEPLOYMENT_MATRIX.md and docs/DEPLOYMENT_WORKFLOW.md
   for how this integrates with the deployment system
   ```

## Function Organization

Functions are organized by domain in the `.functions.d/` directory:

- **git.sh** - Git helper functions
- **system.sh** - System utilities
- **productivity.sh** - Productivity tools

### Adding New Functions

1. **Choose the appropriate file** or create a new domain-specific file (e.g., `docker.sh` for Docker functions)

2. **Use proper header documentation**:
```bash
#!/usr/bin/env bash
# Domain of functions
# Brief description of what this module contains

# Function name with clear purpose
function_name() {
  # Brief description of what it does
  #
  # Usage: function_name [arguments]
  # Example: function_name "arg1" "arg2"

  local arg1="$1"
  local arg2="$2"
  ...
}
```

3. **Document parameters and outputs**:
```bash
my_function() {
  # Extract files modified in last N days
  # Parameters: days (default: 1)
  # Output: file names, one per line

  local days="${1:-1}"
  find . -mtime -"$days" -type f
}
```

4. **Test in both shells**:
```bash
# Test in bash
bash -c 'source ~/.bash_profile; my_function arg1 arg2'

# Test in zsh
zsh -c 'source ~/.zshrc; my_function arg1 arg2'
```

## Shell Startup Configuration

### ZSH Configuration (`.zshrc`)

The workflow for ZSH is:
1. `.zshrc` sources common exports/aliases/functions
2. `.functions.d/*.sh` files are sourced
3. Profile files (`.<name>_profile`) are sourced in documented order
4. User-customizations (`.zshrc.local`) are sourced last

### Bash Configuration (`.bash_profile`)

The workflow for Bash is:
1. `.bash_profile` (login shell) sources common exports/aliases
2. `.functions.d/*.sh` files are sourced
3. Profile files (`.<name>_profile`) are sourced in documented order
4. User-customizations (`.bashrc.local`) are sourced last

Note: `.bashrc` is sourced by `.bash_profile` for interactive shells.

## Testing Your Functions

Before committing, test your functions:

```bash
# Source the files manually
source ~/.bash_profile
source ~/.zshrc

# Test individual functions
git_current_branch
mkd /tmp/test_dir
todo "add this task"

# Run the validation script
./validate-dotfiles.sh
```

## Running the Validation

After making changes, run:

```bash
./validate-dotfiles.sh
```

This checks:
- All symlinks are correct
- Function modules are installed
- Permissions are secure
- Shell configuration is complete

## Committing Changes

When ready to commit:

1. Verify functions work in both shells
2. Run `validate-dotfiles.sh` and verify all checks pass
3. Update `CHANGELOG.md` if adding significant features
4. Commit with clear message:
   ```
   feat(functions): add docker helper functions
   ```

Use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation updates
- `refactor:` for code refactoring without behavior changes

## Cross-Platform Notes

### macOS/BSD Differences

Most functions will work identically on macOS and BSD. Watch for:

- `sed` differences (macOS uses BSD sed, Linux uses GNU sed)
  - Use `-e` before regex instead of inline: `sed -e 's/pattern/replace/' file`

- `find` syntax can differ
  - Use `-type f` instead of relying on defaults
  - Be explicit with `-path` patterns

- `ls` options vary
  - Use `find` for recursive operations rather than `ls -R`

### Utilities to Prefer

Prefer these (available on all POSIX systems):
- `grep`, `sed`, `awk` for text processing
- `find` for file operations
- `cut`, `tr` for string manipulation
- `printf` instead of `echo` for precise output

Avoid these (platform-specific):
- `gstat` (GNU), use `stat` with BSD flags
- `brew` commands (Homebrew-specific)

## Contributing Profiles

Profiles are tool-specific configuration files that extend the shell environment. If you'd like to contribute a new profile:

### Adding a New Profile

1. **Create the profile file** in the dotfiles repo:
   ```bash
   touch ~/dotfiles/.{toolname}_profile
   ```

2. **Add a descriptive header**:
   ```bash
   #!/usr/bin/env bash
   # {Tool Name} Configuration
   # Description of what this profile does
   # Dependencies: {other tools/profiles if any}
   ```

3. **Keep it focused**: One profile = one tool/domain
   - ✅ `.python_profile` - Python/pyenv setup
   - ✅ `.aws_profile` - AWS CLI configuration
   - ❌ `.languages_profile` - Multiple tools (too broad)

4. **Handle missing dependencies**:
   ```bash
   # Check before using
   if ! [ -x "$(command -v pyenv)" ]; then
     return  # or: echo "Warning: pyenv not installed"
   fi
   ```

5. **Make it shell-compatible**:
   ```bash
   # ZSH-specific features
   if [ -n "$ZSH_VERSION" ]; then
     autoload -U compinit && compinit  # ZSH completions
   fi
   ```

6. **Handle secrets properly**:
   ```bash
   # Profile contains public configuration
   export PUBLIC_VAR="value"

   # But prompt for or source private configuration
   [ -f "$HOME/.bash_secrets" ] && source "$HOME/.bash_secrets"
   ```

7. **Document the profile** in `docs/PROFILE_GUIDE.md`:
   - What it does
   - Dependencies
   - How to configure it
   - Common issues/troubleshooting

8. **Test both shells**:
   ```bash
   bash -n ~/dotfiles/.{toolname}_profile    # Check syntax
   bash -c 'source ~/dotfiles/.{toolname}_profile && echo OK'
   zsh -c 'source ~/dotfiles/.{toolname}_profile && echo OK'
   ```

### Profile Naming Convention

Profiles use this naming pattern: `.{toolname}_profile`

- Use lowercase tool name
- Use underscore separators: `.my_tool_profile` (not `.myToolProfile`)
- Include in commit with a message like: "Add .{toolname}_profile configuration"

Examples:
- `.python_profile` ✅
- `.rust_profile` ✅
- `.kubernetes_profile` ✅
- `.my-tool_profile` ❌ (use underscore, not dash)
- `.myToolProfile` ❌ (use lowercase and underscores)

### Profile Loading Order

Profiles are sourced in this order (edit `.bash_profile` and `.zshrc` if changing):

1. **Language managers** (set up runtimes first)
   - `.python_profile`, `.ruby_profile`, `.go_profile`, `.rust_profile`, `.node_profile`
2. **Cloud platforms** (depends on languages)
   - `.aws_profile`, `.azure_profile`, `.gcloud_profile`
3. **DevOps tools** (depends on clouds)
   - `.docker_profile`, `.kubernetes_profile`, `.rancher_profile`
4. **Package managers**
   - `.brew_profile`
5. **Services and platforms**
   - `.github_profile`, `.openai_profile`, etc.

Add new profiles to the appropriate category in both shell rc files.

### Testing Your Contribution

Before submitting:

```bash
# 1. Syntax check
bash -n ~/dotfiles/.{toolname}_profile
zsh -n ~/dotfiles/.{toolname}_profile

# 2. Functionality test
source ~/dotfiles/.{toolname}_profile
# Verify expected environment variables/aliases

# 3. Run validation
bash validate-dotfiles.sh

# 4. Verify setup.sh still works
bash setup.sh --dry-run | grep {toolname}

# 5. Test on fresh shell
exec zsh
# Verify profile loaded without errors
```

### Documentation Requirements

When adding a profile, update:

1. **docs/PROFILE_GUIDE.md** - Add profile to table and describe it
2. **docs/LANGUAGE_ECOSYSTEM.md** - If it's a language tool
3. **docs/PACKAGE_MANAGER_GUIDE.md** - If it manages packages
4. **README.md** - If it's major/important

## Contributing Shell Functions

When adding new shell functions to `~/.functions.d/`:

### File Organization
- One tool per file: `git.sh` for git functions, `system.sh` for system utilities
- Use `.sh` extension for clarity
- Keep related functions in the same file

### Function Guidelines

```bash
# Good function template
function my_function() {
  # Description
  local var1="$1"
  local var2="$2"

  # Implementation using POSIX-compatible features
  if [ -z "$var1" ]; then
    echo "Usage: my_function <arg1> [arg2]" >&2
    return 1
  fi

  # Do work
  return 0
}

# Export if it should be available in subshells
export -f my_function
```

### Documentation
- Add comments explaining what the function does
- Document expected arguments
- Show usage examples

## Questions?

Refer to:
- POSIX Shell Reference: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
- Bash vs ZSH: https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/
- The .d Pattern: https://chr4.org/posts/2014-09-10-conf-dot-d-like-directories-for-zsh-slash-bash-dotfiles/
- [PROFILE_GUIDE.md](docs/PROFILE_GUIDE.md) - Comprehensive profile documentation
