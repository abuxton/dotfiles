## ADDED Requirements

### Requirement: setup.sh is single source of truth for deployment
Replaces bootstrap.sh with new setup.sh that is fully reproducible and handles all state changes programmatically.

#### Scenario: Single command deploys entire environment
- **WHEN** user clones dotfiles and runs `source setup.sh`
- **THEN** ALL required state is created: symlinks, directories, permissions, secrets file
- **AND** user does NOT need to run manual commands (no `ln -s` commands in terminal)
- **AND** environment is fully functional after setup.sh completes

#### Scenario: setup.sh replaces bootstrap.sh functionality
- **WHEN** comparing old bootstrap.sh to new setup.sh
- **THEN** setup.sh does everything bootstrap.sh did
- **AND** setup.sh adds: automatic directory creation, symlink management, permission handling
- **AND** setup.sh is more robust (handles edge cases, provides backups)

### Requirement: setup.sh is fully idempotent and safe
Running setup.sh multiple times (or on already-configured system) produces identical, safe results.

#### Scenario: Second run locks in same state as first
- **WHEN** user runs `source setup.sh`, then runs it again
- **THEN** second run produces identical symlinks, directories, permissions
- **AND** no files are deleted or corrupted
- **AND** no manual intervention needed

#### Scenario: setup.sh handles existing configurations gracefully
- **WHEN** user already has custom dotfiles setup
- **THEN** setup.sh creates backups before replacing anything
- **AND** setup.sh validates that backups were successful
- **AND** user can restore from backup if needed

### Requirement: Bootstrap process is transparent and documented
Users understand exactly what setup.sh does and why.

#### Scenario: setup.sh output explains each step
- **WHEN** setup.sh runs
- **THEN** script outputs clear messages: "Creating ~/.functions.d/", "Linking .zshrc", "Setting permissions"
- **AND** user can follow along with the deployment process
- **AND** errors are specific and actionable

#### Scenario: README documents the deployment process
- **WHEN** user reads README
- **THEN** documentation explains: what setup.sh does, when to run it, what happens
- **AND** troubleshooting section covers common setup issues
- **AND** user knows how to verify successful installation

### Requirement: Backward compatibility with customizations
Users with existing custom dotfiles can migrate without losing work.

#### Scenario: User's customizations are preserved
- **WHEN** user runs setup.sh with existing `.bashrc.local` and `.<name>_profile` files
- **THEN** setup.sh preserves user files (does not overwrite)
- **AND** user customizations continue to work
- **AND** setup.sh creates backups as safety measure

#### Scenario: Migration guide provides safe path
- **WHEN** user reads documentation about upgrade
- **THEN** documentation shows: how to migrate from bootstrap.sh, what to watch for, how to verify
- **AND** user can confidently upgrade without data loss
