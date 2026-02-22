# Root File Inventory - Complete Audit

## Overview
Complete inventory of all files and directories in the repository root, organized by category, with deployment status and recommendations.

**Total Items**: ~95 (files + directories + hidden items)
**Files**: ~60+ dotfiles, scripts, configs, markdown
**Directories**: ~18+ infrastructure, documentation, configuration directories

---

## Category 1: Shell Configuration Files (Deployed by setup.sh via symlinks)

### Status: ✅ Fully Handled by setup.sh

| File | Type | Size | Purpose | Deployed? | Recommendation |
|------|------|------|---------|-----------|---|
| .bash_profile | Shell config | 3 KiB | Bash session initialization | ✅ Symlinked | Keep - essential |
| .bashrc | Shell config | 41 B | Bash command-line initialization | ✅ Symlinked | Keep - essential |
| .zshrc | Shell config | 7 KiB | Zsh session initialization | ✅ Symlinked | Keep - essential |
| .exports | Shell config | 1 KiB | Environment variable definitions | ✅ Symlinked | Keep - essential |
| .aliases | Shell config | 7 KiB | Command aliases | ✅ Symlinked | Keep - essential |
| .path | Shell config | 1 KiB | PATH manipulation | ✅ Symlinked | Keep - essential |
| .bash_prompt | Shell config | 3 KiB | Bash prompt customization | ✅ Symlinked | Keep - enhances UX |
| .p10k.zsh | Zsh config | 89 KiB | Powerlevel10k theme config | ✅ Symlinked | Keep - zsh theming |
| .fzf.bash | Shell config | 338 B | Fuzzy finder bash integration | ✅ Symlinked | Keep - nice-to-have |
| .fzf.zsh | Shell config | 511 B | Fuzzy finder zsh integration | ✅ Symlinked | Keep - nice-to-have |
| .hushlogin | Shell config | 241 B | Suppress login message | ✅ Symlinked | Keep - UX enhancement |
| .inputrc | Shell config | 1 KiB | Readline configuration | ✅ Symlinked | Keep - input handling |

---

## Category 2: Language/Ecosystem Profiles (Deployed by setup.sh via symlinks)

### Status: ✅ Fully Handled by setup.sh (22 profiles)

| Profile | Type | Size | Purpose | Deployed? | Recommendation |
|---------|------|------|---------|-----------|---|
| .python_profile | Language mgr | 1 KiB | Python (pyenv) setup | ✅ Symlinked | Keep - essential for Python |
| .ruby_profile | Language mgr | 901 B | Ruby (rbenv) setup | ✅ Symlinked | Keep - essential for Ruby |
| .go_profile | Language mgr | 1 KiB | Go setup (go install) | ✅ Symlinked | Keep - Go support |
| .rust_profile | Language mgr | 88 B | Rust (rustup) setup | ✅ Symlinked | Keep - Rust support |
| .node_profile | Language mgr | 2 KiB | Node.js (npm) setup | ✅ Symlinked | Keep - Node support |
| .perl_profile | Language mgr | 481 B | Perl setup | ✅ Symlinked | Keep - Perl support |
| .uv_profile | Tool mgr | 345 KiB | UV Python tool setup | ✅ Symlinked | Keep - UV support |
| .aws_profile | Cloud | 686 B | AWS CLI setup | ✅ Symlinked | Keep - cloud support |
| .azure_profile | Cloud | 413 B | Azure CLI setup | ✅ Symlinked | Keep - cloud support |
| .gcloud_profile | Cloud | 494 B | Google Cloud CLI setup | ✅ Symlinked | Keep - cloud support |
| .brew_profile | Package mgr | 378 B | Homebrew setup | ✅ Symlinked | Keep - system packages |
| .bob_profile | Tool | 274 B | Bob CLI setup | ✅ Symlinked | Keep - dev tool |
| .claude_profile | AI | 271 B | Claude AI tool setup | ✅ Symlinked | Keep - AI integration |
| .docker_profile | Container | 1 KiB | Docker setup | ✅ Symlinked | Keep - containers |
| .github_profile | Platform | 437 B | GitHub CLI setup | ✅ Symlinked | Keep - GitHub integration |
| .hashicorp_profile | IaC | 26 KiB | HashiCorp tools (Terraform, Vault, etc.) | ✅ Symlinked | Keep - large but essential |
| .instruqt_profile | Learning | 24 KiB | Instruqt lab platform setup | ✅ Symlinked | Keep - learning platform |
| .kubectl_completion | Kubernetes | 388 KiB | kubectl completion/setup | ✅ Symlinked | Keep - K8s support (large) |
| .openai_profile | AI | 178 B | OpenAI CLI setup | ✅ Symlinked | Keep - AI integration |
| .rancher_profile | Container | 889 B | Rancher setup | ✅ Symlinked | Keep - Rancher support |
| .vagrant_profile | IaC | 209 B | Vagrant VM setup | ✅ Symlinked | Keep - VM management |
| .vscode_profile | IDE | 211 B | VS Code setup | ✅ Symlinked | Keep - editor integration |
| .atlassian_profile | Platform | 1 KiB | Atlassian tools setup | ✅ Symlinked | Keep - dev platform |

