#!/usr/bin/env bash
# ============================================================================
# Opt-in macOS preference deployment
# ============================================================================
#
# .macos is kept as the source of truth, but this wrapper applies it in
# reviewable phases. Every phase is validated before the next phase starts:
#
#   security -> UI -> power -> Finder -> Safari -> Spotlight
#   -> development tools -> applications
#
# The wrapper provides the safe boundary:
#
#   macos-setup.sh --dry-run     Validate syntax and print each phase
#   macos-setup.sh --do-nothing  Print each phase and pause for manual work
#   macos-setup.sh --apply       Execute and validate every phase
#
# Dry-run is an audit preview, not a simulation: commands inside .macos are
# not executed.
# ============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR
MACOS_SCRIPT="$DOTFILES_DIR/.macos"
readonly MACOS_SCRIPT
MODE="dry-run"
TEMP_DIR=""
PHASES=(
  security
  ui
  power
  finder
  safari
  spotlight
  development-tools
  applications
)

show_help() {
  cat <<'EOF'
Opt-in macOS preference deployment

USAGE:
  macos-setup.sh --dry-run
  macos-setup.sh --do-nothing
  macos-setup.sh --apply

Phases:
  security, ui, power, finder, safari, spotlight,
  development-tools, applications

The default mode is --dry-run. The --apply mode executes and validates every
phase from .macos before continuing to the next phase.
EOF
}

require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    printf '.macos can only be applied on macOS.\n' >&2
    return 1
  fi
}

extract_section() {
  local title="$1"
  awk -v title="$title" '
    BEGIN { pattern = "^# " title "[[:space:]]*#" }
    $0 ~ pattern { in_section = 1 }
    in_section { print }
    in_section && saw_body && $0 ~ /^###############################################################################/ {
      exit
    }
    in_section && $0 !~ /^#/ && $0 !~ /^[[:space:]]*$/ {
      saw_body = 1
    }
  ' "$MACOS_SCRIPT"
}

extract_preamble() {
  awk '
    NR > 2 && /^###############################################################################/ { exit }
    NR > 2 { print }
  ' "$MACOS_SCRIPT"
}

append_section_if_present() {
  local title="$1"
  shift
  local path

  for path in "$@"; do
    if [[ -e "$path" ]]; then
      extract_section "$title"
      return 0
    fi
  done
  return 0
}

write_phase() {
  local phase="$1"
  local output="$2"

  printf '%s\n\n' 'set -euo pipefail' >"$output"
  case "$phase" in
    security)
      extract_preamble >>"$output"
      extract_section "Security" >>"$output"
      ;;
    ui)
      extract_section "General UI/UX" >>"$output"
      extract_section "Trackpad, mouse, keyboard, Bluetooth accessories, and input" >>"$output"
      extract_section "Screen" >>"$output"
      extract_section "Dock, Dashboard, and hot corners" >>"$output"
      ;;
    power)
      extract_section "Energy saving" >>"$output"
      ;;
    finder)
      extract_section "Finder" >>"$output"
      ;;
    safari)
      extract_section "Safari & WebKit" >>"$output"
      ;;
    spotlight)
      extract_section "Spotlight" >>"$output"
      ;;
    development-tools)
      extract_section "Terminal & iTerm 2" >>"$output"
      extract_section "Activity Monitor" >>"$output"
      ;;
    applications)
      extract_section "Mail" >>"$output"
      extract_section "Time Machine" >>"$output"
      extract_section "Address Book, Dashboard, iCal, TextEdit, and Disk Utility" >>"$output"
      extract_section "Mac App Store" >>"$output"
      extract_section "Photos" >>"$output"
      extract_section "Messages" >>"$output"
      append_section_if_present "Google Chrome & Google Chrome Canary" \
        "/Applications/Google Chrome.app" \
        "/Applications/Google Chrome Canary.app" >>"$output"
      append_section_if_present "GPGMail 2" \
        "$HOME/Library/Mail/Bundles/GPGMail.mailbundle" \
        "/Library/Mail/Bundles/GPGMail.mailbundle" >>"$output"
      append_section_if_present "Opera & Opera Developer" \
        "/Applications/Opera.app" \
        "/Applications/Opera Developer.app" >>"$output"
      append_section_if_present "SizeUp.app" \
        "/Applications/SizeUp.app" >>"$output"
      append_section_if_present "Sublime Text" \
        "/Applications/Sublime Text.app" \
        "$DOTFILES_DIR/init/Preferences.sublime-settings" >>"$output"
      append_section_if_present "Spectacle.app" \
        "/Applications/Spectacle.app" \
        "$DOTFILES_DIR/init/spectacle.json" >>"$output"
      append_section_if_present "Transmission.app" \
        "/Applications/Transmission.app" >>"$output"
      extract_section "Kill affected applications" >>"$output"
      ;;
    *)
      printf 'Unknown phase: %s\n' "$phase" >&2
      return 2
      ;;
  esac
}

