#!/usr/bin/env bash
# ============================================================================
# deploy-agents.sh - Agent Configuration Deployment
# ============================================================================
#
# PURPOSE:
#   Deploy AI agent configurations to home directory. This script is run
#   AFTER bootstrap.sh and setup.sh to configure local agent environments.
#   It symlinks all agent configuration directories and the primary agents
#   documentation to the home directory for system-wide access.
#
# USAGE:
#   bash deploy-agents.sh           # Run interactive deployment
#   bash deploy-agents.sh --dry-run # Preview changes without applying
#   bash deploy-agents.sh --force   # Deploy without confirmation
#   bash deploy-agents.sh --enable-zsh-plugins # Also update ~/.zshrc plugins array
#   bash deploy-agents.sh -f        # Alias for --force
#   bash deploy-agents.sh --help    # Show this help message
#
# RELATIONSHIP WITH bootstrap.sh AND setup.sh:
#   bootstrap.sh is FIRST  (repo sync + rsync deploy)
#   setup.sh is SECOND     (symlinks + profiles + configuration)
#   deploy-agents.sh is THIRD (agent configs + skill deployment)
#
#   Typical workflow:
#     1. bash bootstrap.sh        ← git pull, rsync, oh-my-zsh, npm globals
#     2. bash setup.sh            ← symlinks, profiles, directories
#     3. bash deploy-agents.sh    ← agent configs, skills, prompts
#     4. Start new shell          ← agents available in $HOME/.agents/
#
# RESPONSIBILITIES:
#
#   1. AGENT CONFIG DIRECTORIES
#      - Symlinks ./agents/.agents/ → ~/.agents/
#      - Symlinks ./agents/.bob/ → ~/.bob/
#      - Symlinks ./agents/.claude/ → ~/.claude/
#      - Symlinks ./agents/.github/ → ~/.github/
#      - Symlinks ./agents/.opencode/ → ~/.opencode/
#      - Creates symlinks for all agent-specific configurations
#      - Backup-safe: existing files backed up before symlinking
#      Full responsibility: All agent configs available at ~/.agents/, etc.
#
#   2. AGENT DOCUMENTATION
#      - Symlinks ./agents/AGENTS.md → $HOME/AGENTS.md
#      - Makes primary agent workflow guide available at home
#      - Enables system-wide reference to agent configuration
#      Full responsibility: $HOME/AGENTS.md available
#
#   3. SKILLS & PROMPTS DEPLOYMENT
#      - Makes deployed skills available at ~/.agents/skills/
#      - Makes deployed prompts available at ~/.agents/prompts/
#      - Makes deployed commands available at ~/.agents/commands/
#      - Includes: OpenSpec skills, git-workflow, domain-specific skills
#      Full responsibility: All skills accessible for agent operations
#
#   4. COMPREHENSIVE VALIDATION
#      - Verifies all symlinks exist and point to correct locations
#      - Validates agent configuration structure
#      - Tests skill availability
#      - Confirms $HOME/AGENTS.md accessibility
#      Full responsibility: Agent deployment is valid and ready
#
#   5. OH MY ZSH AI CLI PLUGINS
#      - Syncs https://github.com/abuxton/ohmyzsh-ai-cli-plugins
#      - Symlinks plugin folders into ~/.oh-my-zsh/custom/plugins/
#      - Deploys claude, codex, and gemini plugin directories
#      - Warns if plugins are not enabled in ~/.zshrc
#      Full responsibility: AI CLI completion plugins are available to oh-my-zsh
#
# DEPLOYMENT PHASES:
#   Phase 1: Parse arguments & validate environment
#   Phase 2: Validate dotfiles directory exists
#   Phase 3: Create symlinks for agent config directories
#   Phase 4: Create symlink for AGENTS.md
#   Phase 5: Deploy oh-my-zsh AI CLI plugins
#   Phase 6: Validate all symlinks and permissions
#   Phase 7: Display deployment summary
#
# ============================================================================

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

