## ADDED Requirements

### Requirement: Discover and enumerate all profile files
The system SHALL scan the dotfiles repository and discover all `.*_profile` files with their locations, sizes, and modification dates.

#### Scenario: Profile discovery during setup
- **WHEN** setup.sh runs its initialization phase
- **THEN** it outputs a list of all discovered profile files

### Requirement: Symlink all discovered profiles to home directory
The system SHALL create symlinks for all discovered `.*_profile` files in the home directory, with conflict detection and backup of existing files.

#### Scenario: First-time profile symlinking
- **WHEN** setup.sh detects that ~/.bash_profile does not exist as a symlink
- **THEN** it creates a symlink from ~/.bash_profile to $DOTFILES_DIR/.bash_profile

#### Scenario: Profile symlink exists but points to wrong location
- **WHEN** setup.sh detects that ~/.python_profile exists as a symlink pointing to an old location
- **THEN** it backs up the existing symlink and creates a new correct one

#### Scenario: Profile conflicts with existing file
- **WHEN** setup.sh detects that ~/.azure_profile exists as a regular file (not symlink)
- **THEN** it backs up the existing file and creates the symlink

### Requirement: Validate profile symlink integrity
The system SHALL verify that all expected profile symlinks exist and point to the correct files in the dotfiles repository.

#### Scenario: Validation passes
- **WHEN** all profile symlinks are correctly established
- **THEN** validation exits with status 0

#### Scenario: Validation detects missing symlink
- **WHEN** ~/.ruby_profile is expected but doesn't exist as a symlink
- **THEN** validate-dotfiles.sh reports "Missing profile symlink: ~/.ruby_profile"

### Requirement: Make profile deployment idempotent
Running the profile deployment process multiple times SHALL produce the same result without side effects or errors.

#### Scenario: Re-running profile setup
- **WHEN** setup.sh is run a second time
- **THEN** symlinks are verified existing and correct, no conflicts reported
