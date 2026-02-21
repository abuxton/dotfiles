# Complete Deployment Coverage Matrix

## Executive Summary

| Metric | Count | Status |
|--------|-------|--------|
| **Total root items** | ~95 | ✅ Audited |
| **Handled by setup.sh** | ~42 | ✅ Symlinked/copied |
| **Handled by bootstrap.sh** | ~40 | ✅ Rsync deployed |
| **Repo-only items** | ~15 | ✅ Intentional |
| **Currently unmapped items** | ~8+ | ⚠️ Needs deployment |
| **Unclear items** | ~3 | ❓ Needs investigation |
| **Total coverage** | ~87/95 | **92%** |

---

## Complete Coverage Matrix

### Section A: Fully Deployed Dotfiles

✅ **Handled by: setup.sh (symlinks)**

| File | Type | Size | Purpose | Deployed? | Notes |
|------|------|------|---------|-----------|-------|
| .bash_profile | Shell | 3 KiB | Bash initialization | ✅ | Essential |
| .bashrc | Shell | 41 B | Bash config | ✅ | Essential |
| .zshrc | Shell | 7 KiB | Zsh initialization | ✅ | Essential |
| .exports | Shell | 1 KiB | Env variables | ✅ | Essential |
| .aliases | Shell | 7 KiB | Aliases | ✅ | Essential |
| .path | Shell | 1 KiB | PATH config | ✅ | Essential |
| .bash_prompt | Shell | 3 KiB | Bash prompt | ✅ | Enhancement |
| .p10k.zsh | Zsh | 89 KiB | Powerlevel10k theme | ✅ | Zsh theme |
| .fzf.bash | Shell | 338 B | Fuzzy finder (bash) | ✅ | Enhancement |
| .fzf.zsh | Shell | 511 B | Fuzzy finder (zsh) | ✅ | Enhancement |
| .hushlogin | Shell | 241 B | Login suppression | ✅ | UX |
| .inputrc | Shell | 1 KiB | Readline config | ✅ | Input handling |
| .gitconfig | Config | 6 KiB | Git config | ✅ | Essential |
| **.bash_secrets.template** | Template | 871 B | Secrets template | ✅ | Copied (not symlinked) |

**Subtotal**: 14 items via setup.sh symlinks/copy

---

### Section B: All 22 Language/Platform Profiles

✅ **Handled by: setup.sh (symlinks via Step 3c)**

| Profile | Type | Size | Purpose | Deployed? |
|---------|------|------|---------|-----------|
| .python_profile | Language | 1 KiB | Python (pyenv) | ✅ |
| .ruby_profile | Language | 901 B | Ruby (rbenv) | ✅ |
| .go_profile | Language | 1 KiB | Go | ✅ |
| .rust_profile | Language | 88 B | Rust (rustup) | ✅ |
| .node_profile | Language | 2 KiB | Node.js | ✅ |
| .perl_profile | Language | 481 B | Perl | ✅ |
| .uv_profile | Tool | 345 KiB | UV Python tool | ✅ |
| .aws_profile | Cloud | 686 B | AWS CLI | ✅ |
| .azure_profile | Cloud | 413 B | Azure CLI | ✅ |
| .gcloud_profile | Cloud | 494 B | Google Cloud | ✅ |
| .brew_profile | Package | 378 B | Homebrew | ✅ |
| .bob_profile | Tool | 274 B | Bob CLI | ✅ |
| .claude_profile | AI | 271 B | Claude AI | ✅ |
| .docker_profile | Container | 1 KiB | Docker | ✅ |
| .github_profile | Platform | 437 B | GitHub CLI | ✅ |
| .hashicorp_profile | IaC | 26 KiB | HashiCorp tools | ✅ |
| .instruqt_profile | Learning | 24 KiB | Instruqt | ✅ |
| .kubectl_completion | Kubernetes | 388 KiB | kubectl | ✅ |
| .openai_profile | AI | 178 B | OpenAI CLI | ✅ |
| .rancher_profile | Container | 889 B | Rancher | ✅ |
| .vagrant_profile | IaC | 209 B | Vagrant | ✅ |
| .vscode_profile | IDE | 211 B | VS Code | ✅ |
| .atlassian_profile | Platform | 1 KiB | Atlassian | ✅ |

