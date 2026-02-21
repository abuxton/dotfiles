# Specification: Missing File Audit

## Overview
Audit all root-level files and directories in the dotfiles repo, determining which should be deployed to $HOME, which should remain in repo-only, and which require new deployment strategy.

## ADDED Requirements

### Requirement: Create comprehensive file inventory
The system SHALL enumerate all files and directories in the repository root, organized by category.

#### Scenario: Extract root files
- **WHEN** listing root directory
- **THEN** capture all files (dotfiles, scripts, configs, markdown, etc.)

#### Scenario: Extract root directories
- **WHEN** listing root directory
- **THEN** capture all subdirectories (init, modules, docs, assets, bin, .functions, .functions.d, etc.)

#### Scenario: Organize by type
- **WHEN** inventory is created
- **THEN** categorize: configuration files, shell scripts, documentation, assets, hidden directories, application configs

### Requirement: Classify each file's deployment status
The system SHALL determine for each file/directory: whether it should go to $HOME, stay in repo-only, or requires new deployment.

#### Scenario: Already deployed files
- **WHEN** reviewing inventory
- **THEN** identify which files are already handled by setup.sh (dotfiles, .*_profile, .functions.d)

#### Scenario: Bootstrap-deployed files
- **WHEN** reviewing inventory
- **THEN** identify which files are deployed by bootstrap.sh rsync

#### Scenario: Repo-only files
- **WHEN** examining structure
- **THEN** identify files that should remain in repo (documentation, configuration files, git metadata)

#### Scenario: Undeployed candidate files
- **WHEN** analyzing remaining files
- **THEN** flag files not currently deployed that MIGHT need deployment (unclear purpose files)

### Requirement: Evaluate special directories
The system SHALL deeply analyze complex directories (init, modules, bin, .functions, .functions.d) to understand their purpose and deployment strategy.

#### Scenario: init/ directory analysis
- **WHEN** examining init/
- **THEN** determine: what are these files? (terminal themes, pref files) Should they be deployed? Where?

#### Scenario: modules/ directory analysis
- **WHEN** examining modules/
- **THEN** determine: what are these? (shell/config modules?) Should they be deployed to ~/.modules?

#### Scenario: bin/ directory analysis
- **WHEN** examining bin/
- **THEN** determine: what scripts are here? Should they be deployed? Should they be in PATH?

#### Scenario: .functions vs .functions.d
- **WHEN** comparing these directories
- **THEN** clarify: why are there two? What goes in each? How should they be deployed?

#### Scenario: .zsh.d directory
- **WHEN** examining .zsh.d/
- **THEN** determine: is this zsh-specific module directory? Should it be symlinked or copied?

### Requirement: Identify unmapped files
The system SHALL produce a list of all files that are currently not handled by any deployment script.

#### Scenario: Extract unmapped files
- **WHEN** comparing full inventory against setup.sh and bootstrap.sh handling
- **THEN** produce list of files with status: CURRENTLY_UNMAPPED

#### Scenario: Categorize unmapped files
- **WHEN** reviewing unmapped list
- **THEN** classify each as: SHOULD_DEPLOY, REPO_ONLY, UNCLEAR_PURPOSE, or LEGACY

#### Scenario: Flag unclear purpose
- **WHEN** file has unclear purpose
- **THEN** mark with question and note: "Requires clarification"

### Requirement: Determine deployment strategy for new deployments
The system SHALL recommend how to deploy files that currently aren't (symlink, copy, directory creation, add to PATH, etc.)

#### Scenario: Directory deployment approach
- **WHEN** evaluating whether directory should be deployed
- **THEN** recommend: create in $HOME? If so, create empty or copy contents?

#### Scenario: Script deployment approach
- **WHEN** evaluating scripts (bin/*, .functions.d/*.sh)
- **THEN** recommend: symlink, copy, or add to PATH?

#### Scenario: Configuration deployment
- **WHEN** evaluating config files that should go to $HOME
- **THEN** recommend: full path mapping, symlink strategy, merge with existing

#### Scenario: Hidden directory deployment
- **WHEN** evaluating dotted directories (e.g., .zsh.d)
- **THEN** recommend: symlink entire directory or symlink individual files?

### Requirement: Produce unmapped files audit report
The system SHALL create a detailed report showing deployment status of every root file/directory.

#### Scenario: Coverage matrix
- **WHEN** audit is complete
- **THEN** create table: filename | type | size | current_handler | deployment_recommendation | notes

#### Scenario: Gap identification
- **WHEN** analyzing matrix
- **THEN** highlight rows showing UNMAPPED or UNCLEAR status

#### Scenario: Deployment proposal
- **WHEN** review unmapped files
- **THEN** for each one, propose: deploy? how? or leave in repo-only? Why?

### Requirement: Identify potential improvements
The system SHALL flag any opportunities to consolidate, improve clarity, or rationalize the file structure.

#### Scenario: Consolidation opportunities
- **WHEN** examining similar files or directories
- **THEN** identify: could these be merged? Would consolidation improve clarity?

#### Scenario: Naming consistency
- **WHEN** reviewing file names and purposes
- **THEN** identify: are naming conventions clear? Do similar files follow same pattern?

#### Scenario: Clarity opportunities
- **WHEN** examining unmapped or unclear files
- **THEN** suggest: better names, clearer documentation, or clearer purpose statements
