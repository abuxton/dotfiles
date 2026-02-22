## 1. Profile Audit & Discovery

- [x] 1.1 Create audit script to discover all .*_profile files
- [x] 1.2 Generate profile-inventory.md with metadata (name, size, lines of code, last modified, purpose)
- [x] 1.3 Map cross-profile dependencies (which profiles depend on others)
- [x] 1.4 Categorize profiles by domain (language tools, cloud platforms, development tools, etc.)
- [x] 1.5 Identify conflicting operations (e.g., multiple profiles modifying same PATH)
- [x] 1.6 Flag obsolete or unused profiles
- [x] 1.7 Generate audit-report.md with findings, issues, and recommendations
- [x] 1.8 Document current profile organization in PROFILE_AUDIT.md at openspec/changes/audit-profile-deployment-package-managers/

## 2. Profile Deployment in setup.sh

- [x] 2.1 Extend setup.sh to discover all .*_profile files in DOTFILES_DIR
- [x] 2.2 Add profile symlink creation function following existing symlink pattern
- [x] 2.3 Create symlinks for all discovered profiles to home directory
- [x] 2.4 Handle profile conflicts (back up existing files before symlinking)
- [x] 2.5 Add profile symlinks to setup.sh's backup and idempotency logic
- [x] 2.6 Update setup.sh dry-run mode to include profile symlinking
- [x] 2.7 Test setup.sh runs twice without errors (idempotency validation)

- [x] 3.1 Add explicit profile sourcing loop to .bash_profile (after .functions.d/, before .bash_secrets)
- [x] 3.2 Add same sourcing loop to .zshrc
- [x] 3.3 Document the profile sourcing order and why it matters
- [x] 3.4 Add comments in .bash_profile and .zshrc explaining profile loading
- [x] 3.5 Test that profiles are discovered and sourced by both shells
- [x] 3.6 Verify no duplicate sourcing or conflicts occur

## 4. Bootstrap & Setup Clarification

- [x] 4.1 Document bootstrap.sh responsibilities in code and README (git pull, oh-my-zsh setup, rsync, npm global)
- [x] 4.2 Document setup.sh responsibilities in code and README (directories, symlinks, profiles, delegation)
- [x] 4.3 Clarify relationship: bootstrap.sh pulls repo, setup.sh configures environment
- [x] 4.4 Update README.md with clear deployment workflow (when to use which script)
- [x] 4.5 Create docs/DEPLOYMENT.md with complete step-by-step walkthrough
- [x] 4.6 Document what each script does and does NOT do
- [x] 4.7 Document delegation points (setup.sh calls brewfile-setup.sh if user chooses)

## 5. Language Ecosystem Initialization

- [x] 5.1 Review .python_profile and ensure pyenv init hooks are correctly ordered
- [x] 5.2 Review .ruby_profile and ensure rbenv init hooks are correctly ordered
- [x] 5.3 Review .go_profile and ensure GOPATH/GOBIN setup is complete
- [x] 5.4 Review .rust_profile and ensure rustup paths are set correctly
- [x] 5.5 Add initialization for Node.js (nvm or nodenv) if not present
- [x] 5.6 Document correct initialization order in each profile (why order matters)
- [x] 5.7 Test that each language manager initializes correctly when profile is sourced

## 6. Package Manager Consolidation Planning

- [x] 6.1 Create pyproject.toml template for Python tools (reserved for future consolidation)
- [x] 6.2 Create .ruby-version + Gemfile structure documentation (reserved for future consolidation)
- [x] 6.3 Document go-tools.manifest structure for Go packages
- [x] 6.4 Document npm-packages.json structure for Node global tools
- [x] 6.5 Document rust-toolchain.toml structure for Rust ecosystem
- [x] 6.6 Create migration guides for each ecosystem (referencing audit recommendations)
- [x] 6.7 Document that manifests are optional now, but will be canonical in future

## 7. Validation & Testing

- [x] 7.1 Extend validate-dotfiles.sh to check all profile symlinks exist
- [x] 7.2 Add validation that profile symlinks point to correct files
- [x] 7.3 Add language ecosystem validation (pyenv, rbenv, nvm, rustup available if enabled)
- [x] 7.4 Test shell sourcing for both bash and zsh (no errors when sourcing)
- [x] 7.5 Add idempotency test: setup.sh --dry-run produces same output on second run
- [x] 7.6 Add profile sourcing test (verify profiles load without errors)
- [x] 7.7 Document validation output and what each check means

## 8. Documentation & Integration

- [x] 8.1 Update README.md with new profile deployment information
- [x] 8.2 Create docs/PROFILE_GUIDE.md explaining all profiles and their purposes
- [x] 8.3 Create docs/LANGUAGE_ECOSYSTEM.md documenting setup for each language
- [x] 8.4 Add troubleshooting section to docs for common profile issues
- [x] 8.5 Update CONTRIBUTING.md with guidelines for adding new profiles
- [x] 8.6 Document how to create local-only profiles (outside dotfiles)
- [x] 8.7 Create migration guide for users upgrading from old setup

## 9. Verification & Cleanup

- [x] 9.1 Run complete setup.sh on fresh environment and verify all profiles symlink
- [x] 9.2 Verify both bash and zsh can source all configuration without errors
- [x] 9.3 Verify pyenv/rbenv/etc. show versions correctly at shell startup
- [x] 9.4 Run validate-dotfiles.sh and ensure all checks pass
- [x] 9.5 Test that setup.sh is idempotent (run twice, same result)
- [x] 9.6 Clean up any temporary audit files
- [x] 9.7 Ensure all changes are backwards compatible (old setup still works)

## 10. Handoff & Future Work

- [x] 10.1 Archive this change in OpenSpec
- [x] 10.2 Create follow-up change for package manager manifest adoption (if pursuing)
- [x] 10.3 Create follow-up change for consolidating most-used tools (if pursuing)
- [x] 10.4 Update CHANGELOG.md with profile deployment improvements
- [x] 10.5 Note open questions for future discussion
