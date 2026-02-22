## ADDED Requirements

### Requirement: Define bootstrap.sh responsibilities
The system SHALL document what bootstrap.sh does, its entry point conditions, and what it delegates to other scripts.

#### Scenario: Bootstrap.sh documented behavior
- **WHEN** viewing bootstrap.sh documentation
- **THEN** it clearly states: "Pulls latest changes from git, sources oh-my-zsh install, runs rsync deployment, installs global npm packages"

#### Scenario: Bootstrap.sh entry conditions
- **WHEN** bootstrap.sh runs
- **THEN** documentation specifies: "Assumes git repo is already cloned, requires user confirmation or --force flag"

### Requirement: Define setup.sh responsibilities
The system SHALL document what setup.sh does, its entry point conditions, prerequisite checks, and what it does NOT do.

#### Scenario: Setup.sh documented behavior
- **WHEN** viewing setup.sh documentation
- **THEN** it clearly states: "Creates directories, symlinks profiles, deploys dotfiles, installs package managers"

#### Scenario: Setup.sh prerequisites
- **WHEN** setup.sh documentation is reviewed
- **THEN** it specifies: "Requires bash 4+, git installed, and optionally curl for remote scripts"

### Requirement: Clarify relationship between bootstrap and setup
The system SHALL define whether bootstrap and setup are sequential, independent, or alternative workflows.

#### Scenario: Workflow sequencing
- **WHEN** new user starts deployment
- **THEN** documentation states: "Run: bootstrap.sh (pulls repo) → setup.sh (configures environment)"

#### Scenario: Alternative workflows
- **WHEN** user wants to re-setup environment only
- **THEN** documentation states: "setup.sh can be run standalone if repo already present"

### Requirement: Delegate language-specific setup to brewfile-setup.sh
The system SHALL clarify that language-specific package management is delegated to brewfile-setup.sh and language-specific management scripts.

#### Scenario: Brew packages setup
- **WHEN** user runs setup.sh
- **THEN** it optionally delegates to brewfile-setup.sh for package installation

#### Scenario: Language manager setup
- **WHEN** setup.sh detects language tools needed
- **THEN** it delegates to appropriate language manager setup (pyenv, rbenv, etc.)

### Requirement: Create unified entry-point documentation
The system SHALL create a clear README or docs file showing the complete deployment workflow with all scripts and their roles.

#### Scenario: Deployment flow documentation
- **WHEN** user reads deployment documentation
- **THEN** they see clear section describing which script to use for each scenario (first-time setup, refresh, add packages, etc.)

#### Scenario: Script dependencies documentation
- **WHEN** viewing deployment documentation
- **THEN** scripts are shown with their prerequisites, what they modify, and what they delegate