validation_command() {
  case "$1" in
    security)
      printf '%s\n' 'sudo defaults read /Library/Preferences/com.apple.alf globalstate'
      ;;
    ui)
      printf '%s\n' 'defaults read NSGlobalDomain AppleShowScrollBars'
      ;;
    power)
      printf '%s\n' 'pmset -g custom'
      ;;
    finder)
      printf '%s\n' 'defaults read com.apple.finder AppleShowAllFiles'
      ;;
    safari)
      printf '%s\n' 'defaults read com.apple.Safari IncludeDevelopMenu'
      ;;
    spotlight)
      printf '%s\n' 'defaults read com.apple.spotlight orderedItems'
      ;;
    development-tools)
      printf '%s\n' 'defaults read com.apple.terminal SecureKeyboardEntry'
      ;;
    applications)
      printf '%s\n' 'defaults read com.apple.TimeMachine DoNotOfferNewDisksForBackup'
      ;;
  esac
}

validate_phase() {
  local phase="$1"
  case "$phase" in
    security) sudo defaults read /Library/Preferences/com.apple.alf globalstate >/dev/null ;;
    ui) defaults read NSGlobalDomain AppleShowScrollBars >/dev/null ;;
    power) pmset -g custom >/dev/null ;;
    finder) defaults read com.apple.finder AppleShowAllFiles >/dev/null ;;
    safari) defaults read com.apple.Safari IncludeDevelopMenu >/dev/null ;;
    spotlight) defaults read com.apple.spotlight orderedItems >/dev/null ;;
    development-tools) defaults read com.apple.terminal SecureKeyboardEntry >/dev/null ;;
    applications) defaults read com.apple.TimeMachine DoNotOfferNewDisksForBackup >/dev/null ;;
    *) printf 'Unknown phase: %s\n' "$phase" >&2; return 2 ;;
  esac
}

show_phase_plan() {
  local phase="$1"
  local fragment="$2"

  printf '\n==> %s\n' "$phase"
  printf 'Commands:\n'
  grep -nE '(^|[;[:space:]])(sudo[[:space:]]+)?(defaults[[:space:]]+write|pmset|systemsetup|networksetup|launchctl|mdutil|chflags|osascript|diskutil|ln[[:space:]]+-s|rm[[:space:]]|find[[:space:]])' "$fragment" || true
  printf 'Validation: %s\n' "$(validation_command "$phase")"
}

run_phase() {
  local phase="$1"
  local fragment="$2"

  write_phase "$phase" "$fragment"
  if [[ ! -s "$fragment" ]]; then
    printf 'Phase %s produced no commands.\n' "$phase" >&2
    return 1
  fi

  case "$MODE" in
    apply)
      printf '\n==> Applying %s\n' "$phase"
      (cd "$DOTFILES_DIR" && bash "$fragment")
      validate_phase "$phase"
      printf 'Validated %s\n' "$phase"
      ;;
    dry-run)
      show_phase_plan "$phase" "$fragment"
      ;;
    do-nothing)
      show_phase_plan "$phase" "$fragment"
      read -r -p "Complete the ${phase} phase manually, then press Enter: "
      validate_phase "$phase"
      printf 'Validated %s\n' "$phase"
      ;;
  esac
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

  bash -n "$MACOS_SCRIPT"

  TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/macos-setup.XXXXXX")"
  trap 'rm -rf "$TEMP_DIR"' EXIT

  if [[ "$MODE" == "apply" ]]; then
    require_macos
  fi

  local phase
  for phase in "${PHASES[@]}"; do
    run_phase "$phase" "$TEMP_DIR/${phase}.sh"
  done
}

main "$@"
