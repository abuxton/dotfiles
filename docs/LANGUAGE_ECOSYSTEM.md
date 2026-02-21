# Language Ecosystem Initialization Guide

This document explains how language managers are initialized in dotfiles, their initialization order, and why order matters.

## Table of Contents

1. [Overview](#overview)
2. [Language Manager Profiles](#language-manager-profiles)
3. [Initialization Order](#initialization-order)
4. [Why Order Matters](#why-order-matters)
5. [Profile Details](#profile-details)
6. [Testing Language Initialization](#testing-language-initialization)
7. [Troubleshooting](#troubleshooting)

## Overview

Dotfiles supports multiple programming language ecosystems, each with its own package manager and development environment. These are configured via **language-specific profiles** (`.python_profile`, `.ruby_profile`, etc.) which are sourced during shell startup.

### Current Language Support

| Language | Manager | Profile | Status |
|----------|---------|---------|--------|
| Python | pyenv | `.python_profile` | ✅ Active |
| Ruby | rbenv | `.ruby_profile` | ✅ Active |
| Go | go install | `.go_profile` | ✅ Active |
| Rust | rustup/cargo | `.rust_profile` | ✅ Active |
| Node.js | npm | Not configured | ⏸️ Planned |
| Perl | perl | Not configured | ⏸️ Planned |

## Language Manager Profiles

### Python (.python_profile)

**Manager**: pyenv - Python version management via `~/.pyenv`

**Initialization**:
```bash
# Set up build flags for common libraries
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"

# Set PYENV_ROOT and add to PATH
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:/Users/abuxton/.local/bin:$PATH"

# Initialize pyenv in shell (enables switching Python versions)
eval "$(pyenv init --path)"

# ZSH completions
autoload -U compinit && compinit

# Python argcomplete for pip
eval "$(register-python-argcomplete pipx)"
```

**Key Features**:
- Manages multiple Python versions simultaneously
- Auto-switches Python based on `.python-version` file
- Builds Python from source (uses build flags above)
- Includes pip completion via argcomplete

**Aliases**:
- `gitdir` - Python3 utility for git operations
- `octoprint-serve` - OctoPrint server launch
- `octoprint` - Open OctoPrint web interface

**Dependencies**:
- `.uv_profile` - UV package manager (sourced at end)

### Ruby (.ruby_profile)

**Manager**: rbenv - Ruby version management via `~/.rbenv`

**Initialization**:
```bash
# Initialize rbenv in shell (enables switching Ruby versions)
eval "$(rbenv init -)"
```

**Key Features**:
- Manages multiple Ruby versions simultaneously
- Auto-switches Ruby based on `.ruby-version` file
- Integrates with colorls gem for colorized directory listings

**Aliases** (if colorls installed):
- `ls` → `colorls -h --sd -1`
- `ll` → `colorls -A --sd -l`
- `lc` → `colorls -lA --sd`
- `lgs` → `colorls -A --sd -l --gs`
- `treecl` → `colorls --tree`

### Go (.go_profile)

**Manager**: go install - Built-in Go module system (no version manager)

**Initialization**:
```bash
# Set GOPATH and GOBIN (where compiled binaries go)
export GOPATH=$HOME/golang
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# Set up Homebrew-installed Go (use libexec from Homebrew)
export GOROOT="$(brew --prefix golang)/libexec"
export PATH=$PATH:$GOROOT
export PATH=$PATH:$GOROOT/bin
```

**Key Features**:
- Single global Go version (typically via Homebrew)
- Uses go install for package management
- Auto-installs common development tools:
  - `golint` - Linter
  - `gom` - Go dependency manager
  - `gup` - Update checker

### Rust (.rust_profile)

**Manager**: rustup - Rust version and toolchain manager

**Initialization**:
```bash
# Ensure Homebrew-installed rustup is in PATH
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"

# Set CARGO_HOME and add bin directory
export PATH="${HOME}/.cargo/bin:$PATH"
```

**Key Features**:
- Manages Rust stable/beta/nightly versions
- cargo handles package installation
- Automatically installed global via Homebrew

## Initialization Order

Shell startup sequence for language managers:

### In .bash_profile (Bash)

```bash
# 1. Core shell setup (.bash_profile, .exports, .aliases, etc.)
# 2. Function modules (in alphabetical order from ~/.functions.d/)
# 3. Secrets (.bash_secrets)
# 4. Language managers (in explicit order):
#    - Language packages first (pyenv, rbenv, rustup, nvm)
#    - Then cloud CLIs (aws, azure, gcloud)
#    - Then devops/tools (docker, kubernetes)
#    - Then other services
# 5. Optional profiles (with error suppression)
```

### In .zshrc (Zsh)

```bash
# 1. Oh My Zsh framework setup
# 2. Core shell setup (.exports, .aliases, etc.)
# 3. Secrets (.bash_secrets)
# 4. Language managers (MANDATORY - must load):
#    - .python_profile
#    - .ruby_profile
#    - .go_profile
#    - .rust_profile
#    - .node_profile (if/when added)
#    - .perl_profile (if/when added)
# 5. Cloud platforms (aws, azure, gcloud)
# 6. DevOps tools (docker, kubernetes, etc.)
# 7. Optional supplementary profiles (with error suppression)
```

## Why Order Matters

Language managers MUST load in the correct order for two critical reasons:

### 1. PATH Resolution

Each manager modifies PATH to prepend its binary directory:

```
Initial PATH: /usr/bin:/usr/local/bin:...
After pyenv: ~/.pyenv/bin:/usr/bin:/usr/local/bin:...
After rbenv: ~/.rbenv/bin:~/.pyenv/bin:/usr/bin:/usr/local/bin:...
After rustup: ~/.cargo/bin:~/.rbenv/bin:~/.pyenv/bin:/usr/bin:/usr/local/bin:...
```

**Why it matters**: First match in PATH wins. If Python's bin directory isn't early, `which python` finds system Python instead of pyenv-managed Python.

### 2. Environment Variable Dependencies

Some tools depend on environment variables set by other managers:

- **Python tools** may use `CARGO_BIN` or `GOBIN` (if written in Rust/Go)
- **Ruby tools** may import Python libraries
- **Build tools** need access to all managed languages

**Why it matters**: Tool initialization can fail if dependencies aren't available yet.

## Profile Details

### Python Profile Deep Dive

The `.python_profile` is layered:

1. **Build Flags** - Required for compiling Python with zlib support
   ```bash
   export LDFLAGS="-L/usr/local/opt/zlib/lib"
   export CPPFLAGS="-I/usr/local/opt/zlib/include"
   ```
   Without these, `pyenv install` fails on some Python versions.

2. **pyenv Initialization** - Enables version switching
   ```bash
   eval "$(pyenv init --path)"  # Initialize (first time)
   eval "$(pyenv init --path)"  # Note: appears twice (not a duplicate, both needed)
   ```

3. **Shell Completions** - ZSH-specific
   ```bash
   autoload -U compinit && compinit  # Load ZSH completions
   ```

4. **Tool Completions** - pip with argcomplete
   ```bash
   eval "$(register-python-argcomplete pipx)"  # Bash/ZSH compatible
   ```

5. **UV Integration** - ZSH-specific package manager
   ```bash
   source ~/.uv_profile  # At the end for tool loading
   ```

\### Ruby Profile Deep Dive

The `.ruby_profile` is simpler:

1. **rbenv Initialization** - Enables version switching
   ```bash
   eval "$(rbenv init -)"
   ```

2. **Optional: colorls Integration** - Enhanced directory listings
   - Checks if colorls gem is installed
   - Sets aliases for colored output
   - Falls back gracefully if not installed

### Go Profile Deep Dive

The `.go_profile` is more declarative:

1. **Path Setup** - Required directories
   ```bash
   export GOPATH=$HOME/golang
   export GOBIN=$GOPATH/bin
   export PATH=$PATH:$GOBIN
   ```

2. **Homebrew Integration** - Uses Homebrew's Go installation
   ```bash
   export GOROOT="$(brew --prefix golang)/libexec"
   export PATH=$PATH:$GOROOT:$GOROOT/bin
   ```

3. **Auto-tool Installation** - Installs Go tools on first run
   ```bash
   [ -x "$(command -v golint)" ] || go install golang.org/x/lint/golint@latest
   [ -x "$(command -v gom)" ] || go install github.com/mattn/gom@latest
   [ -x "$(command -v gup)" ] || go install github.com/nao1215/gup@latest
   [ -x "$(command -v jsonui)" ] || go install github.com/ericchiang/pup@latest
   ```

## Testing Language Initialization

### Verify Language Manager is Available

```bash
# Test Python
python --version      # Should show pyenv Python
which python          # Should show ~/.pyenv/shims/python

# Test Ruby
ruby --version        # Should show rbenv Ruby
which ruby            # Should show ~/.rbenv/shims/ruby

# Test Go
go version            # Should show brew Go
which go              # Should show /usr/local/bin/go or similar

# Test Rust
rustc --version       # Should show rustup Rust
which rustc           # Should show ~/.cargo/bin/rustc
```

### Test Version Switching (pyenv/rbenv)

```bash
# List available Python versions
pyenv versions

# Switch to specific Python version
pyenv shell 3.12.0

# Verify switch
python --version      # Should show 3.12.0

# Go back to default
pyenv shell --unset

# List available Ruby versions
rbenv versions

# Switch Ruby version (similar to pyenv)
rbenv shell 3.3.0
```

### Debug Initialization

If a language manager isn't available:

```bash
# Check if profile is symlinked
ls -la ~/.python_profile
# Should show: ~/.python_profile -> /Users/username/dotfiles/.python_profile

# Try sourcing profile directly
source ~/.python_profile
# Should show no errors (or only minor warnings)

# Check PATH after sourcing
echo $PATH
# Should contain manager bin directories

# Test specific tool
pyenv --version
# Should work without error
```

## Troubleshooting

### Python not found or wrong version

**Symptom**: `python` not found, or points to system Python rather than pyenv

**Debug**:
```bash
which python          # Shows /usr/bin/python (wrong)
pyenv_version=($(pyenv versions))  # Arrays look weird

echo $PATH            # Check if ~/.pyenv/bin is early
source ~/.python_profile 2>&1 | head -20  # See any errors
```

**Solutions**:
1. Check if pyenv is installed: `ls -la ~/.pyenv`
2. Recreate symlinks: `bash setup.sh`
3. Reload shell: `exec zsh` or `exec bash`
4. Manual fix: `eval "$(pyenv init --path)"`

### Ruby gems not found

**Symptom**: `gem` or gems (like colorls) not found after install

**Debug**:
```bash
which gem              # Should show rbenv shim
rbenv versions         # Check current Ruby version
gem list               # List installed gems
```

**Solutions**:
1. Reinstall gem: `gem install colorls`
2. Update rbenv: `brew upgrade rbenv`
3. Switch Ruby then back: `rbenv shell 3.3.0 && rbenv shell --unset`

### Go tools not installing

**Symptom**: `go install` fails, permissions error, etc.

**Debug**:
```bash
go env GOPATH          # Should show ~/golang
ls -la ~/golang        # Must be writable
which go               # Should show /usr/local/bin/go or similar
```

**Solutions**:
1. Create golang directory: `mkdir -p ~/golang/{bin,src,pkg}`
2. Fix permissions: `chmod -R 755 ~/golang`
3. Reinstall Go: `brew reinstall go`

### Rust compiler not available

**Symptom**: `rustc` not found, or old version

**Debug**:
```bash
which rustc            # Should show ~/.cargo/bin/rustc
rustup toolchain list # Show installed toolchains
cargo --version       # Show cargo version
```

**Solutions**:
1. Install Rust: `brew install rustup`
2. Update Rust: `rustup update`
3. Source profile: `source ~/.rust_profile`

## See Also

- [DEPLOYMENT.md](./DEPLOYMENT.md) - How deployment scripts orchestrate setup
- [PROFILE_GUIDE.md](./PROFILE_GUIDE.md) - Creating and managing new profiles
- [SHELL_CONFIGURATION.md](./SHELL_CONFIGURATION.md) - Shell startup sequence, functions
- [docs/PROFILE_AUDIT.md](./PROFILE_AUDIT.md) - Complete profile audit and categorization
