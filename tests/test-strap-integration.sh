#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"

test -x "$repo/script/setup"
test -x "$repo/script/strap-after-setup"
test -x "$repo/macos-setup.sh"

bash -n "$repo/script/setup"
bash -n "$repo/script/strap-after-setup"
bash -n "$repo/setup.sh"
bash -n "$repo/bootstrap.sh"
bash -n "$repo/macos-setup.sh"

setup_output="$("$repo/script/setup" --dry-run)"
grep -q 'RUNZSH=no CHSH=no bash bootstrap.sh --force --skip-npm' <<<"$setup_output"
grep -q 'setup.sh --skip-brew --dry-run' <<<"$setup_output"
grep -q 'deploy-agents.sh --force --dry-run' <<<"$setup_output"

after_output="$("$repo/script/strap-after-setup" --dry-run --apply-macos)"
grep -q 'npm i -g add-gitignore' <<<"$after_output"
grep -q 'macos-setup.sh --apply' <<<"$after_output"
grep -q 'validate-dotfiles.sh' <<<"$after_output"

macos_output="$("$repo/macos-setup.sh" --dry-run)"
grep -q 'Audited script:' <<<"$macos_output"
grep -q 'defaults write' <<<"$macos_output"

printf 'Strap integration tests passed\n'
