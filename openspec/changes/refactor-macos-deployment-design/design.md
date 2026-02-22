# Design: macOS/ZSH-Optimized Dotfiles Refactor

## Context

**Current State**: The dotfiles repository contains:
- Mixed bash/zsh support with duplicated patterns
- Inherited Linux-distribution-specific configurations
- Manual bootstrap process (requires manual symlinks, permissions, directory creation)
- Profile-based organization with significant sprawl (many `.<name>_profile` files)
- Unclear separation between OS-specific, shell-specific, and tool-specific config

**Constraints**:
- Must maintain backward compatibility for existing ZSH users
- Bash functionality should remain (simplified, not dropped)
- Cannot require macOS-specific tools that don't exist on BSD
- Setup process must be runnable from fresh clone
- Users maintain custom `.extras` and `.<name>_profile` files

**Stakeholders**:
- Current users: Adam Buxton(abuxton), contributors who have customized the dotfiles
- Target users: macOS/BSD developers using ZSH or Bash
- Integration points: OpenSpec workflow, Github Copilot, OpenCode

## Goals / Non-Goals

**Goals:**
- Make setup fully reproducible (single `source setup.sh` command recreates entire environment)
- Eliminate manual state changes (symlinks, permissions, directory creation all in scripts)
- Reduce configuration duplication between bash/zsh
- Clarify directory structure (files organized by capability, not platform noise)
- Improve maintainability and onboarding
- Support both bash and zsh with minimal special-case code

**Non-Goals:**
- Support Linux distributions (this is macOS-focused)
- Maintain Ansible configurations or other orchestration tools
- Support sh/ksh/fish/other shells
- Eliminate all profile files (keep them, but simplify organizational patterns)
- Provide GUI setup wizard (CLI-only approach)

## Decisions

### Decision 1: Modular Function/Alias Loading with POSIX-Compatible Patterns
**Choice**: Implement `.functions.d/` directory sourced from both shells; write functions in POSIX-compatible shell syntax.

