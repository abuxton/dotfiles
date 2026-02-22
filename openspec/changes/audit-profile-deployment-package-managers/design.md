## Context

**Current State**:
- `setup.sh` (created in refactor-macos-deployment-design) handles core dotfile deployment: directories, core symlinks, permissions
- `brewfile-setup.sh` (created in refactor-macos-deployment-design) manages Homebrew packages via ~/.homebrew (cloned from atxtechbro/homebrew-brewfile)
- `.bash_profile` and `.zshrc` source `.exports`, `.aliases`, `.functions.d/`, `.bash_secrets`, but do NOT explicitly source `.*_profile` files
- 22 context-specific profile files exist (`.*_profile`) with scattered package manager operations: pyenv, rbenv, nvm, rustup, cargo, go install, npm install, etc.
- Key language managers (pyenv, rbenv) have `version` commands that run at shell startup showing they're active
- `.extras` file provides user customization hook but is not git-tracked
- `validate-dotfiles.sh` exists but doesn't validate profile deployment or package manager health

**Constraints**:
- Existing infrastructure (brewfile-setup.sh, setup.sh) must not be rewritten; only extended
- Profiles currently work (even if not explicitly sourced) - don't break them
- BREW_HOME is a separate git repository (~/.homebrew cloned from external repo) with its own Brewfile
- Users have customized dotfiles and credentials in profile files; must provide safe migration path
- Homebrew is already fully operational with its own management layer
- Decision 4 from refactor design: "Keep tool-specific `.<name>_profile` files; add explicit sourcing"

**Stakeholders**:
- Current users who have custom profiles and credentials
- Language tool maintainers (pyenv, rbenv, etc. setups scattered in profiles)
- New users who want reproducible language ecosystem setup

## Goals / Non-Goals

**Goals**:
- Enable explicit, discoverable sourcing of all `.*_profile` files in .zshrc and .bash_profile
- Audit and document what each profile does and its dependencies (inventory)
- Create declarative manifests for language tools (pyproject.toml, .ruby-version, Gemfile, etc.) without forcing immediate consolidation
- Ensure profile sourcing order is correct and predictable (language managers before tool installations)
- Extend setup.sh to deploy all profile symlinks, not just core dotfiles
- Define clear sourcing hooks for language-specific initialization (pyenv init, rbenv init, rustup setup, etc.)
- Validate that package managers and language ecosystems are healthy after setup