# Get script directory and dotfiles path
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="${SCRIPT_DIR}"
AGENTS_DIR="${DOTFILES_DIR}/agents"
AI_ZSH_PLUGIN_REPO_URL="https://github.com/abuxton/ohmyzsh-ai-cli-plugins.git"
AI_ZSH_PLUGIN_CACHE_DIR="${HOME}/.cache/ohmyzsh-ai-cli-plugins"
OH_MY_ZSH_CUSTOM_PLUGINS_DIR="${HOME}/.oh-my-zsh/custom/plugins"
AI_ZSH_PLUGIN_NAMES=("claude" "codex" "gemini")

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
DRY_RUN=false
FORCE=false
VERBOSE=false
ENABLE_ZSH_PLUGINS=false

# Counters
SYMLINKS_CREATED=0
SYMLINKS_SKIPPED=0
SYMLINKS_UPDATED=0
ERRORS=0
ZSH_PLUGINS_READY=0
ZSH_PLUGINS_SKIPPED=0
ZSH_PLUGINS_ENABLED=0
ZSH_PLUGINS_ENABLE_SKIPPED=0

# ============================================================================
# Functions
# ============================================================================

log() {
    echo -e "${BLUE}[agents]${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*"
    ((ERRORS++))
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}   ${NC} $*"
    fi
}

# Create symlink with backup and idempotency
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"

    # Check if source exists
    if [[ ! -e "$source" ]]; then
        error "Source does not exist: $source"
        return 1
    fi

    # Handle existing target
    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            # Is a symlink - check if it points to the right place
            local current_target=$(readlink "$target")
            if [[ "$current_target" == "$source" ]]; then
                log_verbose "Symlink already correct: $name"
                ((SYMLINKS_SKIPPED++))
                return 0
            else
                # Points to wrong location - update it
                log_verbose "Updating symlink: $name ($current_target → $source)"
                if [[ "$DRY_RUN" != true ]]; then
                    rm "$target"
                    ln -s "$source" "$target"
                fi
                ((SYMLINKS_UPDATED++))
                return 0
            fi
        else
            # Is a regular file/directory - back it up
            local backup_dir="${HOME}/.dotfiles.backup"
            local backup_path="${backup_dir}/$(basename "$target").$(date +%s).bak"
            warning "Target exists and is not a symlink: $target"

            if [[ "$DRY_RUN" != true ]]; then
                mkdir -p "$backup_dir"
                mv "$target" "$backup_path"
                log_verbose "Backed up to: $backup_path"
                ln -s "$source" "$target"
            fi
            ((SYMLINKS_CREATED++))
            return 0
        fi
    else
        # Target doesn't exist - create symlink
        log_verbose "Creating symlink: $name"
        if [[ "$DRY_RUN" != true ]]; then
            ln -s "$source" "$target"
        fi
        ((SYMLINKS_CREATED++))
        return 0
    fi
}

# Validate symlink
validate_symlink() {
    local target="$1"
    local name="$2"

    if [[ ! -L "$target" ]]; then
        error "Not a symlink: $target ($name)"
        return 1
    fi

    local source=$(readlink "$target")
    if [[ ! -e "$source" ]]; then
        error "Symlink target does not exist: $target → $source"
        return 1
    fi

    success "Verified: $name"
    return 0
}

zshrc_has_plugin() {
    local plugin="$1"
    local zshrc_file="${HOME}/.zshrc"

    if [[ ! -f "$zshrc_file" && ! -L "$zshrc_file" ]]; then
        return 1
    fi

    if grep -q "^[[:space:]]*${plugin}[[:space:]]*$" "$zshrc_file"; then
        return 0
    fi

    if grep -q "^plugins=(.*${plugin}.*)" "$zshrc_file"; then
        return 0
    fi

    return 1
}

