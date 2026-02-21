## 1. Profile Audit & Discovery

- [ ] 1.1 Create audit script to discover all .*_profile files
- [ ] 1.2 Generate profile-inventory.md with metadata (name, size, lines of code, last modified, purpose)
- [ ] 1.3 Map cross-profile dependencies (which profiles depend on others)
- [ ] 1.4 Categorize profiles by domain (language tools, cloud platforms, development tools, etc.)
- [ ] 1.5 Identify conflicting operations (e.g., multiple profiles modifying same PATH)
- [ ] 1.6 Flag obsolete or unused profiles
- [ ] 1.7 Generate audit-report.md with findings, issues, and recommendations
- [ ] 1.8 Document current profile organization in PROFILE_AUDIT.md at openspec/changes/audit-profile-deployment-package-managers/

## 2. Profile Deployment in setup.sh

- [ ] 2.1 Extend setup.sh to discover all .*_profile files in DOTFILES_DIR
- [ ] 2.2 Add profile symlink creation function following existing symlink pattern
- [ ] 2.3 Create symlinks for all discovered profiles to home directory
- [ ] 2.4 Handle profile conflicts (back up existing files before symlinking)
- [ ] 2.5 Add profile symlinks to setup.sh's backup and idempotency logic
- [ ] 2.6 Update setup.sh dry-run mode to include profile symlinking
- [ ] 2.7 Test setup.sh runs twice without errors (idempotency validation)

## 3. Explicit Profile Sourcing in Shell Configuration

- [ ] 3.1 Add explicit profile sourcing loop to .bash_profile (after .functions.d/, before .bash_secrets)
- [ ] 3.2 Add same sourcing loop to .zshrc
- [ ] 3.3 Document the profile sourcing order and why it matters
- [ ] 3.4 Add comments in .bash_profile and .zshrc explaining profile loading
- [ ] 3.5 Test that profiles are discovered and sourced by both shells
- [ ] 3.6 Verify no duplicate sourcing or conflicts occur

## 4. Bootstrap & Setup Clarification

- [ ] 4.1 Document bootstrap.sh responsibilities in code and README (git pull, oh-my-zsh setup, rsync, npm global)
- [ ] 4.2 Document setup.sh responsibilities in code and README (directories, symlinks, profiles, delegation)
- [ ] 4.3 Clarify relationship: bootstrap.sh pulls repo, setup.sh configures environment
- [ ] 4.4 Update README.md with clear deployment workflow (when to use which script)
- [ ] 4.5 Create docs/DEPLOYMENT.md with complete step-by-step walkthrough
- [ ] 4.6 Document what each script does and does NOT do
- [ ] 4.7 Document delegation points (setup.sh calls brewfile-setup.sh if user chooses)

## 5. Language Ecosystem Initialization

- [ ] 5.1 Review .python_profile and ensure pyenv init hooks are correctly ordered
- [ ] 5.2 Review .ruby_profile and ensure rbenv init hooks are correctly ordered
- [ ] 5.3 Review .go_profile and ensure GOPATH/GOBIN setup is complete
- [ ] 5.4 Review .rust_profile and ensure rustup paths are set correctly
- [ ] 5.5 Add initialization for Node.js (nvm or nodenv) if not present
- [ ] 5.6 Document correct initialization order in each profile (why order matters)
- [ ] 5.7 Test that each language manager initializes correctly when profile is sourced

## 6. Package Manager Consolidation Planning

- [ ] 6.1 Create pyproject.toml template for Python tools (reserved for future consolidation)
- [ ] 6.2 Create .ruby-version + Gemfile structure documentation (reserved for future consolidation)
- [ ] 6.3 Document go-tools.manifest structure for Go packages
- [ ] 6.4 Document npm-packages.json structure for Node global tools
- [ ] 6.5 Document rust-toolchain.toml structure for Rust ecosystem
- [ ] 6.6 Create migration guides for each ecosystem (referencing audit recommendations)
- [ ] 6.7 Document that manifests are optional now, but will be canonical in future

## 7. Validation & Testing

- [ ] 7.1 Extend validate-dotfiles.sh to check all profile symlinks exist
- [ ] 7.2 Add validation that profile symlinks point to correct files
- [ ] 7.3 Add language ecosystem validation (pyenv, rbenv, nvm, rustup available if enabled)
- [ ] 7.4 Test shell sourcing for both bash and zsh (no errors when sourcing)
- [ ] 7.5 Add idempotency test: setup.sh --dry-run produces same output on second run
- [ ] 7.6 Add profile sourcing test (verify profiles load without errors)
- [ ] 7.7 Document validation output and what each check means

## 8. Documentation & Integration

- [ ] 8.1 Update README.md with new profile deployment information
- [ ] 8.2 Create docs/PROFILE_GUIDE.md explaining all profiles and their purposes
- [ ] 8.3 Create docs/LANGUAGE_ECOSYSTEM.md documenting setup for each language
- [ ] 8.4 Add troubleshooting section to docs for common profile issues
- [ ] 8.5 Update CONTRIBUTING.md with guidelines for adding new profiles
- [ ] 8.6 Document how to create local-only profiles (outside dotfiles)
- [ ] 8.7 Create migration guide for users upgrading from old setup

## 9. Verification & Cleanup

- [ ] 9.1 Run complete setup.sh on fresh environment and verify all profiles symlink
- [ ] 9.2 Verify both bash and zsh can source all configuration without errors
- [ ] 9.3 Verify pyenv/rbenv/etc. show versions correctly at shell startup
- [ ] 9.4 Run validate-dotfiles.sh and ensure all checks pass
- [ ] 9.5 Test that setup.sh is idempotent (run twice, same result)
- [ ] 9.6 Clean up any temporary audit files
- [ ] 9.7 Ensure all changes are backwards compatible (old setup still works)

## 10. Handoff & Future Work

- [ ] 10.1 Archive this change in OpenSpec
- [ ] 10.2 Create follow-up change for package manager manifest adoption (if pursuing)
- [ ] 10.3 Create follow-up change for consolidating most-used tools (if pursuing)
- [ ] 10.4 Update CHANGELOG.md with profile deployment improvements
- [ ] 10.5 Note open questions for future discussion
