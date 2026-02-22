# Specification: Bootstrap.sh Necessity Evaluation

## Overview
Evaluate whether bootstrap.sh is a unique, necessary first-time-setup script or if its responsibilities are superseded by setup.sh. Determine consolidation recommendations.

## ADDED Requirements

### Requirement: Identify bootstrap.sh unique responsibilities
The system SHALL document every action bootstrap.sh performs and flag which ones are NOT handled by setup.sh.

#### Scenario: Extract git operations
- **WHEN** analyzing bootstrap.sh
- **THEN** verify: does setup.sh handle git pull? If not, is this essential for first-time setup?

#### Scenario: Extract oh-my-zsh installation
- **WHEN** examining makeItHappen function
- **THEN** document: is this needed every time or only first-time? Can setup.sh detect and handle this?

#### Scenario: Extract rsync deployment
- **WHEN** analyzing doIt function
- **THEN** compare: bootstrap.sh uses rsync copy, setup.sh uses symlinks. Are both needed or redundant?

#### Scenario: Extract npm globals installation
- **WHEN** examining nodeKnows function
- **THEN** document: why is this in bootstrap vs setup? What npm packages does it install?

#### Scenario: Extract shell reload
- **WHEN** analyzing final source operations
- **THEN** verify: does setup.sh also handle shell reload?

### Requirement: Classify each bootstrap.sh operation as unique or redundant
The system SHALL categorize each operation as one of: FIRST-TIME-ONLY, IDEMPOTENT-SETUP, MAINTENANCE, REDUNDANT, or CONFLICTING.

#### Scenario: First-time operations
- **WHEN** evaluating operations like oh-my-zsh installation
- **THEN** confirm: can these only run once or can they run multiple times safely?

#### Scenario: Redundant operations
- **WHEN** comparing bootstrap.sh and setup.sh responsibilities
- **THEN** identify operations that BOTH scripts perform (likely conflict risk)

#### Scenario: Conflicting operations
- **WHEN** examining rsync deployment vs symlink creation
- **THEN** verify: if bootstrap.sh copies files and setup.sh symlinks, which takes precedence?

### Requirement: Evaluate bootstrap.sh necessity for fresh machines
The system SHALL determine if a completely fresh machine needs bootstrap.sh or if setup.sh alone is sufficient.

#### Scenario: Fresh machine workflow
- **WHEN** a new user clones the dotfiles repo
- **THEN** determine: must they run bootstrap.sh first or can they run setup.sh directly?

#### Scenario: Missing prerequisites
- **WHEN** bootstrap.sh runs oh-my-zsh and npm setup
- **THEN** document: are these prerequisites for setup.sh or independent capabilities?

#### Scenario: Existing dotfiles conflict
- **WHEN** user has existing ~/.zshrc or other dotfiles
- **THEN** verify: does bootstrap.sh overwrite them and if so, is this conflict-aware?

### Requirement: Identify integration points and conflicts
The system SHALL document all places where bootstrap.sh and setup.sh interact, overlap, or potentially conflict.

#### Scenario: Documented workflow order
- **WHEN** examining both scripts' documentation
- **THEN** verify: docs clearly state "run bootstrap THEN setup" or is relationship unclear?

#### Scenario: File ownership after both scripts
- **WHEN** bootstrap.sh runs rsync then setup.sh runs symlinks
- **THEN** document: who owns the files? Does setup.sh overwrite bootstrap.sh's copies?

#### Scenario: Idempotency interaction
- **WHEN** user runs bootstrap.sh multiple times
- **THEN** verify: is it safe or does rsync corrupt existing setup?

### Requirement: Produce consolidation recommendation
The system SHALL analyze all findings and recommend either: KEEP BOTH (with clear separation), MERGE, or DEPRECATE bootstrap.sh.

#### Scenario: Keep both scenario
- **WHEN** bootstrap.sh has unique first-time-only operations
- **THEN** document: exact responsibilities and when each should be used

#### Scenario: Merge scenario
- **WHEN** bootstrap.sh operations can be absorbed into setup.sh
- **THEN** document: how to integrate each operation while maintaining idempotency

#### Scenario: Deprecate scenario
- **WHEN** bootstrap.sh is completely superseded
- **THEN** document: deprecation path and messaging for existing users

### Requirement: Create decision tree for users
The system SHALL produce a clear guide for when to run which script.

#### Scenario: Documented user guide
- **WHEN** user asks "which script do I run?"
- **THEN** provide decision tree: "If you're setting up for the first time → do this. If you're updating → do that."

#### Scenario: Example workflows
- **WHEN** user is following the guide
- **THEN** show worked example: "New machine: bootstrap then setup", "Existing machine: setup only", etc.
