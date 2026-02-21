# Deep Directory Investigation Report

## init/ Directory

### Purpose
Configuration files for terminal emulators, IDE editors, and window managers.

### Contents

| File | Purpose | Type | Deploy? |
|------|---------|------|---------|
| Preferences.sublime-settings | Sublime Text 3 settings | JSON config | MAYBE |
| Solarized Dark xterm-256color.terminal | Terminal.app theme | macOS plist | MAYBE |
| Solarized Dark.itermcolors | iTerm2 color scheme | Config | MAYBE |
| spectacle.json | Spectacle window manager config | JSON config | MAYBE |

### Analysis

**Current Status**: Not automatically deployed by any script.

**Manual deployment typical flow**:
- Users need to manually copy or symlink these to appropriate locations
- Terminal.app: ~/Library/Application Support/Terminal/Profiles/
- iTerm2: Load from file in iTerm2 preferences
- Sublime Text: ~/Library/Application Support/Sublime Text 3/Packages/User/
- Spectacle: ~/Library/Application Support/Spectacle/

**Recommendation**: OPTIONAL DEPLOYMENT
- These are environment-specific (which terminal/editor users prefer)
- Some users may use different preferences
- Consider creating optional `setup-init.sh` for users who want these
- Add documentation to README: "Optional: run `bash init-setup.sh` to install terminal themes and editor settings"
- Rationale: Environment-specific, not essential for core dotfiles functionality

---

## modules/ Directory

### Purpose
UNKNOWN - Currently empty directory

### Contents
Empty (no files)

### Analysis

**Current Status**:
- Directory exists but is empty
- Unclear purpose
- Not referenced in any deployment scripts

**Investigation Questions**:
1. Is this a placeholder for future use?
2. Was this meant to hold plugin modules?
3. Should it be removed?
4. Does ".functions.d/" already serve the module purpose that "modules/" was intended for?

**Recommendation**: CLARIFY FIRST
- Determine if this directory has a purpose
- If no purpose, consider removing from repo
- If intended purpose exists, document it
- Don't deploy; wait for clarification

---

## .claude/ Directory

### Purpose
Claude AI integration configuration

### Contents

| Item | Purpose |
|------|---------|
| commands/ | Claude command definitions |
| skills/ | Claude skill definitions |

### Analysis

**Current Status**: Not deployed

**Purpose**: Stores CLI commands and skills for Claude AI agent integration

**Should Deploy?**: YES

**Reasoning**:
- These are part of the development setup
- Claude skills contain important automation logic
- Users who use Claude will need these

**Deployment Recommendation**: SYMLINK
- Add to explicit symlink handling in setup.sh
- Or use pattern: `for dir in "$DOTFILES_DIR"/.*/; do ...`
- Important for developers using Claude integration

---

## .opencode/ Directory

### Purpose
OpenCode (alternative agent) integration configuration

### Contents

| Item | Purpose |
|------|---------|
| command/ | OpenCode command definitions |
| skills/ | OpenCode skill definitions |

### Analysis

**Current Status**: Not deployed

**Purpose**: Stores configurations for OpenCode agent integration

**Should Deploy?**: YES

**Reasoning**:
- Similar to .claude/, contains development automation
- Users who use OpenCode will need these

**Deployment Recommendation**: SYMLINK
- Add to setup.sh or create pattern for all agent tool directories
- Create ~/.opencode if needed and symlink contents

---

## .bob/ Directory

### Purpose
Bob CLI tool configuration

### Contents

| Item | Purpose | Size |
|------|---------|------|
| installation_id | Bob installation identifier | Small |
| settings.json | Bob tool settings | Config |

### Analysis

**Current Status**: Not deployed

**Purpose**: Stores Bob CLI tool configuration and identity

**Should Deploy?**: YES (conditionally)

**Reasoning**:
- Users with Bob tool will want these settings
- Settings are machine-specific (installation_id might not be portable)

**Deployment Recommendation**: SYMLINK with caveat
- Symlink settings.json
- Consider NOT symlinking installation_id (machine-specific)
- Or create .bob_profile to handle Bob initialization

---

## .specify/ Directory

### Purpose
Specify tool configuration

### Contents: Unknown (not examined)

### Analysis

**Current Status**: Not deployed

**Should Deploy?**: PROBABLY YES

**Recommendation**: INVESTIGATE FIRST
- Examine contents
- Determine if user-portable
- Add to deployment if applicable

---

## .foundations/ Directory

### Purpose
Foundation library/framework configuration

### Contents: Unknown (not examined)

### Analysis

**Current Status**: Not deployed

**Should Deploy?**: PROBABLY YES

**Recommendation**: INVESTIGATE FIRST
- Examine contents
- Determine purpose and portability
- Add to deployment if applicable

---

