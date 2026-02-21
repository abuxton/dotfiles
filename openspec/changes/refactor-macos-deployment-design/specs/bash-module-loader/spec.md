## ADDED Requirements

### Requirement: Bash can load modular functions from .functions.d/ directory
The Bash shell SHALL automatically source all shell scripts in the `~/.functions.d/` directory when an interactive shell is initialized, using identical sourcing pattern to ZSH.

#### Scenario: Shell initializes and loads all function files
- **WHEN** user opens a new Bash interactive shell
- **THEN** all `.sh` files from `~/.functions.d/` are sourced using portable shell syntax
- **AND** functions defined in those files are available in the shell session

#### Scenario: Function from module is available in new bash shell
- **WHEN** user opens a new interactive bash shell after installing dotfiles
- **THEN** functions from `~/.functions.d/*.sh` are immediately available
- **AND** user can call custom functions without additional setup

### Requirement: Bash and ZSH use identical sourcing mechanism for .functions.d/
The sourcing pattern in `.bashrc` and `.zshrc` for loading `.functions.d/` SHALL be identical and portable.

#### Scenario: Same sourcing code works in both shells
- **WHEN** both `.bashrc` and `.zshrc` contain: `for func_file in ~/.functions.d/*.sh; do [ -f "$func_file" ] && . "$func_file"; done`
- **THEN** the sourcing completes without error in both shells
- **AND** functions are loaded identically

### Requirement: Bash interactive shells load functions consistently
Whether Bash is a login shell (`.bash_profile`) or non-login interactive shell (`.bashrc`), functions SHALL be available.

#### Scenario: Functions available in login shell
- **WHEN** user logs in and starts a login bash shell
- **THEN** `.bash_profile` sources `.bashrc`
- **AND** `.bashrc` sources functions from `~/.functions.d/`
- **AND** functions are available in the login shell

#### Scenario: Functions available in non-login interactive shell
- **WHEN** user opens a new non-login bash shell (e.g., running `bash`)
- **THEN** `.bashrc` is sourced directly
- **AND** `.bashrc` sources functions from `~/.functions.d/`
- **AND** functions are available in the shell
