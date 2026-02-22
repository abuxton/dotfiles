# Specification: Deployment Workflow Clarity

## Overview
Create clear documentation and decision trees that help users understand when to run bootstrap.sh vs setup.sh, what each does, and what the complete deployment workflow looks like.

## ADDED Requirements

### Requirement: Document complete deployment workflows
The system SHALL describe all valid deployment workflows with clear steps and prerequisites.

#### Scenario: Fresh machine workflow
- **WHEN** user is setting up dotfiles on a new machine
- **THEN** document: step-by-step instructions (clone repo, run X script, run Y script, edit secrets, restart shell)

#### Scenario: Existing dotfiles conflict workflow
- **WHEN** user has existing dotfiles that conflict
- **THEN** document: backup strategy, conflict resolution, safe procedure

#### Scenario: Update existing setup workflow
- **WHEN** user already has dotfiles working and wants to update
- **THEN** document: do they need to re-run bootstrap? Just setup? Something else?

#### Scenario: Profile addition workflow
- **WHEN** user adds a new .*_profile file to repo
- **THEN** document: what command do they run? Does setup.sh auto-detect and deploy it?

### Requirement: Create decision tree for script selection
The system SHALL produce a clear, user-friendly decision tree for determining which scripts to run.

#### Scenario: Flowchart format
- **WHEN** user consults documentation
- **THEN** present decision tree as: "Is this your first time? → If yes, run bootstrap. Do you need config? → If yes, run setup."

#### Scenario: Tricky decision points
- **WHEN** user is in ambiguous situation (e.g., "I already have zsh, do I need bootstrap?")
- **THEN** provide guidance: "If oh-my-zsh is already installed, you can skip bootstrap's makeItHappen, but still should run git pull"

#### Scenario: Safe recommendations
- **WHEN** user is unsure
- **THEN** recommend safe defaults: "When in doubt, running setup.sh again is always safe"

### Requirement: Document script relationships and dependencies
The system SHALL make explicit the relationship between bootstrap.sh and setup.sh (sequential, parallel, independent, conflicting, etc.).

#### Scenario: Explicit ordering
- **WHEN** reading documentation
- **THEN** confirm: must bootstrap run BEFORE setup? Or can they run in any order?

#### Scenario: Dependency documentation
- **WHEN** examining each script
- **THEN** document: what must exist before this script runs? (git repo exists? shell installed? npm installed?)

#### Scenario: Prerequisite validation
- **WHEN** scripts run
- **THEN** document: do they validate prerequisites and fail gracefully or assume they exist?

### Requirement: Create quick reference guide
The system SHALL provide a quick, at-a-glance reference for common scenarios.

#### Scenario: Quick reference format
- **WHEN** user needs fast answer
- **THEN** provide format like: "New machine? `bootstrap.sh` then `setup.sh`. Just updating? `setup.sh`."

#### Scenario: Scenario-based reference
- **WHEN** listing common scenarios
- **THEN** include: new machine, existing dotfiles, add new profile, update repo, troubleshoot profile

#### Scenario: Copy-paste commands
- **WHEN** user reads scenario
- **THEN** provide exact commands to run (not vague descriptions)

### Requirement: Document idempotency and safety
The system SHALL clearly state which scripts are safe to run multiple times and which are not.

#### Scenario: Idempotent scripts
- **WHEN** executing setup.sh multiple times
- **THEN** document: expected outcome (idempotent - re-runs safely, no issues)

#### Scenario: Non-idempotent operations
- **WHEN** executing bootstrap.sh
- **THEN** document: which operations are safe to repeat? (git pull yes, rsync caution)

#### Scenario: Dry-run documentation
- **WHEN** user wants to preview changes
- **THEN** document: which scripts support it (`setup.sh --dry-run`), which don't

### Requirement: Document backup and recovery procedures
The system SHALL explain how backups work and how to recover if something goes wrong.

#### Scenario: Where backups are created
- **WHEN** scripts create backups
- **THEN** document: location format (`~/.dotfiles.backup/<file>.backup.<timestamp>`)

#### Scenario: How to restore
- **WHEN** user needs to restore
- **THEN** provide command: `cp ~/.dotfiles.backup/<backup-file> ~/<target>`

#### Scenario: Manual conflict resolution
- **WHEN** symlink conflicts occur
- **THEN** document: why, how to inspect, and how to manually resolve

### Requirement: Document shell integration
The system SHALL clarify how scripts initialize shells and when users need to reload.

#### Scenario: Shell reloading
- **WHEN** scripts complete
- **THEN** document: does user need to `exec zsh` or `source ~/.zshrc`? When is this required vs optional?

#### Scenario: Profile loading
- **WHEN** new profiles are deployed
- **THEN** document: how to verify they loaded, how to debug if they didn't

#### Scenario: Bash vs Zsh differences
- **WHEN** user is on either shell
- **THEN** document: any differences in deployment or behavior between bash and zsh?

### Requirement: Create troubleshooting guide
The system SHALL address common problems and how to diagnose/fix them.

#### Scenario: Profiles not loading
- **WHEN** user reports profiles don't seem active
- **THEN** provide: diagnostic commands (ls, source, echo), expected output, common causes

#### Scenario: Symlink conflicts
- **WHEN** symlink creation fails
- **THEN** provide: diagnostic approach, manual resolution steps, why it happened

#### Scenario: Script errors
- **WHEN** scripts fail
- **THEN** provide: how to see detailed debugging, common error messages and fixes

#### Scenario: Dry-run inspection
- **WHEN** user wants to see what would happen
- **THEN** document: how to use `--dry-run`, how to interpret output