## .devcontainer/ Directory

### Purpose
Dev Container configuration

### Contents: Docker/container setup files

### Analysis

**Current Status**: Not deployed (intentionally)

**Recommendation**: KEEP REPO-ONLY
- Dev containers are environment-specific
- Should NOT be deployed to home directory
- Meant for VS Code dev container integration
- Located in repo for team use

---

## .dependabot/ Directory

### Purpose
GitHub Dependabot configuration

### Contents: GitHub automation config

### Analysis

**Current Status**: Not deployed (intentionally)

### Recommendation**: KEEP REPO-ONLY
- GitHub-specific infrastructure
- Should NOT be deployed to home directory
- Only relevant within GitHub repository

---

## .vscode/ Directory

### Purpose
VS Code workspace settings

### Contents: Settings, launch configs

### Analysis

**Current Status**: Not deployed

**Should Deploy?**: YES (with consideration)

**Reasoning**:
- VS Code workspace settings define editor behavior
- If stored in repo, all team members get same setup
- Currently system-local (not tracked with repo)

**Deployment Recommendation**: SYMLINK
- Create ~/.vscode as symlink to $DOTFILES_DIR/.vscode
- Ensures consistent VS Code experience across machines
- Allows team alignment on editor settings

---

## .hashicorp/ Directory

### Purpose
HashiCorp tools configuration (Terraform, Vault, Consul, etc.)

### Contents

| Item | Purpose |
|------|---------|
| vault-radar/ | Vault security scanning tool |

### Analysis

**Current Status**: Not deployed

**Should Deploy?**: YES

**Reasoning**:
- Infrastructure team needs HashiCorp tool configs
- Centralizing these in dotfiles ensures consistency

**Deployment Recommendation**: SYMLINK
- Add .hashicorp directory symlink
- Or include in .hashicorp_profile (which already exists!)
- Check if .hashicorp_profile already handles this

---

## .refactor-tracking/ Directory

### Purpose
Project refactoring documentation and tracking

### Contents: Project-specific notes

### Analysis

**Current Status**: Not deployed (intentionally)

**Recommendation**: KEEP REPO-ONLY
- Project-specific tracking
- Should NOT be deployed to home directory
- Part of project documentation, not personal setup

---

## Summary of Findings

### Should DEPLOY (add to setup.sh):

1. **. claude/** - Symlink (Claude integration configs)
2. **.opencode/** - Symlink (OpenCode integration configs)
3. **.bob/** - Symlink with caveat (installation_id may not be portable)
4. **.vscode/** - Symlink (consistent editor settings)
5. **.specify/** - Investigate first, then decide
6. **.foundations/** - Investigate first, then decide
7. **.hashicorp/** - Symlink or rely on .hashicorp_profile

### Should KEEP REPO-ONLY (not deploy):

1. **.git/** - Version control (currently excluded from rsync)
2. **.github/** - GitHub infrastructure
3. **.dependabot/** - GitHub automation
4. **.devcontainer/** - Dev container (repo-specific)
5. **init/** - Terminal/editor preferences (optional, but not auto-deploy)
6. **modules/** - Empty, unclear purpose (needs clarification)
7. **.refactor-tracking/** - Project documentation
8. **common/** - Infrastructure code
9. **docs/** - Documentation
10. **assets/** - Documentation assets
11. **openspec/** - Project workflow tracking

### Requires Investigation:

1. **init/** - Create optional deployment script?
2. **modules/** - What is this for?
3. **.specify/** - What is this?
4. **.foundations/** - What is this?

---

## Deployment Strategy Recommendation

### Option A: Conservative (Minimal changes)
- Don't deploy unclear directories (.specify, .foundations, modules)
- Only deploy proven tool configs (.claude, .opencode, .vscode)
- Add to setup.sh explicitly

### Option B: Comprehensive (Sync all configs)
- Create pattern in setup.sh: "symlink all directories except known repo-only ones"
- Explicitly include: .claude, .opencode, .bob, .vscode, .hashicorp, .specify, .foundations
- Explicitly exclude: .git, .github, .dependabot, .devcontainer
- Add documentation explaining each

### Option C: User-configurable
- Add setup.sh flag: `setup.sh --deploy-tools` to opt-in to tool directory symlinks
- Default behavior: only core dotfiles
- Power users can enable full deployment

**Recommended**: Option A or B
- Option A is safer (less chance of breaking things)
- Option B is more comprehensive (ensures all needed configs follow repo)

---

## Next Steps

1. Decide on deployment strategy (A/B/C)
2. Investigate .specify and .foundations to understand purpose
3. Clarify modules/ purpose
4. Create opt-in setup for init/ (terminal themes/preferences)
5. Update setup.sh with new directory symlinks
6. Document which directories are auto-deployed vs optional
