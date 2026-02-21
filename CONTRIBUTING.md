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
