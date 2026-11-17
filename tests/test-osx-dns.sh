#!/usr/bin/env bash
set -eu

repo=$(cd "$(dirname "$0")/.." && pwd)

if [ "${1:-}" != "--run" ]; then
  for shell in /bin/bash /bin/zsh; do
    "$shell" "$0" --run
  done
  echo 'macOS DNS tests passed'
  exit
fi

test_dir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-dns.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT
HOME="$test_dir"
export HOME
log="$test_dir/calls"
output="$test_dir/output"
mock_dns=$(printf '192.0.2.53\n2001:db8::53')
read_fail=0
set_fail=0

# shellcheck disable=SC2032
networksetup() {
  printf '<%s>' "$@" >> "$log"
  printf '\n' >> "$log"
  if [ "$1" = "-getdnsservers" ]; then
    [ "$read_fail" -eq 0 ] || return 42
    printf '%s\n' "$mock_dns"
  else
    [ "$set_fail" -eq 0 ] || return 42
  fi
}

sudo() {
  "$@"
}

. "$repo/.osx"

assert_call() {
  expected=$1
  shift
  : > "$log"
  printf 'y\n' > "$test_dir/answer"
  dns "$@" < "$test_dir/answer" > "$output" 2>&1
  tail -n 1 "$log" | grep -Fx "$expected" > /dev/null
}

assert_call '<-setdnsservers><Wi-Fi><1.1.1.1><1.0.0.1>' --cloudflare
grep -q 'Created DNS backup' "$output"
hash=$(printf '%s' Wi-Fi | shasum -a 256)
backup="$HOME/.config/dns/${hash%% *}"
printf '%s\n' "$mock_dns" | diff - "$backup"

: > "$log"
if dns --google < /dev/null > "$output" 2>&1; then
  echo 'dns accepted an unanswered backup warning' >&2
  exit 1
fi
grep -q 'backup already exists' "$output"
[ ! -s "$log" ]
printf '%s\n' "$mock_dns" | diff - "$backup"
printf 'n\n' > "$test_dir/answer"
if dns --google < "$test_dir/answer" > "$output" 2>&1; then
  echo 'dns accepted a declined backup warning' >&2
  exit 1
fi
[ ! -s "$log" ]

mock_dns='198.51.100.1'
assert_call '<-setdnsservers><Wi-Fi><1.1.1.1><1.0.0.1>' --unfiltered --cloudflare
grep -q 'backup already exists' "$output"
printf '192.0.2.53\n2001:db8::53\n' | diff - "$backup"
assert_call '<-setdnsservers><Wi-Fi><1.1.1.2><1.0.0.2>' --cloudflare --malware
assert_call '<-setdnsservers><USB Ethernet><8.8.8.8><8.8.4.4>' --service 'USB Ethernet' --google
assert_call '<-setdnsservers><Wi-Fi><208.67.222.222><208.67.220.220>' --opendns
assert_call '<-setdnsservers><Wi-Fi><empty>' --automatic
assert_call '<-getdnsservers><Wi-Fi>' --show
grep -qx '198.51.100.1' "$output"

printf 'invalid backup\n' > "$backup"
: > "$log"
if dns --reset > "$output" 2>&1; then
  echo 'dns accepted an invalid backup' >&2
  exit 1
fi
[ ! -s "$log" ]
[ -f "$backup" ]
printf '192.0.2.53\n2001:db8::53\n' > "$backup"
set_fail=1
if dns --reset > "$output" 2>&1; then
  echo 'dns reported success after restore failed' >&2
  exit 1
fi
[ -f "$backup" ]
set_fail=0
assert_call '<-setdnsservers><Wi-Fi><192.0.2.53><2001:db8::53>' --reset
[ ! -e "$backup" ]
assert_call '<-setdnsservers><USB Ethernet><198.51.100.1>' --reset --service 'USB Ethernet'
if dns --reset > "$output" 2>&1; then
  echo 'dns restored a missing backup' >&2
  exit 1
fi
grep -q 'no DNS backup exists' "$output"

mock_dns="There aren't any DNS Servers set on Wi-Fi."
assert_call '<-setdnsservers><Wi-Fi><8.8.8.8><8.8.4.4>' --google
assert_call '<-setdnsservers><Wi-Fi><empty>' --reset
[ ! -e "$backup" ]

read_fail=1
: > "$log"
if dns --google > "$output" 2>&1; then
  echo 'dns changed settings after reading DNS failed' >&2
  exit 1
fi
[ ! -e "$backup" ]
grep -q 'failed to read DNS' "$output"
if grep -q '<-setdnsservers>' "$log"; then
  echo 'dns changed settings after reading DNS failed' >&2
  exit 1
fi
read_fail=0
mock_dns='unexpected response'
if dns --google > "$output" 2>&1; then
  echo 'dns accepted invalid DNS data' >&2
  exit 1
fi
[ ! -e "$backup" ]
grep -q 'unrecognized DNS data' "$output"

assert_invalid() {
  : > "$log"
  if dns "$@" > "$output" 2>&1; then
    printf 'dns unexpectedly accepted: %s\n' "$*" >&2
    exit 1
  fi
  [ ! -s "$log" ]
  grep -q '^dns:' "$output"
}

assert_invalid --google --malware
assert_invalid --cloudflare --google
assert_invalid --malware --unfiltered --cloudflare
assert_invalid --service
assert_invalid --service --google
assert_invalid --unknown

: > "$log"
dns > "$output"
grep -q '^Usage: dns' "$output"
grep -q -- '--malware' "$output"
grep -q -- '--service NAME.*default: Wi-Fi' "$output"
for help_arg in help -h --help; do
  dns "$help_arg" > "$test_dir/help"
  diff "$output" "$test_dir/help"
done
[ ! -s "$log" ]

mock_dns='192.0.2.53'
set_fail=1
if dns --google > "$output" 2>&1; then
  echo 'dns reported success after networksetup failed' >&2
  exit 1
fi
grep -q '^dns: failed to update DNS' "$output"
[ -f "$backup" ]
read_fail=1
if dns --show > "$output" 2>&1; then
  echo 'dns --show reported success after networksetup failed' >&2
  exit 1
fi
