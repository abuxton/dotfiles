# Proposal: Audit setup.sh Coverage & Bootstrap.sh Necessity

## Why

The dotfiles deployment workflow relies on two scripts (`bootstrap.sh` and `setup.sh`) whose responsibilities overlap and whose coverage of project files is not fully documented. Current state:
- **setup.sh** handles 8+ responsibilities across file symlinks, profiles, and validation, but its complete coverage is unclear
- **bootstrap.sh** performs rsync deployment + oh-my-zsh + npm setup, but we don't know if this is still necessary or if setup.sh supersedes it
- **Root files**: 80+ files/dirs exist in repo - unclear which should be deployed to `$HOME` and by which script
- **Missing coverage**: Some files like `.functions.d/`, shell function modules, and init templates may not be properly deployed

This audit will:
1. Document every file setup.sh handles and why (deployment responsibility matrix)
2. Clarify bootstrap.sh's unique role or recommend consolidation
3. Identify unmapped root files and determine if they need deployment
4. Create clear decision tree: "When should I run bootstrap vs setup?"

## What Changes

- Document complete file coverage for setup.sh (what it deploys, validates, manages)
- Document bootstrap.sh responsibilities and identify any that are unique or superseded
- Create audit report of unmapped root files (files not yet listed in any deployment script)
- Clarify when/if to run bootstrap.sh vs setup.sh
- Produce deployment responsibility matrix (which script owns which files)
- Identify any missing symlinks or deployment steps
- Recommend either: keep both scripts separate with clear purposes OR consolidate into single deployment flow

## Capabilities

### New Capabilities

- `setup-sh-file-coverage`: Complete audit of every file/directory setup.sh currently handles, with rationale for each. Documents the full scope and any gaps.
- `bootstrap-sh-necessity`: Evaluate if bootstrap.sh is a unique first-time-setup script or if its responsibilities can be handled by setup.sh. Determine if it can be deprecated or merged.
- `missing-file-audit`: Review all ~80 root files and identify which ones are candidates for deployment (should go to `$HOME`), which should stay in repo only, and which need new deployment strategy.
- `deployment-workflow-clarity`: Create decision tree and documentation clarifying: "as a new user, what order do I run scripts?" and "what does each script do that the other doesn't?"

### Modified Capabilities

(None - this is purely investigative/clarification work)

## Impact

- **deployment process**: Understanding which script is responsible for which files will improve clarity for new users
- **setup.sh**: May reveal missing file deployments or unnecessary complexity
- **bootstrap.sh**: May reveal it's superseded by setup.sh, or confirm it's needed for first-time setup from blank machine
- **documentation**: Output will feed into README, DEPLOYMENT.md, and CONTRIBUTING.md to clarify user workflow

## Success Criteria

- [x] Complete mapping of all files setup.sh handles (with line references)
- [x] Complete mapping of all files bootstrap.sh handles (with line references)
- [x] Audit report of root files not yet assigned to any deployment script
- [x] Clear determination: bootstrap.sh uniqueness vs redundancy
- [x] Recommendation: keep both scripts or consolidate
- [x] Deployment workflow decision tree created
