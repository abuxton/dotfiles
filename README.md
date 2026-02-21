# Dotfiles

[![Awesome](https://awesome.re/badge.svg)](https://awesome.re)

**Optimized for macOS/BSD with ZSH as primary shell and simplified Bash support.**

[![dotfiles cast](./assets/asciinema/dotfiles-session.gif)](./assets/asciinema/dotfiles-session.gif)

## Quick Start

```bash
git clone https://github.com/abuxton/dotfiles.git ~/dotfiles
cd ~/dotfiles
source setup.sh
./validate-dotfiles.sh
```

That's it! `setup.sh` handles everything:
- Creating required directories (`~/.functions.d/`, `~/.config/`)
- Setting up symlinks for all dotfiles
- Creating `.bash_secrets` with secure permissions (600)
- Installing function modules
- Backing up existing configurations

## Installation

**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don't want or need. Don't blindly use my settings unless you know what that entails. Use at your own risk!

### Using setup.sh (Recommended)

The easiest way to set up these dotfiles:

```bash
git clone https://github.com/abuxton/dotfiles.git ~/dotfiles
cd ~/dotfiles
source setup.sh
```

The `setup.sh` script is fully **idempotent** - running it multiple times is safe and produces the same result.

### Verify Installation

After installation, verify everything is configured:

```bash
./validate-dotfiles.sh
```

## Configuration

### Secrets Management

Create `~/.bash_secrets` for sensitive environment variables (API keys, tokens):

```bash
# Template is created automatically by setup.sh
# Edit to add your secrets
vim ~/.bash_secrets

# Verify permissions are secure (600)
ls -la ~/.bash_secrets
```

### Shell Configuration

- **ZSH (Primary)**: Full feature support with Oh My ZSH, Powerlevel10k theme
- **Bash (Simplified)**: Same core functionality with simpler setup

### Function Modules

Shell functions are organized in `~/.functions.d/`:
- **git.sh** - Git helpers
- **system.sh** - System utilities
- **productivity.sh** - Productivity tools

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## Troubleshooting

Run the validation script to diagnose issues:

```bash
./validate-dotfiles.sh
```

See README section for common issues and solutions.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed guidelines and POSIX-compatible shell patterns.

## License

MIT © Adam Buxton
