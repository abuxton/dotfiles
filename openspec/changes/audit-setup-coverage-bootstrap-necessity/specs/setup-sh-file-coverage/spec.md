# Specification: setup.sh File Coverage Audit

## Overview
Complete documentation of every file, directory, and configuration element that setup.sh currently handles, including the why/rationale for each deployment.

## ADDED Requirements

### Requirement: Document all directory creation operations
The system SHALL identify and document every directory that setup.sh creates, including the purpose and justification for each.

#### Scenario: Extract directory creation from setup.sh
- **WHEN** analyzing setup.sh line-by-line
- **THEN** identify all `mkdir -p` operations and categorize by purpose (runtime, configuration, backup storage)

#### Scenario: Document directory rationale
- **WHEN** a directory is identified as created by setup.sh
- **THEN** document why it's needed (what uses it, what gets stored there, why not in repo)

### Requirement: Document all symlink operations
The system SHALL identify every symlink that setup.sh creates, mapping source files (in repo) to targets (in $HOME).

#### Scenario: Extract dotfile symlinks
- **WHEN** examining setup.sh symlink operations
- **THEN** create matrix showing: repo file → target location → purpose

#### Scenario: Extract profile symlinks
- **WHEN** analyzing profile deployment code (Step 3c)
- **THEN** verify all 22 *.\_profile files are listed with symlink strategy

#### Scenario: Extract convenience symlinks
- **WHEN** examining .dotfiles and .ssh symlinks
- **THEN** document their purpose (navigation convenience vs. functional requirement)

### Requirement: Document all function module operations
The system SHALL identify all shell function modules that setup.sh copies and their deployment strategy.

#### Scenario: Identify function source directory
- **WHEN** analyzing .functions.d/ handling
- **THEN** confirm: are functions copied, symlinked, or sourced directly?

#### Scenario: Document function discovery mechanism
- **WHEN** setup.sh processes function modules
- **THEN** verify the pattern (.*.sh files) and document any include/exclude rules

### Requirement: Document all configuration file operations
The system SHALL identify all configuration files (not dotfiles) that setup.sh manages, including .bash_secrets, backups, and dry-run support.

#### Scenario: Verify secrets template handling
- **WHEN** setup.sh runs
- **THEN** confirm .bash_secrets is created with 600 permissions only if missing

#### Scenario: Document backup strategy
- **WHEN** existing files conflict with symlinks
- **THEN** verify backups are created with timestamp naming convention

#### Scenario: Verify dry-run capability
- **WHEN** setup.sh --dry-run is executed
- **THEN** confirm no files are modified, only operations are previewed

### Requirement: Document all validation operations
The system SHALL identify every check that setup.sh performs and its success criteria.

#### Scenario: List validation checks
- **WHEN** setup.sh completes
- **THEN** document each validation step (directories exist, symlinks correct, profiles loaded, etc.)

#### Scenario: Verify validation output format
- **WHEN** validate-dotfiles.sh is called by setup.sh
- **THEN** confirm it runs and produces expected output

### Requirement: Document Homebrew integration
The system SHALL clarify how setup.sh integrates with brewfile-setup.sh and what responsibilities each has.

#### Scenario: Verify Homebrew is optional
- **WHEN** user declines Homebrew setup
- **THEN** confirm setup.sh completes successfully without Homebrew

#### Scenario: Identify Homebrew responsibilities
- **WHEN** Homebrew setup is selected
- **THEN** document which capabilities are handled by brewfile-setup.sh vs. setup.sh

### Requirement: Create deployment responsibility matrix
The system SHALL produce a clear matrix showing: what each root-level file/directory is, whether setup.sh handles it, and if not, what does handle it.

#### Scenario: Produce coverage report
- **WHEN** audit is complete
- **THEN** create table showing: file/dir name, deployed by setup.sh?, deployed by bootstrap.sh?, deployed by other script?, missing deployment?, rationale for each

#### Scenario: Identify coverage gaps
- **WHEN** examining the matrix
- **THEN** highlight any files that are not currently deployed by any script but perhaps should be
