## ADDED Requirements

### Requirement: .bash_secrets is managed securely by setup
The `.bash_secrets` file (containing sensitive API keys, credentials, etc.) is created from a template by setup.sh and configured with secure permissions.

#### Scenario: New machine gets template-based secrets file
- **WHEN** user runs setup.sh on a new machine
- **THEN** setup.sh checks if `~/.bash_secrets` exists
- **AND** if missing, setup.sh copies from `~/.dotfiles/.bash_secrets.example`
- **AND** file is created with `600` permissions (owner read/write only)

#### Scenario: Secrets file is not overwritten on subsequent runs
- **WHEN** user has existing `~/.bash_secrets` with personal credentials
- **AND** user runs setup.sh again
- **THEN** setup.sh preserves the existing file
- **AND** file permissions remain `600`
- **AND** setup.sh does not modify user's credentials

### Requirement: .bash_secrets.example provides template
A template file documents the structure and expected secrets without containing real values.

#### Scenario: Template guides users on what to populate
- **WHEN** developer or user opens `.bash_secrets.example`
- **THEN** file shows example variable names and comments (e.g., `# Export GITHUB_TOKEN...`)
- **AND** file contains no real secrets (keys, tokens, passwords)
- **AND** user can copy to `~/.bash_secrets` and fill in personal values

#### Scenario: Template is version-controlled with repository
- **WHEN** setup.sh references `.bash_secrets.example`
- **THEN** file is tracked in git
- **AND** new developers can see what secrets are expected
- **AND** updates to secret requirements are distributed via git

### Requirement: Secrets are automatically sourced in shell startup
When a user's shell initializes, `.bash_secrets` is sourced to make credentials available.

#### Scenario: Secrets are available in new shell sessions
- **WHEN** user opens a new shell and runs `echo $GITHUB_TOKEN`
- **THEN** the token (from `.bash_secrets`) is available
- **AND** shell did not prompt or require manual setup

#### Scenario: Missing secrets file does not break shell
- **WHEN** `.bash_secrets` does not exist
- **THEN** shell startup completes without error
- **AND** shell continues functioning (just without credentials)
- **AND** user sees guidance on creating the file

### Requirement: Profile-specific credentials can coexist with bash_secrets
Tool-specific `.<name>_profile` files can store credentials without forcing consolidation; explicit sourcing order is documented.

#### Scenario: Multiple profiles are sourced in defined order
- **WHEN** shell initializes
- **THEN** shell sources profiles in explicit order (documented in `.bashrc` or `.zshrc`)
- **AND** `.bash_secrets` is sourced at expected point in sequence
- **AND** profile variables cascade predictably (first set wins, or later set overwrites)