deploy_ohmyzsh_ai_plugins() {
    local repo_url="$AI_ZSH_PLUGIN_REPO_URL"
    local cache_dir="$AI_ZSH_PLUGIN_CACHE_DIR"
    local plugin_root="$OH_MY_ZSH_CUSTOM_PLUGINS_DIR"
    local plugin source target

    if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
        warning "oh-my-zsh not found at ${HOME}/.oh-my-zsh; skipping AI CLI plugin deployment"
        ((ZSH_PLUGINS_SKIPPED+=${#AI_ZSH_PLUGIN_NAMES[@]}))
        return 0
    fi

    if ! command -v git >/dev/null 2>&1; then
        warning "git command not found; skipping AI CLI plugin deployment"
        ((ZSH_PLUGINS_SKIPPED+=${#AI_ZSH_PLUGIN_NAMES[@]}))
        return 0
    fi

    log ""
    log "Deploying Oh My Zsh AI CLI plugins..."

    if [[ "$DRY_RUN" == true ]]; then
        log_verbose "Would sync plugin repo: ${repo_url} -> ${cache_dir}"
        for plugin in "${AI_ZSH_PLUGIN_NAMES[@]}"; do
            log_verbose "Would create symlink: ${plugin_root}/${plugin} -> ${cache_dir}/${plugin}"
        done
        return 0
    else
        if [[ -d "${cache_dir}/.git" ]]; then
            log_verbose "Updating cached plugin repository: ${cache_dir}"
            if ! git -C "$cache_dir" pull --ff-only >/dev/null 2>&1; then
                warning "Failed to update ${cache_dir}; keeping existing local copy"
            fi
        else
            log_verbose "Cloning plugin repository: ${repo_url}"
            mkdir -p "$(dirname "$cache_dir")"
            if ! git clone "$repo_url" "$cache_dir" >/dev/null 2>&1; then
                error "Failed to clone plugin repository: ${repo_url}"
                ((ZSH_PLUGINS_SKIPPED+=${#AI_ZSH_PLUGIN_NAMES[@]}))
                return 1
            fi
        fi
    fi

    if [[ "$DRY_RUN" != true ]]; then
        mkdir -p "$plugin_root"
    fi

    for plugin in "${AI_ZSH_PLUGIN_NAMES[@]}"; do
        source="${cache_dir}/${plugin}"
        target="${plugin_root}/${plugin}"

        if [[ ! -d "$source" ]]; then
            warning "Plugin source not found: $source"
            ((ZSH_PLUGINS_SKIPPED++))
            continue
        fi

        if create_symlink "$source" "$target" "oh-my-zsh plugin: ${plugin}"; then
            ((ZSH_PLUGINS_READY++))
            if ! zshrc_has_plugin "$plugin"; then
                warning "Plugin '${plugin}' is deployed but not enabled in ~/.zshrc plugins array"
            fi
        else
            ((ZSH_PLUGINS_SKIPPED++))
        fi
    done
}

enable_ohmyzsh_plugins_in_zshrc() {
    local zshrc_file="${HOME}/.zshrc"
    local plugin temp_file

    if [[ "$ENABLE_ZSH_PLUGINS" != true ]]; then
        return 0
    fi

    log ""
    log "Updating ~/.zshrc plugins array..."

    if [[ ! -f "$zshrc_file" && ! -L "$zshrc_file" ]]; then
        warning "~/.zshrc not found; cannot enable plugins automatically"
        ((ZSH_PLUGINS_ENABLE_SKIPPED+=${#AI_ZSH_PLUGIN_NAMES[@]}))
        return 0
    fi

    if ! grep -q "^plugins=(" "$zshrc_file"; then
        warning "No plugins=(...) block found in ~/.zshrc; please add plugins manually"
        ((ZSH_PLUGINS_ENABLE_SKIPPED+=${#AI_ZSH_PLUGIN_NAMES[@]}))
        return 0
    fi

    for plugin in "${AI_ZSH_PLUGIN_NAMES[@]}"; do
        if zshrc_has_plugin "$plugin"; then
            log_verbose "~/.zshrc already contains plugin: ${plugin}"
            ((ZSH_PLUGINS_ENABLE_SKIPPED++))
            continue
        fi

        if [[ "$DRY_RUN" == true ]]; then
            log_verbose "Would add '${plugin}' to ~/.zshrc plugins array"
            ((ZSH_PLUGINS_ENABLED++))
            continue
        fi

        temp_file=$(mktemp)

        # Single-line plugins=(git brew ...)
        if grep -q "^plugins=(.*)" "$zshrc_file"; then
            sed "s/^plugins=(\(.*\))/plugins=(\1 ${plugin})/" "$zshrc_file" > "$temp_file"
        else
            # Multi-line plugins=( ... )
            awk -v plugin="$plugin" '
                /^plugins=\(/ { in_plugins=1 }
                in_plugins && /^\)/ {
                    print "  " plugin
                    in_plugins=0
                }
                { print }
            ' "$zshrc_file" > "$temp_file"
        fi

        cat "$temp_file" > "$zshrc_file"
        rm -f "$temp_file"
        success "Enabled plugin in ~/.zshrc: ${plugin}"
        ((ZSH_PLUGINS_ENABLED++))
    done
}

show_help() {
    cat << EOF
${BLUE}deploy-agents.sh${NC} - Deploy agent configurations to home directory

${BLUE}USAGE:${NC}
  bash deploy-agents.sh [OPTIONS]

${BLUE}OPTIONS:${NC}
  --dry-run      Preview changes without applying
  --force, -f    Deploy without confirmation
    --enable-zsh-plugins  Add claude/codex/gemini to ~/.zshrc plugins array
  -v, --verbose  Show detailed output
  -h, --help     Show this help message

${BLUE}EXAMPLES:${NC}
  bash deploy-agents.sh        # Interactive deployment
  bash deploy-agents.sh --dry-run   # Preview first
  bash deploy-agents.sh --force     # Deploy without prompts
    bash deploy-agents.sh --enable-zsh-plugins

${BLUE}DESCRIPTION:${NC}
  Deploys AI agent configurations from agents/ to the home directory.

  Creates symlinks for:
    - ~/.agents/     (OpenSpec and domain-specific skills)
    - ~/.bob/        (Bob agent configuration)
    - ~/.claude/     (Claude agent configuration)
    - ~/.github/     (GitHub Copilot configuration)
    - ~/.opencode/   (OpenCode CLI configuration)
    - ~/AGENTS.md    (Primary agent workflow documentation)

  Symlinks are idempotent - safe to run multiple times.

${BLUE}WORKFLOW:${NC}
  1. bash bootstrap.sh      ← First: repo sync + initial deployment
  2. bash setup.sh          ← Second: dotfiles + profiles
  3. bash deploy-agents.sh  ← Third: agent configurations
  4. New shell              ← Agents ready in ~/.agents/

${BLUE}REFERENCE:${NC}
  See ~/AGENTS.md for complete agent workflow documentation.

EOF
}

# ============================================================================
# Main Script
# ============================================================================

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            VERBOSE=true
            shift
            ;;
        --force|-f)
            FORCE=true
            shift
            ;;
        --enable-zsh-plugins)
            ENABLE_ZSH_PLUGINS=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# ============================================================================
# Validation
# ============================================================================

log "Agent Configuration Deployment"
log "=============================="

# Check if agents directory exists
if [[ ! -d "$AGENTS_DIR" ]]; then
    error "Agents directory not found: $AGENTS_DIR"
    exit 1
fi

# Check if AGENTS.md exists
if [[ ! -f "$AGENTS_DIR/AGENTS.md" ]]; then
    error "AGENTS.md not found: $AGENTS_DIR/AGENTS.md"
    exit 1
fi

# Validate agent config directories exist
declare -a AGENT_DIRS=(".agents" ".bob" ".claude" ".github" ".opencode")
for dir in "${AGENT_DIRS[@]}"; do
    if [[ ! -d "$AGENTS_DIR/$dir" ]]; then
        error "Agent directory not found: $AGENTS_DIR/$dir"
    fi
done

if [[ $ERRORS -gt 0 ]]; then
    exit 1
fi

# ============================================================================
# Preview Deployment Plan (shown for all modes)
# ============================================================================

echo ""
log "Deployment Plan:"
log "================="

log ""
log "Agent configurations will be deployed to:"
for dir in "${AGENT_DIRS[@]}"; do
    echo "  - ${HOME}/${dir} ← ${AGENTS_DIR}/${dir}"
done
echo "  - ${HOME}/AGENTS.md ← ${AGENTS_DIR}/AGENTS.md"
echo ""

log "Deployed resources:"
echo "  • ~/.agents/skills/     - All available skills"
echo "  • ~/.agents/prompts/    - Agent-specific prompts"
echo "  • ~/.agents/commands/   - CLI command definitions"
echo "  • ~/.oh-my-zsh/custom/plugins/{claude,codex,gemini}/ - AI CLI completions"
echo "  • ~/AGENTS.md           - Workflow documentation"
echo ""

log "Oh My Zsh plugin source repository:"
echo "  - ${AI_ZSH_PLUGIN_REPO_URL}"
echo ""

if [[ "$ENABLE_ZSH_PLUGINS" == true ]]; then
    log "Zsh plugin auto-enable mode: enabled"
    echo "  - ~/.zshrc plugins array will be updated for: ${AI_ZSH_PLUGIN_NAMES[*]}"
    echo ""
fi

# ============================================================================
# Confirmation (only in interactive mode)
# ============================================================================

if [[ "$DRY_RUN" == true ]]; then
    log "${YELLOW}DRY RUN MODE${NC} - Preview complete. No changes will be applied."
    log "Run without --dry-run to apply changes."
elif [[ "$FORCE" != true ]]; then
    read -p "Continue with deployment? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Deployment cancelled."
        exit 0
    fi
else
    log "Force mode: Skipping confirmation prompt."
fi

# ============================================================================
# Deploy Agent Config Directories
# ============================================================================

log ""
log "Creating agent configuration symlinks..."

for dir in "${AGENT_DIRS[@]}"; do
    source="${AGENTS_DIR}/${dir}"
    target="${HOME}/${dir}"
    log_verbose "Processing: $dir"
    create_symlink "$source" "$target" "$dir" || true
done

# ============================================================================
# Deploy AGENTS.md
# ============================================================================

log ""
log "Creating AGENTS.md symlink..."
source="${AGENTS_DIR}/AGENTS.md"
target="${HOME}/AGENTS.md"
create_symlink "$source" "$target" "AGENTS.md" || true

# ============================================================================
# Deploy Oh My Zsh AI CLI Plugins
# ============================================================================

deploy_ohmyzsh_ai_plugins || true
enable_ohmyzsh_plugins_in_zshrc || true

# ============================================================================
# Validation
# ============================================================================

# Only validate if not in dry-run mode (symlinks won't exist in dry-run)
if [[ "$DRY_RUN" != true ]]; then
    log ""
    log "Validating deployment..."

    for dir in "${AGENT_DIRS[@]}"; do
        target="${HOME}/${dir}"
        validate_symlink "$target" "$dir" || true
    done

    target="${HOME}/AGENTS.md"
    validate_symlink "$target" "AGENTS.md" || true

    if [[ -d "${HOME}/.oh-my-zsh" ]]; then
        for plugin in "${AI_ZSH_PLUGIN_NAMES[@]}"; do
            target="${OH_MY_ZSH_CUSTOM_PLUGINS_DIR}/${plugin}"
            if [[ -e "$target" || -L "$target" ]]; then
                validate_symlink "$target" "oh-my-zsh plugin: ${plugin}" || true
            fi
        done
    fi
fi

# ============================================================================
# Summary
# ============================================================================

log ""
log "Deployment Summary"
log "=================="
log_verbose "Symlinks created:    $SYMLINKS_CREATED"
log_verbose "Symlinks skipped:    $SYMLINKS_SKIPPED"
log_verbose "Symlinks updated:    $SYMLINKS_UPDATED"

if [[ $ERRORS -gt 0 ]]; then
    error "Errors encountered:  $ERRORS"
    exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
    log ""
    success "Dry run complete."
    log ""
    log "What would be deployed:"
    log "  Source directories:"
    for dir in "${AGENT_DIRS[@]}"; do
        log "    ${AGENTS_DIR}/${dir}/"
    done
    log "    ${AGENTS_DIR}/AGENTS.md"
    log "    ${AI_ZSH_PLUGIN_CACHE_DIR}/{claude,codex,gemini}/"
    if [[ "$ENABLE_ZSH_PLUGINS" == true ]]; then
        log "    ~/.zshrc plugins=(...) block"
    fi
    log ""
    log "  Symbolic links to create:"
    for dir in "${AGENT_DIRS[@]}"; do
        log "    ${HOME}/${dir} → ${AGENTS_DIR}/${dir}"
    done
    log "    ${HOME}/AGENTS.md → ${AGENTS_DIR}/AGENTS.md"
    log "    ${OH_MY_ZSH_CUSTOM_PLUGINS_DIR}/{claude,codex,gemini} → ${AI_ZSH_PLUGIN_CACHE_DIR}/{claude,codex,gemini}"
    if [[ "$ENABLE_ZSH_PLUGINS" == true ]]; then
        log "    ~/.zshrc updated to include: ${AI_ZSH_PLUGIN_NAMES[*]}"
    fi
    log ""
    log "${YELLOW}No changes were applied in dry-run mode.${NC}"
    log "Run 'bash deploy-agents.sh' to apply, or 'bash deploy-agents.sh --force' to skip confirmation."
else
    log ""
    success "Agent configurations deployed successfully!"
    log ""
    log "Agent resources are now available at:"
    log "  - ~/.agents/skills/        (OpenSpec and domain-specific skills)"
    log "  - ~/.agents/prompts/       (Agent prompts and templates)"
    log "  - ~/.agents/commands/      (CLI command definitions)"
    log "  - ~/.oh-my-zsh/custom/plugins/claude"
    log "  - ~/.oh-my-zsh/custom/plugins/codex"
    log "  - ~/.oh-my-zsh/custom/plugins/gemini"
    log "  - ~/AGENTS.md              (Workflow documentation)"
    log ""
    log "Oh My Zsh AI plugins ready: ${ZSH_PLUGINS_READY}"
    log "Oh My Zsh AI plugins skipped: ${ZSH_PLUGINS_SKIPPED}"
    if [[ "$ENABLE_ZSH_PLUGINS" == true ]]; then
        log "Oh My Zsh plugins enabled in ~/.zshrc: ${ZSH_PLUGINS_ENABLED}"
        log "Oh My Zsh plugin enables skipped: ${ZSH_PLUGINS_ENABLE_SKIPPED}"
    fi
    log ""
    log "Verify deployment:"
    log "  ls -la ~/.agents/"
    log "  ls -la ~/.oh-my-zsh/custom/plugins/"
    log "  cat ~/AGENTS.md"
    log ""
    log "Next steps:"
    log "  1. Review ~/.agents/ structure"
    log "  2. Configure agent-specific settings in ~/.agents/settings.json"
    log "  3. Start using agents with: copilot, claude, opencode, etc."
    log ""
    log "Reference: See ~/AGENTS.md for complete documentation"
fi

exit 0
