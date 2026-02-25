# Claude AI - Dotfiles Project Guidance

**For:** Claude Code and Claude AI API
**Type:** Deployable Reference Material

---

## Overview

This file provides Claude-specific guidance for working with the dotfiles project. It's designed to be deployed to your Claude configuration directory and used alongside the main workflow guide.

## Quick Start

### 1. Understand the Workflow

Project use **OpenSpec**, an artifact-driven workflow system. Start here:

```bash
# Main reference (after deployment to $HOME)
cat ./.claude/CLAUDE.md
cat ./AGENTS.md
cat $HOME/AGENTS.md
```

This guide covers:
- Core OpenSpec concepts (Change, Artifact, Schema, Skills)
- Available skill operations (new-change, apply-change, explore, verify-change, archive-change, etc.)
- Workflow patterns (step-by-step, fast-forward, explore-first)
- Common workflows (features, bugs, refactors)

### 2. Access Available Skills

Skills are organized in your project directory:

```bash
# After deployment
ls .claude/skills
ls .opencode/skills/     # All OpenSpec + git-workflow
ls .github/skills/
ls .agent/skills
ls $HOME/.agent/skills
ls $HOME/.opencode/skills/     # All OpenSpec + git-workflow

```

### 3. Use Skills When Appropriate

When you need to discuss:

- **"I want to add/fix/build something"** → Use `openspec-new-change` or `openspec-ff-change`
- **"How do I implement this?"** → Use `openspec-apply-change`
- **"Should we do X or Y?"** → Use `openspec-explore`
- **"Is this complete?"** → Use `openspec-verify-change`
- **"Archive this work"** → Use `openspec-archive-change`
- **"Git branching and commits"** → Use `git-workflow` skill (if available locally)

## Claude-Specific Best Practices

### Understanding Project Context

**The dotfiles project structure:**
- Manages shell configurations, profiles, and setup automation
- Uses OpenSpec for organizing work
- Bootstrap phase → Setup phase → Validation → Optional features
- Key files: `bootstrap.sh`, `setup.sh`, `validate-dotfiles.sh`

**When Claude engages:**
1. Load full project context (all markdown files, shell scripts)
2. Reference AGENTS.md for OpenSpec details
3. Use available skills when appropriate
4. Maintain awareness of idempotency and safety (scripts can fail gracefully)

### Workflow Patterns for Claude

#### Pattern 1: Step-by-Step (Best for Complex Changes)
```
User: "I want to add X to the dotfiles"
Claude: "Let me create a proposal for this work"
  → openspec-new-change
  → "Here's the proposal, does this direction work for you?"
  → (User reviews/revises)
  → openspec-continue-change for specs
  → (Iterative refinement)
  → openspec-apply-change for implementation
  → openspec-verify-change
  → openspec-archive-change
```

#### Pattern 2: Fast-Forward (Best for Straightforward Work)
```
User: "Create shell validation for profile files"
Claude: "I'll create all artifacts at once then implement"
  → openspec-ff-change
  → openspec-apply-change
  → openspec-verify-change
  → openspec-archive-change
```

#### Pattern 3: Explore-First (Best for Uncertain Direction)
```
User: "Should we refactor the profile system?"
Claude: "Let me think through this with you"
  → openspec-explore
  → (Discussion of options, tradeoffs)
  → Decision made
  → openspec-new-change
  → openspec-apply-change
  → openspec-verify-change
  → openspec-archive-change
```

### Code Interaction Best Practices

#### Shell Script Conventions

When working with shell scripts, follow these patterns:

**Script Safety:**
```bash
#!/usr/bin/env bash
set -euo pipefail  # Error handling and strict mode
```

**Logging:**
```bash
log_info() { echo "ℹ $*"; }
log_success() { echo "✓ $*"; }
log_warn() { echo "⚠ $*" >&2; }
log_error() { echo "✗ $*" >&2; }
```

**Dry-Run Support:**
```bash
if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[DRY-RUN] Would execute: $command"
else
  # Execute command
fi
```

