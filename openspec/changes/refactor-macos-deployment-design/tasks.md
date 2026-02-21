# Tasks: macOS/ZSH-Optimized Dotfiles Refactor

## Overview

Implementation tasks for refactoring dotfiles for macOS/ZSH optimization. Tasks are organized by capability group with clear acceptance criteria and testing guidance.

**Tracking Notes:**
- Mark tasks complete as they're finished (not all at once at the end)
- Each task includes testing guidance and acceptance criteria
- Run full deployment validation after completing each capability group
- Update documentation after each significant feature is complete

---

## NEW CAPABILITIES

### zsh-module-loader

- [x] **Create `.functions.d/` directory structure**
  - Acceptance: Directory exists with placeholder/example function files
  - Testing: `ls ~/.functions.d/` shows expected files
  - Related specs: zsh-module-loader/spec.md - Requirement 1

- [x] **Create git functions in `.functions.d/git.sh`**
  - Acceptance: Common git helper functions available (e.g., git status, recent branches)
  - Testing: Source `.zshrc` then run git functions: `git_current_branch`, `git_recent_branches`
  - Related specs: zsh-module-loader/spec.md - Requirement 3

- [x] **Create system functions in `.functions.d/system.sh`**
  - Acceptance: Common system helper functions available (e.g., mkd, rm-dsstore)
  - Testing: Source `.zshrc` then run functions: `mkd /tmp/test`, `rm-dsstore /tmp/`
  - Related specs: zsh-module-loader/spec.md - Requirement 3

- [x] **Update `.zshrc` to source `.functions.d/` directory**
  - Acceptance: `.zshrc` contains loop that sources all `.sh` files from `.functions.d/`
  - Testing: Source `.zshrc` without errors; verify functions are available
  - Related specs: zsh-module-loader/spec.md - Requirement 1

- [x] **Add `.functions.d/` sourcing to `.gitignore` (if applicable)**
  - Acceptance: Files in `.functions.d/` can be user-customized without git tracking
  - Testing: Create custom function file; verify git doesn't track it
  - Related specs: zsh-module-loader/spec.md - Requirement 2

### bash-module-loader

- [x] **Create bash-compatible function loading in `.bashrc`**
  - Acceptance: `.bashrc` uses identical `.functions.d/` sourcing pattern as `.zshrc`
  - Testing: Source `.bashrc` in bash shell; verify functions available
  - Related specs: bash-module-loader/spec.md - Requirement 1

- [x] **Verify functions work identically in both shells**
  - Acceptance: Run same function in bash and zsh; both produce identical behavior
  - Testing: `zsh -c "git_current_branch"` and `bash -c "git_current_branch"` both work
  - Related specs: bash-module-loader/spec.md - Requirement 2

- [x] **Document bash/zsh compatibility constraints in `.functions.d/README.md`**
  - Acceptance: README explains POSIX-compatible patterns required
  - Testing: Read README; understand what shell features to avoid
  - Related specs: bash-module-loader/spec.md - Requirement 3

### reproducible-deployment

- [x] **Create `setup.sh` script to replace bootstrap.sh**
  - Acceptance: Single script handles all deployment state
  - Testing: New clone → `source setup.sh` → environment is functional
  - Related specs: reproducible-deployment/spec.md - Requirements 1, 2

- [x] **Implement directory creation logic in setup.sh**
  - Acceptance: setup.sh creates: `~/.functions.d/`, `~/.config/`, project-specific directories
  - Testing: Fresh start → `source setup.sh` → all required directories exist
  - Related specs: reproducible-deployment/spec.md - Requirement 1

- [x] **Implement symlink creation logic in setup.sh**
  - Acceptance: setup.sh creates symlinks for: `.bashrc`, `.zshrc`, `.aliases`, `.exports`, etc.
  - Testing: Fresh start → `source setup.sh` → all symlinks exist and point correctly
  - Related specs: reproducible-deployment/spec.md - Requirement 2

- [x] **Implement permission setting in setup.sh**
  - Acceptance: setup.sh sets correct permissions: 600 on `.bash_secrets`, 644 on most files
  - Testing: `ls -la ~` shows correct permissions after setup.sh
  - Related specs: reproducible-deployment/spec.md - Requirement 1

- [x] **Implement backup logic in setup.sh if symlinks/files exist**
  - Acceptance: Before overwriting, setup.sh backs up existing files to `.dotfiles.backup/`
  - Testing: Existing config → `source setup.sh` → backup created; config still works
  - Related specs: reproducible-deployment/spec.md - Requirement 3

