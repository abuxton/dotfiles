# Package Manager Manifests & Consolidation Guide

This document outlines the current package management approach and the future consolidation strategy for dotfiles' language ecosystems.

## Current State: Profile-Based Configuration

Currently, package selection is embedded in shell profiles (e.g., `.python_profile`, `.ruby_profile`). Global packages are installed via:
- Language manager hooks (e.g., `eval "$(pyenv init -)`)
- Imperative commands (`pip install`, `gem install -g`, `npm install -g`)
- Homebrew via `brewfile-setup.sh`

**Current Approach Benefits**:
- ✅ Immediate, declarative configuration
- ✅ No extra dependency manifests to maintain
- ✅ Quick setup for development

**Current Approach Limitations**:
- ❌ Imperative installations not reproducible
- ❌ No declarative record of what's installed
- ❌ Difficult to track version pinning
- ❌ Hard to diff changes to package sets
- ❌ Collaborators must discover packages manually

## Future State: Manifest-Based Configuration

Future iterations will consolidate package management by using native manifest files:

```
Current                          Future (Proposed)
─────────────────────────────────────────────────────
eval "$(pyenv init -)"           pyenv init via profile (unchanged)
  + manual `pip install`         → pyproject.toml (project-level)
  + manual `pip install -g`      → requirements-global.txt (system-level)

eval "$(rbenv init -)"           rbenv init via profile (unchanged)
  + manual `gem install -g`      → Gemfile + gemspec (declarative)

go install github.com/...        → go-tools.manifest (declarative)

npm i -g ...                     → package.json (root level)

cargo install ...                → Cargo.toml w/ [bin] section
```

## Package Manager Manifest Templates

### Python: pyproject.toml & requirements.txt

**Location**: `~/dotfiles/pyproject.toml` (optional, for future use)

**Purpose**: Declarative Python global packages and tool configuration

**Structure** (PEP 518/PEP 621 format):

```toml
[project]
name = "dotfiles-python"
version = "1.0.0"
description = "Global Python tools for dotfiles environment"
requires-python = ">=3.9"
dependencies = []

[project.optional-dependencies]
# Global tools installed to user environment
global = [
    "pipx>=1.0.0",           # Virtual env manager for CLI tools
    "argcomplete>=2.0",      # Bash/ZSH completion for argparse CLI
    "black>=22.0",           # Code formatter
    "isort>=5.0",            # Import sorter
    "pytest>=7.0",           # Test framework
    "mypy>=0.950",           # Type checker
    "flake8>=4.0",           # Linter
    "pylint>=2.0",           # Code analysis
    "ipython>=8.0",          # Interactive shell
    "jupyter>=1.0",          # Notebook environment
]

# Alternative: Use pyenv + pip
# Global packages installed to: $PYENV_ROOT/versions/X.Y.Z/bin/

[tool.black]
line-length = 100
target-version =['py39', 'py310', 'py311']

[tool.isort]
profile = "black"
line_length = 100
```

**Alternative: requirements-global.txt** (simpler)

```
# Global Python utilities (installed to user .local or venv)
# Installation: pip install -r requirements-global.txt

pipx>=1.0.0
argcomplete>=2.0
black>=22.0
isort>=5.0
pytest>=7.0
mypy>=0.950
flake8>=4.0
pylint>=2.0
ipython>=8.0
jupyter>=1.0
```

**Installation** (when manifest-based approach is adopted):

```bash
# Via pipx (isolated virtual environments)
pipx install pipx  # Bootstrap
pipx install black isort pytest mypy

# Via direct pip (single environment)
pip install --user -r requirements-global.txt

# Via pyenv (to a specific Python version)
eval "$(pyenv init --path)"
pip install -r requirements-global.txt
```

### Ruby: Gemfile & .ruby-version

**Location**: `~/dotfiles/Gemfile` (optional, for future use)

**Purpose**: Declarative Ruby global gems and version management

**Structure** (Bundler format):

```ruby
# Gemfile - Define Ruby global gems
# Version management via rbenv + .ruby-version

source "https://rubygems.org"

# Global gems installed to rbenv's gem directory
gem "rspec"           # Testing framework
gem "bundler"         # Dependency management (usually pre-installed)
gem "rake"            # Task automation
gem "rubocop"         # Code linter
gem "erb-lint"        # Template linter
gem "jekyll"          # Static site generator (optional)
gem "octoprint-cli"   # OctoPrint CLI (if used)
gem "colorls"         # Colored directory listing
```

