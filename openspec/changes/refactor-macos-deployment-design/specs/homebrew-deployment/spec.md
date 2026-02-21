## ADDED Requirements

### Requirement: Homebrew deployment is orchestrated via setup.sh integration
The setupsh script integrates with https://github.com/abuxton/homebrew-brewfile to ensure all dependencies are installed.

#### Scenario: setup.sh can optionally install dependencies
- **WHEN** user runs `source setup.sh`
- **THEN** setup.sh offers option to install Homebrew packages (e.g., "Install Homebrew dependencies? [y/n]")
- **AND** if user chooses yes, setup.sh calls brewfile deployment
- **AND** all packages from brewfile are installed or updated

#### Scenario: setup.sh documents brewfile requirement
- **WHEN** user reads setup.sh output or README
- **THEN** documentation explains the brewfile dependency
- **AND** user knows they can manage dependencies separately if desired
- **AND** setup.sh works even if brewfile is skipped

### Requirement: Brewfile is version-controlled separately
Homebrew dependencies are maintained in an external repository to avoid tight coupling.

#### Scenario: Brewfile location is obvious
- **WHEN** user looks at setup.sh or README
- **THEN** documentation links to https://github.com/abuxton/homebrew-brewfile
- **AND** user understands: brewfile is separate from dotfiles, versioned independently
- **AND** user can update brewfile without updating dotfiles

### Requirement: Deployment is optional but recommended
Users can skip Homebrew setup; dotfiles work without it (with reduced capabilities).

#### Scenario: Dotfiles work without running brewfile
- **WHEN** user runs `source setup.sh` and declines to install dependencies
- **THEN** dotfiles setup completes successfully
- **AND** shell functions work (those that don't require external tools)
- **AND** user understands some features may be limited without dependencies

#### Scenario: Documentation guides when brewfile is useful
- **WHEN** user reads README or deployment docs
- **THEN** documentation explains: which tools are optional, which are recommended
- **AND** user can make informed decision about whether to run brewfile