- [x] **Implement idempotent verification for setup.sh**
  - Acceptance: Running `source setup.sh` twice produces identical final state
  - Testing: Run setup.sh twice → verify no re-creation of symlinks, no permission changes
  - Related specs: reproducible-deployment/spec.md - Requirement 3

- [x] **Update `README.md` with setup.sh documentation**
  - Acceptance: README explains: what setup.sh does, when to run it, what it changes
  - Testing: New user reads README → can successfully run setup.sh
  - Related specs: reproducible-deployment/spec.md - Requirement 4

- [ ] **Add troubleshooting guide to README for common setup issues**
  - Acceptance: README includes: symlink conflicts, permission errors, missing directories
  - Testing: User encounters common issue → finds solution in README
  - Related specs: reproducible-deployment/spec.md - Requirement 4

### function-library

- [ ] **Organize git functions into `.functions.d/git.sh`**
  - Acceptance: Git functions separated from system/utility functions
  - Testing: All git-related functions available when sourced
  - Related specs: function-library/spec.md - Requirement 1

- [ ] **Organize system functions into `.functions.d/system.sh`**
  - Acceptance: System utilities (mkd, rm-dsstore, etc.) separated
  - Testing: All system functions available when sourced
  - Related specs: function-library/spec.md - Requirement 1

- [ ] **Create `.functions.d/productivity.sh` for productivity functions**
  - Acceptance: Productivity tools (e.g., todo helpers, timer) in dedicated file
  - Testing: Functions available after sourcing `.zshrc`
  - Related specs: function-library/spec.md - Requirement 1

- [x] **Document POSIX-compatible patterns in `CONTRIBUTING.md`**
  - Acceptance: CONTRIBUTING.md explains shell portability constraints
  - Testing: Contributor reads CONTRIBUTING.md; understands patterns to follow
  - Related specs: function-library/spec.md - Requirement 2

- [ ] **Add shell detection and fallback handling**
  - Acceptance: Functions gracefully handle bash/zsh differences
  - Testing: `cat .functions.d/*.sh | grep "bash\|zsh"` shows no bash-specific constructs
  - Related specs: function-library/spec.md - Requirement 2

### secrets-framework

- [x] **Create `.bash_secrets` template file**
  - Acceptance: Template includes placeholder environment variables for common tools
  - Testing: File exists at `~/.bash_secrets` with expected structure
  - Related specs: secrets-framework/spec.md - Requirement 1

- [ ] **Implement automatic template creation in setup.sh**
  - Acceptance: If `.bash_secrets` doesn't exist, setup.sh creates it from template
  - Testing: Fresh install → setup.sh runs → `.bash_secrets` exists
  - Related specs: secrets-framework/spec.md - Requirement 1

- [ ] **Set secure permissions (600) on `.bash_secrets` in setup.sh**
  - Acceptance: `.bash_secrets` has permissions 600 (readable/writable by owner only)
  - Testing: `ls -la ~/.bash_secrets` shows: `-rw------- 1 user user`
  - Related specs: secrets-framework/spec.md - Requirement 1

- [ ] **Add `.bash_secrets` sourcing to `.bashrc` and `.zshrc`**
  - Acceptance: Both rc files source `.bash_secrets` if it exists
  - Testing: Export variable in `.bash_secrets`; verify it's available in shell
  - Related specs: secrets-framework/spec.md - Requirement 2

- [ ] **Document `.bash_secrets` usage in README**
  - Acceptance: README explains: what goes in secrets, how to create variables, how to use them
  - Testing: User can follow README to add custom secret to `.bash_secrets`
  - Related specs: secrets-framework/spec.md - Requirement 3

- [ ] **Verify `.bash_secrets` doesn't interfere with profile files**
  - Acceptance: Profile files can coexist with `.bash_secrets`; both are sourced
  - Testing: Create both `.bash_secrets` and `.github_profile`; both available in shell
  - Related specs: secrets-framework/spec.md - Requirement 4

### deployment-validation

- [x] **Create `validate-dotfiles.sh` script**
  - Acceptance: Script checks: directories exist, symlinks are correct, permissions are set
  - Testing: Run `validate-dotfiles.sh` after setup → no errors
  - Related specs: deployment-validation/spec.md - Requirement 1

- [ ] **Implement directory existence checks in validation script**
  - Acceptance: Script verifies: `~/.functions.d/`, `~/.config/`, project directories exist
  - Testing: `validate-dotfiles.sh` reports missing directories with remediation steps
  - Related specs: deployment-validation/spec.md - Requirement 1

