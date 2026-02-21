## MODIFIED Requirements

### Requirement: setup.sh creates all required directories automatically
The setup.sh script SHALL create all necessary directories (symbolic link targets, function directories, local config directories, package manager directories) as part of deployment. No manual `mkdir` commands are required from the user.

#### Scenario: Fresh clone gets all required directories
- **WHEN** user runs `source setup.sh` on a fresh clone
- **THEN** setup.sh creates `~/.functions.d/` directory
- **AND** setup.sh creates `~/.config/` directory
- **AND** setup.sh creates language-specific directories (e.g., `~/.pyenv`, `~/.cargo`, `~/.rbenv`)
- **AND** setup.sh creates `~/.homebrew/log` for Homebrew logging
- **AND** user does not receive "directory not found" errors

#### Scenario: Running setup.sh twice is safe
- **WHEN** user runs `source setup.sh` a second time
- **THEN** setup.sh does not error on existing directories
- **AND** directories are not deleted or modified unnecessarily

### Requirement: setup.sh creates and verifies all symlinks (core and profiles)
All dotfiles including context-specific profiles are deployed as symlinks (not copies). setup.sh SHALL create, verify, and update symlinks.

#### Scenario: Core dotfiles are symlinked to home directory
- **WHEN** user runs `source setup.sh`
- **THEN** core dotfiles (.bash_profile, .zshrc, .aliases, etc.) are symlinked to `~/`
- **AND** symlinks are verified to exist after creation
- **AND** no manual `ln -s` commands needed

#### Scenario: All profile files are symlinked
- **WHEN** user runs `source setup.sh`
- **THEN** all `.*_profile` files (.python_profile, .rust_profile, .azure_profile, etc.) are discovered and symlinked
- **AND** symlinks are created in home directory
- **AND** profiles are ready to be sourced by shell initialization

#### Scenario: Existing symlinks are updated if incorrect
- **WHEN** user runs setup.sh and a symlink points to wrong location
- **THEN** setup.sh removes the incorrect symlink
- **AND** setup.sh creates a new symlink to the correct location
- **AND** operation completes without user intervention

### Requirement: setup.sh sets file permissions correctly
Critical files (secrets, scripts, profiles) receive appropriate Unix permissions automatically.

#### Scenario: .bash_secrets receives secure permissions
- **WHEN** setup.sh creates or finds `.bash_secrets`
- **THEN** file permissions are set to `600` (read/write owner only)
- **AND** no other user can read credentials

#### Scenario: Executable scripts receive executable permissions
- **WHEN** setup.sh processes shell scripts in `~/bin/` or similar
- **THEN** scripts that should be executable receive `755` permissions
- **AND** non-executable scripts remain `644`

#### Scenario: Profile files have correct permissions
- **WHEN** symlinked profile files are deployed
- **THEN** profiles have `644` permissions (readable by user and shell, not writable by others)

### Requirement: setup.sh is idempotent (safe to run multiple times)
Running `source setup.sh` multiple times produces identical results. No data loss, no unexpected changes.

#### Scenario: Running setup.sh twice resets to same state
- **WHEN** user runs `source setup.sh`, then runs it again
- **THEN** all symlinks (core and profiles), directories, and permissions are identical to first run
- **AND** no files are deleted
- **AND** no errors occur

#### Scenario: Backups prevent data loss
- **WHEN** setup.sh needs to replace an existing file or symlink
- **THEN** setup.sh creates a backup (e.g., in `.dotfiles.backup/`) first
- **AND** user can manually recover from backup if needed

### Requirement: setup.sh validates installation success (including profiles and package manager readiness)
After completion, setup.sh SHALL verify that the environment is ready for use, including profile integrity and package manager availability.

#### Scenario: Validation confirms successful installation
- **WHEN** setup.sh completes
- **THEN** setup.sh validates: all symlinks exist, permissions correct, key directories present, all profiles symlinked
- **AND** user sees success message or list of issues
- **AND** no manual verification needed

#### Scenario: Validation detects and reports problems
- **WHEN** setup.sh validation finds a problem (broken symlink, wrong permissions, missing profile)
- **THEN** user receives clear error message explaining the problem
- **AND** user is given guidance to fix or re-run setup.sh

### Requirement: setup.sh delegates package manager setup appropriately
setup.sh SHALL coordinate package manager initialization (Homebrew, language managers) while delegating specific package installation to specialized scripts.

#### Scenario: Optional package manager setup
- **WHEN** setup.sh completes core deployment
- **THEN** it prompts user: "Install package managers and packages? (y/n)"
- **AND** if yes, it delegates to brewfile-setup.sh and language-specific managers

#### Scenario: Package manager initialization detected
- **WHEN** setup.sh detects brew, pyenv, rbenv needed
- **THEN** it initializes them with correct hooks in profile files
- **AND** profiles are ready to use package managers on shell startup

#### Scenario: Language ecosystem validation
- **WHEN** setup.sh completes
- **THEN** it checks if language ecosystems (Python via uv, Go, Ruby, Node, Rust) are available when needed
- **AND** it reports which are ready and which require additional setup

## ADDED Requirements

### Requirement: Profile sourcing hooks are automatically added to shell initialization
setup.sh SHALL automatically add source statements for all context profiles to `.zshrc` or `.bash_profile` if not already present.

#### Scenario: Profile sourcing added to .zshrc
- **WHEN** setup.sh runs and profiles are symlinked
- **THEN** if .zshrc does not contain sourcing for profiles, setup.sh adds: `for profile in ~/.{python,rust,go,ruby,azure}_profile; do [ -r "$profile" ] && source "$profile"; done`
- **AND** profiles are sourced in correct order (system tools first, then language tools)

#### Scenario: Profile sourcing idempotency
- **WHEN** setup.sh runs twice
- **THEN** profile sourcing lines are not duplicated in shell initialization files

### Requirement: Package manager state is predictable after setup
After setup completes, all package managers are in a known, clean state ready for package installation.

#### Scenario: Homebrew ready for bundle install
- **WHEN** setup.sh completes and Homebrew is installed
- **THEN** Homebrew is functional and ready to install packages via brewfile-setup.sh

#### Scenario: Python environment ready
- **WHEN** setup.sh completes and Python tools are enabled
- **THEN** pyenv/uv is available, correct Python version can be set, and packages can be installed

#### Scenario: Language managers initialized
- **WHEN** setup.sh completes
- **THEN** all enabled language managers (rbenv, nvm, rustup, etc.) are initialized and available in shell