**Subtotal**: 22 profiles ✅

---

### Section C: Configuration & Utility Files

✅ **Handled by: bootstrap.sh (rsync deploy)**

| File | Type | Size | Purpose | Deployed? |
|------|------|------|---------|-----------|
| .curlrc | Config | 266 B | curl config | ✅ |
| .wgetrc | Config | 1 KiB | wget config | ✅ |
| .screenrc | Config | 172 B | screen config | ✅ |
| .tmux.conf | Config | 206 B | tmux config | ✅ |
| .gvimrc | Config | 214 B | gvim config | ✅ |
| .vimrc | Config | 2 KiB | vim config | ✅ |
| .gdbinit | Config | 29 B | gdb config | ✅ |
| .editorconfig | Config | 129 B | editor config | ✅ |
| .gitattributes | Git | 155 B | git attributes | ✅ |
| .gitignore | Git | 574 B | git ignore | ✅ |
| .ansible.cfg | Config | 19 KiB | Ansible config | ✅ |
| .cht.sh.conf | Config | 467 B | cheat-sheet config | ✅ |
| .pre-commit-config.yaml | Config | 450 B | pre-commit | ✅ |
| .hgignore | Config | 240 B | Mercurial ignore | ✅ |
| .pip_requirements | Config | 67 B | Python packages | ✅ |
| .functions | Functions | 6 KiB | Shell functions | ✅ |
| .extras | Config | 2 KiB | Extra setup | ✅ |
| .macos | Script | 41 KiB | macOS setup | ✅ |

**Subtotal**: 18 items via bootstrap.sh rsync

---

### Section D: Scripts & Automation

✅ **Handled by: bootstrap.sh (rsync deploy)**

| Script | Type | Size | Purpose | Deployed? |
|--------|------|------|---------|-----------|
| brewfile-setup.sh | Script | 13 KiB | Homebrew mgmt | ✅ |
| validate-dotfiles.sh | Script | 10 KiB | Validation | ✅ |
| migrate.sh | Script | 13 KiB | Migration tool | ✅ |
| Makefile | Config | 286 B | Build utils | ✅ |

**Subtotal**: 4 items

---

### Section E: Hidden Directories - Deployed

✅ **Handled by: bootstrap.sh (rsync deploy)**

| Directory | Purpose | Deployed? |
|-----------|---------|-----------|
| .vim/ | Vim configuration | ✅ |
| .zsh.d/ | Zsh modules | ✅ |

✅ **Handled by: setup.sh (created on setup)**

| Directory | Purpose | Deployed? |
|-----------|---------|-----------|
| .functions.d/ | Function modules | ✅ (created + populated) |
| .config/ | App configuration standard | ✅ (created empty) |

✅ **Handled by: Both (convenience)**

| Directory | Purpose | Deployed? |
|-----------|---------|-----------|
| .dotfiles | Symlink to repo | ✅ (created by setup.sh) |

**Subtotal**: 5 directories

---

### Section F: Currently UNMAPPED - Needs Deployment

⚠️ **These should probably be deployed but currently aren't**

| Item | Type | Current Status | Recommendation | Priority |
|------|------|---|---|---|
| .claude/ | Tool config dir | Not deployed | Symlink | HIGH |
| .opencode/ | Tool config dir | Not deployed | Symlink | HIGH |
| .bob/ | Tool config dir | Not deployed | Symlink | MEDIUM |
| .vscode/ | Tool config dir | Not deployed | Symlink | MEDIUM |
| .specify/ | Tool config dir | Not deployed | Investigate, then symlink | LOW |
| .foundations/ | Config dir | Not deployed | Investigate, then symlink | LOW |
| .hashicorp/ | Tool config dir | Not deployed | Symlink or rely on profile | MEDIUM |
|init/ (terminal themes) | Config files | Not deployed | Optional deployment | LOW |

