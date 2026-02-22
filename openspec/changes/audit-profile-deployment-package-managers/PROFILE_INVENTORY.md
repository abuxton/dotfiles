# Profile Inventory

## Overview

This document catalogs all context-specific profile files (.*_profile) in the dotfiles repository.

| # | Profile | Lines | Size | Purpose | Category | Dependencies |
|---|---------|-------|------|---------|----------|--------------|
| 1 | `.atlasssian_profile` | 33 | 4.0K |  | Other |  |
| 2 | `.aws_profile` | 33 | 4.0K | https://stackoverflow.com/a/53199639/2362673 | Cloud Platforms |  |
| 3 | `.azure_profile` | 33 | 4.0K | azure helpers | Cloud Platforms |  |
| 4 | `.bash_profile` | 33 | 4.0K | Add `~/bin` to the `$PATH` | Other | brew |
| 5 | `.bob_profile` | 33 | 4.0K | TBD | Development Tools | go |
| 6 | `.brew_profile` | 33 | 4.0K | Brew_profile for addiitional paths etc from Brew/C | Package Manager |  |
| 7 | `.claude_profile` | 33 | 4.0K | TBD | Development Tools |  |
| 8 | `.docker_profile` | 33 | 4.0K | alias docker-up='open /Applications/docker.app' | DevOps Tools |  |
| 9 | `.gcloud_profile` | 33 | 4.0K | export GOOGLE_CREDENTIALS=$(cat ${GOOGLE_APPLICATI | Cloud Platforms |  |
| 10 | `.github_profile` | 33 | 4.0K | alias g="git" #cos I is lazy! | Other |  |
| 11 | `.go_profile` | 33 | 4.0K | !/usr/local/bin/go | Language Tools | brew go |
| 12 | `.hashicorp_profile` | 33 |  28K | # | Cloud Platforms | go |
| 13 | `.instruqt_profile` | 33 |  28K | Generate shell auto completion scripts. | Development Tools | brew |
| 14 | `.openai_profile` | 33 | 4.0K | ChatGP-Tea https://github.com/hwixley/ChatGP-Tea | Development Tools |  |
| 15 | `.perl_profile` | 33 | 4.0K | support cpan from brew | Language Tools | brew |
| 16 | `.python_profile` | 33 | 4.0K | eval "$(pyenv init -)" | Language Tools | pyenv |
| 17 | `.rancher_profile` | 33 | 4.0K | Rancher/Docker configuration | Cloud Platforms |  |
| 18 | `.ruby_profile` | 33 | 4.0K | https://github.com/athityakumar/colorls#installati | Language Tools | rbenv gem |
| 19 | `.rust_profile` | 33 | 4.0K | TBD | Language Tools | rustup cargo brew |
| 20 | `.uv_profile` | 33 | 348K | compdef uv | Other |  |
| 21 | `.vagrant_profile` | 33 | 4.0K |  | DevOps Tools |  |
| 22 | `.vscode_profile` | 33 | 4.0K | TBD | Editor/IDE |  |

## Categorization by Domain

### Language Tools
Profiles for programming language version managers and tooling:
- `.python_profile` - Python (pyenv, uv, pip)
- `.ruby_profile` - Ruby (rbenv, gems)
- `.go_profile` - Go (go install, GOPATH)
- `.rust_profile` - Rust (rustup, cargo)

### Package Managers
- `.brew_profile` - Homebrew paths and setup

### Cloud Platforms
- `.aws_profile` - AWS CLI and tools
- `.azure_profile` - Azure CLI and tools
- `.gcloud_profile` - Google Cloud CLI
- `.rancher_profile` - Rancher CLI
- `.hashicorp_profile` - HashiCorp tools (Terraform, Vault, etc.)

### DevOps & Container Tools
- `.docker_profile` - Docker configuration
- `.kubernetes_profile` - Kubernetes/kubectl setup
- `.vagrant_profile` - Vagrant VM management
- `.bob_profile` - Bob (build orchestration?)

### Development & Utilities
- `.claude_profile` - Claude AI integration
- `.openai_profile` - OpenAI API integration
- `.instruqt_profile` - Instruqt learning platform
- `.vscode_profile` - VS Code configuration
- `.uv_profile` - uv Python package manager
- `.githubprofile` - GitHub-specific setup
- `.atlasssian_profile` - Atlassian tools
- `.perl_profile` - Perl environment

## Dependencies Matrix

Profile dependencies on language managers and tools:

```
Profile File        | Requires  | Purpose
--------------------|-----------|------------------------------------------
.python_profile     | pyenv     | Python version management & uv
.ruby_profile       | rbenv     | Ruby version management & colorls
.go_profile         | go        | Go package installations & tools
.rust_profile       | rustup    | Rust toolchain setup
.brew_profile       | brew      | Homebrew paths and additional config
.gcloud_profile     | gcloud    | Google Cloud SDK paths
.aws_profile        | aws       | AWS CLI configuration
.azure_profile      | az        | Azure CLI configuration
.docker_profile     | docker    | Docker daemon and tools
.kubernetes_profile | kubectl   | Kubernetes configuration
```

## Notes

- Profiles are sourced in each shell's rc file (~/.bashrc, ~/.zshrc)
- Some profiles reference external repositories (e.g., Homebrew, oh-my-zsh)
- Several profiles embed package installation logic that could be consolidated
- Order of profile sourcing matters (language managers typically before package installs)
