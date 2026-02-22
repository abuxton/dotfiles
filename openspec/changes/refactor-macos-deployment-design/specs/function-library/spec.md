## ADDED Requirements

### Requirement: Organized shell functions by domain
Shell functions are organized into domain-specific files in `~/.functions.d/` directory for maintainability and clarity.

#### Scenario: Functions are discoverable by category
- **WHEN** user browses `~/.functions.d/` directory
- **THEN** files are named by domain (e.g., `git.sh`, `system.sh`, `productivity.sh`)
- **AND** each file contains related functions only
- **AND** user can quickly find relevant functions

#### Scenario: New functions follow established pattern
- **WHEN** developer adds a new function to the library
- **THEN** developer places it in the appropriate domain file (or creates new one if needed)
- **AND** filename follows pattern: `<domain>.sh` (lowercase, kebab-case)
- **AND** function is documented with comment explaining purpose

### Requirement: Common shell functions are POSIX-compatible
All functions in the library use POSIX shell syntax to ensure they work in both Bash and ZSH.

#### Scenario: Function uses only portable shell constructs
- **WHEN** reviewing function code in `.functions.d/*.sh`
- **THEN** function avoids: bash arrays, `[[` conditionals, parameter expansion features specific to one shell
- **AND** function uses: `test`/`[` for conditionals, variables for data, functions for reusability
- **AND** function compiles without error in both bash and zsh

#### Scenario: CONTRIBUTING.md documents allowed constructs
- **WHEN** developer opens CONTRIBUTING.md
- **THEN** document lists POSIX-compatible shell constructs with examples
- **AND** document shows incorrect patterns to avoid
- **AND** developer has clear guidance for writing portable functions

### Requirement: Function library provides common utilities
The library provides well-tested, commonly-needed shell functions to reduce duplication across user customizations.

#### Scenario: Common functions are available
- **WHEN** user runs a new shell
- **THEN** common functions (e.g., git helpers, directory utilities, filtering tools) are available
- **AND** user can call functions from command line
- **AND** user can use functions within their own scripts

#### Scenario: Users can extend with custom functions
- **WHEN** user creates a new function in `~/.functions.d/custom.sh`
- **THEN** function is immediately available to new shell sessions
- **AND** user's custom functions coexist with library functions
- **AND** custom functions are preserved during dotfiles updates
