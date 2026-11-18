#!/usr/bin/env bash
# ============================================================================
# Opt-in macOS preference deployment
# ============================================================================
#
# .macos contains personal macOS defaults, power settings, Finder/Dock/Safari
# preferences, Spotlight changes, and development-tool conveniences. It is
# intentionally separate from Strap's foundational security and prerequisite
# work because several settings are opinionated or materially invasive.
#
# This wrapper provides the safe boundary:
#
#   macos-setup.sh --dry-run     Validate syntax and print affected commands
#   macos-setup.sh --do-nothing  Print the plan and wait for manual approval
#   macos-setup.sh --apply       Execute .macos
#
# The dry-run is an audit preview, not a simulation: shell commands inside
# .macos are not executed. Review the printed commands before applying.
# ============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR
MACOS_SCRIPT="$DOTFILES_DIR/.macos"
readonly MACOS_SCRIPT
MODE="dry-run"

show_help() {
  cat <<'EOF'
Opt-in macOS preference deployment

USAGE:
  macos-setup.sh --dry-run
  macos-setup.sh --do-nothing
  macos-setup.sh --apply

The default mode is --dry-run. The --apply mode executes .macos.
EOF
}

require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    printf '.macos can only be applied on macOS.\n' >&2
    return 1
  fi
}

show_plan() {
  bash -n "$MACOS_SCRIPT"
  printf 'Audited script: %s\n' "$MACOS_SCRIPT"
  printf 'Potentially changing commands:\n'
  grep -nE '(^|[;[:space:]])(sudo[[:space:]]+)?(defaults[[:space:]]+write|pmset|systemsetup|networksetup|launchctl|mdutil|chflags|osascript|diskutil|ln[[:space:]]+-s|rm[[:space:]]|find[[:space:]])' "$MACOS_SCRIPT" || true
}

main() {
  while (($#)); do
    case "$1" in
      --dry-run) MODE="dry-run" ;;
      --do-nothing) MODE="do-nothing" ;;
      --apply) MODE="apply" ;;
      --help|-h) show_help; return 0 ;;
      *) printf 'Unknown option: %s\n' "$1" >&2; show_help >&2; return 2 ;;
    esac
    shift
  done

  case "$MODE" in
    apply)
      require_macos
      bash "$MACOS_SCRIPT"
      ;;
    dry-run)
      show_plan
      ;;
    do-nothing)
      show_plan
      read -r -p "Press Enter to apply .macos manually, or Ctrl-C to stop: "
      printf 'Manual step: bash %s --apply\n' "$0"
      ;;
  esac
}

main "$@"