**Idempotent Operations:**
- Check state before making changes
- Support repeated runs without side effects
- Back up existing files with timestamps
- Validate at the end

#### Profile-Based Configuration

The project uses profile files for different contexts:
- `.python_profile` - Python environment
- `.ruby_profile` - Ruby environment
- `.node_profile` - Node.js environment
- `.bash_profile`, `.bashrc`, `.zshrc` - Shell configuration

When adding features:
- Create context-specific profile files
- Source from main shell configs conditionally
- Maintain idempotency
- Document dependencies

### Artifact-Driven Thinking

When Claude creates artifacts (proposal, specs, design, tasks):

1. **Proposal** - Answer: What/Why/Who benefits
2. **Specs** - Answer: What are the technical requirements and acceptance criteria
3. **Design** - Answer: How will we implement this (architecture, approach)
4. **Tasks** - Answer: What are the concrete, actionable work items

Each artifact should be:
- Clear and unambiguous
- Actionable by a human or agent
- Connected to previous artifacts
- Sized appropriately (not too big, not too small)

## Deployment Context

This file is designed to be deployed to `$HOME/.claude/CLAUDE.md` where it can:

- Reference `$HOME/AGENTS.md` for the complete workflow guide
- Point to skills in `$HOME/.opencode/skills/` and `$HOME/.github/skills/` and `$HOME/.agent/skills` and `$HOME/.claude/skills`
- Use `$HOME/openspec/` for change management or override with `./openspec`
- Work with any shell environment

**After deployment, use:**
```bash
cd $HOME
cat AGENTS.md              # Full workflow guide
cat .claude/CLAUDE.md      # This file
ls .opencode/skills/       # Available skills
```

## Common Tasks

### Starting a New Feature

```
User: "Add automatic validation for shell scripts"

Claude response:
1. Understand requirements using openspec-new-change
2. Reference AGENTS.md "Adding a New Feature" section
3. Create proposal covering:
   - What validation to add
   - Which scripts to validate
   - How to integrate into setup
4. Refine until approved
5. Create specs and design
6. Implement with openspec-apply-change
```

### Fixing a Bug

```
User: "Bootstrap.sh fails when git is not installed"

Claude response:
1. Use openspec-explore to discuss root cause
2. Create focused change with openspec-new-change
3. Design robust error handling
4. Implement with proper logging
5. Test idempotency
6. Verify and archive
```

### Refactoring Code

```
User: "Consolidate profile sourcing logic"

Claude response:
1. Use openspec-explore to understand current state
2. Create detailed design with openspec-new-change + specs + design
3. Break into focused tasks
4. Implement methodically
5. Validate no behavior changes
6. Archive when verified
```

## References

**Key Documentation:**
- `$HOME/AGENTS.md` - Main OpenSpec workflow guide
- `./AGENTS.md` -  local updates and overrides to workflow guide
- `./`
- `$./.github'/CONTRIBUTING.md` - Contribution guidelines

**Available Skills:**
- `.opencode/skills/openspec-*/SKILL.md` - OpenSpec skill documentation
- `.opencode/skills/git-workflow/SKILL.md` - Git workflow patterns

**Project Structure:**
- `$HOME/openspec/changes/` - Active and archived changes
- `$HOME/openspec/specs/` - Specification files
- `$HOME/openspec/config.yaml` - OpenSpec configuration

## Tips

1. **Always reference AGENTS.md** for the complete workflow guide
2. **Use skills appropriately** - They're available for a reason
3. **Think in artifacts** - Proposal → Specs → Design → Tasks → Implementation
4. **Maintain idempotency** - Scripts should be safe to run multiple times
5. **Be specific about changes** - "Add $FOO to do $BAR" is better than generic requests
6. **Use explore when uncertain** - Better to discuss before implementing
7. **Archive completed work** - Keeps active changes focused
8. **Reference examples** - "Like how bootstrap.sh handles dependencies"

---

**Version:** 1.0
**Last Updated:** February 2026
**Location:** Deploy to `$HOME/.claude/CLAUDE.md`
