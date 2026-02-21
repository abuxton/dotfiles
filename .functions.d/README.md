# Functions Directory

Common shell functions sourced by both `.bashrc` and `.zshrc`.

## Organization

Functions are organized by domain in separate files:

- **git.sh** - Git helper functions (current branch, recent branches, status, root, stash)
- **system.sh** - System utilities (mkdir-cd, remove .DS_Store, list dirs, disk usage, find, backup)
- **productivity.sh** - Productivity tools (todo management, timer, terminal reset)

## Adding New Functions

1. Create a new `.sh` file in this directory or add to an existing file
2. Write functions using **POSIX-compatible shell syntax only**
3. Include header comment with function purpose
4. Document function parameters and behavior

## Sourcing

Functions are automatically sourced by `.bashrc` and `.zshrc`:

```bash
for func_file in ~/.functions.d/*.sh; do
  [ -r "$func_file" ] && . "$func_file"
done
```

## POSIX Compatibility Requirements

To ensure functions work in both bash and zsh:

- Use `[ ]` for conditionals, not `[[ ]]`
- Avoid bash-specific constructs (arrays, etc.)
- Use `$( )` for command substitution, not backticks
- Document shell-specific behaviors if needed

## Custom Functions

Users can add custom functions by creating new `.sh` files in this directory.
Custom files will be sourced automatically and are not tracked by git.