**Subtotal**: 22 profiles, all symlinked ✅

---

## Category 3: Application Configuration Files (Deployed by setup.sh or bootstrap.sh)

| File | Type | Size | Handler | Deployed? | Recommendation |
|------|------|------|---------|-----------|---|
| .gitconfig | Config | 6 KiB | setup.sh (symlink) | ✅ Symlinked | Keep - essential |
| .curlrc | Config | 266 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - curl config |
| .wgetrc | Config | 1 KiB | bootstrap.sh (rsync) | ✅ Rsync | Keep - wget config |
| .screenrc | Config | 172 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - screen config |
| .tmux.conf | Config | 206 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - tmux config |
| .gvimrc | Config | 214 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - vim config |
| .vimrc | Config | 2 KiB | bootstrap.sh (rsync) | ✅ Rsync | Keep - essential |
| .gdbinit | Config | 29 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - debugger config |
| .editorconfig | Config | 129 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - cross-editor |
| .gitattributes | Git config | 155 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - git config |
| .gitignore | Git config | 574 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - version control |
| .ansible.cfg | Config | 19 KiB | bootstrap.sh (rsync) | ✅ Rsync | Keep - Ansible config |
| .cht.sh.conf | Config | 467 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - cheat sheet config |
| .pre-commit-config.yaml | Config | 450 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - git hooks |
| .hgignore | Config | 240 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - Mercurial config |
| .pip_requirements | Config | 67 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - Python packages |
| .kubectl_completion | Config | 388 KiB | bootstrap.sh (rsync) | ✅ Rsync | Keep - huge but essential |

---

## Category 4: Utility Files

| File | Type | Size | Handler | Deployed? | Recommendation |
|------|------|------|---------|-----------|---|
| .bash_secrets.template | Template | 871 B | setup.sh (cp) | ✅ Copied | Keep - essential security |
| .dotfiles | Symlink | Link | setup.sh | ✅ Symlinked | Keep - convenience |
| .DS_Store | macOS | 6 KiB | Unknown | ❌ Not deployed | Should IGNORE (macOS system file) |
| .functions | Functions | 6 KiB | bootstrap.sh (rsync) | ✅ Rsync | Keep - shell functions |
| .extras | Config | 2 KiB | bootstrap.sh (rsync) | ✅ Rsync | Keep - extra setup |
| .osx | Script | 67 B | bootstrap.sh (excluded!) | ⚠️ Excluded | INTENTIONAL (repo-only tool) |
| .macos | Script | 41 KiB | bootstrap.sh (rsync) | ✅ Rsync | Keep - macOS setup |
| .gitconfig | Config | 6 KiB | setup.sh | ✅ Symlinked | Keep - essential |

---

## Category 5: Documentation (Excluded by bootstrap.sh, Not deployed)

| File | Type | Size | Handler | Deployed? | Recommendation |
|------|------|------|---------|-----------|---|
| README.md | Docs | 6 KiB | - | ❌ Not deployed | INTENTIONAL (repo-only) |
| CHANGELOG.md | Docs | 16 KiB | - | ❌ Not deployed | INTENTIONAL (repo-only) |
| CONTRIBUTING.md | Docs | 11 KiB | - | ❌ Not deployed | INTENTIONAL (repo-only) |
| LICENSE-MIT.txt | License | 1 KiB | - | ❌ Not deployed | INTENTIONAL (repo-only) |
| AGENTS.md | Docs | 13 KiB | - | ❌ Not deployed | INTENTIONAL (repo-only) |
| copilot-instructions.md | Docs | 8 KiB | - | ❌ Not deployed | INTENTIONAL (repo-only) |

---

## Category 6: Shell Scripts (Some deployed, some excluded)

