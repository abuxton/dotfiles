---
name: changelog-automation
description: "Auto-generate changelogs from git commits and PRs using conventional commits, git-cliff, and GitHub releases."
metadata: {"thinkfleetbot":{"emoji":"📝","requires":{"anyBins":["git","gh"]}}}
---

# Changelog Automation

Generate changelogs from commit history and manage releases.

## Conventional Commits Format

```
<type>[optional scope]: <description>

feat: add user registration
fix: resolve login timeout
docs: update API documentation
refactor: simplify auth middleware
test: add unit tests for payments
chore: update dependencies
perf: optimize database queries
breaking: remove deprecated v1 endpoints
```

## Generate Changelog from Git

### Simple git log approach

```bash
# Changelog since last tag
git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"- %s (%h)" --no-merges

# Grouped by type (conventional commits)
echo "## Features"
git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"- %s (%h)" --no-merges | grep "^- feat"
echo ""
echo "## Bug Fixes"
git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"- %s (%h)" --no-merges | grep "^- fix"
echo ""
echo "## Other"
git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"- %s (%h)" --no-merges | grep -v "^- feat\|^- fix"
```

### Between two tags

```bash
git log v1.0.0..v2.0.0 --pretty=format:"- %s (%an, %h)" --no-merges
```

## git-cliff (Rust-based changelog generator)

```bash
# Generate full changelog
git-cliff -o CHANGELOG.md

# Since last tag
git-cliff --latest -o CHANGELOG.md

# Specific range
git-cliff v1.0.0..v2.0.0

# Prepend to existing changelog
git-cliff --latest --prepend CHANGELOG.md

# Custom template
git-cliff --config cliff.toml -o CHANGELOG.md
```

## GitHub Releases

```bash
# Create release with auto-generated notes
gh release create v2.0.0 --generate-notes

# Create release with custom notes
gh release create v2.0.0 --title "v2.0.0" --notes "$(git-cliff --latest --strip all)"

# Create draft release
gh release create v2.0.0 --draft --generate-notes

# Create pre-release
gh release create v2.0.0-rc1 --prerelease --generate-notes

# List recent releases
gh release list --limit 5

# View release notes
gh release view v2.0.0
```

## PR-Based Changelog

```bash
# List merged PRs since last release
gh pr list --state merged --base main --json number,title,labels,mergedAt \
  --jq '.[] | "- #\(.number) \(.title)"' | head -30

# Grouped by label
echo "## Features"
gh pr list --state merged --base main --label "feature" --json number,title \
  --jq '.[] | "- #\(.number) \(.title)"'
echo ""
echo "## Bug Fixes"
gh pr list --state merged --base main --label "bug" --json number,title \
  --jq '.[] | "- #\(.number) \(.title)"'
```

## Notes

- Conventional commits make automation reliable. Enforce with commitlint in CI.
- `git-cliff` is the most flexible tool. Install: `cargo install git-cliff` or `brew install git-cliff`.
- GitHub's `--generate-notes` uses PR titles and labels — keep PRs well-titled.
- Tag releases consistently: `v1.0.0`, `v1.1.0`, `v2.0.0` (semver).
- Draft releases let you review notes before publishing.
