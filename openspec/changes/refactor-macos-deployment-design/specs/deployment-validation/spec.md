## ADDED Requirements

### Requirement: Deployment validation script verifies environment readiness
A validation script checks that installation was successful and the environment is usable.

#### Scenario: Validation confirms successful dotfiles installation
- **WHEN** user runs validation script after setup.sh
- **THEN** script checks: symlinks exist, permissions correct, key files present
- **AND** script runs basic shell syntax checks on `.bashrc` and `.zshrc`
- **AND** user sees "PASS" or specific failures with remediation steps

#### Scenario: Validation detects common problems
- **WHEN** validation script runs
- **THEN** script detects: broken symlinks, wrong permissions, missing directories
- **AND** script reports findings clearly (e.g., "ERROR: ~/.bashrc is not a symlink to dotfiles")
- **AND** script suggests fix (e.g., "Run source setup.sh to repair")

#### Scenario: Both bash and zsh are tested
- **WHEN** validation runs
- **THEN** script tests `source ~/.bashrc` in bash shell
- **AND** script tests `source ~/.zshrc` in zsh shell
- **AND** script confirms functions load without error in both shells

### Requirement: CI/CD pipeline validates dotfiles integrity
GitHub Actions workflow validates that shell startup files are syntactically correct.

#### Scenario: Pull request triggers validation
- **WHEN** developer opens a PR that modifies shell config files
- **THEN** GitHub Actions workflow runs automatically
- **AND** workflow: `bash -n ~/.bashrc` to check bash syntax
- **AND** workflow: `zsh -n ~/.zshrc` to check zsh syntax
- **AND** PR shows: ✓ if syntax is valid, ✗ if invalid

#### Scenario: Validation runs on all shell configurations
- **WHEN** CI validates the changes
- **THEN** validation checks all dotfiles that affect shell startup
- **AND** validation includes `.bash_exports`, `.aliases`, `.functions.d/` etc.
- **AND** errors fail the PR (blocks merge until fixed)

### Requirement: Users can run validation locally
Validation script is available for manual/debugging use.

#### Scenario: User runs validation script to troubleshoot
- **WHEN** user runs `./scripts/validate-dotfiles.sh` (or similar)
- **THEN** script performs all checks and reports results
- **AND** script exits with code 0 on success, non-zero on failure
- **AND** script output is clear and actionable
