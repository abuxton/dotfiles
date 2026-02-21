# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Profile Deployment & Management System
- **Profile Symlink Deployment** - All 22 `.*_profile` files now automatically symlinked by `setup.sh`
  - Explicit profile sourcing in `.bash_profile` and `.zshrc`
  - Shell-aware profile loading (bash skips ZSH-specific features, zsh loads all)
  - Documented sourcing order explaining why sequence matters
  - New `.node_profile` for Node.js/npm configuration

- **Enhanced Language Ecosystem Support** (Phase 5)
  - Python/pyenv initialization with completion hooks
  - Ruby/rbenv with colorls integration (bash-compatible)
  - Go/go install with auto-tool installation
  - Rust/rustup with cargo path setup
  - Node.js/npm global package management
  - Fixed `.ruby_profile` bash compatibility (global aliases)

- **Comprehensive Documentation** (Phases 4-8)
  - `docs/DEPLOYMENT.md` - Complete deployment workflow guide
  - `docs/LANGUAGE_ECOSYSTEM.md` - Language manager setup and initialization order
  - `docs/PROFILE_GUIDE.md` - Comprehensive profile management guide
  - `docs/PACKAGE_MANAGER_GUIDE.md` - Package manager templates and consolidation strategy
  - Updated `README.md` with clear bootstrap.sh vs setup.sh guidance
  - Updated `CONTRIBUTING.md` with profile contribution guidelines

#### Enhanced Validation & Testing (Phase 7)
- **Extended `validate-dotfiles.sh`** with new checks:
  - 6: Profile symlink validation (all 22 profiles checked)
  - 7: Language ecosystem availability (pyenv, rbenv, go, rustup, node)
  - 8: Shell sourcing validation (bash and zsh both work)
  - 9: PATH verification
  - Comprehensive validation output documentation
  - Actionable remediation commands for each failure
  - Extended success/failure summary with next steps

#### Script Documentation & Clarification (Phase 4)
- **bootstrap.sh** - Added 130+ line documentation header explaining responsibilities
  - Repository sync (git pull)
  - Oh-my-zsh installation
  - Rsync deployment
  - npm global packages
  - Idempotency notes and comparison matrix with setup.sh

- **setup.sh** - Added 160+ line documentation header explaining responsibilities
  - Directory creation
  - Secrets template generation
  - Symlink management for dotfiles and profiles
  - Function module deployment
  - Profile sourcing configuration
  - Comprehensive phase breakdown and safety guarantees

- **Delegation Pattern Documentation** in `docs/DEPLOYMENT.md`
  - setup.sh orchestrates brewfile-setup.sh for Homebrew
  - Clear separation of concerns
  - Single responsibility principle
  - Optional vs. required features

#### Package Manager Planning (Phase 6)
- **Future-Ready Manifest Templates**
  - Python: `pyproject.toml` and `requirements-global.txt` templates
  - Ruby: `Gemfile` structure with `.ruby-version`
  - Go: `go-tools.manifest` format
  - Node.js: `npm-packages.txt` and `package.json` structure
  - Rust: `rust-tools.manifest` for `cargo install` tools
  - Migration guides for each ecosystem
  - Consolidation phases documented (current → manifests available → adoption → standard)

### Changed

#### Bootstrap & Setup Workflow
- **bootstrap.sh** - Clarified as "repo sync + initial deployment" only
  - No longer recommended as sole deployment method
  - Use `bootstrap.sh` → `setup.sh` sequence for first-time setup
  - Updated to include comprehensive documentation

- **setup.sh** - Enhanced profile handling
  - Now automatically symlinks all discovered `.*_profile` files (Phase 2)
  - Explicit profile sourcing in shell rc files (Phase 3)
  - Profiles load in defined order (language → cloud → devops → optional)

- **`.bash_profile` and `.zshrc`** - Profile sourcing
  - Explicit loops sourcing all context-specific profiles
  - Shell-aware sourcing (bash skips ZSH-specific, zsh loads all)
  - Documented sourcing order with rationale
  - Error suppression for optional profiles

#### Deployment Guidance
- **README.md** - Updated quick start
  - Clear two-step setup: `bash bootstrap.sh` then `bash setup.sh`
  - Explicit guidance on when to use which script
  - Link to comprehensive `docs/DEPLOYMENT.md`

