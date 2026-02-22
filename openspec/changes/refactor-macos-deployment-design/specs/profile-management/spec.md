## ADDED Requirements

### Requirement: Tool-specific profiles are maintained with explicit sourcing
`.bashrc` and `.zshrc` explicitly source `.<name>_profile` files in a documented, consistent order.

#### Scenario: Profiles are sourced in explicit order
- **WHEN** shell initializes
- **THEN** `.bashrc`/`.zshrc` contains explicit code that sources profiles in known order (e.g., github, aws, gcloud, azure...)
- **AND** sourcing order is documented in the rc file as comments
- **AND** user can predict evaluation order and precedence

#### Scenario: New profiles can be added without modifying rc files
- **WHEN** user creates a new `~/.my_tool_profile`
- **THEN** user can manually add it to the rc file sourcing loop
- **AND** OR user reads documentation recommending how to add it
- **AND** dotfiles do not need to be updated (backward compatible)

### Requirement: Profile organization is simplified but not forced
Users keep existing profiles; documentation guides consolidation path without requiring it.

#### Scenario: Existing profiles continue to work unchanged
- **WHEN** user has existing `.github_profile`, `.aws_profile`, etc.
- **THEN** setup.sh does not move or modify these files
- **AND** shell startup sources them from their current location
- **AND** user's credentials and settings remain intact

#### Scenario: Documentation proposes consolidation path
- **WHEN** user reads README or optimization guide
- **THEN** documentation explains: profile files could be consolidated into `.bash_secrets`
- **AND** documentation provides template showing how to migrate
- **AND** documentation states: consolidation is optional
- **AND** no pressure or requirement to change existing workflow

### Requirement: Profile sourcing order is transparent
Users understand when each profile is sourced relative to other config.

#### Scenario: Sourcing sequence is documented
- **WHEN** user reads .bashrc or .zshrc
- **THEN** file contains clear comments showing sourcing sequence:
  1. Direct .bashrc/.zshrc content
  2. .bash_exports (common variables)
  3. .aliases (common aliases)
  4. .functions.d/ (modular functions)
  5. .<name>_profile files (tool-specific, in order)
  6. .bashrc.local/.zshrc.local (user customizations)
- **AND** user understands precedence and can predict behavior

#### Scenario: README documents profile loading
- **WHEN** user reads README
- **THEN** section "Shell Configuration" or "Profile Sourcing" explains the load order
- **AND** user understands which profile should go where
- **AND** user can troubleshoot variable conflicts

### Requirement: Profile conflicts are resolvable
If multiple profiles define the same variable, behavior is predictable.

#### Scenario: Last profile sourced wins
- **WHEN** multiple profiles define `$MYVAR`
- **THEN** the last profile in sourcing order sets the final value
- **AND** user can inspect sourcing order to predict which profile wins
- **AND** user can override by placing variables in later profiles

#### Scenario: User can document dependencies
- **WHEN** profile depends on variables from earlier profiles
- **THEN** profile contains comments explaining dependencies
- **AND** user understands profile interactions
- **AND** reordering profiles is a documented, intentional operation