| Script | Type | Size | Handler | Deployed? | Recommendation |
|--------|------|------|---------|-----------|---|
| bootstrap.sh | Executable | 6 KiB | - | ❌ Not deployed | INTENTIONAL (can't overwrite running script) |
| setup.sh | Executable | 17 KiB | - | ❌ Not deployed | INTENTIONAL (repo-only) |
| brew.sh | Shell script | 2 KiB | bootstrap.sh (excluded!) | ⚠️ Excluded | QUESTION: Should this be deployed? |
| brewfile-setup.sh | Shell script | 13 KiB | bootstrap.sh (rsync) | ✅ Rsync | Keep - Homebrew management |
| migrate.sh | Shell script | 13 KiB | bootstrap.sh (rsync) | ✅ Rsync | Keep - migration tool |
| validate-dotfiles.sh | Shell script | 10 KiB | bootstrap.sh (rsync) | ✅ Rsync | Keep - validation tool |
| .macos | Executable script | 41 KiB | bootstrap.sh (rsync) | ✅ Rsync | Keep - macOS setup |

---

## Category 7: Support Configuration Files

| File | Type | Size | Handler | Deployed? | Recommendation |
|------|------|------|---------|-----------|---|
| Makefile | Config | 286 B | bootstrap.sh (rsync) | ✅ Rsync | Keep - build utilities |

---

## Category 8: Directories - Core Infrastructure

| Directory | Purpose | Contents | Deployed? | Recommendation |
|-----------|---------|----------|-----------|---|
| .git/ | Version control | Git history, config | ❌ Not deployed (excluded) | INTENTIONAL (shouldn't be in home) |
| openspec/ | Workflow tracking | Change management | ✅ Partial (repo only) | INTENTIONAL (project-specific) |
| .github/ | GitHub actions | Workflows, templates | ❌ Not deployed | INTENTIONAL (GitHub repo infrastructure) |

---

## Category 9: Directories - Developer Tools & Configuration

| Directory | Purpose | Items | Deployed? | Recommendation |
|-----------|---------|-------|-----------|---|
| .vim/ | Vim configuration | Plugin manager, configs | ✅ Rsync (directory copy) | Keep - essential editor |
| .vscode/ | VS Code settings | Settings, extensions | ❌ NOT DEPLOYED | ⚠️ QUESTION: Should be symlinked to repo configs? |
| bin/ | Scripts/executables | Custom commands | ✅ Rsync (copy files) | Keep - utility scripts |
| common/ | Shared utilities | Build files, helpers | ❌ Not deployed | Repo-only/referenced by scripts |
| modules/ | Plugin modules | Custom modules | ❌ NOT DEPLOYED | ⚠️ QUESTION: Purpose unclear, deserves investigation |
| .functions.d/ | Function modules | Shell scripts | ✅ Copied by setup.sh | Keep - modular functions |
| .zsh.d/ | Zsh modules | Zsh-specific config | ✅ Rsync (directory copy) | Keep - zsh extensions |
| .config/ | App config directory | Various app configs | ✅ Created by setup.sh | Keep - XDG standard |
| .claude/ | Claude AI integration | Configuration files | ❌ NOT DEPLOYED | ⚠️ QUESTION: Should be deployed? |
| .opencode/ | OpenCode integration | Configuration files | ❌ NOT DEPLOYED | ⚠️ QUESTION: Should be deployed? |
| .bob/ | Bob tool config | Configuration | ❌ NOT DEPLOYED | ⚠️ QUESTION: Should be deployed? |
| .specify/ | Specify tool config | Configuration | ❌ NOT DEPLOYED | ⚠️ QUESTION: Should be deployed? |
| .foundations/ | Foundation configs | Configuration | ❌ NOT DEPLOYED | ⚠️ QUESTION: Should be deployed? |
| .devcontainer/ | Dev container config | Container setup | ❌ NOT DEPLOYED | INTENTIONAL (repo-only) |
| .dependabot/ | GitHub dependabot | Config files | ❌ NOT DEPLOYED | INTENTIONAL (GitHub-specific) |
| .hashicorp/ | HashiCorp tools | Config files | ❌ NOT DEPLOYED | ⚠️ QUESTION: Should be deployed? |
| .refactor-tracking/ | Refactoring notes | Documentation | ❌ NOT DEPLOYED | INTENTIONAL (project-only) |

---

## Category 10: Documentation Directories (Not deployed)

| Directory | Purpose | Status | Recommendation |
|-----------|---------|--------|---|
| docs/ | Documentation | ❌ Not deployed | INTENTIONAL (repo-only) |
| assets/ | Documentation assets | ❌ Not deployed (excluded) | INTENTIONAL (repo-only) |
| init/ | ⚠️ PURPOSE UNCLEAR | ❌ Not deployed | NEEDS INVESTIGATION |

---

## Coverage Summary by Handler

### Deployed by setup.sh (symlinks or copy):
- Main dotfiles (12 files)
- All 22 profiles
- .bash_secrets template
- Function modules (.functions.d/)
- Convenience symlinks (.dotfiles, .ssh)
- **Count**: ~40+ items directly handled

### Deployed by bootstrap.sh (rsync):
- Configuration files (15+ files)
- Scripts (migrate.sh, validate-dotfiles.sh, brewfile-setup.sh, .macos)
- Hidden directories (.vim, .zsh.d, and copies of others)
- ALL rsync-deployed items (~40+ files/dirs)
- **Count**: ~40+ items via rsync

### NOT Deployed (Repo-only):
- Documentation (.md files)
- GitHub workflows (.github/, .dependabot/)
- Development tools (common/, modules/, parts of .{config}/)
- Project infrastructure (openspec/, .git/)
- **Count**: ~15+ items

### UNCLEAR / NEEDS INVESTIGATION:
- .vscode/ (should VS Code settings be symlinked?)
- modules/ (what is this for? Should it deploy?)
- init/ (what are these files? Should they deploy?)
- .claude/, .opencode/, .bob/, .specify/, .foundations/ (developer tool configs - unclear if they should deploy)
- .hashicorp/ (tool configs - should they deploy?)
- brew.sh (why excluded from rsync?)

---

## Deployment Gap Analysis

### Files that SHOULD probably be deployed but aren't:

| Item | Current Status | Recommendation | Reasoning |
|------|---|---|---|
| .vscode/ | Not deployed | INVESTIGATE & SYMLINK | VS Code settings should follow repo, not system |
| .claude/ | Not deployed | INVESTIGATE & SYMLINK | Interactive development tool config |
| .opencode/ | Not deployed | INVESTIGATE & SYMLINK | Development agent configuration |
| .bob/ | Not deployed | INVESTIGATE & SYMLINK | Tool configuration |
| .specify/ | Not deployed | INVESTIGATE & SYMLINK | Tool configuration |
| .foundations/ | Not deployed | INVESTIGATE & SYMLINK | Foundation configs probably relevant |
| .hashicorp/ | Not deployed | INVESTIGATE & SYMLINK | Infrastructure code tool configs |
| modules/ | Not deployed | INVESTIGATE FIRST | Unknown purpose - investigate before deploying |
| init/ | Not deployed | INVESTIGATE FIRST | Unclear purpose - terminal themes? - investigate before deploying |

### Files that might NOT need deployment:

| Item | Current Status | Alternative Recommendation |
|---|---|---|
| brew.sh | Not deployed (excluded) | If it's repo-only tool, exclusion is correct |
| .osx | Not deployed (excluded) | If it's repo-only tool, exclusion is correct |
| common/ | Not deployed | If it's only for internal scripts, repo-only is correct |

---

## Investigation Needed

### High Priority:

1. **init/ directory**
   - Current files: Preferences.sublime-settings, Solarized Dark xterm-256color.terminal, Solarized Dark.itermcolors, spectacle.json
   - Question: Are these meant to be deployed to specific locations?
   - Recommendation: Clarify purpose and deployment path

2. **modules/ directory**
   - Current: Unknown contents
   - Question: What is this for? Is it actively used?
   - Recommendation: Document purpose

3. **.vscode/ directory**
   - Current: VS Code workspace settings?
   - Question: Should these follow the repo (symlink)?
   - Recommendation: If yes, create symlinks in setup.sh

### Medium Priority:

4. **Tool configuration directories** (.claude, .opencode, .bob, .specify, .foundations, .hashicorp)
   - Question: Are these user-local or should they follow repo?
   - Recommendation: Classify as "user-local (don't deploy)" or "repo-tracked (deploy as symlinks)"

### Low Priority:

5. **Excluded scripts** (brew.sh, .osx)
   - Verify they are intentionally repo-only

---

## Recommendations Summary

### ✅ Keep Current:
- All shell configuration files (symlinked)
- All 22 language/ecosystem profiles (symlinked)
- All deployed configuration files (rsync)
- .bash_secrets template
- Function modules and helpers

### ⚠️ Investigate & Decide:
- init/ - clarify purpose, add deployment if needed
- modules/ - clarify purpose, add deployment if needed
- Tool config directories - decide if user-local or repo-tracked
- .vscode/ - should follow repo or remain system-local?

### ❌ Keep Repo-Only:
- Documentation files (.md)
- GitHub infrastructure (.github/, .dependabot/)
- Development project files (openspec/, .git/, common/)

### 🔄 Possible Improvements:
- Create local-only mechanism (.local_profile concept) for user-specific configs
- Add documentation about which are safe to edit locally vs which should be synced to repo
- Consider creating symbolic link strategy for .vscode and other IDE-specific configs
- Document why brew.sh and .osx are excluded from rsync

---

## Totals

- **Total root files**: ~63
- **Total root directories**: ~18+
- **Files deployed via setup.sh**: ~40+ (symlinked or copied)
- **Files deployed via bootstrap.sh**: ~40+ (rsync)
- **Files NOT deployed**: ~15+ (repo-only or tool-only)
- **Items needing investigation**: ~10+

---

## Next Steps in Audit

1. ✅ Inventory complete
2. ⏭️ **Deep-dive into unclear directories** (init/, modules/, tool configs)
3. ⏭️ **Generate coverage matrix** (unified view)
4. ⏭️ **Analyze bootstrap.sh necessity** against setup.sh
5. ⏭️ **Create deployment workflow guide**
