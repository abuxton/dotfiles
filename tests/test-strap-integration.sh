#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"

test -x "$repo/script/setup"
test -x "$repo/script/strap-after-setup"

bash -n "$repo/script/setup"
bash -n "$repo/script/strap-after-setup"
bash -n "$repo/setup.sh"

setup_output="$("$repo/script/setup" --dry-run)"
grep -q 'bootstrap.sh --force' <<<"$setup_output"
grep -q 'setup.sh --skip-brew --dry-run' <<<"$setup_output"
grep -q 'deploy-agents.sh --force --dry-run' <<<"$setup_output"

after_output="$("$repo/script/strap-after-setup" --dry-run)"
grep -q 'validate-dotfiles.sh' <<<"$after_output"

printf 'Strap integration tests passed\n'
