#!/usr/bin/env bash
set -eu

repo=$(cd "$(dirname "$0")/.." && pwd)
test_home=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-startup.XXXXXX")
trap 'rm -rf -- "$test_home"' EXIT

mkdir -p "$test_home/bin" "$test_home/.functions.d" \
  "$test_home/.oh-my-zsh/custom/themes/powerlevel10k" \
  "$test_home/Dropbox/profile/atlassian/.jira"
for file in .zshrc .extras .osx .python_profile .ruby_profile .vagrant_profile .atlasssian_profile; do
  cp "$repo/$file" "$test_home/$file"
done
printf 'fixture\n' > "$test_home/Dropbox/profile/atlassian/jira_api_token.txt"
printf 'fixture\n' > "$test_home/Dropbox/profile/atlassian/.jira/.config.yml"
printf 'autoload -U compinit; compinit -D -i\n' > "$test_home/.oh-my-zsh/oh-my-zsh.sh"
: > "$test_home/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
: > "$test_home/.functions.d/fixture.sh"
printf 'echo uv >> "$HOME/calls"\n' > "$test_home/.uv_profile"

cat > "$test_home/bin/pyenv" <<'EOF'
#!/bin/sh
if [ "$1" = init ]; then
  echo 'pyenv() { command pyenv "$@"; }'
fi
EOF
cat > "$test_home/bin/rbenv" <<'EOF'
#!/bin/sh
echo "rbenv $*" >> "$HOME/calls"
if [ "$1" = init ]; then
  echo 'rbenv() { command rbenv "$@"; }'
fi
EOF
cat > "$test_home/bin/jira" <<'EOF'
#!/bin/sh
echo jira >> "$HOME/calls"
[ "${JIRA_FAIL:-}" != 1 ] || exit 1
echo '# jira completion'
EOF
cat > "$test_home/bin/vagrant" <<'EOF'
#!/bin/sh
echo vagrant >> "$HOME/calls"
EOF
cat > "$test_home/bin/register-python-argcomplete" <<'EOF'
#!/bin/sh
exit 0
EOF
cat > "$test_home/bin/archey" <<'EOF'
#!/bin/sh
echo archey >> "$HOME/calls"
EOF
chmod +x "$test_home/bin/"*

run_shell() {
  env HOME="$test_home" ZDOTDIR="$test_home" PATH="$test_home/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
    TERM_PROGRAM="$1" VSCODE_INJECTION="$2" JIRA_FAIL="${3:-}" \
    /bin/zsh -d -i -c "${4:-:}" > "$test_home/output" 2>&1
}

run_shell Apple_Terminal ''
for city in SFO UTC Berlin India NSW; do
  grep -q "^$city:" "$test_home/output"
done
[ "$(grep -c '^jira$' "$test_home/calls")" -eq 1 ]
[ "$(grep -c '^uv$' "$test_home/calls")" -eq 1 ]
! grep -q '^vagrant$' "$test_home/calls"
! grep -q '^rbenv ' "$test_home/calls"
! grep -q 'Setting up atlassian profile' "$test_home/output"

run_shell vscode ''
! grep -Eq '^(SFO|UTC|Berlin|India|NSW):' "$test_home/output"
[ "$(grep -c '^jira$' "$test_home/calls")" -eq 1 ]
[ "$(grep -c '^archey$' "$test_home/calls")" -eq 1 ]

run_shell Apple_Terminal 1 '' 'rbenv shell test'
! grep -Eq '^(SFO|UTC|Berlin|India|NSW):' "$test_home/output"
grep -q '^rbenv init --no-rehash - zsh$' "$test_home/calls"
grep -q '^rbenv shell test$' "$test_home/calls"

touch -t 202001010000 "$test_home/.config/.jira/.jira_completion"
run_shell vscode '' 1
grep -q 'Failed to generate Jira completion' "$test_home/output"
grep -q '^# jira completion$' "$test_home/.config/.jira/.jira_completion"

cat > "$test_home/bin/date" <<'EOF'
#!/bin/sh
printf '%s|%s\n' "$TZ" "${LC_TIME:-}"
EOF
chmod +x "$test_home/bin/date"
for shell in /bin/bash /bin/zsh; do
  env PATH="$test_home/bin:/usr/bin:/bin" LC_TIME=C "$shell" -c \
    '. "$1"; clocks' _ "$repo/.osx" > "$test_home/output"
  grep -q '^SFO:    US/Pacific|C$' "$test_home/output"
  grep -q '^UTC:    Etc/GMT|C$' "$test_home/output"
  grep -q '^Berlin: Europe/Berlin|C$' "$test_home/output"
  grep -q '^India:  Asia/Calcutta|C$' "$test_home/output"
  grep -q '^NSW:    Australia/Sydney|C$' "$test_home/output"
done

echo 'zsh startup tests passed'
