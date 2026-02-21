## Why

The current bootstrap and setup system has evolved organically with two separate entry points (`bootstrap.sh` and `setup.sh`), minimal profile deployment support, and scattered package manager operations across 22+ context-specific profile files (`.*_profile`). This creates deployment fragility, inconsistent execution paths, and makes it difficult to maintain reproducibility and validate setup completion. Package manager operations (Go, Python, Ruby, npm, Rust, etc.) are embedded in profiles rather than centralized, making it hard to audit dependencies and manage version consistency.

Consolidating and auditing this system will improve reproducibility, clarity, and enable declarative package management across all language ecosystems.

## What Changes

- **Audit & Map**: Complete inventory of all profile files, identify what each does, and map dependencies
- **Profile Deployment**: Ensure all `.*_profile` files are symlinked in `setup.sh` (currently minimal coverage)
- **Package Manager Audit**: Identify all package manager operations (brew, pip, npm, gem, cargo, rustup, rbenv, pyenv, etc.) across all profiles
- **Package Manager Consolidation**: Move language-specific package installations to a declarative system:
  - Homebrew packages → `Brewfile` (already partially implemented)
  - Python packages → `pyproject.toml` or `uv.lock` (with pyenv/uv integration)
  - Node packages → `package.json` with global tools or `npm-packages` manifest
  - Ruby gems → `.ruby-version` + `Gemfile` or bundle-managed globals
  - Go tools → `go.work` or `go-tools` manifest
  - Rust tools → `rustup` toolchain file with tool-specific manifests
  - Other managers (gcloud, az, etc.) → Integration points in setup
- **Clear Responsibilities**: Define which script handles what (bootstrap vs setup vs brewfile-setup vs new package managers)

## Capabilities

### New Capabilities

- `profile-deployment`: Symlink all context-specific profile files (`.*_profile`) in a standardized, discoverable way
- `package-manager-consolidation`: Create unified package management system replacing embedded installations with declarative manifests
- `profile-inventory-and-auditing`: Document all profiles, their dependencies, and what they configure
- `bootstrap-setup-clarification`: Define clear responsibilities between `bootstrap.sh` and `setup.sh`
- `language-ecosystem-integration`: Standardized approach for each language ecosystem (Python/uv, Go, Ruby, Node, Rust, etc.)

### Modified Capabilities

- `reproducible-deployment`: (existing from refactor-macos-deployment-design) — Update with profile symlinks and package manager integration

## Impact

- **Files affected**: `bootstrap.sh`, `setup.sh`, `brewfile-setup.sh`, all `.*_profile` files
- **New files**: Language-specific package manifests (if not already present)
- **Dependencies**: Package managers (brew, uv, npm, gem, etc.) and their configuration discovery
- **Breaking changes**: Potentially rescopes what `bootstrap.sh` does; users may need to adjust workflows