**Pattern** (see https://chr4.org/posts/2014-09-10-conf-dot-d-like-directories-for-zsh-slash-bash-dotfiles/):
```
.functions.d/
├── git.sh        # Common git functions (POSIX shell)
├── system.sh     # Common system functions (POSIX shell)
└── productivity.sh

.bashrc sources functions:
  for func_file in ~/.functions.d/*.sh; do
    [ -f "$func_file" ] && . "$func_file"
  done

.zshrc sources functions (same pattern):
  for func_file in ~/.functions.d/*.sh; do
    [ -f "$func_file" ] && . "$func_file"
  done
```

**Constraints**:
- Functions must use POSIX-compatible shell constructs (no bash-isms like `[[`, arrays, etc.)
- Functions requiring shell-specific features go in shell-specific sections of .bashrc/.zshrc
- Document compatible constructs in CONTRIBUTING.md

**Rationale**: 
- POSIX-compatible functions achieve DRY without special-case code
- Both shells iterate and source the same directory using standard patterns
- No duplication, easier maintenance
- Users can add custom functions to the same directory
- Transparent sourcing behavior

**Alternative Considered**: Separate `.zsh_functions` and `.bash_functions`
- Rejected: Doubles maintenance burden; POSIX compatibility achieves most benefits

---

### Decision 2: Unified setup.sh as Single Source of Truth
**Choice**: Single `setup.sh` script that:
- Creates all required directories
- Installs/removes symlinks
- Sets file permissions
- Validates installation

**Pattern**:
```bash
# setup.sh orchestrates:
1. Create ~/.config, ~/.local/bin, etc.
2. Link dotfiles to ~/ (symlinks, not copies)
3. Set permissions (.bash_secrets → 600, scripts → 755)
4. Load .bash_exports from either ~/.bash_exports.local or environment
5. Validate: check symlinks exist, permissions correct, shells work
```

**Rationale**:
- Reproducible: Running twice is idempotent and safe
- Follows "Spilled Coffee Principle" (single person doesn't become bottleneck)
- No manual commands needed
- Self-documenting (setup process is visible, not tribal knowledge)

**Alternative Considered**: Keep bootstrap.sh with manual linking
- Rejected: Users forget steps, environment breaks with symlink errors

---

### Decision 3: Shell Startup Order - Explicit and Documented
**Choice**: Follow standard shell startup behavior; explicit sourcing order in each shell's rc file, documented for clarity.

**Reference**: https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/

**Bash Startup** (.bash_profile on login shells, .bashrc on interactive):
```bash
# .bash_profile (login shells only):
[ -f ~/.bashrc ] && . ~/.bashrc
[ -f ~/.bash_profile.local ] && . ~/.bash_profile.local

# .bashrc (ALL interactive shells):
#  1. .bash_exports (common exports)
#  2. .aliases (common, portable aliases)
#  3. .functions.d/*.sh (common functions)
#  4. Tool-specific profiles (github, aws, etc.)
#  5. ~/.bashrc.local (user customizations)
```

**Zsh Startup** (.zshrc on interactive shells, .zprofile on login):
```zsh
# .zprofile (login shells only):
[ -f ~/.zshenv ] && . ~/.zshenv
[ -f ~/.zprofile.local ] && . ~/.zprofile.local

# .zshrc (interactive shells):
#  1. .bash_exports (common exports)
#  2. .aliases (common, portable aliases)
#  3. .functions.d/*.sh (common functions)
#  4. Tool-specific profiles (github, aws, etc.)
#  5. ~/.zshrc.local (zsh plugins, prompt, customizations)
```

**File Structure**:
```
.bashrc                    # Sources common exports, aliases, functions; loads profiles
.bash_profile              # Minimal: sources .bashrc and .bash_profile.local
.zshrc                     # Sources common exports, aliases, functions; loads profiles; zsh-specific
.zprofile                  # Minimal: sources .zshenv and .zprofile.local
.bash_exports              # Common exports (variable definitions)
.aliases                   # Common aliases (POSIX compatible)
.functions.d/              # Modular functions, both shells source
.bashrc.local/.zshrc.local # User customizations (git-ignored)
```

**Rationale**:
- Matches standard macOS shell startup and expected user behavior
- Clear, documented sourcing order prevents surprises
- Explains WHY files are sourced in a particular order
- Shell-specific customizations (plugins, prompt) stay in appropriate files
- Matches reference material and best practices

**Alternative Considered**: Create single unified .rc file for both shells
- Rejected: Shell startup mechanisms are fundamentally different; unification creates confusion

---

### Decision 4: Profile Organization - Explicit Sourcing with Documented Migration Path
**Choice**: Keep tool-specific `.<name>_profile` files; add explicit sourcing in both `.bashrc` and `.zshrc` with documented migration path.

**Pattern**:
```bash
# In .bashrc/.zshrc, after .functions.d/ sourcing:
for profile_name in github aws gcloud azure docker kubernetes rancher; do
  profile_file="$HOME/.${profile_name}_profile"
  if [ -f "$profile_file" ]; then
    . "$profile_file"
  fi
done

# After profiles, source local customizations:
[ -f ~/.bashrc.local ] && . ~/.bashrc.local     # bash only
[ -f ~/.zshrc.local ] && . ~/.zshrc.local       # zsh only
```

**Migration Path** (documented in README):
- Existing `.<name>_profile` files continue to work unchanged
- Users can migrate profiles to `.bash_secrets` at their own pace
- Document `.bash_secrets` template with examples
- Provide script to help migrate if desired

**Rationale**:
- Users already have `.<name>_profile` files with credentials
- Forcing migration creates friction and risk of lost credentials
- Explicit sourcing order prevents surprises and hard-to-debug issues
- Profiles sourced consistently in both shells
- Provides path to eventual consolidation without forcing it
- Respects existing user workflows

**Alternative Considered**: Merge all profiles into one `.bash_secrets` immediately
- Rejected: Would require risky data migration; risk credential loss; existing workflow is stable

---

### Decision 5: Secrets Handling with Automatic Template
**Choice**: Provide template; setup.sh creates from template if missing:

```bash
# setup.sh:
if [ ! -f ~/.bash_secrets ]; then
  cp ~/.dotfiles/.bash_secrets.example ~/.bash_secrets
  chmod 600 ~/.bash_secrets
fi
```

**Rationale**:
- No manual permission management
- Template keeps secrets out of git
- Clear pattern for new machines
- All permissions automated

---

### Decision 6: Remove Linux-Specific Dotfiles
**Choice**: Delete:
- `arch-linux/` directory
- `.bash` patterns specific to non-macOS systems
- Platform detection logic that adds complexity

**Rationale**:
- This is a macOS project
- Platform-specific logic in shared files creates maintenance burden
- atxtechbro/dotfiles shows clean organization by platform at top level

**Alternative Considered**: Keep for future Linux support
- Rejected: Maintains complexity today for hypothetical future

---

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| **Users have customized existing dotfiles** | Provide migration guide; setup.sh creates backups of existing symlinks before replacing them |
| **Bash users feel abandoned** | Keep bash working; simplified but fully supported; document that ZSH is optimized path |
| **Shell detection logic fails silently** | Validation script tests both bash and zsh; CI runs basic sourcing tests |
| **Users have custom profile files** | Keep profile pattern; document clearly; don't force consolidation |
| **Symlink strategy breaks if user moves dotfiles** | setup.sh uses DOT_DEN env var or discovers dotfiles dynamically; validate in setup.sh |
| **setup.sh runs twice causing issues** | Design for idempotency; idempotent creates symlinks, removes old ones safely |

---

## Migration Plan

### Phase 1: Setup Script Enhancement (pre-release)
1. Create new setup.sh with full reproducibility
2. Backup strategy: setup.sh backs up existing files before replacing
3. Validation: setup.sh confirms all symlinks, permissions, environment

### Phase 2: Branch Refactor (feature branch)
1. Restructure files (functions.d/, consolidate aliases, remove Linux-specific)
2. Test both bash and zsh sourcing
3. Verify ZSH plugins still work (fzf, prompt, etc.)
4. Commit to feature branch; request review

### Phase 3: Release (PR → main)
1. PR includes migration guide for users with customizations
2. Document what changed: file locations, profile ordering
3. Provide rollback: keep old setup for 1-2 releases if needed

### Phase 4: Deprecation (future release)
1. Remove old bootstrap.sh references from README
2. Migrate atxtechbro/homebrew-brewfile integration to new setup.sh

### Rollback Strategy
- setup.sh creates `.dotfiles.backup/` with previous state
- User can restore: `cp -r ~/.dotfiles.backup/* ~/`
- Git provides history if symlinks break

---

## Open Questions

1. **Should we version the setup.sh?** (e.g., setup-v2.sh alongside original)
   - Recommendation: Yes, for safety. New branch uses setup.sh; old branch keeps bootstrap.sh.

2. **How do we handle macOS Homebrew path optimization?**
   - Recommendation: Integrate atxtechbro/homebrew-brewfile; setup.sh calls into it

3. **Should ZSH plugins (.oh-my-zsh, p10k, etc.) be vendored or assumed installed?**
   - Recommendation: Document assumptions; setup.sh validates they exist; users install separately via brewfile

4. **Do we provide compliance/validation CI checks?**
   - Recommendation: Yes; GitHub Actions workflow runs: `bash setup.sh && bash -c '...'` to validate sourcing

5. **Profile sourcing order**: Alphabetical or explicit?**
   - Recommendation: Explicit list in setup.sh so users understand load order

