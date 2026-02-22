## ADDED Requirements

### Requirement: Shell startup files are consolidated and clear
Both `.bashrc` and `.zshrc` use identical sourcing patterns for common configuration; shell-specific config is kept minimal and documented.

#### Scenario: Common configuration is sourced from same files
- **WHEN** `.bashrc` and `.zshrc` initialize
- **THEN** both source: `.bash_exports`, `.aliases`, `.functions.d/`, and tool-specific profiles
- **AND** sourcing order is explicit and identical between shells
- **AND** users understand configuration precedence

#### Scenario: Shell-specific features stay in rc files
- **WHEN** shell-specific plugins or settings are needed (e.g., ZSH plugins, Bash completion)
- **THEN** these are configured directly in `.zshrc` or `.bashrc`
- **AND** they do not interfere with common configuration
- **AND** both shells work even if one shell-specific feature breaks

### Requirement: Linux-specific patterns are removed
Shell configuration no longer includes Linux-distribution-specific logic (Arch-specific, Ubuntu-specific patterns removed).

#### Scenario: No Linux platform detection in shared files
- **WHEN** reviewing `.bashrc`, `.zshrc`, `.aliases`, `.functions.d/`
- **THEN** files contain no Linux platform detection (e.g., `if [[ "$OSTYPE" == "linux-gnu" ]]`)
- **AND** files assume macOS/BSD operating system
- **AND** Linux users are directed to maintain separate configuration

#### Scenario: Installation documentation is macOS-focused
- **WHEN** user reads README or installation docs
- **THEN** documentation states: "These dotfiles are optimized for macOS and BSD"
- **AND** documentation does not provide Linux installation instructions
- **AND** Linux users understand this is not their tool

### Requirement: Configuration is optimized for macOS/ZSH
Shell configuration follows macOS defaults and ZSH-first patterns.

#### Scenario: ZSH is primary, Bash is supported
- **WHEN** shell configuration is set up
- **THEN** ZSH gets more features/optimization (plugins, prompt, advanced completion)
- **AND** Bash receives simplified but fully functional setup
- **AND** README documents this optimization policy

#### Scenario: macOS-specific paths and tools are used
- **WHEN** shell needs to reference system paths or tools
- **THEN** configuration uses macOS Homebrew paths (e.g., `/opt/homebrew/bin`)
- **AND** configuration does not require manual path edits for standard macOS setup
- **AND** cross-platform fallbacks are not added (macOS is assumed)

### Requirement: No complex bash-specific patterns
Eliminates complex bash patterns that don't work in ZSH or vice versa.

#### Scenario: Array usage is minimal and documented
- **WHEN** reviewing shell functions and configuration
- **THEN** array usage is avoided where possible (arrays don't port between shells)
- **AND** if arrays are used, they are documented with shell-specific alternatives
- **AND** most functions use simple variables instead

#### Scenario: Conditional syntax is portable
- **WHEN** reviewing shell code
- **THEN** conditionals use `[ ]` instead of `[[ ]]` for portability
- **AND** complex bash-specific conditionals are avoided
- **AND** equivalent ZSH patterns are used instead