- **Documentation Structure** - New `docs/` files
  - Added 4 new comprehensive guides
  - Profile system now fully documented
  - Language ecosystem setup explained
  - Package manager future strategy outlined

### Fixed

- **`.ruby_profile`** - Bash compatibility
  - Fixed global alias syntax for bash (removed `-g` flag in bash section)
  - Added shell detection (ZSH uses `-g`, Bash doesn't)
  - Now sources without errors in both shells

### Improved

- **Audit and Discovery** (Phase 1)
  - Created `audit-profiles.sh` script
  - Generated `PROFILE_INVENTORY.md` with all 22 profiles catalogued
  - Generated `PROFILE_AUDIT_REPORT.md` with findings and recommendations
  - Identified package manager opportunities and consolidation potential

- **Profile Categorization**
  - 5 Language Tools (python, ruby, go, rust, node)
  - 5 Cloud Platforms (aws, azure, gcloud, ...)
  - 4 DevOps Tools (docker, kubernetes, rancher, terraform, vault)
  - 2 Package Managers (HomeBrew, npm)
  - 1 Editor (VS Code)
  - 4+ Specialized Tools (GitHub, OpenAI, Claude, Instruqt, etc.)

- **Shell Profile Sourcing Strategy**
  - Explicit loading order documented
  - Dependency management clear (language managers first)
  - Error handling for optional profiles
  - Shell-specific feature handling (ZSH completions, etc.)

### See Also

- `OpenSpec` change: `audit-profile-deployment-package-managers` (Phase 1-10 complete)
- All changes tracked in `openspec/changes/audit-profile-deployment-package-managers/tasks.md`

### Next Steps for Contributors

- Monitor adoption of new profile management system
- Gather feedback on profile organization and loading
- Plan Phase 2: Package manager manifest adoption (optional, future)
- Consider language ecosystem consolidation (optional, future)

#### New Core Infrastructure
- **`setup.sh`** - Single reproducible deployment script replacing `bootstrap.sh`
  - Fully automated symlink creation and permission management
  - Idempotent design: safe to run multiple times
  - Automatic backup of existing config files
  - Built-in validation with color-coded output
  - Replaces all manual bootstrap steps

- **`validate-dotfiles.sh`** - Comprehensive setup verification script
  - Validates directory structure completeness
  - Checks symlink targets are correct
  - Verifies `.bash_secrets` has secure 600 permissions
  - Tests shell configuration sourcing
  - Validates function module loading
  - Provides specific remediation commands for failures
  - Color-coded pass/fail output

- **`.bash_secrets.template`** - Secure credentials template
  - Automatic 600 permissions for privacy
  - Placeholders for GitHub, AWS, Google Cloud, Azure, Docker credentials
  - Sourced automatically by shells
  - Never committed to git (in `.gitignore`)
  - Setup.sh creates from template on first run

#### Modular Function System
- **`.functions.d/` directory** - New modular function organization
  - `git.sh` - Git utilities (current_branch, recent_branches, status, root, stash_timestamp)
  - `system.sh` - System utilities (mkd, rm_dsstore, lsd, dus, ff, backup)
  - `productivity.sh` - Productivity tools (todo, done_todo, timer, reset_terminal)
  - Automatic loading by both ZSH and Bash
  - POSIX-compatible implementations (no bash-specific constructs)
  - Sourced in correct order before custom functions
  - Easily extensible - add new `.sh` files to directory

#### Shell Configuration Improvements
- **Unified startup order** with explicit documentation
  - ZSH configuration (`.zshrc`) refactored for clarity
  - Bash configuration (`.bash_profile`) streamlined
  - Consistent loading order across shells
  - `.bash_secrets` sourcing in both shells for credentials
  - `.bashrc` lightweight for interactive shells only

- **`.zshrc` enhancements**:
  - Automatic `.functions.d/` module loading
  - Proper `.bash_secrets` sourcing with existence checks
  - Maintains existing ZSH configuration compatibility
  - No breaking changes to current ZSH setup

- **`.bash_profile` enhancements**:
  - Automatic `.functions.d/` module loading
  - Proper `.bash_secrets` sourcing with existence checks
  - Consistent with ZSH startup order
  - Simplified structure vs previous version

#### Documentation
- **[SHELL_CONFIGURATION.md](./docs/SHELL_CONFIGURATION.md)** - Comprehensive shell behavior guide
  - ZSH startup sequence (login vs interactive shells)
  - Bash startup sequence (login vs interactive shells)
  - 7-step configuration loading order with detailed explanation
  - Guidelines for adding exports, aliases, functions, secrets
  - POSIX compatibility principles and constraints
  - Troubleshooting common shell issues
  - Platform-specific notes for macOS/BSD

- **[CONTRIBUTING.md](./CONTRIBUTING.md)** - Development guidelines
  - POSIX-compatible shell patterns with examples
  - Function organization and best practices
  - Testing procedures for new functions
  - Git workflow with Conventional Commits
  - Code review process
  - Shell scripting style guide

- **[MIGRATION.md](./docs/MIGRATION.md)** - Upgrade guide from bootstrap.sh
  - Step-by-step migration instructions
  - What changed and why
  - Troubleshooting common migration issues
  - Feature comparison (old vs new)
  - Backup and restore procedures
  - FAQ for common questions

- **[README.md](./README.md)** - Complete rewrite with new structure
  - Quick start using `setup.sh`
  - Installation instructions
  - Configuration guide
  - File structure documentation
  - Troubleshooting section

#### CI/CD & Automation
- **`.github/workflows/validate-dotfiles.yml`** - GitHub Actions workflow
  - Runs on macOS-latest for authenticity
  - Validates shell syntax (.bash_profile, .bashrc, .zshrc)
  - Checks POSIX compliance (no bash-specific constructs)
  - Verifies file structure completeness
  - Tests function module sourcing
  - Validates symlink targets
  - Runs on push to feature/main branches
  - Runs on all pull requests
  - Provides clear pass/fail status for code review

#### Updated Configuration Files
- **`.gitignore`** - Expanded ignore patterns
  - `/.bash_secrets` - Never commit credentials
  - `/.dotfiles.backup/` - Backup directory
  - `user-specific-functions/` - For user customizations (if added)
  - Maintains reproducibility across clones

### Changed

#### Shell Startup Behavior
- **Explicit sourcing order** now documented in code comments
- **Function loading** changed from single `~/.functions` file to modular `.functions.d/`
- **Secrets management** now automatic with template-based creation
- **Startup time** improved by modular loading and lazy-load potential

#### Deployment Process
- **bootstrap.sh** → **setup.sh** (improved, idempotent, automated)
- **Manual steps** → **Automated setup** (no manual symlink creation)
- **Validation** Integrated into setup process + separate `validate-dotfiles.sh`
- **Backup strategy** Automatic backups instead of manual

#### Directory Structure
- **Old structure**:
  ```
  ~/.functions         (single file with all functions)
  ~/dotfiles/bootstrap.sh  (brittle, manual process)
  ```

- **New structure**:
  ```
  ~/.functions.d/      (modular functions directory)
    ├── git.sh
    ├── system.sh
    ├── productivity.sh
    └── README.md
  ~/.config/          (new config directory for future use)
  ~/dotfiles/setup.sh        (idempotent, automated)
  ~/dotfiles/validate-dotfiles.sh (comprehensive validation)
  ```

#### Documentation Organization
- **Old**: Scattered information in README, comments
- **New**: Dedicated docs with clear purposes:
  - `SHELL_CONFIGURATION.md` - How shells work
  - `CONTRIBUTING.md` - How to develop
  - `MIGRATION.md` - How to upgrade
  - `README.md` - Getting started

### Removed

#### Deprecated & Platform Changes
- **`bootstrap.sh`** - Replaced by `setup.sh`
  - Reason: Not idempotent, manual steps, limited validation
  - Migration: See [MIGRATION.md](./docs/MIGRATION.md)

- **Linux support files** - Removed
  - Reason: Project focused on macOS/BSD only
  - Impact: Removed Linux-specific dotfile variations
  - Note: Can be added back in separate branch if needed

- **Fragmented function loading** - Consolidated to `.functions.d/`
  - Old: Functions in multiple files (`.functions`, individual snippets)
  - New: Modular `.functions.d/` directory
  - Benefit: Easier to maintain, test, extend

### Fixed

- **Shell compatibility issues** - Now POSIX-compliant across Bash and ZSH
- **Function loading order** - Explicit documented order prevents conflicts
- **Permission races** - setup.sh atomically sets `.bash_secrets` 600
- **Idempotency problems** - Multiple setup.sh runs now safe
- **Backup loss** - Automatic backups prevent accidental overwrites
- **Documentation desync** - Single source of truth for configuration order

### Security

- **`.bash_secrets` permissions** - Automatic 600 (user read/write only)
- **Setup script** - No `sudo` required (doesn't touch system files)
- **Template pattern** - Credentials never committed (template only)
- **File validation** - Checks all symlinks point to intended targets
- **CI/CD workflow** - Validates before merge to prevent misconfigurations

### Technical Details

#### Design Decisions
1. **Modular functions** - POSIX-compatible shell functions in `.functions.d/`
   - Rationale: Same code works in Bash and ZSH without conditionals
   - Benefit: Easier to test, maintain, and extend

2. **Unified setup.sh** - Single reproducible deployment script
   - Rationale: One source of truth for environment setup
   - Benefit: Idempotent; bootstraps any number of times safely

3. **Explicit startup order** - Documented shell loading sequence
   - Rationale: Shell startup is complex; make it explicit
   - Benefit: Easier to debug, understand, and modify configuration

4. **Profile organization** - Separate shell, export, alias, function loading
   - Rationale: Clear separation of concerns
   - Benefit: Easier to find and modify specific settings

5. **Secrets framework** - Automatic template-based creation
   - Rationale: Credentials need special handling (permissions, ignore)
   - Benefit: Secure by default; never accidentally commit credentials

6. **macOS/BSD focus** - Removed Linux-specific patterns
   - Rationale: Project used on macOS only
   - Benefit: Simpler codebase, platform-specific optimizations possible

### Performance

- **setup.sh**:
  - Typical run time: < 1 second on fast systems
  - Idempotent: ~0.5 seconds if already configured (no changes)
  - No external dependencies (pure shell)

- **validate-dotfiles.sh**:
  - Typical run time: < 2 seconds
  - Comprehensive validation of 20+ system properties
  - Suggests specific fixes if issues found

- **Shell startup**:
  - Modular loading enables future lazy-loading
  - No performance regression vs previous system
  - Functions load in defined consistent order

## [Previous] - Historical

See git history for versions prior to this refactoring:
```bash
git log --oneline  # See all previous versions
```

## Migration Path

**For existing users**: See [MIGRATION.md](./docs/MIGRATION.md)

**For new users**: Simply run:
```bash
git clone https://github.com/abuxton/dotfiles.git ~/dotfiles
cd ~/dotfiles
source setup.sh
```

## Future Considerations

### Potential Additions
- [ ] Homebrew package manifest (`brewfile-setup.sh`)
- [ ] Optional ZSH plugins (fzf, zoxide integration)
- [ ] Optional development tool profiles (Node, Python, Rust, Go)
- [ ] Platform-specific documentation (M1 vs Intel optimization)
- [ ] Docker configuration sync
- [ ] SSH configuration templates
- [ ] Git configuration profiles (work vs personal)
- [ ] Terminal color scheme themes

### Potential Improvements
- [ ] Shell completion for custom functions
- [ ] Performance monitoring/benchmarking
- [ ] Automated testing on fresh macOS VMs
- [ ] Release automation with semantic versioning
- [ ] Comprehensive logging/audit trail for setup
- [ ] Recovery procedures for common issues

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Breaking changes (e.g., major directory restructure)
- **MINOR** (0.X.0): New features backward compatible (new functions, docs)
- **PATCH** (0.0.X): Bug fixes and non-breaking updates

## Links

- [Shell Configuration Guide](./docs/SHELL_CONFIGURATION.md)
- [Contributing Guidelines](./CONTRIBUTING.md)
- [Migration Guide](./docs/MIGRATION.md)
- [README](./README.md)

---

**Last Updated**: See git history via `git log CHANGELOG.md`