**Non-Goals**:
- Rewrite or restructure brewfile-setup.sh (it's working; only extend setup.sh to use it)
- Force immediate migration of credentials from profiles to .bash_secrets (provide path, not mandate)
- Create single unified manifest for all packages (Homebrew, Python, Go, Ruby, Node, Rust each have their own ecosystem)
- Change bootstrap.sh responsibilities (it's secondary; setup.sh is main path)
- Support languages beyond: Python, Ruby, Go, Node, Rust (Homebrew handles others via packages)

## Decisions

### Decision 1: Explicit Profile Sourcing in Shell Initialization
**Choice**: Add explicit profile sourcing loop to both `.bash_profile` and `.zshrc` AFTER `.functions.d/` but BEFORE `.bash_secrets` and `.extras`.

**Pattern**:
```bash
# In .bash_profile (after .functions.d/, before .bash_secrets):
for profile in ~/.{github,aws,gcloud,azure,docker,kubernetes,python,ruby,go,rust}_profile ~/.{bob,claude,openai,hashicorp,rancher,instruqt,vscode}_profile; do
  [ -r "$profile" ] && source "$profile"
done

# Same pattern in .zshrc
```

**Rationale**:
- Profiles ARE used by current setup (pyenv/rbenv show versions at startup)
- Currently sourced implicitly (or not at all); making explicit prevents silent failures
- Matches Decision 4 from refactor design: "explicit sourcing with documented migration path"
- Order matters: profiles must source BEFORE .bash_secrets and .extras so credentials can be in profiles
- Provides clear contract: if users see profile loop, they understand how profiles are loaded
- No forced migration: profiles continue to work exactly as before, just sourceable

**Alternative Considered**: Auto-discover profiles with glob pattern
- Rejected: Explicit list better for security and clarity; globs can unexpectedly source files

---

### Decision 2: Profile Deployment as Part of setup.sh
**Choice**: Extend setup.sh (which already symlinks core dotfiles) to also symlink all discovered `.*_profile` files to home directory.

**Implementation in setup.sh**:
```bash
# After core symlinks, discover and link all .*_profile files:
for profile in openspec/changes/audit-profile-deployment-package-managers/specs/profile-deployment/spec.md$DOTFILES_DIR/.*_profile; do
  if [ -f "$profile" ]; then
    create_symlink "$profile" "$HOME/$(basename $profile)"
  fi
done
```

**Rationale**:
- setup.sh is already doing symlink orchestration; profile symlinks follow same pattern
- Keeps all deployment logic in one place (not split across multiple scripts)
- Profiles move from manual sourcing to automatic discovery via symlinks
- Idempotent: running setup.sh twice re-validates profile symlinks are correct

**Alternative Considered**: Keep profiles in dotfiles/ and source directly (no symlink)
- Rejected: Symlinks provide flexibility for future local-only profiles; matches refactor design pattern

---

### Decision 3: Language Ecosystem Initialization Hooks
**Choice**: Each profile files includes initialization hooks for its package manager in correct order:

```bash
# .python_profile:
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"  # Must run early
eval "$(pyenv init -)"       # Then shell specific

# .ruby_profile:
eval "$(rbenv init -)"
export RUBY_PACKAGE_PATH="$HOME/.gem/bin"
export PATH="$RUBY_PACKAGE_PATH:$PATH"

# .go_profile:
export GOPATH=$HOME/golang
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN:$(brew --prefix golang)/libexec/bin

# .rust_profile:
export PATH="${HOME}/.cargo/bin:$PATH"
# rustup handles its own init
```

**Rationale**:
- Language managers require very specific initialization order
- Consolidating in profiles prevents PATH/init pollution in shell rc files
- Hooks called once per environment at shell startup
- Each profile owns its own ecosystem setup

**Alternative Considered**: Centralize all language inits in .zshrc
- Rejected: Creates tight coupling; shell rc files become complex; profiles own their domains

---

### Decision 4: Profile Inventory & Audit Process
**Choice**: Create formal audit capability (`openspec/changes/audit-profile-deployment-package-managers/...`) that generates:
1. **profile-inventory.md** - Complete list with metadata (size, location, last modified, purpose)
2. **audit-report.md** - Analysis of dependencies, cross-profile conflicts, unused profiles, consolidation opportunities
3. **Recommendations** - Path for each tool to move to declarative manifests without forced migration

**When to Run**:
- As part of CI/CD to catch new profiles and dependency changes
- Manually when adding new profiles
- Before consolidating profiles (to understand impact)

**Rationale**:
- Profiles are scattered and hard to track; audit makes them visible and analyzable
- Recommendations provide path forward without forcing immediate change
- Enables future consolidation work to start from solid understanding

---

### Decision 5: Package Manager Manifests (Declarative, Non-Blocking)
**Choice**: Create optional manifest files for each language ecosystem WITHOUT consolidating operations yet:

**Manifests to Create**:
- `pyproject.toml` + `uv.lock`: Python tools (currently: pyenv config, pip installs) - **status**: define only
- `.ruby-version` + `Gemfile`: Ruby tools (currently: rbenv config, gem colorls) - **status**: define only
- `go-tools.manifest`: Go tools (currently: go install commands in .go_profile) - **status**: define only
- `npm-packages.json`: Node tools (currently: npm install -g in bootstrap.sh) - **status**: define only
- `rust-toolchain.toml` + cargo.toml: Rust tools (currently: rustup paths in .rust_profile) - **status**: define only
- `.zprofile-path` or similar for shell-specific PATH setup - **status**: define only

**Approach**:
- Define structure and location but don't force immediate use
- Document mapping: "If .python-version exists, pyenv uses it; if pyproject.toml exists, uv uses it"
- Provide migration helper tools/docs but don't automate migration
- Audit will flag when tools should move to manifests (recommendations)

**Rationale**:
- Each language ecosystem has its own package manager and conventions
- Creating manifests now enables future consolidation without rewriting profiles
- Non-blocking approach respects existing workflows
- Matches Decision 4 from refactor: "provide migration path but don't force it"

---

### Decision 6: Validation Integration
**Choice**: Extend `validate-dotfiles.sh` to check:
1. All expected profile symlinks exist and are readable
2. Key language managers are installed and functional (if profiles enable them)
3. Setup.sh can re-run without errors (idempotency check)
4. Shell can source all configuration without errors

**New validation sections**:
```bash
# validate-dotfiles.sh additions:
validate_profiles()      # Check all .*_profile symlinks
validate_language_tools() # Check pyenv, rbenv, nvm, rustup, go, cargo available
validate_setup_idempotency() # Re-run setup.sh in dry-run mode
validate_shell_sourcing() # bash -c 'source ~/.bash_profile' && zsh -c 'source ~/.zshrc'
```

**Rationale**:
- Current validation in setup.sh is minimal; extending it catches more issues
- Validates complete deployment chain: symlinks + initialization + tools ready
- Idempotency check catches breaking changes early

---

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| **Adding profile sourcing loop changes startup time** | Profile sourcing is negligible overhead; if issue, document how to disable specific profiles temporarily |
| **Explicit profile loop might conflict with user's .bashrc.local sourcing** | Document in .bashrc comments that local sourcing should not duplicate profiles; validation catches conflicts |
| **Package manager initialization order sensitive** | Document exact order required for each manager; audit report flags incorrect ordering |
| **Current profiles might have circular sources or conflicts** | Audit report flags these; user chooses migration timeline |
| **Profiles not yet deployed to home (only in dotfiles)** | setup.sh symlinks them; after one run, they're at ~/.python_profile, etc. |
| **Users with custom local profiles won't symlink** | Document that users can create ~/.custom_profile without symlinking; sourcing loop will find it |
| **validate-dotfiles.sh becomes slower with more checks** | Break validation into fast (symlinks) and slow (language tools); allow selective runs |

---

## Migration Plan

### Phase 1: This Change (Immediate)
1. Add explicit profile sourcing to .bash_profile and .zshrc
2. Extend setup.sh to symlink all .*_profile files
3. Create audit capability and generate profile-inventory.md, audit-report.md
4. Document profiles and their purposes in README

### Phase 2: User Adoption (Optional, Self-Paced)
1. Run `bash setup.sh` (places profile symlinks in home)
2. Profiles load automatically on next shell startup
3. Review audit-report.md for consolidation opportunities
4. Optionally create declarative manifests for tools (pyproject.toml, Gemfile, etc.)

### Phase 3: Future Consolidation (Only if Adopted)
1. Consolidate most-used tools to manifests (Python, Ruby)
2. Reduce redundant profile operations
3. Standardize initialization across environments

### Rollback Strategy
- If profile sourcing causes issues: temporarily remove specific profiles from sourcing loop in .zshrc/.bash_profile
- If symlinks cause conflicts: setup.sh already backs up existing files to ~/.dotfiles.backup
- Original profiles work unchanged; symlinks are optional convenience

---

## Open Questions

1. **Should profile sourcing be optional?** (e.g., ENABLE_PROFILES env var)
   - Current: Decidedly explicit (always source listed profiles)
   - Alternative: Could make optional to reduce startup overhead for minimal users

2. **Should setup.sh also initialize Homebrew?** (Currently brewfile-setup.sh does this separately)
   - Current: setup.sh calls into brewfile-setup.sh when user chooses
   - Alternative: setup.sh could automatically run minimal Homebrew initialization

3. **Which profiles are essential vs. optional for validation?**
   - Current: Audit report shows all; validate-dotfiles.sh checks what exists
   - Alternative: Mark core vs. optional; validate only warns on optional missing

4. **Should audit-report.md be version-controlled or generated dynamically?**
   - Current: Generated as part of audit process
   - Alternative: Keep in git for historical tracking of profile evolution