**With .ruby-version file** (sets Python version):

```
3.3.0
```

**Installation** (when manifest-based approach is adopted):

```bash
# Install all gems
bundle install --global

# Or install specific gems
gem install rspec bundler rake rubocop

# Via rbenv with .ruby-version
rbenv install 3.3.0
bundle install --gemfile ~/dotfiles/Gemfile
```

### Go: go-tools.manifest

**Location**: `~/dotfiles/go-tools.manifest` (optional, for future use)

**Purpose**: Declarative Go tools and versions

**Structure** (custom manifest format):

```
# go-tools.manifest - Go development tools
# Format: tool_name version_or_repo
# Installed to: $GOBIN (typically ~/golang/bin)

# Code quality tools
golang.org/x/lint/golint@latest
golang.org/x/tools/cmd/goimports@latest
github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Development utilities
github.com/mattn/gom@latest
github.com/nao1215/gup@latest
github.com/ericchiang/pup@latest
github.com/gulyasm/jsonui@latest

# Optional: Add versions for reproducibility
# golang.org/x/tools/cmd/gopls@v0.12.0
# github.com/cosmtrek/air@v1.40.0
```

**Installation Workflow**:

```bash
# Parse manifest and install each tool
while IFS= read -r tool; do
  [ -z "$tool" ] || [ "$tool" = "${tool#\#}" ] || continue  # Skip comments
  go install "$tool"
done < go-tools.manifest
```

### Node.js/npm: package.json

**Location**: `~/dotfiles/package.json` (optional, for future use)

**Purpose**: Declarative npm global packages

**Structure** (npm package format):

```json
{
  "name": "dotfiles-node",
  "version": "1.0.0",
  "description": "Global npm tools for dotfiles environment",
  "engines": {
    "node": ">=16.0.0",
    "npm": ">=8.0.0"
  },
  "dependencies": {},
  "devDependencies": {},
  "scripts": {
    "install-global": "npm install -g --prefer-global $(cat ./npm-packages.txt | tr '\\n' ' ')"
  }
}
```

**Alternative: npm-packages.txt** (simpler, one package per line):

```
# Global npm packages (installed to NPM_HOME)
# Installation: npm install -g $(cat npm-packages.txt | tr '\\n' ' ')

@angular/cli
create-react-app
typescript
ts-node
eslint
prettier
@nestjs/cli
webpack-cli
express-generator
http-server
```

**Installation** (when manifest-based approach is adopted):

```bash
# Install all global packages
npm install -g $(cat npm-packages.txt | tr '\\n' ' ')

# Or via npm scripts
npm run install-global

# Individual installation
npm install -g @angular/cli create-react-app typescript
```

### Rust: Cargo.toml with [bin]

**Location**: `~/dotfiles/Cargo.toml` (optional, for future use)

**Purpose**: Declarative Rust tools and utilities

**Structure** (Cargo package format):

```toml
[package]
name = "dotfiles-rust"
version = "1.0.0"
edition = "2021"

# Binary tools to install
[[bin]]
name = "ripgrep"
path = "src/bins/ripgrep.sh"

[[bin]]
name = "fd"
path = "src/bins/fd.sh"

# Or simpler: just list them
# cargo-watch
# cargo-audit
# cargo-update
```

**Alternative: rust-tools.manifest** (simpler):

```
# Rust development tools
# Installed to: ~/.cargo/bin (via cargo install)

ripgrep                  # Fast grep alternative
fd                       # Fast find alternative
cargo-watch              # Auto-rebuild on changes
cargo-audit              # Security vulnerability scanner
cargo-update             # Update Rust dependencies
cargo-edit               # Edit Cargo.toml from CLI
cargo-expand             # Expand Rust macros
```

**Installation** (when manifest-based approach is adopted):

```bash
# Install all tools
cat rust-tools.manifest | grep -v '^#' | xargs -I {} cargo install {}

# Individual installation
cargo install ripgrep fd cargo-watch cargo-audit
```

## Consolidation Phases

### Phase 1: Current (Pre-Consolidation)

**Status**: ✅ Implemented

- Profiles explicitly loaded from `~/.{python,ruby,...}_profile`
- Package installations embedded in profiles
- No separate manifests
- Audit and documentation complete

