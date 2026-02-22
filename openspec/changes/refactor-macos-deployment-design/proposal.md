# Proposal: macOS/ZSH-Optimized Dotfiles Refactor with Simplified Bash Support

## Why

The current dotfiles repository inherited broad cross-platform patterns (Linux distributions, multiple shells, complex organizational structure) that create maintenance burden and obscure the primary use case: macOS development with ZSH.

**Problem**: Complex shell patterns cause:
- Duplicate logic across bash/zsh files
- Difficult onboarding for contributors
- Brittle bootstrap process (manual state changes, not reproducible)
- Unclear directory structure (why are these files organized this way?)
- Profile sprawl creating namespace pollution

**Opportunity**: By optimizing for macOS/ZSH as the primary use case while maintaining simplified bash support, we can:
- Reduce configuration duplication
- Make setup truly reproducible (Spilled Coffee Principle)
- Improve maintainability and clarity
- Enable faster deployment on new systems
- Create a model for clean dotfiles architecture

## What Changes

- **Simplify shell configuration**: Remove complex bash-ism patterns; unify bash/zsh where possible through simple abstractions
- **Make deployment reproducible**: Enhance bootstrap.sh to handle ALL state changes (symlinks, permissions, directories) - no manual commands needed
- **Reorganize for clarity**: Structure files by capability/domain, not by inheritance or platform noise
- **Implement modular function loading**: Both bash and zsh can source functions from a common library with shell detection
- **Enhance secrets management**: Automatically handle `.bash_secrets` creation and permissions
- **Add validation/verification**: Deploy process includes checks that verify environment is ready
- **Remove platform-specific branches**: Drop Linux-specific dotfiles that complicate the codebase (this is a macOS project)

## Capabilities

### New Capabilities

- **zsh-module-loader**: Modular ZSH function/alias loading from centralized library
- **bash-module-loader**: Simplified bash compatibility layer that sources same modules as ZSH
- **reproducible-deployment**: setup.sh handles all state changes (symlinks, directories, permissions)
- **function-library**: Organized shell functions by domain (git, system, productivity)
- **secrets-framework**: Safe .bash_secrets handling with automatic creation from template
- **deployment-validation**: Scripts verify installation success and environment readiness
- **homebrew deployment**: Scripts to orchestrate deployment from https://github.com/abuxton/homebrew-brewfile

### Modified Capabilities

- **shell-configuration**: Consolidate bash/zsh configs; remove Linux-specific patterns; optimize for macOS
- **dotfiles-bootstrap**: Make fully reproducible - running setup.sh twice should be idempotent and safe
- **profile-management**: Simplify profile organization; maintain many `.<name>_profile` files and suggest updates, but simplify source ordering and validate $PATH usage.

## Impact

- **Users**: ZSH remains primary shell; bash still works but with simpler implementation
- **Setup**: Faster, more reliable; no manual symlink/permission commands
- **Code**: Cleaner structure, easier to maintain and extend
- **Breaking**: `.aliases`, `.functions`, `.exports` organization may change (users need to re-run setup)
- **Platform**: macOS/BSD only; removes Linux-specific configurations
- **Shell Login**: Slightly different bootstrap sequence (setup.sh handles everything upfront)

# Refrences

- https://github.com/atxtechbro/dotfiles
- https://github.com/webpro/awesome-dotfiles
- https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/
- https://chr4.org/posts/2014-09-10-conf-dot-d-like-directories-for-zsh-slash-bash-dotfiles/
