# Example Tool-Specific Profile Template

This template shows how to create and document dependency-aware tool profiles.

## Example: GitHub Profile

```bash
#!/usr/bin/env bash
# ~/.github_profile - GitHub-specific configuration
#
# Dependencies:
#   - Requires: git (in PATH)
#   - Recommends: gh CLI (GitHub's official CLI)
#   - Conflicts: None known
#   - Order: Load after .bash_secrets
#

# GitHub personal access token (from .bash_secrets)
# export GITHUB_TOKEN="..."  ← Already set in .bash_secrets

# GitHub-specific settings
export GITHUB_USER="abuxton"
export GITHUB_DEFAULT_BRANCH="main"

# GitHub CLI configuration
export GH_CONFIG_DIR="$HOME/.config/gh"

# Function to authenticate with GitHub CLI
gh_auth() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "Error: GitHub CLI (gh) not installed"
    return 1
  fi

  # Login if not already authenticated
  if ! gh auth status >/dev/null 2>&1; then
    gh auth login
  fi
}

# Helper to list GitHub repos
gh_repos() {
  gh repo list --limit 100
}
```

## Example: AWS Profile

```bash
#!/usr/bin/env bash
# ~/.aws_profile - AWS-specific configuration
#
# Dependencies:
#   - Requires: AWS Credentials in .bash_secrets
#   - Recommends: aws CLI v2
#   - Conflicts: None known
#   - Order: Load after .bash_secrets
#

# AWS credentials (from .bash_secrets)
# export AWS_ACCESS_KEY_ID="..."      ← Already set in .bash_secrets
# export AWS_SECRET_ACCESS_KEY="..."  ← Already set in .bash_secrets

# AWS defaults
export AWS_REGION="us-west-2"
export AWS_OUTPUT="json"
export AWS_PROFILE="default"

# Helper to switch AWS profile
aws_profile() {
  local profile="$1"
  if [ -z "$profile" ]; then
    echo "Current AWS_PROFILE: $AWS_PROFILE"
    return 0
  fi

  export AWS_PROFILE="$profile"
  echo "Switched to AWS_PROFILE: $profile"
}

# Helper to get current AWS account
aws_account() {
  aws sts get-caller-identity --query "Account" --output text
}
```

## Example: Work/Personal Separation

```bash
#!/usr/bin/env bash
# ~/.work_profile - Work-specific configuration
#
# Dependencies:
#   - Requires: GitHub token in .bash_secrets (GITHUB_TOKEN_WORK)
#   - Optional: AWS profile switching for work account
#   - Conflicts: Personal GitHub profile (set after this one)
#   - Order: Load early, before personal profiles
#

# Work-specific GitHub
export GITHUB_TOKEN="$GITHUB_TOKEN_WORK"
export GITHUB_USER="myname-work"

# Work-specific AWS
export AWS_PROFILE="work"

# Work email for git
git_work_config() {
  git config user.email "name@company.com"
  git config user.name "Name (Work)"
}
```

## Best Practices for Tool Profiles

1. **Document Dependencies**
   ```bash
   # Dependencies:
   #   - Requires: <what must be installed>
   #   - Recommends: <optional enhancements>
   #   - Conflicts: <known conflicts with other profiles>
   #   - Order: <when this profile should load>
   ```

2. **Use Defensive Checks**
   ```bash
   # Check if required program exists
   if ! command -v aws >/dev/null 2>&1; then
     echo "Warning: AWS CLI not installed" >&2
     return 0
   fi
   ```

3. **Source from .bash_secrets When Possible**
   ```bash
   # Store sensitive data in .bash_secrets, reference in profile
   # .bash_secrets already sourced, so variables available
   export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"  # From .bash_secrets
   ```

4. **Lazy Loading for Heavy Operations**
   ```bash
   # Don't initialize expensive operations on shell startup
   # Instead, provide functions users call explicitly

   kubernetes_connect() {
     # Only run if user calls this function
     kubectl config use-context production
   }
   ```

5. **Clear Variable Scope**
   ```bash
   # Set at top for easy discovery
   export MY_TOOL_HOME="/opt/my-tool"

   # Functions with descriptive names
   my_tool_init() { ... }
   my_tool_setup() { ... }
   ```

6. **Provide Diagnostic Helper**
   ```bash
   github_debug() {
     echo "GitHub Profile Status:"
     echo "  GITHUB_USER=$GITHUB_USER"
     echo "  GITHUB_TOKEN_SET=${GITHUB_TOKEN:+yes*}"  # Say yes if set (hide value)
     echo "  gh CLI: $(which gh || echo 'not found')"
     command -v gh >/dev/null && gh auth status
   }
   ```

## Usage Instructions

1. **Copy template and adapt for your tool:**
   ```bash
   cp ~/.github_profile ~/.my_tool_profile
   vim ~/.my_tool_profile  # Edit for your tool
   ```

2. **If conflicts exist between profiles:**
   - Later profiles override earlier ones (last one wins)
   - Organize load order in `.zshrc` or `.bash_profile` if needed

3. **Test profile loads correctly:**
   ```bash
   # Reload shell
   exec zsh

   # Verify variables
   env | grep YOUR_PROFILE_VAR
   ```

4. **Verify no shell startup slowdown:**
   ```bash
   # Time shell startup
   time zsh -i -c exit
   ```

## Migration from Separate Profiles

If you have many separate profile files:

```bash
# Consolidate everything into .bash_secrets for safety
cat ~/.github_profile >> ~/.bash_secrets
cat ~/.aws_profile >> ~/.aws_profile
cat ~/.work_profile >> ~/.bash_secrets

# Remove or archive old files
mkdir ~/.profiles.archive
mv ~/.github_profile ~/.profiles.archive/  # Keep backup
mv ~/.aws_profile ~/.profiles.archive/

# Restart shells
exec zsh
```

---

For shell startup documentation, see [SHELL_CONFIGURATION.md](../docs/SHELL_CONFIGURATION.md).

For shell best practices, see [CONTRIBUTING.md](../CONTRIBUTING.md).