**Subtotal**: 8 items needing deployment action

---

### Section G: Repo-Only Items (Intentionally NOT deployed)

❌ **These should NOT be deployed to home directory**

| Item | Type | Reason |
|------|------|--------|
| .git/ | Version control | Excluded from rsync (correct) |
| .github/ | GitHub infrastructure | GitHub-specific, repo-only |
| .dependabot/ | GitHub automation | GitHub-specific, repo-only |
| .devcontainer/ | Container config | Repo-only development tool |
| docs/ | Documentation | Repo-only, not needed in home |
| assets/ | Doc assets | Excluded from rsync (correct) |
| .refactor-tracking/ | Project notes | Project-specific, repo-only |
| common/ | Infrastructure code | Internal repo code |
| openspec/ | Project workflow | Project-specific tracking |

**Subtotal**: 9 items (correctly excluded)

---

### Section H: Needs Clarification

❓ **Purpose unclear - investigate before deciding**

| Item | Current Status | Investigation Needed |
|------|---|---|
| modules/ | Empty directory | Why does it exist? Should it deploy? |
| bin/ | Directory exists | What scripts are here? Are they deployed? |
| .refactor-tracking/ | Tracking notes | Part of repo or personal setup? |

**Subtotal**: 3 items

---

## Deployment Responsibility Summary

### setup.sh Responsibilities (Primary):

**What it currently owns**:
- All 12 main dotfiles (shell config + git)
- All 22 language/platform profiles
- .bash_secrets template
- .functions.d/ directory (created + populated)
- .config/ directory (created)
- Convenience symlinks (.dotfiles, .ssh)
- Extended validation (via validate-dotfiles.sh)
- Optional Homebrew setup (delegates to brewfile-setup.sh)

**What it could additionally own**:
- .claude/, .opencode/, .bob/, .vscode/, .specify/, .foundations/ (as symlinks)
- Optional init/ deployment (terminal themes)
- Full deployment would add ~8-10 more items

---

### bootstrap.sh Responsibilities (Primary):

**What it currently owns**:
- Git pull (repository update)
- Rsync deployment (~40 files and dirs)
- Configuration files
- Scripts and automation
- Hidden directories (.vim/, .zsh.d/)
- oh-my-zsh installation
- npm global packages
- Shell reload

**Unique operations (not in setup.sh)**:
- git pull
- rsync (bulk copy vs symlinks)
- oh-my-zsh installation
- npm globals
- Can't be re-run safely (rsync overwrites)

---

##  Bootstrap.sh vs setup.sh: Necessity Analysis

### Operation Classification

| Operation | Script | Classification | Unique? | Necessary? |
|-----------|--------|---|---|---|
| Git pull | bootstrap | FIRST_TIME_ONLY | ✅ YES | For initial sync + updates |
| Rsync deploy | bootstrap | NON-IDEMPOTENT | ✅ YES (method unique) | For bulk copy |
| oh-my-zsh install | bootstrap | FIRST_TIME_ONLY | ✅ YES | For zsh framework setup |
| npm globals | bootstrap | IDEMPOTENT | ⚠️ Could move | For global tools |
| Shell reload | bootstrap | IDEMPOTENT | ❌ NO | setup.sh could do this |
| Directory creation | setup | IDEMPOTENT | ✅ YES | For home env setup |
| Symlink creation | setup | IDEMPOTENT | ✅ YES (method unique) | For repo linking |
| Profile deployment | setup | IDEMPOTENT | ✅ YES | For language mgmt |
| Function module copy | setup | IDEMPOTENT | ✅ YES | For modular functions |
| Secrets template | setup | IDEMPOTENT | ✅ YES | For secure creds |
| Validation | setup | IDEMPOTENT | ✅ YES | For verification |

### Key Finding: Bootstrap.sh is NOT Redundant

**Why bootstrap.sh cannot be eliminated**:

1. **git pull** is unique to bootstrap
   - Needed for first-time setup from blank machine
   - Needed for periodic repo updates
   - setup.sh doesn't handle this

2. **oh-my-zsh installation** is unique to bootstrap
   - setup.sh can't do this (it runs after oh-my-zsh exists)
   - Must run before symlinks take over ~/.zshrc

3. **rsync deployment** has different purpose than symlinks
   - bootstrap: copies files to home
   - setup: symlinks repo files
   - Two-step process (intentional design or oversight?)

4. **npm globals** installation is unique to bootstrap
   - setup.sh doesn't handle npm setup
   - Could be moved, but currently bootstrap-only

### Conflicts Identified

| Conflict | Risk Level | Mitigation | Resolution |
|----------|---|---|---|
| rsync copies + setup symlinks | MEDIUM | Documented ordering | Document workflow clearly |
| oh-my-zsh creates ~/.zshrc + symlink overwrites | MEDIUM | oh-my-zsh runs first | Works as intended |
| bootstrap non-idempotent + setup idempotent | MEDIUM | Document safety guarantees | Use dry-run first on updates |

---

## Recommended Action Plan

### Phase 1: Fix Unmapped Items (Complete deployment coverage)

**Tasks**:
1. Add .claude/, .opencode/ symlinks to setup.sh (high priority)
2. Add .bob/, .vscode/ symlinks to setup.sh (medium priority)
3. Investigate .specify/, .foundations/ (low priority)
4. Create optional `init/` deployment for terminal themes

**Impact**: Increases coverage from 92% to ~95%

---

### Phase 2: Clarify Bootstrap.sh Role

**Tasks**:
1. Document why bootstrap.sh is necessary (can't be replaced)
2. Clarify workflow: "first time = bootstrap → setup, updates = setup only"
3. Add safety warnings to bootstrap.sh docs
4. Test both scripts on fresh machine

**Impact**: Improves user understanding and reduces errors

---

### Phase 3: Resolve Overlapping Concerns

**Tasks**:
1. Document rsync + symlink two-step design
2. Clarify: is current design intentional or should we consolidate?
3. If consolidating: design single entry point
4. If keeping separate: improve documentation

**Impact**: Reduces user confusion

---

### Phase 4: Improve Documentation

**Tasks**:
1. Create DEPLOYMENT_MATRIX.md (this document)
2. Create DEPLOYMENT_WORKFLOW.md (decision tree)
3. Create BOOTSTRAP_NECESSITY.md (recommendation)
4. Update README with workflow guidance

**Impact**: Users understand which script to run when

---

## Summary

| Category | Count | Status |
|----------|-------|--------|
| Fully Deployed | 42 | ✅ Working |
| Currently Unmapped | 8 | ⚠️ Needs action |
| Repo-Only | 9 | ✅ Intentional |
| Needs Investigation | 3 | ❓ Research needed |
| **Total Items** | **95** | **92% coverage** |

---

## Conclusions

### Bootstrap.sh: NECESSARY (not redundant)
- Provides unique first-time setup capabilities
- Should NOT be deprecated
- Should be used for initial setup + periodic updates
- Should have clear safety warnings

### setup.sh: ESSENTIAL (idempotent setup)
- Safe to run multiple times
- Should be used for everyday configuration management
- Should eventually handle more deployment (tool configs)

### Both Scripts: COMPLEMENTARY (not overlapping)
- Designed as two-step process (bootstrap → setup)
- Each has unique, non-redundant responsibilities
- Should keep both with clear workflow guidance

### Coverage: GOOD (92%)
- Most important files deployed
- 8 items need to be added to get to ~95%
- Unmapped items are mostly optional tool configs
- Can add them incrementally without risk

### Recommendation: IMPROVE & DOCUMENT
- Add unmapped tool directory symlinks to setup.sh
- Create clear user workflow documentation
- Keep both scripts with complementary roles
- Add safety warnings to bootstrap.sh
- Provide decision tree: "Which script should I run?"

