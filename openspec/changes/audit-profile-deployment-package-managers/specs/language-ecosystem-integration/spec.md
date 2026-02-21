## ADDED Requirements

### Requirement: Define Python package management through uv/pyenv
The system SHALL standardize Python tool installation through uv package manager and pyenv version management.

#### Scenario: Python tools via uv
- **WHEN** installing Python tools (black, ruff, pytest, etc.)
- **THEN** system uses uv to manage them with specified versions in pyproject.toml or uv.toml

#### Scenario: Python version management
- **WHEN** system detects .python-version file
- **THEN** pyenv is used to install and activate the specified Python version

### Requirement: Define Go package management through go.work and manifests
The system SHALL standardize Go tool installation through go.work or dedicated go-tools manifest.

#### Scenario: Go tools installation
- **WHEN** installing Go tools (golint, gum, gup, jsonui, etc.)
- **THEN** go install commands are executed with versions specified in go-tools manifest

#### Scenario: GOPATH and GOROOT setup
- **WHEN** system detects Go is needed
- **THEN** GOPATH and GOROOT are configured via .go_profile, with tools installed to GOBIN

### Requirement: Define Ruby package management through rbenv and Gemfile
The system SHALL standardize Ruby tool installation through rbenv version management and Bundler.

#### Scenario: Ruby version management
- **WHEN** system detects .ruby-version file
- **THEN** rbenv is used to install and activate the specified Ruby version

#### Scenario: Ruby gems installation
- **WHEN** Ruby tools are needed (colorls, etc.)
- **THEN** they are installed via Gemfile managed by Bundler, not directly in profile

### Requirement: Define Node.js package management through nvm/npm
The system SHALL standardize Node.js global tool installation through npm-packages manifest or package.json.

#### Scenario: Node version management
- **WHEN** system detects .nvmrc or node version requirement
- **THEN** nvm is used to install and activate the specified Node version

#### Scenario: Global npm packages
- **WHEN** global npm tools are needed (add-gitignore, etc.)
- **THEN** they are installed via npm packages manifest with versions

### Requirement: Define Rust package management through rustup and tool-specific manifests
The system SHALL standardize Rust tool installation through rustup and language-specific tool managers.

#### Scenario: Rustup toolchain setup
- **WHEN** system detects Rust is needed
- **THEN** rustup is used to manage toolchains, with versions specified in rust-toolchain.toml

#### Scenario: Cargo binary installation
- **WHEN** Rust CLI tools are needed
- **THEN** cargo install is used with versions tracked in a Rust tools manifest

### Requirement: Define package manager initialization order
The system SHALL specify the correct initialization and execution order for all package managers during setup.

#### Scenario: Initialization sequence
- **WHEN** setup.sh initializes language tools
- **THEN** order is: 1) Homebrew, 2) pyenv, 3) rbenv, 4) nvm, 5) rustup, 6) language-specific packages

#### Scenario: Post-initialization
- **WHEN** all package managers are initialized
- **THEN** profiles source the appropriate initialization hooks (eval statements) after paths are set

### Requirement: Verify each language ecosystem is configured and available
The system SHALL perform health checks ensuring each language ecosystem is properly installed, initialized, and can install packages.

#### Scenario: Python ecosystem check
- **WHEN** system validates Python setup
- **THEN** it verifies: pyenv installed, Python version active, uv available, can install packages

#### Scenario: Go ecosystem check
- **WHEN** system validates Go setup
- **THEN** it verifies: Go installed, GOPATH set, GOBIN in PATH, can execute go install