**Example Profile**:
```bash
# .python_profile
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
autoload -U compinit && compinit
# Packages are installed manually or in setup scripts
```

### Phase 2: Proposed (Manifests Available)

**When**: Next iteration (if adopted)

- Keep existing profiles (no breaking changes)
- Add optional manifest files (`pyproject.toml`, `Gemfile`, `go-tools.manifest`)
- Documentation guides users on optional adoption
- Migration guides for moving to manifests

**Example**:
```bash
# .python_profile (unchanged)
eval "$(pyenv init --path)"
# New: Optional sourcing of manifest-based tools
# [ -f ~/.dotfiles/pyproject.toml ] && pip install -r requirements-global.txt
```

### Phase 3: Adoption (Active Migration)

**When**: After community feedback (optional future step)

- Provide `migrate.sh` script to convert existing setups
- Update setup.sh to offer manifest-based installation
- Maintain backwards compatibility (profiles still work)
- Reduce duplicate package declarations

**Example Migration Script**:
```bash
#!/bin/bash
# migrate-to-manifests.sh

# Backup current setup
cp .python_profile .python_profile.bak

# Generate pyproject.toml from installed packages
pip list --format=json > /tmp/installed.json

# Prompt user
read -p "Use manifest-based package management? (y/n)" -n 1
if [[ $REPLY =~ ^[Yy]$ ]]; then
  cp pyproject.toml.template pyproject.toml
  # Edit and customize
fi
```

### Phase 4: Standard (Manifests Canonical)

**When**: Only if strong community adoption (optional future step)

- Manifests become the source of truth
- Profiles delegate to manifests
- Significantly reduced profile complexity
- Clear separation: shell configs vs. package management

## Consolidation Benefits

### Reproducibility
```bash
# Current: "Works on my machine" problem
eval "$(pyenv init -)"
# Run setup.sh
# Manually: pip install black isort pytest

# Future: Deterministic
eval "$(pyenv init -)"
pip install -r requirements-global.txt
# Always same packages, pinned versions
```

### Collaboration
```bash
# Current: Teammates discover packages organically
# "Oh, you need to install X for feature Y"

# Future: Clear declaration
# Manifest file lists all required tools
# Collaborators: "pip install -r requirements-global.txt" - done
```

### Version Control
```bash
# Current: Hard to track what changed
git diff setup.sh  # Shows lots of irrelevant changes

# Future: Focused diffs
git diff pyproject.toml  # Shows exactly which packages changed
```

### CI/CD Integration
```yaml
# Example: GitHub Actions with manifests
- name: Install Python tools
  run: pip install -r dotfiles/requirements-global.txt

- name: Install Node tools
  run: npm install -g $(cat dotfiles/npm-packages.txt)

- name: Install Go tools
  run: |
    while read tool; do
      go install "$tool"
    done < dotfiles/go-tools.manifest
```

## Migration Path (Optional)

For users wanting to adopt manifests:

1. **Document current packages** (optional audit)
   ```bash
   pip list > python-packages.txt
   gem list > ruby-packages.txt
   go list -m all > go-packages.txt
   npm list -g > node-packages.txt
   ```

2. **Create manifest files** (from templates in this guide)

3. **Test manifest-based installation** on new machine or in container

4. **Update profiles** to source from manifests (or keep both)

5. **Migrate CI/CD** to use manifests

## Recommendations by Ecosystem

| Ecosystem | Recommended Approach | Reason |
|-----------|----------------------|--------|
| **Python** | requirements-global.txt | Simple, widely understood, easy to maintain |
| **Ruby** | Gemfile + Bundler | Standard Ruby approach, excellent version management |
| **Go** | go-tools.manifest | Custom (no standard), but simple to parse/execute |
| **Node.js** | npm-packages.txt | Simple, avoids package.json complexity |
| **Rust** | rust-tools.manifest | Custom, simple format, easy to parse |
| **Homebrew** | Brewfile | Already using! Keep as-is |

## See Also

- [LANGUAGE_ECOSYSTEM.md](./LANGUAGE_ECOSYSTEM.md) - Language manager setup and initialization
- [DEPLOYMENT.md](./DEPLOYMENT.md) - How deployment scripts work together
- [PROFILE_GUIDE.md](./PROFILE_GUIDE.md) - Creating and managing profiles
- [openspec/changes/audit-profile-deployment-package-managers/](../openspec/changes/audit-profile-deployment-package-managers/) - OpenSpec change tracking this work
