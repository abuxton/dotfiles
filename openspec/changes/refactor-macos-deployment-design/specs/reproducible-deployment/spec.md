## ADDED Requirements

### Requirement: setup.sh creates all required directories automatically
The setup.sh script SHALL create all necessary directories (symbolic link targets, function directories, local config directories) as part of deployment. No manual `mkdir` commands are required from the user.

#### Scenario: Fresh clone gets all required directories
- **WHEN** user runs `source setup.sh` on a fresh clone
- **THEN** setup.sh creates `~/.functions.d/` directory
- **AND** setup.sh creates any other required directories (e.g., `~/.config/`, if used)
- **AND** user does not receive "directory not found" errors

#### Scenario: Running setup.sh twice is safe
- **WHEN** user runs `source setup.sh` a second time
- **THEN** setup.sh does not error on existing directories
- **AND** directories are not deleted or modified unnecessarily

### Requirement: setup.sh creates and verifies all symlinks
All dotfiles are deployed as symlinks (not copies). setup.sh SHALL create, verify, and update symlinks.

#### Scenario: Dotfiles are symlinked to home directory
- **WHEN** user runs `source setup.sh`
- **THEN** dotfiles in the repository are symlinked to `~/` (e.g., `.zshrc` → `~/dotfiles/.zshrc`)
- **AND** symlinks are verified to exist after creation
- **AND** no manual `ln -s` commands needed

#### Scenario: Existing symlinks are updated if incorrect
- **WHEN** user runs setup.sh and a symlink points to wrong location
- **THEN** setup.sh removes the incorrect symlink
- **AND** setup.sh creates a new symlink to the correct location
- **AND** operation completes without user intervention

### Requirement: setup.sh sets file permissions correctly
Critical files (secrets, scripts) receive appropriate Unix permissions automatically.

#### Scenario: .bash_secrets receives secure permissions
- **WHEN** setup.sh creates or finds `.bash_secrets`
- **THEN** file permissions are set to `600` (read/write owner only)
- **AND** no other user can read credentials

#### Scenario: Executable scripts receive executable permissions
- **WHEN** setup.sh processes shell scripts in `~/bin/` or similar
- **THEN** scripts that should be executable receive `755` permissions
- **AND** non-executable scripts remain `644`

### Requirement: setup.sh is idempotent (safe to run multiple times)
Running `source setup.sh` multiple times produces identical results. No data loss, no unexpected changes.

#### Scenario: Running setup.sh twice resets to same state
- **WHEN** user runs `source setup.sh`, then runs it again
- **THEN** all symlinks, directories, and permissions are identical to first run
- **AND** no files are deleted
- **AND** no errors occur

#### Scenario: Backups prevent data loss
- **WHEN** setup.sh needs to replace an existing file or symlink
- **THEN** setup.sh creates a backup (e.g., in `.dotfiles.backup/`) first
- **AND** user can manually recover from backup if needed

### Requirement: setup.sh validates installation success
After completion, setup.sh SHALL verify that the environment is ready for use.

#### Scenario: Validation confirms successful installation
- **WHEN** setup.sh completes
- **THEN** setup.sh validates: all symlinks exist, permissions correct, key directories present
- **AND** user sees success message or list of issues
- **AND** no manual verification needed

#### Scenario: Validation detects and reports problems
- **WHEN** setup.sh validation finds a problem (broken symlink, wrong permissions)
- **THEN** user receives clear error message explaining the problem
- **AND** user is given guidance to fix or re-run setup.sh
