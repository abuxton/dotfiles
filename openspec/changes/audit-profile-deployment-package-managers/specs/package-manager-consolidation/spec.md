## ADDED Requirements

### Requirement: Audit and catalog all package manager operations
The system SHALL identify and document all package manager invocations across profiles (brew, pip, npm, gem, cargo, rustup, etc.) with their dependencies and purposes.

#### Scenario: Catalog Go package installations
- **WHEN** auditing the .go_profile file
- **THEN** system documents: "go install golang.org/x/lint/golint@latest" with reason "Go linter"

#### Scenario: Catalog Python tools
- **WHEN** auditing the .python_profile file
- **THEN** system identifies pyenv, uv, and virtual environment configurations

#### Scenario: Catalog Ruby gems
- **WHEN** auditing the .ruby_profile file
- **THEN** system documents the colorls gem installation and dependency path

### Requirement: Extract package manager operations into declarative manifests
The system SHALL move language-specific package installations from profile files to standardized, declarative manifests appropriate to each ecosystem.

#### Scenario: Extract Go tools to manifest
- **WHEN** consolidating Go package manager operations
- **THEN** a go-tools manifest is created or updated with tool versions and installation methods

#### Scenario: Extract Python tools to uv/pip manifest
- **WHEN** consolidating Python package manager operations
- **THEN** a pyproject.toml or uv.lock is updated with tool specifications

#### Scenario: Extract npm globals
- **WHEN** consolidating Node package manager operations
- **THEN** a npm-packages manifest or package.json is created with global tool list

#### Scenario: Extract Ruby gems
- **WHEN** consolidating Ruby package manager operations
- **THEN** a .ruby-version file and Gemfile are configured for rbenv/bundle

### Requirement: Define installation order and dependencies
The system SHALL specify the order in which package managers are initialized and packages installed, respecting dependency chains.

#### Scenario: Correct initialization order
- **WHEN** setup.sh installs packages
- **THEN** Homebrew is initialized first, then language managers (pyenv, rbenv, etc.), then language-specific packages

#### Scenario: Dep management during install
- **WHEN** Python tools require specific Python version
- **THEN** system ensures pyenv is available and correct Python version installed before pip packages

### Requirement: Provide rollback/cleanup capability
The system SHALL support removing consolidated package manager operations and restoring profiles if needed.

#### Scenario: Remove Go tools manifest
- **WHEN** user runs cleanup for go package manager
- **THEN** go-tools manifest is removed and old .go_profile is restored (if backed up)