- [ ] **Implement symlink verification in validation script**
  - Acceptance: Script verifies all expected symlinks exist and point to correct targets
  - Testing: Broken symlink → `validate-dotfiles.sh` detects and reports
  - Related specs: deployment-validation/spec.md - Requirement 1

- [ ] **Implement permission checks in validation script**
  - Acceptance: Script verifies permissions on `.bash_secrets` (600), other files (644)
  - Testing: Wrong permissions → `validate-dotfiles.sh` detects and suggests fix
  - Related specs: deployment-validation/spec.md - Requirement 1

- [ ] **Create GitHub Actions workflow for CI/CD validation**
  - Acceptance: Workflow runs `validate-dotfiles.sh` on every commit to main branch
  - Testing: Push to main → Actions workflow runs → passes validation
  - Related specs: deployment-validation/spec.md - Requirement 2

- [ ] **Add validation step to setup.sh**
  - Acceptance: After setup completes, script runs validation and reports status
  - Testing: `source setup.sh` completes → validation runs → reports success/failure
  - Related specs: deployment-validation/spec.md - Requirement 2

### homebrew-deployment

- [ ] **Create `brewfile-setup.sh` to orchestrate Homebrew package installation**
  - Acceptance: Script can be sourced to set up Homebrew and packages
  - Testing: Fresh macOS → `source brewfile-setup.sh` → Homebrew packages installed
  - Related specs: homebrew-deployment/spec.md - Requirement 1

- [ ] **Integrate Homebrew setup into `setup.sh`**
  - Acceptance: `setup.sh` calls Homebrew setup as optional step
  - Testing: `source setup.sh` → prompts for Homebrew setup → can skip or proceed
  - Related specs: homebrew-deployment/spec.md - Requirement 1

- [ ] **Document Homebrew package list in separate `Brewfile`**
  - Acceptance: Brewfile tracked in git with all managed packages
  - Testing: `cat Brewfile` shows list of Homebrew packages and versions
  - Related specs: homebrew-deployment/spec.md - Requirement 2

- [ ] **Make Homebrew setup optional in setup.sh**
  - Acceptance: User can skip Homebrew setup if they've already configured packages
  - Testing: `source setup.sh` → prompted "Install Homebrew packages? (y/n)" → can choose
  - Related specs: homebrew-deployment/spec.md - Requirement 3

---

## MODIFIED CAPABILITIES

### shell-configuration

- [ ] **Consolidate shell startup in `.bashrc` and `.zshrc`**
  - Acceptance: Both files use identical sourcing pattern for common config
  - Testing: Source both files; same variables/aliases available in both shells
  - Related specs: shell-configuration/spec.md - Requirement 1

- [ ] **Document shell startup order in rc files**
  - Acceptance: `.bashrc` and `.zshrc` include comments showing sourcing sequence
  - Testing: Read rc files; understand precedence of exports → aliases → functions → profiles
  - Related specs: shell-configuration/spec.md - Requirement 1

- [ ] **Remove Linux-specific platform detection**
  - Acceptance: Grep `.bashrc`, `.zshrc`, `.aliases`, `.functions.d/*` for Linux patterns; none found
  - Testing: `grep -r "linux\|debian\|ubuntu\|arch" ~` in dotfiles → no matches
  - Related specs: shell-configuration/spec.md - Requirement 2

- [ ] **Update README to state macOS/BSD focus**
  - Acceptance: README first section states: "These dotfiles are optimized for macOS and BSD"
  - Testing: Read README; understand platform focus
  - Related specs: shell-configuration/spec.md - Requirement 2

- [ ] **Verify ZSH is documented as primary shell**
  - Acceptance: README explains ZSH is primary with more features; Bash works but simplified
  - Testing: User understands shell optimization strategy
  - Related specs: shell-configuration/spec.md - Requirement 3

- [ ] **Replace complex bash-specific patterns with portable alternatives**
  - Acceptance: No `[[ ]]` conditionals, array assignments, or bashisms in shared files
  - Testing: `grep -r "\[\[" ~/.functions.d` → no matches
  - Related specs: shell-configuration/spec.md - Requirement 4

### dotfiles-bootstrap

- [ ] **Refactor bootstrap.sh into setup.sh**
  - Acceptance: setup.sh is drop-in replacement with enhanced capabilities
  - Testing: Old bootstrap.sh functionality is present in setup.sh
  - Related specs: dotfiles-bootstrap/spec.md - Requirement 1

- [ ] **Make setup.sh command non-sourceable (can be executed)**
  - Acceptance: `bash setup.sh` and `source setup.sh` both work
  - Testing: `./setup.sh` runs without errors
  - Related specs: dotfiles-bootstrap/spec.md - Requirement 1

- [ ] **Implement full idempotency in setup.sh**
  - Acceptance: Running setup.sh twice on configured system produces no changes
  - Testing: Configured system → `source setup.sh` twice → diff shows no differences
  - Related specs: dotfiles-bootstrap/spec.md - Requirement 2

- [ ] **Add backup mechanism for existing configurations**
  - Acceptance: setup.sh creates `.dotfiles.backup/` before modifying existing files
  - Testing: Custom `.bashrc` exists → `source setup.sh` → backup created at `.dotfiles.backup/.bashrc`
  - Related specs: dotfiles-bootstrap/spec.md - Requirement 2

- [ ] **Add clear progress output to setup.sh**
  - Acceptance: Each step outputs status: "Creating ~/.functions.d/", "Linking .zshrc", etc.
  - Testing: Run `source setup.sh` → watch clear output of each operation
  - Related specs: dotfiles-bootstrap/spec.md - Requirement 3

- [ ] **Create migration guide from bootstrap.sh to setup.sh**
  - Acceptance: Documentation explains upgrade path and what to watch for
  - Testing: User reads migration guide; can confidently upgrade
  - Related specs: dotfiles-bootstrap/spec.md - Requirement 4

- [ ] **Add error handling and validation to setup.sh**
  - Acceptance: setup.sh detects errors during execution and reports them clearly
  - Testing: Force error condition → setup.sh detects and reports with remediation
  - Related specs: dotfiles-bootstrap/spec.md - Requirement 3

### profile-management

- [ ] **Document profile sourcing order in rc files**
  - Acceptance: `.bashrc` and `.zshrc` contain explicit sourcing loop for profiles with comments
  - Testing: Read rc files; predict which profile sets final value
  - Related specs: profile-management/spec.md - Requirement 1

- [ ] **Maintain existing `.<name>_profile` files without modification**
  - Acceptance: setup.sh does NOT move, rename, or delete existing profiles
  - Testing: Existing `.github_profile`, `.aws_profile` remain untouched
  - Related specs: profile-management/spec.md - Requirement 2

- [ ] **Create profile consolidation guide in README**
  - Acceptance: Documentation explains how to consolidate profiles into `.bash_secrets`
  - Testing: User can optionally consolidate without being forced to
  - Related specs: profile-management/spec.md - Requirement 2

- [ ] **Document profile sourcing order in README**
  - Acceptance: README includes section "Profile Sourcing Order" with clear sequence
  - Testing: User reads README; understands which profile wins if conflicts occur
  - Related specs: profile-management/spec.md - Requirement 3

- [ ] **Add profile dependency documentation template**
  - Acceptance: Template shows how to document profile dependencies in comments
  - Testing: Create example profile with dependency comments
  - Related specs: profile-management/spec.md - Requirement 4

- [ ] **Create troubleshooting guide for profile conflicts**
  - Acceptance: README includes section on resolving variable conflicts between profiles
  - Testing: User can diagnose which profile set unexpected value
  - Related specs: profile-management/spec.md - Requirement 4

- [ ] **Verify profile sourcing is backward compatible**
  - Acceptance: Old `.bashrc.local` mechanism still works alongside new system
  - Testing: Create `.bashrc.local` → verify it's sourced after all profiles
  - Related specs: profile-management/spec.md - Requirement 1

---

## INTEGRATION & VALIDATION

- [ ] **Verify all capabilities work together after implementation**
  - Acceptance: Fresh clone → `source setup.sh` → all features functional
  - Testing: Run full deployment validation suite
  - Related specs: All specs - integration test

- [ ] **Update main README.md with comprehensive setup instructions**
  - Acceptance: README covers: quick start, setup.sh, verification, troubleshooting
  - Testing: New user reads README → successfully sets up dotfiles
  - Related specs: reproducible-deployment/spec.md

- [ ] **Create CHANGELOG.md documenting all changes**
  - Acceptance: CHANGELOG explains: new capabilities, modified behaviors, breaking changes
  - Testing: User can understand version differences
  - Related specs: All specs - documentation

- [ ] **Tag git commit marking release of refactored dotfiles**
  - Acceptance: Version tag created with release notes
  - Testing: `git tag v2.0.0` created with release documentation
  - Related specs: All specs - deployment

---

## Post-Implementation Review

After all tasks are complete:

1. **Run full validation suite**: Execute `validate-dotfiles.sh` on fresh system
2. **Test both shells**: Verify bash and zsh both work identically
3. **Test upgrade path**: Verify existing users can upgrade without data loss
4. **Get peer review**: Have another user test the setup process
5. **Archive change**: Mark this OpenSpec change as complete for project history
